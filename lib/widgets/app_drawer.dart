import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

import 'package:provider/provider.dart';
import 'package:ilpf/controllers/tree_controller.dart';

import '../controllers/area_controller.dart';

import 'package:flutter/services.dart';

import 'app_snackbars.dart';

class AppDrawer extends StatefulWidget {

  final int treeCounter;
  final void Function(int) onCounterChanged;

  const AppDrawer({
    super.key,
    required this.treeCounter,
    required this.onCounterChanged,
  });

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {

  final radioOptions = ['unidade', 'rank'];
  late ValueNotifier<String> radioValue = ValueNotifier(radioOptions.first);

  late int treeCounter;

  late AreaController areaController;
  late TreeController treeController;
  late TextEditingController sidesController;

  int selectedAreaIndex = -1;

  @override
  void initState() {
    super.initState();
    treeCounter = widget.treeCounter;
    sidesController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    treeController = Provider.of<TreeController>(context);
    areaController = treeController.areaController;

    if (areaController.allAreas.length == 1 && selectedAreaIndex == -1) {
      selectedAreaIndex = 0;
    }
  }

  @override
  void dispose() {
    super.dispose();
    sidesController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: (MediaQuery.of(context).size.width * 0.3),
      backgroundColor: Colors.grey.shade300,
      child: ValueListenableBuilder<String>(
        valueListenable: radioValue,
        builder: (context, value, _) {
          return ListView(
            children: [
              DrawerHeader(
                margin: EdgeInsets.zero,
                decoration: const BoxDecoration(color: Colors.lightBlue),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: DropdownButtonFormField2<int>(
                            isExpanded: true,
                            decoration: InputDecoration(
                              filled: true,
                              iconColor: Colors.grey,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none
                              ),
                            ),
                            dropdownStyleData: DropdownStyleData(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            menuItemStyleData:MenuItemStyleData(
                              overlayColor: WidgetStateProperty.all(Colors.grey.shade300),
                            ),
                            value: selectedAreaIndex == -1 ? null : selectedAreaIndex,
                            hint: Center(
                              child: Text(
                                'Selecione uma área',
                                style: TextStyle(
                                  color: Colors.grey.shade500
                                ),
                              )
                            ),
                            items: List.generate(areaController.allAreas.length, (index) {
                              return DropdownMenuItem(
                                value: index,
                                child: Center(
                                  child: Text(
                                    'area_${index + 1}'
                                  ),
                                ),
                              );
                            }),
                            onChanged: (index) {
                              setState(() => selectedAreaIndex = index!);
                            },
                          ),
                        ),
                        if (value == 'rank') ...[
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 15),
                            child: Text(
                              'Lados:',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: TextField(
                              controller: sidesController,
                              cursorColor: Colors.black.withValues(alpha: 0.35),
                              cursorRadius: const Radius.circular(8),
                              cursorWidth: 3,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(2)
                              ],
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                              ),
                            ),
                          )
                        ]
                      ]
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: radioOptions.map((op) {
                        return Row(
                          children: [
                            Radio<String>(
                              value: op,
                              groupValue: value,
                              visualDensity: VisualDensity.compact,
                              fillColor: const WidgetStatePropertyAll(Colors.white),
                              onChanged: (value) => radioValue.value = value!
                            ),
                            Text(
                              op,
                              style: const TextStyle(
                                color: Colors.white
                              ),
                            ),
                            const SizedBox(width: 16)
                          ]
                        );
                      }).toList(),
                    ),
                  ]
                )
              ),
              ListTile(
                leading: Icon(
                  Icons.park,
                  color: Colors.green.shade700
                ),
                title: const Text(
                  'Arvore',
                  style: TextStyle(
                    color: Colors.white
                  )
                ),
                tileColor: Colors.lightBlue,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Visibility(
                      visible: value == 'rank',
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            color: Colors.white,
                            onPressed: () {
                              setState(() {
                                if (treeCounter > 0) {
                                  treeCounter--;
                                  widget.onCounterChanged(treeCounter);
                                }
                              });
                            }
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              treeCounter.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16
                              )
                            )
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            color: Colors.white,
                            onPressed: () {
                              setState(() {
                                treeCounter++;
                                widget.onCounterChanged(treeCounter);
                              });
                            }
                          )
                        ]
                      )
                    ),
                    IconButton(
                      icon: const Icon(Icons.pin_drop),
                      color: Colors.green.shade700,
                      style: ButtonStyle(
                        overlayColor: WidgetStatePropertyAll(Colors.transparent.withValues(alpha: 0.05))
                      ),
                      onPressed: () {
                        if (selectedAreaIndex == -1) {
                          showErrorSnackBar(
                            context,
                            message: 'Por favor! escolha uma área'
                          );
                          return;
                        }

                        final text = sidesController.text;
                        final sides = int.tryParse(text) ?? 0;

                        final treesRemainder = treeCounter % sides;

                        if (treesRemainder != 0) {
                          showWarningSnackBar(
                            context,
                            message: 'A quantidade de árvores não é suficiente para construir o rank'
                          );
                          return;
                        }

                        if (sides < 3) {
                          showErrorSnackBar(
                            context,
                            message: 'Adicione pelo menos 3 pontos'
                          );
                          return;
                        }

                        treeController.addRankTreeToArea(selectedAreaIndex, treeCounter, sides);
                      }
                    )
                  ]
                )
              )
            ],
          );
        }
      )
    );
  }
}