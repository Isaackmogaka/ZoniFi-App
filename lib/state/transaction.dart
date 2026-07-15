/// A single completed purchase record. Deliberately a plain, simple
/// class with no Flutter widget code at all — same separation-of-
/// concerns idea as WalletState itself. This class ALSO happens to be
/// shaped very close to what a Firestore document will look like in
/// Phase 5: a handful of named fields, one record per purchase.
class Transaction {
  final String packageLabel;
  final double cost;
  final DateTime timestamp;

  const Transaction({
    required this.packageLabel,
    required this.cost,
    required this.timestamp,
  });
}