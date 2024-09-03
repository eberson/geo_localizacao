import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

Future<Position> _descobrePosicao() async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

  if (!serviceEnabled) {
    return Future.error("Serviço de geolocalização desabilitado.");
  }

  var permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied) {
      return Future.error("Não temos permissão para de usar geo localização");
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return Future.error("Não temos permissão e nem podemos pedi-la");
  }

  return await Geolocator.getCurrentPosition(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100,
    ),
  );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Coord? aPoint, anotherPoint;
  double? distance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(aPoint?.print() ?? "-/-"),
                  ElevatedButton(
                    onPressed: () async {
                      final position = await _descobrePosicao();

                      setState(() {
                        aPoint = Coord.fromPosition(position);
                      });
                    },
                    child: const Text("Carrega primeiro ponto"),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(anotherPoint?.print() ?? "-/-"),
                  ElevatedButton(
                    onPressed: () async {
                      final position = await _descobrePosicao();

                      setState(() {
                        anotherPoint = Coord.fromPosition(position);
                      });
                    },
                    child: const Text("Carrega segundo ponto"),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("${distance ?? -1}m"),
                  ElevatedButton(
                    onPressed: () {
                      if (aPoint != null && anotherPoint != null) {
                        setState(() {
                          distance = Geolocator.distanceBetween(
                            aPoint!.latitude,
                            aPoint!.longitude,
                            anotherPoint!.latitude,
                            anotherPoint!.longitude,
                          );
                        });
                      }
                    },
                    child: const Text("Recalcula distância"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Aplicacao extends StatelessWidget {
  const Aplicacao({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: "Geo Localização",
      home: HomePage(),
    );
  }
}

class Coord {
  final double latitude;
  final double longitude;
  final double acuracia;

  Coord(this.latitude, this.longitude, this.acuracia);

  String print() {
    return "Latitude: $latitude\nLongitude: $longitude\nAcurácia: $acuracia";
  }

  factory Coord.fromPosition(Position position) {
    return Coord(position.latitude, position.longitude, position.accuracy);
  }
}

void main() => runApp(const Aplicacao());
