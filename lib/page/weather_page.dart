import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../helpers/constants.dart';
import '../helpers/helper_function.dart';
import '../providers/weather_provider.dart';

class WeatherPage extends StatefulWidget {
  static const String routeName='/weather';
  const WeatherPage({Key? key}) : super(key: key);

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  late WeatherProvider provider;
  bool isFirst = true;


  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if(isFirst) {
      provider = Provider.of<WeatherProvider>(context);
      _getData();
      isFirst = false;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          alignment: Alignment.topCenter,
      
          child: provider.hasDataLoaded ? ListView(
            shrinkWrap: true,
            padding:  EdgeInsets.all(8),
            children: [
              SizedBox(height: 30,),
              _currentWeatherSection(),
              ...provider.forecastList!.map((e) => ListTile(title: Text(e.wind!.speed!.toString()),))
            ],
          ) :
          Center(child: Text('Please wait...',style: TextStyle(color: Colors.black),)),
        ),
      ),
    );
  }
  Widget _currentWeatherSection() {
    final response = provider.currentResponseModel;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(

          children: [
            SizedBox(height: 30,),
            Text('Today ${getFormattedDateTime(response!.dt!, 'MMM dd, yyyy')}',style:  GoogleFonts.sora(color: Colors.black,fontSize: 16),),
            Row(
              children: [
                IconButton(onPressed: (){}, icon: Icon(Icons.search,color: Colors.transparent,)),
                IconButton(onPressed: (){}, icon: Icon(Icons.location_on_outlined,color: Colors.transparent,)),
                Expanded(child: Text('${response.name}',style:  GoogleFonts.sora(color: Colors.black,fontSize: 22),textAlign: TextAlign.center,)),
                IconButton(onPressed: ()async{
                  final result=await showSearch(context: context, delegate: _CitySearchDelegate());
                  if(result!=null&&result.isNotEmpty){
                    provider.convertAddressToLatLng(result);
                  }
                }, icon: Icon(Icons.search,color: Colors.black,)),
                IconButton(onPressed: (){
                  _getData();
                }, icon: Icon(Icons.location_on_outlined,color: Colors.black,)),
              ],
            ),
            Text('${response.sys!.country}',style:  GoogleFonts.sora(color: Colors.black,fontSize: 16),),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0,horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  // color: Color.fromARGB(5, 22, 44, 33),
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.8), // Shadow color
                      spreadRadius: 0, // How far the shadow extends
                      blurRadius: 10, // The blur radius
                      offset: Offset(0, 5), // Offset in the y-direction (bottom shadow)
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.network('$iconPrefix${response.weather![0].icon}$iconSuffix', fit: BoxFit.contain,color:Colors.black,height: 70,width: 70,),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(' ${response.main!.temp!.round()}$degree${provider.unitSymbol}',style:  GoogleFonts.sora( color:Colors.black,fontSize: 42),),
                          Wrap(
                            alignment: WrapAlignment.start,

                            children: [
                              const SizedBox(width: 10,),
                              Text('${response.weather![0].main}, ${response.weather![0].description}',style:  GoogleFonts.sora(color:Colors.black,fontSize: 16),)
                            ],
                          ),
                        ],
                      )

                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 20,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset('images/min.svg',height: 32,width: 32,color: Colors.black,),
                        SizedBox(width: 10,),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${response.main!.tempMin}$degree${provider.unitSymbol}',style:  GoogleFonts.sora(color: Colors.black,fontSize: 16),),
                            SizedBox(height: 5,),
                            Text('Minimum',style:  GoogleFonts.sora(color: Colors.black,fontSize: 16,fontWeight: FontWeight.w500),),

                          ],
                        )
                      ],
                    ),
                    SizedBox(height: 10,),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset('images/humidity.svg',height: 32,width: 32,color: Colors.black,),
                        SizedBox(width: 10,),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${response.main!.humidity}%',style:  GoogleFonts.sora(color: Colors.black,fontSize: 16),),
                            SizedBox(height: 5,),
                            Text('Humidity',style:  GoogleFonts.sora(color: Colors.black,fontSize: 16,fontWeight: FontWeight.w500),),
                          ],
                        )
                      ],
                    ),

                    SizedBox(height: 10,),
                    // Text('Sea level',style:  GoogleFonts.sora(color: Colors.black,fontSize: 16),),
                    // SizedBox(height: 5,),
                    // Text('${response.main!.seaLevel}',style:  GoogleFonts.sora(color: Colors.black,fontSize: 16),),
                    // SizedBox(height: 10,),

                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [

                        SvgPicture.asset('images/fahrenheit.svg',height: 32,width: 32,color: Colors.black,),
                        SizedBox(width: 10,),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${(response.main!.temp!*(9/5)+32).toStringAsFixed(2)} F',style:  GoogleFonts.sora(color: Colors.black,fontSize: 16),),
                            SizedBox(height: 5,),
                            Text('Fahrenheit',style:  GoogleFonts.sora(color: Colors.black,fontSize: 16,fontWeight: FontWeight.w500),),
                          ],
                        )
                      ],
                    ),

                    SizedBox(height: 10,),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset('images/wind.svg',height: 32,width: 32,color: Colors.black,),
                        SizedBox(width: 10,),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${response.wind!.speed}m/s',style:  GoogleFonts.sora(color: Colors.black,fontSize: 16),),
                            SizedBox(height: 5,),
                            Text('Wind',style:  GoogleFonts.sora(color: Colors.black,fontSize: 16,fontWeight: FontWeight.w500),),

                          ],
                        )
                      ],
                    ),

                    SizedBox(height: 10,),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset('images/sunrise.svg',height: 32,width: 32,color: Colors.black,),
                        SizedBox(width: 10,),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            Text('${getFormattedDateTime(response.sys!.sunrise!, 'hh:mm a')}',style:  GoogleFonts.sora(color: Colors.black,fontSize: 16),),
                            SizedBox(height: 5,),
                            Text('Sunrise',style:  GoogleFonts.sora(color: Colors.black,fontSize: 16,fontWeight: FontWeight.w500),),

                          ],
                        )
                      ],
                    ),
                    SizedBox(height: 10,),
                  ],
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset('images/max.svg',height: 32,width: 32,color: Colors.black,),
                        SizedBox(width: 10,),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${response.main!.tempMax}$degree${provider.unitSymbol}',style:  GoogleFonts.sora(color: Colors.black,fontSize: 16),),
                            SizedBox(height: 5,),
                            Text('Maximum',style:  GoogleFonts.sora(color: Colors.black,fontSize: 16,fontWeight: FontWeight.w500),),
                          ],
                        )
                      ],
                    ),
                    SizedBox(height: 10,),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset('images/air.svg',height: 32,width: 32,color: Colors.black,),
                        SizedBox(width: 10,),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${response.main!.pressure} Pa',style:  GoogleFonts.sora(color: Colors.black,fontSize: 16),),
                            SizedBox(height: 5,),
                            Text('Air pressure',style:  GoogleFonts.sora(color: Colors.black,fontSize: 16,fontWeight: FontWeight.w500),),
                          ],
                        )
                      ],
                    ),



                    SizedBox(height: 10,),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset('images/visibility.svg',height: 32,width: 32,color: Colors.black,),
                        SizedBox(width: 10,),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${response.visibility}',style:  GoogleFonts.sora(color: Colors.black,fontSize: 16),),
                            SizedBox(height: 5,),
                            Text('Visibility',style:  GoogleFonts.sora(color: Colors.black,fontSize: 16,fontWeight: FontWeight.w500),),
                          ],
                        )
                      ],
                    ),

                    SizedBox(height: 10,),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset('images/degree.svg',height: 32,width: 32,color: Colors.black,),
                        SizedBox(width: 10,),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${response.wind!.deg}$degree',style:  GoogleFonts.sora(color: Colors.black,fontSize: 16),),
                            SizedBox(height: 5,),
                            Text('Degree',style:  GoogleFonts.sora(color: Colors.black,fontSize: 16,fontWeight: FontWeight.w500),),

                          ],
                        )
                      ],
                    ),


                    SizedBox(height: 10,),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset('images/sunset.svg',height: 32,width: 32,color: Colors.black,),
                        SizedBox(width: 10,),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${getFormattedDateTime(response.sys!.sunset!, 'hh:mm a')}',style:  GoogleFonts.sora(color: Colors.black,fontSize: 16),),
                            SizedBox(height: 5,),
                            Text('Sunset',style:  GoogleFonts.sora(color: Colors.black,fontSize: 16,fontWeight: FontWeight.w500),),

                          ],
                        )
                      ],
                    ),

                    SizedBox(height: 10,),
                  ],
                ),
              ],
            ),



          ],
        ),
      

      ],
    );
  }

  Future<void> _getData() async {
    final isLocationEnabled = await Geolocator.isLocationServiceEnabled();
    if(!isLocationEnabled) {
      showMsgWithAction(
          context: context,
          msg: 'Please turn on location',
          callback: () async {
            final status = await Geolocator.openLocationSettings();
            print(status);
          });
      return;
    }
    try{
      final position = await determinePosition();
      provider.setNewLocation(position.latitude, position.longitude);
      // provider.setTempUnit(await provider.getPreferenceTempUnitValue());
      provider.getWeatherData();
    }catch(error) {
      rethrow;
    }
  }

 






}


class _CitySearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: const Icon(Icons.clear),
      )
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    IconButton(
      onPressed: () {
        close(context, '');
      },
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.search),
      title: Text(query),
      onTap: () {
        close(context, query);
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final filteredList = query.isEmpty ? cities :
    cities.where((city) =>
        city.toLowerCase().startsWith(query.toLowerCase())).toList();
    return ListView.builder(
      itemCount: filteredList.length,
      itemBuilder: (context, index) => ListTile(
        title: Text(filteredList[index]),
        onTap: () {
          query = filteredList[index];
          close(context, query);
        },
      ),
    );
  }

}