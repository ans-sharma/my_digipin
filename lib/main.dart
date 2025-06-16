import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:my_digipin/utils/digipin.dart';
import 'package:my_digipin/widgets/icon_container.dart';
import 'package:my_digipin/widgets/reusable_container.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

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
  final TextEditingController _controller = TextEditingController();
  String digipin = "ABC-ABC-ABCD";
  String userInputDigipin = "";
  bool loading = false;
  bool decodeLoading = false;

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

      // lat = 25.2632267;
      // lon = 82.9939901;

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
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          IconContainer(
                            marginR: 4,
                            child: IconButton(
                              iconSize: 28.0,
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
                              iconSize: 28.0,
                              onPressed: loading
                                  ? null
                                  : () async {
                                      try {
                                        await Share.share(
                                          'My Current DigiPin is: $digipin',
                                        );
                                      } catch (e) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(content: Text("Error: $e")),
                                        );
                                      }
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
                          backgroundColor: WidgetStatePropertyAll(
                            const Color.fromARGB(255, 255, 255, 255),
                          ),
                        ),
                        onPressed: loading
                            ? null
                            : () {
                                try {
                                  generateDigiPin();
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Error: ${e.toString}"),
                                    ),
                                  );
                                }
                              },
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
              color: Color.fromARGB(255, 76, 91, 92),
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
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: TextField(
                                controller: _controller,
                                textCapitalization:
                                    TextCapitalization.characters,
                                cursorHeight: 30,
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                                // obscureText: true,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Enter Digipin',
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 0,
                                    horizontal: 10,
                                  ),
                                ),

                                onChanged: (value) => {
                                  setState(() {
                                    _controller.text = value.toUpperCase();
                                  }),
                                  // print(_controller.text),
                                },
                              ),
                            ),
                          ),
                          IconContainer(
                            child: IconButton(
                              iconSize: 28.0,
                              onPressed: loading
                                  ? null
                                  : () async {
                                      final clipBoardData =
                                          await Clipboard.getData(
                                            Clipboard.kTextPlain,
                                          );
                                      final pastedText =
                                          clipBoardData?.text ?? '';
                                      setState(() {
                                        _controller.text = pastedText
                                            .toUpperCase();
                                        // ScaffoldMessenger.of(
                                        //   context,
                                        // ).showSnackBar(
                                        //   SnackBar(
                                        //     content: Text(
                                        //       'Pasted: $pastedText',
                                        //     ),
                                        //   ),
                                        // );
                                      });
                                    },
                              icon: const Icon(Icons.paste),
                            ),
                          ),

                          // Spacer(),
                          // ElevatedButton(
                          //   onPressed: () {},
                          //   child: Text("Open in Maps"),
                          // ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Spacer(),
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(Colors.white),
                        ),
                        onPressed: decodeLoading
                            ? null
                            : () async {
                                try {
                                  decodeLoading = true;
                                  // generateDigiPin();
                                  final input = _controller.text
                                      .trim()
                                      .toUpperCase();

                                  final coords = DigiPin.getLatLngFromDigiPin(
                                    input,
                                  );
                                  final lat = coords['latitude'];
                                  final lon = coords['longitude'];

                                  final googleMapsUrl =
                                      'https://www.google.com/maps/search/?api=1&query=$lat,$lon';

                                  final uri = Uri.parse(googleMapsUrl);
                                  try {
                                    decodeLoading = false;
                                    await launchUrl(
                                      uri,
                                      mode: LaunchMode.externalApplication,
                                    );
                                  } catch (e) {
                                    decodeLoading = false;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "Could not open Google Maps: $e",
                                        ),
                                      ),
                                    );
                                  }
                                  decodeLoading = false;
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Error: $e")),
                                  );
                                }
                              },
                        child: decodeLoading
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
                                  Text("Decoding..."),
                                ],
                              )
                            : const Text("Open in Maps"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
