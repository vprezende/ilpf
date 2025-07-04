import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

import 'package:provider/provider.dart';
import 'package:ilpf/controllers/tree_controller.dart';

import '../controllers/area_controller.dart';

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

  int selectedAreaIndex = 0;

  @override
  void initState() {
    super.initState();
    treeCounter = widget.treeCounter;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    treeController = Provider.of<TreeController>(context);
    areaController = treeController.areaController;
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
                    DropdownButtonFormField2<int>(
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
                      value: selectedAreaIndex,
                      hint: Center(
                        child: Text(
                          'Selecione uma área',
                          style: TextStyle(
                            color: Colors.grey.shade500
                          ),
                        )
                      ),
                      items: List.generate(areaController.areas.length, (index) {
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
                        treeController.addTreeToArea(selectedAreaIndex);
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