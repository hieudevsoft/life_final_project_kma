import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:dartx/dartx.dart';
import 'package:provider/provider.dart';
import 'package:uvid/common/extensions.dart';
import 'package:uvid/data/local_storage.dart';
import 'package:uvid/domain/models/audio_mode.dart';
import 'package:uvid/domain/models/language_type.dart';
import 'package:uvid/domain/models/notification_mode.dart';
import 'package:uvid/domain/models/phone_verify_screen_type.dart';
import 'package:uvid/domain/models/profile.dart';
import 'package:uvid/domain/models/video_mode.dart';
import 'package:uvid/exceptions/sign_out.dart';
import 'package:uvid/providers/auth.dart';
import 'package:uvid/providers/firestore.dart';
import 'package:uvid/ui/pages/phone_verify_page.dart';
import 'package:uvid/ui/widgets/elevated_button.dart';
import 'package:uvid/ui/widgets/gap.dart';
import 'package:uvid/ui/widgets/popup_menu.dart';
import 'package:uvid/ui/widgets/text_button.dart';
import 'package:uvid/utils/home_manager.dart';
import 'package:uvid/utils/theme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:uvid/utils/utils.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with AutomaticKeepAliveClientMixin<SettingsScreen> {
  bool _isSignOutAvailable = true;
  Profile? profile = null;
  bool _isShowMoreInformation = false;

  @override
  void initState() {
    super.initState();
  }

  void _signOut(BuildContext context) async {
    try {
      AuthProviders().signOut();
      Utils().showToast(AppLocalizations.of(context)!.sign_out_successfully, backgroundColor: Colors.greenAccent.shade200);
      Future.delayed(
        Duration(milliseconds: 300),
        () {
          Navigator.popAndPushNamed(context, '/login');
        },
      );
    } on SignOutException catch (e) {
      Utils().showToast(e.toString(), backgroundColor: Colors.redAccent.shade200);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _buildMainContent();
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      physics: BouncingScrollPhysics(),
      child: Column(
        children: [
          _buildHeaderProfile(context, () {
            setState(() {
              _isShowMoreInformation = !_isShowMoreInformation;
            });
          }, _isShowMoreInformation),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: context.colorScheme.primary,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 8,
                    color: context.colorScheme.primary.withOpacity(0.6),
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  gapV12,
                  _buildRowLanguageOptionSetting(context),
                  gapV12,
                  Divider(
                    color: context.colorScheme.onPrimary,
                    thickness: 1,
                  ),
                  gapV12,
                  _buildRowDarkModeOptionSetting(context),
                  gapV12,
                  Divider(
                    color: context.colorScheme.onPrimary,
                    thickness: 1,
                  ),
                  gapV12,
                  buildRowMuteAudioOptionSetting(context),
                  gapV12,
                  Divider(
                    color: context.colorScheme.onPrimary,
                    thickness: 1,
                  ),
                  gapV12,
                  buildRowMuteVideoOptionSetting(context),
                  gapV12,
                  Divider(
                    color: context.colorScheme.onPrimary,
                    thickness: 1,
                  ),
                  gapV12,
                  _buildRowNotificationOptionSetting(context),
                  gapV12
                ],
              ),
            ),
          ),
          gapH24,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 64),
            child: MyElevatedButton(
              child: Text(
                AppLocalizations.of(context)!.sign_out,
                style: context.textTheme.subtitle1?.copyWith(
                  fontSize: 18,
                  color: context.colorScheme.onError,
                  fontWeight: FontWeight.w900,
                ),
              ),
              backgroundColor: context.colorScheme.error,
              shadowColor: context.colorScheme.error,
              shape: StadiumBorder(),
              isEnabled: _isSignOutAvailable,
              onPressed: () {
                setState(() {
                  _isSignOutAvailable = false;
                });
                _signOut(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderProfile(
    BuildContext context,
    Function onClickShowMore,
    bool isShowMore,
  ) {
    profile = context.select<HomeManager, Profile?>((homeManager) => homeManager.profile);
    if (profile == null) {
      return Column(
        children: [
          Card(
            shape: CircleBorder(),
            elevation: 12,
            shadowColor: Colors.black87,
            borderOnForeground: true,
            surfaceTintColor: Colors.redAccent,
            child: CircleAvatar(
              radius: 38,
              backgroundColor: Colors.transparent,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: Image.asset(
                  'assets/ic_launcher.png',
                  fit: BoxFit.contain,
                  width: 76,
                  height: 76,
                ),
              ),
            ),
          ),
          Text(
            AppLocalizations.of(context)!.guest_account,
            style: context.textTheme.subtitle1?.copyWith(
              fontSize: 18,
              color: context.colorScheme.onSecondary,
              fontWeight: FontWeight.w900,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    } else {
      return _buildProfile(context, profile!, onClickShowMore, isShowMore);
    }
  }

  Widget _buildProfile(
    BuildContext context,
    Profile profile,
    Function onClickShowMore,
    bool isShowMore,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.max,
      children: [
        Card(
          shape: CircleBorder(),
          elevation: 12,
          shadowColor: Colors.black87,
          borderOnForeground: true,
          surfaceTintColor: Colors.redAccent,
          child: InkWell(
            onTap: () {
              _showFullScreenImage(
                context,
                profile.photoUrl == null
                    ? Image.asset(
                        'assets/ic_launcher.png',
                        fit: BoxFit.contain,
                        width: context.screenWidth * 3 / 4,
                      )
                    : profile.avatarUrlIsLink
                        ? Image.network(
                            profile.photoUrl!,
                            fit: BoxFit.contain,
                            width: context.screenWidth * 3 / 4,
                          )
                        : Image.memory(
                            base64Decode(profile.photoUrl!),
                            fit: BoxFit.contain,
                            width: context.screenWidth * 3 / 4,
                          ),
              );
            },
            child: CircleAvatar(
              radius: 38,
              backgroundColor: Colors.transparent,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: profile.photoUrl == null
                    ? Image.asset(
                        'assets/ic_launcher.png',
                        fit: BoxFit.contain,
                        width: 76,
                        height: 76,
                      )
                    : profile.avatarUrlIsLink
                        ? Image.network(
                            profile.photoUrl!,
                            fit: BoxFit.cover,
                            width: 76,
                            height: 76,
                          )
                        : Image.memory(
                            base64Decode(profile.photoUrl!),
                            fit: BoxFit.cover,
                            width: 76,
                            height: 76,
                          ),
              ),
            ),
          ),
        ),
        MyTextButton(
          child: Text(AppLocalizations.of(context)!.update + ' ' + AppLocalizations.of(context)!.avatar.decapitalize()),
          shape: StadiumBorder(),
          onPressed: () async {
            final imageBase64 = await _pickedImage();
            final newProfile = profile.copyWith(photoUrl: imageBase64);
            context.read<HomeManager>().setProfile(newProfile);
            final isSuccessUpdateProfile = await FirestoreProviders().updateProfile(newProfile);
            print(isSuccessUpdateProfile);
            if (isSuccessUpdateProfile) {
              Utils().showToast(
                AppLocalizations.of(context)!.updated,
                backgroundColor: Colors.green.shade400,
              );
            } else {
              Utils().showToast(
                AppLocalizations.of(context)!.some_thing_went_wrong,
                backgroundColor: Colors.redAccent.shade400,
              );
            }
          },
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              profile.locale == 'vi' ? 'assets/images/ic_vi.png' : 'assets/images/ic_en.png',
              width: 24,
              height: 24,
            ),
            gapH4,
            Text(
              profile.name ?? 'Live Chat Account',
              style: context.textTheme.subtitle1?.copyWith(
                fontSize: 20,
                color: context.colorScheme.onSecondary,
                fontWeight: FontWeight.w900,
                overflow: TextOverflow.ellipsis,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
        gapV4,
        Text(
          '${AppLocalizations.of(context)!.contacts}: ' + (profile.email ?? 'Hacker user'),
          style: context.textTheme.subtitle1?.copyWith(
            fontSize: 16,
            color: context.colorScheme.onSecondary.withOpacity(0.8),
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
          textAlign: TextAlign.center,
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Visibility(
              child: Text(
                '${AppLocalizations.of(context)!.phone_number}: ${profile.phoneNumber ?? ""}',
                style: context.textTheme.subtitle1?.copyWith(
                  fontSize: 16,
                  color: context.colorScheme.onSecondary.withOpacity(0.8),
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
              visible: profile.phoneNumber != null,
            ),
            Visibility(
              child: MyTextButton(
                onPressed: () {
                  Utils().phoneVerifyPageType = PhoneVerifyPageType.UPDATE_PHONE;
                  Navigator.pushNamed(context, '/phone_verify');
                },
                child: Text(
                  AppLocalizations.of(context)!.update_your_number,
                  style: context.textTheme.subtitle1?.copyWith(
                    fontSize: 14,
                    color: context.colorScheme.onSecondary.withOpacity(0.8),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                shape: StadiumBorder(),
              ),
              visible: profile.phoneNumber == null,
            ),
          ],
        ),
        Visibility(
          visible: isShowMore,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    profile.isVerified == true ? Icons.check_rounded : Icons.close_rounded,
                    color: profile.isVerified == true ? Colors.greenAccent.shade700 : context.colorScheme.error,
                  ),
                  gapH4,
                  Text(
                    profile.isVerified == true
                        ? AppLocalizations.of(context)!.account_verified
                        : AppLocalizations.of(context)!.account_unverified,
                    style: context.textTheme.subtitle1?.copyWith(
                      fontSize: 13,
                      color: profile.isVerified == true ? Colors.greenAccent.shade700 : context.colorScheme.error,
                      fontWeight: FontWeight.w900,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Visibility(
                    child: MyTextButton(
                      child: Text(AppLocalizations.of(context)!.update),
                      shape: StadiumBorder(),
                    ),
                    visible: profile.isVerified != true,
                  )
                ],
              ),
              gapV4,
              Text(
                "${AppLocalizations.of(context)!.account_creation_time}: " +
                    DateFormat.yMEd(profile.locale ?? 'en').format(profile.createdAt!) +
                    " " +
                    DateFormat.Hms(profile.locale ?? 'en').format(profile.createdAt!),
                style: context.textTheme.subtitle1?.copyWith(
                  fontSize: 13,
                  color: context.colorScheme.onTertiary,
                  fontWeight: FontWeight.w900,
                ),
                textAlign: TextAlign.center,
              ),
              gapV4,
              Text(
                "${AppLocalizations.of(context)!.last_login}: " +
                    DateFormat.yMEd(profile.locale ?? 'en').format(profile.lastSignInTime!) +
                    " " +
                    DateFormat.Hms(profile.locale ?? 'en').format(profile.lastSignInTime!),
                style: context.textTheme.subtitle1?.copyWith(
                  fontSize: 13,
                  color: context.colorScheme.onTertiary,
                  fontWeight: FontWeight.w900,
                ),
                textAlign: TextAlign.center,
              ),
              gapV4,
              Text(
                "${AppLocalizations.of(context)!.account_type}: " + ((profile.providerId ?? 'unknown').capitalize()),
                style: context.textTheme.subtitle1?.copyWith(
                  fontSize: 13,
                  color: context.colorScheme.onTertiary,
                  fontWeight: FontWeight.w900,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        FloatingActionButton(
          onPressed: () {
            onClickShowMore();
          },
          mini: true,
          backgroundColor: context.colorScheme.background,
          splashColor: context.colorScheme.primary,
          child: Icon(
            isShowMore ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
            color: context.colorScheme.onBackground,
          ),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}

Future<String?> _pickedImage() async {
  XFile? image = await ImagePicker().pickImage(
    source: ImageSource.gallery,
    imageQuality: 50,
    preferredCameraDevice: CameraDevice.front,
  );

  if (image != null) {
    final bytes = File(image.path).readAsBytesSync();
    String img64 = base64Encode(bytes);
    return img64;
  }
  {
    return null;
  }
}

Widget _buildRowLanguageOptionSetting(BuildContext context) {
  final isVietnamese = context.select<ThemeManager, bool>(((themeManager) => themeManager.locale.languageCode == 'vi'));
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.language,
              style: context.textTheme.subtitle1?.copyWith(
                fontSize: 18,
                color: context.colorScheme.onPrimary,
                fontWeight: FontWeight.w900,
              ),
              textAlign: TextAlign.start,
            ),
          ),
          Image.asset(
            isVietnamese ? 'assets/images/ic_vi.png' : 'assets/images/ic_en.png',
            width: 24,
            height: 24,
            fit: BoxFit.cover,
            isAntiAlias: false,
          ),
          gapH8,
          Text(
            isVietnamese ? AppLocalizations.of(context)!.vi : AppLocalizations.of(context)!.en,
            style: context.textTheme.subtitle1?.copyWith(
              fontSize: 16,
              color: context.colorScheme.onPrimary,
              fontWeight: FontWeight.w900,
            ),
            textAlign: TextAlign.start,
          ),
          UvidPopupMenu<LanguageType>(
            values: LanguageType.values,
            initialValue: context.read<ThemeManager>().locale.languageCode == 'vi' ? LanguageType.VI : LanguageType.EN,
            onUvidPopupSelected: (type) {
              context.read<ThemeManager>().toggleLocale(type);
            },
            dropdownColor: context.colorScheme.onPrimary,
          )
        ],
      ),
    ),
  );
}

Widget _buildRowDarkModeOptionSetting(BuildContext context) {
  final isDarkmode = context.select<ThemeManager, bool>(((themeManager) => themeManager.themeMode == ThemeMode.dark));
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.display_mode,
              style: context.textTheme.subtitle1?.copyWith(
                fontSize: 18,
                color: context.colorScheme.onPrimary,
                fontWeight: FontWeight.w900,
              ),
              textAlign: TextAlign.start,
            ),
          ),
          Image.asset(
            isDarkmode ? 'assets/images/ic_dark_mode.png' : 'assets/images/ic_light_mode.png',
            height: 24,
            fit: BoxFit.cover,
            isAntiAlias: false,
          ),
          gapH8,
          Text(
            isDarkmode ? AppLocalizations.of(context)!.dark_mode : AppLocalizations.of(context)!.light_mode,
            style: context.textTheme.subtitle1?.copyWith(
              fontSize: 16,
              color: context.colorScheme.onPrimary,
              fontWeight: FontWeight.w900,
            ),
            textAlign: TextAlign.start,
          ),
          UvidPopupMenu<bool>(
            values: [true, false],
            initialValue: isDarkmode,
            onUvidPopupSelected: (type) {
              context.read<ThemeManager>().toggleTheme(type);
            },
            dropdownColor: context.colorScheme.onPrimary,
          )
        ],
      ),
    ),
  );
}

Widget buildRowMuteAudioOptionSetting(BuildContext context) {
  final isMuteAudio = context.select<HomeManager, bool>(((homeManager) => homeManager.isMuteAudio));
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.audio,
              style: context.textTheme.subtitle1?.copyWith(
                fontSize: 18,
                color: context.colorScheme.onPrimary,
                fontWeight: FontWeight.w900,
              ),
              textAlign: TextAlign.start,
            ),
          ),
          Image.asset(
            isMuteAudio ? 'assets/images/ic_mute_voice.png' : 'assets/images/ic_voice.png',
            width: 24,
            height: 24,
            fit: BoxFit.cover,
            isAntiAlias: false,
            color: context.colorScheme.onPrimary,
          ),
          gapH8,
          Text(
            isMuteAudio ? AppLocalizations.of(context)!.off : AppLocalizations.of(context)!.on,
            style: context.textTheme.subtitle1?.copyWith(
              fontSize: 16,
              color: context.colorScheme.onPrimary,
              fontWeight: FontWeight.w900,
            ),
            textAlign: TextAlign.start,
          ),
          UvidPopupMenu<AudioMode>(
            values: AudioMode.values,
            initialValue: isMuteAudio ? AudioMode.OFF : AudioMode.ON,
            onUvidPopupSelected: (type) {
              context.read<HomeManager>().onChangeMuteAudio(type);
            },
            dropdownColor: context.colorScheme.onPrimary,
          )
        ],
      ),
    ),
  );
}

Widget buildRowMuteVideoOptionSetting(BuildContext context) {
  final isMuteVideo = context.select<HomeManager, bool>(((homeManager) => homeManager.isMuteVideo));
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              'Video',
              style: context.textTheme.subtitle1?.copyWith(
                fontSize: 18,
                color: context.colorScheme.onPrimary,
                fontWeight: FontWeight.w900,
              ),
              textAlign: TextAlign.start,
            ),
          ),
          Image.asset(
            isMuteVideo ? 'assets/images/ic_no_video.png' : 'assets/images/ic_video.png',
            width: 24,
            height: 24,
            fit: BoxFit.cover,
            isAntiAlias: false,
            color: context.colorScheme.onPrimary,
          ),
          gapH8,
          Text(
            isMuteVideo ? AppLocalizations.of(context)!.off : AppLocalizations.of(context)!.on,
            style: context.textTheme.subtitle1?.copyWith(
              fontSize: 16,
              color: context.colorScheme.onPrimary,
              fontWeight: FontWeight.w900,
            ),
            textAlign: TextAlign.start,
          ),
          UvidPopupMenu<VideoMode>(
            values: VideoMode.values,
            initialValue: isMuteVideo ? VideoMode.OFF : VideoMode.ON,
            onUvidPopupSelected: (type) {
              context.read<HomeManager>().onChangeMuteVideo(type);
            },
            dropdownColor: context.colorScheme.onPrimary,
          )
        ],
      ),
    ),
  );
}

Widget _buildRowNotificationOptionSetting(BuildContext context) {
  final isMuteNotification = context.select<HomeManager, bool>(((homeManager) => homeManager.isMuteNotification));
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.notification,
              style: context.textTheme.subtitle1?.copyWith(
                fontSize: 18,
                color: context.colorScheme.onPrimary,
                fontWeight: FontWeight.w900,
              ),
              textAlign: TextAlign.start,
            ),
          ),
          Icon(
            isMuteNotification ? Icons.notifications_off_rounded : Icons.notifications_on_rounded,
            size: 24,
            color: context.colorScheme.onPrimary,
          ),
          gapH8,
          Text(
            isMuteNotification ? AppLocalizations.of(context)!.off : AppLocalizations.of(context)!.on,
            style: context.textTheme.subtitle1?.copyWith(
              fontSize: 16,
              color: context.colorScheme.onPrimary,
              fontWeight: FontWeight.w900,
            ),
            textAlign: TextAlign.start,
          ),
          UvidPopupMenu<NotificationMode>(
            values: NotificationMode.values,
            initialValue: isMuteNotification ? NotificationMode.OFF : NotificationMode.ON,
            onUvidPopupSelected: (type) {
              context.read<HomeManager>().onChangeMuteNotification(type);
            },
            dropdownColor: context.colorScheme.onPrimary,
          )
        ],
      ),
    ),
  );
}

void _showFullScreenImage(BuildContext context, Widget image) {
  showGeneralDialog(
    context: context,
    barrierColor: Colors.black12.withOpacity(0.6), // Background color
    barrierDismissible: false,
    barrierLabel: 'Dialog',
    transitionDuration: Duration(milliseconds: 400),
    pageBuilder: (_, __, ___) {
      return Column(
        children: <Widget>[
          Expanded(flex: 6, child: image),
          Expanded(
            flex: 1,
            child: SizedBox.expand(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  AppLocalizations.of(context)!.off,
                  style: context.textTheme.subtitle1?.copyWith(
                    fontSize: 30,
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}
