import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:ilpf/controllers/area_controller.dart';
import 'package:geodesy/geodesy.dart';
import 'package:ilpf/widgets/app_snackbars.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue),
      ),
      home: const MapScreen(),
    );
  }
}

class JsonDialog extends StatefulWidget {

  final String jsonString;

  const JsonDialog(this.jsonString, {super.key});

  @override
  State<JsonDialog> createState() => _JsonDialogState();
}

class _JsonDialogState extends State<JsonDialog> {

  late final ScrollController verticalController;
  late final ScrollController horizontalController;

  late final String formattedJson;

  @override
  void initState() {

    super.initState();

    verticalController = ScrollController();
    horizontalController = ScrollController();

    formattedJson = const JsonEncoder.withIndent('  ').convert(jsonDecode(widget.jsonString));
  }

  @override
  void dispose() {
    verticalController.dispose();
    horizontalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Center(
        child: Text('Dados da Área')
      ),
      content: SizedBox(
        width: 400,
        height: 400,
        child: Scrollbar(
          controller: verticalController,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: verticalController,
            scrollDirection: Axis.vertical,
            child: Scrollbar(
              controller: horizontalController,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: horizontalController,
                scrollDirection: Axis.horizontal,
                child: Text(
                  formattedJson,
                  style: const TextStyle(fontFamily: 'monospace'),
                )
              ),
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Fechar'),
        ),
      ],
    );
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {

  AreaController areaController = AreaController();

  bool isAddingPoints = false;

  void showJsonDialog(BuildContext context, String jsonString) {
    showDialog(
      context: context,
      builder: (context) {
        return JsonDialog(jsonString);
      },
    );
  }

  Future<void> showAllAreasAsJson() async {

    if (areaController.currentArea.isNotEmpty) {
      showWarningSnackBar(
        context,
        message: 'Você precisa fechar a área atual antes de visualizar os dados'
      );
      return;
    }

    if (areaController.allAreas.isEmpty) {
      showErrorSnackBar(
        context,
        message: 'Nenhuma área fechada foi adicionada ainda'
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Carregando dados da área...'),
            ],
          ),
        );
      },
    );

    await Future.delayed(Duration.zero);

    if (mounted) {

      final data = await areaController.fetchAreaData(context);

      if (mounted) {
        Navigator.of(context).pop();

        String jsonStringApiData = jsonEncode(data);

        showJsonDialog(context, jsonStringApiData);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterMap(
        options: MapOptions(
          initialCenter: const LatLng(-21.1358, -41.68),
          initialZoom: 13,
          minZoom: 3,
          maxZoom: 17,
          onTap: ((_, point) {
            if (isAddingPoints) {
              setState(() => areaController.addPoint(point));
            }
          }),
          // Impedindo que o usuário ultrapasse a borda inferior e superior do mapa
          cameraConstraint: CameraConstraint.contain(
            bounds: LatLngBounds(
              const LatLng(-85.0511, -180), // Limite inferior da projeção Mercator
              const LatLng(85.0511, 180), // Limite superior da projeção Mercator
            ),
          ),
        ),
        children: [
          TileLayer(
            tileProvider: CancellableNetworkTileProvider(),
            urlTemplate: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
            userAgentPackageName: 'dev.fleaflet.flutter_map.example',
          ),

          TileLayer(
            tileProvider: CancellableNetworkTileProvider(),
            urlTemplate: 'https://services.arcgisonline.com/ArcGIS/rest/services/Reference/World_Boundaries_and_Places/MapServer/tile/{z}/{y}/{x}',
            userAgentPackageName: 'dev.fleaflet.flutter_map.example',
          ),

          // Camada para exibir os pontos da tela
          MarkerLayer(
            markers: areaController.currentArea.map((point) {
              return Marker(
                point: point,
                width: 12,
                height: 12,
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue,
                  ),
                ),
              );
            }).toList(),
          ),

          // Camada para desenhar o polígono
          PolygonLayer(
            polygons: areaController.allAreas.map((polygon) {
              return Polygon(
                points: polygon,
                color: Colors.blue.withAlpha(80),
                borderStrokeWidth: 3.0,
                borderColor: Colors.blue,
              );
            }).toList(),
          ),
        ],
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            onPressed: () {
              setState(() {
                isAddingPoints = !isAddingPoints;
              });
            },
            backgroundColor: isAddingPoints ? Colors.green : Colors.blue,
            child: Icon(isAddingPoints ? Icons.add_location_alt : Icons.add_location_alt_outlined,),
          ),

          const SizedBox(height: 25),

          FloatingActionButton(
            onPressed: () {
              setState(() => areaController.closeArea(context));
            },
            child: const Icon(Icons.crop_square)
          ),

          const SizedBox(height: 25),

          FloatingActionButton(
            onPressed: () {
              setState(() => areaController.resetArea());
            },
            child: const Icon(Icons.delete)
          ),

          const SizedBox(height: 25),

          FloatingActionButton(
            onPressed: () {
              setState(() => areaController.undo());
            },
            child: const Icon(Icons.undo)
          ),

          const SizedBox(height: 25),

          FloatingActionButton(
            onPressed: showAllAreasAsJson,
            child: const Icon(Icons.info),
          ),
        ],
      ),
    );
  }
}