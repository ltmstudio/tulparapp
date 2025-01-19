import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tulpar/controller/app.dart';
import 'package:tulpar/core/colors.dart';
import 'package:tulpar/routes/tabs.dart';

class BottomNavigationBarWidget extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavigationBarWidget({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppController>(builder: (appController) {
      var tabData = tabUserData;
      if (appController.appMode.value == AppMode.driver) {
        tabData = tabDriverData;
      }
      return Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(
              width: 1,
              color: Color(0xFFECECEC),
            ),
          ),
        ),
        child: Theme(
          data: ThemeData(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: BottomNavigationBar(
              showUnselectedLabels: true,
              showSelectedLabels: true,
              enableFeedback: true,
              backgroundColor: Colors.white,
              type: BottomNavigationBarType.fixed,
              elevation: 1,
              selectedItemColor: CoreColors.primary,
              unselectedItemColor: CoreColors.black,
              selectedFontSize: 12,
              unselectedLabelStyle: const TextStyle(fontFamily: 'Mulish', fontWeight: FontWeight.w700),
              selectedLabelStyle: const TextStyle(fontFamily: 'Mulish', fontWeight: FontWeight.w700),
              selectedIconTheme: const IconThemeData(
                color: CoreColors.primary,
              ),
              currentIndex: currentIndex,
              onTap: onTap,
              items: [
                for (var i = 0; i < tabData.length; i++)
                  BottomNavigationBarItem(
                    backgroundColor: Colors.white,
                    icon: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          tabData[i].icon!,
                          size: 24,
                          color: currentIndex == i ? CoreColors.primary : CoreColors.grey,
                        ),
                        // Text(
                        //   tabData[i].label.tr,
                        //   // style: Coresth(color: currentIndex == i ? CoreColors.primary : CoreColors.grey),
                        // )
                      ],
                    ),
                    label: tabData[i].label.tr,
                  )
              ]),
        ),
      );
    });
  }
}
