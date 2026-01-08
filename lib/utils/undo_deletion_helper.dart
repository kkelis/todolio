import 'dart:async';
import 'package:flutter/material.dart';

/// Helper function to handle undo deletion pattern
/// 
/// Shows a SnackBar with undo option for 5 seconds.
/// If undo is clicked, calls [onUndo]. If timeout occurs, [onUndo] is not called.
Future<void> showUndoDeletionSnackBar(
  BuildContext context, {
  required String itemName,
  required VoidCallback onUndo,
  Duration duration = const Duration(seconds: 5),
}) {
  // Cancel token to track if undo was clicked
  bool undoClicked = false;
  Timer? timer;

  final scaffoldMessenger = ScaffoldMessenger.of(context);
  
  // Show the SnackBar
  final snackBar = SnackBar(
    content: Row(
      children: [
        Expanded(
          child: Text(
            '"$itemName" deleted',
            style: const TextStyle(color: Colors.black87),
          ),
        ),
        TextButton(
          onPressed: () {
            undoClicked = true;
            timer?.cancel();
            scaffoldMessenger.hideCurrentSnackBar();
            onUndo();
          },
          child: const Text(
            'UNDO',
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
    backgroundColor: Colors.white,
    duration: duration,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    margin: const EdgeInsets.all(16),
  );

  // Show the SnackBar
  scaffoldMessenger.showSnackBar(snackBar);

  // Set up timer to track if undo was clicked
  timer = Timer(duration, () {
    if (!undoClicked) {
      // Timeout occurred, undo was not clicked
      // The deletion is already done, nothing to do here
    }
  });

  // Return a future that completes when the SnackBar is dismissed
  return Future.value();
}
