package com.impaktek.impak_thermal_printer.impak_thermal_printer

import android.Manifest
import android.app.Activity
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothSocket
import android.content.Context
import android.content.pm.PackageManager
import android.hardware.usb.UsbDevice
import android.hardware.usb.UsbManager
import android.os.Build
import androidx.annotation.NonNull
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.OutputStream
import java.util.*
import android.util.Log
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import kotlinx.coroutines.launch

/** ImpakThermalPrinterPlugin */
class ImpakThermalPrinterPlugin: FlutterPlugin, MethodCallHandler, ActivityAware {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var context: Context
  private var activity: Activity? = null
  private var bluetoothSocket: BluetoothSocket? = null
  private var outputStream: OutputStream? = null

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "impak_thermal_printer")
    channel.setMethodCallHandler(this)
    context = flutterPluginBinding.applicationContext
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      "GET_PAIRED_DEVICES" -> {
        if (checkAndRequestBluetoothPermission()) {
          getPairedBluetoothDevices(result)
        } else {
          result.error("PERMISSION_DENIED", "Bluetooth permission is required", null)
        }
      }
      "CONNECT_BLUETOOTH" -> {
        val address = call.argument<String>("address")
        if (address != null) {
          if (checkAndRequestBluetoothPermission()) {
            connectBluetoothPrinter(address, result)
          } else {
            result.error("PERMISSION_DENIED", "Bluetooth permission is required", null)
          }
        } else {
          result.error("INVALID_ADDRESS", "Bluetooth address is required", null)
        }
      }
      "CONNECTION_STATUS"-> {
        CoroutineScope(Dispatchers.IO).launch{
          if(outputStream != null) {
            try{
              outputStream?.run {
                write(" ".toByteArray())
                result.success(true)
              }
            }catch (e: Exception){
              result.success(false)
              outputStream = null
            }
          }else{
            result.success(false)
          }
        }

      }
      "PRINT" -> {
        CoroutineScope(Dispatchers.IO).launch{
          var list = call.argument<List<Int>>("bytes")

          if(list != null){
            writeBytes(list, result)
          }else {
            result.error("INVALID_BYTES", "Bytes to print is required", false)
          }
        }


      }
      "DISCONNECT_BLUETOOTH" -> {
        disconnectPrinter(result)
      }
      "GET_PLATFORM_VERSION" -> {
        result.success("Android ${android.os.Build.VERSION.RELEASE}")
      }
      else -> {
        result.notImplemented()
      }
    }
  }

  private fun writeBytes(rawBytes: List<Int>, result: Result) {
    CoroutineScope(Dispatchers.IO).launch{
      if(outputStream != null) {
        var bytes: ByteArray = "\n".toByteArray()

        rawBytes.forEach {
          bytes += it.toByte()
        }
        try{
          outputStream?.write(bytes)
          result.success(true)
        }catch (e: Exception){
          result.success(false)
          outputStream = null
        }
      }else{
        result.success(false)
      }
    }
  }

  private fun checkAndRequestBluetoothPermission(): Boolean {

    val currentActivity = activity ?: return false

    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
      if (ContextCompat.checkSelfPermission(currentActivity, Manifest.permission.BLUETOOTH_CONNECT) != PackageManager.PERMISSION_GRANTED) {
        ActivityCompat.requestPermissions(
          currentActivity,
          arrayOf(
            Manifest.permission.BLUETOOTH_CONNECT,
            Manifest.permission.BLUETOOTH_SCAN
          ),
          0
        )
        return false
      }
    } else {
      if (ContextCompat.checkSelfPermission(currentActivity, Manifest.permission.BLUETOOTH) != PackageManager.PERMISSION_GRANTED) {
        ActivityCompat.requestPermissions(
          currentActivity,
          arrayOf(Manifest.permission.BLUETOOTH),
          0
        )
        return false
      }
    }
    return true
  }

  private fun getPairedBluetoothDevices(result: Result) {
    CoroutineScope(Dispatchers.IO).launch{
      try {
        val bluetoothAdapter = BluetoothAdapter.getDefaultAdapter()
        if (bluetoothAdapter == null) {
          result.error("BLUETOOTH_NOT_AVAILABLE", "Bluetooth is not available on this device", null)
          return@launch
        }

        val pairedDevices = bluetoothAdapter.bondedDevices
        val deviceList = mutableListOf<String>()

        for (device in pairedDevices) {
          if(device.address != null){
            deviceList.add("${device.name ?: "Unknown Device"}#${device.address}")
          }
        }

        result.success(deviceList)
      } catch (e: Exception) {
        result.error("BLUETOOTH_ERROR", e.message, null)
      }
    }
  }

  private fun connectBluetoothPrinter(address: String, result: Result) {
    CoroutineScope(Dispatchers.IO).launch{
      try {
        val bluetoothAdapter = BluetoothAdapter.getDefaultAdapter()
        if (bluetoothAdapter == null) {
          result.error("BLUETOOTH_NOT_AVAILABLE", "Bluetooth is not available on this device", null)
          return@launch
        }
        bluetoothSocket?.close()
        outputStream?.close()
        val device = bluetoothAdapter.getRemoteDevice(address)
        bluetoothSocket = device.createInsecureRfcommSocketToServiceRecord(UUID.fromString("00001101-0000-1000-8000-00805F9B34FB"))
        bluetoothSocket?.connect()
        outputStream = bluetoothSocket?.outputStream
        result.success(true)
      } catch (e: Exception) {
        result.error("CONNECTION_ERROR", e.message, null)
      }
    }

  }

  private fun disconnectPrinter(result: Result) {
    try {
      outputStream?.close()
      bluetoothSocket?.close()
      outputStream = null
      bluetoothSocket = null
      result.success(true)
    } catch (e: Exception) {
      result.error("DISCONNECT_ERROR", e.message, null)
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
    disconnectPrinter(object : Result {
      override fun success(result: Any?) {}
      override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {}
      override fun notImplemented() {}
    })
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity
  }

  override fun onDetachedFromActivityForConfigChanges() {
    activity = null
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    activity = binding.activity
  }

  override fun onDetachedFromActivity() {
    activity = null
  }
}
