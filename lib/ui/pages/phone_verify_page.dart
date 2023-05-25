import 'dart:math';

import 'package:fl_country_code_picker/fl_country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'package:uvid/common/extensions.dart';
import 'package:uvid/data/local_storage.dart';
import 'package:uvid/domain/models/phone_verify_screen_type.dart';
import 'package:uvid/domain/models/profile.dart';
import 'package:uvid/providers/auth.dart';
import 'package:uvid/providers/firestore.dart';
import 'package:uvid/ui/widgets/elevated_button.dart';
import 'package:uvid/ui/widgets/gap.dart';
import 'package:uvid/utils/routes.dart';
import 'package:uvid/utils/state_managment/contact_manager.dart';
import 'package:uvid/utils/state_managment/home_manager.dart';
import 'package:uvid/utils/utils.dart';

class PhoneVerifyPage extends StatefulWidget {
  const PhoneVerifyPage({super.key});

  @override
  State<PhoneVerifyPage> createState() => _PhoneVerifyPageState();
}

class _PhoneVerifyPageState extends State<PhoneVerifyPage> {
  late AuthProviders _authProviders;
  CountryCode? _code = null;
  String phoneNumber = '';

  final _countryPicker = const FlCountryCodePicker(
    showDialCode: true,
    showSearchBar: true,
  );

  TextEditingController _phoneController = TextEditingController(text: '');
  bool _isRequestOTPAvailable = false;
  bool _isLoadingVerifyOTP = false;
  bool _isConfirmOTP = false;
  final formKey = GlobalKey<FormState>();
  final pinController = TextEditingController();
  final focusNode = FocusNode();
  String _verificationId = '';
  @override
  void initState() {
    super.initState();
    _authProviders = AuthProviders();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        foregroundColor: context.colorScheme.onPrimary,
        title: Text(
          _isConfirmOTP ? 'OTP' : AppLocalizations.of(context)!.phone_verify,
          style: context.textTheme.bodyText1?.copyWith(
            color: context.colorScheme.onPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Image.asset(
            _isConfirmOTP ? 'assets/images/otp.png' : 'assets/images/phone_verify.png',
            filterQuality: FilterQuality.medium,
            height: MediaQuery.of(context).size.height / 3,
            width: MediaQuery.of(context).size.height / 3,
            alignment: Alignment.center,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            child: Text(
              _isConfirmOTP
                  ? AppLocalizations.of(context)!.sent_verification_code + '\n${_code?.dialCode}$phoneNumber'
                  : AppLocalizations.of(context)!.phone_number,
              style: context.textTheme.bodyText1?.copyWith(
                color: context.colorScheme.onPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
              textAlign: _isConfirmOTP ? TextAlign.center : TextAlign.start,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: _isConfirmOTP
                ? _buildOTPConFirm(context)
                : Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: context.colorScheme.onPrimary,
                        strokeAlign: StrokeAlign.inside,
                      ),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () async {
                            _code = await _countryPicker.showPicker(context: context);
                            if (_code != null) {
                              setState(() {
                                if (phoneNumber.length >= 9 && _code != null) _isRequestOTPAvailable = true;
                              });
                            }
                          },
                          child: Row(
                            children: [
                              if (_code?.flagImage != null) ...[
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(5),
                                  child: _code!.flagImage,
                                  clipBehavior: Clip.antiAlias,
                                ),
                                gapH4,
                                Text(
                                  _code!.dialCode,
                                  style: context.textTheme.bodyText1?.copyWith(
                                    color: context.colorScheme.onPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                              Icon(
                                Icons.arrow_drop_down_rounded,
                                color: context.colorScheme.onPrimary,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 28,
                          color: context.colorScheme.onPrimary,
                          width: 1,
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: TextField(
                              controller: _phoneController,
                              maxLines: 1,
                              textAlign: TextAlign.start,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: AppLocalizations.of(context)!.phone_number,
                                hintStyle: TextStyle(color: Colors.grey.shade300),
                              ),
                              cursorWidth: 2,
                              cursorRadius: Radius.circular(20),
                              cursorColor: context.colorScheme.onBackground,
                              style: context.textTheme.bodyText1,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9]'),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  phoneNumber = value;
                                  if (phoneNumber.length >= 9 && _code != null) _isRequestOTPAvailable = true;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
          gapV24,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: _isConfirmOTP
                ? null
                : MyElevatedButton(
                    onPressed: () {
                      final phone = _code!.dialCode + phoneNumber;
                      Utils().showToast(AppLocalizations.of(context)!.requested_otp);
                      _isRequestOTPAvailable = false;
                      _authProviders.requestOTP(
                        phone,
                        (verificationId) {
                          setState(() {
                            _isRequestOTPAvailable = true;
                            _verificationId = verificationId;
                            _isConfirmOTP = true;
                          });
                        },
                        onException: (ex) {
                          setState(() {
                            _isRequestOTPAvailable = true;
                            _isConfirmOTP = true;
                          });
                        },
                      );
                    },
                    backgroundColor: context.colorScheme.error,
                    child: Text(
                      AppLocalizations.of(context)!.request_otp,
                      style: context.textTheme.bodyText1?.copyWith(
                        color: context.colorScheme.onError,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    isEnabled: _isRequestOTPAvailable,
                  ),
          ),
          gapV24,
          if (_isConfirmOTP)
            InkWell(
              onTap: () {
                setState(() {
                  _isConfirmOTP = false;
                  _isLoadingVerifyOTP = false;
                  pinController.clear();
                });
              },
              borderRadius: BorderRadius.circular(20),
              child: Text(
                AppLocalizations.of(context)!.did_not_received_otp,
                style: context.textTheme.bodyText1?.copyWith(
                  color: context.colorScheme.onError,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOTPConFirm(
    BuildContext context,
  ) {
    final focusedBorderColor = context.colorScheme.onPrimary;
    final fillColor = context.colorScheme.secondary;
    final borderColor = Colors.grey;
    final size = min(56, MediaQuery.of(context).size.width / 6).toDouble();
    final defaultPinTheme = PinTheme(
      width: size,
      height: size,
      textStyle: context.textTheme.bodyText1?.copyWith(
        color: context.colorScheme.onSecondary,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: borderColor),
      ),
    );
    return Form(
      key: formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Directionality(
            textDirection: TextDirection.ltr,
            child: Pinput(
              length: 6,
              controller: pinController,
              focusNode: focusNode,
              androidSmsAutofillMethod: AndroidSmsAutofillMethod.smsUserConsentApi,
              listenForMultipleSmsOnAndroid: true,
              defaultPinTheme: defaultPinTheme,
              hapticFeedbackType: HapticFeedbackType.lightImpact,
              onCompleted: (pin) async {
                print(pin);
                setState(() {
                  _isLoadingVerifyOTP = true;
                });
                final isOK = await _authProviders.verifyOTP(
                  _verificationId,
                  pin.trim(),
                  isJustVerify: PhoneVerifyPageType.UPDATE_PHONE == Utils().phoneVerifyPageType,
                  onException: (ex) {
                    setState(() {
                      _isLoadingVerifyOTP = false;
                    });
                  },
                  onPhoneCallback: (phone) async {
                    final profile = await LocalStorage().getProfile();
                    if (profile != null) {
                      final newProfile = profile.copyWith(phoneNumber: phone);
                      final isUpdatePhoneSuccessfully = await FirestoreProviders().updateProfile(newProfile);
                      if (isUpdatePhoneSuccessfully) {
                        context.read<HomeManager>().setProfile(newProfile);
                        Utils().showToast(AppLocalizations.of(context)!.updated);
                        Navigator.pushNamedAndRemoveUntil(context, AppRoutesDirect.home.route, (route) {
                          return route.settings.name == "/home";
                        });
                      }
                    }
                  },
                );
                if (isOK) {
                  LocalStorage().getProfile().then((value) {
                    if (value != null && PhoneVerifyPageType.REGISTER == Utils().phoneVerifyPageType) {
                      context.read<HomeManager>().setProfile(value);
                      context.read<ContactManager>().loadInitData();
                      Navigator.pushNamedAndRemoveUntil(context, AppRoutesDirect.home.route, (route) {
                        return route.settings.name == "/home";
                      });
                    }
                  });
                } else {
                  Utils().showToast(
                    'OTP failure',
                    backgroundColor: Colors.redAccent.shade200,
                  );
                }
              },
              onChanged: (value) {
                setState(() {
                  _isLoadingVerifyOTP = false;
                });
              },
              cursor: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 9),
                    width: 22,
                    height: 3,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: focusedBorderColor,
                    ),
                  ),
                ],
              ),
              focusedPinTheme: defaultPinTheme.copyWith(
                decoration: defaultPinTheme.decoration!.copyWith(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: focusedBorderColor),
                ),
              ),
              submittedPinTheme: defaultPinTheme.copyWith(
                decoration: defaultPinTheme.decoration!.copyWith(
                  color: fillColor,
                  borderRadius: BorderRadius.circular(19),
                  border: Border.all(color: focusedBorderColor),
                ),
              ),
              errorPinTheme: defaultPinTheme.copyBorderWith(
                border: Border.all(color: Colors.redAccent),
              ),
            ),
          ),
          gapV12,
          _isLoadingVerifyOTP
              ? CircularProgressIndicator(
                  color: context.colorScheme.onPrimary,
                )
              : SizedBox()
        ],
      ),
    );
  }
}
