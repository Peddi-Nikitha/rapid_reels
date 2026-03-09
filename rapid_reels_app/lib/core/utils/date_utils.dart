import 'package:intl/intl.dart';

class DateTimeUtils {
  // Format date to display format (e.g., 15 Feb 2026)
  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }
  
  // Format time to display format (e.g., 10:30 AM)
  static String formatTime(DateTime dateTime) {
    return DateFormat('hh:mm a').format(dateTime);
  }
  
  // Format date and time (e.g., 15 Feb 2026, 10:30 AM)
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
  }
  
  // Format date for API (e.g., 2026-02-15)
  static String formatDateForApi(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }
  
  // Format time for API (e.g., 10:30:00)
  static String formatTimeForApi(DateTime dateTime) {
    return DateFormat('HH:mm:ss').format(dateTime);
  }
  
  // Parse date string from API
  static DateTime? parseDateFromApi(String dateString) {
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }
  
  // Get day name (e.g., Monday)
  static String getDayName(DateTime date) {
    return DateFormat('EEEE').format(date);
  }
  
  // Get short day name (e.g., Mon)
  static String getShortDayName(DateTime date) {
    return DateFormat('EEE').format(date);
  }
  
  // Get month name (e.g., February)
  static String getMonthName(DateTime date) {
    return DateFormat('MMMM').format(date);
  }
  
  // Get short month name (e.g., Feb)
  static String getShortMonthName(DateTime date) {
    return DateFormat('MMM').format(date);
  }
  
  // Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }
  
  // Check if date is tomorrow
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year && 
           date.month == tomorrow.month && 
           date.day == tomorrow.day;
  }
  
  // Check if date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year && 
           date.month == yesterday.month && 
           date.day == yesterday.day;
  }
  
  // Get relative day string (Today, Tomorrow, Yesterday, or formatted date)
  static String getRelativeDay(DateTime date) {
    if (isToday(date)) return 'Today';
    if (isTomorrow(date)) return 'Tomorrow';
    if (isYesterday(date)) return 'Yesterday';
    return formatDate(date);
  }
  
  // Calculate duration between two dates in hours
  static int calculateDurationInHours(DateTime start, DateTime end) {
    return end.difference(start).inHours;
  }
  
  // Calculate duration between two dates in minutes
  static int calculateDurationInMinutes(DateTime start, DateTime end) {
    return end.difference(start).inMinutes;
  }
  
  // Get time remaining until date (e.g., "2 hours 30 minutes")
  static String getTimeRemaining(DateTime targetDate) {
    final now = DateTime.now();
    final difference = targetDate.difference(now);
    
    if (difference.isNegative) return 'Passed';
    
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ${difference.inHours % 24} hour${(difference.inHours % 24) != 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ${difference.inMinutes % 60} minute${(difference.inMinutes % 60) != 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'Less than a minute';
    }
  }
  
  // Add duration to time (for booking slots)
  static DateTime addDuration(DateTime start, int durationInMinutes) {
    return start.add(Duration(minutes: durationInMinutes));
  }
  
  // Check if time slot is available (not in past)
  static bool isTimeSlotAvailable(DateTime slotTime) {
    return slotTime.isAfter(DateTime.now());
  }
}

