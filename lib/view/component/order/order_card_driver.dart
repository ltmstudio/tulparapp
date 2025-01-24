import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tulpar/controller/driver_order.dart';
import 'package:tulpar/core/colors.dart';
import 'package:tulpar/core/decoration.dart';
import 'package:tulpar/extension/string.dart';
import 'package:tulpar/model/order/order.dart';
import 'package:tulpar/view/dialog/driver_order_detatils.dart';

class DriverOrderCard extends StatelessWidget {
  final bool onHistoryPage;
  final bool blockOpen;
  final OrderModel order;
  const DriverOrderCard({super.key, required this.order, this.onHistoryPage = false, this.blockOpen = false});

  // final AppController themeSwitcher = Get.put(AppController(), permanent: true);
  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () {
        if (blockOpen) return;
        Get.find<DriverOrderController>().setSelectedOrder(order);
        if (order.geoA?.toLatLng != null && order.geoB?.toLatLng != null && !onHistoryPage) {
          showBottomSheet(context: context, builder: (context) => const DriverOrderDetailsDialog());
        } else {
          showModalBottomSheet(context: context, builder: (context) => const DriverOrderDetailsDialog());
        }
      },
      child: Container(
        width: w,
        decoration: BoxDecoration(
          color: CoreColors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: CoreColors.primary.withOpacity(0.08),
              offset: const Offset(0, 0),
              blurRadius: 4,
              spreadRadius: 2,
            )
          ],
        ),
        margin: const EdgeInsets.symmetric(horizontal: CoreDecoration.primaryPadding).copyWith(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  "${order.type ?? ""} ${order.id != null ? "#${order.id}" : ""}",
                  style: const TextStyle(fontSize: 16, color: CoreColors.primary, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (order.createdAt != null)
                  GetBuilder<DriverOrderController>(builder: (_) {
                    return Text(
                      " ${order.timeAgo ?? ""}",
                      style: TextStyle(fontSize: 12, color: CoreColors.black.withOpacity(0.6)),
                    );
                  }),
              ],
            ),
            Divider(),
            if (order.typeId == 1 && order.pointA != null && order.pointB != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.place_outlined, size: 26, color: CoreColors.primary),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          order.pointA ?? '--',
                          style: TextStyle(fontSize: 14, color: CoreColors.black, fontWeight: FontWeight.bold),
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
                      Icon(Icons.place_outlined, size: 26, color: CoreColors.primary),
                      const SizedBox(width: 5),
                      Flexible(
                          child: Text(
                        order.pointB ?? '--',
                        softWrap: true,
                        style: TextStyle(fontSize: 14, color: CoreColors.black, fontWeight: FontWeight.bold),
                      )),
                    ],
                  ),
                ],
              ),
            if (order.typeId == 2 && order.cityA != null && order.cityB != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                          text: order.cityA?.name ?? '--',
                          style: const TextStyle(fontSize: 14, color: CoreColors.black, fontWeight: FontWeight.bold),
                        ),
                        const WidgetSpan(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 5),
                            child: Icon(Icons.keyboard_double_arrow_right_sharp, size: 16, color: CoreColors.primary),
                          ),
                        ),
                        TextSpan(
                          text: order.cityB?.name ?? '--',
                          style: const TextStyle(fontSize: 14, color: CoreColors.black, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            Divider(),
            Row(
              children: [
                if (order.people != null)
                  Row(
                    children: [
                      const Icon(Icons.people, size: 16, color: CoreColors.primary),
                      const SizedBox(width: 5),
                      Text(
                        "${order.people}",
                        style: TextStyle(fontSize: 14, color: CoreColors.black),
                      ),
                    ],
                  ),
                const Spacer(),
                Text(
                  "+${order.userCost} ₸",
                  style: TextStyle(fontSize: 16, color: CoreColors.primary, fontWeight: FontWeight.bold),
                ),
              ],
            )
            // Text("${order.id}")
          ],
        ),
      ),
    );
  }
}

class DashedLineVerticalPainter extends CustomPainter {
  DashedLineVerticalPainter({this.color = CoreColors.primary});

  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    double dashHeight = 5, dashSpace = 3, startY = 0;
    final paint = Paint()
      ..color = color.withOpacity(0.6)
      ..strokeWidth = size.width;
    while (startY < size.height) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashHeight), paint);
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
