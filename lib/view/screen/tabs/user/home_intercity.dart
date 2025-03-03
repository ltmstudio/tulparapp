import 'dart:async';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:tulpar/controller/user_order.dart';
import 'package:tulpar/core/assets.dart';
import 'package:tulpar/core/colors.dart';
import 'package:tulpar/core/decoration.dart';
import 'package:tulpar/core/event.dart';
import 'package:tulpar/core/log.dart';
import 'package:tulpar/core/styles.dart';
import 'package:tulpar/core/toast.dart';
import 'package:tulpar/extension/string.dart';
import 'package:tulpar/model/app/city.dart';
import 'package:tulpar/model/order/order.dart';
import 'package:tulpar/view/dialog/datetime_picker.dart';
import 'package:tulpar/view/dialog/time_picker.dart';

class HomeIntercityTab extends StatefulWidget {
  const HomeIntercityTab({super.key});

  @override
  State<HomeIntercityTab> createState() => _HomeIntercityTabState();
}

class _HomeIntercityTabState extends State<HomeIntercityTab> {
  StreamSubscription<StreamWidgetEvent>? screenSubscrition;

  var timeController = TextEditingController();
  var peopleValue = ValueNotifier<int>(1);
  var commentsController = TextEditingController();
  var commentFieldExpanded = ValueNotifier<bool>(false);
  var priceController = TextEditingController();

  @override
  void initState() {
    var orderController = Get.find<UserOrderController>();
    screenSubscrition = orderController.widgetStream.listen((event) async {
      if (event.type == WidgetEvent.flushStartForm && mounted) {
        orderController.cityA.value = null;
        orderController.cityB.value = null;
        peopleValue.value = 1;
        priceController.clear();
        timeController.clear();
        commentsController.clear();
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserOrderController>(builder: (orderController) {
      var orderCreateLoading = orderController.orderCreateLoading.value;

      return Scaffold(
          body: Column(
        children: [
          Image.asset(CoreAssets.intercityMode),
          Expanded(
            child: ListView(children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Откуда'.tr, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownSearch<CityModel?>(
                        popupProps: PopupProps.menu(
                          menuProps: const MenuProps(
                            backgroundColor: CoreColors.white,
                          ),
                          showSearchBox: true, // Включаем поиск
                          searchFieldProps: TextFieldProps(
                            decoration: CoreDecoration.textField.copyWith(
                              hintText: "Введите город",
                            ),
                            style: CoreStyles.h4,
                          ),
                        ),

                        compareFn: (item1, item2) => item1?.id == item2?.id,
                        items: (_, __) => orderController.cities.value, // Список городов
                        selectedItem: orderController.cityA.value,
                        decoratorProps: DropDownDecoratorProps(
                            baseStyle: CoreStyles.h4,
                            decoration: CoreDecoration.textField.copyWith(
                              hintText: "Выберите город",
                            )),
                        itemAsString: (item) => item?.name ?? "",
                        onChanged: (CityModel? newValue) {
                          orderController.cityA.value = newValue;
                          orderController.update();
                        },
                      ),
                    ),
                    // Container(
                    //   decoration: BoxDecoration(
                    //       color: CoreColors.white,
                    //       borderRadius: BorderRadius.circular(CoreDecoration.primaryBorderRadius)),
                    //   child: Ink(
                    //     decoration:
                    //         BoxDecoration(borderRadius: BorderRadius.circular(CoreDecoration.primaryBorderRadius)),
                    //     child: Material(
                    //       borderRadius: BorderRadius.circular(CoreDecoration.primaryBorderRadius),
                    //       color: Colors.transparent,
                    //       child: DropdownButton<CityModel?>(
                    //         isExpanded: true,
                    //         value: orderController.cityA.value,
                    //         underline: const SizedBox(),
                    //         items: [
                    //           DropdownMenuItem<CityModel?>(
                    //             value: null,
                    //             child: Padding(
                    //               padding: const EdgeInsets.symmetric(horizontal: CoreDecoration.primaryPadding),
                    //               child: Text("Выберите город".tr, style: CoreStyles.hint),
                    //             ),
                    //           ),
                    //           for (var city in orderController.cities.value)
                    //             DropdownMenuItem<CityModel?>(
                    //               value: city,
                    //               child: Padding(
                    //                 padding: const EdgeInsets.symmetric(horizontal: CoreDecoration.primaryPadding),
                    //                 child: Text("${city.name}", style: CoreStyles.h4),
                    //               ),
                    //             )
                    //         ],
                    //         onChanged: (CityModel? newValue) {
                    //           orderController.cityA.value = newValue;
                    //           orderController.update();
                    //         },
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    const SizedBox(height: 15),
                    Text('Куда'.tr, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownSearch<CityModel?>(
                        popupProps: PopupProps.menu(
                          menuProps: const MenuProps(
                            backgroundColor: CoreColors.white,
                          ),
                          showSearchBox: true, // Включаем поиск
                          searchFieldProps: TextFieldProps(
                            decoration: CoreDecoration.textField.copyWith(
                              hintText: "Введите город",
                            ),
                            style: CoreStyles.h4,
                          ),
                        ),

                        compareFn: (item1, item2) => item1?.id == item2?.id,
                        items: (_, __) => orderController.cities.value, // Список городов
                        selectedItem: orderController.cityB.value,
                        decoratorProps: DropDownDecoratorProps(
                            baseStyle: CoreStyles.h4,
                            decoration: CoreDecoration.textField.copyWith(
                              hintText: "Выберите город",
                            )),
                        itemAsString: (item) => item?.name ?? "",
                        onChanged: (CityModel? newValue) {
                          orderController.cityB.value = newValue;
                          orderController.update();
                        },
                      ),
                    ),
                    // Container(
                    //   decoration: BoxDecoration(
                    //       color: CoreColors.white,
                    //       borderRadius: BorderRadius.circular(CoreDecoration.primaryBorderRadius)),
                    //   child: Ink(
                    //     child: Material(
                    //       color: Colors.transparent,
                    //       child: DropdownButton<CityModel?>(
                    //         isExpanded: true,
                    //         underline: const SizedBox(),
                    //         value: orderController.cityB.value,
                    //         items: [
                    //           DropdownMenuItem<CityModel?>(
                    //             value: null,
                    //             child: Padding(
                    //               padding: const EdgeInsets.symmetric(horizontal: CoreDecoration.primaryPadding),
                    //               child: Text("Выберите город".tr, style: CoreStyles.hint),
                    //             ),
                    //           ),
                    //           for (var city in orderController.cities.value)
                    //             DropdownMenuItem<CityModel?>(
                    //               value: city,
                    //               child: Padding(
                    //                 padding: const EdgeInsets.symmetric(horizontal: CoreDecoration.primaryPadding),
                    //                 child: Text("${city.name}", style: CoreStyles.h4),
                    //               ),
                    //             )
                    //         ],
                    //         onChanged: (CityModel? newValue) {
                    //           orderController.cityB.value = newValue;
                    //           orderController.update();
                    //         },
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: CoreDecoration.primaryPadding),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                              padding: const EdgeInsets.only(bottom: 10, top: 15),
                              child: Text('Стоимость'.tr,
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
                          TextField(
                            controller: priceController,
                            textAlign: TextAlign.end,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            decoration: CoreDecoration.textField.copyWith(
                                hintText: 'Укажите за сколько хотите доехать'.tr,
                                suffixIcon: const IconButton(
                                    onPressed: null,
                                    icon: Text(
                                      "₸",
                                      style: TextStyle(color: CoreColors.primary),
                                    ))),
                            onTapOutside: (event) {
                              FocusManager.instance.primaryFocus?.unfocus();
                            },
                          )
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                              padding: const EdgeInsets.only(bottom: 10, top: 15),
                              child: Text('Кол-во пассажиров'.tr,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
                          ValueListenableBuilder(
                              valueListenable: peopleValue,
                              builder: (_, p, __) {
                                return TextField(
                                    controller: TextEditingController(text: p.toString()),
                                    textAlign: TextAlign.center,
                                    keyboardType: TextInputType.number,
                                    readOnly: true,
                                    onTapOutside: (event) {
                                      FocusManager.instance.primaryFocus?.unfocus();
                                    },
                                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                    decoration: CoreDecoration.textField.copyWith(
                                      prefixIcon: IconButton(
                                          onPressed: () {
                                            if (peopleValue.value > 1) {
                                              peopleValue.value = peopleValue.value - 1;
                                            }
                                          },
                                          icon: const Icon(
                                            Icons.remove,
                                            color: CoreColors.primary,
                                            size: 16,
                                          )),
                                      suffixIcon: IconButton(
                                          onPressed: () {
                                            peopleValue.value = peopleValue.value + 1;
                                          },
                                          icon: const Icon(
                                            Icons.add,
                                            color: CoreColors.primary,
                                            size: 16,
                                          )),
                                    ));
                              })
                        ],
                      ),
                    ),
                    // const SizedBox(width: 10),

                    // Expanded(
                    //   flex: 2,
                    //   child: Column(
                    //     crossAxisAlignment: CrossAxisAlignment.start,
                    //     children: [

                    //     ],
                    //   ),
                    // ),
                  ],
                ),
              ),
              Padding(
                  padding: const EdgeInsets.only(bottom: 10, top: 15, left: CoreDecoration.primaryPadding),
                  child: Text('Время'.tr, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: CoreDecoration.primaryPadding),
                child: TextField(
                  controller: timeController,
                  readOnly: true,
                  onTap: () async {
                    DateTime? time = await showDialog(
                        context: context,
                        builder: (context) {
                          var now = DateTime.now().add(const Duration(minutes: 20));
                          var hour = now.hour;
                          var roundedMinute = (now.minute / 10).ceil() * 10;
                          var currentSelectedTime = timeController.text.toDateTime;
                          if (currentSelectedTime != null) {
                            return DateTimePickerDialog(
                              initialDateTime: currentSelectedTime,
                            );
                          }
                          return DateTimePickerDialog(
                            initialDateTime: DateTime(now.year, now.month, now.day, hour, roundedMinute),
                          );
                        });
                    if (time != null && mounted) {
                      timeController.text = DateFormat('dd-MM-yyyy HH:mm').format(time);
                      setState(() {});
                    }
                  },
                  onTapOutside: (event) {
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: CoreDecoration.textField.copyWith(
                      hintText: 'Как можно быстрее'.tr,
                      suffixIcon: timeController.text.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                timeController.clear();
                                setState(() {});
                              },
                              icon: const Icon(
                                Icons.close,
                                color: CoreColors.primary,
                                size: 16,
                              ))
                          : const IconButton(
                              onPressed: null,
                              icon: Icon(
                                Icons.access_time_rounded,
                                color: CoreColors.primary,
                                size: 16,
                              ))),
                ),
              ),
              ListTile(
                onTap: () {
                  commentFieldExpanded.value = !commentFieldExpanded.value;
                },
                title: Text("Комментарий".tr, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                trailing: TextButton(
                    onPressed: () {
                      commentFieldExpanded.value = !commentFieldExpanded.value;
                    },
                    child: Text("Добавить".tr, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
              ),
              ValueListenableBuilder(
                  valueListenable: commentFieldExpanded,
                  builder: (_, expanded, __) {
                    return AnimatedSwitcher(
                        duration: Durations.short2,
                        transitionBuilder: (child, animation) => SizeTransition(
                              sizeFactor: animation,
                              axis: Axis.vertical,
                              child: child,
                            ),
                        child: !expanded
                            ? const SizedBox()
                            : Container(
                                padding: const EdgeInsets.symmetric(horizontal: CoreDecoration.primaryPadding),
                                child: TextField(
                                  controller: commentsController,
                                  onTapOutside: (event) {
                                    FocusManager.instance.primaryFocus?.unfocus();
                                  },
                                  maxLines: 3,
                                  decoration: CoreDecoration.textField.copyWith(
                                    hintText: 'Введите заметку для водителя'.tr,
                                  ),
                                ),
                              ));
                  }),
              Padding(
                padding: const EdgeInsets.all(15).copyWith(bottom: 0),
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: CoreColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7),
                        )),
                    onPressed: () {
                      if (orderCreateLoading) return;
                      if (orderController.cityA.value == null ||
                          orderController.cityB.value == null ||
                          orderController.cityB.value == orderController.cityA.value ||
                          priceController.text.isEmpty) {
                        CoreToast.showToast('Заполните все поля'.tr);
                        return;
                      }
                      // собираем заказ
                      var newOrder = OrderModel(
                          cityAId: orderController.cityA.value!.id,
                          cityBId: orderController.cityB.value!.id,
                          userComment: commentsController.text.isEmpty ? null : commentsController.text,
                          userCost: int.tryParse(priceController.text),
                          userTime: timeController.text.isEmpty ? null : timeController.text,
                          people: peopleValue.value,
                          typeId: 2);

                      orderController.createOrder(newOrder);
                    },
                    child: Center(
                        child: orderCreateLoading
                            ? Lottie.asset(
                                CoreAssets.lottieLoading,
                                width: 20,
                                height: 20,
                              )
                            : Text(
                                'Заказать TULPAR'.tr,
                                style:
                                    const TextStyle(color: CoreColors.white, fontSize: 14, fontWeight: FontWeight.w500),
                              ))),
              ),
            ]),
          ),
        ],
      ));
    });
  }
}
