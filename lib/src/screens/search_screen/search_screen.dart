import 'package:after_layout/after_layout.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:substring_highlight/substring_highlight.dart';

import '../../blocs/search_bloc/search_bloc.dart';
import '../../blocs/search_bloc/search_event.dart';
import '../../blocs/search_bloc/search_state.dart';
import '../../dependencies/app_dependentcies.dart';
import '../../models/city.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/load_fail_widget.dart';

class SearchScreen extends StatefulWidget {
  final String cityName;

  const SearchScreen({Key? key, required this.cityName}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

String displayStringForOption(City city) => city.name;

class _SearchScreenState extends State<SearchScreen>
    with AfterLayoutMixin<SearchScreen> {
  final _searchBloc = AppDependencies.injector.get<SearchBloc>();

  @override
  void afterFirstLayout(BuildContext context) {
    AppDependencies.injector.get<SearchBloc>().add(SearchRequested());
  }

  @override
  Widget build(BuildContext context) {
    TextStyle _titleAppBarStyle = Theme.of(context)
        .textTheme
        .copyWith()
        .bodyText2!
        .copyWith(
            fontWeight: AppFontWeight.light, fontSize: 20, color: Colors.white);

    TextStyle _subTitleAppBarStyle = Theme.of(context)
        .textTheme
        .copyWith()
        .bodyText2!
        .copyWith(fontSize: 18, color: AppColors.secondaryTextColor);
    TextEditingController _fieldTextEditingController = TextEditingController();

    return Scaffold(
        backgroundColor: AppColors.primary,
        appBar: CustomAppBar(
          title: Column(
            children: [
              Text(
                tr('searchScreen.location'),
                style: _titleAppBarStyle,
              ),
              Text(
                widget.cityName,
                style: _subTitleAppBarStyle,
              ),
            ],
          ),
          widgetLeading: TextButton(
            child: Text(tr('searchScreen.done'),
                style: Theme.of(context)
                    .textTheme
                    .copyWith()
                    .bodyText2!
                    .copyWith(
                        fontSize: 17,
                        fontWeight: FontWeight.w400,
                        color: AppColors.leadingTextColor)),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ),
        body: BlocBuilder<SearchBloc, SearchState>(
          bloc: _searchBloc,
          builder: (context, state) {
            if (state is SearchLoadInProgress) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is SearchLoadFailure) {
              return LoadFailWidget(
                  reload: () {
                    context.read<SearchBloc>().add(SearchRequested());
                  },
                  title: tr('appConstants.loadFailureText'));
            } else if (state is SearchLoadSuccess) {
              return Container(
                color: AppColors.searchFieldColor,
                child: Autocomplete<City>(
                  displayStringForOption: displayStringForOption,
                  fieldViewBuilder:
                      (context, controller, focusNode, onEditingComplete) {
                    _fieldTextEditingController = controller;
                    return TextField(
                        cursorColor: AppColors.cursorColor,
                        autofocus: true,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.search,
                              color: AppColors.searchIconColor),
                          suffixIcon: IconButton(
                            onPressed: () =>
                                _fieldTextEditingController.clear(),
                            icon: const Icon(Icons.close,
                                color: AppColors.searchFieldIconColor),
                          ),
                          border: const OutlineInputBorder(
                              borderSide: BorderSide.none),
                          hintText: tr('searchScreen.hintText'),
                        ),
                        controller: _fieldTextEditingController,
                        focusNode: focusNode,
                        style: Theme.of(context).textTheme.subtitle1!.copyWith(
                            fontSize: 16, color: Colors.grey.shade400));
                  },
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text.isEmpty) {
                      return const Iterable<City>.empty();
                    }
                    return state.cities.where((City city) {
                      return city.name
                              .toString()
                              .toLowerCase()
                              .contains(textEditingValue.text.toLowerCase()) ||
                          city.longitude
                              .toString()
                              .contains(textEditingValue.text);
                    });
                  },
                  optionsViewBuilder: (context, onSelected, cities) {
                    return Material(
                      child: Container(
                        color: AppColors.primary,
                        child: ListView.separated(
                          padding: EdgeInsets.zero,
                          itemBuilder: (context, index) {
                            final City city = cities.elementAt(index);
                            return ListTile(
                                onTap: () {
                                  Navigator.pop(context, city);
                                },
                                title: SubstringHighlight(
                                    text: city.name,
                                    term: _fieldTextEditingController.text,
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .copyWith()
                                        .headline6!
                                        .copyWith(color: Colors.grey),
                                    textStyleHighlight: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white)));
                          },
                          separatorBuilder: (BuildContext context, int index) =>
                              const Divider(
                                  thickness: 1,
                                  indent: 17,
                                  color: Colors.white),
                          itemCount: cities.length,
                        ),
                      ),
                    );
                  },
                ),
              );
            }
            return Container(color: Colors.orange);
          },
        ));
  }
}
