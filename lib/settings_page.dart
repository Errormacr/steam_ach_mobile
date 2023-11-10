import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _apiKeyController = TextEditingController();
  final TextEditingController _steamIdController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Center(child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        ElevatedButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text("Enter New API Key"),
                  content: TextField(
                    controller: _apiKeyController,
                    decoration: const InputDecoration(labelText: 'New API Key'),
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: const Text("Cancel"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
                      child: const Text("OK"),
                      onPressed: () async {
                        final newApiKey = _apiKeyController.text;
                        final secureStorage = FlutterSecureStorage();
                        await secureStorage.write(key: "apiKey", value: newApiKey);
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          },
          child: const Text("Change API Key"),
        ),
        ElevatedButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text("Enter New Steam ID"),
                  content: TextField(
                    controller: _steamIdController,
                    decoration: const InputDecoration(labelText: 'New Steam ID'),
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: const Text("Cancel"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
                      child: const Text("OK"),
                      onPressed: () async {
                        final newSteamId = _steamIdController.text;
                        final secureStorage = FlutterSecureStorage();
                        await secureStorage.write(key: "steamId", value: newSteamId);
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          },
          child: const Text("Change Steam ID"),
        ),
      ],
    ));
  }
}
