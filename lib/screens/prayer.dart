import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

class PrayerTimeService {
  Future<Map<String, dynamic>> getPrayerTimes(
      String latitude, String longitude) async {
    final url =
        'https://api.aladhan.com/v1/timings?latitude=$latitude&longitude=$longitude';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data']['timings'];
    } else {
      throw Exception('Failed to load prayer times');
    }
  }
}

class PrayerTimesWidget extends StatefulWidget {
  @override
  _PrayerTimesWidgetState createState() => _PrayerTimesWidgetState();
}

class _PrayerTimesWidgetState extends State<PrayerTimesWidget> {
  final PrayerTimeService _prayerTimeService = PrayerTimeService();
  Map<String, dynamic>? _prayerTimes;
  bool _isLoading = true;
  Position? _currentPosition;
  String? _nextPrayer;
  String? _nextPrayerTime;
  Duration? _timeLeft;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        setState(() {
          _isLoading = false;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    _currentPosition = await Geolocator.getCurrentPosition();
    _fetchPrayerTimes();
  }

  Future<void> _fetchPrayerTimes() async {
    if (_currentPosition == null) return;

    try {
      Map<String, dynamic> timings = await _prayerTimeService.getPrayerTimes(
        _currentPosition!.latitude.toString(),
        _currentPosition!.longitude.toString(),
      );

      // Format and store the prayer times
      DateFormat formatter = DateFormat("HH:mm");
      timings.forEach((key, value) {
        try {
          DateTime time = formatter.parse(value);
          String formattedTime = DateFormat("h:mm a").format(time);
          timings[key] = formattedTime;
        } catch (e) {
          print("Error parsing time for $key: $e");
          timings[key] =
              "Invalid Time"; // or keep original value, based on your needs
        }
      });

      // Determine the next prayer time
      DateTime now = DateTime.now();
      DateFormat nextPrayerFormatter = DateFormat("h:mm a");
      DateTime? nextPrayerTime;
      String? nextPrayer;

      timings.forEach((key, value) {
        try {
          DateTime prayerTime = nextPrayerFormatter.parse(value);
          if (now.isBefore(prayerTime) &&
              (nextPrayerTime == null ||
                  prayerTime.isBefore(nextPrayerTime!))) {
            nextPrayerTime = prayerTime;
            nextPrayer = key;
          }
        } catch (e) {
          print("Error parsing prayer time for $key: $e");
        }
      });

      // Calculate time left until next prayer
      if (nextPrayerTime != null) {
        _timeLeft = nextPrayerTime?.difference(now);
      }

      // Update the state
      setState(() {
        _prayerTimes = timings;
        _nextPrayer = nextPrayer;
        _nextPrayerTime = nextPrayerTime != null
            ? nextPrayerFormatter.format(nextPrayerTime!)
            : "Not available";
        _isLoading = false;
      });
    } catch (e) {
      print("An error occurred: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(title: Text("Prayer Times")),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _prayerTimes == null
              ? Center(child: Text("Failed to load prayer times"))
              : Column(
                  children: [
                    _buildPrayerTimeHeader(screenWidth, screenHeight),
                    Expanded(
                      child: ListView(
                        children: _prayerTimes!.entries
                            .where((entry) => ![
                                  "Firstthird",
                                  "Lastthird",
                                  "Midnight",
                                  "Imsak",
                                  "Sunset"
                                ].contains(entry.key))
                            .map((entry) {
                          return Card(
                            margin: EdgeInsets.symmetric(
                                vertical: screenHeight * 0.01),
                            child: ListTile(
                              title: Text(entry.key),
                              trailing: Text(entry.value),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildPrayerTimeHeader(double screenWidth, double screenHeight) {
    return Container(
      width: screenWidth,
      padding: EdgeInsets.all(screenWidth * 0.05),
      decoration: BoxDecoration(
        color: Colors.teal,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _nextPrayer ?? "Next Prayer",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screenWidth * 0.05,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _nextPrayerTime ?? "Loading...",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screenWidth * 0.07,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: screenHeight * 0.005),
                Text(
                  _timeLeft != null
                      ? "Time left: ${_timeLeft!.inHours}:${_timeLeft!.inMinutes.remainder(60).toString().padLeft(2, '0')}:${_timeLeft!.inSeconds.remainder(60).toString().padLeft(2, '0')}"
                      : "Calculating...",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: screenWidth * 0.04,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.access_time,
            color: Colors.white,
            size: screenWidth * 0.15,
          ),
        ],
      ),
    );
  }
}
