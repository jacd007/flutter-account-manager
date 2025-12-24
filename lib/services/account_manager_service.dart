import 'dart:developer' as developer;

import 'package:flutter/services.dart';

class AccountManagerService {
  static const MethodChannel _channel = MethodChannel(
    'com.example.flutter_account_manager/auth',
  );

  Future<bool> addAccount(String username, String password) async {
    try {
      final bool result = await _channel.invokeMethod('addAccount', {
        'username': username,
        'password': password,
      });
      return result;
    } on PlatformException catch (e) {
      developer.log("Failed to add account: '${e.message}'.");
      return false;
    }
  }

  Future<List<String>> getAccounts() async {
    try {
      final List<dynamic> result = await _channel.invokeMethod('getAccounts');
      return result.cast<String>();
    } on PlatformException catch (e) {
      developer.log("Failed to get accounts: '${e.message}'.");
      return [];
    }
  }

  Future<String?> getPassword(String username) async {
    try {
      final String? result = await _channel.invokeMethod('getPassword', {
        'username': username,
      });
      return result;
    } on PlatformException catch (e) {
      developer.log("Failed to get password: '${e.message}'.");
      return null;
    }
  }

  Future<bool> removeAccount(String username) async {
    try {
      final bool result = await _channel.invokeMethod('removeAccount', {
        'username': username,
      });
      return result;
    } on PlatformException catch (e) {
      developer.log("Failed to remove account: '${e.message}'.");
      return false;
    }
  }
}
