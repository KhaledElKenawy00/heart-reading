class SensorData {
  final int? id;
  final int heartRate;
  final int spo2;
  final int glucose;
  final String date; // e.g., 2025-04-29
  final String time; // e.g., 09:15:30

  SensorData({
    this.id,
    required this.heartRate,
    required this.spo2,
    required this.glucose,
    required this.date,
    required this.time,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'heartRate': heartRate,
      'spo2': spo2,
      'glucose': glucose,
      'date': date,
      'time': time,
    };
  }

  factory SensorData.fromMap(Map<String, dynamic> map) {
    return SensorData(
      id: map['id'],
      heartRate: map['heartRate'],
      spo2: map['spo2'],
      glucose: map['glucose'],
      date: map['date'],
      time: map['time'],
    );
  }
}
