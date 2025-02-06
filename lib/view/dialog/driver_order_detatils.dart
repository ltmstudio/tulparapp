import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tulpar/controller/driver.dart';
import 'package:tulpar/controller/driver_order.dart';
import 'package:tulpar/controller/route_launcher.dart';
import 'package:tulpar/core/colors.dart';
import 'package:tulpar/core/decoration.dart';
import 'package:tulpar/core/log.dart';
import 'package:tulpar/core/toast.dart';
import 'package:tulpar/extension/string.dart';
import 'package:tulpar/view/component/order/order_card.dart';
import 'package:tulpar/view/dialog/driver_order_reject.dart';
import 'package:tulpar/view/widget/elevated_button.dart';
import 'package:url_launcher/url_launcher.dart';

class DriverOrderDetailsDialog extends StatefulWidget {
  const DriverOrderDetailsDialog({
    super.key,
  });

  @override
  State<DriverOrderDetailsDialog> createState() => _DriverOrderDetailsDialogState();
}

class _DriverOrderDetailsDialogState extends State<DriverOrderDetailsDialog> {
  @override
  void dispose() {
    Get.find<DriverOrderController>().removeSelectedOrder();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;

    return GetBuilder<DriverOrderController>(builder: (orderController) {
      var order = orderController.selectedOrderOnMap.value;
      var expandedOrders = orderController.expandedOrders.value;
      var expandedOrderLoading = orderController.expandedOrderLoading.value;
      var isOrderExpanded = false;
      if (order != null) {
        var expanded = expandedOrders.firstWhereOrNull((element) => element.id == order!.id);
        if (expanded != null) {
          if (expanded.phone != null) {
            isOrderExpanded = true;
          }
          order = expanded;
        }
      }
      return Container(
        height: h * 0.5,
        padding: const EdgeInsets.all(CoreDecoration.primaryPadding),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Заказ №${order?.id}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: CoreColors.black),
                ),
                if (order?.createdAt != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 15),
                    child: Text(
                      DateFormat('dd.MM.yyyy в HH:mm').format(order!.createdAt!),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: CoreColors.grey),
                    ),
                  ),
              ],
            ),
            const Divider(height: 25),
            Expanded(
                child: ListView(children: [
              Row(
                children: [
                  if (order?.typeId != null)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Тип'.tr,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                          ),
                          Text(
                            order?.type ?? order?.typeId.toString() ?? '--',
                            style:
                                const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: CoreColors.primary),
                          ),
                        ],
                      ),
                    ),
                  if (order?.carClass != null)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Класс поездки'.tr,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                          ),
                          Text(
                            order?.carClass?.name ?? order?.classId.toString() ?? '--',
                            style:
                                const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: CoreColors.primary),
                          ),
                        ],
                      ),
                    ),
                  if (order?.people != null)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Кол-во пассажиров'.tr,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                          ),
                          Text(
                            "${order?.people}",
                            style:
                                const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: CoreColors.primary),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              if (order?.typeId == 1 && order?.pointA != null && order?.pointB != null)
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
                            order?.pointA ?? '--',
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
                          order?.pointB ?? '--',
                          softWrap: true,
                          style: const TextStyle(fontSize: 14, color: CoreColors.black, fontWeight: FontWeight.bold),
                        )),
                      ],
                    ),
                    if (order?.geoA?.toLatLng != null && order?.geoB?.toLatLng != null)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                            onPressed: () {
                              try {
                                Get.find<RouteLauncher>().open2GIS(
                                    // orderController.open2GIS(
                                    order!.geoA!.toLatLng!.latitude,
                                    order.geoA!.toLatLng!.longitude,
                                    order.geoB!.toLatLng!.latitude,
                                    order.geoB!.toLatLng!.longitude);
                              } on Exception catch (e) {
                                Log.error("Не удалось открыть маршрут");
                              }
                            },
                            child: const Text("Открыть маршрут")),
                      )
                  ],
                ),
              if (order?.typeId == 2 && order?.cityA != null && order?.cityB != null)
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
                            text: order?.cityA?.name ?? '--',
                            style: const TextStyle(fontSize: 14, color: CoreColors.black, fontWeight: FontWeight.bold),
                          ),
                          const WidgetSpan(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 5),
                              child: Icon(Icons.keyboard_double_arrow_right_sharp, size: 16, color: CoreColors.primary),
                            ),
                          ),
                          TextSpan(
                            text: order?.cityB?.name ?? '--',
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
                  if (order?.userCost != null)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Стоимость'.tr,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                          ),
                          Text(
                            "${order?.userCost} ₸",
                            style:
                                const TextStyle(fontSize: 25, fontWeight: FontWeight.w600, color: CoreColors.primary),
                          ),
                        ],
                      ),
                    ),
                  if (order?.userTime != null)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Запланированное время'.tr,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                          ),
                          Text(
                            order?.userTime ?? '--',
                            style:
                                const TextStyle(fontSize: 25, fontWeight: FontWeight.w600, color: CoreColors.primary),
                          ),
                        ],
                      ),
                    )
                ],
              ),
              if (order?.userComment != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(),
                    Text(
                      'Комментарий'.tr,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                    Text(
                      order?.userComment ?? '--',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              if (order?.phone != null)
                ListTile(
                    contentPadding: const EdgeInsets.all(0),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                            onPressed: () async {
                              await Clipboard.setData(ClipboardData(text: "+7${order?.phone}"));
                              if (mounted) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(content: Text('Номер скопирован'.tr)));
                              }
                            },
                            icon: const Icon(Icons.copy, color: CoreColors.primary)),
                        IconButton(
                            onPressed: () async {
                              final Uri url = Uri(
                                scheme: 'tel',
                                path: "+7${order!.phone!}",
                              );
                              if (await canLaunchUrl(url)) {
                                await launchUrl(url);
                              } else {
                                CoreToast.showToast("Ошибка при попытке позвонить".tr);
                              }
                            },
                            icon: const Icon(Icons.phone, color: CoreColors.primary)),
                      ],
                    ),
                    title: Text(
                      "+7 ${order?.phone}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('Телефон клиента'.tr)),
            ])),
            Row(
              children: [
                Expanded(
                    flex: 4,
                    child: PrimaryElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        light: true,
                        text: "Закрыть".tr)),
                if (order?.status == 'new') const SizedBox(width: 10),
                if (order?.status == 'new')
                  GetBuilder<DriverController>(builder: (driverController) {
                    var driver = driverController.profile.value;
                    // return Text("driver: ${driver?.id}, order: ${order?.driverId}");
                    if (order?.phone != null && order?.driverId != null && order?.driverId == driver?.id) {
                      return Expanded(
                          flex: 6,
                          child: Row(
                            children: [
                              Expanded(
                                flex: 4,
                                child: PrimaryElevatedButton(
                                    loading: expandedOrderLoading,
                                    onPressed: () async {
                                      if (order?.id != null) {
                                        String? alertMessage = await orderController.closeOrderRequest(order!.id!);
                                        if (alertMessage != null && mounted) {
                                          showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(content: Text(alertMessage)));
                                        } else if (mounted) {
                                          Navigator.of(context).pop();
                                        }
                                      }
                                    },
                                    shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.horizontal(
                                            left: Radius.circular(CoreDecoration.primaryBorderRadius))),
                                    text: 'Выполнено'.tr),
                              ),
                              // const SizedBox(width: 2),
                              // Expanded(
                              //   child: PrimaryElevatedButton(
                              //       loading: expandedOrderLoading,
                              //       onPressed: () async {},
                              //       shape: const RoundedRectangleBorder(
                              //           borderRadius: BorderRadius.horizontal(
                              //               right: Radius.circular(CoreDecoration.primaryBorderRadius))),
                              //       icon: Icons.keyboard_arrow_down_rounded,
                              //       text: ''.tr),
                              // ),
                              PopupMenuButton(
                                  style: ElevatedButton.styleFrom(
                                      shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.horizontal(
                                              right: Radius.circular(CoreDecoration.primaryBorderRadius))),
                                      padding: const EdgeInsets.symmetric(vertical: 11),
                                      backgroundColor: CoreColors.primary,
                                      elevation: 0),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  iconColor: CoreColors.white,
                                  position: PopupMenuPosition.under,
                                  itemBuilder: (context) {
                                    return [
                                      PopupMenuItem(
                                          value: 'edit',
                                          child: Row(
                                            children: [
                                              const Icon(Icons.close, size: 14, color: CoreColors.error),
                                              const SizedBox(width: 5),
                                              Text('Отказаться'.tr, style: const TextStyle(color: CoreColors.error)),
                                            ],
                                          )),
                                    ];
                                  },
                                  onSelected: (value) async {
                                    bool? confirmed = await showDialog(
                                        context: context, builder: (context) => const DriverOrderRejectConfirmDialog());
                                    if (confirmed == true) {
                                      if (order?.id != null) {
                                        String? alertMessage = await orderController.cancelOrderRequest(order!.id!);
                                        if (alertMessage != null && mounted) {
                                          showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(content: Text(alertMessage)));
                                        } else if (mounted) {
                                          Navigator.of(context).pop();
                                        }
                                      }
                                    }
                                  }),
                            ],
                          ));
                    } else {
                      if (!isOrderExpanded) {
                        return Expanded(
                            flex: 6,
                            child: PrimaryElevatedButton(
                                loading: expandedOrderLoading,
                                onPressed: () async {
                                  if (order?.id != null) {
                                    String? alertMessage = await orderController.fetchOrderDetails(order!.id!);
                                    if (alertMessage != null && mounted) {
                                      showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(content: Text(alertMessage)));
                                    }
                                  }
                                },
                                text: 'Получить контакты'.tr));
                      } else {
                        return Expanded(
                            flex: 6,
                            child: PrimaryElevatedButton(
                                loading: expandedOrderLoading,
                                onPressed: () async {
                                  if (order?.id != null) {
                                    String? alertMessage = await orderController.takeOrderRequest(order!.id!);
                                    if (alertMessage != null && mounted) {
                                      showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(content: Text(alertMessage)));
                                    }
                                  }
                                },
                                text: 'Взять заказ'.tr));
                      }
                    }
                  }),
              ],
            ),
          ],
        ),
      );
    });
  }
}
