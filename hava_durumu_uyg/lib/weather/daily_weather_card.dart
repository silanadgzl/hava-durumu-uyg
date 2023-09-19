import 'package:flutter/material.dart';

class DailyWeatherCard extends StatelessWidget {
  const DailyWeatherCard({Key? key,required this.icon, required this.temperature, required this.date}) : super(key: key);

  final String icon;
  final double temperature;
  final String date;

  @override
  Widget build(BuildContext context) {
    //txt olarak gelen date verisini Datetime objesine parse
    DateTime parsedTime = DateTime.parse(date);
    List<String> weekdays=["Pazartesi","Salı","Çarşamba","Perşembe","Cuma","Cumartesi","Pazar"];
    return Card(
      color: Colors.transparent,
      //elevation: 0, tamamen şeffaf yapar
      child: SizedBox(
        child: Column(children: [
          Image.network("https://openweathermap.org/img/wn/$icon@2x.png"),
          Text("$temperature °C",
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold)),
          Text(weekdays[parsedTime.weekday-1],style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 20),)
        ]),
      ),
    );
  }
}

