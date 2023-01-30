import 'package:flutter/material.dart';
import 'package:uvid/common/extensions.dart';
import 'package:uvid/ui/widgets/gap.dart';

Widget fullScreenLoadingWidget(BuildContext context) => Container(
      color: context.colorScheme.secondary,
      child: Center(
        widthFactor: 1,
        heightFactor: 1,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              clipBehavior: Clip.antiAliasWithSaveLayer,
              child: Image.asset(
                'assets/ic_launcher.png',
                width: 82,
              ),
            ),
            gapV12,
            Container(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(
                color: context.colorScheme.onTertiary,
                strokeWidth: 3,
              ),
            ),
          ],
        ),
      ),
    );
