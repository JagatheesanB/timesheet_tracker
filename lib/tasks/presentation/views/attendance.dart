import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:geocoding/geocoding.dart';
import 'package:location/location.dart' as loc;
import 'package:timesheet_management/tasks/presentation/views/attendance_history.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../providers/auth_provider.dart';

class AttendanceLocationScreen extends ConsumerStatefulWidget {
  const AttendanceLocationScreen({Key? key}) : super(key: key);

  @override
  ConsumerState createState() => _AttendanceLocationScreenState();
}

class _AttendanceLocationScreenState
    extends ConsumerState<AttendanceLocationScreen> {
  late Timer _timer;
  late DateTime _lastCheckInTime;
  late DateTime _today;

  String hoursString = "00", minuteString = "00", secondString = "00";
  int hours = 0, minutes = 0, seconds = 0;
  bool isTimerRunning = false;

  bool isLoading = false;
  loc.LocationData? locationData;
  List<Placemark>? placemarks;

  @override
  void initState() {
    super.initState();
    _lastCheckInTime = DateTime.now();
    _today = DateTime.now();
    _initializeTimer();
    _getLocation();
    _timer = Timer(const Duration(seconds: 0), () {});
  }

  void _initializeTimer() async {
    final userId = ref.read(currentUserProvider);
    final lastCheckIn = await AttendanceStorage.getCheckIn(_today, userId!);
    final lastCheckOut = await AttendanceStorage.getCheckOut(_today, userId);
    if (lastCheckIn != null &&
        (lastCheckOut == null || lastCheckIn.isAfter(lastCheckOut))) {
      // If there's an ongoing timer
      final difference = DateTime.now().difference(lastCheckIn);

      setState(() {
        _lastCheckInTime = lastCheckIn;
        isTimerRunning = true;
        hours = difference.inHours;
        minutes = difference.inMinutes.remainder(60);
        seconds = difference.inSeconds.remainder(60);
        hoursString = hours.toString().padLeft(2, '0');
        minuteString = minutes.toString().padLeft(2, '0');
        secondString = seconds.toString().padLeft(2, '0');
      });
      _startTimer();
    }
  }

// periodic timer that fires every second to update the timer display.
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _updateTimer();
      });
    });
  }

//  calculates the time difference between the current time and the last check-in time
  void _updateTimer() {
    final now = DateTime.now();
    final difference = now.difference(_lastCheckInTime);
    setState(() {
      hours = difference.inHours;
      minutes = difference.inMinutes.remainder(60);
      seconds = difference.inSeconds.remainder(60);
      hoursString = hours.toString().padLeft(2, '0');
      minuteString = minutes.toString().padLeft(2, '0');
      secondString = seconds.toString().padLeft(2, '0');
    });
  }

  void _checkIn() async {
    final userId = ref.read(currentUserProvider);

    final now = DateTime.now();
    setState(() {
      _lastCheckInTime = now;
      isTimerRunning = true;
      isLoading = true;
    });
    await AttendanceStorage.saveCheckIn(now, userId!);
    _startTimer();
    await _getLocation();
    setState(() {
      isLoading = false;
    });
  }

  void _checkOut() async {
    final userId = ref.read(currentUserProvider);

    final now = DateTime.now();
    _timer.cancel();
    setState(() {
      isTimerRunning = false;
      isLoading = true;
    });
    await AttendanceStorage.saveCheckOut(now, userId!);
    await _getLocation();
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _getLocation() async {
    final loc.Location location = loc.Location();
    bool serviceEnabled;
    loc.PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == loc.PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != loc.PermissionStatus.granted) {
        return;
      }
    }

    locationData = await location.getLocation();
    if (locationData != null) {
      try {
        placemarks = await placemarkFromCoordinates(
            locationData!.latitude!, locationData!.longitude!);
      } catch (e) {
        // print('error');
      }
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Container _buildTimerBox(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(
          vertical: 5.0, horizontal: 8.0), // Adjust padding
      decoration: BoxDecoration(
        color: Colors.white,
        border:
            Border.all(color: Colors.black, width: 1.0), // Reduce border size
        borderRadius: BorderRadius.circular(8.0), // Adjust border radius
      ),
      child: Column(
        children: [
          Text(
            value.padLeft(2, '0'),
            style: const TextStyle(
              fontSize: 50,
              fontFamily: 'poppins',
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 5),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber.shade100,
      appBar: AppBar(
        backgroundColor: Colors.amber.shade100,
        title: Text(
          AppLocalizations.of(context)!.attendance,
          style: const TextStyle(
            fontFamily: 'poppins',
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Text(
                  'History',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AttendanceHistoryScreen()),
                  );
                },
              ),
            ],
            icon: const Icon(Icons.more_vert_rounded),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                "assets/lottie/location.json",
                width: 200,
                height: 170,
              ),
              const SizedBox(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildTimerBox(hoursString),
                  const SizedBox(width: 10),
                  const Text(
                    " : ",
                    style: TextStyle(
                      fontSize: 30,
                      fontFamily: 'poppins',
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  _buildTimerBox(minuteString),
                  const SizedBox(width: 10),
                  const Text(
                    " : ",
                    style: TextStyle(
                      fontSize: 30,
                      fontFamily: 'poppins',
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  _buildTimerBox(secondString),
                ],
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Hours',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'poppins',
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Minutes',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'poppins',
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Seconds',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'poppins',
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    decoration: BoxDecoration(
                      color: isTimerRunning
                          ? Colors.white
                          : Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: isTimerRunning ? null : _checkIn,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 10.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(width: 8.0),
                          Text(
                            "Check-In",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color:
                                  isTimerRunning ? Colors.black : Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    decoration: BoxDecoration(
                      color: isTimerRunning
                          ? Theme.of(context).primaryColor
                          : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: isTimerRunning ? _checkOut : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 10.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(width: 8.0),
                          Text(
                            "Check-Out",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color:
                                  isTimerRunning ? Colors.white : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              if (placemarks != null && placemarks!.isNotEmpty)
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Colors.black,
                      size: 30,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "${placemarks![0].street}, ${placemarks![0].subLocality}, ${placemarks![0].locality}, ${placemarks![0].postalCode}, ${placemarks![0].country}"
                          .toUpperCase(),
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 11,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                )
              else
                const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Colors.black,
                        size: 30,
                      ),
                      Text("Not Available"),
                    ]),
            ],
          ),
        ),
      ),
    );
  }
}

class AttendanceStorage {
  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<File> _getFile(String fileName) async {
    final path = await _localPath;
    return File('$path/$fileName');
  }

  static Future<Map<String, dynamic>> _readData(
      String fileName, int userId) async {
    try {
      final file = await _getFile(fileName);
      String contents = await file.readAsString();
      return contents.isNotEmpty
          ? Map<String, dynamic>.from(jsonDecode(contents))
          : {};
    } catch (e) {
      return {};
    }
  }

  static Future<void> _writeData(
      String fileName, Map<String, dynamic> data, int userId) async {
    final file = await _getFile(fileName);
    if (!file.existsSync()) {
      await file.create(recursive: true);
    }
    await file.writeAsString(jsonEncode(data));
  }

  static Future<void> saveCheckIn(DateTime dateTime, int userId) async {
    final today = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final fileName = '${today.year}-${today.month}-${today.day}.json';
    final data = await _readData(fileName, userId);
    data['checkIn'] = dateTime.toIso8601String();
    await _writeData(fileName, data, userId);
  }

  static Future<void> saveCheckOut(DateTime dateTime, int userId) async {
    final today = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final fileName = '${today.year}-${today.month}-${today.day}.json';
    final data = await _readData(
      fileName,
      userId,
    );
    data['checkOut'] = dateTime.toIso8601String();
    await _writeData(fileName, data, userId);
  }

  static Future<DateTime?> getCheckIn(DateTime dateTime, int userId) async {
    final today = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final fileName = '${today.year}-${today.month}-${today.day}.json';
    final data = await _readData(fileName, userId);
    final checkInString = data['checkIn'];
    if (checkInString != null) {
      return DateTime.parse(checkInString);
    }
    return null;
  }

  static Future<DateTime?> getCheckOut(DateTime dateTime, int userId) async {
    final today = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final fileName = '${today.year}-${today.month}-${today.day}.json';
    final data = await _readData(fileName, userId);
    final checkOutString = data['checkOut'];
    if (checkOutString != null) {
      return DateTime.parse(checkOutString);
    }
    return null;
  }

  static Future<void> deleteEntry(DateTime date, int userId) async {
    final fileName = '${date.year}-${date.month}-${date.day}.json';
    final file = await _getFile(fileName);
    if (file.existsSync()) {
      await file.delete();
    }
  }
}
