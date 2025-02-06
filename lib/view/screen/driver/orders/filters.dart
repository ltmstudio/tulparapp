import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tulpar/controller/driver.dart';
import 'package:tulpar/controller/driver_order.dart';
import 'package:tulpar/core/decoration.dart';

class OrdersFiltersDialog extends StatelessWidget {
  const OrdersFiltersDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DriverOrderController>(builder: (orderController) {
      var orderTypes = orderController.orderTypes;
      var selectedOrderType = orderController.selectedOrderType.value;
      var orderClasses = orderController.orderClasses;
      var selectedOrderClass = orderController.selectedOrderClass.value;
      var selectedNoDelivery = orderController.selectedNotDelivery.value;
      var selectedNoCargo = orderController.selectedNoCargo.value;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16.0, left: CoreDecoration.primaryPadding),
            child: Text("Фильтрация".tr, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 16.0, left: CoreDecoration.primaryPadding),
                  child: Text("Тип".tr, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
                RadioListTile<int?>(
                  title: Text(
                    "Все".tr,
                    style: const TextStyle(fontSize: 16),
                  ),
                  value: null,
                  groupValue: selectedOrderType?.id,
                  onChanged: (v) {
                    orderController.selectedOrderType.value = null;
                    orderController.update();
                    Navigator.of(context).pop(true);
                  },
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  contentPadding: EdgeInsets.zero,
                ),
                for (var value in orderTypes)
                  RadioListTile<int?>(
                    title: Text(
                      "${value.name}",
                      style: const TextStyle(fontSize: 16),
                    ),
                    value: value.id,
                    groupValue: selectedOrderType?.id,
                    onChanged: (v) {
                      orderController.selectedOrderType.value = value;
                      orderController.update();
                      Navigator.of(context).pop(true);
                    },
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    contentPadding: EdgeInsets.zero,
                  ),
                Divider(),
                Padding(
                  padding: const EdgeInsets.only(top: 16.0, left: CoreDecoration.primaryPadding),
                  child: Text("Класс поездки".tr, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
                RadioListTile<int?>(
                  title: Text(
                    "Все".tr,
                    style: const TextStyle(fontSize: 16),
                  ),
                  value: null,
                  groupValue: selectedOrderClass?.id,
                  onChanged: (v) {
                    orderController.selectedOrderClass.value = null;
                    orderController.update();
                    Navigator.of(context).pop(true);
                  },
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  contentPadding: EdgeInsets.zero,
                ),
                for (var orderClass in orderClasses)
                  RadioListTile<int?>(
                    title: Text(
                      "${orderClass.name}",
                      style: const TextStyle(fontSize: 16),
                    ),
                    value: orderClass.id,
                    groupValue: selectedOrderClass?.id,
                    onChanged: (v) {
                      orderController.selectedOrderClass.value = orderClass;
                      orderController.update();
                      Navigator.of(context).pop(true);
                    },
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    contentPadding: EdgeInsets.zero,
                  ),
                GetBuilder<DriverController>(builder: (driverController) {
                  var profile = driverController.profile.value;
                  if (profile?.delivery != 1 && profile?.cargo != 1) return const SizedBox();
                  return Column(
                    children: [
                      if (profile?.delivery == 1)
                        CheckboxListTile(
                          value: !selectedNoDelivery,
                          onChanged: (v) {
                            orderController.selectedNotDelivery.value = !v!;
                            orderController.update();
                            Navigator.of(context).pop(true);
                          },
                          title: Text("Доставка".tr),
                        ),
                      if (profile?.cargo == 1)
                        CheckboxListTile(
                          value: !selectedNoCargo,
                          onChanged: (v) {
                            orderController.selectedNoCargo.value = !v!;
                            orderController.update();
                            Navigator.of(context).pop(true);
                          },
                          title: Text("Груз".tr),
                        ),
                    ],
                  );
                })
              ],
            ),
          ),
        ],
      );
    });
  }
}
