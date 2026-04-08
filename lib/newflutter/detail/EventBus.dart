import 'dart:async';

class EventBus {
  EventBus._internal();

  static final EventBus _instance = EventBus._internal();

  factory EventBus() => _instance;

  final _controller = StreamController<dynamic>.broadcast();

  void fire(event) {
    _controller.add(event);
  }

  Stream<T> on<T>() {
    return _controller.stream.where((event) => event is T).cast<T>();
  }

  void dispose() {
    _controller.close();
  }
}

final eventBus = EventBus();

class PositionEvent {
  final int position;

  PositionEvent({required this.position});
}