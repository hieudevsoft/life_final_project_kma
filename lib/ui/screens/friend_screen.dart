import 'package:flutter/material.dart';
import 'package:uvid/common/extensions.dart';
import 'package:uvid/ui/widgets/bouncing_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FriendScreen extends StatefulWidget {
  const FriendScreen({super.key});

  @override
  State<FriendScreen> createState() => _FriendScreenState();
}

class _FriendScreenState extends State<FriendScreen> {
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
              onClickListener: () {},
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
      body: SizedBox(),
    );
  }
}
