const List<String> _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
];
const List<String> _monthsLong = [
  'JANUARY', 'FEBRUARY', 'MARCH', 'APRIL', 'MAY', 'JUNE', 'JULY', 'AUGUST',
  'SEPTEMBER', 'OCTOBER', 'NOVEMBER', 'DECEMBER'
];
const List<String> _weekdaysLong = [
  'MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY', 'SUNDAY'
];

/// 85000 -> "85,000"
String formatNumber(num value) {
  final negative = value < 0;
  final digits = value.abs().round().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }
  return negative ? '-$buffer' : buffer.toString();
}

/// 85000 -> "UGX 85,000"
String formatMoney(num value) => 'UGX ${formatNumber(value)}';

/// 5000.0 -> "5000", 12.5 -> "12.5" (for filling text fields)
String formatInput(num value) {
  if (value == value.roundToDouble()) return value.toInt().toString();
  return value.toString();
}

/// The API sends UTC times without a "Z". Parse them as UTC and convert to local time.
DateTime parseApiDate(String raw) {
  final hasZone = RegExp(r'(Z|[+-]\d{2}:?\d{2})$').hasMatch(raw);
  return DateTime.parse(hasZone ? raw : '${raw}Z').toLocal();
}

String formatClock(DateTime d) {
  var hour = d.hour % 12;
  if (hour == 0) hour = 12;
  final minute = d.minute.toString().padLeft(2, '0');
  return '$hour:$minute ${d.hour >= 12 ? 'PM' : 'AM'}';
}

/// "Today · 10:42 AM", "Yesterday · 4:30 PM", "3 Nov · 9:05 AM"
String formatWhen(DateTime d, {DateTime? now}) {
  final current = now ?? DateTime.now();
  final today = DateTime(current.year, current.month, current.day);
  final day = DateTime(d.year, d.month, d.day);
  final diff = today.difference(day).inDays;
  if (diff == 0) return 'Today · ${formatClock(d)}';
  if (diff == 1) return 'Yesterday · ${formatClock(d)}';
  return '${d.day} ${_months[d.month - 1]} · ${formatClock(d)}';
}

String formatDate(DateTime d) => '${d.day} ${_months[d.month - 1]} ${d.year}';

/// "MONDAY, 8 NOVEMBER"
String formatLongDate(DateTime d) =>
    '${_weekdaysLong[d.weekday - 1]}, ${d.day} ${_monthsLong[d.month - 1]}';

String greeting([DateTime? now]) {
  final hour = (now ?? DateTime.now()).hour;
  if (hour < 12) return 'Good morning';
  if (hour < 17) return 'Good afternoon';
  return 'Good evening';
}

/// The backend has no product images, so a category-based emoji stands in for the icon.
String productEmoji(String? category) {
  final c = (category ?? '').toLowerCase();
  bool has(List<String> words) => words.any(c.contains);
  if (has(['electr', 'phone', 'computer', 'tech'])) return '🎧';
  if (has(['cloth', 'apparel', 'fashion', 'shoe'])) return '👕';
  if (has(['drink', 'beverage', 'water', 'soda'])) return '🥤';
  if (has(['grocer', 'food', 'snack'])) return '🛒';
  if (has(['home', 'kitchen', 'furniture'])) return '🏠';
  if (has(['station', 'book', 'office'])) return '📚';
  if (has(['health', 'pharm', 'medic'])) return '💊';
  if (has(['beauty', 'cosmetic'])) return '🧴';
  if (has(['tool', 'hardware'])) return '🔧';
  return '📦';
}
