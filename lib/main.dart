import 'package:flutter/material.dart';
import 'package:ilpf/controllers/area_controller.dart';
import 'package:ilpf/controllers/tree_controller.dart';
import 'package:ilpf/screens/map_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AreaController()),
        ChangeNotifierProvider(create: (context) => TreeController(
          areaController: context.read<AreaController>()
        ))
      ],
      child: const HomeScreen(),
    )
  );
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue
        ).copyWith(
          primary: Colors.blue,
          primaryContainer: Colors.blue,
          onPrimaryContainer: Colors.white
        ),
      ),
      home: const MapScreen(),
    );
  }
}