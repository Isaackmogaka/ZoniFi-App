import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'otp_screen.dart';

/// A small, plain data model: one selectable country, its dial code,
/// flag emoji, and how many digits a valid local number should have.
class CountryCode {
  final String name;
  final String dialCode;
  final String flag;
  final int expectedDigits;

  const CountryCode({
    required this.name,
    required this.dialCode,
    required this.flag,
    required this.expectedDigits,
  });
}

const List<CountryCode> _countries = [
  // East Africa
  CountryCode(name: 'Kenya', dialCode: '+254', flag: '🇰🇪', expectedDigits: 9),
  CountryCode(name: 'Uganda', dialCode: '+256', flag: '🇺🇬', expectedDigits: 9),
  CountryCode(name: 'Tanzania', dialCode: '+255', flag: '🇹🇿', expectedDigits: 9),
  CountryCode(name: 'Rwanda', dialCode: '+250', flag: '🇷🇼', expectedDigits: 9),
  CountryCode(name: 'Burundi', dialCode: '+257', flag: '🇧🇮', expectedDigits: 8),
  CountryCode(name: 'South Sudan', dialCode: '+211', flag: '🇸🇸', expectedDigits: 9),
  CountryCode(name: 'Ethiopia', dialCode: '+251', flag: '🇪🇹', expectedDigits: 9),
  CountryCode(name: 'Somalia', dialCode: '+252', flag: '🇸🇴', expectedDigits: 8),
  // West Africa
  CountryCode(name: 'Nigeria', dialCode: '+234', flag: '🇳🇬', expectedDigits: 10),
  CountryCode(name: 'Ghana', dialCode: '+233', flag: '🇬🇭', expectedDigits: 9),
  CountryCode(name: 'Senegal', dialCode: '+221', flag: '🇸🇳', expectedDigits: 9),
  CountryCode(name: 'Ivory Coast', dialCode: '+225', flag: '🇨🇮', expectedDigits: 10),
  CountryCode(name: 'Mali', dialCode: '+223', flag: '🇲🇱', expectedDigits: 8),
  // Southern Africa
  CountryCode(name: 'South Africa', dialCode: '+27', flag: '🇿🇦', expectedDigits: 9),
  CountryCode(name: 'Zimbabwe', dialCode: '+263', flag: '🇿🇼', expectedDigits: 9),
  CountryCode(name: 'Zambia', dialCode: '+260', flag: '🇿🇲', expectedDigits: 9),
  CountryCode(name: 'Botswana', dialCode: '+267', flag: '🇧🇼', expectedDigits: 8),
  CountryCode(name: 'Namibia', dialCode: '+264', flag: '🇳🇦', expectedDigits: 9),
  CountryCode(name: 'Mozambique', dialCode: '+258', flag: '🇲🇿', expectedDigits: 9),
  // North Africa
  CountryCode(name: 'Egypt', dialCode: '+20', flag: '🇪🇬', expectedDigits: 10),
  CountryCode(name: 'Morocco', dialCode: '+212', flag: '🇲🇦', expectedDigits: 9),
  CountryCode(name: 'Algeria', dialCode: '+213', flag: '🇩🇿', expectedDigits: 9),
  CountryCode(name: 'Tunisia', dialCode: '+216', flag: '🇹🇳', expectedDigits: 8),
  // Middle East
  CountryCode(name: 'United Arab Emirates', dialCode: '+971', flag: '🇦🇪', expectedDigits: 9),
  CountryCode(name: 'Saudi Arabia', dialCode: '+966', flag: '🇸🇦', expectedDigits: 9),
  // Europe
  CountryCode(name: 'United Kingdom', dialCode: '+44', flag: '🇬🇧', expectedDigits: 10),
  CountryCode(name: 'Germany', dialCode: '+49', flag: '🇩🇪', expectedDigits: 10),
  CountryCode(name: 'France', dialCode: '+33', flag: '🇫🇷', expectedDigits: 9),
  // Asia
  CountryCode(name: 'India', dialCode: '+91', flag: '🇮🇳', expectedDigits: 10),
  CountryCode(name: 'China', dialCode: '+86', flag: '🇨🇳', expectedDigits: 11),
  CountryCode(name: 'Pakistan', dialCode: '+92', flag: '🇵🇰', expectedDigits: 10),
  // Americas
  CountryCode(name: 'United States', dialCode: '+1', flag: '🇺🇸', expectedDigits: 10),
  CountryCode(name: 'Canada', dialCode: '+1', flag: '🇨🇦', expectedDigits: 10),
  CountryCode(name: 'Brazil', dialCode: '+55', flag: '🇧🇷', expectedDigits: 11),
  // Oceania
  CountryCode(name: 'Australia', dialCode: '+61', flag: '🇦🇺', expectedDigits: 9),
];

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  CountryCode _selectedCountry = _countries[0];
  final TextEditingController _phoneController = TextEditingController();
  String _digitsOnly = '';

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_onPhoneChanged);
  }

  @override
  void dispose() {
    _phoneController.removeListener(_onPhoneChanged);
    _phoneController.dispose();
    super.dispose();
  }

  void _onPhoneChanged() {
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
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(country.flag, style: const TextStyle(fontSize: 16)),
                                const SizedBox(width: 6),
                                Text(
                                  '${country.dialCode} ${country.name}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.navy,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        selectedItemBuilder: (context) {
                          // A more compact display for the CLOSED
                          // dropdown (just flag + dial code), so it
                          // doesn't crowd the row when a long country
                          // name like "United Arab Emirates" is picked.
                          return _countries.map((country) {
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(country.flag, style: const TextStyle(fontSize: 16)),
                                const SizedBox(width: 6),
                                Text(
                                  country.dialCode,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.navy,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            );
                          }).toList();
                        },
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
                              builder: (context) => OtpScreen(
                                phoneNumber:
                                    '${_selectedCountry.dialCode} $_digitsOnly',
                              ),
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