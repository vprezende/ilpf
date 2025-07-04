import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:geodesy/geodesy.dart';
import 'package:ilpf/controllers/tree_controller.dart';
import 'package:ilpf/widgets/app_drawer.dart';
import 'package:provider/provider.dart';

// importando widgets

import '../widgets/area_dialog.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {

  bool isAddingPoints = false;
  int treeCounter = 0;

  late AppDrawer appDrawer = AppDrawer(
    treeCounter: treeCounter,
    onCounterChanged: (newValue) {
      setState(() => treeCounter = newValue);
    }
  );

  @override
  Widget build(BuildContext context) {

    final treeController = context.watch<TreeController>();
    final areaController = treeController.areaController;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        toolbarHeight: (56 + 20),
        leadingWidth: 75,
        leading: Builder(
          builder: (context) {
            return Container(
              margin: const EdgeInsets.only(top: 20, left: 20),
              child: FloatingActionButton(
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
                child: const Icon(Icons.menu),
              ),
            );
          },
        ),
      ),
      drawer: appDrawer,
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
            userAgentPackageName: 'dev.fleaflet.flutter_map.imagery'
          ),

          TileLayer(
            tileProvider: CancellableNetworkTileProvider(),
            urlTemplate: 'https://services.arcgisonline.com/ArcGIS/rest/services/Reference/World_Boundaries_and_Places/MapServer/tile/{z}/{y}/{x}',
            userAgentPackageName: 'dev.fleaflet.flutter_map.labels',
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

          MarkerLayer(
            markers: treeController.treeMarkers.map((point) {
              return Marker(
                point: point,
                width: 24,
                height: 24,
                child: Icon(Icons.park, color: Colors.green.shade800),
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
            onPressed: () => AreaDialog.show(context, areaController),
            child: const Icon(Icons.info),
          ),
        ],
      ),
    );
  }
}