
// import 'dart:io';

// void main() {
//   final dir = Directory('/Users/yyy/Downloads/home/uzxarid/lib');
//   int count = 0;
//   for (final file in dir.listSync(recursive: true)) {
//     if (file is File && file.path.endsWith('.dart')) {
//       final content = file.readAsStringSync();
//       if (content.contains('')) {
//         final newContent = content.replaceAll(
//           '',
//           '//  // delegated to appbar',
//         );
//         file.writeAsStringSync(newContent);
//         count++;
//         print('Updated \${file.path}');
//       }
//     }
//   }
//   print('Total updated: \$count');
// }
