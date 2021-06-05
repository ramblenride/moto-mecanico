import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:moto_mecanico/themes.dart';

class AppBarFilter extends StatefulWidget implements PreferredSizeWidget {
  AppBarFilter(
      {Key key,
      @required this.updateSearchQueryCb,
      this.title,
      this.hintText,
      this.leading,
      this.leadingActions,
      this.trailingActions,
      this.bottom})
      : assert(updateSearchQueryCb != null),
        preferredSize = Size.fromHeight(
            kToolbarHeight + (bottom?.preferredSize?.height ?? 0.0)),
        super(key: key);
  final Function(String) updateSearchQueryCb;
  final Widget title;
  final String hintText;
  final Widget leading;
  final List<Widget> leadingActions;
  final List<Widget> trailingActions;
  final PreferredSizeWidget bottom;

  @override
  final Size preferredSize;

  @override
  _AppBarFilterState createState() => _AppBarFilterState();
}

class _AppBarFilterState extends State<AppBarFilter> {
  _AppBarFilterState();

  TextEditingController _searchQuery;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchQuery = TextEditingController();
  }

  @override
  void dispose() {
    _searchQuery.dispose();
    super.dispose();
  }

  void _startSearch() {
    ModalRoute.of(context)
        .addLocalHistoryEntry(LocalHistoryEntry(onRemove: _stopSearching));

    setState(() {
      _isSearching = true;
    });
  }

  void _stopSearching() {
    _clearSearchQuery();

    setState(() {
      _isSearching = false;
    });
  }

  void _clearSearchQuery() {
    setState(() {
      _searchQuery.clear();
      _updateSearchQuery('');
    });
  }

  void _updateSearchQuery(String newQuery) {
    setState(() {
      widget.updateSearchQueryCb(newQuery);
    });
  }

  Widget _buildSearchField() {
    return TextField(
      autofocus: true,
      controller: _searchQuery,
      cursorWidth: 3,
      decoration: InputDecoration(
        hintText: widget.hintText,
        border: InputBorder.none,
        hintStyle: const TextStyle(fontSize: 18),
      ),
      style: TextStyle(color: RnrColors.blue[200], fontSize: 20),
      textInputAction: TextInputAction.search,
      onChanged: _updateSearchQuery,
    );
  }

  List<Widget> _buildActions() {
    if (_isSearching) {
      return <Widget>[
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            Navigator.pop(context);
            return;
          },
        ),
      ];
    }

    final actions = <Widget>[];
    actions.addAll(widget.leadingActions ?? []);
    actions.add(
      IconButton(
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
        tooltip: AppLocalizations.of(context).appbar_filter_textfield_tootip,
        icon: const Icon(Icons.filter_list),
        onPressed: _startSearch,
      ),
    );
    actions.addAll(widget.trailingActions ?? []);

    return actions;
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: _isSearching ? BackButton() : widget.leading,
      title: _isSearching ? _buildSearchField() : widget.title,
      actions: _buildActions(),
      bottom: widget.bottom,
    );
  }
}
