import 'package:flutter/material.dart';

/// WalletState: the single shared source of truth for balance,
/// connection status, and usage — replacing the hardcoded values that
/// were scattered across HomeScreen, PackagesScreen, and ConnectedScreen.
///
/// WHY extends ChangeNotifier: this gives us the ability to call
/// notifyListeners() any time a value here changes. Any widget that's
/// "listening" to this class automatically rebuilds itself when that
/// happens — this is the mechanism that replaces setState() for state
/// that needs to be shared ACROSS screens, not just inside one.
class WalletState extends ChangeNotifier {
  // Underscore prefix = private. Nothing outside this class can
  // change these directly — they can only be changed through the
  // methods below (like topUp() or startSession()). This is
  // deliberate: it stops some random screen from silently setting
  // _balance to a wrong number by accident; every change has to go
  // through a named, intentional method.
  double _balance = 100.0;
  bool _isConnected = false;
  int _secondsRemaining = 0;
  String? _lastPackageLabel;

  // Getters: the only way OUTSIDE code can READ these values. Plain
  // and read-only from the outside — this is a common Dart pattern
  // called "encapsulation," same idea as a private field with a
  // public getter in Java, or a property in Python.
  double get balance => _balance;
  bool get isConnected => _isConnected;
  int get secondsRemaining => _secondsRemaining;
  String? get lastPackageLabel => _lastPackageLabel;

  /// Called when a package purchase succeeds. Deducts the cost from
  /// balance, marks the user as connected, and starts the countdown.
  void startSession({
    required double cost,
    required int durationSeconds,
    required String packageLabel,
  }) {
    _balance -= cost;
    _isConnected = true;
    _secondsRemaining = durationSeconds;
    _lastPackageLabel = packageLabel;

    // THIS is the actual moment the "announcement" happens. Every
    // widget listening to WalletState gets told "something changed,
    // rebuild yourself" right here.
    notifyListeners();
  }

  /// Called every second by a Timer (Phase 4) to count down.
  void tick() {
    if (_secondsRemaining > 0) {
      _secondsRemaining--;
      if (_secondsRemaining == 0) {
        _isConnected = false;
      }
      notifyListeners();
    }
  }

  /// Adds funds to the balance — e.g. after a top-up purchase.
  void topUp(double amount) {
    _balance += amount;
    notifyListeners();
  }

  /// Manually disconnects (used by an error/reset flow later).
  void disconnect() {
    _isConnected = false;
    _secondsRemaining = 0;
    notifyListeners();
  }
}