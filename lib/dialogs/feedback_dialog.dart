import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:moto_mecanico/assets.dart';
import 'package:moto_mecanico/themes.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher_string.dart';

class FeedbackDialog extends StatelessWidget {
  const FeedbackDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Dialog(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.only(top: 15, bottom: 10),
              decoration: BoxDecoration(
                color: RnrColors.blue[800],
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    topRight: Radius.circular(20.0)),
              ),
              child: Text(
                AppLocalizations.of(context)!.feedback_page_title,
                style: theme.dialogHeader,
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Wrap(
                children: [
                  ListTile(
                    leading: const Icon(Icons.feedback),
                    title: const Text('Twitter / X'),
                    onTap: () {
                      _sendToTwitter();
                      Navigator.of(context).pop();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.email),
                    title: Text(AppLocalizations.of(context)!.feedback_email),
                    onTap: () {
                      _sendToEmail();
                      Navigator.of(context).pop();
                    },
                  ),
                  ListTile(
                      leading: const Icon(Icons.apps),
                      title: Text(AppLocalizations.of(context)!.feedback_rate),
                      onTap: () {
                        _ratePlayStore();
                        Navigator.of(context).pop();
                      }),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      AppLocalizations.of(context)!.feedback_page_thanks,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        child: Text(
                          AppLocalizations.of(context)!.dialog_cancel_button,
                          style: theme.dialogButton,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendToEmail() async {
    final pkgInfo = await PackageInfo.fromPlatform();
    final appName = pkgInfo.appName;
    final packageName = pkgInfo.packageName;
    final version = pkgInfo.version;
    final buildNumber = pkgInfo.buildNumber;

    final emailUrl =
        'mailto:$emailFeedback?subject=$appName Feedback&body=Package: $packageName\\n\\r'
        'App Version: $version\\n\\rBuild: $buildNumber\\n\\r';

    await launchUrlString(emailUrl);
  }

  void _sendToTwitter() async {
    await launchUrlString(twitterFeedbackUrl);
  }

  void _ratePlayStore() async {
    await launchUrlString(googlePlayUrl);
  }
}
