import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../utils/merchant_status_helper.dart';

class MerchantStatusBadge extends StatelessWidget {
  final Map<String, dynamic>? merchantData;
  final bool isCompact;
  final bool showTiming;
  final bool onCard; // true when rendered over the gradient Udhar Card

  const MerchantStatusBadge({
    super.key,
    required this.merchantData,
    this.isCompact = true,
    this.showTiming = true,
    this.onCard = false,
  });

  @override
  Widget build(BuildContext context) {
    final status = MerchantStatusHelper.getStatus(merchantData);

    if (isCompact) {
      return _buildCompactBadge(status);
    } else {
      return _buildBannerWidget(status);
    }
  }

  Widget _buildCompactBadge(MerchantStatusInfo status) {
    // When rendered over the dark/teal gradient card in CustomerUdharMerchantsScreen
    final Color bgColor = onCard
        ? (status.isOpen
            ? const Color(0xFF10B981).withValues(alpha: 0.20)
            : const Color(0xFFEF4444).withValues(alpha: 0.25))
        : status.badgeBgColor;

    final Color borderColor = onCard
        ? (status.isOpen ? const Color(0xFF34D399) : const Color(0xFFF87171))
        : status.badgeBorderColor;

    final Color textColor = onCard ? Colors.white : status.badgeTextColor;

    final Color dotColor = onCard
        ? (status.isOpen ? const Color(0xFF34D399) : const Color(0xFFF87171))
        : status.dotColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: borderColor.withValues(alpha: 0.6), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6.r,
                height: 6.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: dotColor,
                  boxShadow: [
                    BoxShadow(
                      color: dotColor.withValues(alpha: 0.8),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 5.w),
              Text(
                status.statusBadgeText,
                style: TextStyle(
                  color: textColor,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
        ),
        if (showTiming) ...[
          SizedBox(height: 3.h),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.access_time_rounded,
                size: 11.sp,
                color: onCard ? Colors.white.withValues(alpha: 0.75) : Colors.grey.shade600,
              ),
              SizedBox(width: 4.w),
              Text(
                status.timingText,
                style: TextStyle(
                  color: onCard ? Colors.white.withValues(alpha: 0.75) : Colors.grey.shade700,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildBannerWidget(MerchantStatusInfo status) {
    final isDark = status.isOpen ? const Color(0xFF064E3B) : const Color(0xFF7F1D1D);
    final lightBg = status.isOpen ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2);
    final border = status.isOpen ? const Color(0xFFA7F3D0) : const Color(0xFFFECACA);
    final accent = status.isOpen ? const Color(0xFF059669) : const Color(0xFFDC2626);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: lightBg,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: border, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              status.isOpen ? Icons.storefront_rounded : Icons.store_mall_directory_outlined,
              color: accent,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      width: 7.r,
                      height: 7.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accent,
                        boxShadow: [
                          BoxShadow(
                            color: accent.withValues(alpha: 0.6),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      status.isOpen ? "Shop is Open" : "Shop is Currently Closed",
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Text(
                  "${status.detailText} • Timings: ${status.timingText}",
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.grey.shade700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
