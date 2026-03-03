import 'package:flutter_test/flutter_test.dart';
import 'package:wildsnap_pro/core/utils/date_time_utils.dart';

void main() {
  group('DateTimeUtils', () {
    test('formatFullDate should format date correctly', () {
      final date = DateTime(2024, 1, 15, 14, 30);
      final formatted = DateTimeUtils.formatFullDate(date);
      expect(formatted, contains('Jan'));
      expect(formatted, contains('15'));
      expect(formatted, contains('2024'));
      expect(formatted, contains('14:30'));
    });

    test('formatDateOnly should format date without time', () {
      final date = DateTime(2024, 1, 15, 14, 30);
      final formatted = DateTimeUtils.formatDateOnly(date);
      expect(formatted, contains('Jan'));
      expect(formatted, contains('15'));
      expect(formatted, contains('2024'));
      expect(formatted, isNot(contains('14:30')));
    });

    test('formatTimeOnly should format time only', () {
      final date = DateTime(2024, 1, 15, 14, 30);
      final formatted = DateTimeUtils.formatTimeOnly(date);
      expect(formatted, '14:30');
    });

    test('toIsoString should return ISO format', () {
      final date = DateTime(2024, 1, 15, 14, 30);
      final isoString = DateTimeUtils.toIsoString(date);
      expect(isoString, contains('2024-01-15'));
    });

    test('getRelativeTime should return "Just now" for recent time', () {
      final now = DateTime.now();
      final result = DateTimeUtils.getRelativeTime(now);
      expect(result, 'Just now');
    });

    test('getRelativeTime should return minutes ago', () {
      final past = DateTime.now().subtract(const Duration(minutes: 5));
      final result = DateTimeUtils.getRelativeTime(past);
      expect(result, contains('minutes ago'));
    });

    test('getRelativeTime should return hours ago', () {
      final past = DateTime.now().subtract(const Duration(hours: 3));
      final result = DateTimeUtils.getRelativeTime(past);
      expect(result, contains('hours ago'));
    });

    test('getRelativeTime should return Yesterday', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final result = DateTimeUtils.getRelativeTime(yesterday);
      expect(result, 'Yesterday');
    });

    test('getRelativeTime should return days ago', () {
      final past = DateTime.now().subtract(const Duration(days: 3));
      final result = DateTimeUtils.getRelativeTime(past);
      expect(result, contains('days ago'));
    });

    test('isToday should return true for today', () {
      final today = DateTime.now();
      expect(DateTimeUtils.isToday(today), true);
    });

    test('isToday should return false for yesterday', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      expect(DateTimeUtils.isToday(yesterday), false);
    });

    test('isYesterday should return true for yesterday', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      expect(DateTimeUtils.isYesterday(yesterday), true);
    });

    test('isYesterday should return false for today', () {
      final today = DateTime.now();
      expect(DateTimeUtils.isYesterday(today), false);
    });
  });
}
