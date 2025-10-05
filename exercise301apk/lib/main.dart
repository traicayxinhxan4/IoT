// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

// void main() => runApp(const MyApp());

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'IoT Device Controller',
//       home: const IoTDeviceDashboard(),
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }

// class IoTDeviceDashboard extends StatefulWidget {
//   const IoTDeviceDashboard({super.key});
//   @override
//   State<IoTDeviceDashboard> createState() => _IoTDeviceDashboardState();
// }

// class _IoTDeviceDashboardState extends State<IoTDeviceDashboard> {
//   final _baseUrl = 'http://10.0.2.2:8080';
//   List<Device> _devices = [];
//   final _deviceNameController = TextEditingController();
//   final _deviceTopicController = TextEditingController();

//   Map<int, String> _payloads = {}; // lưu trạng thái LED

//   @override
//   void initState() {
//     super.initState();
//     fetchDevices();
//   }

//   Future<void> fetchDevices() async {
//     final response = await http.get(Uri.parse('$_baseUrl/devices'));
//     if (response.statusCode == 200) {
//       final List list = json.decode(response.body);
//       setState(() {
//         _devices = list.map((json) => Device.fromJson(json)).toList();
//         for (var d in _devices) {
//           _payloads[d.id] = d.status ?? "LED_OFF"; // ✅ dùng status từ server
//         }
//       });
//     }
//   }

//   Future<void> createDevice() async {
//     if (_deviceNameController.text.isEmpty || _deviceTopicController.text.isEmpty) return;
//     final response = await http.post(
//       Uri.parse('$_baseUrl/devices'),
//       headers: {'Content-Type': 'application/json'},
//       body: json.encode({
//         'name': _deviceNameController.text,
//         'topic': _deviceTopicController.text,
//       }),
//     );
//     if (response.statusCode == 200 || response.statusCode == 201) {
//       _deviceNameController.clear();
//       _deviceTopicController.clear();
//       fetchDevices();
//     }
//   }

//   // Future<void> controlDevice(int id) async {
//   //   final payload = _payloads[id] ?? "LED_ON";
//   //   final response = await http.post(
//   //     Uri.parse('$_baseUrl/devices/$id/control'),
//   //     headers: {'Content-Type': 'text/plain'},
//   //     body: payload,
//   //   );
//   //   if (response.statusCode == 200) {
//   //     fetchDevices(); // ✅ cập nhật trạng thái ngay
//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       SnackBar(content: Text('Đã gửi lệnh: $payload')),
//   //     );
//   //   }
//   // }
//   Future<void> controlDevice(int id) async {
//     final payload = _payloads[id] ?? "LED_ON";
//     final response = await http.post(
//       Uri.parse('$_baseUrl/devices/$id/control'),
//       headers: {'Content-Type': 'text/plain'},
//       body: payload,
//     );
//     if (response.statusCode == 200) {
//       // ✅ cập nhật local state ngay thay vì fetchDevices
//       setState(() {
//         _payloads[id] = payload;
//         _devices = _devices.map((d) {
//           if (d.id == id) {
//             return Device(id: d.id, name: d.name, topic: d.topic, status: payload);
//           }
//           return d;
//         }).toList();
//       });

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Đã gửi lệnh: $payload')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('📡 IoT Device Controller'),
//         centerTitle: true,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: ListView(
//           children: [
//             const Text('📋 Danh sách thiết bị', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//             ..._devices.map((d) {
//               final status = _payloads[d.id] ?? "LED_ON";
//               final color = status == "LED_ON" ? Colors.green.shade100 : Colors.red.shade100;
//               return Card(
//                 color: color,
//                 child: Padding(
//                   padding: const EdgeInsets.all(12),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Icon(Icons.memory,
//                               color: status == "LED_ON" ? Colors.green : Colors.red),
//                           const SizedBox(width: 8),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(d.name,
//                                     style: const TextStyle(
//                                         fontSize: 16, fontWeight: FontWeight.bold)),
//                                 Text("MQTT Topic: ${d.topic}",
//                                     style: const TextStyle(fontSize: 12)),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 10),
//                       DropdownButtonFormField<String>(
//                         value: _payloads[d.id] ?? "LED_ON",
//                         decoration: const InputDecoration(
//                           labelText: "Lệnh điều khiển",
//                           border: OutlineInputBorder(),
//                         ),
//                         items: const [
//                           DropdownMenuItem(value: "LED_ON", child: Text("LED_ON")),
//                           DropdownMenuItem(value: "LED_OFF", child: Text("LED_OFF")),
//                         ],
//                         onChanged: (val) {
//                           setState(() {
//                             _payloads[d.id] = val!;
//                           });
//                         },
//                       ),
//                       const SizedBox(height: 12),
//                       Align(
//                         alignment: Alignment.centerRight, // ✅ gom về góc phải
//                         child: Wrap(
//                           spacing: 8,
//                           children: [
//                             ElevatedButton.icon(
//                               onPressed: () => controlDevice(d.id),
//                               icon: const Icon(Icons.send),
//                               label: const Text("Gửi"),
//                             ),
//                             // ElevatedButton.icon(
//                             //   style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
//                             //   onPressed: () {
//                             //     setState(() {
//                             //       _payloads[d.id] = "LED_ON";
//                             //     });
//                             //     controlDevice(d.id);
//                             //   },
//                             //   icon: const Icon(Icons.lightbulb),
//                             //   label: const Text("Bật LED"),
//                             // ),
//                             // ElevatedButton.icon(
//                             //   style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//                             //   onPressed: () {
//                             //     setState(() {
//                             //       _payloads[d.id] = "LED_OFF";
//                             //     });
//                             //     controlDevice(d.id);
//                             //   },
//                             //   icon: const Icon(Icons.lightbulb_outline),
//                             //   label: const Text("Tắt LED"),
//                             // ),
//                             ElevatedButton.icon(
//                               style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
//                               onPressed: () {
//                                 setState(() {
//                                   _payloads[d.id] = "LED_ON";
//                                   _devices = _devices.map((dev) =>
//                                     dev.id == d.id
//                                         ? Device(id: dev.id, name: dev.name, topic: dev.topic, status: "LED_ON")
//                                         : dev
//                                   ).toList();
//                                 });
//                                 controlDevice(d.id); // gửi API
//                               },
//                               icon: const Icon(Icons.lightbulb),
//                               label: const Text("Bật LED"),
//                             ),

//                             ElevatedButton.icon(
//                               style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//                               onPressed: () {
//                                 setState(() {
//                                   _payloads[d.id] = "LED_OFF";
//                                   _devices = _devices.map((dev) =>
//                                     dev.id == d.id
//                                         ? Device(id: dev.id, name: dev.name, topic: dev.topic, status: "LED_OFF")
//                                         : dev
//                                   ).toList();
//                                 });
//                                 controlDevice(d.id); // gửi API
//                               },
//                               icon: const Icon(Icons.lightbulb_outline),
//                               label: const Text("Tắt LED"),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             }),
//             const SizedBox(height: 20),
//             const Text('➕ Thêm thiết bị mới', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//             TextField(controller: _deviceNameController, decoration: const InputDecoration(labelText: 'Tên thiết bị')),
//             TextField(controller: _deviceTopicController, decoration: const InputDecoration(labelText: 'Topic MQTT')),
//             ElevatedButton(onPressed: createDevice, child: const Text('Tạo thiết bị')),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class Device {
//   final int id;
//   final String name;
//   final String topic;
//   final String status;

//   Device({required this.id, required this.name, required this.topic, required this.status});

//   factory Device.fromJson(Map<String, dynamic> json) {
//     return Device(
//       id: json['id'],
//       name: json['name'],
//       topic: json['topic'],
//       status: json['status'] ?? "LED_OFF",
//     );
//   }
// }


// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:mqtt_client/mqtt_client.dart';
// import 'package:mqtt_client/mqtt_server_client.dart';
// import 'package:speech_to_text/speech_to_text.dart';

// void main() => runApp(const MyApp());

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'IoT Device Controller',
//       home: const IoTDeviceDashboard(),
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }

// class IoTDeviceDashboard extends StatefulWidget {
//   const IoTDeviceDashboard({super.key});
//   @override
//   State<IoTDeviceDashboard> createState() => _IoTDeviceDashboardState();
// }

// // class _IoTDeviceDashboardState extends State<IoTDeviceDashboard> {
// //   final _baseUrl = 'http://10.0.2.2:8080';
// //   List<Device> _devices = [];
// //   final _deviceNameController = TextEditingController();
// //   final _deviceTopicController = TextEditingController();

// //   Map<int, String> _payloads = {};
// //   late MqttServerClient mqttClient;
// //   bool _isMqttConnected = false;

// //   @override
// //   void initState() {
// //     super.initState();
// //     fetchDevices();
// //     setupMqtt();
// //   }

// //   // ---------- MQTT setup ----------
// //   Future<void> setupMqtt() async {
// //     mqttClient = MqttServerClient('10.0.2.2', 'flutter_client_${DateTime.now().millisecondsSinceEpoch}');
// //     mqttClient.port = 1884;
// //     mqttClient.keepAlivePeriod = 20;
// //     mqttClient.logging(on: false);
// //     mqttClient.setProtocolV311();
// //     mqttClient.onConnected = () {
// //       debugPrint('✅ MQTT connected');
// //       setState(() => _isMqttConnected = true);
// //       mqttClient.subscribe('/sensor/led', MqttQos.atMostOnce);
// //     };
// //     mqttClient.onDisconnected = () {
// //       debugPrint('❌ MQTT disconnected');
// //       setState(() => _isMqttConnected = false);
// //     };

// //     try {
// //       await mqttClient.connect();
// //     } catch (e) {
// //       debugPrint('MQTT error: $e');
// //       mqttClient.disconnect();
// //       return;
// //     }

// //     mqttClient.updates?.listen((messages) {
// //       final recMsg = MqttPublishPayload.bytesToStringAsString(
// //         (messages[0].payload as MqttPublishMessage).payload.message,
// //       );
// //       debugPrint('📩 MQTT message: $recMsg');

// //       setState(() {
// //         _devices = _devices.map((d) => d.copyWith(status: recMsg)).toList();
// //         for (var d in _devices) {
// //           _payloads[d.id] = recMsg;
// //         }
// //       });
// //     });
// //   }

// //   // ---------- REST ----------
// //   Future<void> fetchDevices() async {
// //     final res = await http.get(Uri.parse('$_baseUrl/devices'));
// //     if (res.statusCode == 200) {
// //       final List list = json.decode(res.body);
// //       setState(() {
// //         _devices = list.map((e) => Device.fromJson(e)).toList();
// //         for (var d in _devices) {
// //           _payloads[d.id] = d.status;
// //         }
// //       });
// //     }
// //   }

// //   Future<void> createDevice() async {
// //     if (_deviceNameController.text.isEmpty || _deviceTopicController.text.isEmpty) return;
// //     final res = await http.post(
// //       Uri.parse('$_baseUrl/devices'),
// //       headers: {'Content-Type': 'application/json'},
// //       body: json.encode({
// //         'name': _deviceNameController.text,
// //         'topic': _deviceTopicController.text,
// //       }),
// //     );
// //     if (res.statusCode == 200 || res.statusCode == 201) {
// //       _deviceNameController.clear();
// //       _deviceTopicController.clear();
// //       fetchDevices();
// //     }
// //   }

// //   Future<void> controlDevice(int id) async {
// //     final payload = _payloads[id] ?? "LED_OFF";
// //     final res = await http.post(
// //       Uri.parse('$_baseUrl/devices/$id/control'),
// //       headers: {'Content-Type': 'text/plain'},
// //       body: payload,
// //     );
// //     if (res.statusCode == 200) {
// //       // ✅ publish ngay lên MQTT (đồng bộ real-time)
// //       if (_isMqttConnected) {
// //         final builder = MqttClientPayloadBuilder()..addString(payload);
// //         mqttClient.publishMessage('/sensor/led', MqttQos.atMostOnce, builder.payload!);
// //       }
// //       setState(() {
// //         _devices = _devices.map((d) => d.id == id ? d.copyWith(status: payload) : d).toList();
// //         _payloads[id] = payload;
// //       });
// //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đã gửi lệnh: $payload')));
// //     }
// //   }

// //   // ---------- UI ----------
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text('📡 IoT Device Controller'),
// //         centerTitle: true,
// //         backgroundColor: Colors.blueAccent,
// //       ),
// //       body: Padding(
// //         padding: const EdgeInsets.all(16),
// //         child: ListView(
// //           children: [
// //             Row(
// //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //               children: [
// //                 const Text('📋 Danh sách thiết bị',
// //                     style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
// //                 Row(
// //                   children: [
// //                     Icon(
// //                       _isMqttConnected ? Icons.wifi : Icons.wifi_off,
// //                       color: _isMqttConnected ? Colors.green : Colors.red,
// //                     ),
// //                     const SizedBox(width: 6),
// //                     Text(_isMqttConnected ? "MQTT OK" : "MQTT lỗi"),
// //                   ],
// //                 ),
// //               ],
// //             ),
// //             const SizedBox(height: 8),
// //             ..._devices.map((d) {
// //               final status = _payloads[d.id] ?? "LED_OFF";
// //               final color = status == "LED_ON" ? Colors.green.shade100 : Colors.red.shade100;
// //               return Card(
// //                 color: color,
// //                 child: Padding(
// //                   padding: const EdgeInsets.all(12),
// //                   child: Column(
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       Row(
// //                         children: [
// //                           Icon(Icons.memory,
// //                               color: status == "LED_ON" ? Colors.green : Colors.red),
// //                           const SizedBox(width: 8),
// //                           Expanded(
// //                             child: Column(
// //                               crossAxisAlignment: CrossAxisAlignment.start,
// //                               children: [
// //                                 Text(d.name,
// //                                     style: const TextStyle(
// //                                         fontSize: 16, fontWeight: FontWeight.bold)),
// //                                 Text("Topic: ${d.topic}", style: const TextStyle(fontSize: 12)),
// //                               ],
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                       const SizedBox(height: 10),
// //                       DropdownButtonFormField<String>(
// //                         value: _payloads[d.id],
// //                         decoration: const InputDecoration(
// //                           labelText: "Chọn lệnh điều khiển",
// //                           border: OutlineInputBorder(),
// //                         ),
// //                         items: const [
// //                           DropdownMenuItem(value: "LED_ON", child: Text("LED_ON")),
// //                           DropdownMenuItem(value: "LED_OFF", child: Text("LED_OFF")),
// //                         ],
// //                         // onChanged: (val) {
// //                         //   setState(() => _payloads[d.id] = val!);
// //                         // },
// //                         onChanged: (val) {
// //                           if (val == null) return;
// //                           setState(() {
// //                             _payloads[d.id] = val;

// //                             // ✅ Cập nhật luôn trạng thái thiết bị để đổi màu ngay lập tức
// //                             _devices = _devices.map((dev) {
// //                               if (dev.id == d.id) {
// //                                 return dev.copyWith(status: val);
// //                               }
// //                               return dev;
// //                             }).toList();
// //                           });
// //                         },
// //                       ),
// //                       const SizedBox(height: 12),
// //                       Align(
// //                         alignment: Alignment.centerRight,
// //                         child: Wrap(
// //                           spacing: 8,
// //                           children: [
// //                             ElevatedButton.icon(
// //                               onPressed: () => controlDevice(d.id),
// //                               icon: const Icon(Icons.send),
// //                               label: const Text("Gửi"),
// //                             ),
// //                             ElevatedButton.icon(
// //                               style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
// //                               onPressed: () {
// //                                 setState(() => _payloads[d.id] = "LED_ON");
// //                                 controlDevice(d.id);
// //                               },
// //                               icon: const Icon(Icons.lightbulb),
// //                               label: const Text("Bật LED"),
// //                             ),
// //                             ElevatedButton.icon(
// //                               style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
// //                               onPressed: () {
// //                                 setState(() => _payloads[d.id] = "LED_OFF");
// //                                 controlDevice(d.id);
// //                               },
// //                               icon: const Icon(Icons.lightbulb_outline),
// //                               label: const Text("Tắt LED"),
// //                             ),
// //                           ],
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //               );
// //             }),
// //             const Divider(thickness: 1),
// //             const SizedBox(height: 12),
// //             const Text('➕ Thêm thiết bị mới',
// //                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
// //             TextField(controller: _deviceNameController, decoration: const InputDecoration(labelText: 'Tên thiết bị')),
// //             TextField(controller: _deviceTopicController, decoration: const InputDecoration(labelText: 'Topic MQTT')),
// //             const SizedBox(height: 8),
// //             ElevatedButton(onPressed: createDevice, child: const Text('Tạo thiết bị')),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }

//   class _IoTDeviceDashboardState extends State<IoTDeviceDashboard> {
//     final _baseUrl = 'http://10.0.2.2:8080';
//     List<Device> _devices = [];
//     final _deviceNameController = TextEditingController();
//     final _deviceTopicController = TextEditingController();

//     Map<int, String> _payloads = {};
//     late MqttServerClient mqttClient;
//     bool _isMqttConnected = false;

//     // 🎙️ Speech to Text
//     final SpeechToText _speech = SpeechToText();
//     bool _isListening = false;
//     String _recognizedText = '';

//     @override
//     void initState() {
//       super.initState();
//       fetchDevices();
//       setupMqtt();
//     }

//     // ---------- MQTT setup ----------
//     Future<void> setupMqtt() async {
//       mqttClient = MqttServerClient('10.0.2.2', 'flutter_client_${DateTime.now().millisecondsSinceEpoch}');
//       mqttClient.port = 1884;
//       mqttClient.keepAlivePeriod = 20;
//       mqttClient.logging(on: false);
//       mqttClient.setProtocolV311();
//       mqttClient.onConnected = () {
//         debugPrint('✅ MQTT connected');
//         setState(() => _isMqttConnected = true);
//         mqttClient.subscribe('/sensor/led', MqttQos.atMostOnce);
//       };
//       mqttClient.onDisconnected = () {
//         debugPrint('❌ MQTT disconnected');
//         setState(() => _isMqttConnected = false);
//       };

//       try {
//         await mqttClient.connect();
//       } catch (e) {
//         debugPrint('MQTT error: $e');
//         mqttClient.disconnect();
//         return;
//       }

//       mqttClient.updates?.listen((messages) {
//         final recMsg = MqttPublishPayload.bytesToStringAsString(
//           (messages[0].payload as MqttPublishMessage).payload.message,
//         );
//         debugPrint('📩 MQTT message: $recMsg');

//         setState(() {
//           _devices = _devices.map((d) => d.copyWith(status: recMsg)).toList();
//           for (var d in _devices) {
//             _payloads[d.id] = recMsg;
//           }
//         });
//       });
//     }

//     // ---------- REST ----------
//     Future<void> fetchDevices() async {
//       final res = await http.get(Uri.parse('$_baseUrl/devices'));
//       if (res.statusCode == 200) {
//         final List list = json.decode(res.body);
//         setState(() {
//           _devices = list.map((e) => Device.fromJson(e)).toList();
//           for (var d in _devices) {
//             _payloads[d.id] = d.status;
//           }
//         });
//       }
//     }

//     Future<void> createDevice() async {
//       if (_deviceNameController.text.isEmpty || _deviceTopicController.text.isEmpty) return;
//       final res = await http.post(
//         Uri.parse('$_baseUrl/devices'),
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode({
//           'name': _deviceNameController.text,
//           'topic': _deviceTopicController.text,
//         }),
//       );
//       if (res.statusCode == 200 || res.statusCode == 201) {
//         _deviceNameController.clear();
//         _deviceTopicController.clear();
//         fetchDevices();
//       }
//     }

//     Future<void> controlDevice(int id, String payload) async {
//       final res = await http.post(
//         Uri.parse('$_baseUrl/devices/$id/control'),
//         headers: {'Content-Type': 'text/plain'},
//         body: payload,
//       );
//       if (res.statusCode == 200) {
//         if (_isMqttConnected) {
//           final builder = MqttClientPayloadBuilder()..addString(payload);
//           mqttClient.publishMessage('/sensor/led', MqttQos.atMostOnce, builder.payload!);
//         }
//         setState(() {
//           _devices = _devices.map((d) => d.id == id ? d.copyWith(status: payload) : d).toList();
//           _payloads[id] = payload;
//         });
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đã gửi lệnh: $payload')));
//       }
//     }

//     // ---------- 🎙️ Giọng nói ----------
//     // Future<void> toggleListening() async {
//     //   if (!_isListening) {
//     //     bool available = await _speech.initialize(
//     //       onStatus: (val) => debugPrint('🗣️ Status: $val'),
//     //       onError: (val) => debugPrint('❌ Error: $val'),
//     //     );
//     //     if (available) {
//     //       setState(() => _isListening = true);
//     //       _speech.listen(
//     //         localeId: 'vi_VN', // Tiếng Việt
//     //         onResult: (result) {
//     //           setState(() {
//     //             _recognizedText = result.recognizedWords;
//     //           });

//     //           if (result.finalResult) {
//     //             handleVoiceCommand(result.recognizedWords.toLowerCase());
//     //           }
//     //         },
//     //       );
//     //     }
//     //   } else {
//     //     setState(() => _isListening = false);
//     //     _speech.stop();
//     //   }
//     // }

//     // void handleVoiceCommand(String text) {
//     //   debugPrint('🎧 Voice command: $text');

//     //   if (_devices.isEmpty) return;
//     //   final id = _devices.first.id;

//     //   if (text.contains('bật') || text.contains('on')) {
//     //     controlDevice(id, 'LED_ON');
//     //   } else if (text.contains('tắt') || text.contains('off')) {
//     //     controlDevice(id, 'LED_OFF');
//     //   }

//     //   setState(() {
//     //     _isListening = false;
//     //   });
//     // }

//     Future<void> toggleListening() async {
//       if (!_isListening) {
//         bool available = await _speech.initialize(
//           onStatus: (val) => debugPrint('🗣️ Status: $val'),
//           onError: (val) => debugPrint('❌ Error: $val'),
//         );
//         if (available) {
//           setState(() => _isListening = true);
//           _speech.listen(
//             localeId: 'vi_VN',
//             listenMode: ListenMode.confirmation,
//             partialResults: true,
//             onResult: (result) {
//               final text = result.recognizedWords.toLowerCase();
//               setState(() {
//                 _recognizedText = text;
//               });

//               // 👉 Xử lý ngay khi nhận được (không cần đợi finalResult)
//               handleVoiceCommand(text);
//             },
//           );
//         }
//       } else {
//         _speech.stop();
//         setState(() => _isListening = false);
//       }
//     }

//     void handleVoiceCommand(String text) {
//       debugPrint('🎧 Voice command: $text');

//       if (_devices.isEmpty) return;
//       final id = _devices.first.id;

//       // 👉 Nhận dạng linh hoạt hơn
//       bool includeAny(String input, List<String> keywords) =>
//           keywords.any((k) => input.contains(k));

//       if (includeAny(text, ['bật', 'bat', 'on', 'mở', 'mo'])) {
//         controlDevice(id, 'LED_ON');
//         _speech.stop();
//         setState(() => _isListening = false);
//       } else if (includeAny(text, ['tắt', 'tat', 'off', 'đóng', 'dong'])) {
//         controlDevice(id, 'LED_OFF');
//         _speech.stop();
//         setState(() => _isListening = false);
//       }
//     }

//     // ---------- UI ----------
//     @override
//     Widget build(BuildContext context) {
//       return Scaffold(
//         appBar: AppBar(
//           title: const Text('📡 IoT Device Controller'),
//           centerTitle: true,
//           backgroundColor: Colors.blueAccent,
//           actions: [
//             IconButton(
//               icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
//               onPressed: toggleListening,
//             ),
//           ],
//         ),
//         body: Padding(
//           padding: const EdgeInsets.all(16),
//           child: ListView(
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text('📋 Danh sách thiết bị',
//                       style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//                   Icon(
//                     _isMqttConnected ? Icons.wifi : Icons.wifi_off,
//                     color: _isMqttConnected ? Colors.green : Colors.red,
//                   ),
//                 ],
//               ),
//               if (_recognizedText.isNotEmpty)
//                 Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 8.0),
//                   child: Text('🗣️ Nghe được: "$_recognizedText"',
//                       style: const TextStyle(fontStyle: FontStyle.italic)),
//                 ),
//               const SizedBox(height: 8),
//               ..._devices.map((d) {
//                 final status = _payloads[d.id] ?? "LED_OFF";
//                 final color = status == "LED_ON" ? Colors.green.shade100 : Colors.red.shade100;
//                 return Card(
//                   color: color,
//                   child: Padding(
//                     padding: const EdgeInsets.all(12),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text("${d.name} (${d.topic})", style: const TextStyle(fontWeight: FontWeight.bold)),
//                         const SizedBox(height: 8),
//                         DropdownButtonFormField<String>(
//                           value: _payloads[d.id],
//                           decoration: const InputDecoration(labelText: "Lệnh điều khiển"),
//                           items: const [
//                             DropdownMenuItem(value: "LED_ON", child: Text("LED_ON")),
//                             DropdownMenuItem(value: "LED_OFF", child: Text("LED_OFF")),
//                           ],
//                           onChanged: (val) {
//                             if (val != null) {
//                               setState(() => _payloads[d.id] = val);
//                               controlDevice(d.id, val);
//                             }
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               }),
//               const Divider(),
//               const Text('➕ Thêm thiết bị mới', style: TextStyle(fontWeight: FontWeight.bold)),
//               TextField(controller: _deviceNameController, decoration: const InputDecoration(labelText: 'Tên thiết bị')),
//               TextField(controller: _deviceTopicController, decoration: const InputDecoration(labelText: 'Topic MQTT')),
//               const SizedBox(height: 8),
//               ElevatedButton(onPressed: createDevice, child: const Text('Tạo thiết bị')),
//             ],
//           ),
//         ),
//       );
//     }
//   }

// // ---------- MODEL ----------
// class Device {
//   final int id;
//   final String name;
//   final String topic;
//   final String status;

//   Device({
//     required this.id,
//     required this.name,
//     required this.topic,
//     required this.status,
//   });

//   Device copyWith({String? status}) {
//     return Device(
//       id: id,
//       name: name,
//       topic: topic,
//       status: status ?? this.status,
//     );
//   }

//   factory Device.fromJson(Map<String, dynamic> json) {
//     return Device(
//       id: json['id'],
//       name: json['name'],
//       topic: json['topic'],
//       status: json['status'] ?? "LED_OFF",
//     );
//   }
// }


// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:mqtt_client/mqtt_client.dart';
// import 'package:mqtt_client/mqtt_server_client.dart';
// import 'package:speech_to_text/speech_to_text.dart';

// void main() => runApp(const MyApp());

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'IoT Device Controller',
//       home: const IoTDeviceDashboard(),
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }

// class IoTDeviceDashboard extends StatefulWidget {
//   const IoTDeviceDashboard({super.key});
//   @override
//   State<IoTDeviceDashboard> createState() => _IoTDeviceDashboardState();
// }

// class _IoTDeviceDashboardState extends State<IoTDeviceDashboard> {
//   final _baseUrl = 'http://10.0.2.2:8080';
//   List<Device> _devices = [];
//   final _deviceNameController = TextEditingController();
//   final _deviceTopicController = TextEditingController();
//   Map<int, String> _payloads = {};

//   late MqttServerClient mqttClient;
//   bool _isMqttConnected = false;

//   // 🎙️ Speech to Text
//   final SpeechToText _speech = SpeechToText();
//   bool _isListening = false;
//   int? _listeningDeviceId;
//   String _recognizedText = '';

//   @override
//   void initState() {
//     super.initState();
//     fetchDevices();
//     setupMqtt();
//   }

//   // ---------- MQTT setup ----------
//   Future<void> setupMqtt() async {
//     mqttClient = MqttServerClient(
//         '10.0.2.2', 'flutter_client_${DateTime.now().millisecondsSinceEpoch}');
//     mqttClient.port = 1884;
//     mqttClient.keepAlivePeriod = 20;
//     mqttClient.logging(on: false);
//     mqttClient.setProtocolV311();
//     mqttClient.onConnected = () {
//       debugPrint('✅ MQTT connected');
//       setState(() => _isMqttConnected = true);
//       mqttClient.subscribe('/sensor/led', MqttQos.atMostOnce);
//     };
//     mqttClient.onDisconnected = () {
//       debugPrint('❌ MQTT disconnected');
//       setState(() => _isMqttConnected = false);
//     };

//     try {
//       await mqttClient.connect();
//     } catch (e) {
//       debugPrint('MQTT error: $e');
//       mqttClient.disconnect();
//       return;
//     }

//     mqttClient.updates?.listen((messages) {
//       final recMsg = MqttPublishPayload.bytesToStringAsString(
//         (messages[0].payload as MqttPublishMessage).payload.message,
//       );
//       debugPrint('📩 MQTT message: $recMsg');
//       setState(() {
//         _devices =
//             _devices.map((d) => d.copyWith(status: recMsg)).toList();
//         for (var d in _devices) {
//           _payloads[d.id] = recMsg;
//         }
//       });
//     });
//   }

//   // ---------- REST ----------
//   Future<void> fetchDevices() async {
//     final res = await http.get(Uri.parse('$_baseUrl/devices'));
//     if (res.statusCode == 200) {
//       final List list = json.decode(res.body);
//       setState(() {
//         _devices = list.map((e) => Device.fromJson(e)).toList();
//         for (var d in _devices) {
//           _payloads[d.id] = d.status;
//         }
//       });
//     }
//   }

//   Future<void> createDevice() async {
//     if (_deviceNameController.text.isEmpty ||
//         _deviceTopicController.text.isEmpty) return;
//     final res = await http.post(
//       Uri.parse('$_baseUrl/devices'),
//       headers: {'Content-Type': 'application/json'},
//       body: json.encode({
//         'name': _deviceNameController.text,
//         'topic': _deviceTopicController.text,
//       }),
//     );
//     if (res.statusCode == 200 || res.statusCode == 201) {
//       _deviceNameController.clear();
//       _deviceTopicController.clear();
//       fetchDevices();
//     }
//   }

//   Future<void> controlDevice(int id, String payload) async {
//     final res = await http.post(
//       Uri.parse('$_baseUrl/devices/$id/control'),
//       headers: {'Content-Type': 'text/plain'},
//       body: payload,
//     );
//     if (res.statusCode == 200) {
//       if (_isMqttConnected) {
//         final builder = MqttClientPayloadBuilder()..addString(payload);
//         mqttClient.publishMessage('/sensor/led', MqttQos.atMostOnce, builder.payload!);
//       }
//       setState(() {
//         _devices = _devices.map((d) => d.id == id ? d.copyWith(status: payload) : d).toList();
//         _payloads[id] = payload;
//       });
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text('Đã gửi lệnh: $payload')));
//     }
//   }

//   // ---------- Voice per device ----------
//   Future<void> toggleListening(int deviceId) async {
//     if (!_isListening) {
//       bool available = await _speech.initialize(
//         onStatus: (val) => debugPrint('🗣️ Status: $val'),
//         onError: (val) => debugPrint('❌ Error: $val'),
//       );
//       if (available) {
//         setState(() {
//           _isListening = true;
//           _listeningDeviceId = deviceId;
//           _recognizedText = '';
//         });
//         _speech.listen(
//           localeId: 'vi_VN',
//           listenMode: ListenMode.confirmation,
//           partialResults: true,
//           onResult: (result) {
//             final text = result.recognizedWords.toLowerCase();
//             setState(() {
//               _recognizedText = text;
//             });
//             handleVoiceCommand(deviceId, text);
//           },
//         );
//       }
//     } else {
//       _speech.stop();
//       setState(() {
//         _isListening = false;
//         _listeningDeviceId = null;
//       });
//     }
//   }

//   void handleVoiceCommand(int deviceId, String text) {
//     bool includeAny(String input, List<String> keys) =>
//         keys.any((k) => input.contains(k));
//     if (includeAny(text, ['bật', 'bat', 'on', 'mở', 'mo'])) {
//       controlDevice(deviceId, 'LED_ON');
//       _speech.stop();
//       setState(() => _isListening = false);
//     } else if (includeAny(text, ['tắt', 'tat', 'off', 'đóng', 'dong'])) {
//       controlDevice(deviceId, 'LED_OFF');
//       _speech.stop();
//       setState(() => _isListening = false);
//     }
//   }

//   // ---------- UI ----------
//   // @override
//   // Widget build(BuildContext context) {
//   //   return Scaffold(
//   //     appBar: AppBar(
//   //       title: const Text('📡 IoT Device Controller'),
//   //       centerTitle: true,
//   //       backgroundColor: Colors.blueAccent,
//   //     ),
//   //     body: Padding(
//   //       padding: const EdgeInsets.all(16),
//   //       child: ListView(
//   //         children: [
//   //           Row(
//   //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//   //             children: [
//   //               const Text('📋 Danh sách thiết bị',
//   //                   style:
//   //                       TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//   //               Icon(
//   //                 _isMqttConnected ? Icons.wifi : Icons.wifi_off,
//   //                 color: _isMqttConnected ? Colors.green : Colors.red,
//   //               ),
//   //             ],
//   //           ),
//   //           if (_recognizedText.isNotEmpty)
//   //             Padding(
//   //               padding: const EdgeInsets.symmetric(vertical: 8),
//   //               child: Text('🗣️ Nghe được: "$_recognizedText"',
//   //                   style: const TextStyle(fontStyle: FontStyle.italic)),
//   //             ),
//   //           const SizedBox(height: 8),
//   //           ..._devices.map((d) {
//   //             final status = _payloads[d.id] ?? "LED_OFF";
//   //             final color = status == "LED_ON"
//   //                 ? Colors.green.shade100
//   //                 : Colors.red.shade100;
//   //             return Card(
//   //               color: color,
//   //               child: Padding(
//   //                 padding: const EdgeInsets.all(12),
//   //                 child: Column(
//   //                   crossAxisAlignment: CrossAxisAlignment.start,
//   //                   children: [
//   //                     Text("${d.name} (${d.topic})",
//   //                         style: const TextStyle(fontWeight: FontWeight.bold)),
//   //                     const SizedBox(height: 8),
//   //                     DropdownButtonFormField<String>(
//   //                       value: _payloads[d.id],
//   //                       decoration:
//   //                           const InputDecoration(labelText: "Lệnh điều khiển"),
//   //                       items: const [
//   //                         DropdownMenuItem(
//   //                             value: "LED_ON", child: Text("LED_ON")),
//   //                         DropdownMenuItem(
//   //                             value: "LED_OFF", child: Text("LED_OFF")),
//   //                       ],
//   //                       onChanged: (val) {
//   //                         if (val != null) setState(() => _payloads[d.id] = val);
//   //                       },
//   //                     ),
//   //                     const SizedBox(height: 8),
//   //                     Row(
//   //                       children: [
//   //                         ElevatedButton.icon(
//   //                           onPressed: () => controlDevice(
//   //                               d.id, _payloads[d.id] ?? "LED_OFF"),
//   //                           icon: const Icon(Icons.send),
//   //                           label: const Text("Gửi lệnh"),
//   //                         ),
//   //                         const SizedBox(width: 12),
//   //                         IconButton(
//   //                           icon: Icon(
//   //                             _isListening && _listeningDeviceId == d.id
//   //                                 ? Icons.mic
//   //                                 : Icons.mic_none,
//   //                             color: Colors.deepOrange,
//   //                           ),
//   //                           onPressed: () => toggleListening(d.id),
//   //                         ),
//   //                       ],
//   //                     ),
//   //                   ],
//   //                 ),
//   //               ),
//   //             );
//   //           }),
//   //           const Divider(),
//   //           const Text('➕ Thêm thiết bị mới',
//   //               style: TextStyle(fontWeight: FontWeight.bold)),
//   //           TextField(
//   //               controller: _deviceNameController,
//   //               decoration: const InputDecoration(labelText: 'Tên thiết bị')),
//   //           TextField(
//   //               controller: _deviceTopicController,
//   //               decoration: const InputDecoration(labelText: 'Topic MQTT')),
//   //           const SizedBox(height: 8),
//   //           ElevatedButton(
//   //               onPressed: createDevice, child: const Text('Tạo thiết bị')),
//   //         ],
//   //       ),
//   //     ),
//   //   );
//   // }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('📡 IoT Device Controller'),
//         centerTitle: true,
//         backgroundColor: Colors.blueAccent,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: ListView(
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text('📋 Danh sách thiết bị',
//                     style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//                 Icon(
//                   _isMqttConnected ? Icons.wifi : Icons.wifi_off,
//                   color: _isMqttConnected ? Colors.green : Colors.red,
//                 ),
//               ],
//             ),
//             if (_recognizedText.isNotEmpty)
//               Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 8),
//                 child: Text('🗣️ Nghe được: "$_recognizedText"',
//                     style: const TextStyle(fontStyle: FontStyle.italic)),
//               ),
//             const SizedBox(height: 8),

//             // 👉 Mỗi thiết bị hiển thị như "card web"
//             ..._devices.map((d) {
//               final status = _payloads[d.id] ?? "LED_OFF";
//               final isOn = status == "LED_ON";
//               final bgColor = isOn ? Colors.green.shade50 : Colors.red.shade50;

//               return Container(
//                 margin: const EdgeInsets.symmetric(vertical: 8),
//                 decoration: BoxDecoration(
//                   color: bgColor,
//                   borderRadius: BorderRadius.circular(12),
//                   boxShadow: [
//                     BoxShadow(
//                         color: Colors.grey.shade300,
//                         blurRadius: 4,
//                         offset: const Offset(2, 2))
//                   ],
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(12),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Tiêu đề + Mic
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 d.name,
//                                 style: const TextStyle(
//                                     fontWeight: FontWeight.bold, fontSize: 16),
//                               ),
//                               Text("Topic: ${d.topic}",
//                                   style: const TextStyle(color: Colors.black54)),
//                             ],
//                           ),
//                           IconButton(
//                             icon: Icon(
//                               _isListening && _listeningDeviceId == d.id
//                                   ? Icons.mic
//                                   : Icons.mic_none,
//                               color: Colors.deepOrange,
//                               size: 28,
//                             ),
//                             onPressed: () => toggleListening(d.id),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 8),

//                       // Dropdown lệnh
//                       DropdownButtonFormField<String>(
//                         value: _payloads[d.id],
//                         decoration: const InputDecoration(
//                           labelText: "Lệnh điều khiển",
//                           border: OutlineInputBorder(),
//                           isDense: true,
//                         ),
//                         items: const [
//                           DropdownMenuItem(
//                               value: "LED_ON", child: Text("LED_ON")),
//                           DropdownMenuItem(
//                               value: "LED_OFF", child: Text("LED_OFF")),
//                         ],
//                         onChanged: (val) {
//                           if (val != null) setState(() => _payloads[d.id] = val);
//                         },
//                       ),
//                       const SizedBox(height: 10),

//                       // Hàng nút Gửi / Bật / Tắt
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                         children: [
//                           ElevatedButton.icon(
//                             style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.blue),
//                             onPressed: () => controlDevice(
//                                 d.id, _payloads[d.id] ?? "LED_OFF"),
//                             icon: const Icon(Icons.send),
//                             label: const Text("GỬI"),
//                           ),
//                           ElevatedButton(
//                             style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.green),
//                             onPressed: () => controlDevice(d.id, "LED_ON"),
//                             child: const Text("BẬT"),
//                           ),
//                           ElevatedButton(
//                             style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.red),
//                             onPressed: () => controlDevice(d.id, "LED_OFF"),
//                             child: const Text("TẮT"),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             }),

//             const Divider(),
//             const Text('➕ Thêm thiết bị mới',
//                 style: TextStyle(fontWeight: FontWeight.bold)),
//             TextField(
//                 controller: _deviceNameController,
//                 decoration: const InputDecoration(labelText: 'Tên thiết bị')),
//             TextField(
//                 controller: _deviceTopicController,
//                 decoration: const InputDecoration(labelText: 'Topic MQTT')),
//             const SizedBox(height: 8),
//             ElevatedButton(
//                 onPressed: createDevice, child: const Text('Tạo thiết bị')),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ---------- MODEL ----------
// class Device {
//   final int id;
//   final String name;
//   final String topic;
//   final String status;

//   Device({
//     required this.id,
//     required this.name,
//     required this.topic,
//     required this.status,
//   });

//   Device copyWith({String? status}) {
//     return Device(
//       id: id,
//       name: name,
//       topic: topic,
//       status: status ?? this.status,
//     );
//   }

//   factory Device.fromJson(Map<String, dynamic> json) {
//     return Device(
//       id: json['id'],
//       name: json['name'],
//       topic: json['topic'],
//       status: json['status'] ?? "LED_OFF",
//     );
//   }
// }


// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:mqtt_client/mqtt_client.dart';
// import 'package:mqtt_client/mqtt_server_client.dart';
// import 'package:speech_to_text/speech_to_text.dart';

// void main() => runApp(const MyApp());

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'IoT Device Controller',
//       home: const IoTDeviceDashboard(),
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }

// class IoTDeviceDashboard extends StatefulWidget {
//   const IoTDeviceDashboard({super.key});
//   @override
//   State<IoTDeviceDashboard> createState() => _IoTDeviceDashboardState();
// }

// class _IoTDeviceDashboardState extends State<IoTDeviceDashboard> {
//   final _baseUrl = 'http://10.0.2.2:8080';
//   List<Device> _devices = [];
//   final _deviceNameController = TextEditingController();
//   final _deviceTopicController = TextEditingController();
//   Map<int, String> _payloads = {};

//   late MqttServerClient mqttClient;
//   bool _isMqttConnected = false;

//   // 🎙️ Speech to Text
//   final SpeechToText _speech = SpeechToText();
//   bool _isListening = false;
//   int? _listeningDeviceId;
//   String _recognizedText = '';

//   @override
//   void initState() {
//     super.initState();
//     fetchDevices();
//     setupMqtt();
//   }

//   // ---------- MQTT setup ----------
//   Future<void> setupMqtt() async {
//     mqttClient = MqttServerClient(
//       '10.0.2.2', 'flutter_client_${DateTime.now().millisecondsSinceEpoch}');
//     mqttClient.port = 1884;
//     mqttClient.keepAlivePeriod = 20;
//     mqttClient.logging(on: false);
//     mqttClient.setProtocolV311();

//     mqttClient.onConnected = () {
//       debugPrint('✅ MQTT connected');
//       setState(() => _isMqttConnected = true);

//       // 🔸 Sub tất cả topic trong danh sách có sẵn
//       for (var d in _devices) {
//         mqttClient.subscribe(d.topic, MqttQos.atMostOnce);
//         debugPrint('🔔 Subscribed: ${d.topic}');
//       }

//       // Hoặc đơn giản hơn: mqttClient.subscribe('/sensor/#', MqttQos.atMostOnce);
//     };

//     mqttClient.onDisconnected = () {
//       debugPrint('❌ MQTT disconnected');
//       setState(() => _isMqttConnected = false);
//     };

//     try {
//       await mqttClient.connect();
//     } catch (e) {
//       debugPrint('MQTT connect error: $e');
//       mqttClient.disconnect();
//       return;
//     }

//     mqttClient.updates?.listen((messages) {
//       final msg = messages[0].payload as MqttPublishMessage;
//       final topic = messages[0].topic;
//       final payload =
//           MqttPublishPayload.bytesToStringAsString(msg.payload.message);
//       debugPrint('📩 [$topic] $payload');

//       // Tìm thiết bị có topic khớp
//       final target = _devices.firstWhere(
//         (d) => d.topic == topic,
//         orElse: () => Device(id: -1, name: '', topic: '', status: ''),
//       );
//       if (target.id == -1) return; // Không khớp thiết bị nào

//       // Cập nhật trạng thái chỉ thiết bị đó
//       setState(() {
//         _devices = _devices.map((d) {
//           if (d.topic == topic) return d.copyWith(status: payload);
//           return d;
//         }).toList();
//         _payloads[target.id] = payload;
//       });
//     });
//   }

//   // ---------- REST ----------
//   Future<void> fetchDevices() async {
//     final res = await http.get(Uri.parse('$_baseUrl/devices'));
//     if (res.statusCode == 200) {
//       final List list = json.decode(res.body);
//       setState(() {
//         _devices = list.map((e) => Device.fromJson(e)).toList();
//         for (var d in _devices) {
//           _payloads[d.id] = d.status;
//         }
//       });

//       // 🔸 Nếu MQTT đang kết nối → đăng ký topic mới
//       if (_isMqttConnected) {
//         for (var d in _devices) {
//           mqttClient.subscribe(d.topic, MqttQos.atMostOnce);
//         }
//       }
//     } else {
//       debugPrint('Fetch devices error: ${res.statusCode}');
//     }
//   }

//   Future<void> createDevice() async {
//     if (_deviceNameController.text.isEmpty ||
//         _deviceTopicController.text.isEmpty) return;

//     final res = await http.post(
//       Uri.parse('$_baseUrl/devices'),
//       headers: {'Content-Type': 'application/json'},
//       body: json.encode({
//         'name': _deviceNameController.text,
//         'topic': _deviceTopicController.text,
//       }),
//     );

//     if (res.statusCode == 200 || res.statusCode == 201) {
//       _deviceNameController.clear();
//       _deviceTopicController.clear();
//       fetchDevices();
//       ScaffoldMessenger.of(context)
//           .showSnackBar(const SnackBar(content: Text('✅ Thêm thiết bị thành công')));
//     } else {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(const SnackBar(content: Text('❌ Lỗi tạo thiết bị')));
//     }
//   }

//   Future<void> controlDevice(int id, String payload) async {
//     final device = _devices.firstWhere((d) => d.id == id);
//     final res = await http.post(
//       Uri.parse('$_baseUrl/devices/$id/control'),
//       headers: {'Content-Type': 'text/plain'},
//       body: payload,
//     );

//     if (res.statusCode == 200) {
//       // 🔸 Publish ra MQTT topic tương ứng
//       if (_isMqttConnected) {
//         final builder = MqttClientPayloadBuilder()..addString(payload);
//         mqttClient.publishMessage(
//             device.topic, MqttQos.atMostOnce, builder.payload!);
//       }

//       setState(() {
//         _devices = _devices.map((d) {
//           if (d.id == id) return d.copyWith(status: payload);
//           return d;
//         }).toList();
//         _payloads[id] = payload;
//       });

//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text('Đã gửi lệnh: $payload')));
//     } else {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(const SnackBar(content: Text('❌ Gửi lệnh thất bại')));
//     }
//   }

//   // ---------- Voice ----------
//   Future<void> toggleListening(int deviceId) async {
//     if (!_isListening) {
//       bool available = await _speech.initialize(
//         onStatus: (val) => debugPrint('🗣️ Status: $val'),
//         onError: (val) => debugPrint('❌ Error: $val'),
//       );
//       if (available) {
//         setState(() {
//           _isListening = true;
//           _listeningDeviceId = deviceId;
//           _recognizedText = '';
//         });
//         _speech.listen(
//           localeId: 'vi_VN',
//           listenMode: ListenMode.confirmation,
//           partialResults: true,
//           onResult: (result) {
//             final text = result.recognizedWords.toLowerCase();
//             setState(() => _recognizedText = text);
//             handleVoiceCommand(deviceId, text);
//           },
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Trình duyệt không hỗ trợ giọng nói')));
//       }
//     } else {
//       _speech.stop();
//       setState(() {
//         _isListening = false;
//         _listeningDeviceId = null;
//       });
//     }
//   }

//   void handleVoiceCommand(int deviceId, String text) {
//     bool includeAny(String input, List<String> keys) =>
//         keys.any((k) => input.contains(k));

//     if (includeAny(text, ['bật', 'bat', 'on', 'mở', 'mo'])) {
//       controlDevice(deviceId, 'LED_ON');
//       _speech.stop();
//       setState(() => _isListening = false);
//     } else if (includeAny(text, ['tắt', 'tat', 'off', 'đóng', 'dong'])) {
//       controlDevice(deviceId, 'LED_OFF');
//       _speech.stop();
//       setState(() => _isListening = false);
//     }
//   }

//   // ---------- UI ----------
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('📡 IoT Device Controller'),
//         centerTitle: true,
//         backgroundColor: Colors.blueAccent,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: ListView(
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text('📋 Danh sách thiết bị',
//                     style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//                 Icon(
//                   _isMqttConnected ? Icons.wifi : Icons.wifi_off,
//                   color: _isMqttConnected ? Colors.green : Colors.red,
//                 ),
//               ],
//             ),
//             if (_recognizedText.isNotEmpty)
//               Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 8),
//                 child: Text('🗣️ Nghe được: "$_recognizedText"',
//                     style: const TextStyle(fontStyle: FontStyle.italic)),
//               ),
//             const SizedBox(height: 8),

//             // 👉 Mỗi thiết bị hiển thị như card web
//             ..._devices.map((d) {
//               final status = _payloads[d.id] ?? "LED_OFF";
//               final isOn = status == "LED_ON";
//               final bgColor = isOn ? Colors.green.shade50 : Colors.red.shade50;

//               return Container(
//                 margin: const EdgeInsets.symmetric(vertical: 8),
//                 decoration: BoxDecoration(
//                   color: bgColor,
//                   borderRadius: BorderRadius.circular(12),
//                   boxShadow: [
//                     BoxShadow(
//                         color: Colors.grey.shade300,
//                         blurRadius: 4,
//                         offset: const Offset(2, 2))
//                   ],
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(12),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Header + mic
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 d.name,
//                                 style: const TextStyle(
//                                     fontWeight: FontWeight.bold, fontSize: 16),
//                               ),
//                               Text("Topic: ${d.topic}",
//                                   style: const TextStyle(color: Colors.black54)),
//                             ],
//                           ),
//                           IconButton(
//                             icon: Icon(
//                               _isListening && _listeningDeviceId == d.id
//                                   ? Icons.mic
//                                   : Icons.mic_none,
//                               color: Colors.deepOrange,
//                               size: 28,
//                             ),
//                             onPressed: () => toggleListening(d.id),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 8),

//                       // Dropdown
//                       DropdownButtonFormField<String>(
//                         value: _payloads[d.id],
//                         decoration: const InputDecoration(
//                           labelText: "Lệnh điều khiển",
//                           border: OutlineInputBorder(),
//                           isDense: true,
//                         ),
//                         items: const [
//                           DropdownMenuItem(
//                               value: "LED_ON", child: Text("LED_ON")),
//                           DropdownMenuItem(
//                               value: "LED_OFF", child: Text("LED_OFF")),
//                         ],
//                         onChanged: (val) {
//                           if (val != null) setState(() => _payloads[d.id] = val);
//                         },
//                       ),
//                       const SizedBox(height: 10),

//                       // Buttons
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                         children: [
//                           ElevatedButton.icon(
//                             style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.blue),
//                             onPressed: () => controlDevice(
//                                 d.id, _payloads[d.id] ?? "LED_OFF"),
//                             icon: const Icon(Icons.send),
//                             label: const Text("GỬI"),
//                           ),
//                           ElevatedButton(
//                             style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.green),
//                             onPressed: () => controlDevice(d.id, "LED_ON"),
//                             child: const Text("BẬT"),
//                           ),
//                           ElevatedButton(
//                             style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.red),
//                             onPressed: () => controlDevice(d.id, "LED_OFF"),
//                             child: const Text("TẮT"),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             }),

//             const Divider(),
//             const Text('➕ Thêm thiết bị mới',
//                 style: TextStyle(fontWeight: FontWeight.bold)),
//             TextField(
//                 controller: _deviceNameController,
//                 decoration: const InputDecoration(labelText: 'Tên thiết bị')),
//             TextField(
//                 controller: _deviceTopicController,
//                 decoration: const InputDecoration(labelText: 'Topic MQTT')),
//             const SizedBox(height: 8),
//             ElevatedButton(
//                 onPressed: createDevice, child: const Text('Tạo thiết bị')),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ---------- MODEL ----------
// class Device {
//   final int id;
//   final String name;
//   final String topic;
//   final String status;

//   Device({
//     required this.id,
//     required this.name,
//     required this.topic,
//     required this.status,
//   });

//   Device copyWith({String? status}) {
//     return Device(
//       id: id,
//       name: name,
//       topic: topic,
//       status: status ?? this.status,
//     );
//   }

//   factory Device.fromJson(Map<String, dynamic> json) {
//     return Device(
//       id: json['id'],
//       name: json['name'],
//       topic: json['topic'],
//       status: json['status'] ?? "LED_OFF",
//     );
//   }
// }


// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:mqtt_client/mqtt_client.dart';
// import 'package:mqtt_client/mqtt_server_client.dart';
// import 'package:speech_to_text/speech_to_text.dart';

// void main() => runApp(const MyApp());

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'IoT Device Controller',
//       home: const IoTDeviceDashboard(),
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }

// class IoTDeviceDashboard extends StatefulWidget {
//   const IoTDeviceDashboard({super.key});
//   @override
//   State<IoTDeviceDashboard> createState() => _IoTDeviceDashboardState();
// }

// class _IoTDeviceDashboardState extends State<IoTDeviceDashboard> {
//   final _baseUrl = 'http://10.0.2.2:8080';
//   List<Device> _devices = [];
//   final _deviceNameController = TextEditingController();
//   final _deviceTopicController = TextEditingController();
//   Map<int, String> _payloads = {};

//   late MqttServerClient mqttClient;
//   bool _isMqttConnected = false;

//   // 🎙️ Speech to Text
//   final SpeechToText _speech = SpeechToText();
//   bool _isListening = false;
//   int? _listeningDeviceId;
//   String _recognizedText = '';

//   @override
//   void initState() {
//     super.initState();
//     setupMqtt().then((_) => fetchDevices());
//   }

//   // ---------- MQTT setup ----------
//   Future<void> setupMqtt() async {
//     mqttClient = MqttServerClient(
//         '10.0.2.2', 'flutter_client_${DateTime.now().millisecondsSinceEpoch}');
//     mqttClient.port = 1884;
//     mqttClient.keepAlivePeriod = 20;
//     mqttClient.logging(on: false);
//     mqttClient.setProtocolV311();

//     mqttClient.onConnected = () {
//       debugPrint('✅ MQTT connected');
//       setState(() => _isMqttConnected = true);

//       // Sub tất cả topic thiết bị hiện có
//       for (var d in _devices) {
//         mqttClient.subscribe(d.topic, MqttQos.atMostOnce);
//       }

//       // 🔸 Sub topic chung báo có thay đổi danh sách thiết bị
//       mqttClient.subscribe('/devices/update', MqttQos.atMostOnce);
//     };

//     mqttClient.onDisconnected = () {
//       debugPrint('❌ MQTT disconnected');
//       setState(() => _isMqttConnected = false);
//     };

//     try {
//       await mqttClient.connect();
//     } catch (e) {
//       debugPrint('MQTT connect error: $e');
//       mqttClient.disconnect();
//       return;
//     }

//     mqttClient.updates?.listen((messages) async {
//       final msg = messages[0].payload as MqttPublishMessage;
//       final topic = messages[0].topic;
//       final payload =
//           MqttPublishPayload.bytesToStringAsString(msg.payload.message);
//       debugPrint('📩 [$topic] $payload');

//       // Nếu là topic thông báo cập nhật danh sách thiết bị
//       if (topic == '/devices/update') {
//         debugPrint('🔁 Danh sách thiết bị thay đổi → reload...');
//         await fetchDevices();
//         return;
//       }

//       // Tìm thiết bị có topic khớp
//       final target = _devices.firstWhere(
//         (d) => d.topic == topic,
//         orElse: () => Device(id: -1, name: '', topic: '', status: ''),
//       );
//       if (target.id == -1) return;

//       // Cập nhật trạng thái thiết bị
//       setState(() {
//         _devices = _devices.map((d) {
//           if (d.topic == topic) return d.copyWith(status: payload);
//           return d;
//         }).toList();
//         _payloads[target.id] = payload;
//       });
//     });
//   }

//   // ---------- REST ----------
//   Future<void> fetchDevices() async {
//     final res = await http.get(Uri.parse('$_baseUrl/devices'));
//     if (res.statusCode == 200) {
//       final List list = json.decode(res.body);
//       setState(() {
//         _devices = list.map((e) => Device.fromJson(e)).toList();
//         for (var d in _devices) {
//           _payloads[d.id] = d.status;
//         }
//       });

//       // Sub topic mới nếu có
//       if (_isMqttConnected) {
//         for (var d in _devices) {
//           mqttClient.subscribe(d.topic, MqttQos.atMostOnce);
//         }
//       }
//     } else {
//       debugPrint('Fetch devices error: ${res.statusCode}');
//     }
//   }

//   Future<void> createDevice() async {
//     if (_deviceNameController.text.isEmpty ||
//         _deviceTopicController.text.isEmpty) return;

//     final res = await http.post(
//       Uri.parse('$_baseUrl/devices'),
//       headers: {'Content-Type': 'application/json'},
//       body: json.encode({
//         'name': _deviceNameController.text,
//         'topic': _deviceTopicController.text,
//       }),
//     );

//     if (res.statusCode == 200 || res.statusCode == 201) {
//       _deviceNameController.clear();
//       _deviceTopicController.clear();
//       await fetchDevices();

//       // 🔸 Sau khi thêm → publish tín hiệu MQTT để app/web khác reload
//       // if (_isMqttConnected) {
//       //   final builder = MqttClientPayloadBuilder()..addString('refresh');
//       //   mqttClient.publishMessage(
//       //       '/devices/update', MqttQos.atMostOnce, builder.payload!);
//       // }

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('✅ Thêm thiết bị thành công')),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('❌ Lỗi tạo thiết bị')),
//       );
//     }
//   }

//   Future<void> controlDevice(int id, String payload) async {
//     final device = _devices.firstWhere((d) => d.id == id);
//     final res = await http.post(
//       Uri.parse('$_baseUrl/devices/$id/control'),
//       headers: {'Content-Type': 'text/plain'},
//       body: payload,
//     );

//     if (res.statusCode == 200) {
//       if (_isMqttConnected) {
//         final builder = MqttClientPayloadBuilder()..addString(payload);
//         mqttClient.publishMessage(
//             device.topic, MqttQos.atMostOnce, builder.payload!);
//       }

//       setState(() {
//         _devices = _devices.map((d) {
//           if (d.id == id) return d.copyWith(status: payload);
//           return d;
//         }).toList();
//         _payloads[id] = payload;
//       });

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Đã gửi lệnh: $payload')),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('❌ Gửi lệnh thất bại')),
//       );
//     }
//   }

//   // ---------- Voice ----------
//   Future<void> toggleListening(int deviceId) async {
//     if (!_isListening) {
//       bool available = await _speech.initialize(
//         onStatus: (val) => debugPrint('🗣️ Status: $val'),
//         onError: (val) => debugPrint('❌ Error: $val'),
//       );
//       if (available) {
//         setState(() {
//           _isListening = true;
//           _listeningDeviceId = deviceId;
//           _recognizedText = '';
//         });
//         _speech.listen(
//           localeId: 'vi_VN',
//           listenMode: ListenMode.confirmation,
//           partialResults: true,
//           onResult: (result) {
//             final text = result.recognizedWords.toLowerCase();
//             setState(() => _recognizedText = text);
//             handleVoiceCommand(deviceId, text);
//           },
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Không hỗ trợ giọng nói')),
//         );
//       }
//     } else {
//       _speech.stop();
//       setState(() {
//         _isListening = false;
//         _listeningDeviceId = null;
//       });
//     }
//   }

//   void handleVoiceCommand(int deviceId, String text) {
//     bool includeAny(String input, List<String> keys) =>
//         keys.any((k) => input.contains(k));

//     if (includeAny(text, ['bật', 'bat', 'on', 'mở', 'mo'])) {
//       controlDevice(deviceId, 'LED_ON');
//       _speech.stop();
//       setState(() => _isListening = false);
//     } else if (includeAny(text, ['tắt', 'tat', 'off', 'đóng', 'dong'])) {
//       controlDevice(deviceId, 'LED_OFF');
//       _speech.stop();
//       setState(() => _isListening = false);
//     }
//   }

//   // ---------- UI ----------
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('📡 IoT Device Controller'),
//         centerTitle: true,
//         backgroundColor: Colors.blueAccent,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: ListView(
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text(
//                   '📋 Danh sách thiết bị',
//                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                 ),
//                 Icon(
//                   _isMqttConnected ? Icons.wifi : Icons.wifi_off,
//                   color: _isMqttConnected ? Colors.green : Colors.red,
//                 ),
//               ],
//             ),
//             if (_recognizedText.isNotEmpty)
//               Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 8),
//                 child: Text(
//                   '🗣️ Nghe được: "$_recognizedText"',
//                   style: const TextStyle(fontStyle: FontStyle.italic),
//                 ),
//               ),
//             const SizedBox(height: 8),

//             // 👉 Mỗi thiết bị hiển thị như card
//             ..._devices.map((d) {
//               final status = _payloads[d.id] ?? "LED_OFF";
//               final isOn = status == "LED_ON";
//               final bgColor = isOn ? Colors.green.shade50 : Colors.red.shade50;

//               return Container(
//                 margin: const EdgeInsets.symmetric(vertical: 8),
//                 decoration: BoxDecoration(
//                   color: bgColor,
//                   borderRadius: BorderRadius.circular(12),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.grey.shade300,
//                       blurRadius: 4,
//                       offset: const Offset(2, 2),
//                     )
//                   ],
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(12),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Header
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 d.name,
//                                 style: const TextStyle(
//                                     fontWeight: FontWeight.bold, fontSize: 16),
//                               ),
//                               Text("Topic: ${d.topic}",
//                                   style: const TextStyle(color: Colors.black54)),
//                             ],
//                           ),
//                           IconButton(
//                             icon: Icon(
//                               _isListening && _listeningDeviceId == d.id
//                                   ? Icons.mic
//                                   : Icons.mic_none,
//                               color: Colors.deepOrange,
//                               size: 28,
//                             ),
//                             onPressed: () => toggleListening(d.id),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 8),
//                       DropdownButtonFormField<String>(
//                         value: _payloads[d.id],
//                         decoration: const InputDecoration(
//                           labelText: "Lệnh điều khiển",
//                           border: OutlineInputBorder(),
//                           isDense: true,
//                         ),
//                         items: const [
//                           DropdownMenuItem(
//                               value: "LED_ON", child: Text("LED_ON")),
//                           DropdownMenuItem(
//                               value: "LED_OFF", child: Text("LED_OFF")),
//                         ],
//                         onChanged: (val) {
//                           if (val != null) setState(() => _payloads[d.id] = val);
//                         },
//                       ),
//                       const SizedBox(height: 10),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                         children: [
//                           ElevatedButton.icon(
//                             style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.blue),
//                             onPressed: () => controlDevice(
//                                 d.id, _payloads[d.id] ?? "LED_OFF"),
//                             icon: const Icon(Icons.send),
//                             label: const Text("GỬI"),
//                           ),
//                           ElevatedButton(
//                             style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.green),
//                             onPressed: () => controlDevice(d.id, "LED_ON"),
//                             child: const Text("BẬT"),
//                           ),
//                           ElevatedButton(
//                             style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.red),
//                             onPressed: () => controlDevice(d.id, "LED_OFF"),
//                             child: const Text("TẮT"),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             }),

//             const Divider(),
//             const Text(
//               '➕ Thêm thiết bị mới',
//               style: TextStyle(fontWeight: FontWeight.bold),
//             ),
//             TextField(
//               controller: _deviceNameController,
//               decoration:
//                   const InputDecoration(labelText: 'Tên thiết bị'),
//             ),
//             TextField(
//               controller: _deviceTopicController,
//               decoration:
//                   const InputDecoration(labelText: 'Topic MQTT'),
//             ),
//             const SizedBox(height: 8),
//             ElevatedButton(
//               onPressed: createDevice,
//               child: const Text('Tạo thiết bị'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ---------- MODEL ----------
// class Device {
//   final int id;
//   final String name;
//   final String topic;
//   final String status;

//   Device({
//     required this.id,
//     required this.name,
//     required this.topic,
//     required this.status,
//   });

//   Device copyWith({String? status}) {
//     return Device(
//       id: id,
//       name: name,
//       topic: topic,
//       status: status ?? this.status,
//     );
//   }

//   factory Device.fromJson(Map<String, dynamic> json) {
//     return Device(
//       id: json['id'],
//       name: json['name'],
//       topic: json['topic'],
//       status: json['status'] ?? "LED_OFF",
//     );
//   }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:speech_to_text/speech_to_text.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IoT Device Controller',
      home: const IoTDeviceDashboard(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class IoTDeviceDashboard extends StatefulWidget {
  const IoTDeviceDashboard({super.key});
  @override
  State<IoTDeviceDashboard> createState() => _IoTDeviceDashboardState();
}

class _IoTDeviceDashboardState extends State<IoTDeviceDashboard> {
  final _baseUrl = 'http://10.0.2.2:8080';
  List<Device> _devices = [];
  final _deviceNameController = TextEditingController();
  final _deviceTopicController = TextEditingController();
  Map<int, String> _payloads = {};

  late MqttServerClient mqttClient;
  bool _isMqttConnected = false;

  // 🎙️ Speech to Text
  final SpeechToText _speech = SpeechToText();
  bool _isListening = false;
  int? _listeningDeviceId;
  String _recognizedText = '';

  @override
  void initState() {
    super.initState();
    setupMqtt().then((_) => fetchDevices());
  }

  // ---------- MQTT setup ----------
  Future<void> setupMqtt() async {
    mqttClient = MqttServerClient(
        '10.0.2.2', 'flutter_client_${DateTime.now().millisecondsSinceEpoch}');
    // mqttClient.port = 1883;
    // mqttClient = MqttServerClient.withPort('10.0.2.2', 'flutter_client', 9001);
    mqttClient.port = 1884;
    mqttClient.keepAlivePeriod = 20;
    mqttClient.logging(on: false);
    mqttClient.setProtocolV311();
    // mqttClient.useWebSocket = false;

    mqttClient.onConnected = () {
      debugPrint('✅ MQTT connected');
      setState(() => _isMqttConnected = true);

      // Sub tất cả topic thiết bị hiện có
      for (var d in _devices) {
        mqttClient.subscribe(d.topic, MqttQos.atMostOnce);
      }
      mqttClient.subscribe('/devices/update', MqttQos.atMostOnce);
    };

    mqttClient.onDisconnected = () {
      debugPrint('❌ MQTT disconnected');
      setState(() => _isMqttConnected = false);
    };

    try {
      await mqttClient.connect();
    } catch (e) {
      debugPrint('MQTT connect error: $e');
      mqttClient.disconnect();
      return;
    }

    mqttClient.updates?.listen((messages) async {
      final msg = messages[0].payload as MqttPublishMessage;
      final topic = messages[0].topic;
      final payload =
          MqttPublishPayload.bytesToStringAsString(msg.payload.message);
      debugPrint('📩 [$topic] $payload');

      if (topic == '/devices/update') {
        debugPrint('🔁 Danh sách thiết bị thay đổi → reload...');
        await fetchDevices();
        return;
      }

      final target = _devices.firstWhere(
        (d) => d.topic == topic,
        orElse: () => Device(id: -1, name: '', topic: '', status: ''),
      );
      if (target.id == -1) return;

      setState(() {
        _devices = _devices.map((d) {
          if (d.topic == topic) return d.copyWith(status: payload);
          return d;
        }).toList();
        _payloads[target.id] = payload;
      });
    });
  }

  // ---------- REST ----------
  // Future<void> fetchDevices() async {
  //   final res = await http.get(Uri.parse('$_baseUrl/devices'));
  //   if (res.statusCode == 200) {
  //     final List list = json.decode(res.body);
  //     setState(() {
  //       _devices = list.map((e) => Device.fromJson(e)).toList();
  //       for (var d in _devices) {
  //         _payloads[d.id] = d.status;
  //       }
  //     });

  //     // Sub các topic mới
  //     if (_isMqttConnected) {
  //       for (var d in _devices) {
  //         mqttClient.subscribe(d.topic, MqttQos.atMostOnce);
  //       }
  //     }
  //   } else {
  //     debugPrint('Fetch devices error: ${res.statusCode}');
  //   }
  // }
  Future<void> fetchDevices() async {
    final res = await http.get(Uri.parse('$_baseUrl/devices'));
    if (res.statusCode == 200) {
      final List list = json.decode(res.body);
      setState(() {
        _devices = list.map((e) => Device.fromJson(e)).toList();
        for (var d in _devices) {
          _payloads[d.id] = d.status;
        }
      });

      // 🔹 Đảm bảo sub lại tất cả sau khi fetch thành công
      if (_isMqttConnected) {
        mqttClient.subscribe('/devices/update', MqttQos.atMostOnce); // thêm dòng này
        for (var d in _devices) {
          mqttClient.subscribe(d.topic, MqttQos.atMostOnce);
        }
      }
    } else {
      debugPrint('Fetch devices error: ${res.statusCode}');
    }
  }

  Future<void> createDevice() async {
    if (_deviceNameController.text.isEmpty ||
        _deviceTopicController.text.isEmpty) return;

    final res = await http.post(
      Uri.parse('$_baseUrl/devices'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': _deviceNameController.text,
        'topic': _deviceTopicController.text,
      }),
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      _deviceNameController.clear();
      _deviceTopicController.clear();

      await fetchDevices();

      // ✅ Gửi thông báo MQTT để tất cả client reload
      if (_isMqttConnected) {
        final builder = MqttClientPayloadBuilder()..addString('refresh');
        mqttClient.publishMessage(
            '/devices/update', MqttQos.atMostOnce, builder.payload!);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Thêm thiết bị thành công')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Lỗi tạo thiết bị')),
      );
    }
  }

  Future<void> controlDevice(int id, String payload) async {
    final device = _devices.firstWhere((d) => d.id == id);
    final res = await http.post(
      Uri.parse('$_baseUrl/devices/$id/control'),
      headers: {'Content-Type': 'text/plain'},
      body: payload,
    );

    if (res.statusCode == 200) {
      if (_isMqttConnected) {
        final builder = MqttClientPayloadBuilder()..addString(payload);
        mqttClient.publishMessage(
            device.topic, MqttQos.atMostOnce, builder.payload!);
      }

      setState(() {
        _devices = _devices.map((d) {
          if (d.id == id) return d.copyWith(status: payload);
          return d;
        }).toList();
        _payloads[id] = payload;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã gửi lệnh: $payload')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Gửi lệnh thất bại')),
      );
    }
  }

  // ---------- Voice ----------
  Future<void> toggleListening(int deviceId) async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => debugPrint('🗣️ Status: $val'),
        onError: (val) => debugPrint('❌ Error: $val'),
      );
      if (available) {
        setState(() {
          _isListening = true;
          _listeningDeviceId = deviceId;
          _recognizedText = '';
        });
        _speech.listen(
          localeId: 'vi_VN',
          listenMode: ListenMode.confirmation,
          partialResults: true,
          onResult: (result) {
            final text = result.recognizedWords.toLowerCase();
            setState(() => _recognizedText = text);
            handleVoiceCommand(deviceId, text);
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không hỗ trợ giọng nói')),
        );
      }
    } else {
      _speech.stop();
      setState(() {
        _isListening = false;
        _listeningDeviceId = null;
      });
    }
  }

  void handleVoiceCommand(int deviceId, String text) {
    bool includeAny(String input, List<String> keys) =>
        keys.any((k) => input.contains(k));

    if (includeAny(text, ['bật', 'bat', 'on', 'mở', 'mo'])) {
      controlDevice(deviceId, 'LED_ON');
      _speech.stop();
      setState(() => _isListening = false);
    } else if (includeAny(text, ['tắt', 'tat', 'off', 'đóng', 'dong'])) {
      controlDevice(deviceId, 'LED_OFF');
      _speech.stop();
      setState(() => _isListening = false);
    }
  }

  // ---------- UI ----------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📡 IoT Device Controller'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '📋 Danh sách thiết bị',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Icon(
                  _isMqttConnected ? Icons.wifi : Icons.wifi_off,
                  color: _isMqttConnected ? Colors.green : Colors.red,
                ),
              ],
            ),
            if (_recognizedText.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  '🗣️ Nghe được: "$_recognizedText"',
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            const SizedBox(height: 8),

            ..._devices.map((d) {
              final status = _payloads[d.id] ?? "LED_OFF";
              final isOn = status == "LED_ON";
              final bgColor = isOn ? Colors.green.shade50 : Colors.red.shade50;

              return Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: 4,
                      offset: const Offset(2, 2),
                    )
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                d.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Text("Topic: ${d.topic}",
                                  style: const TextStyle(color: Colors.black54)),
                            ],
                          ),
                          IconButton(
                            icon: Icon(
                              _isListening && _listeningDeviceId == d.id
                                  ? Icons.mic
                                  : Icons.mic_none,
                              color: Colors.deepOrange,
                              size: 28,
                            ),
                            onPressed: () => toggleListening(d.id),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _payloads[d.id],
                        decoration: const InputDecoration(
                          labelText: "Lệnh điều khiển",
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        items: const [
                          DropdownMenuItem(
                              value: "LED_ON", child: Text("LED_ON")),
                          DropdownMenuItem(
                              value: "LED_OFF", child: Text("LED_OFF")),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _payloads[d.id] = val);
                        },
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue),
                            onPressed: () => controlDevice(
                                d.id, _payloads[d.id] ?? "LED_OFF"),
                            icon: const Icon(Icons.send),
                            label: const Text("GỬI"),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green),
                            onPressed: () => controlDevice(d.id, "LED_ON"),
                            child: const Text("BẬT"),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red),
                            onPressed: () => controlDevice(d.id, "LED_OFF"),
                            child: const Text("TẮT"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),

            const Divider(),
            const Text(
              '➕ Thêm thiết bị mới',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _deviceNameController,
              decoration: const InputDecoration(labelText: 'Tên thiết bị'),
            ),
            TextField(
              controller: _deviceTopicController,
              decoration: const InputDecoration(labelText: 'Topic MQTT'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: createDevice,
              child: const Text('Tạo thiết bị'),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------- MODEL ----------
class Device {
  final int id;
  final String name;
  final String topic;
  final String status;

  Device({
    required this.id,
    required this.name,
    required this.topic,
    required this.status,
  });

  Device copyWith({String? status}) {
    return Device(
      id: id,
      name: name,
      topic: topic,
      status: status ?? this.status,
    );
  }

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['id'],
      name: json['name'],
      topic: json['topic'],
      status: json['status'] ?? "LED_OFF",
    );
  }
}


