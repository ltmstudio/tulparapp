import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:tulpar/core/decoration.dart';
import 'package:tulpar/view/widget/elevated_button.dart';

final List<int> thirtyOnes = [0, 2, 4, 6, 7, 9, 11];
final List<String> monthNames = [
  "Январь",
  "Февраль",
  "Март",
  "Апрель",
  "Май",
  "Июнь",
  "Июль",
  "Август",
  "Сентябрь",
  "Октябрь",
  "Ноябрь",
  "Декабрь"
];

class DateNumberPickerDialog extends StatefulWidget {
  const DateNumberPickerDialog({super.key, this.initialDate});
  final DateTime? initialDate;
  @override
  State<DateNumberPickerDialog> createState() => _DateNumberPickerDialogState();
}

class _DateNumberPickerDialogState extends State<DateNumberPickerDialog> {
  ValueNotifier<int> selectedMonth = ValueNotifier<int>(0);
  ValueNotifier<int> selectedDate = ValueNotifier<int>(1);
  ValueNotifier<int> selectedYear = ValueNotifier<int>(2000);
  @override
  void initState() {
    if (widget.initialDate != null) {
      selectedYear.value = widget.initialDate!.year;
      selectedMonth.value = widget.initialDate!.month - 1;
      selectedDate.value = widget.initialDate!.day;
    }
    super.initState();
  }

// NumberPicker(
//                               minValue: 1,
//                               infiniteLoop: true,
//                               textMapper: (numberText) => numberText.padLeft(2, '0'),
//                               textStyle: CoreStyles.s10w500.copyWith(color: CoreColors.black.withOpacity(0.5)),
//                               selectedTextStyle: CoreStyles.s14w500c,
//                               maxValue: 23,
//                               value: year,
//                               onChanged: (v) {
//                                 selectedhour.value = v;
//                               });
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 15),
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 25),
      actionsPadding: const EdgeInsets.only(bottom: 15, right: 10, left: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(CoreDecoration.primaryBorderRadius)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Выберите дату',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
          ),
          Row(
            children: [
              Expanded(
                child: ValueListenableBuilder<int>(
                  valueListenable: selectedYear,
                  builder: (context, year, child) {
                    return ValueListenableBuilder<int>(
                      valueListenable: selectedMonth,
                      builder: (context, month, child) {
                        return ValueListenableBuilder<int>(
                          valueListenable: selectedDate,
                          builder: (context, date, child) {
                            return NumberPicker(
                              minValue: 1,
                              maxValue: year % 4 == 0 && month == 1
                                  ? 29
                                  : thirtyOnes.contains(month)
                                      ? 31
                                      : 30,
                              value: date,
                              onChanged: (value) => selectedDate.value = value,
                              textStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
                              selectedTextStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
              Expanded(
                child: ValueListenableBuilder<int>(
                  valueListenable: selectedMonth,
                  builder: (context, month, child) {
                    return NumberPicker(
                      minValue: 0,
                      maxValue: 11,
                      value: month,
                      onChanged: (v) {
                        selectedMonth.value = v;
                        if (selectedDate.value >
                            (selectedYear.value % 4 == 0 && v == 1
                                ? 29
                                : thirtyOnes.contains(v)
                                    ? 31
                                    : 30)) {
                          selectedDate.value = (selectedYear.value % 4 == 0 && v == 1
                              ? 29
                              : thirtyOnes.contains(v)
                                  ? 31
                                  : 30);
                        }
                      },
                      textMapper: (numberText) => monthNames[int.parse(numberText)],
                      textStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
                      selectedTextStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    );
                  },
                ),
              ),
              Expanded(
                child: ValueListenableBuilder<int>(
                  valueListenable: selectedYear,
                  builder: (context, year, child) {
                    var nowYear = DateTime.now().year;
                    return NumberPicker(
                      minValue: nowYear - 100,
                      maxValue: nowYear + 100,
                      value: year,
                      onChanged: (value) => selectedYear.value = value,
                      textStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
                      selectedTextStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    );
                  },
                ),
              )
            ],
          )
        ],
      ),
      actions: [
        PrimaryElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(DateTime(selectedYear.value, selectedMonth.value + 1, selectedDate.value));
            },
            text: 'Выбрать')
        // ElevatedButton(
        //     style: ElevatedButton.styleFrom(backgroundColor: CoreColors.primary),
        //     onPressed: () {
        //       Navigator.of(context).pop(DateTime(selectedYear.value, selectedMonth.value + 1, selectedDate.value));
        //     },
        //     child: Center(
        //         child: Text(
        //       ,
        //       style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: CoreColors.white),
        //     ))),
      ],
    );
  }
}
