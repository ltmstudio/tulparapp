import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tulpar/controller/driver_order.dart';
import 'package:tulpar/core/colors.dart';
import 'package:tulpar/core/decoration.dart';
import 'package:tulpar/core/styles.dart';
import 'package:tulpar/model/app/city.dart';
import 'package:tulpar/view/widget/elevated_button.dart';

class OrdersCitiesFiltersDialog extends StatelessWidget {
  const OrdersCitiesFiltersDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DriverOrderController>(builder: (orderController) {
      var cities = orderController.cities;
      var cityA = orderController.selectedCityA.value;
      var cityB = orderController.selectedCityB.value;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16.0, left: CoreDecoration.primaryPadding),
            child: Text("Фильтр по городам".tr, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Откуда'.tr, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                      color: CoreColors.white, borderRadius: BorderRadius.circular(CoreDecoration.primaryBorderRadius)),
                  child: Ink(
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(CoreDecoration.primaryBorderRadius)),
                    child: Material(
                      borderRadius: BorderRadius.circular(CoreDecoration.primaryBorderRadius),
                      color: Colors.transparent,
                      child: DropdownButton<CityModel?>(
                        isExpanded: true,
                        value: cityA,
                        underline: const SizedBox(),
                        items: [
                          DropdownMenuItem<CityModel?>(
                            value: null,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: CoreDecoration.primaryPadding),
                              child: Text("Выберите город".tr, style: CoreStyles.hint),
                            ),
                          ),
                          for (var city in cities)
                            DropdownMenuItem<CityModel?>(
                              value: city,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: CoreDecoration.primaryPadding),
                                child: Text("${city.name}", style: CoreStyles.h4),
                              ),
                            )
                        ],
                        onChanged: (CityModel? newValue) {
                          orderController.selectedCityA.value = newValue;
                          orderController.update();
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Text('Куда'.tr, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                      color: CoreColors.white, borderRadius: BorderRadius.circular(CoreDecoration.primaryBorderRadius)),
                  child: Ink(
                    child: Material(
                      color: Colors.transparent,
                      child: DropdownButton<CityModel?>(
                        isExpanded: true,
                        underline: const SizedBox(),
                        value: cityB,
                        items: [
                          DropdownMenuItem<CityModel?>(
                            value: null,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: CoreDecoration.primaryPadding),
                              child: Text("Выберите город".tr, style: CoreStyles.hint),
                            ),
                          ),
                          for (var city in cities)
                            DropdownMenuItem<CityModel?>(
                              value: city,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: CoreDecoration.primaryPadding),
                                child: Text("${city.name}", style: CoreStyles.h4),
                              ),
                            )
                        ],
                        onChanged: (CityModel? newValue) {
                          orderController.selectedCityB.value = newValue;
                          orderController.update();
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: PrimaryElevatedButton(
                          light: true,
                          onPressed: () {
                            orderController.unsetSelectedCities();
                            Navigator.of(context).pop(true);
                          },
                          text: 'Сбросить'.tr),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: PrimaryElevatedButton(
                          onPressed: () {
                            orderController.setSelectedCities(
                                orderController.selectedCityA.value, orderController.selectedCityB.value);
                            Navigator.of(context).pop(true);
                          },
                          text: 'Применить'.tr),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
        // orderController.selectedOrderType.value = value;
        // orderController.update();
        // Navigator.of(context).pop(true);
      );
    });
  }
}
