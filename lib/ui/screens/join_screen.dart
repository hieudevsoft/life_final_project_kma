import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:jitsi_meet/jitsi_meet.dart';
import 'package:provider/provider.dart';
import 'package:uvid/common/extensions.dart';
import 'package:uvid/domain/models/custom_jitsi_config_options.dart';
import 'package:uvid/providers/jitsimeet.dart';
import 'package:uvid/ui/widgets/elevated_button.dart';
import 'package:uvid/ui/widgets/gap.dart';
import 'package:uvid/utils/state_managment/home_manager.dart';
import 'package:uvid/utils/utils.dart';

class JoinScreen extends StatefulWidget {
  const JoinScreen({super.key});

  @override
  State<JoinScreen> createState() => _JoinScreenState();
}

class _JoinScreenState extends State<JoinScreen> {
  late TextEditingController meetingIdController;
  late TextEditingController nameController;
  late TextEditingController userAvatarURLController;

  @override
  void initState() {
    super.initState();
    meetingIdController = TextEditingController(text: '');
    nameController = TextEditingController(text: '');
    userAvatarURLController = TextEditingController(text: '');
  }

  _joinMeeting(BuildContext context) {
    final profile = context.read<HomeManager>().profile;
    final userDisplayName = nameController.text.isEmpty
        ? profile?.name == null
            ? profile?.phoneNumber == null
                ? ''
                : profile!.phoneNumber
            : profile!.email
        : nameController.text;
    String avatarProfile = '';
    if (profile != null) {
      avatarProfile = profile.avatarUrlIsLink ? profile.photoUrl ?? '' : '';
    }
    final userAvatar = userAvatarURLController.text.isEmpty ? avatarProfile : userAvatarURLController.text;
    final CustomJitsiConfigOptions jitsiConfigOptions = CustomJitsiConfigOptions(
      room: meetingIdController.text,
      audioMuted: context.read<HomeManager>().isMuteAudio,
      videoMuted: context.read<HomeManager>().isMuteAudio,
      userDisplayName: userDisplayName,
      userAvatarURL: userAvatar,
      userAuthencation: profile?.email ?? profile?.phoneNumber,
    );
    JitsiMeetProviders().createMeeting(
      customJitsiConfigOptions: jitsiConfigOptions,
      isOwnerRoom: false,
      onRoomIdNotSetup: () {
        Utils().showToast(
          AppLocalizations.of(context)!.room_id_must_not_empty,
          backgroundColor: Colors.redAccent.shade200,
        );
      },
      onError: () {
        Utils().showToast(
          AppLocalizations.of(context)!.some_thing_went_wrong,
          backgroundColor: Colors.redAccent.shade200,
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    meetingIdController.dispose();
    nameController.dispose();
    userAvatarURLController.dispose();
    JitsiMeet.removeAllListeners();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          AppLocalizations.of(context)!.join_meeting,
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
                  Row(
                    children: [
                      InkWell(
                        onTap: () async {
                          final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
                          if (clipboardData == null) return;
                          print(clipboardData.text);
                          setState(() {
                            meetingIdController = TextEditingController(text: clipboardData.text ?? '');
                          });
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Ink(
                          padding: EdgeInsetsDirectional.all(8.0),
                          child: Icon(
                            Icons.cleaning_services_rounded,
                            color: context.colorScheme.onPrimary,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () async {
                          if (meetingIdController.text.isEmpty) {
                            Utils().showToast(
                              AppLocalizations.of(context)!.room_id_must_not_empty,
                              backgroundColor: Colors.redAccent.shade200,
                              textColor: Colors.white,
                            );
                          } else {
                            await Clipboard.setData(ClipboardData(text: meetingIdController.text));
                            Utils().showToast(
                              AppLocalizations.of(context)!.copied,
                              backgroundColor: Colors.greenAccent.shade200,
                              textColor: Colors.white,
                            );
                          }
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Ink(
                          padding: EdgeInsetsDirectional.all(8.0),
                          child: Icon(
                            Icons.copy_rounded,
                            color: context.colorScheme.onPrimary,
                          ),
                        ),
                      ),
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
                  )
                ],
              ),
              gapV4,
              _buildTextFieldOption(context, meetingIdController, AppLocalizations.of(context)!.room_id),
              gapV12,
              _buildTextTitle(context, AppLocalizations.of(context)!.name),
              gapV4,
              _buildTextFieldOption(context, nameController, AppLocalizations.of(context)!.name),
              gapV12,
              _buildTextTitle(context, AppLocalizations.of(context)!.link_avatar),
              gapV4,
              _buildTextFieldOption(context, userAvatarURLController, AppLocalizations.of(context)!.link_avatar),
              gapV12,
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
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
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
                onChanged: (value) {
                  setState(() {});
                },
              ),
            ),
            Visibility(
              visible: controller.text.isNotEmpty,
              child: InkWell(
                onTap: () {
                  setState(() {
                    controller.clear();
                  });
                },
                borderRadius: BorderRadius.circular(20),
                child: Ink(
                  padding: EdgeInsetsDirectional.all(8.0),
                  child: Icon(
                    Icons.clear_rounded,
                    color: context.colorScheme.onPrimary,
                  ),
                ),
              ),
            )
          ],
        ));
  }
}
