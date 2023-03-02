import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uvid/common/extensions.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:uvid/ui/app.dart';
import 'package:uvid/ui/screens/contact_screen.dart';
import 'package:uvid/ui/screens/history_meeting_screen.dart';
import 'package:uvid/ui/screens/setting_screen.dart';
import 'package:uvid/ui/widgets/page_animation/single_route_scale_builder.dart';
import 'package:uvid/utils/platform_details.dart';
import 'package:uvid/utils/routes.dart';
import 'package:uvid/utils/state_managment/home_manager.dart';

import '../../utils/notifications.dart';
import '../screens/meeting_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final pages = [
    const MeetingScreen(),
    const HistoryMeetingScreen(),
    const ContactScreen(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    NotificationManager().checkedAllowed(() {
      NotificationManager().showDialogRequestPermission(context);
    });
    NotificationManager().notificationStream.listen((notification) {
      if (Platform.isIOS) {
        NotificationManager().decreaseBadgeNotification();
      }
      if (notification.channelKey == NotificationManager.basicNotificationChannelKey) {
        Navigator.push(
          context,
          SingleRouteScaleBuilder(mtAppKey: mtAppKey, routeName: AppRoutesDirect.notification.route),
        );
      } else {
        Navigator.push(
          context,
          SingleRouteScaleBuilder(mtAppKey: mtAppKey, routeName: AppRoutesDirect.scheduleCalendar.route),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.tertiary,
      appBar: AppBar(
        elevation: 0,
        title: Text(
          context.read<HomeManager>().page == 0
              ? AppLocalizations.of(context)!.meet_and_chat_title
              : context.read<HomeManager>().page == 1
                  ? AppLocalizations.of(context)!.meetings
                  : context.read<HomeManager>().page == 2
                      ? AppLocalizations.of(context)!.contacts
                      : AppLocalizations.of(context)!.settings,
          style: context.textTheme.bodyText1?.copyWith(
            color: context.colorScheme.onTertiary,
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
        centerTitle: true,
        backgroundColor: context.colorScheme.tertiary,
        foregroundColor: context.colorScheme.onTertiary,
      ),
      body: IndexedStack(
        children: pages,
        index: context.watch<HomeManager>().page,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: context.colorScheme.tertiary,
        selectedItemColor: context.colorScheme.onTertiary,
        elevation: 10,
        unselectedItemColor: Colors.grey.shade500,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 16,
        showUnselectedLabels: false,
        onTap: context.read<HomeManager>().onPageChanged,
        currentIndex: context.watch<HomeManager>().page,
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.video_call_rounded,
            ),
            label: AppLocalizations.of(context)!.meet_and_chat,
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.meeting_room_rounded,
            ),
            label: AppLocalizations.of(context)!.meetings,
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.contacts_rounded,
            ),
            label: AppLocalizations.of(context)!.contacts,
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.settings_rounded,
            ),
            label: AppLocalizations.of(context)!.settings,
          ),
        ],
      ),
    );
  }
}
