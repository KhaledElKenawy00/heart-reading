import 'package:flutter/material.dart';
import 'package:heart_reading/provider/blue_provider_type_classic.dart';
import 'package:provider/provider.dart';

class SensorDataPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<BleScanProviderTypeCLASSIC>(
      builder: (context, provider, _) {
        return Scaffold(
          appBar: AppBar(title: Text('Sensor Data')),
          body: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: provider.sensorData.length,
                  itemBuilder: (context, index) {
                    final data = provider.sensorData[index];
                    return ListTile(
                      title: Text('Heart Rate: ${data['heart_rate']}'),
                      subtitle: Text(
                        'SPO2: ${data['spo2']} | Glucose: ${data['glucose']}',
                      ),
                      trailing: Text('${data['date']} ${data['time']}'),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: provider.previousPage,
                    child: Text('Previous'),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: provider.nextPage,
                    child: Text('Next'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
