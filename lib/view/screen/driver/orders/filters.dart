import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16.0, left: CoreDecoration.primaryPadding),
            child: Text("Фильтрация", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          RadioListTile<int?>(
            title: Text(
              "Все",
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
        ],
      );
    });
  }
}
