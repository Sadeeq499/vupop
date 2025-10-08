import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../utils/common_code.dart';

class CustomSocketService {
  static final CustomSocketService _instance = CustomSocketService._internal();

  io.Socket? socket;
  final isSocketConnect = false.obs;
  CustomSocketService._internal();

  static CustomSocketService get instance => _instance;

  void initializeSocket(String uri, {required Map<dynamic, dynamic> queryParams}) {
    socket = io.io(uri, io.OptionBuilder().setTransports(['websocket']).disableAutoConnect().build());

    socket?.connect();
    printLogs("Socket initialized and connected for notification");
  }

  void disconnectSocket() {
    socket?.disconnect();
    socket = null;
    if (kDebugMode) {
      printLogs("Socket disconnected for notification");
    }
  }

/*  void setupSocketListeners() {
    //final socket = ChatSocketService.instance.socket;

    socket?.onConnect((_) {
      printLogs('======in on connect');
      isSocketConnect.value = true;
      // fetchChats();
    });

    socket?.onDisconnect((_) {
      isSocketConnect.value = false;
    });

    socket?.onReconnect((_) {
      // fetchChats();
    });

    socket?.onError((data) {
      isSocketConnect.value = false;
    });

    socket?.onConnectError((data) {
      isSocketConnect.value = false;
    });
  }*/
}
// import 'package:get/get.dart';
//
// class CustomSocketService extends GetxService {
//   WebSocketChannel? _channel;
//   final _isConnected = false.obs;
//   final _messageStream = ''.obs;
//
//   bool get isConnected => _isConnected.value;
//   Stream<String> get messageStream => _messageStream.stream;
//
//   void connect(String url) {
//     try {
//       _channel = WebSocketChannel.connect(Uri.parse(url));
//       _isConnected.value = true;
//
//       // Listen to incoming messages
//       _channel!.stream.listen(
//         (message) {
//           _messageStream.value = message.toString();
//         },
//         onError: (error) {
//           printLogs('WebSocket Error: $error');
//           _isConnected.value = false;
//           reconnect(url);
//         },
//         onDone: () {
//           _isConnected.value = false;
//           reconnect(url);
//         },
//       );
//     } catch (e) {
//       printLogs('Connection Error: $e');
//       _isConnected.value = false;
//     }
//   }
//
//   void reconnect(String url) {
//     Future.delayed(Duration(seconds: 5), () {
//       if (!_isConnected.value) {
//         connect(url);
//       }
//     });
//   }
//
//   void sendMessage(String message) {
//     if (_channel != null && _isConnected.value) {
//       _channel!.sink.add(message);
//     }
//   }
//
//   void dispose() {
//     _channel?.sink.close();
//     _isConnected.value = false;
//   }
// }
