import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tulpar/controller/user_order.dart';
import 'package:tulpar/core/colors.dart';
import 'package:tulpar/core/toast.dart';
import 'package:tulpar/model/order/order.dart';
import 'package:tulpar/view/dialog/user_order_delete.dart';
import 'package:url_launcher/url_launcher.dart';

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
          // const SizedBox(height: 15),
          if (order.typeId == 1 && order.pointA != null && order.pointB != null)
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
                        order.pointA ?? '--',
                        style: const TextStyle(fontSize: 14, color: CoreColors.black),
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
                      order.pointB ?? '--',
                      softWrap: true,
                      style: const TextStyle(fontSize: 14, color: CoreColors.black),
                    )),
                  ],
                ),
              ],
            ),
          if (order.typeId != 1 && order.cityA != null && order.cityB != null)
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
                        text: order.cityA?.name ?? '--',
                        style: const TextStyle(fontSize: 14, color: CoreColors.black),
                      ),
                      const WidgetSpan(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 5),
                          child: Icon(Icons.keyboard_double_arrow_right_sharp, size: 16, color: CoreColors.primary),
                        ),
                      ),
                      TextSpan(
                        text: order.cityB?.name ?? '--',
                        style: const TextStyle(fontSize: 14, color: CoreColors.black),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          const Divider(),
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
            ],
          ),
          const Divider(),
          if (order.driverId != null && order.driver != null)
            Builder(builder: (_) {
              var profile = order.driver!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Данные водителя'.tr,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: CoreColors.lightGrey,
                          shape: BoxShape.circle,
                          border: Border.all(color: CoreColors.primary, width: 3),
                        ),
                        child: profile.avatar != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(40),
                                child: CachedNetworkImage(
                                  imageUrl: profile.avatarUrl,
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Icon(Icons.person, size: 20, color: CoreColors.white),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                          child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile.fullname,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          Row(children: [
                            if (profile.carName != null)
                              Text(
                                "${profile.carName}",
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            if (profile.carNumber != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                margin: const EdgeInsets.only(left: 5),
                                decoration: BoxDecoration(
                                    border: Border.all(color: CoreColors.black, width: 1),
                                    borderRadius: BorderRadius.circular(5)),
                                child: Text(
                                  "${profile.carNumber}",
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                ),
                              ),
                          ]),
                        ],
                      )),
                      if (profile.phone != null)
                        IconButton(
                            onPressed: () async {
                              final Uri url = Uri(
                                scheme: 'tel',
                                path: "+7${profile.phone!}",
                              );
                              if (await canLaunchUrl(url)) {
                                await launchUrl(url);
                              } else {
                                // copy to clipboard
                                Clipboard.setData(ClipboardData(text: "+7${profile.phone!}"));
                                CoreToast.showToast('Номер скопирован в буфер обмена'.tr);
                              }
                            },
                            icon: const Icon(Icons.call, size: 15),
                            color: CoreColors.primary)
                    ],
                  ),
                ],
              );
            })
          else
            Row(
              children: [
                TextButton.icon(
                    style: TextButton.styleFrom(foregroundColor: CoreColors.error),
                    onPressed: () async {
                      bool? delete = await showDialog(
                        context: context,
                        builder: (context) {
                          return const UserOrderDeleteConfirmDialog();
                        },
                      );
                      if (order.id != null && delete == true) {
                        Get.find<UserOrderController>().deleteOrder(order.id!);
                      }
                    },
                    icon: const Icon(Icons.close, size: 14),
                    label: Text('Отменить заказ'.tr))
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
