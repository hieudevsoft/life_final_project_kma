import 'package:flutter/material.dart';
import 'package:uvid/ui/widgets/gap.dart';

class HomeMeetingButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final Color color;
  final Color iconColor;
  final Widget? footer;
  final bool isHasBaged;
  const HomeMeetingButton({
    Key? key,
    required this.onPressed,
    required this.icon,
    required this.color,
    required this.iconColor,
    this.footer,
    this.isHasBaged = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onPressed,
        child: Stack(
          children: [
            Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 10,
                        color: Colors.black.withOpacity(0.06),
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  width: 60,
                  height: 60,
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 30,
                  ),
                ),
                gapV8,
                if (footer != null) ...[footer!]
              ],
            ),
            Visibility(
              visible: isHasBaged,
              child: Positioned(
                right: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.redAccent.shade200,
                  ),
                ),
              ),
            )
          ],
        ));
  }
}
