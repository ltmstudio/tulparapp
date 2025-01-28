import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cache/flutter_map_cache.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:tulpar/controller/driver_order.dart';
import 'package:tulpar/controller/driver_shift.dart';
import 'package:tulpar/controller/location.dart';
import 'package:tulpar/controller/user_order.dart';
import 'package:tulpar/core/colors.dart';
import 'package:tulpar/core/decoration.dart';
import 'package:tulpar/core/icons.dart';
import 'package:tulpar/extension/string.dart';
import 'package:tulpar/model/order/order.dart';
import 'package:tulpar/view/component/order/order_card_driver.dart';
import 'package:tulpar/view/screen/driver/orders/cities.dart';
import 'package:tulpar/view/screen/driver/orders/filters.dart';
import 'package:tulpar/view/screen/driver/orders/sorting.dart';
import 'package:tulpar/view/screen/driver/shift.dart';

class DriverFeedTab extends StatefulWidget {
  const DriverFeedTab({super.key});

  @override
  State<DriverFeedTab> createState() => _DriverFeedTabState();
}

class _DriverFeedTabState extends State<DriverFeedTab> with TickerProviderStateMixin {
  // maps
  late LocationProvider locationProvider;
  final mapController = MapController();
  var mapControllerInitialized = ValueNotifier(false);
  final _dio = Dio();

  Worker? routeBuilderWorker;
  late var routeLoadingController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
  late var routeLoadingAnimation = CurvedAnimation(parent: routeLoadingController, curve: Curves.easeInOut);

  @override
  void initState() {
    routeBuilderWorker = ever(Get.find<DriverOrderController>().isRouteLoading, (l) {
      if (l) {
        routeLoadingController.repeat(reverse: true);
      } else {
        routeLoadingController.stop();
      }
    });
    locationProvider = LocationProvider();
    super.initState();
  }

  @override
  void dispose() {
    for (var entry in _animationControllers.entries) {
      var controller = entry.value;
      if (controller.isAnimating) {
        controller.stop();
      }
      controller.dispose();
    }
    _animationControllers.clear();
    locationProvider.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return GetBuilder<DriverOrderController>(builder: (orderController) {
      var orders = orderController.orders.value;
      var expandedOrders = orderController.expandedOrders.value;
      var ordersLoading = orderController.ordersLoading.value;

      var geoRoute = orderController.geoRoute.value;
      var selectedOrder = orderController.selectedOrderOnMap.value;
      if (selectedOrder != null) {
        var expanded = expandedOrders.firstWhereOrNull((element) => element.id == selectedOrder!.id);
        if (expanded != null) {
          selectedOrder = expanded;
        }
      }

      var selectedSortingValue = orderController.selectedSortingValue.value;
      var selectedOrderType = orderController.selectedOrderType.value;
      var selectedCityA = orderController.selectedCityA.value;
      var selectedCityB = orderController.selectedCityB.value;

      return Scaffold(
        appBar: AppBar(
          surfaceTintColor: Colors.transparent,
          leading: AnimatedSwitcher(
              duration: Durations.short2,
              transitionBuilder: (child, animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: selectedOrder != null
                  ? IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.arrow_back))
                  : ordersLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ))
                      : const Icon(TulparIcons.logo, color: CoreColors.primary)),
          title: Text('Лента заказов'.tr),
          actions: [
            GetBuilder<DriverShiftController>(builder: (driverShiftController) {
              var isActive = driverShiftController.shiftStatus.value?.isActive == true;
              return TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const DriverShiftScreen()),
                    );
                  },
                  child: Text.rich(TextSpan(children: [
                    TextSpan(
                      text: isActive ? 'СМЕНА АКТИВНА' : 'НАЧАТЬ СМЕНУ',
                      style: TextStyle(
                          color: isActive ? CoreColors.moderationApprovedStatus : CoreColors.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    ),
                    WidgetSpan(
                        child: Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        margin: EdgeInsets.all(4),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isActive ? CoreColors.moderationApprovedStatus : CoreColors.grey),
                      ),
                    )),
                  ])));
            })
          ],
        ),
        body: Column(
          children: [
            AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: selectedOrder != null &&
                        selectedOrder.geoA?.toLatLng != null &&
                        selectedOrder.geoB?.toLatLng != null
                    ? h * 0.4
                    : 0,
                color: Colors.red.withOpacity(0.5),
                child: SizedBox.expand(
                  child: Stack(
                    children: [
                      // map
                      SizedBox.expand(
                        child: ValueListenableBuilder(
                            valueListenable: locationProvider.currentPosition,
                            builder: (_, myPos, __) {
                              var o = orderController.selectedOrderOnMap.value;
                              if (o?.geoA?.toLatLng != null && o?.geoB?.toLatLng != null) {
                                var pointALatLng = o!.geoA!.toLatLng!;
                                var pointBLatLng = o.geoB!.toLatLng!;

                                var bounds = LatLngBounds.fromPoints([pointALatLng, pointBLatLng]);
                                Future.delayed(const Duration(milliseconds: 300), () {
                                  mapController.fitCamera(CameraFit.bounds(
                                      bounds: bounds, padding: const EdgeInsets.all(40).copyWith(bottom: 100)));
                                });
                              } else if (myPos != null) {
                                _animatedMapMove(myPos, mapController.camera.zoom);
                                // mapController.move(
                                //     myPos, mapController.camera.zoom);
                              }
                              // return AnimatedBuilder(
                              //     animation: routeLoadingAnimation,
                              //     builder: (context, _) {
                              return AnimatedBuilder(
                                  animation: routeLoadingAnimation,
                                  builder: (context, _) {
                                    return FlutterMap(
                                      mapController: mapController,
                                      options: MapOptions(
                                        initialCenter: const LatLng(43.29446, 76.94687),
                                        initialZoom: 12,
                                        onMapReady: () {
                                          mapControllerInitialized.value = true;
                                        },
                                        // onPositionChanged: (c, _) {
                                        //   if (!isLocSelector) return;
                                        //   selectlocDebouncer.call(() {
                                        //     Log.success('${c.center.latitude} ${c.center.longitude}');
                                        //     orderController.fetchGeocode(c.center);
                                        //   });
                                        // },
                                      ),
                                      children: [
                                        TileLayer(
                                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                          // '${CoreEnvironment.appSocketUrl}/maps/{z}/{x}/{y}',
                                          // 'http://95.85.126.166/tile/{z}/{x}/{y}.png',
                                          // 'https://map.tp-projects.com/tile/{z}/{x}/{y}.png',
                                          // 'https://tmuber.com.tm/maps-custom/{z}/{x}/{y}.png',
                                          tileProvider: CachedTileProvider(
                                              dio: _dio,
                                              store: HiveCacheStore(
                                                '${Get.find<UserOrderController>().cachePath.path}${Platform.pathSeparator}HiveCacheStore',
                                                hiveBoxName: 'HiveCacheStore',
                                              )),
                                        ),
                                        PolylineLayer(
                                          polylines: [
                                            if (geoRoute?.route?.geometry?.latLngList != null)
                                              Polyline(
                                                points: geoRoute!.route!.geometry!.latLngList!,
                                                strokeWidth: 4.0,
                                                borderStrokeWidth: 1,
                                                borderColor: Colors.white,
                                                color: CoreColors.primary,
                                              )
                                            else if (selectedOrder?.geoA?.toLatLng != null &&
                                                selectedOrder?.geoB?.toLatLng != null)
                                              Polyline(
                                                points: [selectedOrder!.geoA!.toLatLng!, selectedOrder.geoB!.toLatLng!],
                                                strokeWidth: 4.0,
                                                borderStrokeWidth: 1,
                                                colorsStop: [0.0, routeLoadingAnimation.value, 1.0],
                                                gradientColors: [
                                                  CoreColors.primary.withOpacity(0.5),
                                                  CoreColors.white,
                                                  CoreColors.primary.withOpacity(0.5),
                                                ],
                                                borderColor: Colors.white,
                                              )
                                          ],
                                        ),
                                        MarkerLayer(markers: [
                                          if (myPos != null)
                                            // Marker(
                                            //     rotate: true,
                                            //     point: myPos,
                                            //     height: 40,
                                            //     width: 40 * 0.7,
                                            //     alignment: Alignment.topCenter,
                                            //     child: const CustomMapMarker(
                                            //         size: 40,
                                            //         color: Colors.red,
                                            //         child: Text('ME',
                                            //             style:
                                            //                 CoreStyles.normalSxtn))),
                                            Marker(
                                                // rotate: true,
                                                point: LatLng(myPos.latitude, myPos.longitude),
                                                height: 40,
                                                width: 40 * 0.7,
                                                alignment: Alignment.center,
                                                child: Container(
                                                  decoration: const BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: CoreColors.white,
                                                  ),
                                                  child: myPos.heading != 0.0
                                                      ? Transform.rotate(
                                                          angle: myPos.heading * (pi / 180),
                                                          child: const Icon(
                                                            Icons.navigation_rounded,
                                                            color: Colors.blue,
                                                          ),
                                                        )
                                                      : const Icon(
                                                          Icons.person,
                                                          color: CoreColors.primary,
                                                        ),
                                                )),
                                          if (selectedOrder?.geoA?.toLatLng != null)
                                            Marker(
                                              point: selectedOrder!.geoA!.toLatLng!,
                                              height: 30,
                                              width: 30,
                                              alignment: Alignment.center,
                                              child: Container(
                                                decoration: const BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: CoreColors.white,
                                                  border: Border.fromBorderSide(BorderSide(color: CoreColors.primary)),
                                                ),
                                                child: const Center(
                                                  child: Text("A",
                                                      textAlign: TextAlign.center,
                                                      style: const TextStyle(
                                                          height: 1,
                                                          color: CoreColors.primary,
                                                          fontSize: 18,
                                                          fontWeight: FontWeight.w700)),
                                                ),
                                              ),
                                            ),
                                          if (selectedOrder?.geoB?.toLatLng != null)
                                            Marker(
                                              point: selectedOrder!.geoB!.toLatLng!,
                                              height: 30,
                                              width: 30,
                                              alignment: Alignment.center,
                                              child: Container(
                                                height: 30,
                                                width: 30,
                                                decoration: const BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: CoreColors.white,
                                                  border: Border.fromBorderSide(BorderSide(color: CoreColors.primary)),
                                                ),
                                                child: const Center(
                                                  child: Text("Б",
                                                      textAlign: TextAlign.center,
                                                      style: const TextStyle(
                                                          height: 1,
                                                          color: CoreColors.primary,
                                                          fontSize: 18,
                                                          fontWeight: FontWeight.w700)),
                                                ),
                                              ),
                                            ),

                                          // if (fakePos != null)
                                          //   Marker(
                                          //       rotate: true,
                                          //       point: LatLng(fakePos.latitude,
                                          //           fakePos.longitude),
                                          //       height: 40,
                                          //       width: 40 * 0.7,
                                          //       alignment: Alignment.topCenter,
                                          //       child: const CustomMapMarker(
                                          //           size: 40,
                                          //           color: Colors.red,
                                          //           child: Text('FK',
                                          //               style: CoreStyles.normalSxtn))),
                                        ]),
                                      ],
                                    );
                                  });
                              // });
                            }),
                      ),
                      // distance - time
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: AnimatedSwitcher(
                          duration: Durations.short4,
                          transitionBuilder: (child, animation) => SizeTransition(
                            sizeFactor: animation,
                            axis: Axis.vertical,
                            child: child,
                          ),
                          child: geoRoute?.route?.distance == null ||
                                  geoRoute?.route?.duration == null ||
                                  selectedOrder == null
                              ? const SizedBox()
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 50),
                                      padding: const EdgeInsets.symmetric(horizontal: 15),
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: CoreColors.white,
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.route_outlined,
                                            color: CoreColors.primary,
                                            size: 18,
                                          ),
                                          Text(
                                            ' ${geoRoute?.route?.distanceInKilometers ?? ''} км',
                                            style: const TextStyle(fontSize: 14),
                                          ),
                                          const SizedBox(width: 10),
                                          const Icon(
                                            Icons.access_time_rounded,
                                            color: CoreColors.primary,
                                            size: 18,
                                          ),
                                          Text(
                                            ' ${geoRoute?.route?.durationInMinutes ?? ''} мин',
                                            style: const TextStyle(fontSize: 14),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      )
                    ],
                  ),
                )),
            Expanded(
              child: Column(
                children: [
                  Container(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: Row(
                              children: [
                                const SizedBox(width: 10),
                                const Icon(Icons.sort, color: CoreColors.primary),
                                const SizedBox(width: 6),
                                Text(
                                  selectedSortingValue?.name ?? 'Сортировка',
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const SizedBox(width: 15),
                              ],
                            ),
                            onPressed: () async {
                              bool? changed = await showModalBottomSheet(
                                  context: context,
                                  shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(CoreDecoration.primaryBorderRadius))),
                                  backgroundColor: CoreColors.white,
                                  builder: (_) => const OrdersSortingDialog());
                              if (changed ?? false) {
                                orderController.fetchOrdersFeed(resetAll: true);
                              }
                            },
                          ),
                          IconButton(
                            icon: Row(
                              children: [
                                SizedBox(width: 10),
                                Icon(Icons.filter_alt_outlined, color: CoreColors.primary),
                                SizedBox(width: 6),
                                Text(
                                  selectedOrderType?.name ?? 'Фильтрация',
                                  style: TextStyle(fontSize: 14),
                                ),
                                SizedBox(width: 15),
                              ],
                            ),
                            onPressed: () async {
                              bool? changed = await showModalBottomSheet(
                                  context: context,
                                  shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(CoreDecoration.primaryBorderRadius))),
                                  backgroundColor: CoreColors.white,
                                  builder: (_) => const OrdersFiltersDialog());
                              if (changed ?? false) {
                                orderController.fetchOrdersFeed(resetAll: true);
                              }
                            },
                          ),
                        ],
                      )),
                  AnimatedSwitcher(
                    duration: Durations.short2,
                    transitionBuilder: (child, animation) => SizeTransition(
                      sizeFactor: animation,
                      axis: Axis.vertical,
                      child: child,
                    ),
                    child: selectedOrderType == null || selectedOrderType.id == 1
                        ? const SizedBox()
                        : Container(
                            padding: const EdgeInsets.symmetric(horizontal: CoreDecoration.primaryPadding),
                            margin: const EdgeInsets.only(bottom: 5),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Text(
                                        "Город А:  ",
                                        style: TextStyle(fontSize: 15),
                                      ),
                                      Text(
                                        selectedCityA?.name ?? "Все",
                                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                      )
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 5),
                                  child: Icon(Icons.keyboard_double_arrow_right_sharp,
                                      size: 16, color: CoreColors.primary),
                                ),
                                Expanded(
                                  child: Row(
                                    children: [
                                      Text(
                                        "Город Б:  ",
                                        style: TextStyle(fontSize: 15),
                                      ),
                                      Text(
                                        selectedCityB?.name ?? "Все",
                                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                      )
                                    ],
                                  ),
                                ),
                                SizedBox(
                                    height: 35,
                                    child: TextButton(
                                        onPressed: () async {
                                          bool? changed = await showModalBottomSheet(
                                              context: context, builder: (context) => OrdersCitiesFiltersDialog());
                                          if (changed ?? false) {
                                            orderController.fetchOrdersFeed(resetAll: true);
                                          }
                                        },
                                        style: TextButton.styleFrom(padding: EdgeInsets.all(5)),
                                        child: Text("Выбрать")))
                              ],
                            ),
                          ),
                  ),
                  Divider(),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        await orderController.fetchOrdersFeed();
                      },
                      child: AnimatedList(
                        key: orderController.listKey,
                        initialItemCount: orders.length,
                        itemBuilder: (context, index, animation) {
                          final order = orders[index];
                          return _buildOrderItem(order, animation);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildOrderItem(OrderModel order, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: animation,
      child: FadeTransition(
          opacity: animation,
          // SlideTransition(
          // position: animation.drive(
          //   Tween<Offset>(
          //     begin: const Offset(1, 0),
          //     end: Offset.zero,
          //   ),
          // ),
          child: DriverOrderCard(order: order)),
    );
  }

  final Map<String, AnimationController> _animationControllers = {};
  static const _startedId = 'AnimatedMapController#MoveStarted';
  static const _inProgressId = 'AnimatedMapController#MoveInProgress';
  static const _finishedId = 'AnimatedMapController#MoveFinished';

  void _animatedMapMove(Position destLocation, double destZoom) {
    final camera = mapController.camera;
    final latTween = Tween<double>(begin: camera.center.latitude, end: destLocation.latitude);
    final lngTween = Tween<double>(begin: camera.center.longitude, end: destLocation.longitude);
    final zoomTween = Tween<double>(begin: camera.zoom, end: destZoom);

    double? targetRotation;
    bool isToRotateCamera = true;

    if (destLocation.heading != 0.0) {
      // Если heading задан, используем его
      isToRotateCamera = false;
      targetRotation = -destLocation.heading;
    } else {
      // Вычисляем угол между текущей позицией камеры и новой позицией
      final dx = destLocation.longitude - camera.center.longitude;
      final dy = destLocation.latitude - camera.center.latitude;
      targetRotation = atan2(dy, dx) * 180 / pi;
    }

    // Здесь мы корректируем поворот так, чтобы он был кратчайшим
    double rotationDiff = targetRotation - camera.rotation;
    if (rotationDiff > 180) {
      rotationDiff -= 360;
    } else if (rotationDiff < -180) {
      rotationDiff += 360;
    }
    targetRotation = camera.rotation + rotationDiff;
    final rotateTween = Tween<double>(begin: camera.rotation, end: targetRotation);

    final startIdWithTarget = '$_startedId#${destLocation.latitude},${destLocation.longitude},$destZoom';
    final newController = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    _animationControllers[startIdWithTarget] = newController;
    var controller = _animationControllers[startIdWithTarget]!;

    final Animation<double> animation = CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);
    _animationControllers[startIdWithTarget] = controller;
    bool hasTriggeredMove = false;

    controller.addListener(() {
      final String id;
      if (animation.value == 1.0) {
        id = _finishedId;
      } else if (!hasTriggeredMove) {
        id = startIdWithTarget;
      } else {
        id = _inProgressId;
      }

      // Move the map
      hasTriggeredMove |= mapController.move(
        LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
        zoomTween.evaluate(animation),
        id: id,
      );

      // if (isToRotateCamera) {
      //   mapController.rotate(rotateTween.evaluate(animation));
      // }
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed || status == AnimationStatus.dismissed) {
        controller.dispose();
        _animationControllers.remove(startIdWithTarget);
      }
    });

    controller.forward();
  }

  Future<void> disposeAnimators() async {
    for (var entry in _animationControllers.entries) {
      var controller = entry.value;
      if (controller.isAnimating) {
        controller.stop();
      }
      controller.dispose();
    }
    _animationControllers.clear();

    locationProvider.close();
  }
}
