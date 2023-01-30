import 'package:flutter/material.dart';
import 'package:uvid/common/extensions.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

typedef OnUvidPopupSelected<T> = Function(T value);

class UvidPopupMenu<T> extends StatelessWidget {
  final List<T> values;
  final OnUvidPopupSelected onUvidPopupSelected;
  final T initialValue;
  final Color dropdownColor;
  const UvidPopupMenu({
    super.key,
    required this.values,
    required this.onUvidPopupSelected,
    required this.initialValue,
    required this.dropdownColor,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
      ),
      child: PopupMenuButton<T>(
        onSelected: onUvidPopupSelected,
        padding: EdgeInsets.zero,
        color: context.colorScheme.secondary,
        itemBuilder: (BuildContext context) {
          return values
              .map(
                (e) => PopupMenuItem<T>(
                  value: e,
                  padding: EdgeInsets.only(left: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.typeAsString(e),
                        style: context.textTheme.bodyText1?.copyWith(
                          fontSize: 16,
                          color: context.colorScheme.onSecondary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Checkbox(
                        value: initialValue == e,
                        onChanged: (value) {
                          Navigator.pop(context);
                          onUvidPopupSelected(e);
                        },
                        activeColor: context.colorScheme.primary,
                        checkColor: context.colorScheme.onPrimary,
                        shape: StadiumBorder(),
                      )
                    ],
                  ),
                ),
              )
              .toList();
        },
        position: PopupMenuPosition.under,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Icon(
          Icons.arrow_drop_down_rounded,
          color: dropdownColor,
        ),
      ),
    );
  }
}
