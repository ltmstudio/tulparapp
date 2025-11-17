import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:bounce/bounce.dart';
import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cache/flutter_map_cache.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_workers/utils/debouncer.dart';
import 'package:latlong2/latlong.dart';
import 'package:lottie/lottie.dart' hide Marker;
import 'package:tulpar/controller/address.dart';
import 'package:tulpar/controller/location.dart';
import 'package:tulpar/controller/user_order.dart';
import 'package:tulpar/core/assets.dart';
import 'package:tulpar/core/colors.dart';
import 'package:tulpar/core/decoration.dart';
import 'package:tulpar/core/event.dart';
import 'package:tulpar/core/log.dart';
import 'package:tulpar/core/styles.dart';
import 'package:tulpar/core/toast.dart';
import 'package:tulpar/extension/string.dart';
import 'package:tulpar/model/order/car_class.dart';
import 'package:tulpar/model/order/order.dart';
import 'package:tulpar/model/user/address.dart';
import 'package:tulpar/view/component/order/order_type_card.dart';
import 'package:tulpar/view/dialog/address_select.dart';
import 'package:tulpar/view/dialog/time_picker.dart';
import 'package:tulpar/view/screen/tabs/user/home_cargo.dart';
import 'package:tulpar/view/screen/tabs/user/home_intercity.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with TickerProviderStateMixin {
  late TabController _tabController;
  var selectedIndex = ValueNotifier<int>(0);
  StreamSubscription<StreamWidgetEvent>? screenSubscrition;
  // maps
  late LocationProvider locationProvider;
  final mapController = MapController();
  var mapControllerInitialized = ValueNotifier(false);
  final _dio = Dio();
  var selectlocDebouncer = Debouncer(delay: const Duration(milliseconds: 1000));

  var pointAController = TextEditingController();
  var pointBController = TextEditingController();
  var timeController = TextEditingController();
  var peopleValue = ValueNotifier<int>(1);
  var commentsController = TextEditingController();
  var commentFieldExpanded = ValueNotifier<bool>(false);
  var priceController = TextEditingController();
  var isDelivery = ValueNotifier<bool>(false);
  var isCargo = ValueNotifier<bool>(false);

  Worker? routeBuilderWorker;
  late var routeLoadingController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
  late var routeLoadingAnimation = CurvedAnimation(parent: routeLoadingController, curve: Curves.easeInOut);

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    locationProvider = LocationProvider();
    var orderController = Get.find<UserOrderController>();
    screenSubscrition = orderController.widgetStream.listen((event) async {
      if (event.type == WidgetEvent.flushStartForm && mounted) {
        pointAController.clear();
        pointBController.clear();
        peopleValue.value = 1;
        priceController.clear();
        timeController.clear();
        commentsController.clear();
        isDelivery.value = false;
        isCargo.value = false;
      }
    });
    routeBuilderWorker = ever(Get.find<UserOrderController>().isRouteLoading, (l) {
      if (l) {
        routeLoadingController.repeat(reverse: true);
      } else {
        routeLoadingController.stop();
      }
    });
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
    routeBuilderWorker?.dispose();
    routeLoadingController.stop();
    routeLoadingController.dispose();
    locationProvider.close();
    screenSubscrition?.cancel();
    screenSubscrition = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    var appBar = AppBar(title: Text("Новый заказ".tr));
    var tabBar = TabBar(
        controller: _tabController,
        onTap: (value) => selectedIndex.value = value,
        tabs: [Tab(text: "Город".tr), Tab(text: "Межгород".tr), Tab(text: "Грузоперевозки межгород".tr)]);
    return GetBuilder<UserOrderController>(builder: (orderController) {
      // map
      var followLocation = orderController.followLocation.value;
      var isLocSelector = orderController.locSelector.value;
      var locSelectorTitle = orderController.locSelectorTitle.value;

      var currentGeocode = orderController.currentGeocode.value;
      var currentGeocodePosition = orderController.currentGeocodePosition.value;
      var isGeocodeLoading = orderController.isGeocodeLoading.value;
      var onGeocodeDone = orderController.onGeocodeDone.value;

      var carClasses = orderController.carClasses.value;
      var selectedCarClassId = orderController.selectedCarClassId.value;
      var pointA = orderController.poinA.value;
      var pointB = orderController.pointB.value;
      var geoRoute = orderController.geoRoute.value;

      var orderCreateLoading = orderController.orderCreateLoading.value;

      return Scaffold(
        appBar: appBar,
        body: SizedBox(
          width: w,
          height: h,
          child: Column(
            children: [
              ValueListenableBuilder(
                  valueListenable: selectedIndex,
                  builder: (_, index, __) {
                    return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: isLocSelector && index == 0
                            ? h / 1.3
                            : index == 0
                                ? h / 3
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
                                      if (pointA?.geo != null && pointB?.geo != null && index == 0) {
                                        var pointALatLng = LatLng(
                                          double.parse(pointA!.geo!.split(',')[0]),
                                          double.parse(pointA.geo!.split(',')[1]),
                                        );
                                        var pointBLatLng = LatLng(
                                          double.parse(pointB!.geo!.split(',')[0]),
                                          double.parse(pointB.geo!.split(',')[1]),
                                        );

                                        var bounds = LatLngBounds.fromPoints([pointALatLng, pointBLatLng]);
                                        Future.delayed(const Duration(milliseconds: 300), () {
                                          if (pointA.geo != null &&
                                              pointB.geo != null &&
                                              index == 0 &&
                                              !isLocSelector) {
                                            mapController.fitCamera(
                                                CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(50)));
                                          }
                                        });
                                      } else if (myPos != null && followLocation && !isLocSelector) {
                                        _animatedMapMove(myPos, mapController.camera.zoom);
                                        // mapController.move(
                                        //     myPos, mapController.camera.zoom);
                                      }
                                      return AnimatedBuilder(
                                          animation: routeLoadingAnimation,
                                          builder: (context, _) {
                                            return FlutterMap(
                                              mapController: mapController,
                                              options: MapOptions(
                                                initialCenter: const LatLng(43.29446, 76.94687),
                                                initialZoom: 15,
                                                onMapReady: () {
                                                  mapControllerInitialized.value = true;
                                                },
                                                onPointerDown: (_, __) {
                                                  Log.warning('msg');
                                                },
                                                onPositionChanged: (c, _) {
                                                  if (!isLocSelector) return;
                                                  selectlocDebouncer.call(() {
                                                    Log.success('${c.center.latitude} ${c.center.longitude}');
                                                    orderController.fetchGeocode(c.center);
                                                  });
                                                },
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
                                                        '${orderController.cachePath.path}${Platform.pathSeparator}HiveCacheStore',
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
                                                    else if (pointA?.latLng != null && pointB?.latLng != null)
                                                      Polyline(
                                                        points: [pointA!.latLng!, pointB!.latLng!],
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
                                                        rotate: true,
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
                                                  if (pointA?.latLng != null)
                                                    Marker(
                                                      rotate: true,
                                                      point: pointA!.latLng!,
                                                      height: 30,
                                                      width: 30,
                                                      alignment: Alignment.center,
                                                      child: Container(
                                                        decoration: const BoxDecoration(
                                                          shape: BoxShape.circle,
                                                          color: CoreColors.white,
                                                          border: Border.fromBorderSide(
                                                              BorderSide(color: CoreColors.primary)),
                                                        ),
                                                        child: const Center(
                                                          child: Text("A",
                                                              textAlign: TextAlign.center,
                                                              style: TextStyle(
                                                                  height: 1,
                                                                  color: CoreColors.primary,
                                                                  fontSize: 18,
                                                                  fontWeight: FontWeight.w700)),
                                                        ),
                                                      ),
                                                    ),
                                                  if (pointB?.latLng != null)
                                                    Marker(
                                                      rotate: true,
                                                      point: pointB!.latLng!,
                                                      height: 30,
                                                      width: 30,
                                                      alignment: Alignment.center,
                                                      child: Container(
                                                        height: 30,
                                                        width: 30,
                                                        decoration: const BoxDecoration(
                                                          shape: BoxShape.circle,
                                                          color: CoreColors.white,
                                                          border: Border.fromBorderSide(
                                                              BorderSide(color: CoreColors.primary)),
                                                        ),
                                                        child: const Center(
                                                          child: Text("Б",
                                                              textAlign: TextAlign.center,
                                                              style: TextStyle(
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
                                    }),
                              ),
                              if (isLocSelector) const SizedBox.expand(child: Center(child: SelectorMarkerWidget())),
                              // loc selector
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: AnimatedSwitcher(
                                  duration: Durations.short4,
                                  transitionBuilder: (child, animation) => SizeTransition(
                                    sizeFactor: animation,
                                    axis: Axis.vertical,
                                    child: child,
                                  ),
                                  child: isLocSelector
                                      ? Container(
                                          width: w,
                                          padding: const EdgeInsets.all(15),
                                          color: CoreColors.white,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              if (locSelectorTitle != null)
                                                Text(locSelectorTitle,
                                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                                              if (isGeocodeLoading)
                                                const Column(
                                                  children: [
                                                    SizedBox(height: 10),
                                                    LinearProgressIndicator(color: CoreColors.primary),
                                                  ],
                                                ),
                                              const SizedBox(height: 10),
                                              Text(
                                                currentGeocode ?? '',
                                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                                                textAlign: TextAlign.center,
                                              ),
                                              const SizedBox(height: 10),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  TextButton(
                                                    onPressed: orderController.hideLocSelector,
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        const Icon(Icons.close),
                                                        Text('Выйти'.tr),
                                                      ],
                                                    ),
                                                  ),
                                                  TextButton(
                                                    onPressed: !isGeocodeLoading &&
                                                            currentGeocode != null &&
                                                            currentGeocodePosition != null &&
                                                            onGeocodeDone != null
                                                        ? () {
                                                            var newAddress = AddressModel(
                                                                address: currentGeocode,
                                                                geo:
                                                                    '${currentGeocodePosition.latitude},${currentGeocodePosition.longitude}');
                                                            onGeocodeDone(newAddress);
                                                            orderController.hideLocSelector();
                                                          }
                                                        : null,
                                                    child: const Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Icon(Icons.check_rounded),
                                                        Text(' Выбрать адрес'),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        )
                                      : const SizedBox(),
                                ),
                              ),
                              // distance - time
                              Align(
                                alignment: Alignment.topRight,
                                child: AnimatedSwitcher(
                                  duration: Durations.short2,
                                  transitionBuilder: (child, animation) {
                                    return FadeTransition(opacity: animation, child: child);
                                  },
                                  child: index == 0
                                      ? Padding(
                                          padding: const EdgeInsets.all(15.0),
                                          child: IconButton.filled(
                                            style: IconButton.styleFrom(
                                              backgroundColor: CoreColors.white,
                                              padding: EdgeInsets.zero,
                                            ),
                                            icon: Icon(Icons.my_location, color: CoreColors.primary),
                                            onPressed: () {
                                              var myPos = locationProvider.currentPosition.value;
                                              if (myPos != null) {
                                                _animatedMapMove(myPos, mapController.camera.zoom);
                                              } else {
                                                CoreToast.showToast('Местоположение не найдено');
                                              }
                                            },
                                          ),
                                        )
                                      : SizedBox(),
                                ),
                              ),
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
                                          isLocSelector
                                      ? const SizedBox()
                                      : Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              margin: const EdgeInsets.only(bottom: 10),
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
                        ));
                    // return AnimatedSwitcher(
                    //     duration: const Duration(milliseconds: 1300),
                    //     transitionBuilder: (child, animation) =>
                    //         SizeTransition(sizeFactor: animation, axis: Axis.vertical, child: child),
                    //     child: Container(
                    //         height: index == 0 ? h / 3 : h - (kToolbarHeight + 180),
                    //         color: Colors.white.withOpacity(0.5)));
                  }),
              tabBar,
              Expanded(
                  child: TabBarView(
                physics: const NeverScrollableScrollPhysics(),
                controller: _tabController,
                children: [
                  GetBuilder<AddressController>(builder: (addressController) {
                    return RefreshIndicator(
                      onRefresh: () async {
                        await orderController.fetchCarClasses();
                      },
                      child: ListView(
                        padding: const EdgeInsets.symmetric(vertical: CoreDecoration.primaryPadding),
                        children: [
                          Padding(
                              padding: const EdgeInsets.only(left: 15, bottom: 10),
                              child: Text('Класс поездки'.tr,
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
                          SizedBox(
                            height: 130,
                            child: ListView(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(horizontal: 15),
                                children: [
                                  for (final carClass in carClasses)
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(5, 5, 15, 16),
                                      child: Bounce(
                                        onTap: () {
                                          orderController.selectCarClass(carClass.id);
                                          isDelivery.value = false;
                                          isCargo.value = false;
                                        },
                                        child: RideTypeCard(
                                          carClass: carClass,
                                          isActive: selectedCarClassId == carClass.id,
                                        ),
                                      ),
                                    ),
                                  const VerticalDivider(width: 2),
                                  ValueListenableBuilder(
                                      valueListenable: isDelivery,
                                      builder: (_, isD, __) {
                                        return Padding(
                                          padding: const EdgeInsets.fromLTRB(15, 5, 15, 16),
                                          child: Bounce(
                                            onTap: () {
                                              if (!isD) {
                                                orderController.selectCarClass(null);
                                                isCargo.value = false;
                                              }
                                              isDelivery.value = !isD;
                                            },
                                            child: RideTypeCard(
                                              carClass: CarClassModel(name: "Курьер".tr, cost: 100),
                                              isActive: isD,
                                              asset: CoreAssets.deliveryClass,
                                            ),
                                          ),
                                        );
                                      }),
                                  ValueListenableBuilder(
                                      valueListenable: isCargo,
                                      builder: (_, isD, __) {
                                        return Padding(
                                          padding: const EdgeInsets.fromLTRB(5, 5, 15, 16),
                                          child: Bounce(
                                            onTap: () {
                                              if (!isD) {
                                                orderController.selectCarClass(null);
                                                isDelivery.value = false;
                                              }
                                              isCargo.value = !isD;
                                            },
                                            child: RideTypeCard(
                                              carClass: CarClassModel(name: "Груз".tr, cost: 100),
                                              isActive: isD,
                                              asset: CoreAssets.cargoClass,
                                            ),
                                          ),
                                        );
                                      }),
                                ]),
                          ),
                          Padding(
                              padding: const EdgeInsets.only(left: 15, bottom: 10),
                              child:
                                  Text('Откуда'.tr, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15.0).copyWith(bottom: 15),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    onTapOutside: (event) {
                                      FocusManager.instance.primaryFocus?.unfocus();
                                    },
                                    cursorColor: CoreColors.primary,
                                    controller:
                                        pointA != null ? TextEditingController(text: pointA.address) : pointAController,
                                    readOnly: pointA != null,
                                    style: CoreStyles.h4,
                                    decoration: CoreDecoration.textField.copyWith(
                                      hintText: "Укажите или выберите на карте".tr,
                                      suffixIcon: pointA != null
                                          ? IconButton(
                                              onPressed: () {
                                                orderController.clearPointA();
                                              },
                                              icon: const Icon(Icons.clear),
                                            )
                                          : null,
                                    ),
                                  ),
                                ),
                                pointA != null && pointA.id == null
                                    ? IconButton(
                                        onPressed: () {
                                          addressController.addAddress(
                                              address: '${pointA.address}',
                                              geo: pointA.geo,
                                              onDone: (a) {
                                                orderController.setPointA(a);
                                              });
                                        },
                                        icon: const Icon(Icons.save))
                                    : IconButton(
                                        onPressed: () {
                                          addressController.fetchAddresses();
                                          showBottomSheet(
                                              context: context,
                                              enableDrag: true,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                              elevation: 0,
                                              constraints: BoxConstraints(maxHeight: h * 0.5, minHeight: h * 0.5),
                                              builder: (context) {
                                                return AddressSelectDialog(
                                                    title: 'Откуда'.tr,
                                                    onSelected: (address) {
                                                      if (pointB?.id != null && pointB?.id == address.id) {
                                                        return;
                                                      }
                                                      pointAController.clear();
                                                      orderController.setPointA(address);
                                                    });
                                              });
                                        },
                                        icon: const Icon(Icons.list)),
                                IconButton(
                                    onPressed: () {
                                      orderController.fetchGeocode(mapController.camera.center);
                                      orderController.showLocSelector(
                                        title: 'Откуда'.tr,
                                        onDone: (newAddress) {
                                          orderController.setPointA(newAddress);
                                        },
                                      );
                                    },
                                    icon: const Icon(Icons.map)),
                              ],
                            ),
                          ),
                          Padding(
                              padding: const EdgeInsets.only(left: 15, bottom: 10),
                              child:
                                  Text('Куда'.tr, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    cursorColor: CoreColors.primary,
                                    controller:
                                        pointB != null ? TextEditingController(text: pointB.address) : pointBController,
                                    onTapOutside: (event) {
                                      FocusManager.instance.primaryFocus?.unfocus();
                                    },
                                    readOnly: pointB != null,
                                    style: CoreStyles.h4,
                                    decoration: CoreDecoration.textField.copyWith(
                                      hintText: "Укажите или выберите на карте".tr,
                                      suffixIcon: pointB != null
                                          ? IconButton(
                                              onPressed: () {
                                                orderController.clearPointB();
                                              },
                                              icon: const Icon(Icons.clear),
                                            )
                                          : null,
                                    ),
                                  ),
                                ),
                                pointB != null && pointB.id == null
                                    ? IconButton(
                                        onPressed: () {
                                          addressController.addAddress(
                                              address: '${pointB.address}',
                                              geo: pointB.geo,
                                              onDone: (b) {
                                                orderController.setPointB(b);
                                              });
                                        },
                                        icon: const Icon(Icons.save))
                                    : IconButton(
                                        onPressed: () {
                                          addressController.fetchAddresses();
                                          showBottomSheet(
                                              context: context,
                                              enableDrag: true,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                              constraints: BoxConstraints(maxHeight: h * 0.5, minHeight: h * 0.5),
                                              builder: (context) {
                                                return AddressSelectDialog(
                                                    title: 'Куда'.tr,
                                                    onSelected: (address) {
                                                      if (pointA?.id != null && pointA?.id == address.id) {
                                                        return;
                                                      }
                                                      pointBController.clear();
                                                      orderController.setPointB(address);
                                                    });
                                              });
                                        },
                                        icon: const Icon(Icons.list)),
                                IconButton(
                                    onPressed: () {
                                      orderController.fetchGeocode(mapController.camera.center);
                                      orderController.showLocSelector(
                                        title: 'Куда'.tr,
                                        onDone: (newAddress) {
                                          orderController.setPointB(newAddress);
                                        },
                                      );
                                    },
                                    icon: const Icon(Icons.map)),
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
                                // Expanded(
                                //   child: Column(
                                //     crossAxisAlignment: CrossAxisAlignment.start,
                                //     children: [
                                //       Padding(
                                //           padding: const EdgeInsets.only(bottom: 10, top: 15),
                                //           child: Text('Время'.tr,
                                //               style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
                                //       TextField(
                                //         controller: timeController,
                                //         readOnly: true,
                                //         onTap: () async {
                                //           TimeOfDay? time = await showDialog(
                                //               context: context,
                                //               builder: (context) {
                                //                 var now = DateTime.now().add(const Duration(minutes: 20));
                                //                 var hour = now.hour;
                                //                 var roundedMinute = (now.minute / 10).ceil() * 10;
                                //                 var currentSelectedTime = timeController.text.toTimeOfDay;
                                //                 if (currentSelectedTime != null) {
                                //                   return TimeNumberPickerDialog(
                                //                     initialTime: TimeOfDay(
                                //                         hour: currentSelectedTime.hour,
                                //                         minute: currentSelectedTime.minute),
                                //                   );
                                //                 }
                                //                 return TimeNumberPickerDialog(
                                //                   initialTime: TimeOfDay(hour: hour, minute: roundedMinute),
                                //                 );
                                //               });
                                //           if (time != null && mounted) {
                                //             timeController.text = time.format(context).padLeft(5, '0');
                                //             setState(() {});
                                //           }
                                //         },
                                //         onTapOutside: (event) {
                                //           FocusManager.instance.primaryFocus?.unfocus();
                                //         },
                                //         inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                //         decoration: CoreDecoration.textField.copyWith(
                                //             hintText: 'Как можно быстрее'.tr,
                                //             suffixIcon: timeController.text.isNotEmpty
                                //                 ? IconButton(
                                //                     onPressed: () {
                                //                       timeController.clear();
                                //                       setState(() {});
                                //                     },
                                //                     icon: const Icon(
                                //                       Icons.close,
                                //                       color: CoreColors.primary,
                                //                       size: 16,
                                //                     ))
                                //                 : const IconButton(
                                //                     onPressed: null,
                                //                     icon: Icon(
                                //                       Icons.access_time_rounded,
                                //                       color: CoreColors.primary,
                                //                       size: 16,
                                //                     ))),
                                //       )
                                //     ],
                                //   ),
                                // ),
                                // const SizedBox(width: 10),
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
                              ],
                            ),
                          ),
                          ListTile(
                            onTap: () {
                              commentFieldExpanded.value = !commentFieldExpanded.value;
                            },
                            title: Text("Комментарий".tr,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                            trailing: TextButton(
                                onPressed: () {
                                  commentFieldExpanded.value = !commentFieldExpanded.value;
                                },
                                child: Text("Добавить".tr,
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
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
                                            padding:
                                                const EdgeInsets.symmetric(horizontal: CoreDecoration.primaryPadding),
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
                                  if ((pointAController.text.isEmpty && (pointA?.address?.isEmpty ?? true)) ||
                                      (pointBController.text.isEmpty && (pointB?.address?.isEmpty ?? true)) ||
                                      (selectedCarClassId == null &&
                                          isDelivery.value == false &&
                                          isCargo.value == false) ||
                                      priceController.text.isEmpty) {
                                    CoreToast.showToast('Заполните все поля');
                                    return;
                                  }
                                  // собираем заказ
                                  var newOrder = OrderModel(
                                    pointA: pointA?.address ?? pointAController.text,
                                    pointB: pointB?.address ?? pointBController.text,
                                    geoA: pointA?.geo,
                                    geoB: pointB?.geo,
                                    userComment: commentsController.text.isEmpty ? null : commentsController.text,
                                    userCost: int.tryParse(priceController.text),
                                    userTime: timeController.text.isEmpty ? null : timeController.text,
                                    people: peopleValue.value,
                                    typeId: 1,
                                    isDelivery: isDelivery.value,
                                    isCargo: isCargo.value,
                                    classId: selectedCarClassId,
                                  );

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
                                            style: const TextStyle(
                                                color: CoreColors.white, fontSize: 14, fontWeight: FontWeight.w500),
                                          ))),
                          ),
                        ],
                      ),
                    );
                  }),
                  const HomeIntercityTab(),
                  const HomeCargoTab()
                ],
              ))

              // ValueListenableBuilder(
              //     valueListenable: selectedIndex,
              //     builder: (_, index, __) {
              //       return AnimatedContainer(
              //         duration: const Duration(seconds: 3),
              //         height: index == 0
              //             ? h / 3
              //             : h -
              //                 (kToolbarHeight +
              //                     tabBar.preferredSize.height +
              //                     appBar.preferredSize.height +
              //                     MediaQuery.of(context).padding.bottom),
              //         color: Colors.white.withOpacity(0.5),
              //         child: Center(
              //           child: Column(
              //             children: [Text('')],
              //           ),
              //         ),
              //       );
              //       // return AnimatedSwitcher(
              //       //     duration: const Duration(milliseconds: 1300),
              //       //     transitionBuilder: (child, animation) =>
              //       //         SizeTransition(sizeFactor: animation, axis: Axis.vertical, child: child),
              //       //     child: Container(
              //       //         height: index == 0 ? h / 3 : h - (kToolbarHeight + 180),
              //       //         color: Colors.white.withOpacity(0.5)));
              //     })
            ],
          ),
        ),
      );
    });
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

class SelectorMarkerWidget extends StatelessWidget {
  const SelectorMarkerWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Column(
        children: [
          const SizedBox(
            width: 40,
            height: 45,
            child: Stack(
              children: [
                SizedBox(
                  width: 40,
                  height: 45,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(
                        Icons.place,
                        size: 35,
                        color: CoreColors.white,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 40,
                  height: 45,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(
                        Icons.place_outlined,
                        size: 35,
                        color: CoreColors.primary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 40,
            height: 10,
            decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2, strokeAlign: BorderSide.strokeAlignOutside),
                shape: BoxShape.circle,
                color: Colors.black),
          ),
          const SizedBox(width: 40, height: 45),
        ],
      ),
    );
  }
}
