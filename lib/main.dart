import 'package:flutter/material.dart';
import 'package:heart_reading/provider/blue_provider_type_classic.dart';
import 'package:heart_reading/screen/on_boarding_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BleScanProviderTypeCLASSIC()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Heart Reading',
      theme: ThemeData.dark(),
      home: OnboardingScreen(),
    );
  }
}
