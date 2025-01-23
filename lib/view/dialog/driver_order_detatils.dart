import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tulpar/controller/driver_order.dart';
import 'package:tulpar/core/colors.dart';
import 'package:tulpar/core/decoration.dart';
import 'package:tulpar/core/log.dart';
import 'package:tulpar/model/order/order.dart';
import 'package:tulpar/view/component/order/order_card.dart';

class DriverOrderDetailsDialog extends StatefulWidget {
  const DriverOrderDetailsDialog({
    super.key,
    required this.order,
  });

  final OrderModel order;

  @override
  State<DriverOrderDetailsDialog> createState() => _DriverOrderDetailsDialogState();
}

class _DriverOrderDetailsDialogState extends State<DriverOrderDetailsDialog> {
  @override
  void dispose() {
    Log.error('Dispose DriverOrderDetailsDialog');
    Get.find<DriverOrderController>().removeSelectedOrder();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;

    return Container(
      height: h * 0.5,
      padding: const EdgeInsets.all(CoreDecoration.primaryPadding),
      child: Column(
        children: [
          Text(
            'Заказ №${widget.order.id}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: CoreColors.black),
          ),
          const Divider(height: 25),
          Row(
            children: [
              if (widget.order.typeId != null)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Тип'.tr,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                      Text(
                        widget.order.type ?? widget.order.typeId.toString(),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: CoreColors.primary),
                      ),
                    ],
                  ),
                ),
              if (widget.order.carClass != null)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Класс поездки'.tr,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                      Text(
                        widget.order.carClass?.name ?? widget.order.classId.toString(),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: CoreColors.primary),
                      ),
                    ],
                  ),
                ),
              if (widget.order.people != null)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Кол-во пассажиров'.tr,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                      Text(
                        "${widget.order.people}",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: CoreColors.primary),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          if (widget.order.typeId == 1 && widget.order.pointA != null && widget.order.pointB != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                Row(
                  children: [
                    const Icon(Icons.place_outlined, size: 26, color: CoreColors.primary),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        widget.order.pointA ?? '--',
                        style: const TextStyle(fontSize: 14, color: CoreColors.black, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 13.0),
                  child: CustomPaint(size: const Size(1, 15), painter: DashedLineVerticalPainter()),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.place_outlined, size: 26, color: CoreColors.primary),
                    const SizedBox(width: 5),
                    Flexible(
                        child: Text(
                      widget.order.pointB ?? '--',
                      softWrap: true,
                      style: const TextStyle(fontSize: 14, color: CoreColors.black, fontWeight: FontWeight.bold),
                    )),
                  ],
                ),
              ],
            ),
          if (widget.order.typeId == 2 && widget.order.cityA != null && widget.order.cityB != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                Text.rich(
                  TextSpan(
                    children: [
                      const WidgetSpan(
                        child: Padding(
                          padding: EdgeInsets.only(right: 10),
                          child: Icon(Icons.route, size: 16, color: CoreColors.primary),
                        ),
                      ),
                      TextSpan(
                        text: widget.order.cityA?.name ?? '--',
                        style: const TextStyle(fontSize: 14, color: CoreColors.black, fontWeight: FontWeight.bold),
                      ),
                      const WidgetSpan(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 5),
                          child: Icon(Icons.keyboard_double_arrow_right_sharp, size: 16, color: CoreColors.primary),
                        ),
                      ),
                      TextSpan(
                        text: widget.order.cityB?.name ?? '--',
                        style: const TextStyle(fontSize: 14, color: CoreColors.black, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          const Divider(height: 25),
          const SizedBox(height: 10),
          Row(
            children: [
              if (widget.order.userCost != null)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Стоимость'.tr,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                      Text(
                        "${widget.order.userCost} ₸",
                        style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w600, color: CoreColors.primary),
                      ),
                    ],
                  ),
                ),
              if (widget.order.userTime != null)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Запланированное время'.tr,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                      Text(
                        widget.order.userTime ?? '--',
                        style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w600, color: CoreColors.primary),
                      ),
                    ],
                  ),
                )
            ],
          ),
          if (widget.order.userComment != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                Text(
                  'Комментарий'.tr,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
                Text(
                  widget.order.userComment ?? '--',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
