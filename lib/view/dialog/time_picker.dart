import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:get/get.dart';
import 'package:tulpar/core/colors.dart';

class TimeNumberPickerDialog extends StatefulWidget {
  const TimeNumberPickerDialog({super.key, this.initialTime});
  final TimeOfDay? initialTime;
  @override
  State<TimeNumberPickerDialog> createState() => _TimeNumberPickerDialogState();
}

class _TimeNumberPickerDialogState extends State<TimeNumberPickerDialog> {
  var selectedhour = ValueNotifier(1);
  var selectedminute = ValueNotifier(0);
  @override
  void initState() {
    if (widget.initialTime != null) {
      selectedhour.value = widget.initialTime!.hour;
      selectedminute.value = widget.initialTime!.minute;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 15),
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 25),
      actionsPadding: const EdgeInsets.only(bottom: 15, right: 10, left: 10),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Выберите время'.tr,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Row(
            children: [
              Expanded(
                child: ValueListenableBuilder(
                    valueListenable: selectedhour,
                    builder: (_, hours, __) {
                      return NumberPicker(
                          minValue: 1,
                          infiniteLoop: true,
                          textMapper: (numberText) => numberText.padLeft(2, '0'),
                          textStyle: TextStyle(
                              fontSize: 10, fontWeight: FontWeight.w500, color: CoreColors.black.withOpacity(0.5)),
                          selectedTextStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                          maxValue: 23,
                          value: hours,
                          onChanged: (v) {
                            selectedhour.value = v;
                          });
                    }),
              ),
              const Text(
                ':',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              Expanded(
                child: ValueListenableBuilder(
                    valueListenable: selectedminute,
                    builder: (_, minutes, ___) {
                      return NumberPicker(
                          minValue: 0,
                          infiniteLoop: true,
                          textMapper: (numberText) => numberText.padLeft(2, '0'),
                          textStyle: TextStyle(
                              fontSize: 10, fontWeight: FontWeight.w500, color: CoreColors.black.withOpacity(0.5)),
                          selectedTextStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                          step: 10,
                          maxValue: 50,
                          value: minutes,
                          onChanged: (v) {
                            selectedminute.value = v;
                          });
                    }),
              ),
            ],
          )
        ],
      ),
      actions: [
        ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: CoreColors.primary),
            onPressed: () {
              Navigator.of(context).pop(TimeOfDay(hour: selectedhour.value, minute: selectedminute.value));
            },
            child: Center(
                child: Text(
              'Выбрать'.tr,
              style: TextStyle(color: CoreColors.white, fontSize: 14, fontWeight: FontWeight.w500),
            ))),
      ],
    );
  }
}
