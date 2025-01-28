import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_workers/utils/debouncer.dart';
import 'package:tulpar/controller/driver_moderation.dart';
import 'package:tulpar/core/colors.dart';
import 'package:tulpar/core/decoration.dart';

class CatalogCarsScreen extends StatefulWidget {
  const CatalogCarsScreen({super.key});

  @override
  State<CatalogCarsScreen> createState() => _CatalogCarsScreenState();
}

class _CatalogCarsScreenState extends State<CatalogCarsScreen> {
  var searchString = ValueNotifier<String>('');
  var searchDebouncer = Debouncer(delay: const Duration(milliseconds: 500));
  var searchTextController = TextEditingController();

  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      Get.find<DriverModerationController>().fetchCatalogCars(all: true);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DriverModerationController>(builder: (moderationController) {
      var carsLoading = moderationController.catalogCarsLoading.value;
      var searchLoading = moderationController.searchCarsLoading.value;

      var cars = moderationController.catalogCars.value.where((element) => element.popular == 1).toList();
      var allCars = moderationController.catalogCars.value;
      var searchCars = moderationController.searchResultCars.value;

      return DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: Text("База автомобилей".tr),
            bottom: TabBar(tabs: [
              Tab(text: "Популярные".tr),
              Tab(text: "Все".tr),
              Tab(text: "Поиск".tr),
            ]),
          ),
          body: Column(
            children: [
              AnimatedSwitcher(
                duration: Durations.short2,
                transitionBuilder: (child, animation) => SizeTransition(
                  sizeFactor: animation,
                  axis: Axis.vertical,
                  child: child,
                ),
                child: carsLoading ? const LinearProgressIndicator(color: CoreColors.primary) : const SizedBox.shrink(),
              ),
              Expanded(
                  child: TabBarView(children: [
                RefreshIndicator(
                    onRefresh: () async {
                      await moderationController.fetchCatalogCars();
                    },
                    child: ListView.builder(
                        itemCount: cars.length,
                        itemBuilder: (context, index) {
                          var car = cars[index];
                          return ListTile(
                            title: Text("${car.name}"),
                            onTap: () {
                              if (moderationController.selectedCar.value?.id != car.id) {
                                moderationController.selectedCarModel.value = null;
                              }
                              moderationController.selectedCar.value = car;
                              moderationController.update();
                              Navigator.of(context).pop();
                            },
                          );
                        })),
                RefreshIndicator(
                    onRefresh: () async {
                      await moderationController.fetchCatalogCars(all: true);
                    },
                    child: ListView.builder(
                        itemCount: allCars.length,
                        itemBuilder: (context, index) {
                          var car = allCars[index];
                          return ListTile(
                            title: Text("${car.name}"),
                            onTap: () {
                              if (moderationController.selectedCar.value?.id != car.id) {
                                moderationController.selectedCarModel.value = null;
                              }
                              moderationController.selectedCar.value = car;
                              moderationController.update();
                              Navigator.of(context).pop();
                            },
                          );
                        })),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(CoreDecoration.primaryPadding).copyWith(bottom: 0),
                      child: TextField(
                        controller: searchTextController,
                        onChanged: (value) {
                          searchString.value = value;
                          searchDebouncer.call(() {
                            moderationController.searchCatalogCars(searchString.value);
                          });
                        },
                        onTapOutside: (event) {
                          FocusScope.of(context).unfocus();
                        },
                        decoration: CoreDecoration.textField.copyWith(
                            hintText: 'Введите марку или модель'.tr,
                            suffixIcon: ValueListenableBuilder(
                                valueListenable: searchString,
                                builder: (_, s, __) {
                                  if (s.toString().isNotEmpty) {
                                    return IconButton(
                                        icon: const Icon(Icons.close),
                                        onPressed: () {
                                          searchTextController.clear();
                                          searchString.value = '';
                                        });
                                  }
                                  return const Icon(Icons.search);
                                })),
                      ),
                    ),
                    Expanded(
                      child: ValueListenableBuilder(
                          valueListenable: searchString,
                          builder: (_, s, __) {
                            if (searchCars.isEmpty) {
                              if (searchLoading) {
                                return const Center(child: CircularProgressIndicator(color: CoreColors.primary));
                              } else if (s.isEmpty) {
                                return Center(child: Text('Введите марку или модель'.tr));
                              } else {
                                return Center(child: Text('Ничего не найдено'.tr));
                              }
                            } else {
                              return ListView.builder(
                                  itemCount: searchCars.length,
                                  itemBuilder: (context, index) {
                                    var car = searchCars[index];
                                    if (car.models?.isEmpty ?? true) {
                                      return ListTile(
                                        title: Text(
                                          "${car.name}",
                                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                        ),
                                        onTap: () {
                                          if (moderationController.selectedCar.value?.id != car.id) {
                                            moderationController.selectedCarModel.value = null;
                                          }
                                          moderationController.selectedCar.value = car;
                                          moderationController.update();
                                          Navigator.of(context).pop();
                                        },
                                      );
                                    }
                                    return ExpansionTile(
                                      title: Text(
                                        "${car.name}",
                                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                      ),
                                      children: [
                                        ListView.builder(
                                            shrinkWrap: true,
                                            itemCount: car.models?.length ?? 0,
                                            itemBuilder: (context, index) {
                                              var model = car.models![index];
                                              return ListTile(
                                                leading: const Icon(Icons.remove, size: 12, color: CoreColors.primary),
                                                title: Text(
                                                  "${model.name}",
                                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                                ),
                                                onTap: () {
                                                  moderationController.selectedCar.value = car;
                                                  moderationController.selectedCarModel.value = model;
                                                  moderationController.update();
                                                  Navigator.of(context).pop();
                                                },
                                              );
                                            })
                                      ],
                                    );
                                  });
                            }
                          }),
                    )
                  ],
                )
              ])),
            ],
          ),
        ),
      );
    });
  }
}
