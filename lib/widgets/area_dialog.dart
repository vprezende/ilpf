import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:ilpf/widgets/app_snackbars.dart';

import '../controllers/area_controller.dart';

class AreaDialog extends StatefulWidget {

  final String jsonString;

  const AreaDialog(this.jsonString, {super.key});

  static Future<void> show(BuildContext context, AreaController areaController) async {

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

    if (!context.mounted) return;

    final data = await areaController.fetchAreaData(context);

    if (!context.mounted) return;

    Navigator.of(context).pop();

    String jsonStringApiData = jsonEncode(data);

    showDialog(
      context: context,
      builder: (context) {
        return AreaDialog(jsonStringApiData);
      },
    );
  }

  @override
  State<AreaDialog> createState() => _AreaDialogState();
}

class _AreaDialogState extends State<AreaDialog> {

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