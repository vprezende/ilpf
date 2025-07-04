import 'package:flutter/material.dart';
import 'package:geodesy/geodesy.dart';
import 'package:ilpf/controllers/area_controller.dart';

class TreeController extends ChangeNotifier {

  final AreaController areaController;
  List<LatLng> treeMarkers = [];

  TreeController({required this.areaController});

  void addTreeToArea(int areaIndex) {

    final allAreas = this.areaController.allAreas;

    final area = allAreas[areaIndex];

    final geodesy = Geodesy();

    final minLat = area.map((p) => p.latitude).reduce(min);
    final maxLat = area.map((p) => p.latitude).reduce(max);
    final minLng = area.map((p) => p.longitude).reduce(min);
    final maxLng = area.map((p) => p.longitude).reduce(max);

    final random = Random();

    // calculando a altura referente a latitude e
    // longitude da área

    final heightLat = maxLat - minLat;
    final heightLng = maxLng - minLng;

    // gerando uma variação aleatória da latitude e longitude

    final deltaLat = random.nextDouble() * heightLat;
    final deltaLng = random.nextDouble() * heightLng;

    // latitude e logintude finais dentro dos limites da área

    final lat = minLat + deltaLat;
    final lng = minLng + deltaLng;

    // gerando o ponto dentro dos limites da área

    final point = LatLng(lat, lng);

    if (geodesy.isGeoPointInPolygon(point, area)) {
      treeMarkers.add(point);
      notifyListeners();
    }
  }
}
