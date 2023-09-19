import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String selectedCity = "";

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
            image: AssetImage("assets/search.jpg"),
            fit: BoxFit
                .cover //cover tüm ekranı doldur(cihaz boyutuna göre ayarlanıyor)
            ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: TextField(
                  onChanged: (value) {
                    selectedCity = value;
                    print("text fieldaki değer $value");
                  },
                  decoration: const InputDecoration(
                      hintText: "Şehir Seçiniz",
                      border: OutlineInputBorder(borderSide: BorderSide.none)),
                  style: TextStyle(fontSize: 30),
                  textAlign: TextAlign.center,
                ),
              ),
              ElevatedButton(
                  onPressed: () async {
                    ///Bu şehir için API yenıt veriyor mu?
                    var response = await http.get(Uri.parse(
                        "https://api.openweathermap.org/data/2.5/weather?q=$selectedCity&appid=55230a718de233dd6858a2c9b6f824c4"));
                    if (response.statusCode == 200) {
                      ///Sayfayi kaldir vev ayni zamanda bu sayfayi cagiran/acan yere komuta/satira geri don
                      Navigator.pop(context, selectedCity);
                    } else {
                      ///Kullanıcıya uyarı ver ve sayfada kal
                      ///Alert Dialog göster
                      _showMyDialog(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey,
                      foregroundColor: Colors.black54,
                      shadowColor: Colors.orange),
                  child: Text("Select City")),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showMyDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Şehir bulunamadı'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text("Lütfen yeni bir şehir giriniz.."),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
