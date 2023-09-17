import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'package:intl/intl.dart';
import 'package:location/location.dart';


/// Determine the current position of the device.
///
/// When the location services are not enabled or permissions
/// are denied the `Future` will return an error.
Future<Position> determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the
    // App to enable the location services.
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  return await Geolocator.getCurrentPosition();
}


String getFormattedDateTime(num dt, String pattern) {
  return DateFormat(pattern).format(
      DateTime.fromMillisecondsSinceEpoch(
          dt.toInt() * 1000));
}

void showMsg(BuildContext context, String msg) {
  ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(msg)));
}

void showMsgWithAction(
    {
      required BuildContext context,
      required String msg,
      required VoidCallback callback}) {
  ScaffoldMessenger.of(context)
      .showSnackBar(
      SnackBar(
        duration: const Duration(days: 365),
        content: Text(msg),
        action: SnackBarAction(
          label: 'Go to Settings',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            callback();
          },
        ),
      ));
}


Future<bool> checkLocationServiceStatus() async {
  Location location = Location();
  bool serviceEnabled;
  serviceEnabled = await location.serviceEnabled();
  if (!serviceEnabled) {
    serviceEnabled = await location.requestService();
    if (!serviceEnabled) {
      // Location services are still disabled
      return false;
    }
  }

  return true;
}




Future<bool> getLocationOpeningInfo(BuildContext context) async {
  final isLocationEnabled = await Geolocator.isLocationServiceEnabled();
  if(!isLocationEnabled) {
    showMsgWithAction(
        context: context,
        msg: 'Please turn on location',
        callback: () async {
          final status = await Geolocator.openLocationSettings();
          print(status);
        });
    return false;
  }
  else {
    return true;
  }
  try{
    // final position = await determinePosition();
    // return true;
  }catch(error) {
    rethrow;
  }
}
Future<bool> backgroundRunningFunction(BuildContext context) async {
  // final completer=Completer<bool>();
  bool isLocationOpen=true;
  Timer.periodic(Duration(seconds: 5), (Timer timer) async {
    // Perform your background tasks here
    print('Running background function...');

    final isLocationEnabled = await Geolocator.isLocationServiceEnabled();
    if(!isLocationEnabled) {
      showMsgWithAction(
          context: context,
          msg: 'Please turn on location',
          callback: () async {
            final status = await Geolocator.openLocationSettings();
            Navigator.pop(context);
            backgroundRunningFunction(context);
          });
      isLocationOpen=false;
      // completer.complete(false);
    }
    else {
      isLocationOpen=true;

    }
  });

  return isLocationOpen;
}




