// import 'dart:convert';
// import 'dart:io';

// void main() {
//   final file = File('BrainGuard API.postman_collection.json');
//   final jsonStr = file.readAsStringSync();
//   final Map<String, dynamic> data = jsonDecode(jsonStr);

//   void extract(List<dynamic> items, String prefix) {
//     for (var item in items) {
//       if (item['item'] != null) {
//         extract(item['item'], prefix + item['name'] + ' -> ');
//       } else if (item['request'] != null) {
//         final req = item['request'];
//         String method = req['method'];
//         String url = '';
//         if (req['url'] is Map) {
//           url = req['url']['raw'] ?? '';
//         } else if (req['url'] is String) {
//           url = req['url'];
//         }
//         print('\$method \$url ($prefix\${item['name']})');
//       }
//     }
//   }

//   if (data['item'] != null) {
//     extract(data['item'], '');
//   }
// }
