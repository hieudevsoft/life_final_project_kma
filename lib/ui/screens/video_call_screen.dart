import 'package:flutter/material.dart';
import 'package:jitsi_meet/jitsi_meet.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:uvid/common/extensions.dart';
import 'package:uvid/domain/models/custom_jitsi_config_options.dart';
import 'package:uvid/domain/models/profile.dart';
import 'package:uvid/providers/auth.dart';
import 'package:uvid/providers/jitsimeet.dart';
import 'package:uvid/ui/screens/setting_screen.dart';
import 'package:uvid/ui/widgets/elevated_button.dart';
import 'package:uvid/ui/widgets/gap.dart';
import 'package:uvid/ui/widgets/meeting_option.dart';
import 'package:uvid/utils/state_managment/home_manager.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:uvid/utils/utils.dart';

class VideoCallScreen extends StatefulWidget {
  const VideoCallScreen({Key? key}) : super(key: key);

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  final AuthProviders _authMethods = AuthProviders();
  late TextEditingController meetingIdController;
  late TextEditingController nameController;
  late TextEditingController desController;
  late TextEditingController serverUrlController;
  late TextEditingController tokenController;
  late TextEditingController userAvatarURLController;
  bool audioOnly = false;
  bool isShowMoreOptions = false;

  final JitsiMeetProviders _jitsiMeetMethods = JitsiMeetProviders();

  @override
  void initState() {
    meetingIdController = TextEditingController();
    nameController = TextEditingController(
      text: _authMethods.currentUserFirebase?.displayName,
    );
    desController = TextEditingController();
    serverUrlController = TextEditingController();
    tokenController = TextEditingController();
    userAvatarURLController = TextEditingController();

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    meetingIdController.dispose();
    nameController.dispose();
    desController.dispose();
    serverUrlController.dispose();
    userAvatarURLController.dispose();
    tokenController.dispose();
    JitsiMeet.removeAllListeners();
  }

  _joinMeeting(BuildContext context) {
    final profile = context.read<HomeManager>().profile;
    final CustomJitsiConfigOptions jitsiConfigOptions = CustomJitsiConfigOptions(
        room: meetingIdController.text,
        audioMuted: context.read<HomeManager>().isMuteAudio,
        videoMuted: context.read<HomeManager>().isMuteAudio,
        userDisplayName: nameController.text.isEmpty
            ? profile?.name == null
                ? profile?.phoneNumber == null
                    ? ''
                    : profile!.phoneNumber
                : profile!.email
            : nameController.text,
        userAvatarURL: userAvatarURLController.text,
        subject: desController.text,
        serverURL: serverUrlController.text,
        token: tokenController.text,
        userAuthencation: profile?.email ?? profile?.phoneNumber,
        audioOnly: audioOnly);
    _jitsiMeetMethods.createMeeting(
      customJitsiConfigOptions: jitsiConfigOptions,
      onRoomIdNotSetup: () {
        Utils().showToast('Room is must note empty', backgroundColor: Colors.redAccent.shade200);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          AppLocalizations.of(context)!.new_meeting,
          style: context.textTheme.bodyText1?.copyWith(
            color: context.colorScheme.onPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              gapV12,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildTextTitle(context, AppLocalizations.of(context)!.room_id),
                  InkWell(
                    onTap: () {
                      setState(() {
                        meetingIdController = TextEditingController(text: getCustomUniqueId());
                      });
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Ink(
                      padding: EdgeInsetsDirectional.all(8.0),
                      child: Icon(
                        Icons.replay_circle_filled_rounded,
                        color: context.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              gapV4,
              _buildTextFieldOption(context, meetingIdController, AppLocalizations.of(context)!.room_id),
              gapV12,
              _buildTextTitle(context, AppLocalizations.of(context)!.description),
              gapV4,
              _buildTextFieldOption(context, desController, AppLocalizations.of(context)!.hint_des_meeting),
              gapV12,
              _buildTextTitle(context, AppLocalizations.of(context)!.name),
              gapV4,
              _buildTextFieldOption(context, nameController, AppLocalizations.of(context)!.link_avatar),
              gapV12,
              Align(
                alignment: Alignment.center,
                child: FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      isShowMoreOptions = !isShowMoreOptions;
                    });
                  },
                  mini: true,
                  backgroundColor: context.colorScheme.background,
                  splashColor: context.colorScheme.primary,
                  child: Icon(
                    isShowMoreOptions ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                    color: context.colorScheme.onBackground,
                  ),
                ),
              ),
              Visibility(
                visible: isShowMoreOptions,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _buildTextTitle(context, AppLocalizations.of(context)!.link_avatar),
                    gapV4,
                    _buildTextFieldOption(context, userAvatarURLController, AppLocalizations.of(context)!.hint_des_link_avatar),
                    gapV12,
                    _buildTextTitle(context, AppLocalizations.of(context)!.server_url),
                    gapV4,
                    _buildTextFieldOption(context, serverUrlController, AppLocalizations.of(context)!.hint_des_server_url),
                    gapV12,
                    _buildTextTitle(context, AppLocalizations.of(context)!.token),
                    gapV4,
                    _buildTextFieldOption(context, tokenController, AppLocalizations.of(context)!.hint_des_token),
                  ],
                ),
              ),
              gapV16,
              Align(
                alignment: Alignment.center,
                child: MyElevatedButton(
                  child: Text(
                    AppLocalizations.of(context)!.join_meeting,
                    style: context.textTheme.subtitle1?.copyWith(
                      fontSize: 16,
                      color: context.colorScheme.onTertiary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  backgroundColor: context.colorScheme.tertiary,
                  shadowColor: context.colorScheme.tertiary,
                  shape: StadiumBorder(),
                  isEnabled: true,
                  onPressed: () {
                    _joinMeeting(context);
                  },
                ),
              ),
              gapV24,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: MeetingOption(
                  text: AppLocalizations.of(context)!.audio_only,
                  isMute: audioOnly,
                  onChange: (change) {
                    setState(() {
                      audioOnly = !audioOnly;
                    });
                  },
                ),
              ),
              gapV8,
              Divider(
                color: context.colorScheme.onBackground,
              ),
              gapV12,
              buildRowMuteAudioOptionSetting(context),
              Visibility(
                visible: !audioOnly,
                child: Column(
                  children: [
                    gapV12,
                    Divider(
                      color: context.colorScheme.onBackground,
                    ),
                    gapV12,
                    buildRowMuteVideoOptionSetting(context),
                  ],
                ),
              ),
              gapV48,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextTitle(BuildContext context, String text) {
    return Text(
      text,
      style: context.textTheme.subtitle1?.copyWith(
        fontSize: 18,
        color: context.colorScheme.onBackground,
        fontWeight: FontWeight.w900,
      ),
      textAlign: TextAlign.start,
    );
  }

  Widget _buildTextFieldOption(
    BuildContext context,
    TextEditingController controller,
    String hint,
  ) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(60),
        color: context.colorScheme.background,
      ),
      child: TextField(
        controller: controller,
        maxLines: 1,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: TextStyle(color: context.colorScheme.onBackground.withOpacity(0.5)),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        ),
        cursorWidth: 2,
        cursorRadius: Radius.circular(20),
        cursorColor: context.colorScheme.onBackground,
        style: context.textTheme.bodyText1?.copyWith(
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
