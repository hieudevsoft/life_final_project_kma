import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:uvid/common/extensions.dart';
import 'package:uvid/domain/models/friend_model.dart';
import 'package:uvid/domain/models/profile.dart';
import 'package:uvid/ui/pages/home_page.dart';
import 'package:uvid/ui/widgets/bouncing_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:uvid/ui/widgets/gap.dart';
import 'package:uvid/utils/notifications.dart';
import 'package:uvid/utils/state_managment/friend_manager.dart';

import '../../utils/utils.dart';

class FriendScreen extends StatefulWidget {
  const FriendScreen({super.key});

  @override
  State<FriendScreen> createState() => _FriendScreenState();
}

class _FriendScreenState extends State<FriendScreen> with TickerProviderStateMixin {
  late AnimationController _scaleAnimationController;
  late Animation<double> _scaleAnimation;
  @override
  void initState() {
    super.initState();
    _scaleAnimationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
      lowerBound: 0.3,
      upperBound: 1,
    );
    _scaleAnimation = CurvedAnimation(parent: _scaleAnimationController, curve: Curves.fastOutSlowIn);
    _scaleAnimationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _scaleAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.tertiary,
      appBar: AppBar(
        elevation: 1,
        title: Text(
          AppLocalizations.of(context)!.friend,
          style: context.textTheme.bodyText1?.copyWith(
            color: context.colorScheme.onPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: BouncingButton(
              child: Icon(Icons.change_circle_rounded),
              onClickListener: () {
                context.read<FriendManager>().reloadFriend(
                  onUnAvailable: () {
                    Utils().showToast(
                      AppLocalizations.of(context)!.unavailable_get_frined,
                      backgroundColor: Colors.redAccent,
                      textColor: Colors.white,
                    );
                  },
                );
              },
            ),
          )
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(8),
            bottomRight: Radius.circular(8),
          ),
        ),
      ),
      body: _buildBody(
        context,
        onPhoneCall: (profile) {
          context.read<FriendManager>().callToFriend(
            profile,
            () {
              _buildDialogPhoneCall(profile, context);
            },
            (meetingID) {
              joinMeeting(context, meetingID, false);
            },
          );
        },
        onRemovedFriend: (profile) {
          context.read<FriendManager>().removeFriend(profile, () {
            Utils().showToast(
              AppLocalizations.of(context)!.unfriend_successfully,
              backgroundColor: Colors.greenAccent,
              textColor: Colors.white,
            );
          });
        },
      ),
    );
  }

  _buildDialogPhoneCall(Profile profile, BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: Icon(Icons.phone_enabled_rounded),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        iconColor: context.colorScheme.onPrimary,
        backgroundColor: context.colorScheme.primary,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(30)),
                child: profile.photoUrl == null
                    ? Image.asset(
                        'assets/ic_launcher.png',
                        fit: BoxFit.cover,
                        width: 60,
                        height: 60,
                      )
                    : profile.avatarUrlIsLink
                        ? Image.network(
                            profile.photoUrl!,
                            fit: BoxFit.cover,
                            width: 60,
                            height: 60,
                          )
                        : Image.memory(
                            base64Decode(profile.photoUrl!),
                            fit: BoxFit.cover,
                            width: 60,
                            height: 60,
                          ),
              ),
            ),
            Text(
              '${profile.name == null ? 'No name' : profile.name}',
              style: context.textTheme.bodyText1?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${profile.email == null ? profile.phoneNumber : profile.email}',
              style: context.textTheme.bodyText1?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(
              height: 12,
            ),
            ScaleTransition(
              scale: _scaleAnimation,
              child: FloatingActionButton(
                heroTag: null,
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                splashColor: getEndColorCute(3),
                elevation: 12,
                mini: true,
                child: Icon(Icons.phone_disabled_rounded),
                onPressed: () {
                  context.read<FriendManager>().cancelCalling();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildBody(
  BuildContext context, {
  required Function(Profile)? onPhoneCall,
  required Function(Profile)? onRemovedFriend,
}) {
  final List<Profile>? friends = context.watch<FriendManager>().friends;
  if (friends == null) {
    return Center(
      child: CircularProgressIndicator(),
    );
  } else if (friends.isEmpty) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            clipBehavior: Clip.antiAliasWithSaveLayer,
            child: Image.asset(
              'assets/images/no_data.jpg',
              width: context.screenWidth / 2,
            ),
          ),
          gapV8,
          Text(
            AppLocalizations.of(context)!.no_result,
            style: context.textTheme.bodyText1?.copyWith(
              color: context.colorScheme.onTertiary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  } else {
    return GridView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: friends.length,
      itemBuilder: (ctx, i) {
        final friend = friends[i];
        return Card(
          elevation: 6,
          color: context.colorScheme.tertiary,
          shadowColor: context.colorScheme.onTertiary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
                      child: friend.photoUrl == null
                          ? Image.asset(
                              'assets/ic_launcher.png',
                              fit: BoxFit.cover,
                            )
                          : friend.avatarUrlIsLink
                              ? Image.network(
                                  friend.photoUrl!,
                                  fit: BoxFit.cover,
                                )
                              : Image.memory(
                                  base64Decode(friend.photoUrl!),
                                  fit: BoxFit.cover,
                                ),
                    ),
                  ),
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            friend.name ?? 'Life',
                            style: context.textTheme.bodyText1?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: context.colorScheme.onTertiary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          gapV4,
                          Text(
                            friend.email ?? friend.phoneNumber ?? '',
                            style: context.textTheme.bodyText1?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: context.colorScheme.onTertiary,
                              fontSize: 12,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          gapV4,
                          Row(
                            children: [
                              Icon(
                                friend.isVerified == true ? Icons.check_rounded : Icons.close_rounded,
                                color: friend.isVerified == true ? Colors.greenAccent.shade700 : context.colorScheme.error,
                                size: 12,
                              ),
                              gapH4,
                              Expanded(
                                child: Text(
                                  friend.isVerified == true
                                      ? AppLocalizations.of(context)!.account_verified
                                      : AppLocalizations.of(context)!.account_unverified,
                                  style: context.textTheme.subtitle1?.copyWith(
                                    fontSize: 12,
                                    color: friend.isVerified == true ? Colors.greenAccent.shade700 : context.colorScheme.error,
                                    fontWeight: FontWeight.w900,
                                  ),
                                  softWrap: false,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.start,
                                ),
                              ),
                            ],
                          ),
                          gapH12,
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              FloatingActionButton(
                                heroTag: null,
                                backgroundColor: Colors.redAccent,
                                foregroundColor: Colors.white,
                                splashColor: getEndColorCute(i),
                                elevation: 12,
                                mini: true,
                                child: Icon(Icons.person_off_rounded),
                                onPressed: () {
                                  onRemovedFriend?.call(friend);
                                },
                              ),
                              FloatingActionButton(
                                heroTag: null,
                                backgroundColor: Colors.greenAccent,
                                foregroundColor: Colors.white,
                                splashColor: getEndColorCute(i),
                                elevation: 12,
                                mini: true,
                                child: Icon(Icons.phone_rounded),
                                onPressed: () {
                                  onPhoneCall?.call(friend);
                                },
                              ),
                            ],
                          )
                        ],
                      )),
                ],
              ),
            ],
          ),
        );
      },
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 12,
        mainAxisSpacing: 5,
      ),
    );
  }
}
