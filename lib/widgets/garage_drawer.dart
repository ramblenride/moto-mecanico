import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:moto_mecanico/assets.dart';
import 'package:moto_mecanico/dialogs/feedback_dialog.dart';
import 'package:moto_mecanico/pages/settings_page.dart';
import 'package:moto_mecanico/themes.dart';
import 'package:moto_mecanico/widgets/config_widget.dart';
import 'package:url_launcher/url_launcher_string.dart';

typedef DrawerMethodCallback = void Function();

class GarageDrawer extends StatefulWidget {
  GarageDrawer({required this.onImport, required this.onExport});

  final DrawerMethodCallback onImport;
  final DrawerMethodCallback onExport;

  @override
  State<StatefulWidget> createState() => _GarageDrawerState();
}

class _GarageDrawerState extends State<GarageDrawer> {
  @override
  Widget build(BuildContext context) {
    final iconColor = Colors.grey[200];
    return Drawer(
      child: Container(
        color: RnrColors.blue[800],
        child: ListView(
          children: <Widget>[
            _header(),
            ListTile(
              leading: Icon(
                Icons.settings,
                color: iconColor,
              ),
              title: Text(AppLocalizations.of(context)!.settings_page_title),
              onTap: _openSettings,
            ),
            ListTile(
              leading: Icon(
                Icons.feedback,
                color: iconColor,
              ),
              title: Text(AppLocalizations.of(context)!.feedback_page_title),
              onTap: _showFeedbackDialog,
            ),
            ListTile(
              leading: Icon(
                Icons.info,
                color: iconColor,
              ),
              title: Text(AppLocalizations.of(context)!.about_page_title),
              onTap: _openAboutDialog,
            ),
            Divider(),
            ListTile(
              leading: Icon(
                Icons.import_export,
                color: iconColor,
              ),
              title: Text(AppLocalizations.of(context)!.garage_import),
              onTap: () {
                Navigator.of(context).pop();
                widget.onImport();
              },
            ),
            ListTile(
              leading: Icon(
                Icons.import_export,
                color: iconColor,
              ),
              title: Text(AppLocalizations.of(context)!.garage_export),
              onTap: () {
                Navigator.of(context).pop();
                widget.onExport();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return DrawerHeader(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      decoration: const BoxDecoration(color: RnrColors.darkBlue),
      child: Image.asset(
        IMG_IDENTITY,
        fit: BoxFit.fill,
        filterQuality: FilterQuality.high,
      ),
    );
  }

  void _openSettings() {
    Navigator.of(context).pop();
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => SettingsPage(),
      ),
    );
  }

  void _openAboutDialog() async {
    Navigator.of(context).pop();
    final pkgInfo = ConfigWidget.of(context).packageInfo;
    showAboutDialog(
      applicationName: pkgInfo?.appName ?? '',
      applicationVersion: pkgInfo?.version ?? '',
      applicationLegalese: AppLocalizations.of(context)!.copyright,
      children: [
        ListTile(
          leading: Icon(
            Icons.open_in_new,
            color: Colors.grey[200],
          ),
          title: Text(AppLocalizations.of(context)!.homepage),
          onTap: () => _openHomePage(),
        ),
        ListTile(
          leading: Icon(
            Icons.security,
            color: Colors.grey[200],
          ),
          title: Text(AppLocalizations.of(context)!.privacy_policy),
          onTap: () => launchUrlString(PRIVACY_POLICY_URL),
        ),
      ],
      context: context,
    );
  }

  void _openHomePage() async {
    await launchUrlString(MOTO_MECANICO_HOMEPAGE);
  }

  void _showFeedbackDialog() async {
    Navigator.of(context).pop();
    await showDialog(
      context: context,
      builder: (BuildContext context) => FeedbackDialog(),
    );
  }
}
