import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:tulpar/controller/driver_moderation.dart';
import 'package:tulpar/core/colors.dart';

class CatalogCarsScreen extends StatefulWidget {
  const CatalogCarsScreen({super.key});

  @override
  State<CatalogCarsScreen> createState() => _CatalogCarsScreenState();
}

class _CatalogCarsScreenState extends State<CatalogCarsScreen> {
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

      var cars = moderationController.catalogCars.value.where((element) => element.popular == 1).toList();
      var allCars = moderationController.catalogCars.value;

      return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text("База автомобилей".tr),
            bottom: TabBar(tabs: [
              Tab(text: "Популярные".tr),
              Tab(text: "Все".tr),
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
                    child: ListView())
              ])),
            ],
          ),
        ),
      );
    });
  }
}
