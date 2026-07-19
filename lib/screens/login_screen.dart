import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'otp_screen.dart';

/// A small, plain data model: one selectable country, its dial code,
/// and how many digits a valid local number should have. Kept to a
/// short, honest list of countries rather than pretending to cover
/// every country manually — a real production app would likely use a
/// dedicated package (e.g. `country_code_picker`) for a complete,
/// properly-maintained list. This hand-built version is enough to
/// demonstrate the pattern and cover Kenya's immediate neighbors.
class CountryCode {
  final String name;
  final String dialCode;
  final int expectedDigits;

  const CountryCode({
    required this.name,
    required this.dialCode,
    required this.expectedDigits,
  });
}

const List<CountryCode> _countries = [
  // East Africa
  CountryCode(name: 'Kenya', dialCode: '+254', expectedDigits: 9),
  CountryCode(name: 'Uganda', dialCode: '+256', expectedDigits: 9),
  CountryCode(name: 'Tanzania', dialCode: '+255', expectedDigits: 9),
  CountryCode(name: 'Rwanda', dialCode: '+250', expectedDigits: 9),
  CountryCode(name: 'Burundi', dialCode: '+257', expectedDigits: 8),
  CountryCode(name: 'South Sudan', dialCode: '+211', expectedDigits: 9),
  CountryCode(name: 'Ethiopia', dialCode: '+251', expectedDigits: 9),
  CountryCode(name: 'Somalia', dialCode: '+252', expectedDigits: 8),
  // West Africa
  CountryCode(name: 'Nigeria', dialCode: '+234', expectedDigits: 10),
  CountryCode(name: 'Ghana', dialCode: '+233', expectedDigits: 9),
  CountryCode(name: 'Senegal', dialCode: '+221', expectedDigits: 9),
  CountryCode(name: 'Ivory Coast', dialCode: '+225', expectedDigits: 10),
  CountryCode(name: 'Mali', dialCode: '+223', expectedDigits: 8),
  // Southern Africa
  CountryCode(name: 'South Africa', dialCode: '+27', expectedDigits: 9),
  CountryCode(name: 'Zimbabwe', dialCode: '+263', expectedDigits: 9),
  CountryCode(name: 'Zambia', dialCode: '+260', expectedDigits: 9),
  CountryCode(name: 'Botswana', dialCode: '+267', expectedDigits: 8),
  CountryCode(name: 'Namibia', dialCode: '+264', expectedDigits: 9),
  CountryCode(name: 'Mozambique', dialCode: '+258', expectedDigits: 9),
  // North Africa
  CountryCode(name: 'Egypt', dialCode: '+20', expectedDigits: 10),
  CountryCode(name: 'Morocco', dialCode: '+212', expectedDigits: 9),
  CountryCode(name: 'Algeria', dialCode: '+213', expectedDigits: 9),
  CountryCode(name: 'Tunisia', dialCode: '+216', expectedDigits: 8),
  // Middle East
  CountryCode(name: 'United Arab Emirates', dialCode: '+971', expectedDigits: 9),
  CountryCode(name: 'Saudi Arabia', dialCode: '+966', expectedDigits: 9),
  // Europe
  CountryCode(name: 'United Kingdom', dialCode: '+44', expectedDigits: 10),
  CountryCode(name: 'Germany', dialCode: '+49', expectedDigits: 10),
  CountryCode(name: 'France', dialCode: '+33', expectedDigits: 9),
  // Asia
  CountryCode(name: 'India', dialCode: '+91', expectedDigits: 10),
  CountryCode(name: 'China', dialCode: '+86', expectedDigits: 11),
  CountryCode(name: 'Pakistan', dialCode: '+92', expectedDigits: 10),
  // Americas
  CountryCode(name: 'United States', dialCode: '+1', expectedDigits: 10),
  CountryCode(name: 'Canada', dialCode: '+1', expectedDigits: 10),
  CountryCode(name: 'Brazil', dialCode: '+55', expectedDigits: 11),
  // Oceania
  CountryCode(name: 'Australia', dialCode: '+61', expectedDigits: 9),
];

/// LoginScreen is now StatefulWidget — it needs to track two pieces
/// of live-changing data: which country is selected, and how many
/// digits have been typed so far, to decide whether "Send code"
/// should be enabled.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  CountryCode _selectedCountry = _countries[0]; // defaults to Kenya
  final TextEditingController _phoneController = TextEditingController();
  String _digitsOnly = '';

  @override
  void initState() {
    super.initState();
    // Listen for every keystroke in the phone field, so we can
    // re-check validity live as the user types, not just when they
    // tap the button.
    _phoneController.addListener(_onPhoneChanged);
  }

  @override
  void dispose() {
    _phoneController.removeListener(_onPhoneChanged);
    _phoneController.dispose();
    super.dispose();
  }

  void _onPhoneChanged() {
    // Strip out anything that isn't a digit (spaces, dashes people
    // might type) so we're always validating against pure digit count,
    // regardless of how the user chooses to format their input.
    final digits = _phoneController.text.replaceAll(RegExp(r'[^0-9]'), '');
    setState(() {
      _digitsOnly = digits;
    });
  }

  bool get _isValid => _digitsOnly.length == _selectedCountry.expectedDigits;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              const Text(
                'Enter your phone number',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.navy,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "We'll text you a code to verify it's you.",
                style: TextStyle(fontSize: 13, color: AppColors.slate400),
              ),
              const SizedBox(height: 32),

              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<CountryCode>(
                        value: _selectedCountry,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        borderRadius: BorderRadius.circular(10),
                        items: _countries.map((country) {
                          return DropdownMenuItem(
                            value: country,
                            child: Text(
                              '${country.dialCode} ${country.name}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.navy,
                                fontSize: 13,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (country) {
                          if (country == null) return;
                          setState(() {
                            _selectedCountry = country;
                          });
                          _onPhoneChanged();
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: '7XX XXX XXX',
                        filled: true,
                        fillColor: const Color(0xFFF1F5F9),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              Text(
                '${_digitsOnly.length}/${_selectedCountry.expectedDigits} digits',
                style: TextStyle(
                  fontSize: 11,
                  color: _isValid ? AppColors.teal : AppColors.slate400,
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _isValid ? AppColors.yellow : AppColors.slate200,
                    foregroundColor:
                        _isValid ? AppColors.navy : AppColors.slate400,
                  ),
                  onPressed: !_isValid
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const OtpScreen(),
                            ),
                          );
                        },
                  child: const Text('Send code'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}