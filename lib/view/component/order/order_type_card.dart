import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tulpar/core/colors.dart';
import 'package:tulpar/core/env.dart';
import 'package:tulpar/model/order/car_class.dart';

class RideTypeCard extends StatelessWidget {
  final CarClassModel carClass;
  final bool isActive;
  final String? asset;
  const RideTypeCard({
    super.key,
    required this.carClass,
    this.asset,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      constraints: BoxConstraints(minWidth: 90),
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: CoreColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: CoreColors.primary.withOpacity(isActive ? 1 : 0),
            width: 1,
            strokeAlign: 1), // Добавляем рамку если карточка активна
        boxShadow: [
          BoxShadow(
            color: isActive
                ? CoreColors.primary.withOpacity(0.15) // Активная тень
                : Colors.black.withOpacity(0.15), // Обычная тень
            offset: const Offset(1, 1),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(
            height: 15,
          ),
          if (asset != null)
            Expanded(
              child: Image.asset(
                asset!,
                fit: BoxFit.contain,
              ),
            )
          else if (carClass.image != null)
            Expanded(
              child: CachedNetworkImage(
                imageUrl: "${CoreEnvironment.appUrl}/${carClass.image!.replaceFirst('public', 'storage')}",
                fit: BoxFit.contain,
              ),
            ),
          const SizedBox(height: 5),
          Text(carClass.name ?? '-',
              style: TextStyle(color: CoreColors.primary, fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 3),
          Text(
            "от ${carClass.cost ?? ''} ₸",
            style: TextStyle(color: CoreColors.primary, fontSize: 12),
          ),
          const SizedBox(height: 5),
        ],
      ),
    );
  }
}
