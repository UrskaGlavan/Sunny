import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with TickerProviderStateMixin {
  late AnimationController _controller1;
  late AnimationController _controller2;
  late AnimationController _controller3;

  String sunrise = "Nalaganje ...";
  String sunset = "Nalaganje ...";
  String todayDate = "";
  String temperature = "Nalaganje...";
  String weatherCondition = "Nalaganje...";

  final String apiKey = "TVOJ_API_KLJUČ"; // Vnesi API ključ

  @override
  void initState() {
    super.initState();
    fetchSunTimes();
    setTodaydate();
    fetchWeather();

    Timer.periodic(const Duration(minutes: 15), (_) {
      setState(() {}); // Osveži gradnike
    });

    // Ustvarjanje posameznih kontrolerjev za animacije
    _controller1 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _controller2 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();

    _controller3 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();
  }

  void setTodaydate() {
    final now = DateTime.now();
    todayDate = "${now.day}.${now.month}.${now.year}";
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();
    super.dispose();
  }

  Future<void> fetchSunTimes() async {
    try {
      final response = await http.get(Uri.parse(
          'https://api.sunrise-sunset.org/json?lat=46.0569&lng=14.5058&formatted=0'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          sunrise = _formatTime(data['results']['sunrise']);
          sunset = _formatTime(data['results']['sunset']);
        });
      } else {
        setState(() {
          sunrise = "Napaka pri pridobivanju";
          sunset = "Napaka pri pridobivanju";
        });
      }
    } catch (e) {
      setState(() {
        sunrise = "Napaka: ${e.toString()}";
        sunset = "Napaka: ${e.toString()}";
      });
    }
  }

  Future<void> fetchWeather() async {
    try {
      final response = await http.get(Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?q=Ljubljana&appid=$apiKey&units=metric'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          temperature = "${data['main']['temp']}°C";
          weatherCondition = data['weather'][0]['description'];
        });
      } else {
        setState(() {
          temperature = "Napaka pri pridobivanju";
          weatherCondition = "Napaka pri pridobivanju";
        });
      }
    } catch (e) {
      setState(() {
        temperature = "Ni povezave";
        weatherCondition = "Ni povezave";
      });
    }
  }

  String _formatTime(String utcTime) {
    final dateTime =
        DateTime.parse(utcTime).toLocal(); // Pretvori v lokalni čas
    return "${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    // Nastavi barvi glede na trenutni čas
    Color backgroundColor =
        DateTime.now().hour < 18 ? Colors.blue : Colors.black;
    Color textColor = DateTime.now().hour < 18 ? Colors.black : Colors.white;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          title: const Text("Sunny days"),
          backgroundColor: Colors.yellow,
        ),
        body: Column(
          children: [
            const Spacer(),
            Text(
              "Današnji datum: $todayDate",
              style: const TextStyle(color: Colors.yellow, fontSize: 30),
            ),
            /*
            Text(
              "Trenutno vreme: $temperature, $weatherCondition",
              style: const TextStyle(color: Colors.white, fontSize: 20),
            ),*/
            Text(
              "Sončni vzhod: $sunrise",
              style: TextStyle(color: textColor, fontSize: 30),
            ),
            const SizedBox(height: 10),
            Text(
              "Sončni zahod: $sunset",
              style: TextStyle(color: textColor, fontSize: 30),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset(
                  'assets/sun1.json',
                  height: 200,
                  width: 200,
                  controller: _controller1,
                  onLoaded: (composition) {
                    _controller1.duration = composition.duration;
                  },
                ),
                const SizedBox(width: 10),
                Lottie.asset(
                  'assets/sun2.json',
                  height: 200,
                  width: 200,
                  controller: _controller2,
                  onLoaded: (composition) {
                    _controller2.duration = composition.duration;
                  },
                ),
                const SizedBox(width: 10),
                Lottie.asset(
                  'assets/sun3.json',
                  height: 200,
                  width: 200,
                  controller: _controller3,
                  onLoaded: (composition) {
                    _controller3.duration = composition.duration;
                  },
                ),
              ],
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
