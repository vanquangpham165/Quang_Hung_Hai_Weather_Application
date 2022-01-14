import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../constants/app_theme.dart';
import 'package:substring_highlight/substring_highlight.dart';

import '../../blocs/location/location_bloc.dart';
import '../../blocs/location/location_event.dart';
import '../../blocs/location/location_state.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_string.dart';
import '../../constants/routes_name.dart';
import '../../models/city.dart';
import '../../widgets/load_fail_widget.dart';

class LocationScreen extends StatelessWidget {
  final String cityName;
  const LocationScreen({Key? key, required this.cityName}) : super(key: key);
  static String displayStringForOption(City city) => city.name;

  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);
    context.read<LocationBloc>().add(LocationRequested());
    TextEditingController _fieldTextEditingController = TextEditingController();

    return Scaffold(
        backgroundColor: ColorsApp.primaryBackgroundColor,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: ColorsApp.primaryBackgroundColor,
          leading: TextButton(
            child: Text(AppString.done,
                style: _theme.textTheme.bodyText2!.copyWith(
                    fontSize: 17,
                    fontWeight: FontWeight.w400,
                    color: ColorsApp.leadingTextColor)),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          centerTitle: true,
          title: Column(
            children: [
              Text(AppString.location,
                  style: _theme.textTheme.bodyText1!.copyWith(
                      fontSize: 17,
                      color: Colors.white,
                      fontWeight: FontWeight.w400)),
              Text(cityName,
                  style: _theme.textTheme.bodyText1!.copyWith(
                      color: ColorsApp.secondaryTextColor,
                      fontSize: 16,
                      fontWeight: AppFontWeight.light))
            ],
          ),
        ),
        body: BlocBuilder<LocationBloc, LocationState>(
          builder: (context, state) {
            if (state is LocationLoadInProgress) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is LocationLoadFailure) {
              return LoadFailWidget(
                  reload: () {
                    context.read<LocationBloc>().add(LocationRequested());
                  },
                  title: AppString.loadFailureText);
            } else if (state is LocationLoadSuccess) {
              return Container(
                color: ColorsApp.searchFieldColor,
                child: Autocomplete<City>(
                  displayStringForOption: displayStringForOption,
                  fieldViewBuilder:
                      (context, controller, focusNode, onEditingComplete) {
                    _fieldTextEditingController = controller;
                    return TextField(
                        cursorColor: ColorsApp.cursorColor,
                        autofocus: true,
                        decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.search,
                                color: ColorsApp.searchIconColor),
                            suffixIcon: IconButton(
                                onPressed: () =>
                                    _fieldTextEditingController.clear(),
                                icon: const Icon(Icons.close,
                                    color: ColorsApp.searchFieldIconColor)),
                            border: const OutlineInputBorder(
                                borderSide: BorderSide.none),
                            hintText: AppString.hintText),
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
                          .contains(textEditingValue.text.toLowerCase());
                    });
                  },
                  optionsViewBuilder: (context, onSelected, cities) {
                    return Material(
                      child: Container(
                        color: ColorsApp.primaryBackgroundColor,
                        child: ListView.separated(
                          padding: EdgeInsets.zero,
                          itemBuilder: (context, index) {
                            final City city = cities.elementAt(index);
                            return ListTile(
                                onTap: () {
                                  Navigator.pop(context,city);
                                },
                                title: SubstringHighlight(
                                    text: city.name,
                                    term: _fieldTextEditingController.text,
                                    textStyle: _theme.textTheme.headline6!
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
