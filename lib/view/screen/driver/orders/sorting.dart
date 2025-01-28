import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tulpar/controller/driver_order.dart';
import 'package:tulpar/core/decoration.dart';

class OrdersSortingDialog extends StatelessWidget {
  const OrdersSortingDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DriverOrderController>(builder: (orderController) {
      var selectedSortingValue = orderController.selectedSortingValue.value;
      var sortingValues = orderController.sortingValues;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16.0, left: CoreDecoration.primaryPadding),
            child: Text("Сортировка".tr, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          for (var value in sortingValues)
            RadioListTile<String?>(
              title: Text(
                "${value.name}".tr,
                style: const TextStyle(fontSize: 16),
              ),
              value: value.name,
              groupValue: selectedSortingValue?.name,
              onChanged: (v) {
                orderController.selectedSortingValue.value = value;
                orderController.update();
                Navigator.of(context).pop(true);
              },
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              contentPadding: EdgeInsets.zero,
            ),
        ],
      );
    });
  }
}
