import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:geocoding/geocoding.dart' as Geo;

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';

import '../helpers/constants.dart';
import '../models/current_response_model.dart';
import '../models/forecast_response_model.dart';


class WeatherProvider extends ChangeNotifier{
  CurrentResponseModel? currentResponseModel;
  ForecastModel? forecastResponseModel;
  List<ForcastList> forecastList=[];
  double latitude = 0.0, longitude = 0.0;
  String unit = 'metric';
  String unitSymbol = celsius;

  bool get hasDataLoaded => currentResponseModel != null;

  bool get isFahrenheit => unit == imperial;

  void setNewLocation(double lat, double lng) {
    latitude = lat;
    longitude = lng;
  }

  void setTempUnit(bool tag) {
    unit = tag ? imperial : metric;
    unitSymbol = tag ? fahrenheit : celsius;
    notifyListeners();
  }

  // Future<bool> setPreferenceTempUnitValue(bool tag) async {
  //   final pref = await SharedPreferences.getInstance();
  //   return pref.setBool('unit', tag);
  // }

  // Future<bool> getPreferenceTempUnitValue() async {
  //   final pref = await SharedPreferences.getInstance();
  //   return pref.getBool('unit') ?? false;
  // }

  getWeatherData() {
    _getCurrentData();
    _getForecastData();
  }

  void convertAddressToLatLng(String result) async {
    try{
      final locationList = await Geo.locationFromAddress(result);
      if(locationList.isNotEmpty) {
        final location = locationList.first;
        setNewLocation(location.latitude, location.longitude);
        getWeatherData();
      } else {
        print('City not found');
      }
    }catch(error) {
      //easyloading use koiren
      print(error.toString());

    }
  }

  void _getCurrentData() async {
    final uri = Uri.parse('https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&units=$unit&appid=$weather_api_key');
    try {
      final response = await get(uri);
      final map = jsonDecode(response.body);
      if(response.statusCode == 200) {
        currentResponseModel = CurrentResponseModel.fromJson(map);
        print(currentResponseModel!.main!.temp!.round());
        notifyListeners();
        print('CURRENT DATA CALLED');
      } else {
        print(map['message']);
      }
    }catch(error) {
      rethrow;
    }
  }

void _getForecastData() async {
  final uri = Uri.parse('https://api.openweathermap.org/data/2.5/forecast?lat=$latitude&lon=$longitude&units=$unit&appid=$weather_api_key');
  print('URI ${uri}');
  forecastList.clear();
  try {
    final response = await get(uri);
    final map = jsonDecode(response.body);
    if(response.statusCode == 200) {
      forecastResponseModel = ForecastModel.fromJson(map);
      for(Map<String,dynamic> i in map['list']){
        forecastList.add(ForcastList.fromJson(i));
      }
      print('forecastList.length ${forecastList.length}');
      print('FORECAST DATA CALLED');
      notifyListeners();
    } else {
      print(map['message']);
    }
  }catch(error) {
    rethrow;
  }
}
}