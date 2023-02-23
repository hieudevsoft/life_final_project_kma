class CustomJitsiConfigOptions {
  final String room;
  final String? serverURL;
  final String? subject;
  final String? token;
  final bool? audioMuted;
  final bool? audioOnly;
  final bool? videoMuted;
  final String? userDisplayName;
  final String? userAuthencation;
  final String? userAvatarURL;

  CustomJitsiConfigOptions({
    required this.room,
    this.serverURL,
    this.subject,
    this.token,
    this.audioMuted,
    this.audioOnly,
    this.videoMuted,
    this.userDisplayName,
    this.userAuthencation,
    this.userAvatarURL,
  });
}
