import 'package:bluetooth_classic/models/device.dart';
import 'package:flutter/material.dart';
import 'package:heart_reading/screen/sensor_data_historey.dart';
import 'package:provider/provider.dart';
import 'package:heart_reading/provider/blue_provider_type_classic.dart';
import 'package:heart_reading/constant/dimentions.dart';

class BluetoothClassicHomePage extends StatefulWidget {
  @override
  _BluetoothClassicHomePageState createState() =>
      _BluetoothClassicHomePageState();
}

class _BluetoothClassicHomePageState extends State<BluetoothClassicHomePage> {
  bool _isConnecting = false;
  String? _connectionError;

  @override
  void initState() {
    super.initState();
    _initializeConnection();
  }

  Future<void> _initializeConnection() async {
    final provider = Provider.of<BleScanProviderTypeCLASSIC>(
      context,
      listen: false,
    );

    // Check if we have a selected device
    if (provider.device == null) {
      await provider.fetchPairedDevices();
      // Try to find our target device automatically
      final targetDevice = provider.pairedDevices.firstWhere(
        (d) => d.address.toUpperCase() == "EC:62:60:A1:B4:D6",
        orElse: () => Device(address: "", name: ""),
      );
      if (targetDevice.address.isNotEmpty) {
        provider.selectDevice(targetDevice);
      }
    }

    // If we have a device but not connected, try to connect
    if (provider.device != null && !provider.isConnected) {
      await _connectToDevice(provider);
    }
  }

  Future<void> _connectToDevice(BleScanProviderTypeCLASSIC provider) async {
    setState(() {
      _isConnecting = true;
      _connectionError = null;
    });

    try {
      await provider.connectToDevice();
    } catch (e) {
      setState(() {
        _connectionError = "Connection failed: ${e.toString()}";
      });
      print("Connection error: $e");
    } finally {
      setState(() {
        _isConnecting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BleScanProviderTypeCLASSIC>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            title: Center(child: Text('Real-Time Sensor Data')),
            actions: [
              IconButton(
                icon: Icon(Icons.medical_information, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) => SensorDataPage(),
                    ),
                  );
                },
              ),
            ],
          ),
          body: _buildBody(provider),
        );
      },
    );
  }

  Widget _buildBody(BleScanProviderTypeCLASSIC provider) {
    // Show connection error if exists
    if (_connectionError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 48),
            SizedBox(height: 16),
            Text(
              _connectionError!,
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _connectToDevice(provider),
              child: Text('Retry Connection'),
            ),
          ],
        ),
      );
    }

    // Show connecting indicator
    if (_isConnecting) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Connecting to ${provider.device?.name ?? 'device'}...',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      );
    }

    // Show device not found/paired message
    if (provider.device == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bluetooth_disabled, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'ESP32 device not paired',
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 8),
            Text(
              'MAC: EC:62:60:A1:B4:D6',
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _initializeConnection(),
              child: Text('Check Again'),
            ),
            SizedBox(height: 16),
            Text(
              'Please pair the device in your phone settings first',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Show connected content
    if (provider.isConnected) {
      return _buildConnectedContent(provider);
    }

    // Show disconnected state
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bluetooth_disabled, size: 48, color: Colors.orange),
          SizedBox(height: 16),
          Text(
            'Disconnected from ${provider.device!.name}',
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _connectToDevice(provider),
            child: Text('Reconnect'),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectedContent(BleScanProviderTypeCLASSIC provider) {
    return StreamBuilder<Map<String, dynamic>>(
      stream: provider.dataStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        if (snapshot.hasData) {
          final data = snapshot.data!;
          return _buildDataCards(data);
        }

        return Center(
          child: Text(
            'Waiting for data...',
            style: TextStyle(color: Colors.white),
          ),
        );
      },
    );
  }

  Widget _buildDataCards(Map<String, dynamic> data) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            _buildDataCard(
              title: "Heart Rate",
              value: _parseValue(data['Heart_Rate']),
              unit: "BPM",
              iconPath: "assets/heart.png",
            ),
            _buildDataCard(
              title: "Glucose",
              value: _parseValue(data['Glucose']),
              unit: "mg/dl",
              iconPath: "assets/glucos.png",
            ),
            _buildDataCard(
              title: "SPO2",
              value: _parseValue(data['SPO2']),
              unit: "%",
              iconPath: "assets/spo.png",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataCard({
    required String title,
    required String value,
    required String unit,
    required String iconPath,
  }) {
    return Center(
      child: Container(
        height: Dimentions.hightPercentage(context, 27),
        width: Dimentions.widthPercentage(context, 50),
        margin: EdgeInsets.symmetric(
          vertical: Dimentions.hightPercentage(context, 1),
          horizontal: Dimentions.widthPercentage(context, 5),
        ),
        decoration: BoxDecoration(
          color: Color(0xff2B2B2B),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            SizedBox(height: Dimentions.hightPercentage(context, 0.5)),
            Text(
              title,
              style: TextStyle(
                fontFamily: "lemonada",
                fontSize: Dimentions.fontPercentage(context, 3),
                fontStyle: FontStyle.italic,
                color: Colors.white,
              ),
            ),
            Image.asset(
              iconPath,
              height:
                  title == "Glucose" || title == "SPO2"
                      ? Dimentions.hightPercentage(context, 15)
                      : null,
            ),
            SizedBox(
              height:
                  title == "Glucose"
                      ? Dimentions.hightPercentage(context, 1)
                      : 0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  height: Dimentions.hightPercentage(context, 6),
                  width: Dimentions.widthPercentage(context, 15),
                  decoration: BoxDecoration(
                    color: Color(0xff026579),
                    borderRadius: BorderRadius.circular(
                      Dimentions.radiusPercentage(context, 1),
                    ),
                  ),
                  child: Column(
                    children: [
                      Center(
                        child: Text(
                          value,
                          style: TextStyle(
                            fontFamily: "lemonada",
                            color: Colors.white,
                            fontSize: Dimentions.fontPercentage(context, 3),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Center(
                        child: Text(
                          unit,
                          style: TextStyle(
                            fontFamily: "lemonada",
                            color: Colors.white,
                            fontSize: Dimentions.fontPercentage(context, 1),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: Dimentions.hightPercentage(context, 3),
                  width: Dimentions.widthPercentage(context, 20),
                  decoration: BoxDecoration(
                    color: Color(0xff026579),
                    borderRadius: BorderRadius.circular(
                      Dimentions.radiusPercentage(context, 1),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      "${DateTime.now().year}/${DateTime.now().month}/${DateTime.now().day}",
                      style: TextStyle(
                        fontFamily: "lemonada",
                        color: Colors.white,
                        fontSize: Dimentions.fontPercentage(context, 1.5),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _parseValue(dynamic value) {
    if (value == null) return "N/A";
    if (value is String) {
      final numValue = int.tryParse(value);
      return numValue != null && numValue >= 0 ? value : "INV";
    }
    if (value is num) {
      return value >= 0 ? value.toString() : "INV";
    }
    return "N/A";
  }
}
