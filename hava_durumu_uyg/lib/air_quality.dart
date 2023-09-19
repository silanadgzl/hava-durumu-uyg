/////////LAT LON BİLGİSİNİ BU SAYFAYA ÇEK BU BİLGİLERE GÖRE HAVA KALİTESİNİ GÖSTER

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hava_durumu_uyg/loading_widget.dart';
import "package:http/http.dart" as http;

class AirQuality extends StatefulWidget {
  const AirQuality({Key? key}) : super(key: key);

  @override
  State<AirQuality> createState() => _AirQualityState();
}

class _AirQualityState extends State<AirQuality> {
  final String apiKey =" "; // API anahtarını buraya girin
  var airQuality;
  var co;
  var no;
  var no2;
  var o3;
  var so2;
  var pm_5;
  var pm10;
  var nh3;
  List<String> value = ["iyi", "Orta", "Orta", "Zayıf", "Çok Kötü"];

  Future<void> getAirPollutionData() async {
    final response = await http.get(Uri.parse(
        "http://api.openweathermap.org/data/2.5/air_pollution?lat=60&lon=50&appid=$apiKey"));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        airQuality = data["list"][0]["main"]["aqi"];
        co = data["list"][0]["components"]["co"];
        no = data["list"][0]["components"]["no"];
        no2 = data["list"][0]["components"]["no2"];
        o3 = data["list"][0]["components"]["o3"];
        so2 = data["list"][0]["components"]["so2"];
        pm_5 = data["list"][0]["components"]["pm5"];
        pm10 = data["list"][0]["components"]["pm10"];
        nh3 = data["list"][0]["components"]["nh3"];
      });
    } else {
      print("Error: ${response.statusCode}");
    }
  }

  @override
  void initState() {
    getAirPollutionData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/sis.jpg"),
          fit: BoxFit.cover,
        ),
      ),
      child: airQuality == null
          ? const LoadingWidget()
          : Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("Hava Durumu Kalitesi"),
                ),
              ),
              body: Column(
                children: [
                  const Text(
                    "Hava Kalite İndeksi",
                    style: TextStyle(fontSize: 45, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 45),
                  Text(
                    "$airQuality ${value[airQuality - 1]}",
                    style: const TextStyle(
                      fontSize: 45,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  SizedBox(height: 70),
                  Text(
                    "Hava Kalitesi ${value[airQuality - 1]}",
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.2,
                    width: MediaQuery.of(context).size.width * 0.93,
                    child: ListView(
                      padding: EdgeInsetsDirectional.all(20),
                      scrollDirection: Axis.horizontal,
                      children: [
                        buildDataCard("CO", co.toString()),
                        buildDataCard("NO", no.toString()),
                        buildDataCard("NO2", no2.toString()),
                        buildDataCard("O3", o3.toString()),
                        buildDataCard("SO2", so2.toString()),
                        buildDataCard("PM5", pm_5.toString()),
                        buildDataCard("PM10", pm10.toString()),
                        buildDataCard("NH3", nh3.toString()),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget buildDataCard(String title, String value) {
    return Card(
      color: Colors.transparent,
      margin: EdgeInsets.all(8),
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
