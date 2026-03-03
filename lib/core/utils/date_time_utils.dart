import 'package:intl/intl.dart';

/// Utility class for date and time formatting
class DateTimeUtils {
  DateTimeUtils._();

  static final DateFormat _fullDateFormat = DateFormat('MMM dd, yyyy HH:mm');
  static final DateFormat _dateOnlyFormat = DateFormat('MMM dd, yyyy');
  static final DateFormat _timeOnlyFormat = DateFormat('HH:mm');
  static final DateFormat _isoFormat = DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'");

  /// Formats DateTime to full date string (e.g., "Jan 15, 2024 14:30")
  static String formatFullDate(DateTime dateTime) {
    return _fullDateFormat.format(dateTime);
  }

  /// Formats DateTime to date only (e.g., "Jan 15, 2024")
  static String formatDateOnly(DateTime dateTime) {
    return _dateOnlyFormat.format(dateTime);
  }

  /// Formats DateTime to time only (e.g., "14:30")
  static String formatTimeOnly(DateTime dateTime) {
    return _timeOnlyFormat.format(dateTime);
  }

  /// Formats DateTime to ISO 8601 string
  static String toIsoString(DateTime dateTime) {
    return _isoFormat.format(dateTime.toUtc());
  }

  /// Parses ISO 8601 string to DateTime
  static DateTime fromIsoString(String isoString) {
    return DateTime.parse(isoString);
  }

  /// Returns relative time string (e.g., "2 hours ago", "Yesterday")
  static String getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    }
  }

  /// Checks if date is today
  static bool isToday(DateTime dateTime) {
    final now = DateTime.now();
    return dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day;
  }

  /// Checks if date is yesterday
  static bool isYesterday(DateTime dateTime) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return dateTime.year == yesterday.year &&
        dateTime.month == yesterday.month &&
        dateTime.day == yesterday.day;
  }
}
