import 'package:flutter_blue/flutter_blue.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class BleController extends GetxController {
  FlutterBlue ble = FlutterBlue.instance;

// This Function will help users to scan near by BLE devices and get the list of Bluetooth devices.
  Future scanDevices() async {
    if (await Permission.bluetoothScan.request().isGranted) {
      if (await Permission.bluetoothConnect.request().isGranted) {
        ble.startScan(timeout: Duration(seconds: 15));

        ble.stopScan();
      }
    }
  }

// This function will help user to connect to BLE devices.
  Future<void> connectToDevice(BluetoothDevice device) async {
    await device?.connect(timeout: Duration(seconds: 15));

    device?.state.listen((isConnected) {
      if (isConnected == BluetoothDeviceState.connecting) {
        print("Device connecting to: ${device.name}");
      } else if (isConnected == BluetoothDeviceState.connected) {
        print("Device connected: ${device.name}");
      } else {
        print("Device Disconnected");
      }
    });
  }

  Stream<List<ScanResult>> get scanResults => ble.scanResults;
}
