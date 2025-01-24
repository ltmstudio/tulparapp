import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:tulpar/controller/pay.dart';
import 'package:tulpar/core/decoration.dart';
import 'package:tulpar/core/log.dart';
import 'package:url_launcher/url_launcher_string.dart';

class PayDialog extends StatefulWidget {
  const PayDialog({super.key});

  @override
  State<PayDialog> createState() => _PayDialogState();
}

class _PayDialogState extends State<PayDialog> {
  @override
  void initState() {
    Get.find<PayController>().fetchPayInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return GetBuilder<PayController>(builder: (payController) {
      var info = payController.payInfo.value;
      var loading = payController.payInfoLoading.value;
      return Container(
        width: w,
        height: h * 0.5,
        padding: const EdgeInsets.all(CoreDecoration.primaryPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Пополнение баланса",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "Ваш баланс будет пополнен суммой оплаты после подтверждения модератором",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            if (loading)
              Expanded(child: Center(child: CircularProgressIndicator()))
            else if (!loading && info == null)
              Text("Ошибка получения данных")
            else
              Expanded(
                  child: Column(
                children: [
                  if (info?.payQrImage != null)
                    Expanded(
                        child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: CoreDecoration.primaryPadding),
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(CoreDecoration.primaryBorderRadius),
                          child: CachedNetworkImage(imageUrl: info!.payQrImage!, width: w)),
                    )),
                ],
              )),
            if (info?.payLink != null)
              ListTile(
                title: Text("Ссылка на оплату"),
                subtitle: Text(info!.payLink!),
                contentPadding: EdgeInsets.all(0),
                onTap: () async {
                  if (await canLaunchUrlString(info.payLink!)) {
                    Log.info("Открытие ссылки на оплату: ${info.payLink}");
                    launchUrlString(info.payLink!);
                  } else {
                    Log.error("Ошибка открытия ссылки на оплату: ${info.payLink}");
                  }
                },
                trailing: IconButton(
                  icon: Icon(Icons.copy),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: info!.payLink!));
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Скопировано")));
                  },
                ),
              ),
          ],
        ),
      );
    });
  }
}
