import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';

import 'package:uvid/common/extensions.dart';

const historyLength = 5;

class FilterSearchModel extends Equatable {
  final List<String> orgList;
  final String searchTerm;
  FilterSearchModel({
    required this.orgList,
    this.searchTerm = '',
  });

  List<String> filterSearchTerms() {
    if (searchTerm.isNotEmpty) {
      // Reversed because we want the last added items to appear first in the UI
      return orgList.reversed.where((term) => term.toLowerCase().contains(searchTerm.toLowerCase())).toList();
    } else {
      return orgList.reversed.toList();
    }
  }

  void addSearchTerm(String term) {
    if (term.isEmpty) return;
    if (orgList.contains(term)) {
      _putSearchTermFirst(term);
      return;
    }
    orgList.add(term);
    if (orgList.length > historyLength) {
      orgList.removeRange(0, orgList.length - historyLength);
    }
  }

  void deleteSearchTerm(String term) {
    orgList.removeWhere((t) => t == term);
  }

  void _putSearchTermFirst(String term) {
    deleteSearchTerm(term);
    addSearchTerm(term);
  }

  @override
  bool? get stringify => true;

  @override
  List<Object> get props => [orgList, searchTerm];

  FilterSearchModel copyWith({
    List<String>? orgList,
    String? searchTerm,
  }) {
    return FilterSearchModel(
      orgList: orgList ?? this.orgList,
      searchTerm: searchTerm ?? this.searchTerm,
    );
  }
}

class FloatingSearchBarWidget extends StatefulWidget {
  final FilterSearchModel filterSearchModel;
  final Function(FilterSearchModel) onSubmitted;
  final Function(FilterSearchModel) onDeletedItem;
  final Widget body;
  const FloatingSearchBarWidget({
    Key? key,
    required this.filterSearchModel,
    required this.onSubmitted,
    required this.onDeletedItem,
    required this.body,
  }) : super(key: key);

  @override
  State<FloatingSearchBarWidget> createState() => _FloatingSearchBarState();
}

class _FloatingSearchBarState extends State<FloatingSearchBarWidget> {
  late FilterSearchModel filterSearchModel;
  late List<String> filteredList;
  late FloatingSearchBarController controller;

  @override
  void initState() {
    super.initState();
    controller = FloatingSearchBarController();
    filterSearchModel = widget.filterSearchModel;
    filteredList = filterSearchModel.filterSearchTerms();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FloatingSearchBar(
      builder: (context, transition) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Material(
              color: context.colorScheme.secondary,
              elevation: 4,
              child: Builder(
                builder: (context) {
                  if (filteredList.isEmpty) {
                    return Container(
                        height: 56,
                        width: double.infinity,
                        alignment: Alignment.center,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.no_result,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.textTheme.bodyText1?.copyWith(
                                color: context.colorScheme.onSecondary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ));
                  } else {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: filteredList
                          .map(
                            (term) => ListTile(
                              title: Text(
                                term,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: context.textTheme.bodyText1?.copyWith(
                                  color: context.colorScheme.onSecondary,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              leading: const Icon(Icons.history),
                              trailing: IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  setState(() {
                                    filterSearchModel = filterSearchModel.copyWith(searchTerm: controller.query);
                                    filterSearchModel.deleteSearchTerm(term);
                                    filteredList = filterSearchModel.filterSearchTerms();
                                    widget.onDeletedItem(filterSearchModel);
                                  });
                                },
                              ),
                              onTap: () {
                                setState(() {
                                  filterSearchModel = filterSearchModel.copyWith(searchTerm: term);
                                  filterSearchModel.addSearchTerm(term);

                                  widget.onSubmitted(filterSearchModel);
                                });
                                controller.close();
                              },
                            ),
                          )
                          .toList(),
                    );
                  }
                },
              )),
        );
      },
      controller: controller,
      accentColor: context.colorScheme.onSecondary,
      backgroundColor: context.colorScheme.secondary,
      autocorrect: false,
      backdropColor: context.colorScheme.tertiary.withOpacity(0.6),
      clearQueryOnClose: true,
      borderRadius: BorderRadius.circular(8),
      transition: CircularFloatingSearchBarTransition(),
      physics: BouncingScrollPhysics(),
      closeOnBackdropTap: true,
      iconColor: context.colorScheme.onSecondary,
      width: context.screenWidth * 0.4,
      openWidth: context.screenWidth,
      axisAlignment: -1,
      title: Text(
        filterSearchModel.searchTerm.isEmpty ? AppLocalizations.of(context)!.search : filterSearchModel.searchTerm,
        style: context.textTheme.bodyText1?.copyWith(
          color: context.colorScheme.onSecondary,
          fontWeight: FontWeight.w800,
        ),
      ),
      hint: AppLocalizations.of(context)!.search,
      hintStyle: context.textTheme.bodyText1?.copyWith(
        color: context.colorScheme.onSecondary.withOpacity(0.5),
        fontWeight: FontWeight.w600,
      ),
      queryStyle: context.textTheme.bodyText1?.copyWith(
        color: context.colorScheme.onSecondary,
        fontWeight: FontWeight.w800,
      ),
      debounceDelay: const Duration(milliseconds: 500),
      actions: [
        FloatingSearchBarAction.searchToClear(),
      ],
      onQueryChanged: (query) {
        setState(() {
          filterSearchModel = filterSearchModel.copyWith(searchTerm: query);
          filteredList = filterSearchModel.filterSearchTerms();
        });
      },
      onSubmitted: (query) {
        setState(() {
          filterSearchModel = filterSearchModel.copyWith(searchTerm: query);
          filterSearchModel.addSearchTerm(query);
          widget.onSubmitted(filterSearchModel);
        });
        controller.close();
      },
      transitionDuration: const Duration(milliseconds: 500),
      body: Builder(
        builder: (context) {
          return FloatingSearchBarScrollNotifier(
            child: widget.body,
          );
        },
      ),
    );
  }
}
