import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/material.dart';
import 'package:uvid/utils/colors.dart';

const String MEETING_COOLECTION = "meetings";
const String USER_COLLECTION = 'user';
const String FRIEND_COLLECTION = 'friend';
const String WAITING_ACCEPT_FRIEND_COLLECTION = 'waiting_accept_friend';
const String SENDER_CALL_COLLECTION = 'sender_call';
const String WAITING_ACCEPT_CALL_COLLECTION = 'waiting_accept_call';
const String APP_NAME = 'Life';
const String serverUrl = "https://alpha.jitsi.net";
final keyAes = encrypt.Key.fromBase64('Q1aOOcpDHh8Gn3oSCPP8ZTYOaB1HpwM8kLJfbK0cAVE=');
final iv = encrypt.IV.fromBase64('ZsM/zT2AxQytn3KgxJPivw==');
const mode = encrypt.AESMode.cbc;

OutlineInputBorder inputBorder = OutlineInputBorder(
  borderRadius: BorderRadius.circular(7),
  borderSide: BorderSide(
    width: 2,
    color: AppColors.lightNavyBlue,
  ),
);

InputDecoration get inputDecoration => InputDecoration(
      border: inputBorder,
      disabledBorder: inputBorder,
      errorBorder: inputBorder.copyWith(
        borderSide: BorderSide(
          width: 2,
          color: AppColors.red,
        ),
      ),
      enabledBorder: inputBorder,
      focusedBorder: inputBorder,
      focusedErrorBorder: inputBorder,
      hintText: "Event Title",
      hintStyle: TextStyle(
        color: AppColors.black,
        fontSize: 17,
      ),
      labelStyle: TextStyle(
        color: AppColors.black,
        fontSize: 17,
      ),
      helperStyle: TextStyle(
        color: AppColors.black,
        fontSize: 17,
      ),
      errorStyle: TextStyle(
        color: AppColors.red,
        fontSize: 12,
      ),
      contentPadding: EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 20,
      ),
    );
