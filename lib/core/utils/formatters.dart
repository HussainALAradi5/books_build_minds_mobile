String formatBhd(num value) => '${value.toStringAsFixed(3)} BHD';

String formatDate(String? value) {
  if (value == null || value.isEmpty) return '—';
  final parsed = DateTime.tryParse(value);
  if (parsed == null) return value;
  return '${parsed.day}/${parsed.month}/${parsed.year}';
}
