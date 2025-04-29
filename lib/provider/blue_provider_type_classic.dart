import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:bluetooth_classic/bluetooth_classic.dart';
import 'package:bluetooth_classic/models/device.dart';
import 'package:flutter/cupertino.dart';
import 'package:heart_reading/service/database_helper.dart';

class BleScanProviderTypeCLASSIC extends ChangeNotifier {
  final BluetoothClassic _bluetooth = BluetoothClassic();
  final StreamController<Map<String, dynamic>> _dataStreamController =
      StreamController<Map<String, dynamic>>.broadcast();

  List<Device> _pairedDevices = [];
  Device? _device;
  bool _isConnected = false;
  String buffer = "";

  // Pagination variables
  int _currentPage = 1;
  final int _pageSize = 10; // Number of records per page
  List<Map<String, dynamic>> _sensorData = [];
  List<Map<String, dynamic>> get sensorData => _sensorData;

  BleScanProviderTypeCLASSIC() {
    fetchPairedDevices();
  }

  // Exposes the stream of JSON data received from the Bluetooth device.
  Stream<Map<String, dynamic>> get dataStream => _dataStreamController.stream;

  // All paired devices
  List<Device> get pairedDevices => _pairedDevices;

  // Currently selected device
  Device? get device => _device;

  // Connection status
  bool get isConnected => _isConnected;

  // Fetch all paired devices
  Future<void> fetchPairedDevices() async {
    try {
      await _bluetooth.initPermissions();
      List<Device> devices = await _bluetooth.getPairedDevices();
      _pairedDevices = devices;

      notifyListeners();
    } catch (e) {
      print("❌ Error fetching devices: $e");
    }
  }

  // Set a selected device (from UI tap, etc.)
  void selectDevice(Device selectedDevice) {
    _device = selectedDevice;
    print("✅ Paired devices: $selectedDevice");
    notifyListeners();
  }

  // Connect to the selected device
  Future<void> connectToDevice() async {
    if (_device == null) {
      print('⚠️ No device selected to connect');
      return;
    }

    try {
      await _bluetooth.connect(
        _device!.address,
        "00001101-0000-1000-8000-00805f9b34fb",
      );
      _isConnected = true;
      notifyListeners();
      print('✅ Connected to ${_device!.address}');

      // Listen for incoming data
      _bluetooth.onDeviceDataReceived().listen((Uint8List data) async {
        String receivedData = utf8.decode(data);
        buffer += receivedData;

        while (buffer.contains("}")) {
          int lastIndex = buffer.lastIndexOf("}");
          String completeMessage = buffer.substring(0, lastIndex + 1);
          buffer = buffer.substring(lastIndex + 1);

          print('📥 Received JSON: $completeMessage');

          try {
            Map<String, dynamic> jsonData = json.decode(completeMessage);
            _dataStreamController.add(jsonData);

            // Store received data into the database with timestamp
            await _storeSensorData(jsonData);
          } catch (e) {
            print('❌ JSON Parsing Error: $e');
          }
        }
      });

      _bluetooth.onDeviceStatusChanged().listen((int status) {
        if (status == 0) {
          print('🔌 Disconnected');
          _isConnected = false;
          notifyListeners();
        }
      });
    } catch (e) {
      print('❌ Connection Failed: $e');
    }
  }

  // Store the received sensor data into the database
  Future<void> _storeSensorData(Map<String, dynamic> data) async {
    try {
      final now = DateTime.now();
      final dataToInsert = {
        'heart_rate': data['Heart_Rate'] ?? -1,
        'spo2': data['SPO2'] ?? -1,
        'glucose': data['Glucose'] ?? -1,
        'date': now.toIso8601String().split('T')[0], // Extract Date
        'time':
            now.toIso8601String().split('T')[1].split('.')[0], // Extract Time
      };

      // Insert data into the database
      await DatabaseHelper.instance.insertSensorData(dataToInsert);
      print("✅ Data stored successfully in the database!");
    } catch (e) {
      print("❌ Error storing data: $e");
    }
  }

  // Disconnect from the Bluetooth device
  void disconnect() async {
    try {
      await _bluetooth.disconnect();
      _isConnected = false;
      notifyListeners();
      print('🔌 Disconnected');
    } catch (e) {
      print('❌ Disconnection Error: $e');
    }
  }

  /// Fetch data for the current page
  Future<void> fetchSensorData() async {
    try {
      final data = await DatabaseHelper.instance.getSensorDataPaged(
        _currentPage,
        _pageSize,
      );
      _sensorData = data;

      print("✅ Data fetched for page $_currentPage: $_sensorData");

      notifyListeners();
    } catch (e) {
      print("❌ Error fetching data: $e");
    }
  }

  /// Move to the next page
  void nextPage() {
    _currentPage++;
    fetchSensorData();
  }

  /// Move to the previous page
  void previousPage() {
    if (_currentPage > 1) {
      _currentPage--;
      fetchSensorData();
    }
  }

  @override
  void dispose() {
    _dataStreamController.close();
    super.dispose();
  }
}
