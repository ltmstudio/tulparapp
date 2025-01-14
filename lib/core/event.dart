enum WidgetEvent { flushStartForm }

class StreamWidgetEvent {
  String id;
  WidgetEvent type;
  StreamWidgetEvent({required this.id, required this.type});
}
