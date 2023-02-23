import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uvid/common/extensions.dart';
import 'package:uvid/ui/widgets/gap.dart';
import 'package:uvid/ui/widgets/home_meeting_button.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:uvid/utils/state_managment/home_manager.dart';
import 'package:uvid/utils/state_managment/theme.dart';

class MeetingScreen extends StatelessWidget {
  const MeetingScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HomeMeetingButton(
              onPressed: () {
                Navigator.pushNamed(context, '/video_call');
              },
              icon: Icons.videocam_rounded,
              iconColor: context.colorScheme.onPrimary,
              color: context.colorScheme.primary,
              footer: SizedBox(
                width: 60,
                child: Text(
                  AppLocalizations.of(context)!.new_meeting,
                  style: context.textTheme.bodyText1?.copyWith(
                    color: context.colorScheme.onTertiary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            HomeMeetingButton(
              onPressed: () {},
              icon: Icons.add_box_rounded,
              iconColor: context.colorScheme.onPrimary,
              color: context.colorScheme.primary,
              footer: SizedBox(
                width: 60,
                child: Text(
                  AppLocalizations.of(context)!.join_meeting,
                  style: context.textTheme.bodyText1?.copyWith(
                    color: context.colorScheme.onTertiary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            HomeMeetingButton(
              onPressed: () {
                Navigator.pushNamed(context, '/schedule_calendar');
              },
              icon: Icons.calendar_month_rounded,
              iconColor: context.colorScheme.onPrimary,
              color: context.colorScheme.primary,
              footer: SizedBox(
                width: 60,
                child: Text(
                  AppLocalizations.of(context)!.schedule,
                  style: context.textTheme.bodyText1?.copyWith(
                    color: context.colorScheme.onTertiary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            HomeMeetingButton(
              onPressed: () {},
              icon: Icons.notifications_on_rounded,
              iconColor: context.colorScheme.onPrimary,
              color: context.colorScheme.primary,
              footer: SizedBox(
                width: 60,
                child: Text(
                  AppLocalizations.of(context)!.notification,
                  style: context.textTheme.bodyText1?.copyWith(
                    color: context.colorScheme.onTertiary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              isHasBaged: !context.read<HomeManager>().isMuteNotification,
            ),
          ],
        ),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  child: Image.asset(
                    'assets/ic_launcher.png',
                    width: 82,
                  ),
                ),
                gapV8,
                Text(
                  AppLocalizations.of(context)!.welcome + '\n' + AppLocalizations.of(context)!.start_or_join_a_metting,
                  style: context.textTheme.bodyText1?.copyWith(
                    color: context.colorScheme.onTertiary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Column(
              children: [
                Icon(
                  context.watch<HomeManager>().statusInternet.contains('Online') ? Icons.wifi_rounded : Icons.wifi_off_rounded,
                  color: context.watch<HomeManager>().statusInternet.contains('Online')
                      ? context.read<ThemeManager>().themeMode == ThemeMode.dark
                          ? Colors.green.shade500
                          : Colors.blueAccent.shade400
                      : context.colorScheme.error,
                  size: 24,
                ),
                Text(
                  context.watch<HomeManager>().statusInternet,
                  style: context.textTheme.bodyText1?.copyWith(
                    color: context.watch<HomeManager>().statusInternet.contains('Online')
                        ? context.read<ThemeManager>().themeMode == ThemeMode.dark
                            ? Colors.green.shade500
                            : Colors.blueAccent.shade400
                        : context.colorScheme.error,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
