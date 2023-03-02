import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:uvid/common/extensions.dart';
import 'package:uvid/domain/models/contact_mode.dart';
import 'package:uvid/domain/models/contact_model.dart';
import 'package:uvid/ui/widgets/bouncing_widget.dart';
import 'package:uvid/ui/widgets/floating_search_bar.dart';
import 'package:uvid/ui/widgets/gap.dart';
import 'package:uvid/utils/state_managment/contact_manager.dart';
import 'package:uvid/utils/state_managment/friend_manager.dart';
import 'package:uvid/utils/utils.dart';

import '../widgets/painter/custom_shape_painter.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final isGuess = context.select<ContactManager, bool>((cm) {
          return cm.isGuessAccount;
        });
        if (isGuess) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  child: Image.asset(
                    'assets/ic_launcher.png',
                    width: context.screenWidth / 2,
                  ),
                ),
                gapV8,
                Text(
                  AppLocalizations.of(context)!.account_unverified,
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
          final FilterSearchModel? filterSearchModel = context.watch<ContactManager>().filterSearchModel;
          if (filterSearchModel == null) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return FloatingSearchBarWidget(
              filterSearchModel: filterSearchModel,
              onSubmitted: (filterSearchModel) async {
                context.read<ContactManager>().setFilterSearchModel(filterSearchModel);
                context.read<ContactManager>().search(filterSearchModel.searchTerm);
              },
              onDeletedItem: (filterSearchModel) async {
                context.read<ContactManager>().setFilterSearchModel(filterSearchModel);
              },
              body: Column(
                children: [
                  Expanded(
                    child: SearchResultsListView(
                      contacts: context.watch<ContactManager>().contactsAvailable,
                      onAddFriendClickListener: (contactModel) {
                        context.read<ContactManager>().triggerHandleFriend(
                          contactModel,
                          2,
                          onComplete: () {
                            Utils().showToast(
                              AppLocalizations.of(context)!.send_add_friend_successfully,
                              backgroundColor: Colors.greenAccent,
                              textColor: Colors.white,
                            );
                          },
                        );
                      },
                      onSendUnfriendClickListener: (contactModel) {
                        context.read<ContactManager>().triggerHandleFriend(
                          contactModel,
                          0,
                          onComplete: () {
                            Utils().showToast(
                              AppLocalizations.of(context)!.cancel_add_friend_successfully,
                              backgroundColor: Colors.greenAccent,
                              textColor: Colors.white,
                            );
                          },
                        );
                      },
                      onUnfriendClickListener: (contactModel) {
                        context.read<ContactManager>().triggerHandleFriend(
                          contactModel,
                          0,
                          isRemoveFriend: true,
                          onComplete: () {
                            context.read<FriendManager>().removeFriendLocal(contactModel.keyId!);
                            Utils().showToast(
                              AppLocalizations.of(context)!.unfriend_successfully,
                              backgroundColor: Colors.greenAccent,
                              textColor: Colors.white,
                            );
                          },
                        );
                      },
                      onResetClickListener: () {
                        context.read<ContactManager>().resetFilterSearchModel();
                      },
                    ),
                  )
                ],
              ),
            );
          }
        }
      },
    );
  }
}

class SearchResultsListView extends StatefulWidget {
  final List<ContactModel> contacts;
  final Function(ContactModel contactModel) onAddFriendClickListener;
  final Function(ContactModel contactModel) onUnfriendClickListener;
  final Function(ContactModel contactModel) onSendUnfriendClickListener;
  final Function() onResetClickListener;
  const SearchResultsListView({
    Key? key,
    required this.contacts,
    required this.onAddFriendClickListener,
    required this.onSendUnfriendClickListener,
    required this.onUnfriendClickListener,
    required this.onResetClickListener,
  }) : super(key: key);
  @override
  State<SearchResultsListView> createState() => _SearchResultsListViewState();
}

class _SearchResultsListViewState extends State<SearchResultsListView> {
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
    final fsb = FloatingSearchBar.of(context);
    final isLoading = context.watch<ContactManager>().isLoadingSearch;
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else if (widget.contacts.isEmpty) {
      return Column(
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
      );
    } else {
      return Stack(
        fit: StackFit.loose,
        children: [
          ListView(
            controller: scrollController,
            padding: EdgeInsets.only(
              top: fsb?.widget.height ?? 0 + (fsb?.widget.margins?.vertical ?? 0),
              bottom: fsb?.widget.height ?? 0 + (fsb?.widget.margins?.vertical ?? 0),
            ),
            children: List.generate(widget.contacts.length, (index) {
              final item = widget.contacts[index];
              return Center(
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
                              child: item.urlLinkImage == null
                                  ? Image.asset(
                                      'assets/ic_launcher.png',
                                      height: 64,
                                      width: 64,
                                      fit: BoxFit.cover,
                                    )
                                  : item.urlLinkImage!.contains('http')
                                      ? Image.network(
                                          item.urlLinkImage!,
                                          fit: BoxFit.cover,
                                          height: 64,
                                          width: 64,
                                        )
                                      : Image.memory(
                                          base64Decode(item.urlLinkImage!),
                                          fit: BoxFit.cover,
                                          height: 64,
                                          width: 64,
                                        ),
                            ),
                            gapH16,
                            Expanded(
                              flex: 4,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    item.name ?? 'Hacker',
                                    style: context.textTheme.bodyText1?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white70,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    item.description ?? 'Hacker',
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
                              heroTag: null,
                              backgroundColor: item.friendStatus == 2
                                  ? Colors.redAccent
                                  : item.friendStatus == 0
                                      ? getStartColorCute(index)
                                      : Colors.amberAccent,
                              foregroundColor: Colors.white,
                              splashColor: getEndColorCute(index),
                              elevation: 12,
                              mini: true,
                              child: Icon(item.friendStatus == 2
                                  ? Icons.person_add_disabled
                                  : item.friendStatus == 0
                                      ? Icons.person_add_rounded
                                      : Icons.person_off_rounded),
                              onPressed: () {
                                if (item.friendStatus == 0) {
                                  widget.onAddFriendClickListener(item);
                                } else if (item.friendStatus == 2) {
                                  widget.onSendUnfriendClickListener(item);
                                } else {
                                  widget.onUnfriendClickListener(item);
                                }
                              },
                            ),
                            gapH8,
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
          Positioned(
              bottom: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  FloatingActionButton(
                    heroTag: null,
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    splashColor: context.colorScheme.primary,
                    isExtended: true,
                    elevation: 24,
                    child: Icon(Icons.change_circle_rounded),
                    onPressed: () {
                      widget.onResetClickListener.call();
                    },
                  ),
                  Visibility(
                    visible: _isScrollToTopVisible,
                    child: FloatingActionButton(
                      heroTag: null,
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
              )),
        ],
      );
    }
  }
}
