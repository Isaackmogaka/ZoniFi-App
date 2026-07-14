import 'dart:async';
import 'package:flutter/material.dart';

class WalletState extends ChangeNotifier {
  double _balance = 100.0;
  bool _isConnected = false;
  int _secondsRemaining = 0;
  int _totalSessionSeconds = 0;
  String? _lastPackageLabel;
  Timer? _countdownTimer;

  double get balance => _balance;
  bool get isConnected => _isConnected;
  int get secondsRemaining => _secondsRemaining;
  int get totalSessionSeconds => _totalSessionSeconds;
  String? get lastPackageLabel => _lastPackageLabel;

  bool startSession({
    required double cost,
    required int durationSeconds,
    required String packageLabel,
  }) {
    if (_balance < cost) {
      return false;
    }
    _balance -= cost;
    _isConnected = true;
    _secondsRemaining = durationSeconds;
    _totalSessionSeconds = durationSeconds;
    _lastPackageLabel = packageLabel;

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      tick();
    });

    notifyListeners();
    return true;
  }

  void tick() {
    if (_secondsRemaining > 0) {
      _secondsRemaining--;
      if (_secondsRemaining == 0) {
        _isConnected = false;
        _countdownTimer?.cancel();
        _countdownTimer = null;
      }
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void topUp(double amount) {
    _balance += amount;
    notifyListeners();
  }

  void disconnect() {
    _isConnected = false;
    _secondsRemaining = 0;
    _countdownTimer?.cancel();
    _countdownTimer = null;
    notifyListeners();
  }
}