// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:uvid/common/extensions.dart';
import 'package:uvid/domain/models/contact_model.dart';
import 'package:uvid/ui/widgets/floating_search_bar.dart';
import 'package:uvid/ui/widgets/gap.dart';
import 'package:uvid/utils/state_managment/contact_manager.dart';

import '../widgets/painter/custom_shape_painter.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ContactManager>(
      create: (context) {
        return ContactManager();
      },
      builder: (context, child) {
        return Builder(
          builder: (context) {
            final FilterSearchModel? filterSearchModel = context.select<ContactManager, FilterSearchModel?>((cm) {
              return cm.filterSearchModel;
            });
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
                body: SearchResultsListView(
                  contacts: context.watch<ContactManager>().contactsAvailable,
                ),
              );
            }
          },
        );
      },
    );
  }
}

class SearchResultsListView extends StatefulWidget {
  final List<ContactModel> contacts;
  const SearchResultsListView({
    Key? key,
    required this.contacts,
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
    if (widget.contacts.isEmpty) {
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
            children: List.generate(
              widget.contacts.length,
              (index) => Center(
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
                              child: Image.asset(
                                'assets/ic_launcher.png',
                                height: 64,
                                width: 64,
                                fit: BoxFit.cover,
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
                                    widget.contacts[index].name ?? 'Hacker',
                                    style: context.textTheme.bodyText1?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white70,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    widget.contacts[index].description ?? 'Hacker',
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
                              backgroundColor: getStartColorCute(index),
                              foregroundColor: Colors.white,
                              splashColor: getEndColorCute(index),
                              elevation: 12,
                              mini: true,
                              child: Icon(Icons.phone_rounded),
                              onPressed: () {
                                scrollController.animateTo(
                                  0,
                                  duration: const Duration(milliseconds: 100),
                                  curve: Curves.linear,
                                );
                              },
                            ),
                            gapH8,
                            FloatingActionButton(
                              backgroundColor: getStartColorCute(index),
                              foregroundColor: Colors.white,
                              splashColor: getEndColorCute(index),
                              elevation: 12,
                              mini: true,
                              child: Icon(Icons.person_add_rounded),
                              onPressed: () {
                                scrollController.animateTo(
                                  0,
                                  duration: const Duration(milliseconds: 100),
                                  curve: Curves.linear,
                                );
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
            ),
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: Visibility(
              visible: _isScrollToTopVisible,
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
          ),
        ],
      );
    }
  }
}
