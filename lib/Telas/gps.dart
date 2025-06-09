import 'package:flutter/material.dart';
import 'package:forumwebapp/Services/location_service.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? _location = "Loading...";
  bool isLoading = true;
  final LocationService _locationHelper = LocationService();

  Future<void> getUserLocation() async {
    setState(() => isLoading = true);

    final locationData = await _locationHelper.getUserLocation();
    if (locationData != null) {
      setState(() {
        _location =
        'Latitude: ${locationData['latitude']}, Longitude: ${locationData['longitude']}\n'
            'City: ${locationData['city']}, Country: ${locationData['country']}\n'
            'Address: ${locationData['address']}';
        isLoading = false;
      });
    } else {
      setState(() {
        _location = "Location not found";
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    getUserLocation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Your Location:', style: TextStyle(fontSize: 20)),
            isLoading
                ? const CircularProgressIndicator()
                : Center(child: Text(_location!, style: const TextStyle(fontSize: 20))),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: getUserLocation,
        tooltip: 'Refresh Location',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}