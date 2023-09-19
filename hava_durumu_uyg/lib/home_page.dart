import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hava_durumu_uyg/air_quality.dart';
import 'package:hava_durumu_uyg/search_page.dart';
import 'package:hava_durumu_uyg/weather/daily_weather_card.dart';
import "package:http/http.dart" as http;
import 'loading_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String location = "Diyarbakır";
  double? temperature;
  final String key = " "; //API anahtarını girin
  var locationData;
  String code = "home";
  var devicePosition;
  String? icon;

  List<String> icons = [];
  List<double> temperatures = [];
  List<String> dates = [];

  Future<void> getLocationDataFromAPI() async {
    locationData = await http.get(Uri.parse(
        "https://api.openweathermap.org/data/2.5/weather?q=$location&appid=$key&units=metric"));
    final locationDataParsed = jsonDecode(locationData.body);

    setState(() {
      temperature = locationDataParsed["main"]["temp"];
      location = locationDataParsed["name"];
      code = locationDataParsed["weather"].first["main"];
      //code = locationDataParsed["weather"][0]["main"]; üstteki kod ile aynı işlev
      icon = locationDataParsed["weather"].first["icon"];
    });
  }

  Future<void> getLocationDataFromAPIByLatLon() async {
    if (devicePosition != null) {
      locationData = await http.get(Uri.parse(
          "https://api.openweathermap.org/data/2.5/weather?lat=${devicePosition!.latitude}&lon=${devicePosition!.longitude}&appid=$key&units=metric"));
      final locationDataParsed = jsonDecode(locationData.body);

      setState(() {
        temperature = locationDataParsed["main"]["temp"];
        location = locationDataParsed["name"];
        code = locationDataParsed["weather"].first["main"];
        //code = locationDataParsed["weather"][0]["main"]; üstteki kod ile aynı
        icon = locationDataParsed["weather"].first["icon"];
      });
    }
  }

  Future<void> getDevicePosition() async {
    try {
      //bu kod çalışmazsa catch hangi hata oldugunu yazdırır
      devicePosition = await _determinePosition();
    } catch (e) {
      print("Şu hata oluştu $e");
    } finally {
      //hata fırlatsın veya fırlatmasın finally içindeki kod çalışır
    }
  }

  Future<void> getDailyForecastByLatLon() async {
    var forecastData = await http.get(Uri.parse(
        "https://api.openweathermap.org/data/2.5/forecast?q=$location&appid=$key&units=metric"));
    var forecastDataParsed = jsonDecode(forecastData.body);

    temperatures.clear();
    icons.clear();
    dates.clear();

    setState(() {
      for (int i = 7; i < 40; i = i + 8) {
        temperatures.add(forecastDataParsed["list"][i]["main"][
            "temp"]); //3 saatte bir yenilendiği için 24 saat sonrasi 8. liste elemanı oluyor yani 7. eleman
        icons.add(forecastDataParsed["list"][i]["weather"][0]["icon"]);
        dates.add(forecastDataParsed["list"][i]["dt_txt"]);
      }
    });
  }

  Future<void> getDailyForecastByLocation() async {
    var forecastData = await http.get(Uri.parse(
        "https://api.openweathermap.org/data/2.5/forecast?q=$location&appid=$key&units=metric"));
    var forecastDataParsed = jsonDecode(forecastData.body);

    temperatures.clear();
    icons.clear();
    dates.clear();

    setState(() {
      for (int i = 7; i < 40; i = i + 8) {
        temperatures.add(forecastDataParsed["list"][i]["main"]["temp"]);
        icons.add(forecastDataParsed["list"][i]["weather"][0]["icon"]);
        dates.add(forecastDataParsed["list"][i]["dt_txt"]);
      }
    });
  }

  void getInitialData() async {
    await getDevicePosition();
    await getLocationDataFromAPIByLatLon(); // Current weather data
    await getDailyForecastByLatLon(); //Forecast dor 5 days
  }

  @override
  void initState() {
    getInitialData();
    //getLocationDataFromAPI();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
            image: AssetImage("assets/$code.jpg"),
            fit: BoxFit
                .cover //cover tam ekranı doldur(cihaz boyutuna göre ayarlanıyor),
            ),
      ),

      //eğer temperature==null ise, CircularProgressIndicator göster,
      //aksi halde veri gelince setState yap ve Scaffold g?ster
      child: (temperature == null ||
              devicePosition == null ||
              icons.isEmpty ||
              dates.isEmpty ||
              temperatures.isEmpty)
          ? const LoadingWidget()
          : Scaffold(
              backgroundColor: Colors.transparent,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 100,
                      child: Image.network(
                          "https://openweathermap.org/img/wn/$icon@2x.png"),
                    ),
                    Text("$temperature °C",
                        style: const TextStyle(
                            fontSize: 70,
                            fontWeight: FontWeight.bold,
                            shadows: <Shadow>[
                              Shadow(
                                  color: Colors.black,
                                  blurRadius: 10,
                                  offset: Offset(5, 7))
                            ])),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(location,
                            style: const TextStyle(fontSize: 30, shadows: <Shadow>[
                              Shadow(
                                  color: Colors.black,
                                  blurRadius: 10,
                                  offset: Offset(5, 7))
                            ])),
                        IconButton(
                          onPressed: () async {
                            final selectedCity = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const SearchPage()));
                            location = selectedCity;
                            getLocationDataFromAPI();
                            getDailyForecastByLatLon();
                          },
                          icon: const Icon(Icons.search),
                        ),
                      ],
                    ),
                    const SizedBox(height: 35),
                    builWeatherCards(context),
                    OutlinedButton(
                        style: const ButtonStyle(
                            backgroundColor:
                                MaterialStatePropertyAll(Colors.black54)),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AirQuality()));
                        },
                        child: const Text(
                          "Hava Durumu Kalitesi",
                          style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ))
                  ],
                ),
              ),
            ),
    );
  }

  Widget builWeatherCards(BuildContext context) {
    List<DailyWeatherCard> cards = [];
    /*
    [DailyWeatherCard(icon: icons[0],date: dates[0],temperature: temperatures[0]),
      DailyWeatherCard(icon: icons[1],date: dates[1],temperature: temperatures[1]),
      DailyWeatherCard(icon: icons[2],date: dates[2],temperature: temperatures[2]),
      DailyWeatherCard(icon: icons[3],date: dates[3],temperature: temperatures[3]),
      DailyWeatherCard(icon: icons[4],date: dates[4],temperature: temperatures[4]),]; */
    for (int i = 0; i < 5; i++) {
      cards.add(DailyWeatherCard(
          icon: icons[i],
          temperature: temperatures[i],
          date: dates[i])); //for döngüsü ile 5 tane DailyWeatherCard tanımlandı
    }

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.3,

      ///Mevcut ekran genişliğinin %90 kadar alana yayıl
      width: MediaQuery.of(context).size.width * 0.93,
      child: ListView(
        scrollDirection: Axis.horizontal, //yatayda kaydır
        children: cards,
      ),
    );
  }

  Future<Position> _determinePosition() async {
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
}
