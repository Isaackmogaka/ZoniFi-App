import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'transaction.dart' as model;

/// WalletState: now backed by real Firestore persistence.
///
/// IMPORTANT: _testUserId is a hardcoded placeholder standing in for
/// a real logged-in user's ID. Tomorrow, once Firebase Auth is wired
/// in, this gets replaced by the actual authenticated user's uid —
/// everything else in this file stays exactly the same, since it
/// doesn't care HOW we got a user ID, only that we have one.
class WalletState extends ChangeNotifier {
  static const String _testUserId = 'test_user_1';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  double _balance = 100.0;
  DateTime? _sessionExpiresAt; // null = no active/past session
  int _totalSessionSeconds = 0;
  String? _lastPackageLabel;
  Timer? _countdownTimer;
  bool _isLoading = true; // true until Firestore data has loaded once
  bool _hasLoadError = false;
  final List<model.Transaction> _transactions = [];

  double get balance => _balance;
  int get totalSessionSeconds => _totalSessionSeconds;
  String? get lastPackageLabel => _lastPackageLabel;
  bool get isLoading => _isLoading;
  bool get hasLoadError => _hasLoadError;
  List<model.Transaction> get transactions => _transactions.reversed.toList();

  /// DERIVED, not stored: true only if we have an expiry time AND
  /// that time hasn't passed yet. No separate boolean to accidentally
  /// get out of sync with reality.
  bool get isConnected =>
      _sessionExpiresAt != null && DateTime.now().isBefore(_sessionExpiresAt!);

  /// DERIVED, not stored: the gap between "when it expires" and
  /// "right now," clamped so it never shows a negative number in the
  /// brief moment between expiry and the timer noticing.
  int get secondsRemaining {
    if (!isConnected) return 0;
    return _sessionExpiresAt!.difference(DateTime.now()).inSeconds;
  }

  /// Call this once, right after creating a WalletState, to load any
  /// existing data for this user from Firestore. Async, so screens
  /// see default values briefly before real data arrives — the
  /// isLoading flag lets UI show a loading state if desired.
 Future<void> loadUserData() async {
    try {
    final doc = await _firestore.collection('users').doc(_testUserId).get();

    if (doc.exists) {
      final data = doc.data()!;
      _balance = (data['balance'] as num?)?.toDouble() ?? 100.0;
      _totalSessionSeconds = (data['totalSessionSeconds'] as num?)?.toInt() ?? 0;
      _lastPackageLabel = data['lastPackageLabel'] as String?;

      // Firestore stores dates as its own Timestamp type, not Dart's
      // DateTime directly — .toDate() converts it.
      final expiresAtRaw = data['sessionExpiresAt'] as Timestamp?;
      _sessionExpiresAt = expiresAtRaw?.toDate();

      // If we loaded a session that's still genuinely active (user
      // closed the app mid-session and reopened it before it ran
      // out), restart the local tick timer so the UI keeps updating.
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

  /// Writes the current user-level fields (NOT transactions, those
  /// are written separately) to Firestore. merge: true means "update
  /// only these fields," so we never accidentally wipe out something
  /// else stored on this document.
  Future<void> _saveUserFields() async {
    await _firestore.collection('users').doc(_testUserId).set({
      'balance': _balance,
      'totalSessionSeconds': _totalSessionSeconds,
      'lastPackageLabel': _lastPackageLabel,
      'sessionExpiresAt':
          _sessionExpiresAt != null ? Timestamp.fromDate(_sessionExpiresAt!) : null,
    }, SetOptions(merge: true));
  }

  bool startSession({
    required double cost,
    required int durationSeconds,
    required String packageLabel,
  }) {
    if (_balance < cost) {
      return false;
    }
    _balance -= cost;

    if (isConnected) {
      // TOP-UP: extend the existing expiry time forward, rather than
      // computing a fresh one from "now" — this correctly stacks on
      // top of whatever time is already left.
      _sessionExpiresAt = _sessionExpiresAt!.add(Duration(seconds: durationSeconds));
      _totalSessionSeconds += durationSeconds;
    } else {
      // FRESH PURCHASE: expiry is simply "duration from right now."
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

    // Fire-and-forget the actual network writes — we don't block the
    // UI waiting for these to finish, since the local state (and
    // notifyListeners below) already reflects the correct outcome.
    _saveUserFields();
    _firestore
        .collection('users')
        .doc(_testUserId)
        .collection('transactions')
        .add({
      'packageLabel': newTransaction.packageLabel,
      'cost': newTransaction.cost,
      'timestamp': Timestamp.fromDate(newTransaction.timestamp),
    });

    notifyListeners();
    return true;
  }

  void _startTicking() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // The timer's only real job now: trigger a rebuild so the
      // countdown visually updates. isConnected/secondsRemaining are
      // computed fresh each time they're read — nothing to update here.
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