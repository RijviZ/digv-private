import 'package:flutter/material.dart';

enum PayTab { upi, credit, debit, bank }

extension PayTabInfo on PayTab {
  String get label {
    switch (this) {
      case PayTab.upi:    return 'UPI';
      case PayTab.credit: return 'Credit';
      case PayTab.debit:  return 'Debit';
      case PayTab.bank:   return 'Bank';
    }
  }

  IconData get icon {
    switch (this) {
      case PayTab.upi:    return Icons.smartphone_outlined;
      case PayTab.credit: return Icons.credit_card_outlined;
      case PayTab.debit:  return Icons.credit_card_outlined;
      case PayTab.bank:   return Icons.account_balance_outlined;
    }
  }
}

class UpiApp {
  final String name;
  final Color bgColor;
  final Color iconBg;
  final _IconPainter iconPainter;

  const UpiApp({
    required this.name,
    required this.bgColor,
    required this.iconBg,
    required this.iconPainter,
  });
}

class PaymentGatewayScreen extends StatefulWidget {
  const PaymentGatewayScreen({super.key});

  @override
  State<PaymentGatewayScreen> createState() => _PaymentGatewayScreenState();
}

class _PaymentGatewayScreenState extends State<PaymentGatewayScreen> {
  PayTab _tab = PayTab.upi;
  int _selectedUpiApp = -1; // -1 = none
  final TextEditingController _upiCtrl = TextEditingController();

  static const int _amount = 525;

  final List<UpiApp> _upiApps = const [
    UpiApp(name: 'Google Pay',  bgColor: Color(0xFFF5F5F5), iconBg: Colors.white,         iconPainter: _GPainter()),
    UpiApp(name: 'PhonePe',     bgColor: Color(0xFFF5F5F5), iconBg: Color(0xFF5F259F),    iconPainter: _PPPainter()),
    UpiApp(name: 'Paytm',       bgColor: Color(0xFF111111), iconBg: Color(0xFF00BAF2),    iconPainter: _PaytmPainter()),
    UpiApp(name: 'BHIM UPI',    bgColor: Color(0xFFF5F5F5), iconBg: Color(0xFF6B3FA0),    iconPainter: _BhimPainter()),
  ];

  @override
  void dispose() {
    _upiCtrl.dispose();
    super.dispose();
  }

  String get _footerLabel {
    switch (_tab) {
      case PayTab.upi:    return 'UPI · Instant payment';
      case PayTab.credit: return 'Credit Card · Secure payment';
      case PayTab.debit:  return 'Debit Card · Secure payment';
      case PayTab.bank:   return 'Net Banking · Secure payment';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF3F8),
      body: SafeArea(
        child: Column(
          children: [
            _topBar(),
            _tabBar(),
            const Divider(height: 1, thickness: 1, color: Color(0xFFE4EAF2)),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: _tabBody(),
              ),
            ),
            _bottomBar(),
          ],
        ),
      ),
    );
  }

  // ── Top Bar ────────────────────────────────────────────────────────────────

  Widget _topBar() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    child: Row(children: [
      GestureDetector(
        onTap: () => Navigator.maybePop(context),
        child: const Icon(Icons.chevron_left, size: 26, color: Color(0xFF111111)),
      ),
      const Expanded(
        child: Text(
          'Payment Gateway',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400, color: Color(0xFF111111)),
        ),
      ),
      const SizedBox(width: 26),
    ]),
  );

  // ── Tab Bar ────────────────────────────────────────────────────────────────

  Widget _tabBar() => Container(
    color: Colors.white,
    child: Row(
      children: PayTab.values.map((tab) {
        final active = _tab == tab;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _tab = tab),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: active ? const Color(0xFF111111) : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    tab.icon,
                    size: 16,
                    color: active ? const Color(0xFF111111) : const Color(0xFF888888),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    tab.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                      color: active ? const Color(0xFF111111) : const Color(0xFF888888),
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

  // ── Tab Body ───────────────────────────────────────────────────────────────

  Widget _tabBody() {
    switch (_tab) {
      case PayTab.upi:
        return _upiBody();
      case PayTab.credit:
        return _cardBody(label: 'Credit Card');
      case PayTab.debit:
        return _cardBody(label: 'Debit Card');
      case PayTab.bank:
        return _bankBody();
    }
  }

  // ── UPI Body ───────────────────────────────────────────────────────────────

  Widget _upiBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _amountCard(),
        const SizedBox(height: 22),
        const Text(
          'Choose UPI App',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF111111)),
        ),
        const SizedBox(height: 14),
        _upiGrid(),
        const SizedBox(height: 20),
        _dividerOr(),
        const SizedBox(height: 16),
        _upiIdInput(),
        const SizedBox(height: 8),
        const Text(
          'Enter your UPI ID linked to any bank account',
          style: TextStyle(fontSize: 11, color: Color(0xFF888888)),
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
              color: selected ? const Color(0xFF111111) : app.bgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected ? const Color(0xFF111111) : const Color(0xFFDDDDDD),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: app.iconBg,
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: CustomPaint(
                      painter: app.iconPainter,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  app.name,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: selected ? Colors.white : const Color(0xFF111111),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _dividerOr() => Row(children: [
    const Expanded(child: Divider(color: Color(0xFFDDDDDD), thickness: 1)),
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Text(
        'or enter UPI ID',
        style: TextStyle(fontSize: 11, color: Colors.grey[500]),
      ),
    ),
    const Expanded(child: Divider(color: Color(0xFFDDDDDD), thickness: 1)),
  ]);

  Widget _upiIdInput() => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFDDDDDD)),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 14),
    height: 52,
    child: Row(children: [
      const Icon(Icons.smartphone_outlined, size: 18, color: Color(0xFF888888)),
      const SizedBox(width: 10),
      Expanded(
        child: TextField(
          controller: _upiCtrl,
          style: const TextStyle(fontSize: 14, color: Color(0xFF111111)),
          decoration: const InputDecoration(
            hintText: 'yourname@upi',
            hintStyle: TextStyle(fontSize: 14, color: Color(0xFFAAAAAA)),
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ),
    ]),
  );

  // ── Card Body ──────────────────────────────────────────────────────────────

  Widget _cardBody({required String label}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _amountCard(),
        const SizedBox(height: 22),
        Text(
          'Enter $label Details',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF111111)),
        ),
        const SizedBox(height: 16),
        _inputField(hint: 'Card number', icon: Icons.credit_card_outlined),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: _inputField(hint: 'MM / YY', icon: Icons.calendar_today_outlined)),
          const SizedBox(width: 10),
          Expanded(child: _inputField(hint: 'CVV', icon: Icons.lock_outline_rounded, obscure: true)),
        ]),
        const SizedBox(height: 10),
        _inputField(hint: 'Cardholder name', icon: Icons.person_outline_rounded),
        const SizedBox(height: 12),
        const Text(
          'Your card details are encrypted and never stored.',
          style: TextStyle(fontSize: 11, color: Color(0xFF888888)),
        ),
      ],
    );
  }

  // ── Bank Body ──────────────────────────────────────────────────────────────

  Widget _bankBody() {
    final banks = ['State Bank of India', 'HDFC Bank', 'ICICI Bank', 'Axis Bank', 'Kotak Mahindra Bank'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _amountCard(),
        const SizedBox(height: 22),
        const Text(
          'Select Your Bank',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF111111)),
        ),
        const SizedBox(height: 14),
        ...banks.asMap().entries.map((e) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFDDDDDD)),
            ),
            child: ListTile(
              leading: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.account_balance_outlined, size: 18, color: Color(0xFF555555)),
              ),
              title: Text(e.value,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF111111))),
              trailing: const Icon(Icons.chevron_right, color: Color(0xFFAAAAAA), size: 20),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            ),
          ),
        )),
      ],
    );
  }

  // ── Shared Widgets ─────────────────────────────────────────────────────────

  Widget _amountCard() => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    decoration: BoxDecoration(
      color: const Color(0xFFF7F8FA),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFE4EAF2)),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Amount Due',
                style: TextStyle(fontSize: 13, color: Color(0xFF888888))),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: const [
                Text('₹ ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF111111))),
                Text('$_amount', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF111111))),
              ],
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FBF4),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFBBDFC8)),
          ),
          child: Row(
            children: const [
              Icon(Icons.lock_outline_rounded, size: 13, color: Color(0xFF16A34A)),
              SizedBox(width: 5),
              Text('SSL Secured',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF16A34A))),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _inputField({
    required String hint,
    required IconData icon,
    bool obscure = false,
  }) =>
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFDDDDDD)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        height: 52,
        child: Row(children: [
          Icon(icon, size: 18, color: const Color(0xFF888888)),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              obscureText: obscure,
              style: const TextStyle(fontSize: 14, color: Color(0xFF111111)),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(fontSize: 14, color: Color(0xFFAAAAAA)),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ]),
      );

  // ── Bottom Bar ─────────────────────────────────────────────────────────────

  Widget _bottomBar() => Container(
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(top: BorderSide(color: Color(0xFFE4EAF2))),
    ),
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF7EE),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.lock_outline_rounded, size: 18, color: Color(0xFF16A34A)),
              ),
              const SizedBox(width: 10),
              Text(
                _footerLabel,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF555555)),
              ),
            ]),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: const [
                Text('₹ ', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF2563EB))),
                Text('$_amount', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF2563EB))),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () {},
          child: Container(
            width: double.infinity,
            height: 54,
            decoration: BoxDecoration(
              color: const Color(0xFF111111),
              borderRadius: BorderRadius.circular(36),
            ),
            alignment: Alignment.center,
            child: const Text(
              'Confirm & Pay',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
            ),
          ),
        ),
      ],
    ),
  );
}

// ─── Abstract icon painter ────────────────────────────────────────────────────

abstract class _IconPainter extends CustomPainter {
  const _IconPainter();
  @override
  bool shouldRepaint(covariant CustomPainter o) => false;
}

// ─── Google Pay icon ──────────────────────────────────────────────────────────

class _GPainter extends _IconPainter {
  const _GPainter();

  @override
  void paint(Canvas canvas, Size s) {
    final cx = s.width / 2;
    final cy = s.height / 2;
    final r = s.width * 0.3;

    // G-shape using 4 arcs / colored segments
    final colors = [
      const Color(0xFF4285F4),
      const Color(0xFF34A853),
      const Color(0xFFFBBC05),
      const Color(0xFFEA4335),
    ];
    for (int i = 0; i < 4; i++) {
      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.55
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: r),
        (i * 90 - 90) * (3.14159265 / 180),
        88 * (3.14159265 / 180),
        false,
        paint,
      );
    }
    // White centre
    canvas.drawCircle(Offset(cx, cy), r * 0.6,
        Paint()..color = Colors.white);
    // "G" letter
    final tp = TextPainter(
      text: const TextSpan(
        text: 'G',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Color(0xFF4285F4),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, cy - tp.height / 2));
  }
}

// ─── PhonePe icon ─────────────────────────────────────────────────────────────

class _PPPainter extends _IconPainter {
  const _PPPainter();

  @override
  void paint(Canvas canvas, Size s) {
    // Orange arrow on purple bg
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final cx = s.width / 2;
    final cy = s.height / 2;

    // Simple "Ph" arrow shape
    final path = Path()
      ..moveTo(cx - s.width * 0.22, cy - s.height * 0.28)
      ..lineTo(cx + s.width * 0.22, cy)
      ..lineTo(cx - s.width * 0.22, cy + s.height * 0.28)
      ..close();
    canvas.drawPath(path, paint..color = const Color(0xFFF7941D));
  }
}

// ─── Paytm icon ───────────────────────────────────────────────────────────────

class _PaytmPainter extends _IconPainter {
  const _PaytmPainter();

  @override
  void paint(Canvas canvas, Size s) {
    final cx = s.width / 2;
    final cy = s.height / 2;
    // "P" letter on blue bg
    final tp = TextPainter(
      text: const TextSpan(
        text: 'P',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w900,
          color: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, cy - tp.height / 2));
  }
}

// ─── BHIM UPI icon ────────────────────────────────────────────────────────────

class _BhimPainter extends _IconPainter {
  const _BhimPainter();

  @override
  void paint(Canvas canvas, Size s) {
    final cx = s.width / 2;
    final cy = s.height / 2;
    // "₹" on purple bg
    final tp = TextPainter(
      text: const TextSpan(
        text: '₹',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, cy - tp.height / 2));
  }
}