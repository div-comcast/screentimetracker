String formatDateTime(DateTime dt) {
  final y = dt.year;
  final mo = dt.month.toString().padLeft(2, '0');
  final d = dt.day.toString().padLeft(2, '0');
  final h = dt.hour.toString().padLeft(2, '0');
  final mi = dt.minute.toString().padLeft(2, '0');
  final s = dt.second.toString().padLeft(2, '0');
  return '$y-$mo-$d $h:$mi:$s';
}

String formatMs(int ms) {
  final hours = ms ~/ 3600000;
  final minutes = (ms % 3600000) ~/ 60000;
  final seconds = (ms % 60000) ~/ 1000;

  if (hours > 0) return '${hours}h ${minutes}m';
  if (minutes > 0) return '${minutes}m ${seconds}s';
  return '${seconds}s';
}
