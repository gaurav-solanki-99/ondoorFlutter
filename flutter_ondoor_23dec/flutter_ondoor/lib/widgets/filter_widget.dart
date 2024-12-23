import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:ondoor/models/get_filter_response.dart';
import 'package:ondoor/services/ApiServices.dart';
import 'package:ondoor/utils/Extension.dart';
import 'package:ondoor/utils/SizeConfig.dart';
import 'package:ondoor/utils/colors.dart';
import 'package:ondoor/widgets/AppWidgets.dart';
import 'package:ondoor/widgets/common_loading_widget.dart';

import '../constants/Constant.dart';
import '../constants/FontConstants.dart';

class FilterWidget extends StatefulWidget {
  final String selectedSubcategoryId;
  List<Filter> selected_filter_list;

  FilterWidget({
    required this.selectedSubcategoryId,
    required this.selected_filter_list,
  });

  @override
  _FilterWidgetState createState() => _FilterWidgetState();
}

class _FilterWidgetState extends State<FilterWidget> {
  GetFilterResponse getFilterResponse = GetFilterResponse();
  FilterData data = FilterData();
  FilterGroup selectedFilterGroup = FilterGroup();
  List<FilterGroup> filterGroups = [];
  List<Filter> selectedFilters = [];
  List<FilterGroup> selectedFilterGroups = [];
  String selectedFilterName = "";

  @override
  void initState() {
    super.initState();
    getFilterList();
  }

  Future<void> getFilterList() async {
    getFilterResponse =
        await ApiProvider().getFilterData(widget.selectedSubcategoryId);
    setState(() {
      data = getFilterResponse.data!;
      filterGroups = data.filterGroups ?? [];
      selectedFilterGroup =
          filterGroups.isNotEmpty ? filterGroups[0] : FilterGroup();
      _initializeFilters();
    });
  }

  void _initializeFilters() {
    for (var group in filterGroups) {
      for (var filter in group.filter ?? []) {
        if (widget.selected_filter_list.any(
            (selectedFilter) => selectedFilter.filterId == filter.filterId)) {
          filter.isChecked = true;
          selectedFilters.add(filter);
          selectedFilterGroups.add(FilterGroup(
              filter: group.filter,
              filterGroupId: group.filterGroupId,
              name: group.name));
        }
      }
    }
    _addSortingFilters();
  }

  void _addSortingFilters() {
    List<Filter> sortList = [
      Filter(name: "Default", title: "Default", filterId: "0"),
      Filter(name: "A - Z", title: "A - Z", filterId: "1"),
      Filter(name: "Z - A", title: "Z - A", filterId: "2"),
      Filter(name: "High to Low", title: "High to Low", filterId: "4"),
      Filter(name: "Low to High", title: "Low to High", filterId: "3"),
    ];
    filterGroups
        .add(FilterGroup(name: "Sort", filter: sortList, filterGroupId: "0"));
  }

  void _toggleFilter(Filter filter, FilterGroup group) {
    setState(() {
      // Check if the current group is the "Sort" group
      if (group.name == "Sort") {
        // Uncheck all filters in the sort group first
        for (var f in group.filter ?? []) {
          f.isChecked = false;
        }
        // Now check the selected filter
        filter.isChecked = true;
        selectedFilters.clear(); // Clear the selectedFilters for sort
        selectedFilters.add(filter);
        selectedFilterGroups.clear(); // Clear selectedFilterGroups for sort
        selectedFilterGroups.add(group);
      } else {
        // For other groups, toggle normally
        filter.isChecked = !filter.isChecked;
        if (filter.isChecked) {
          selectedFilters.add(filter);
          bool groupExists = selectedFilterGroups
              .any((g) => g.filterGroupId == group.filterGroupId);
          if (!groupExists) {
            selectedFilterGroups.add(FilterGroup(
                filter: group.filter,
                filterGroupId: group.filterGroupId,
                name: group.name));
          }
        } else {
          selectedFilters.remove(filter);
          bool groupHasRemainingFilters = selectedFilters.any((f) =>
              filterGroups
                  .firstWhere((g) => g.filterGroupId == group.filterGroupId)
                  .filter!
                  .contains(f));
          if (!groupHasRemainingFilters) {
            selectedFilterGroups.remove(group);
          }
        }
      }
    });
  }

  void _clearAllFilters() {
    setState(() {
      selectedFilterName = "";
      selectedFilters.clear();
      selectedFilterGroups.clear();
      for (var group in filterGroups) {
        for (var filter in group.filter ?? []) {
          filter.isChecked = false;
        }
      }
    });
    _returnFilters();
  }

  void _applyFilters() {
    _returnFilters();
  }

  void _returnFilters() {
    // print("SELECTED FILTER GROUPS ${jsonEncode(selectedFilters)}");
    Navigator.pop(context, {
      "selected_filter_list": selectedFilters.toList(),
      "filter_group": selectedFilterGroups.toList(),
      "selected_filterName": selectedFilterName
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ColorName.whiteSmokeColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: data.filterGroups != null && data.filterGroups!.isNotEmpty
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                Divider(height: .2),
                Expanded(child: _buildFilterLayout()),
                _buildActionButtons(),
              ],
            )
          : CommonLoadingWidget(),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 10, left: 10, bottom: 10),
      child: Text(
        "Filter",
        style: Appwidgets().commonTextStyle(ColorName.black),
      ),
    );
  }

  Widget _buildFilterLayout() {
    return Row(
      children: [
        _buildFilterGroupSelector(),
        VerticalDivider(width: 0.5),
        _buildFilterOptions(),
      ],
    );
  }

  Widget _buildFilterGroupSelector() {
    return Expanded(
      flex: 1,
      child: ListView.builder(
        itemCount: data.filterGroups!.length,
        itemBuilder: (context, index) {
          var group = data.filterGroups![index];
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedFilterName = group.name!;
                selectedFilterGroup = group;
              });
            },
            child: Container(
              color: group == selectedFilterGroup
                  ? ColorName.ColorBagroundPrimary
                  : ColorName.whiteSmokeColor,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Text(
                group.name ?? "",
                style: Appwidgets()
                    .commonTextStyle(
                      group == selectedFilterGroup
                          ? ColorName.ColorPrimary
                          : ColorName.black,
                    )
                    .copyWith(fontWeight: FontWeight.w400),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterOptions() {
    return Expanded(
      flex: 2,
      child: selectedFilterGroup.filter != null &&
              selectedFilterGroup.filter!.isNotEmpty
          ? ListView.builder(
              itemCount: selectedFilterGroup.filter!.length,
              itemBuilder: (context, index) {
                var filter = selectedFilterGroup.filter![index];
                return _buildFilterOption(filter);
              },
            )
          : Center(
              child: Text(
              "No Filters Available!!",
              style: Appwidgets().commonTextStyle(ColorName.black),
            )),
    );
  }

  Widget _buildFilterOption(Filter filter) {
    return Row(
      children: [
        Checkbox(
          activeColor: ColorName.ColorPrimary,
          value: filter.isChecked,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          onChanged: (value) => _toggleFilter(filter, selectedFilterGroup),
        ),
        Expanded(
          child: Text(
            filter.name ?? "",
            maxLines: 2,
            style: Appwidgets()
                .commonTextStyle(ColorName.black)
                .copyWith(fontWeight: FontWeight.w400),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildActionButton("Clear All", ColorName.orange, _clearAllFilters),
          SizedBox(width: 10),
          _buildActionButton("Apply", ColorName.ColorPrimary, _applyFilters),
        ],
      ),
    );
  }

  Widget _buildActionButton(String text, Color color, VoidCallback onPressed) {
    return Expanded(
      child: InkWell(
        onTap: selectedFilters.isEmpty ? null : onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: selectedFilters.isEmpty ? color.withOpacity(.5) : color,
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: Constants.Sizelagre,
                fontFamily: Fontconstants.fc_family_sf,
                fontWeight: Fontconstants.SF_Pro_Display_Bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
