import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';

class ChatSocketService {
  WebSocketChannel? _channel;
  final StreamController<Map<String, dynamic>> _messageController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get messages => _messageController.stream;

  void connect(String url) {
    log('Connecting to WebSocket: $url');
    try {
      _channel = IOWebSocketChannel.connect(Uri.parse(url));
      _channel!.stream.listen(
        (data) {
          try {
            final decoded = jsonDecode(data) as Map<String, dynamic>;
            _messageController.add(decoded);
          } catch (e) {
            log('WebSocket error decoding: $e');
          }
        },
        onError: (error) {
          log('WebSocket error: $error');
        },
        onDone: () {
          log('WebSocket closed');
        },
      );
    } catch (e) {
      log('WebSocket connection error: $e');
    }
  }

  void send(Map<String, dynamic> data) {
    if (_channel != null) {
      _channel!.sink.add(jsonEncode(data));
    } else {
      log('WebSocket error: Trying to send message while channel is null');
    }
  }

  void close() {
    _channel?.sink.close();
    _channel = null;
  }

  void dispose() {
    close();
    _messageController.close();
  }
}
