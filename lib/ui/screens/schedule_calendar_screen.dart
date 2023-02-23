import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:uvid/common/extensions.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ScheduleCalendarScreen extends StatefulWidget {
  const ScheduleCalendarScreen({super.key});

  @override
  State<ScheduleCalendarScreen> createState() => _ScheduleCalendarScreenState();
}

class _ScheduleCalendarScreenState extends State<ScheduleCalendarScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          AppLocalizations.of(context)!.schedule,
          style: context.textTheme.bodyText1?.copyWith(
            color: context.colorScheme.onTertiary,
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
        centerTitle: true,
        backgroundColor: context.colorScheme.tertiary,
        automaticallyImplyLeading: true,
        foregroundColor: context.colorScheme.onTertiary,
      ),
      body: DayView(),
    );
  }
}
