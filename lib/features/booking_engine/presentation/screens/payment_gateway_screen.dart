import 'package:digv/core/theme/app_colors.dart';
import 'package:digv/core/theme/app_text_styles.dart';
import 'package:digv/core/widgets/app_top_bar.dart';
import 'package:digv/features/booking_engine/presentation/models/payment_methods.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_primary_button.dart';

class PaymentGatewayScreen extends StatefulWidget {
  const PaymentGatewayScreen({super.key});

  @override
  State<PaymentGatewayScreen> createState() => _PaymentGatewayScreenState();
}

class _PaymentGatewayScreenState extends State<PaymentGatewayScreen> {
  PayTab _tab = PayTab.upi;
  int _selectedUpiApp = -1;
  final TextEditingController _upiCtrl = TextEditingController();

  static const int _amount = 525;

  final List<UpiApp> _upiApps = const [
    UpiApp(name: 'Google Pay', bgColor: Color(0xFFF5F5F5), iconBg: Colors.white, imagePath: 'assets/images/gpay.png'),
    UpiApp(
      name: 'PhonePe',
      bgColor: Color(0xFFF5F5F5),
      iconBg: Color(0xFF5F259F),
      imagePath: 'assets/images/phonepe.png',
    ),
    UpiApp(name: 'Paytm', bgColor: Color(0xFFF5F5F5), iconBg: Color(0xFF00BAF2), imagePath: 'assets/images/paytm.png'),
    UpiApp(
      name: 'BHIM UPI',
      bgColor: Color(0xFFF5F5F5),
      iconBg: Color(0xFF6B3FA0),
      imagePath: 'assets/images/bheem.png',
    ),
  ];

  @override
  void dispose() {
    _upiCtrl.dispose();
    super.dispose();
  }

  String get _footerLabel {
    switch (_tab) {
      case PayTab.upi:
        return 'UPI · Instant payment';
      case PayTab.credit:
        return 'Credit Card · Secure payment';
      case PayTab.debit:
        return 'Debit Card · Secure payment';
      case PayTab.bank:
        return 'Net Banking · Secure payment';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            const AppTopBar(title: 'Payment Gateway'),
            _tabBar(),
            const Divider(height: 1, thickness: 1, color: AppColors.inputBorder),
            Expanded(
              child: SingleChildScrollView(padding: const EdgeInsets.fromLTRB(16, 16, 16, 16), child: _tabBody()),
            ),
            //_bottomBar(),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme
                .of(context)
                .colorScheme
                .surface,
            border: Border(top: BorderSide(color: AppColors.dropDownBorder)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SvgPicture.asset('assets/images/lock.svg', width: 24, height: 24),
                      const SizedBox(width: 8),
                      Text(
                        _footerLabel,
                        style: AppTextStyles.button.copyWith(color: Theme
                            .of(context)
                            .colorScheme
                            .secondary),
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/images/rupee.svg',
                        width: 20,
                        height: 20,
                        colorFilter: ColorFilter.mode(AppColors.blueLight, BlendMode.srcIn),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '$_amount',
                        style: AppTextStyles.h3.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0,
                          height: 1.5,
                          color: AppColors.blueLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              AppPrimaryButton(
                text: 'Confirm & Pay',
                onTap: () {
                  context.push('/booking_requested');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tabBar() =>
      Container(
        color: Colors.white,
        child: Row(
          children: PayTab.values.map((tab) {
            final active = _tab == tab;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _tab = tab),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: active ? Theme
                        .of(context)
                        .colorScheme
                        .primary : Colors.transparent, width: 1)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        tab.svgPath,
                        height: 20,
                        width: 20,
                        colorFilter:
                        ColorFilter.mode(active ? AppColors.onLight : Theme
                            .of(context)
                            .colorScheme
                            .secondary, BlendMode.srcIn),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        tab.label,
                        style: AppTextStyles.labelMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: active ? Theme
                              .of(context)
                              .colorScheme
                              .primary : Theme
                              .of(context)
                              .colorScheme
                              .secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      );

  Widget _tabBody() {
    switch (_tab) {
      case PayTab.upi:
        return _upiBody();
      case PayTab.credit:
        return _creditDebitBody(isCredit: true);
      case PayTab.debit:
        return _creditDebitBody(isCredit: false);
      case PayTab.bank:
        return _bankBody();
    }
  }

  Widget _upiBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _amountCard(),
        const SizedBox(height: 20),
        Text(
          'Choose UPI App',
          style: AppTextStyles.titleLight.copyWith(
            fontWeight: FontWeight.w500,
            color: Theme
                .of(context)
                .colorScheme
                .onSurface,
          ),
        ),
        const SizedBox(height: 8),
        _upiGrid(),
        const SizedBox(height: 16),
        _dividerOr(),
        const SizedBox(height: 16),
        _upiIdInput(),
        const SizedBox(height: 8),
        Text(
          'Enter your UPI ID linked to any bank account',
          style: AppTextStyles.caption.copyWith(color: Theme
              .of(context)
              .colorScheme
              .secondary),
        ),
      ],
    );
  }

  Widget _upiGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 2.8,
      children: List.generate(_upiApps.length, (i) {
        final app = _upiApps[i];
        final selected = _selectedUpiApp == i;
        return GestureDetector(
          onTap: () => setState(() => _selectedUpiApp = selected ? -1 : i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            decoration: BoxDecoration(
              color: selected ? Theme
                  .of(context)
                  .primaryColor : AppColors.inputBgSecondary,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppColors.inputBorder, width: 1),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(color: app.iconBg, shape: BoxShape.circle),
                  child: ClipOval(child: Image.asset(app.imagePath, fit: BoxFit.cover)),
                ),
                const SizedBox(width: 8),
                Text(
                  app.name,
                  style: AppTextStyles.labelMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: selected ? Theme
                        .of(context)
                        .colorScheme
                        .surface : Theme
                        .of(context)
                        .colorScheme
                        .primary,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _dividerOr() =>
      Row(
        children: [
          const Expanded(child: Divider(color: AppColors.inputBorder, thickness: 1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text('or enter UPI ID', style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.w400,
              color: Theme
                  .of(context)
                  .colorScheme
                  .secondary,
            ),
            ),),
          const Expanded(child: Divider(color: AppColors.inputBorder, thickness: 1)),
        ],
      );

  Widget _upiIdInput() =>
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.inputBorder),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        height: 52,
        child: Row(
          children: [
            SvgPicture.asset(
              'assets/images/mobile.svg',
              height: 18,
              width: 18,
              colorFilter: const ColorFilter.mode(AppColors.textSecondary, BlendMode.srcIn),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _upiCtrl,
                style: AppTextStyles.bodyMedium.copyWith(color: Theme
                    .of(context)
                    .colorScheme
                    .primary),
                decoration: InputDecoration(
                  hintText: 'yourname@upi',
                  hintStyle: AppTextStyles.bodyMedium.copyWith(color: Theme
                      .of(context)
                      .colorScheme
                      .secondary),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
        ),
      );


  Widget _bankBody() {
    final banks = ['State Bank of India', 'HDFC Bank', 'ICICI Bank', 'Axis Bank', 'Kotak Mahindra Bank'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _amountCard(),
        const SizedBox(height: 22),
        const Text(
          'Select Your Bank',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.onLight),
        ),
        const SizedBox(height: 14),
        ...banks
            .asMap()
            .entries
            .map(
              (e) =>
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.inputBorder),
                  ),
                  child: ListTile(
                    leading: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                          color: AppColors.inputBgSecondary, borderRadius: BorderRadius.circular(12)),
                      child: Center(
                        child: SvgPicture.asset(
                          'assets/images/bank.svg',
                          height: 18,
                          width: 18,
                          colorFilter: const ColorFilter.mode(Color(0xFF64748B), BlendMode.srcIn),
                        ),
                      ),
                    ),
                    title: Text(
                      e.value,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.onLight),
                    ),
                    trailing: const Icon(Icons.chevron_right, color: Color(0xFFAAAAAA), size: 20),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
              ),
        ),
      ],
    );
  }
  Widget _amountCard() =>
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.inputBgSecondary,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppColors.inputBorder),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Amount Due',
                  style: AppTextStyles.captionMedium.copyWith(color: AppColors.textSecondary),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    SvgPicture.asset(
                      'assets/images/rupee.svg',
                      height: 16,
                      width: 16,
                      colorFilter: ColorFilter.mode(Theme
                          .of(context)
                          .colorScheme
                          .primary, BlendMode.srcIn),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '$_amount',
                      style: AppTextStyles.h3.copyWith(color: Theme
                          .of(context)
                          .colorScheme
                          .primary, fontWeight: FontWeight.w900, letterSpacing: 0),
                    ),
                  ],
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.successBg,
                borderRadius: BorderRadius.circular(2),
                border: Border.all(color: AppColors.successBorder),
              ),
              child: Row(
                children: [
                  SvgPicture.asset(
                    'assets/images/lock.svg',
                    height: 13,
                    width: 13,
                    colorFilter: ColorFilter.mode(AppColors.success, BlendMode.srcIn),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'SSL Secured',
                    style: AppTextStyles.captionSmall.copyWith(color: AppColors.success),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _inputField({required String hint, IconData? icon, String? svgPath, bool obscure = false}) =>
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.inputBorder),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        height: 48,
        child: Row(
          children: [
            if (svgPath != null)
              SvgPicture.asset(
                svgPath,
                height: 18,
                width: 18,
                colorFilter: ColorFilter.mode(Theme
                    .of(context)
                    .colorScheme
                    .secondary, BlendMode.srcIn),
              )
            else
              if (icon != null)
                Icon(icon, size: 18, color: Theme
                    .of(context)
                    .colorScheme
                    .secondary),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                obscureText: obscure,
                style: AppTextStyles.bodyMedium.copyWith(color: Theme
                    .of(context)
                    .colorScheme
                    .primary),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: AppTextStyles.bodyMedium.copyWith(color: Theme
                      .of(context)
                      .colorScheme
                      .secondary),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
        ),
      );

  // Card fields
  final _cardNumCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController();
  final _cvvCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  bool _saveCard = false;

  // Live card display values
  String get _displayNumber {
    final raw = _cardNumCtrl.text.replaceAll(' ', '');
    if (raw.isEmpty) return '2221 - 0057 - 4680 - 2089';
    final padded = raw.padRight(16, '•');
    return '${padded.substring(0, 4)} ${padded.substring(4, 8)} ${padded.substring(8, 12)} ${padded.substring(12, 16)}';
  }

  String get _displayName =>
      _nameCtrl.text.isEmpty ? 'YOUR NAME' : _nameCtrl.text.toUpperCase();

  String get _displayExpiry =>
      _expiryCtrl.text.isEmpty ? 'MM/YY' : _expiryCtrl.text;

  Widget _creditDebitBody({required bool isCredit}) {
    final label = isCredit ? 'Credit Card Details' : 'Debit Card Details';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTextStyles.titleLight.copyWith(fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.primary)),
        const SizedBox(height: 12),

        _CardPreview(
          number: _displayNumber,
          name: _displayName,
          isCredit: isCredit,
        ),
        const SizedBox(height: 16),

        _cardInputField(
          controller: _cardNumCtrl,
          hint: '1234 5678 9012 3456',
          icon: Icons.credit_card_outlined,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            _CardNumberFormatter(),
          ],
          maxLength: 19,
          suffix: SvgPicture.asset('assets/images/credit-card.svg'),
        ),
        const SizedBox(height: 16),

        Row(children: [
          Expanded(
            child: _cardInputField(
              controller: _expiryCtrl,
              hint: 'MM/YY',
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                _ExpiryFormatter(),
              ],
              maxLength: 5,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _cardInputField(
              controller: _cvvCtrl,
              hint: 'CVV',
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              maxLength: 3,
            ),
          ),
        ]),
        const SizedBox(height: 16),

        // Name field
        _cardInputField(
          controller: _nameCtrl,
          hint: 'Name as on card',
          textCapitalization: TextCapitalization.characters,
        ),
        const SizedBox(height: 16),

        // Save card checkbox
        GestureDetector(
          onTap: () => setState(() => _saveCard = !_saveCard),
          child: Row(children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: _saveCard ? AppColors.onLight : AppColors.onDark,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: _saveCard ? AppColors.onLight : AppColors.inputBorder,
                ),
              ),
              child: _saveCard
                  ? const Icon(Icons.check, size: 13, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 10),
            Text('Save this card for future payments',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontFamily: 'Poppins'
                )),
          ]),
        ),
      ],
    );
  }

  Widget _cardInputField({
    required TextEditingController controller,
    required String hint,
    IconData? icon,
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    int? maxLength,
    Widget? suffix,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: AppColors.inputBorder),
      ),
      padding: const EdgeInsets.all(16),
      height: 52,
      child: Row(children: [
        Expanded(
          child: TextField(
            controller: controller,
            obscureText: obscure,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            textCapitalization: textCapitalization,
            maxLength: maxLength,
            style: AppTextStyles.bodyMedium.copyWith(
                color: Theme.of(context).colorScheme.primary),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: Theme.of(context).colorScheme.primary),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
              counterText: '',
            ),
          ),
        ),
        ?suffix,
      ]),
    );
  }
}

class _CardPreview extends StatelessWidget {
  final String number;
  final String name;
  final bool isCredit;

  const _CardPreview({
    required this.number,
    required this.name,
    required this.isCredit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 185,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFF064A7D),Color(0xFF642401)],
        ),
      ),
      child: Stack(children: [
        // Card content
        Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isCredit ? 'Credit' : 'Debit',
                    style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w400,
                        color: Colors.white, letterSpacing: 0),
                  ),
                  SvgPicture.asset('assets/images/visa.svg', height: 48, width: 48),
                ],
              ),

              const Spacer(),
 Text(
                    name,
                    style: AppTextStyles.bodyLarge.copyWith(
                  color: Colors.white,
                  fontFamily: 'IBMPlexMono',
                ),
              ),
              // Card number
              Text(
                number,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: Colors.white,
                  fontFamily: 'IBMPlexMono',
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue old, TextEditingValue newVal) {
    final digits = newVal.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length && i < 16; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }
    final str = buffer.toString();
    return newVal.copyWith(
      text: str,
      selection: TextSelection.collapsed(offset: str.length),
    );
  }
}

class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue old, TextEditingValue newVal) {
    final digits = newVal.text.replaceAll('/', '');
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length && i < 4; i++) {
      if (i == 2) buffer.write('/');
      buffer.write(digits[i]);
    }
    final str = buffer.toString();
    return newVal.copyWith(
      text: str,
      selection: TextSelection.collapsed(offset: str.length),
    );
  }
}