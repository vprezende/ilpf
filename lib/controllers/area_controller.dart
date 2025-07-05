import 'dart:convert';
import 'package:dart_jts/dart_jts.dart' as jts;
import 'package:flutter/material.dart';
import 'package:geodesy/geodesy.dart';
import 'package:http/http.dart' as http;
import 'package:ilpf/widgets/app_snackbars.dart';

class AreaController extends ChangeNotifier {

  final List<List<LatLng>> _areas = [];

  List<LatLng> currentArea = [];

  final List<List<LatLng>> _originalArea = [];

  addPoint(LatLng point) {
    currentArea.add(point);
    notifyListeners();
  }

  List<LatLng> sort(List<LatLng> areaPoints) {

    // Cria uma "fábrica" para construir as formas geométricas
    final geometryFactory = jts.GeometryFactory.defaultPrecision();

    // Converte seus pontos para o formato da biblioteca geométrica
    final coordinates = areaPoints
      .map((points) => jts.Coordinate(points.longitude, points.latitude))
      .toList();

    // Cria uma forma que envolve todos os pontos
    final shape = jts.ConvexHull.fromPoints(coordinates, geometryFactory).getConvexHull() as jts.Polygon;

    // Pega os pontos dessa forma e converte de volta para o formato de pontos
    // que o mapa consegue entender para poder desenhar
    return shape.getCoordinates()
      .map((coords) => LatLng(coords.y, coords.x))
      .toList();
  }

  closeArea(BuildContext context) {

    if (currentArea.length < 3) {
      showErrorSnackBar(
        context,
        message: 'Para fechar a área, adicione pelo menos 3 pontos'
      );
    }

    // verifica se a área não foi fechada
    // ou seja o primeiro ponto da lista é
    // diferente do último
    if (currentArea.first !=  currentArea.last) {

      this._originalArea.add(currentArea);

      currentArea = sort(currentArea);

      // Fecha a área conectando o último ponto ao primeiro,
      // garantindo que a área seja fechada visualmente e geometricamente.
      currentArea.add(currentArea.first);

      // Adiciona a área fechada à lista de áreas, Em Seguida, limpa
      // a lista atual para permitir o desenho de uma nova área
      this._areas.add(currentArea);
      currentArea = [];
    }
  }

  void resetArea() {
    this._areas.clear();
    currentArea.clear();
    this._originalArea.clear();
  }

  void undo() {
    if (currentArea.isNotEmpty) {
      currentArea.removeLast();
      return;
    }

    if (this._areas.isEmpty || this._originalArea.isEmpty) {
      return;
    }

    this._areas.removeLast();
    currentArea = this._originalArea.removeLast();
  }

  List<List<LatLng>> get allAreas => [...this._areas];

  Future<Map<String, dynamic>> fetchAreaData(BuildContext context) async {

    int areaIndex = 0;

    Map<String, dynamic> data = {};

    final Map<String, dynamic> result = {};

    final geodesy = Geodesy();

    for (final area in allAreas) {

      areaIndex++;

      final centroid = geodesy.findPolygonCentroid(area);

      final lat = centroid.latitude;
      final lon = centroid.longitude;

      final url = Uri.parse('https://rest.isric.org/soilgrids/v2.0/properties/query?lat=$lat&lon=$lon');

      try {

        int retryCount = 0;
        bool success = false;
        bool error = false;

        while(!success && !error) {

          final response = await http.get(url);

          if (response.statusCode != 200 && context.mounted) {
            showErrorSnackBar(
              context,
              message: 'error: Status code ${response.statusCode}'
            );
            error = true;
          }

          if (response.statusCode == 429) {
            retryCount++;
            final waitDuration = Duration(milliseconds: (200 * retryCount));
            await Future.delayed(waitDuration);
          }

          data = jsonDecode(response.body);

          data.remove('query_time_s');

          success = true;
        }
      } catch (e) {
        if (context.mounted) {
          showErrorSnackBar(
            context,
            message: 'error: Status code ${e.toString()}'
          );
        }
      }
      result['area_$areaIndex'] = data;
    }
    return result;
  }
}