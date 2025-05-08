import 'package:flutter/material.dart';
import 'package:flutter_popup/flutter_popup.dart';

class PopupControllerExample extends StatefulWidget {
  const PopupControllerExample({Key? key}) : super(key: key);

  @override
  State<PopupControllerExample> createState() => _PopupControllerExampleState();
}

class _PopupControllerExampleState extends State<PopupControllerExample> {
  // Define popup IDs
  static const String popupId1 = 'info_popup';
  static const String popupId2 = 'settings_popup';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PopupController Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Popup 1 with ID
            CustomPopup(
              id: popupId1, // Assign an ID to this popup
              content: Container(
                width: 200,
                padding: const EdgeInsets.all(16),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Info Popup',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text(
                        'This popup can be closed programmatically using PopupController.'),
                  ],
                ),
              ),
              child: ElevatedButton(
                onPressed:
                    null, // The popup is opened by the CustomPopup widget
                child: const Text('Show Info Popup'),
              ),
            ),
            const SizedBox(height: 16),

            // Popup 2 with ID
            CustomPopup(
              id: popupId2, // Assign an ID to this popup
              content: Container(
                width: 200,
                padding: const EdgeInsets.all(16),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Settings Popup',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text('Another popup that can be closed programmatically.'),
                  ],
                ),
              ),
              child: ElevatedButton(
                onPressed:
                    null, // The popup is opened by the CustomPopup widget
                child: const Text('Show Settings Popup'),
              ),
            ),
            const SizedBox(height: 32),

            // Buttons to close popups
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Close specific popup by ID
                    final closed = PopupController.closePopupById(popupId1);
                    if (!closed) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Info Popup is not currently open')),
                      );
                    }
                  },
                  child: const Text('Close Info Popup'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    // Close specific popup by ID
                    final closed = PopupController.closePopupById(popupId2);
                    if (!closed) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('Settings Popup is not currently open')),
                      );
                    }
                  },
                  child: const Text('Close Settings Popup'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Close all popups
                PopupController.closeAllPopups();
              },
              child: const Text('Close All Popups'),
            ),
            const SizedBox(height: 32),

            // Status display
            Builder(builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  // Display the status of popups
                  final count = PopupController.activePopupsCount;
                  final infoActive = PopupController.isPopupActive(popupId1);
                  final settingsActive =
                      PopupController.isPopupActive(popupId2);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Active popups: $count\n'
                          'Info popup active: $infoActive\n'
                          'Settings popup active: $settingsActive'),
                    ),
                  );
                },
                child: const Text('Check Popup Status'),
              );
            }),
          ],
        ),
      ),
    );
  }
}
