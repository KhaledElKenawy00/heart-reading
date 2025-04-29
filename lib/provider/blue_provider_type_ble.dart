// ble_scan_provider.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BleScanProviderTypeBLE with ChangeNotifier {
  List<ScanResult> _scanResults = [];
  bool _isScanning = false;
  StreamSubscription<List<ScanResult>>? _scanSubscription;
  StreamSubscription<BluetoothAdapterState>? _adapterStateSubscription;

  // Getters
  List<ScanResult> get scanResults => _scanResults;
  bool get isScanning => _isScanning;

  // Initialize BLE
  Future<void> initialize() async {
    // Check if BLE is supported
    if (await FlutterBluePlus.isSupported == false) {
      throw Exception("Bluetooth not supported by this device");
    }

    // Listen to adapter state changes
    _adapterStateSubscription = FlutterBluePlus.adapterState.listen((state) {
      if (state == BluetoothAdapterState.on) {
        // Bluetooth is on, ready to scan
      } else {
        // Bluetooth is off, stop scanning if active
        if (_isScanning) {
          stopScan();
        }
      }
    });
  }

  // Start scanning for BLE devices
  Future<void> startScan({
    Duration timeout = const Duration(seconds: 10),
  }) async {
    if (_isScanning) return;

    try {
      // Clear previous results
      _scanResults = [];
      _isScanning = true;
      notifyListeners();

      // Wait for Bluetooth to be on
      await FlutterBluePlus.adapterState
          .where((state) => state == BluetoothAdapterState.on)
          .first;

      // Setup scan results listener
      _scanSubscription = FlutterBluePlus.onScanResults.listen((results) {
        _scanResults = results;
        notifyListeners();
      }, onError: (e) => print("Scan error: $e"));

      // Auto-cancel subscription when scan completes
      FlutterBluePlus.cancelWhenScanComplete(_scanSubscription!);

      // Start scanning
      await FlutterBluePlus.startScan(
        timeout: timeout,
        androidUsesFineLocation: true, // Required for location-based scanning
      );

      // Wait for scan to complete
      await FlutterBluePlus.isScanning.where((val) => val == false).first;
    } catch (e) {
      print("Scan failed: $e");
      stopScan();
      rethrow;
    } finally {
      _isScanning = false;
      notifyListeners();
    }
  }

  // Stop scanning
  Future<void> stopScan() async {
    if (!_isScanning) return;

    try {
      await FlutterBluePlus.stopScan();
      _scanSubscription?.cancel();
      _isScanning = false;
      notifyListeners();
    } catch (e) {
      print("Error stopping scan: $e");
    }
  }

  // Clean up resources
  @override
  void dispose() {
    stopScan();
    _adapterStateSubscription?.cancel();
    super.dispose();
  }
}
