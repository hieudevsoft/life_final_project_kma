import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uvid/common/extensions.dart';
import 'package:uvid/domain/models/audio_mode.dart';
import 'package:uvid/domain/models/language_type.dart';
import 'package:uvid/domain/models/video_mode.dart';
import 'package:uvid/ui/widgets/gap.dart';
import 'package:uvid/ui/widgets/meeting_option.dart';
import 'package:uvid/ui/widgets/popup_menu.dart';
import 'package:uvid/utils/home_manager.dart';
import 'package:uvid/utils/theme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkmode = context.select<ThemeManager, bool>(((themeManager) => themeManager.themeMode == ThemeMode.dark));
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      physics: BouncingScrollPhysics(),
      child: Column(
        children: [
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
                  _buildRowDarkModeOptionSetting(context, isDarkmode),
                  gapV12,
                  Divider(
                    color: context.colorScheme.onPrimary,
                    thickness: 1,
                  ),
                  gapV12,
                ],
              ),
            ),
          ),
          gapH24,
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
                  _buildRowMuteAudioOptionSetting(context),
                  gapV12,
                  Divider(
                    color: context.colorScheme.onPrimary,
                    thickness: 1,
                  ),
                  gapV12,
                  _buildRowMuteVideoOptionSetting(context),
                  gapV12,
                  Divider(
                    color: context.colorScheme.onPrimary,
                    thickness: 1,
                  ),
                  gapV12,
                ],
              ),
            ),
          ),
        ],
      ),
    );
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

Widget _buildRowDarkModeOptionSetting(BuildContext context, bool isDarkmode) {
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

Widget _buildRowMuteAudioOptionSetting(BuildContext context) {
  final isMuteAudio = context.watch<HomeManager>().isMuteAudio;
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

Widget _buildRowMuteVideoOptionSetting(BuildContext context) {
  final isMuteVideo = context.watch<HomeManager>().isMuteVideo;
  print(isMuteVideo);
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
