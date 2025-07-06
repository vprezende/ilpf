import 'package:flutter/material.dart';
import 'package:geodesy/geodesy.dart';
import 'package:ilpf/controllers/area_controller.dart';

class TreeController extends ChangeNotifier {

  final AreaController areaController;

  List<LatLng> treeMarkers = [];
  List<List<LatLng>> ranks = [];

  TreeController({required this.areaController});

  void addRankTreeToArea(int areaIndex, int totalTrees, int sides) {

    final allAreas = this.areaController.allAreas;

    final area = allAreas[areaIndex];

    final treesPerSide = totalTrees ~/ sides;

    // Pecorre os lados da área
    for (int i = 0; i < sides; i++) {

      final startPoint = area[i];
      final endPoint = area[(i + 1) % sides]; // Fecha a área conectando (último → primeiro)

      // Colocando as árvores ao longo dos lados
      for (int j = 0; j < treesPerSide; j++) {

        double progress = j / treesPerSide;

        // Calcula a variação da latitude entre o ponto inicial e final do lado
        final deltaLat = endPoint.latitude - startPoint.latitude;

        // Calcula a variação da longitude entre o ponto inicial e final do lado
        final deltaLng = endPoint.longitude - startPoint.longitude;

        // Cálculo da variação proporcional da latitude com base no progresso ao longo do lado (0.0 até 1.0)

        double deltaLatProgress = deltaLat * progress;

        // Cálculo da variação proporcional da longitude com base no progresso ao longo do lado (0.0 até 1.0)

        double deltaLngProgress = deltaLng * progress;

        // Latitude final da árvore posicionada ao longo do lado

        final lat = startPoint.latitude + deltaLatProgress;

        // Longitude final da árvore posicionada ao longo do lado

        final lng = startPoint.longitude + deltaLngProgress;

        // Cria um novo ponto (LatLng) na posição calculada
        final point = LatLng(lat, lng);

        treeMarkers.add(point);
      }
    }

    ranks.add(treeMarkers);

    notifyListeners();
  }


  void addTreeToArea(int areaIndex) {

    final allAreas = this.areaController.allAreas;

    final area = allAreas[areaIndex];

    final geodesy = Geodesy();

    final minLat = area.map((p) => p.latitude).reduce(min);
    final maxLat = area.map((p) => p.latitude).reduce(max);
    final minLng = area.map((p) => p.longitude).reduce(min);
    final maxLng = area.map((p) => p.longitude).reduce(max);

    final random = Random();

    // Calculando a variação da latitude e longitude da área

    final deltaLat = maxLat - minLat;
    final deltaLng = maxLng - minLng;

    // Gera coordenadas aleatórias dentro do retângulo delimitador da área

    final lat = minLat + (random.nextDouble() * deltaLat);
    final lng = minLng + (random.nextDouble() * deltaLng);

    // Gerando o ponto dentro dos limites da área

    final point = LatLng(lat, lng);

    if (geodesy.isGeoPointInPolygon(point, area)) {
      treeMarkers.add(point);
      notifyListeners();
    }
  }
}
