import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/date_time_patterns.dart';
import 'package:provider/provider.dart';
import 'package:uvid/common/extensions.dart';
import 'package:uvid/domain/models/friend_model.dart';
import 'package:uvid/ui/widgets/bouncing_widget.dart';
import 'package:uvid/ui/widgets/gap.dart';
import 'package:uvid/ui/widgets/painter/custom_shape_painter.dart';
import 'package:uvid/utils/state_managment/home_manager.dart';
import 'package:uvid/utils/state_managment/notification_manager.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late ScrollController scrollController;
  bool _isScrollToTopVisible = false;
  @override
  void initState() {
    scrollController = ScrollController(keepScrollOffset: true);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      scrollController.addListener(_listener);
    });
  }

  _listener() {
    setState(() {
      _isScrollToTopVisible = scrollController.position.pixels > 50;
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => NotificationManager(),
      lazy: false,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: context.colorScheme.tertiary,
          appBar: AppBar(
            elevation: 1,
            title: Text(
              AppLocalizations.of(context)!.notification,
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
                    context.read<NotificationManager>().fetchWaittingFriendAccept();
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
          body: _buildBody(context, scrollController, _isScrollToTopVisible),
        );
      },
    );
  }
}

Widget _buildBody(BuildContext context, ScrollController scrollController, bool isScrollToTopVisible) {
  final waittings = context.watch<NotificationManager>().waitingAccepts;
  if (waittings == null) {
    return Center(
      child: CircularProgressIndicator(),
    );
  }
  if (waittings.isEmpty) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
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
  }
  return ListView.builder(
    itemCount: waittings.length,
    controller: scrollController,
    itemBuilder: (BuildContext context, int index) {
      final friend = waittings[index];
      return Stack(
        fit: StackFit.loose,
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 24, left: 16, right: 16),
              child: Stack(
                children: <Widget>[
                  Container(
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: LinearGradient(
                        colors: [
                          getStartColorCute(index),
                          getEndColorCute(index),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: getStartColorCute(index),
                          blurRadius: 10,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    top: 0,
                    child: CustomPaint(
                      size: Size(100, 100),
                      painter: CustomCardShapePainter(
                        20,
                        getStartColorCute(index),
                        getEndColorCute(index),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        gapH8,
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          child: friend.image == null
                              ? Image.asset(
                                  'assets/ic_launcher.png',
                                  height: 64,
                                  width: 64,
                                  fit: BoxFit.cover,
                                )
                              : friend.image!.contains('http')
                                  ? Image.network(
                                      friend.image!,
                                      fit: BoxFit.cover,
                                      height: 64,
                                      width: 64,
                                    )
                                  : Image.memory(
                                      base64Decode(friend.image!),
                                      fit: BoxFit.cover,
                                      height: 64,
                                      width: 64,
                                    ),
                        ),
                        gapH16,
                        Expanded(
                          flex: 4,
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                friend.name,
                                style: context.textTheme.bodyText1?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white70,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                friend.description,
                                style: context.textTheme.bodyText1?.copyWith(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white70.withOpacity(0.5),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              gapV4,
                              Text(
                                getStringDateFromDateTime(millisecondsToDateTime(friend.time), 'dd/MM/yyyy HH:mm:ss'),
                                style: context.textTheme.bodyText1?.copyWith(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white70.withOpacity(0.5),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        gapH16,
                        FloatingActionButton(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          splashColor: getEndColorCute(index),
                          elevation: 12,
                          mini: true,
                          child: Icon(Icons.cancel_rounded),
                          onPressed: () {
                            context.read<NotificationManager>().deleteWaitingFriendAccept(friend.userId);
                          },
                        ),
                        gapH8,
                        FloatingActionButton(
                          backgroundColor: Colors.greenAccent,
                          foregroundColor: Colors.white,
                          splashColor: getEndColorCute(index),
                          elevation: 12,
                          mini: true,
                          child: Icon(Icons.check_rounded),
                          onPressed: () {
                            context.read<NotificationManager>().acceptWaitingFriendAccept(friend.userId);
                          },
                        ),
                        gapH8,
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned.fill(
            bottom: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Visibility(
                  visible: isScrollToTopVisible,
                  child: FloatingActionButton(
                    backgroundColor: context.colorScheme.onSecondary,
                    foregroundColor: Colors.white,
                    splashColor: context.colorScheme.primary,
                    isExtended: true,
                    elevation: 24,
                    child: Icon(Icons.arrow_upward_rounded),
                    onPressed: () {
                      scrollController.animateTo(
                        0,
                        duration: const Duration(milliseconds: 100),
                        curve: Curves.linear,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    },
  );
}
