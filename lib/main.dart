import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:my_digipin/utils/digipin.dart';
import 'package:my_digipin/widgets/icon_container.dart';
import 'package:my_digipin/widgets/reusable_container.dart';

void main() {
  runApp(const MyApp());
}

final rand = Random();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Digipin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Digipin'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String digipin = "ABC-ABC-ABCD";
  bool loading = false;

  double lat = 0.0;
  double lon = 0.0;

  void generateDigiPin() async {
    setState(() => loading = true);

    try {
      // Check location services
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception("Location services are disabled.");
      }

      // Check and request permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception("Location permission denied.");
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception("Location permission permanently denied.");
      }

      // Get position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      lat = position.latitude;
      lon = position.longitude;

      String pin = DigiPin.getDigiPin(lat, lon);

      setState(() {
        digipin = pin;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: [
            ReusableContainer(
              child: Column(
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      child: Row(
                        children: [
                          Text(
                            digipin.isNotEmpty
                                ? digipin
                                : "Your DigiPin will appear here",
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          IconContainer(
                            marginR: 4,
                            child: IconButton(
                              iconSize: 32.0,
                              onPressed: loading
                                  ? null
                                  : () {
                                      Clipboard.setData(
                                        ClipboardData(text: digipin),
                                      );
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text("Copied!"),
                                        ),
                                      );
                                    },
                              icon: const Icon(Icons.copy),
                            ),
                          ),
                          IconContainer(
                            child: IconButton(
                              iconSize: 32.0,
                              onPressed: loading
                                  ? null
                                  : () {
                                      // Add share logic here if needed
                                    },
                              icon: const Icon(Icons.share),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      const Spacer(),
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(Colors.amber),
                        ),
                        onPressed: loading ? null : generateDigiPin,
                        child: loading
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Text("Generating..."),
                                ],
                              )
                            : const Text("Get My DigiPin"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ReusableContainer(
              color: Colors.purpleAccent,
              child: const Text("Other content here"),
            ),
          ],
        ),
      ),
    );
  }
}
