import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'transaction.dart' as model;

class WalletState extends ChangeNotifier {
  // No longer a hardcoded constant — this now starts null (no user
  // yet) and gets set for real once someone actually signs in via
  // Firebase Phone Auth. Every method below now checks that a user ID
  // exists before trying to touch Firestore.
  String? _userId;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  double _balance = 100.0;
  DateTime? _sessionExpiresAt;
  int _totalSessionSeconds = 0;
  String? _lastPackageLabel;
  Timer? _countdownTimer;
  bool _isLoading = true;
  bool _hasLoadError = false;
  bool _hasSyncError = false;
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

  /// Called once, right after a successful sign-in (real Firebase
  /// Phone Auth), to tell WalletState WHICH user's data to load and
  /// save from now on. Everything else in this class stays exactly
  /// the same as before — it doesn't care HOW we got a user ID, only
  /// that it has one before touching Firestore.
  Future<void> setUserId(String uid) async {
    _userId = uid;
    await loadUserData();
  }

  Future<void> loadUserData() async {
    // Guard: if somehow called before a real user ID is set, there's
    // nothing to load — bail out safely rather than crashing on a
    // null document path.
    if (_userId == null) return;

    try {
      final doc = await _firestore.collection('users').doc(_userId).get();

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
    if (_userId == null) return;

    final snapshot = await _firestore
        .collection('users')
        .doc(_userId)
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
    if (_userId == null) return;

    await _firestore.collection('users').doc(_userId).set({
      'balance': _balance,
      'totalSessionSeconds': _totalSessionSeconds,
      'lastPackageLabel': _lastPackageLabel,
      'sessionExpiresAt':
          _sessionExpiresAt != null ? Timestamp.fromDate(_sessionExpiresAt!) : null,
    }, SetOptions(merge: true));
  }

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
      if (_userId != null) {
        await _firestore
            .collection('users')
            .doc(_userId)
            .collection('transactions')
            .add({
          'packageLabel': newTransaction.packageLabel,
          'cost': newTransaction.cost,
          'timestamp': Timestamp.fromDate(newTransaction.timestamp),
        });
      }
      _hasSyncError = false;
    } catch (e) {
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