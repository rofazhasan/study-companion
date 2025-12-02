import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ContributionHeatmap extends StatelessWidget {
  final Map<DateTime, int> data;
  final DateTime startDate;
  final DateTime endDate;
  final int maxValue;
  final Color baseColor;

  const ContributionHeatmap({
    super.key,
    required this.data,
    required this.startDate,
    required this.endDate,
    this.maxValue = 3600 * 4, // Default max intensity reference: 4 hours
    this.baseColor = Colors.green,
  });

  @override
  Widget build(BuildContext context) {
    final duration = endDate.difference(startDate).inDays + 1;
    
    Widget content;
    if (duration <= 1) {
      content = _buildDailyView(context);
    } else if (duration <= 7) {
      content = _buildWeeklyView(context);
    } else {
      content = _buildMonthlyYearlyView(context);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        content,
        const SizedBox(height: 16),
        _buildLegend(context),
      ],
    );
  }

  Widget _buildLegend(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text('Less', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(width: 4),
        _buildLegendBox(context, 0),
        const SizedBox(width: 2),
        _buildLegendBox(context, maxValue ~/ 4),
        const SizedBox(width: 2),
        _buildLegendBox(context, maxValue ~/ 2),
        const SizedBox(width: 2),
        _buildLegendBox(context, (maxValue * 0.75).toInt()),
        const SizedBox(width: 2),
        _buildLegendBox(context, maxValue),
        const SizedBox(width: 4),
        Text('More', style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _buildLegendBox(BuildContext context, int value) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: _getColorForIntensity(context, value),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }

  Widget _buildDailyView(BuildContext context) {
    // 24-hour grid: 4 rows x 6 cols
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: List.generate(24, (index) {
            final time = DateTime(startDate.year, startDate.month, startDate.day, index);
            final value = data[time] ?? 0;
            
            return Tooltip(
              message: '${DateFormat('h a').format(time)}: ${_formatDuration(value)}',
              triggerMode: TooltipTriggerMode.tap,
              child: _buildBox(context, value, size: 32, showLabel: true, label: DateFormat('h a').format(time)),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildWeeklyView(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(durationInDays, (index) {
        final date = startDate.add(Duration(days: index));
        final normalizedDate = DateTime(date.year, date.month, date.day);
        final value = data[normalizedDate] ?? 0;

        return Column(
          children: [
            Tooltip(
              message: '${DateFormat('EEEE, MMM d').format(date)}\n${_formatDuration(value)}',
              triggerMode: TooltipTriggerMode.tap,
              child: _buildBox(context, value, size: 40),
            ),
            const SizedBox(height: 8),
            Text(
              DateFormat('E').format(date),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildMonthlyYearlyView(BuildContext context) {
    // GitHub style: Columns = Weeks, Rows = Days (Mon-Sun)
    final firstMonday = startDate.subtract(Duration(days: startDate.weekday - 1));
    final totalDays = endDate.difference(firstMonday).inDays + 1;
    final weeks = (totalDays / 7).ceil();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Y-Axis Labels
          Column(
            children: [
              _buildDayLabel(context, 'Mon'),
              _buildDayLabel(context, 'Tue'),
              _buildDayLabel(context, 'Wed'),
              _buildDayLabel(context, 'Thu'),
              _buildDayLabel(context, 'Fri'),
              _buildDayLabel(context, 'Sat'),
              _buildDayLabel(context, 'Sun'),
            ],
          ),
          const SizedBox(width: 8),
          // The Grid
          Row(
            children: List.generate(weeks, (weekIndex) {
              return Column(
                children: List.generate(7, (dayIndex) {
                  final date = firstMonday.add(Duration(days: weekIndex * 7 + dayIndex));
                  final isOutOfRange = date.isBefore(startDate) || date.isAfter(endDate);
                  
                  if (isOutOfRange) {
                     return Container(
                        width: 14,
                        height: 14,
                        margin: const EdgeInsets.all(2),
                     );
                  }

                  final normalizedDate = DateTime(date.year, date.month, date.day);
                  final value = data[normalizedDate] ?? 0;

                  return Tooltip(
                    message: '${DateFormat('MMM d, yyyy').format(date)}\n${_formatDuration(value)}',
                    triggerMode: TooltipTriggerMode.tap,
                    child: Container(
                      width: 14,
                      height: 14,
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: _getColorForIntensity(context, value),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  );
                }),
              );
            }),
          ),
        ],
      ),
    );
  }

  int get durationInDays => endDate.difference(startDate).inDays + 1;

  Widget _buildBox(BuildContext context, int value, {double size = 20, bool showLabel = false, String? label}) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutQuart,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, animValue, child) {
        return Transform.scale(
          scale: animValue,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: _getColorForIntensity(context, value),
              borderRadius: BorderRadius.circular(size * 0.3), // More rounded
              boxShadow: value > 0 ? [
                BoxShadow(
                  color: baseColor.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                )
              ] : null,
            ),
            alignment: Alignment.center,
            child: showLabel && label != null 
                ? Text(
                    label, 
                    style: TextStyle(
                      fontSize: 10, 
                      color: value > (maxValue / 2) ? Colors.white : Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ) 
                : null,
          ),
        );
      },
    );
  }

  Color _getColorForIntensity(BuildContext context, int value) {
    if (value == 0) {
      return Theme.of(context).brightness == Brightness.dark 
          ? Colors.white.withOpacity(0.05) 
          : Colors.grey.shade200;
    }
    
    final ratio = value / maxValue;
    
    // Distinct steps for "GitHub-like" feel but smoother
    if (ratio > 0.8) return baseColor; // Darkest
    if (ratio > 0.6) return baseColor.withOpacity(0.8);
    if (ratio > 0.4) return baseColor.withOpacity(0.6);
    if (ratio > 0.2) return baseColor.withOpacity(0.4);
    return baseColor.withOpacity(0.25);
  }

  Widget _buildDayLabel(BuildContext context, String text) {
    return Container(
      height: 18, // 14px box + 2px margin top + 2px margin bottom
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10),
      ),
    );
  }

  String _formatDuration(int seconds) {
    if (seconds == 0) return 'No study';
    final duration = Duration(seconds: seconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) return '${hours}h ${minutes}m';
    return '${minutes}m';
  }
}
