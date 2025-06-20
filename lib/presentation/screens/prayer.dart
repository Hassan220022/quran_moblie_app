import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/preference_settings_provider.dart';
import '../widgets/enhanced_loading.dart';

class PrayerTimeService {
  Future<Map<String, dynamic>> getPrayerTimes(String latitude, String longitude,
      {DateTime? date}) async {
    String dateString = '';
    if (date != null) {
      dateString =
          '&date=${date.day}-${date.month}-${date.year}'; // Format as DD-MM-YYYY
    }

    final url =
        'https://api.aladhan.com/v1/timings?latitude=$latitude&longitude=$longitude$dateString';
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
  const PrayerTimesWidget({super.key});

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

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // Check for location permissions
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

    // Get current position
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

      // Format the prayer times
      DateFormat inputFormat = DateFormat("HH:mm");
      DateFormat outputFormat = DateFormat("h:mm a");
      timings.forEach((key, value) {
        try {
          DateTime time = inputFormat.parse(value);
          String formattedTime = outputFormat.format(time);
          timings[key] = formattedTime;
        } catch (e) {
          timings[key] = "Invalid Time";
        }
      });

      // Get next prayer time
      await _getNextPrayerTime(timings);

      if (mounted) {
        setState(() {
          _prayerTimes = timings;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("An error occurred: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _getNextPrayerTime(Map<String, dynamic> timings) async {
    DateTime now = DateTime.now();
    DateFormat formatter = DateFormat("h:mm a");
    DateTime? nextPrayerTime;
    String? nextPrayer;

    // Iterate over today's prayers to find the next prayer
    for (var entry in timings.entries) {
      if ([
        "Fajr",
        "Dhuhr",
        "Asr",
        "Maghrib",
        "Isha",
      ].contains(entry.key)) {
        try {
          DateTime prayerTime = formatter.parse(entry.value);
          DateTime combinedPrayerTime = DateTime(
            now.year,
            now.month,
            now.day,
            prayerTime.hour,
            prayerTime.minute,
          );
          if (combinedPrayerTime.isBefore(now)) {
            continue;
          }
          if (nextPrayerTime == null ||
              combinedPrayerTime.isBefore(nextPrayerTime)) {
            nextPrayerTime = combinedPrayerTime;
            nextPrayer = entry.key;
          }
        } catch (e) {
          print('Error parsing prayer time for ${entry.key}: $e');
        }
      }
    }

    // If no next prayer today, fetch tomorrow's first prayer
    if (nextPrayerTime == null) {
      DateTime tomorrow = now.add(const Duration(days: 1));
      Map<String, dynamic> tomorrowTimings =
          await _prayerTimeService.getPrayerTimes(
        _currentPosition!.latitude.toString(),
        _currentPosition!.longitude.toString(),
        date: tomorrow,
      );

      // Format timings for tomorrow
      tomorrowTimings.forEach((key, value) {
        try {
          DateTime time = DateFormat("HH:mm").parse(value);
          String formattedTime = formatter.format(time);
          tomorrowTimings[key] = formattedTime;
        } catch (e) {
          tomorrowTimings[key] = "Invalid Time";
        }
      });

      // Get the first prayer of tomorrow
      for (var key in ["Fajr", "Dhuhr", "Asr", "Maghrib", "Isha"]) {
        if (tomorrowTimings.containsKey(key)) {
          try {
            DateTime prayerTime = formatter.parse(tomorrowTimings[key]);
            nextPrayerTime = DateTime(
              tomorrow.year,
              tomorrow.month,
              tomorrow.day,
              prayerTime.hour,
              prayerTime.minute,
            );
            nextPrayer = key;
            break;
          } catch (e) {
            print('Error parsing prayer time for $key: $e');
          }
        }
      }
    }

    // Calculate time left until next prayer
    if (nextPrayerTime != null) {
      _timeLeft = nextPrayerTime.difference(now);
      _nextPrayer = nextPrayer;
      _nextPrayerTime = formatter.format(nextPrayerTime);
    } else {
      _timeLeft = Duration.zero;
      _nextPrayer = "No upcoming prayers";
      _nextPrayerTime = "Not available";
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkTheme =
        Provider.of<PreferenceSettingsProvider>(context).isDarkTheme;

    return Scaffold(
      body: _isLoading
          ? const Center(
              child: EnhancedLoading(
                message: 'Loading Prayer Times...',
                style: LoadingStyle.prayerStyle,
              ),
            )
          : _prayerTimes == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_off,
                        size: 64,
                        color: isDarkTheme ? Colors.white70 : Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Failed to load prayer times',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: isDarkTheme ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Please check location permissions',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDarkTheme ? Colors.white70 : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => _refreshPrayerTimes(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _refreshPrayerTimes,
                  color: const Color(0xFF667eea),
                  child: Column(
                    children: [
                      _buildPrayerTimeHeader(context),
                      Expanded(
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: _prayerTimes!.entries
                              .where((entry) => ![
                                    "Firstthird",
                                    "Lastthird",
                                    "Midnight",
                                    "Imsak",
                                    "Sunset",
                                    "Sunrise",
                                  ].contains(entry.key))
                              .map((entry) {
                            return Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: isDarkTheme
                                      ? [
                                          const Color(0xFF2a2a3e),
                                          const Color(0xFF1e1e2e)
                                        ]
                                      : [Colors.white, const Color(0xFFf8f9fa)],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: isDarkTheme
                                        ? Colors.black.withOpacity(0.3)
                                        : Colors.grey.withOpacity(0.1),
                                    spreadRadius: 1,
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                leading: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF2196F3),
                                        Color(0xFF1976D2),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: _getPrayerIcon(entry.key),
                                ),
                                title: Text(
                                  entry.key,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isDarkTheme
                                        ? Colors.white
                                        : Colors.black,
                                    fontSize: 18,
                                  ),
                                ),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2196F3)
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    entry.value,
                                    style: TextStyle(
                                      color: isDarkTheme
                                          ? Colors.white
                                          : Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Future<void> _refreshPrayerTimes() async {
    setState(() {
      _isLoading = true;
      _prayerTimes = null;
    });
    await _determinePosition();
  }

  Widget _buildPrayerTimeHeader(BuildContext context) {
    String timeLeftString = _timeLeft != null
        ? "${_timeLeft!.inHours}h ${_timeLeft!.inMinutes.remainder(60)}m remaining"
        : "Calculating...";

    bool isDarkTheme =
        Provider.of<PreferenceSettingsProvider>(context).isDarkTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: isDarkTheme ? const Color(0xFF091945) : const Color(0xff682DBD),
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
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _nextPrayerTime ?? "Loading...",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  timeLeftString,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.access_time,
            color: Colors.white,
            size: 72,
          ),
        ],
      ),
    );
  }

  Icon _getPrayerIcon(String prayerName) {
    switch (prayerName.toLowerCase()) {
      case 'fajr':
        return const Icon(Icons.wb_twilight);
      case 'dhuhr':
        return const Icon(Icons.wb_sunny);
      case 'asr':
        return const Icon(Icons.wb_incandescent);
      case 'maghrib':
        return const Icon(Icons.nightlight_round);
      case 'isha':
        return const Icon(Icons.bedtime);
      default:
        return const Icon(Icons.access_time);
    }
  }
}
