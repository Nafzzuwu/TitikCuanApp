import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:device_preview/device_preview.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(
    DevicePreview(enabled: true, builder: (context) => const TitikCuanApp()),
  );
}

class TitikCuanApp extends StatelessWidget {
  const TitikCuanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TitikCuan',
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1D9E75)),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
