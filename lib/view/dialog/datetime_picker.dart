import 'package:flutter/material.dart';
import 'package:tulpar/view/dialog/date_picker.dart';
import 'package:tulpar/view/dialog/time_picker.dart';
import 'package:tulpar/view/widget/elevated_button.dart';

class DateTimePickerDialog extends StatefulWidget {
  const DateTimePickerDialog({super.key, this.initialDateTime});
  final DateTime? initialDateTime;

  @override
  State<DateTimePickerDialog> createState() => _DateTimePickerDialogState();
}

class _DateTimePickerDialogState extends State<DateTimePickerDialog> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  @override
  void initState() {
    if (widget.initialDateTime != null) {
      selectedDate = widget.initialDateTime;
      selectedTime = TimeOfDay(hour: widget.initialDateTime!.hour, minute: widget.initialDateTime!.minute);
    } else {
      selectedDate = DateTime.now();
      selectedTime = TimeOfDay.now();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 15),
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 25),
      actionsPadding: const EdgeInsets.only(bottom: 15, right: 10, left: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Выберите дату и время',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
          ),
          ElevatedButton(
            onPressed: () async {
              final date = await showDialog<DateTime>(
                context: context,
                builder: (context) => DateNumberPickerDialog(initialDate: selectedDate),
              );
              if (date != null) {
                setState(() {
                  selectedDate = date;
                });
              }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Выберите дату:'),
                Text('${selectedDate?.toLocal().toString().split(' ')[0]}'),
              ],
            ),
            // child: Text('Выберите дату: ${selectedDate?.toString()}'),
          ),
          ElevatedButton(
            onPressed: () async {
              final time = await showDialog<TimeOfDay>(
                context: context,
                builder: (context) => TimeNumberPickerDialog(initialTime: selectedTime),
              );
              if (time != null) {
                setState(() {
                  selectedTime = time;
                });
              }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Выберите время:'),
                Text('${selectedTime?.format(context)}'),
              ],
            ),
          ),
        ],
      ),
      actions: [
        PrimaryElevatedButton(
            onPressed: () {
              if (selectedDate != null && selectedTime != null) {
                final dateTime = DateTime(
                  selectedDate!.year,
                  selectedDate!.month,
                  selectedDate!.day,
                  selectedTime!.hour,
                  selectedTime!.minute,
                );
                Navigator.of(context).pop(dateTime);
              } else {
                Navigator.of(context).pop(null);
              }
            },
            text: 'Выбрать')
      ],
    );
  }
}
