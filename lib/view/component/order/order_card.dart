import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tulpar/core/colors.dart';
import 'package:tulpar/model/order/order.dart';

class OrderCard extends StatelessWidget {
  final bool onHistoryPage;
  final OrderModel order;
  const OrderCard({super.key, required this.order, this.onHistoryPage = false});

  // final AppController themeSwitcher = Get.put(AppController(), permanent: true);
  @override
  Widget build(BuildContext context) {
    return Container(
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
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "№${order.id}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: CoreColors.primary,
                ),
              ),
              if (order.createdAt != null)
                Text(
                  "  от ${DateFormat('dd MMM HH:mm', 'ru').format(order.createdAt!.add(const Duration(hours: 5)))}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: CoreColors.grey,
                  ),
                ),
            ],
          ),
          Divider(),
          // const SizedBox(height: 15),
          Row(
            children: [
              Icon(Icons.place_outlined, size: 26, color: CoreColors.primary),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  order.pointA ?? '--',
                  style: TextStyle(fontSize: 14, color: CoreColors.black),
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
                style: TextStyle(fontSize: 14, color: CoreColors.black),
              )),
            ],
          ),
          Divider(),
          Row(
            children: [
              if (order.status != null)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Статус'.tr,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                      Text(
                        order.status?.tr ?? '--',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: CoreColors.primary),
                      ),
                    ],
                  ),
                ),
              // Expanded(
              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.end,
              //     children: [
              //       Text('status'.tr, style: TextStyle(fontSize: 12, color: CoreColors.grey)),
              //       Text('${order.status?.tr}',
              //           style: CoreStyles.mediumFrtn
              //               .copyWith(color: isDarkMode ? CoreColors.white : CoreColors.primary)),
              //     ],
              //   ),
              // )
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              if (order.typeId != null)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Тип'.tr,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                      Text(
                        order.type ?? order.typeId.toString(),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: CoreColors.primary),
                      ),
                    ],
                  ),
                ),
              // Expanded(
              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.end,
              //     children: [
              //       Text('status'.tr, style: TextStyle(fontSize: 12, color: CoreColors.grey)),
              //       Text('${order.status?.tr}',
              //           style: CoreStyles.mediumFrtn
              //               .copyWith(color: isDarkMode ? CoreColors.white : CoreColors.primary)),
              //     ],
              //   ),
              // )
            ],
          )
        ],
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
