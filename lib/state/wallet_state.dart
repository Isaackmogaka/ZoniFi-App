import 'dart:async';
import 'package:flutter/material.dart';
import 'transaction.dart';

class WalletState extends ChangeNotifier {
  double _balance = 100.0;
  bool _isConnected = false;
  int _secondsRemaining = 0;
  int _totalSessionSeconds = 0;
  String? _lastPackageLabel;
  Timer? _countdownTimer;
  final List<Transaction> _transactions = [];

  double get balance => _balance;
  bool get isConnected => _isConnected;
  int get secondsRemaining => _secondsRemaining;
  int get totalSessionSeconds => _totalSessionSeconds;
  String? get lastPackageLabel => _lastPackageLabel;
  List<Transaction> get transactions => _transactions.reversed.toList();

  bool startSession({
    required double cost,
    required int durationSeconds,
    required String packageLabel,
  }) {
    if (_balance < cost) {
      return false;
    }
    _balance -= cost;

    // Record this purchase regardless of which branch below runs —
    // both a fresh purchase AND a top-up are real payments, so both
    // deserve a transaction record.
    _transactions.add(Transaction(
      packageLabel: packageLabel,
      cost: cost,
      timestamp: DateTime.now(),
    ));

    if (_isConnected) {
      // TOP-UP CASE: user is already connected and buying more time.
      // ADD to what's remaining instead of overwriting it — otherwise
      // topping up with a shorter package would actually shorten
      // their remaining time, which makes no sense from a paying
      // user's perspective.
      _secondsRemaining += durationSeconds;
      _totalSessionSeconds += durationSeconds;
      _lastPackageLabel = packageLabel;
      // The Timer is already running from the original purchase — we
      // don't touch it here. It will simply keep counting down the
      // now-larger _secondsRemaining value automatically.
    } else {
      // FRESH PURCHASE CASE: nothing was running before, so set
      // everything cleanly and start a brand new timer.
      _isConnected = true;
      _secondsRemaining = durationSeconds;
      _totalSessionSeconds = durationSeconds;
      _lastPackageLabel = packageLabel;

      _countdownTimer?.cancel();
      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        tick();
      });
    }

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