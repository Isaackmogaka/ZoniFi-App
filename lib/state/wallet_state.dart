import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'transaction.dart' as model;

class WalletState extends ChangeNotifier {
  static const String _testUserId = 'test_user_1';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  double _balance = 100.0;
  DateTime? _sessionExpiresAt;
  int _totalSessionSeconds = 0;
  String? _lastPackageLabel;
  Timer? _countdownTimer;
  bool _isLoading = true;
  bool _hasLoadError = false;
  bool _hasSyncError = false; // true if the LAST purchase failed to save to Firestore
  final List<model.Transaction> _transactions = [];

  double get balance => _balance;
  int get totalSessionSeconds => _totalSessionSeconds;
  String? get lastPackageLabel => _lastPackageLabel;
  bool get isLoading => _isLoading;
  bool get hasLoadError => _hasLoadError;
  bool get hasSyncError => _hasSyncError;
  List<model.Transaction> get transactions => _transactions.reversed.toList();

  bool get isConnected =>
      _sessionExpiresAt != null && DateTime.now().isBefore(_sessionExpiresAt!);

  int get secondsRemaining {
    if (!isConnected) return 0;
    return _sessionExpiresAt!.difference(DateTime.now()).inSeconds;
  }

  Future<void> loadUserData() async {
    try {
      final doc = await _firestore.collection('users').doc(_testUserId).get();

      if (doc.exists) {
        final data = doc.data()!;
        _balance = (data['balance'] as num?)?.toDouble() ?? 100.0;
        _totalSessionSeconds = (data['totalSessionSeconds'] as num?)?.toInt() ?? 0;
        _lastPackageLabel = data['lastPackageLabel'] as String?;

        final expiresAtRaw = data['sessionExpiresAt'] as Timestamp?;
        _sessionExpiresAt = expiresAtRaw?.toDate();

        if (isConnected) {
          _startTicking();
        }
      }

      await _loadTransactions();
      _hasLoadError = false;
    } catch (e) {
      _hasLoadError = true;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadTransactions() async {
    final snapshot = await _firestore
        .collection('users')
        .doc(_testUserId)
        .collection('transactions')
        .orderBy('timestamp')
        .get();

    _transactions.clear();
    for (final doc in snapshot.docs) {
      final data = doc.data();
      _transactions.add(model.Transaction(
        packageLabel: data['packageLabel'] as String,
        cost: (data['cost'] as num).toDouble(),
        timestamp: (data['timestamp'] as Timestamp).toDate(),
      ));
    }
  }

  Future<void> _saveUserFields() async {
    await _firestore.collection('users').doc(_testUserId).set({
      'balance': _balance,
      'totalSessionSeconds': _totalSessionSeconds,
      'lastPackageLabel': _lastPackageLabel,
      'sessionExpiresAt':
          _sessionExpiresAt != null ? Timestamp.fromDate(_sessionExpiresAt!) : null,
    }, SetOptions(merge: true));
  }

  /// Now genuinely async (`Future<bool>` instead of bool), and the
  /// Firestore writes are AWAITED inside a try/catch instead of being
  /// fire-and-forget. This is a deliberate UX choice, not just "make
  /// it safer": if the writes fail (no internet, brief Firestore
  /// outage), we still let the purchase succeed LOCALLY — the user's
  /// timer and balance work fine offline — but we flag hasSyncError
  /// so the UI can warn them their purchase might not survive an app
  /// restart until they reconnect.
  Future<bool> startSession({
    required double cost,
    required int durationSeconds,
    required String packageLabel,
  }) async {
    if (_balance < cost) {
      return false;
    }
    _balance -= cost;

    if (isConnected) {
      _sessionExpiresAt = _sessionExpiresAt!.add(Duration(seconds: durationSeconds));
      _totalSessionSeconds += durationSeconds;
    } else {
      _sessionExpiresAt = DateTime.now().add(Duration(seconds: durationSeconds));
      _totalSessionSeconds = durationSeconds;
      _startTicking();
    }
    _lastPackageLabel = packageLabel;

    final newTransaction = model.Transaction(
      packageLabel: packageLabel,
      cost: cost,
      timestamp: DateTime.now(),
    );
    _transactions.add(newTransaction);

    try {
      await _saveUserFields();
      await _firestore
          .collection('users')
          .doc(_testUserId)
          .collection('transactions')
          .add({
        'packageLabel': newTransaction.packageLabel,
        'cost': newTransaction.cost,
        'timestamp': Timestamp.fromDate(newTransaction.timestamp),
      });
      _hasSyncError = false;
    } catch (e) {
      // The purchase still happened locally (balance already
      // deducted, timer already started above) — we just couldn't
      // confirm it saved to the cloud. Flag it rather than pretending
      // everything's fine.
      _hasSyncError = true;
    }

    notifyListeners();
    return true;
  }

  void _startTicking() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      notifyListeners();
      if (!isConnected) {
        timer.cancel();
      }
    });
  }

  Future<void> topUp(double amount) async {
    _balance += amount;
    await _saveUserFields();
    notifyListeners();
  }

  void disconnect() {
    _sessionExpiresAt = null;
    _countdownTimer?.cancel();
    _countdownTimer = null;
    _saveUserFields();
    notifyListeners();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }
}