import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tulpar/controller/address.dart';
import 'package:tulpar/core/colors.dart';
import 'package:tulpar/model/user/address.dart';

class AddressSelectDialog extends StatelessWidget {
  const AddressSelectDialog({super.key, this.title, this.onSelected});
  final String? title;
  final void Function(AddressModel address)? onSelected;
  @override
  Widget build(BuildContext context) {
    return GetBuilder<AddressController>(builder: (addressController) {
      var addresses = addressController.addresses.value;
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 7, bottom: 7),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(color: CoreColors.grey, borderRadius: BorderRadius.circular(5)),
                    ),
                  )
                ],
              ),
            ),
            if (title != null)
              Padding(
                  padding: const EdgeInsets.only(
                    bottom: 15,
                  ),
                  child: Text(title!, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700))),
            if (addresses.isEmpty)
              Expanded(
                  child: Center(
                child: Text("Нет сохраненных адресов".tr),
              )),
            Expanded(
              child: ListView.builder(
                itemCount: addresses.length,
                itemBuilder: (context, index) {
                  var address = addresses[index];
                  return ListTile(
                    contentPadding: EdgeInsets.all(0),
                    leading: PopupMenuButton(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        itemBuilder: (context) {
                          return [
                            PopupMenuItem(
                                child: Row(
                                  children: [
                                    Icon(Icons.delete_outline_outlined, size: 14, color: CoreColors.error),
                                    SizedBox(width: 5),
                                    Text('Удалить'.tr, style: TextStyle(color: CoreColors.error)),
                                  ],
                                ),
                                value: 'edit'),
                          ];
                        },
                        onSelected: (value) {
                          if (address.id != null) {
                            addressController.deleteAddress(address.id!);
                          }
                        }),
                    onTap: () {
                      onSelected?.call(address);
                      Navigator.of(context).pop();
                    },
                    trailing: Padding(
                      padding: const EdgeInsets.only(right: 5),
                      child: const Icon(Icons.chevron_right),
                    ),
                    title: Text('${address.address}'),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // TextButton.icon(
                //     onPressed: () {
                //       // Navigator.of(context).push(
                //       //   MaterialPageRoute(builder: (context) => const AddressesScreen()),
                //       // );
                //     },
                //     icon: const Icon(Icons.edit),
                //     label: Text('Редактировать'.tr)),
                TextButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.arrow_drop_down_rounded),
                    label: Text('Скрыть'.tr)),
              ],
            )
          ],
        ),
      );
    });
  }
}
