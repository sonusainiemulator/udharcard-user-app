import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MerchantStatusInfo {
  final bool isOpen;
  final String statusBadgeText;
  final String timingText;
  final String detailText;
  final Color badgeBgColor;
  final Color badgeBorderColor;
  final Color badgeTextColor;
  final Color dotColor;

  const MerchantStatusInfo({
    required this.isOpen,
    required this.statusBadgeText,
    required this.timingText,
    required this.detailText,
    required this.badgeBgColor,
    required this.badgeBorderColor,
    required this.badgeTextColor,
    required this.dotColor,
  });
}

class MerchantStatusHelper {
  /// Parses various time string formats into minutes from midnight (0..1439).
  /// Supported formats: "09:00 AM", "9:00 AM", "9:00am", "09:00", "21:30".
  static int? parseTimeToMinutes(String? timeStr) {
    if (timeStr == null || timeStr.trim().isEmpty) return null;
    final clean = timeStr.trim().toUpperCase();

    // Try 12-hour format with AM/PM (e.g. 09:00 AM, 9:30 PM)
    try {
      final formats = [
        DateFormat('hh:mm a'),
        DateFormat('h:mm a'),
        DateFormat('hh:mma'),
        DateFormat('h:mma'),
        DateFormat('HH:mm'),
        DateFormat('H:mm'),
      ];

      for (final format in formats) {
        try {
          final dt = format.parse(clean);
          return dt.hour * 60 + dt.minute;
        } catch (_) {}
      }
    } catch (_) {}

    // Manual fallback parsing regex for "HH:MM" or "HH:MM AM/PM"
    final regExp = RegExp(r'^(\d{1,2}):(\d{2})\s*(AM|PM)?$', caseSensitive: false);
    final match = regExp.firstMatch(clean);
    if (match != null) {
      int hour = int.tryParse(match.group(1) ?? '') ?? 0;
      final minute = int.tryParse(match.group(2) ?? '') ?? 0;
      final period = match.group(3)?.toUpperCase();

      if (period == 'PM' && hour < 12) hour += 12;
      if (period == 'AM' && hour == 12) hour = 0;
      return hour * 60 + minute;
    }

    return null;
  }

  /// Evaluates the real-time opening/closing status for a merchant.
  static MerchantStatusInfo getStatus(Map<String, dynamic>? data) {
    if (data == null || data.isEmpty) {
      // Default to Open if no merchant schedule data provided
      return const MerchantStatusInfo(
        isOpen: true,
        statusBadgeText: "OPEN NOW",
        timingText: "09:00 AM - 09:30 PM",
        detailText: "Closes at 09:30 PM",
        badgeBgColor: Color(0xFFE8F5E9),
        badgeBorderColor: Color(0xFF81C784),
        badgeTextColor: Color(0xFF2E7D32),
        dotColor: Color(0xFF4CAF50),
      );
    }

    // 1. Check explicit online / offline toggle
    final rawOnline = data['is_shop_online'] ??
        data['is_online'] ??
        data['shop_status'] ??
        data['isShopOnline'];
    bool isOnline = true;
    if (rawOnline != null) {
      final str = rawOnline.toString().trim().toLowerCase();
      if (str == '0' || str == 'false' || str == 'offline' || str == 'closed') {
        isOnline = false;
      }
    }

    // 2. Extract opening & closing times
    final openingStr = (data['shop_opening_time'] ??
            data['opening_time'] ??
            data['shopOpeningTime'] ??
            '09:00 AM')
        .toString()
        .trim();
    final closingStr = (data['shop_closing_time'] ??
            data['closing_time'] ??
            data['shopClosingTime'] ??
            '09:30 PM')
        .toString()
        .trim();

    final timingDisplay = "$openingStr - $closingStr";

    // 3. Check closed days (e.g. "Sunday", "Sunday, Saturday", or List)
    final rawClosedDays = data['shop_closed_days'] ??
        data['closed_days'] ??
        data['shopClosedDays'];
    final now = DateTime.now();
    final currentDayName = DateFormat('EEEE').format(now).toLowerCase(); // e.g. "monday"

    bool isClosedToday = false;
    if (rawClosedDays != null) {
      if (rawClosedDays is List) {
        isClosedToday = rawClosedDays
            .map((e) => e.toString().trim().toLowerCase())
            .contains(currentDayName);
      } else {
        final daysList = rawClosedDays
            .toString()
            .toLowerCase()
            .split(RegExp(r'[,|/]'))
            .map((e) => e.trim())
            .toList();
        isClosedToday = daysList.contains(currentDayName);
      }
    }

    // If manually marked offline
    if (!isOnline) {
      return MerchantStatusInfo(
        isOpen: false,
        statusBadgeText: "CLOSED",
        timingText: timingDisplay,
        detailText: "Shop is currently closed by merchant",
        badgeBgColor: const Color(0xFFFFEBEE),
        badgeBorderColor: const Color(0xFFE57373),
        badgeTextColor: const Color(0xFFC62828),
        dotColor: const Color(0xFFE53935),
      );
    }

    // If closed today
    if (isClosedToday) {
      final dayCapitalized = DateFormat('EEEE').format(now);
      return MerchantStatusInfo(
        isOpen: false,
        statusBadgeText: "CLOSED TODAY",
        timingText: timingDisplay,
        detailText: "Closed on $dayCapitalized" + "s",
        badgeBgColor: const Color(0xFFFFF3E0),
        badgeBorderColor: const Color(0xFFFFB74D),
        badgeTextColor: const Color(0xFFE65100),
        dotColor: const Color(0xFFFB8C00),
      );
    }

    // 4. Compare current time with opening and closing times
    final openMinutes = parseTimeToMinutes(openingStr) ?? (9 * 60); // 09:00 AM default
    final closeMinutes = parseTimeToMinutes(closingStr) ?? (21 * 60 + 30); // 09:30 PM default
    final currentMinutes = now.hour * 60 + now.minute;

    bool isOpenNow = false;
    String detailText = "";

    if (openMinutes <= closeMinutes) {
      // Standard daytime schedule: e.g. 9:00 AM (540) to 9:30 PM (1290)
      if (currentMinutes < openMinutes) {
        isOpenNow = false;
        detailText = "Opens today at $openingStr";
      } else if (currentMinutes > closeMinutes) {
        isOpenNow = false;
        detailText = "Closed for today • Opens tomorrow at $openingStr";
      } else {
        isOpenNow = true;
        detailText = "Open • Closes at $closingStr";
      }
    } else {
      // Overnight schedule: e.g. 8:00 PM (1200) to 2:00 AM (120)
      if (currentMinutes >= openMinutes || currentMinutes <= closeMinutes) {
        isOpenNow = true;
        detailText = "Open • Closes at $closingStr";
      } else {
        isOpenNow = false;
        detailText = "Opens today at $openingStr";
      }
    }

    if (isOpenNow) {
      return MerchantStatusInfo(
        isOpen: true,
        statusBadgeText: "OPEN NOW",
        timingText: timingDisplay,
        detailText: detailText,
        badgeBgColor: const Color(0xFFE8F5E9),
        badgeBorderColor: const Color(0xFF81C784),
        badgeTextColor: const Color(0xFF2E7D32),
        dotColor: const Color(0xFF4CAF50),
      );
    } else {
      return MerchantStatusInfo(
        isOpen: false,
        statusBadgeText: "CLOSED",
        timingText: timingDisplay,
        detailText: detailText,
        badgeBgColor: const Color(0xFFFFEBEE),
        badgeBorderColor: const Color(0xFFE57373),
        badgeTextColor: const Color(0xFFC62828),
        dotColor: const Color(0xFFE53935),
      );
    }
  }
}
