import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:uvid/common/extensions.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:uvid/domain/models/event.dart';
import 'package:uvid/ui/pages/create_event_page.dart';

class ScheduleCalendarScreen extends StatefulWidget {
  const ScheduleCalendarScreen({super.key});

  @override
  State<ScheduleCalendarScreen> createState() => _ScheduleCalendarScreenState();
}

class _ScheduleCalendarScreenState extends State<ScheduleCalendarScreen> {
  late int mode;

  @override
  void initState() {
    super.initState();
    mode = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        elevation: 8,
        onPressed: () async {
          final event = await context.pushRoute<CalendarEventData<Event?>>(CreateEventPage(
            withDuration: true,
          ));
          if (event == null) return;
          CalendarControllerProvider.of<Event?>(context).controller.add(event);
        },
      ),
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
      body: DayView<Event?>(
        backgroundColor: Colors.white24,
        headerStyle: HeaderStyle(
          headerTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
