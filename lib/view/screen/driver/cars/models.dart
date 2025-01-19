import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tulpar/controller/driver_moderation.dart';
import 'package:tulpar/core/colors.dart';

class CatalogCarModelsScreen extends StatefulWidget {
  const CatalogCarModelsScreen({super.key, required this.carId});
  final String carId;
  @override
  State<CatalogCarModelsScreen> createState() => _CatalogCarModelsScreenState();
}

class _CatalogCarModelsScreenState extends State<CatalogCarModelsScreen> {
  @override
  void initState() {
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      Get.find<DriverModerationController>().fetchCarModels(widget.carId);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DriverModerationController>(builder: (moderationController) {
      var models =
          moderationController.catalogCars.value.firstWhereOrNull((element) => element.id == widget.carId)?.models ??
              [];
      var loading = moderationController.catalogCarsLoading.value;
      return Scaffold(
        appBar: AppBar(
          title: Text("Выберите модель".tr),
        ),
        body: Column(
          children: [
            if (loading) const LinearProgressIndicator(color: CoreColors.primary),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await moderationController.fetchCarModels(widget.carId);
                },
                child: ListView.builder(
                  itemCount: models.length,
                  itemBuilder: (context, index) {
                    var model = models[index];
                    return ListTile(
                      title: Text("${model.name}"),
                      onTap: () {
                        moderationController.selectedCarModel.value = model;
                        moderationController.update();
                        Navigator.of(context).pop();
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
