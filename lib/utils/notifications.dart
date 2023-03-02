import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:uvid/common/extensions.dart';

class NotificationManager {
  NotificationManager._();
  static get _instance => NotificationManager._();
  factory NotificationManager() {
    return _instance;
  }

  static final basicNotificationChannelKey = 'basic_channel';
  final basicNotificationChannelName = 'Basic Notifications';
  final basicNotificationChannelDes = 'Basic Notifications for app';
  final basicNotificationImportant = NotificationImportance.High;
  get _basicNotificationChannel => NotificationChannel(
        channelKey: basicNotificationChannelKey,
        channelName: basicNotificationChannelName,
        channelDescription: basicNotificationChannelDes,
        defaultColor: Colors.teal,
        defaultRingtoneType: DefaultRingtoneType.Notification,
        importance: basicNotificationImportant,
        channelShowBadge: true,
      );

  final scheduleNotificationChannelKey = 'schedule_channel';
  final scheduleNotificationChannelName = 'Schedule Notifications';
  final scheduleNotificationChannelDes = 'Schedule Notifications for app';
  final scheduleNotificationImportant = NotificationImportance.High;
  get _scheduleNotificationChannel => NotificationChannel(
        channelKey: scheduleNotificationChannelKey,
        channelName: scheduleNotificationChannelName,
        channelDescription: scheduleNotificationChannelDes,
        defaultColor: Colors.teal,
        defaultRingtoneType: DefaultRingtoneType.Alarm,
        importance: scheduleNotificationImportant,
        channelShowBadge: true,
        defaultPrivacy: NotificationPrivacy.Public,
      );

  initialize() {
    AwesomeNotifications().initialize(
      'resource://drawable/ic_notification',
      [
        _basicNotificationChannel,
        _scheduleNotificationChannel,
      ],
    );
  }

  checkedAllowed(VoidCallback onNotAllowed) {
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        onNotAllowed();
      }
    });
  }

  decreaseBadgeNotification() {
    AwesomeNotifications().getGlobalBadgeCounter().then((amount) {
      AwesomeNotifications().setGlobalBadgeCounter(amount - 1);
    });
  }

  showDialogRequestPermission(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Allow Notifications'),
        content: Text(
          'Our app would like to send you notifications',
          style: context.textTheme.bodyText1?.copyWith(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              'Don\'t Allow',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 18,
              ),
            ),
          ),
          TextButton(
              onPressed: () => AwesomeNotifications().requestPermissionToSendNotifications().then((_) => Navigator.pop(context)),
              child: Text(
                'Allow',
                style: TextStyle(
                  color: Colors.teal,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ))
        ],
      ),
    );
  }

  Stream<ReceivedAction> get notificationStream => AwesomeNotifications().actionStream;
  dispose() {
    AwesomeNotifications().actionSink.close();
    AwesomeNotifications().createdSink.close();
  }

  Future<void> showBasicNotification(
      {String title = '${Emojis.video_video_camera + Emojis.video_camera_with_flash + Emojis.sun}',
      String body = 'You have a requested call video!!!'}) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: createUniqueID(),
        channelKey: basicNotificationChannelKey,
        title: title,
        body: body,
        notificationLayout: NotificationLayout.Default,
      ),
    );
  }

  Future<void> showScheduledNotification({
    String title = '${Emojis.office_calendar + Emojis.office_calendar + Emojis.person_activity_man_dancing}',
    String body = 'You have a schedule video conference!!!',
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: createUniqueID(),
        channelKey: scheduleNotificationChannelKey,
        title: title,
        body: body,
        notificationLayout: NotificationLayout.Default,
      ),
      actionButtons: [
        NotificationActionButton(
          autoCancel: true,
          enabled: true,
          buttonType: ActionButtonType.Default,
          icon: Emojis.smile_alien,
          showInCompactView: true,
          label: 'Join!!',
          key: 'join',
        )
      ],
      schedule: NotificationCalendar.fromDate(
        allowWhileIdle: true,
        repeats: true,
        date: millisecondsToDateTime(
          DateTime.now().millisecondsSinceEpoch + 1000,
        ),
      ),
    );
  }

  Future<void> cancelAllScheduledNotification() async {
    await AwesomeNotifications().cancelAllSchedules();
  }

  int createUniqueID() {
    return DateTime.now().microsecondsSinceEpoch.remainder(1000000);
  }
}
