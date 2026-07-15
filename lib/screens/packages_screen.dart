import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/zonifi_top_bar.dart';
import '../state/wallet_state.dart';
import 'purchasing_screen.dart';

/// A plain data class describing one package — not a widget, just a
/// data shape. Makes adding a 5th package later a one-line change.
class WifiPackage {
  final String label;
  final String subtitle;
  final bool isPopular;
  final double cost;
  final int durationSeconds;

  const WifiPackage({
    required this.label,
    required this.subtitle,
    required this.cost,
    required this.durationSeconds,
    this.isPopular = false,
  });
}

/// PackagesScreen: our FIRST StatefulWidget. Tapping a tile must
/// visually update THIS screen immediately — that need is what makes
/// it stateful rather than stateless.
class PackagesScreen extends StatefulWidget {
  const PackagesScreen({super.key});

  @override
  State<PackagesScreen> createState() => _PackagesScreenState();
}

class _PackagesScreenState extends State<PackagesScreen> {
  // Mutable state: which tile is currently selected. Starts at 1
  // (Ksh 20, the popular one) as a sensible default.
  int _selectedIndex = 1;

  final List<WifiPackage> _packages = const [
    WifiPackage(
      label: 'Ksh 10',
      subtitle: '50 MB · 30 min',
      cost: 10.0,
      durationSeconds: 30 * 60,
    ),
    WifiPackage(
      label: 'Ksh 20',
      subtitle: '150 MB · 1 hr',
      cost: 20.0,
      durationSeconds: 60 * 60,
      isPopular: true,
    ),
    WifiPackage(
      label: 'Ksh 50',
      subtitle: '400 MB · 3 hr',
      cost: 50.0,
      durationSeconds: 3 * 60 * 60,
    ),
    WifiPackage(
      label: 'Ksh 100',
      subtitle: '1 GB · 8 hr',
      cost: 100.0,
      durationSeconds: 8 * 60 * 60,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<WalletState>();
    final selectedPackage = _packages[_selectedIndex];
    final canAfford = wallet.balance >= selectedPackage.cost;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ZonifiTopBar(showBackButton: true),
              const SizedBox(height: 8),
              const Text(
                'Select an amount to purchase Wi-Fi access',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: AppColors.navy,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  itemCount: _packages.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return _PackageTile(
                      package: _packages[index],
                      isSelected: _selectedIndex == index,
                      onTap: () {
                        // setState() does two things: updates the
                        // variable, AND tells Flutter "redraw this
                        // screen now." Without it, _selectedIndex
                        // would change internally but nothing on
                        // screen would update.
                        setState(() {
                          _selectedIndex = index;
                        });
                      },
                    );
                  },
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: canAfford ? AppColors.navy : AppColors.slate200,
                      foregroundColor: canAfford ? Colors.white : AppColors.slate400,
                    ),
                    onPressed: !canAfford ? null : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PurchasingScreen(
                            package: _packages[_selectedIndex],
                          ),
                        ),
                      );
                    },
                    child: Text(
                      canAfford
                          ? 'Continue with ${selectedPackage.label}'
                          : 'Insufficient balance',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// _PackageTile: one selectable row. STATELESS itself — it doesn't
/// track its own "am I selected" state, it's simply TOLD by its
/// parent via `isSelected`. Only one tile can be selected at a time,
/// so that fact has to live in the parent, which can see all four
/// tiles at once.
class _PackageTile extends StatelessWidget {
  final WifiPackage package;
  final bool isSelected;
  final VoidCallback onTap;

  const _PackageTile({
    required this.package,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // A light, quick pulse — appropriate for a routine selection
        // action, not a big confirmation. Distinguishing intensity by
        // meaning (light for selection, stronger for success/error)
        // is what makes haptics feel intentional rather than random.
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.teal : AppColors.slate200,
            width: 2,
          ),
          color: isSelected ? const Color(0xFFF0FDFA) : Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      package.label,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: AppColors.navy,
                      ),
                    ),
                    if (package.isPopular) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.yellow,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'MOST POPULAR',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: AppColors.navy,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  package.subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.slate400,
                  ),
                ),
              ],
            ),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.teal : Colors.white,
                border: Border.all(
                  color: isSelected ? AppColors.teal : AppColors.slate200,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 13, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}