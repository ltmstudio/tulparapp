import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:navi/navi.dart';
import 'package:collection/collection.dart';
import 'package:tulpar/controller/app.dart';
import 'package:tulpar/controller/user.dart';
import 'package:tulpar/core/animation.dart';
import 'package:tulpar/core/colors.dart';
import 'package:tulpar/routes/tabs.dart';
import 'package:tulpar/view/component/bottom_navigation.dart';
import 'package:tulpar/view/screen/app/splash.dart';
import 'package:tulpar/view/screen/auth/phone.dart';
import 'package:tulpar/view/screen/auth/sms.dart';

class AppStartScreen extends StatefulWidget {
  const AppStartScreen({super.key});

  @override
  State<AppStartScreen> createState() => _AppStartScreenState();
}

class _AppStartScreenState extends State<AppStartScreen> {
  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return Container(
      width: w,
      height: h,
      color: CoreColors.white,
      child: GetBuilder<AppController>(
        builder: (controller) {
          Widget screen = const AppSplashScreen();
          if (controller.appStatus.value == AppConnectionStatus.done) {
            screen = const AuthStartScreen();
          }
          return AnimatedSwitcher(
            duration: CoreAnimations.d200,
            transitionBuilder: (child, animation) {
              return FadeTransition(
                  // return SlideTransition(
                  // position: Tween<Offset>(
                  //         begin: const Offset(1, 0), end: const Offset(0, 0))
                  //     .animate(animation),
                  opacity: animation,
                  child: child);
            },
            child: screen,
          );
        },
      ),
    );
  }
}

class TabsStartScreen extends StatefulWidget {
  const TabsStartScreen({super.key});

  @override
  State<TabsStartScreen> createState() => _TabsStartScreenState();
}

class _TabsStartScreenState extends State<TabsStartScreen> {
  @override
  void initState() {
    AppController.loadAppData();
    super.initState();
  }

  var pageController = PageController(initialPage: 1);

  var currentIndex = ValueNotifier<int>(1);

  void onTap(int index) {
    var appController = Get.find<AppController>();
    var tabData = tabUserData;
    if (appController.appMode.value == AppMode.driver) {
      tabData = tabDriverData;
    }
    if (currentIndex.value == index) {
      if (tabData[index].navigatorKey.currentState?.canPop() ?? false) {
        tabData[index].navigatorKey.currentState?.popUntil((route) => route.isFirst);
      }
    } else {
      currentIndex.value = index;
      pageController.jumpToPage(index);
    }

    // pageController.animateToPage(index,
    //     duration: Duration(milliseconds: 200), curve: Curves.easeIn);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (_) async {
        var pop = false;
        var appController = Get.find<AppController>();
        var tabData = tabUserData;
        if (appController.appMode.value == AppMode.driver) {
          tabData = tabDriverData;
        }
        var currentState = tabData[currentIndex.value].navigatorKey.currentState;
        if (currentState?.canPop() ?? false) {
          currentState?.pop();
          pop = false;
        }
        if (pop) {
          Navigator.of(context).pop();
        }
      },
      child: GetBuilder<AppController>(builder: (appController) {
        var tabData = tabUserData;
        if (appController.appMode.value == AppMode.driver) {
          tabData = tabDriverData;
        }
        return Scaffold(
          extendBody: false,
          body: Column(
            children: [
              Expanded(
                child: PageView(
                  physics: const NeverScrollableScrollPhysics(),
                  controller: pageController,
                  children: tabData.mapIndexed((i, e) => TabBridge(active: i == currentIndex.value, tab: e)).toList(),
                ),
              ),
            ],
          ),
          bottomNavigationBar: ClipRRect(
            child: ValueListenableBuilder(
                valueListenable: currentIndex,
                builder: (_, c, __) {
                  return BottomNavigationBarWidget(
                    currentIndex: c,
                    onTap: onTap,
                  );
                }),
          ),
        );
      }),
    );
  }
}

class AuthStartScreen extends StatefulWidget {
  const AuthStartScreen({super.key});

  @override
  State<AuthStartScreen> createState() => _AuthStartScreenState();
}

class _AuthStartScreenState extends State<AuthStartScreen> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserController>(
      builder: (controller) {
        if (controller.token.value != null && controller.userStage.value == UserLoginStage.done) {
          return const TabsStartScreen();
        } else {
          Widget screen = const AuthPhoneScreen();
          switch (controller.userStage.value) {
            case UserLoginStage.phone:
              screen = const AuthPhoneScreen();
              break;
            case UserLoginStage.sms:
              screen = const AuthSmsScreen();
              break;
            default:
          }
          return AnimatedSwitcher(
            duration: CoreAnimations.d200,
            transitionBuilder: (child, animation) {
              return FadeTransition(
                  // return SlideTransition(
                  //     position: Tween<Offset>(
                  //             begin: const Offset(1, 0), end: const Offset(0, 0))
                  //         .animate(animation),
                  opacity: animation,
                  child: child);
            },
            child: screen,
          );
        }
      },
    );
  }
}

class TabBridge extends StatefulWidget {
  const TabBridge({Key? key, required this.active, required this.tab}) : super(key: key);
  final bool active;
  final TabDataModel tab;

  @override
  State<TabBridge> createState() => TabBridgeState();
}

class TabBridgeState extends State<TabBridge> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return NaviStack(
        navigatorKey: widget.tab.navigatorKey,
        active: widget.active,
        pages: (context) => [NaviPage.material(key: ValueKey(widget.tab.navigatorKey), child: widget.tab.screen)]);
  }
}
