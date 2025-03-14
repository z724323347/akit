import 'package:date_format/date_format.dart';

String toTimeString(int time) {
  return formatDate(DateTime.fromMillisecondsSinceEpoch(time),
      <String>[HH, ':', nn, ':', ss, '.', S]);
}

String toDateString(int time) {
  return formatDate(DateTime.fromMillisecondsSinceEpoch(time),
      <String>[mm, '-', dd, ' ', HH, ':', nn, ':', ss, '.', S]);
}
