import 'package:flutter/material.dart';

class ReportIssueService {
  /*
  // ── FIREBASE FIRESTORE IMPLEMENTATION ──
  // 1. Uncomment cloud_firestore in pubspec.yaml
  // 2. Import: import 'package:cloud_firestore/cloud_firestore.dart';
  // 3. Use this block:

  Future<void> submitIssueToFirebase(String issueText, String userEmail) async {
    try {
      await FirebaseFirestore.instance.collection('issues').add({
        'description': issueText,
        'userEmail': userEmail,
        'reportedAt': DateTime.now(),
        'status': 'open',
        'appVersion': '1.0.0',
      });
    } catch (e) {
      debugPrint('Error reporting issue to Firebase: $e');
      rethrow;
    }
  }
  */

  /// Mock implementation until Firebase is fully configured above.
  Future<void> submitIssueMock(String issueText, String userEmail) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    debugPrint('MOCK FIREBASE: Issue reported by $userEmail -> $issueText');
  }
}
