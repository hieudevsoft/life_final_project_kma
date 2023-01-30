import 'package:flutter/material.dart';
import 'package:uvid/common/extensions.dart';

class MeetingOption extends StatelessWidget {
  final String text;
  final bool isMute;
  final Function(bool) onChange;
  const MeetingOption({
    Key? key,
    required this.text,
    required this.isMute,
    required this.onChange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          text,
          style: context.textTheme.subtitle1?.copyWith(
            fontSize: 18,
            color: context.colorScheme.onPrimary,
            fontWeight: FontWeight.w900,
          ),
          textAlign: TextAlign.start,
        ),
        Switch.adaptive(
          value: isMute,
          onChanged: onChange,
        ),
      ],
    );
  }
}
