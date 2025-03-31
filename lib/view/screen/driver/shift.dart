import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tulpar/controller/driver.dart';
import 'package:tulpar/controller/driver_shift.dart';
import 'package:tulpar/core/colors.dart';
import 'package:tulpar/core/decoration.dart';
import 'package:tulpar/core/icons.dart';
import 'package:tulpar/view/dialog/pay.dart';
import 'package:tulpar/view/widget/elevated_button.dart';

class DriverShiftScreen extends StatefulWidget {
  const DriverShiftScreen({super.key});

  @override
  State<DriverShiftScreen> createState() => _DriverShiftScreenState();
}

class _DriverShiftScreenState extends State<DriverShiftScreen> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Get.find<DriverShiftController>().fetchAvailableShifts();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    return DefaultTabController(
      length: 2,
      child: GetBuilder<DriverShiftController>(builder: (shiftController) {
        var availableShifts = shiftController.availableShifts.value;
        var availableShiftsLoading = shiftController.availableShiftsLoading.value;
        var selectedShift = shiftController.selectedShift.value;

        var orderShiftLoading = shiftController.orderShiftLoading.value;
        var shiftOrders = shiftController.shiftOrders.value;

        var shiftStatus = shiftController.shiftStatus.value;
        return Scaffold(
          appBar: AppBar(
            title: Text("Смены".tr),
            bottom: TabBar(tabs: [
              Tab(
                text: "Статус".tr,
              ),
              Tab(
                text: "История".tr,
              ),
            ]),
          ),
          body: TabBarView(
            children: [
              // Статус
              ListView(
                padding: const EdgeInsets.all(CoreDecoration.primaryPadding),
                children: [
                  shiftStatus?.isActive == true
                      ? Container(
                          padding: const EdgeInsets.all(CoreDecoration.primaryPadding),
                          decoration: BoxDecoration(
                            color: CoreColors.primary,
                            borderRadius: BorderRadius.circular(CoreDecoration.primaryBorderRadius),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Смена активна".tr,
                                      style: const TextStyle(
                                          fontSize: 18, color: CoreColors.white, fontWeight: FontWeight.w800),
                                    ),
                                    const SizedBox(height: 10),
                                    GetBuilder<DriverShiftController>(
                                        id: 'shift_timer',
                                        builder: (_) {
                                          return Text(
                                            "${shiftStatus?.left}",
                                            style: const TextStyle(
                                                fontSize: 18, color: CoreColors.white, fontWeight: FontWeight.w700),
                                          );
                                        }),
                                    const SizedBox(height: 10),
                                    Text(
                                      "Вы можете продлить смену до завершения времени действия".tr,
                                      style: const TextStyle(
                                          fontSize: 12, color: CoreColors.white, fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                TulparIcons.logo,
                                color: CoreColors.white,
                                size: 50,
                              ),
                            ],
                          ),
                        )
                      : Container(
                          padding: const EdgeInsets.all(CoreDecoration.primaryPadding),
                          decoration: BoxDecoration(
                            color: CoreColors.white,
                            borderRadius: BorderRadius.circular(CoreDecoration.primaryBorderRadius),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Нет активной смены".tr,
                                      style: const TextStyle(
                                          fontSize: 18, color: CoreColors.primary, fontWeight: FontWeight.w800),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      "Купите смену для работы с заказами".tr,
                                      style: const TextStyle(
                                          fontSize: 15, color: CoreColors.black, fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                TulparIcons.logo,
                                color: CoreColors.primary,
                                size: 50,
                              ),
                            ],
                          ),
                        ),
                  const SizedBox(height: 15),
                  Text(
                    "Приобрести смену".tr,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: CoreColors.white,
                      borderRadius: BorderRadius.circular(CoreDecoration.primaryBorderRadius),
                    ),
                    child: Ink(
                      child: Material(
                        color: Colors.transparent,
                        child: AnimatedSwitcher(
                          duration: Durations.short2,
                          transitionBuilder: (child, animation) => SizeTransition(
                              sizeFactor: animation,
                              axis: Axis.vertical,
                              child: FadeTransition(opacity: animation, child: child)),
                          child: availableShiftsLoading
                              ? Column(
                                  children: [
                                    SizedBox(width: w, height: 15),
                                    const Center(
                                        child: SizedBox(width: 25, height: 25, child: CircularProgressIndicator())),
                                    SizedBox(width: w, height: 15),
                                  ],
                                )
                              : (availableShifts?.shifts?.isEmpty ?? true)
                                  ? Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(width: w, height: 15),
                                        Text(
                                          "Смены не найдены".tr,
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                        TextButton(
                                            onPressed: () {
                                              shiftController.fetchAvailableShifts();
                                            },
                                            child: Text("Обновить".tr)),
                                        SizedBox(width: w, height: 15),
                                      ],
                                    )
                                  : Column(
                                      children: [
                                        GetBuilder<DriverController>(builder: (driverController) {
                                          var driver = driverController.profile.value;
                                          return ListTile(
                                            contentPadding: EdgeInsets.zero,
                                            title: Text(
                                              "${"Текущий баланс".tr}: ${driver?.balance} ₸",
                                              style: const TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                            subtitle: driver?.level == null
                                                ? null
                                                : Row(
                                                    children: [
                                                      Icon(Icons.star_rounded,
                                                          color: driver?.level?.colorValue ?? CoreColors.grey,
                                                          size: 20),
                                                      Text("${driver?.level?.name}"),
                                                    ],
                                                  ),
                                            trailing: TextButton(
                                                onPressed: () {
                                                  showModalBottomSheet(
                                                      context: context,
                                                      isScrollControlled: true,
                                                      builder: (context) => const PayDialog());
                                                },
                                                child: Text("Пополнить".tr)),
                                          );
                                        }),
                                        const Divider(),
                                        for (var shift in availableShifts!.shifts!)
                                          RadioListTile<int?>(
                                            title: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  shift.shiftName,
                                                  style: const TextStyle(fontSize: 16),
                                                ),
                                                Text(
                                                  "${shift.price} ₸",
                                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                            value: shift.id,
                                            groupValue: selectedShift?.id,
                                            onChanged: (v) {
                                              shiftController.selectedShift.value = shift;
                                              shiftController.update();
                                            },
                                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            contentPadding: EdgeInsets.zero,
                                          ),
                                        const Divider(),
                                        Row(
                                          children: [
                                            TextButton(
                                                onPressed: () {
                                                  Get.find<DriverController>().fetchProfile();
                                                  shiftController.fetchAvailableShifts();
                                                },
                                                child: Text("Обновить".tr)),
                                            const Spacer(),
                                            Expanded(
                                                child: PrimaryElevatedButton(
                                                    onPressed: selectedShift?.id == null
                                                        ? null
                                                        : () {
                                                            if (orderShiftLoading) return;
                                                            shiftController.orderShift();
                                                          },
                                                    loading: orderShiftLoading,
                                                    text: "Приобрести".tr)),
                                          ],
                                        ),
                                      ],
                                    ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
              // История
              RefreshIndicator(
                onRefresh: () async {
                  shiftController.fetchShiftOrders();
                },
                child: ListView.builder(
                  itemCount: shiftOrders.length,
                  itemBuilder: (context, index) {
                    var order = shiftOrders[index];
                    return ListTile(
                      title: Text(
                        order.title,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        order.formattedCreated,
                        style: const TextStyle(fontSize: 14),
                      ),
                      trailing: Text(
                        order.subtitle,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        );
      }),
    );
  }
}
