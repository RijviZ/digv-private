import 'dart:async';

import 'package:digv/I10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_text_styles.dart';

import '../providers/auth_provider.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String phoneNumber;

  const OtpScreen({super.key, required this.phoneNumber});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  int _secondsRemaining = 10;
  Timer? _timer;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    for (var controller in _otpControllers) {
      controller.addListener(() {
        if (mounted) setState(() {});
      });
    }
    _startTimer();
  }

  void _startTimer() {
    _canResend = false;
    _secondsRemaining = 10;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _canResend = true;
          _timer?.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  String get _currentOtp => _otpControllers.map((c) => c.text).join();

  String _formatTime(int seconds) {
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => context.pop(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12.0,
                    horizontal: 6,
                  ),
                  child: Row(
                    children: [
                      SvgPicture.asset('assets/images/CaretLeft.svg'),
                      const SizedBox(width: 8),
                      Text(
                        'Back',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.otp_title,
                style: AppTextStyles.h2.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  children: [
                    const TextSpan(text: '6-digit code sent to '),
                    TextSpan(
                      text: widget.phoneNumber,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  6,
                  (index) => Container(
                    width: 48,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Theme.of(context).dividerColor),
                    ),
                    child: Center(
                      child: TextField(
                        controller: _otpControllers[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(1),
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        style: AppTextStyles.title.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          counterText: '',
                        ),
                        onChanged: (value) {
                          if (value.isNotEmpty && index < 5) {
                            FocusScope.of(context).nextFocus();
                          } else if (value.isEmpty && index > 0) {
                            FocusScope.of(context).previousFocus();
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: (ref.watch(authProvider).isLoading || _currentOtp.length < 6)
                          ? null
                          : () async {
                              final otp = _currentOtp;
                              if (otp.length == 6) {
                                try {
                                  final result = await ref
                                      .read(authProvider.notifier)
                                      .verifyOtp(
                                        phoneNumber: widget.phoneNumber,
                                        otp: otp,
                                      );
                                  if (context.mounted) {
                                    final user = result['user'];
                                    if (user != null) {
                                      if (user.isOnboardingCompleted == true) {
                                        context.go('/home');
                                      } else if (user.isProfileSetupCompleted != true) {
                                        context.go('/setup_welcome', extra: widget.phoneNumber);
                                      } else if (user.latestLocation == null && user.isLocationAccessSkipped != true) {
                                        context.go('/enable_location_access');
                                      } else {
                                        context.go('/home');
                                      }
                                    }
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(e.toString())),
                                    );
                                  }
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(
                          context,
                        ).colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26),
                        ),
                        elevation: 0,
                      ),
                      child: ref.watch(authProvider).isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              "Verify & Continue",
                              style: AppTextStyles.button,
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _canResend ? "Didn't receive code? " : "Resend OTP in ",
                        style: AppTextStyles.caption.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      if (_canResend)
                        GestureDetector(
                          onTap: ref.watch(authProvider).isLoading
                              ? null
                              : () async {
                                  try {
                                    final response = await ref
                                        .read(authProvider.notifier)
                                        .sendOtp(
                                          phoneNumber: widget.phoneNumber,
                                          countryCode: '+91',
                                          role: 'CUSTOMER',
                                        );
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(response['message'] ?? 'OTP resent successfully')),
                                      );
                                    }
                                    _startTimer();
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(content: Text(e.toString())),
                                      );
                                    }
                                  }
                                },
                          child: Text(
                            "Resend",
                            style: AppTextStyles.labelMedium.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      else
                        Text(
                          _formatTime(_secondsRemaining),
                          style: AppTextStyles.caption.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
