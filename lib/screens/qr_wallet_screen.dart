import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../data/models.dart';
import '../theme/app_theme.dart';
import '../widgets/app_icons.dart';
import '../widgets/bottom_tab_bar.dart';

/// "My Tickets": active tickets show a full-size QR, spent ones collapse to a
/// thumbnail beside their reference.
class QrWalletScreen extends StatelessWidget {
  const QrWalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final int active = MockData.tickets
        .where((Ticket t) => t.status == TicketStatus.active)
        .length;
    final int used =
        MockData.tickets.length - active;

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Column(
        children: <Widget>[
          ScreenHeader(
            title: 'My Tickets',
            subtitle: '$active active \u00b7 $used used',
            background: AppColors.charcoal,
            bottomPadding: 20,
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: MockData.tickets.length,
              itemBuilder: (BuildContext context, int index) {
                final Ticket ticket = MockData.tickets[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _TicketCard(ticket: ticket),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  const _TicketCard({required this.ticket});

  final Ticket ticket;

  bool get _isActive => ticket.status == TicketStatus.active;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: _isActive ? 1 : 0.7,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppRadii.card),
          boxShadow: _isActive ? AppShadows.floating : AppShadows.soft,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _TicketBanner(ticket: ticket),
            if (_isActive) _ActiveBody(ticket: ticket) else _UsedBody(ticket: ticket),
          ],
        ),
      ),
    );
  }
}

class _TicketBanner extends StatelessWidget {
  const _TicketBanner({required this.ticket});

  final Ticket ticket;

  @override
  Widget build(BuildContext context) {
    final bool isActive = ticket.status == TicketStatus.active;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      color: isActive ? AppColors.forest : AppColors.muted,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                ticket.date,
                style: TextStyle(
                  fontFamily: AppFonts.body,
                  fontSize: 11,
                  color: AppColors.white.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                ticket.site,
                style: const TextStyle(
                  fontFamily: AppFonts.body,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.gold
                  : AppColors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isActive ? 'VALID' : 'USED',
              style: TextStyle(
                fontFamily: AppFonts.body,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isActive
                    ? AppColors.charcoal
                    : AppColors.white.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveBody extends StatelessWidget {
  const _ActiveBody({required this.ticket});

  final Ticket ticket;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: <Widget>[
          const SizedBox(width: 160, height: 160, child: QrCodeView()),
          const SizedBox(height: 14),
          const Text(
            'Scan at entrance',
            style: TextStyle(
              fontFamily: AppFonts.body,
              fontSize: 11,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            ticket.reference,
            style: const TextStyle(
              fontFamily: AppFonts.body,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: <Widget>[
              Expanded(
                child: _Stat(
                  label: 'Adults',
                  value: '${ticket.adults}',
                  color: AppColors.charcoal,
                  background: AppColors.cream,
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: _Stat(
                  label: 'Entry',
                  value: 'Paid \u2713',
                  color: AppColors.forest,
                  background: Color(0x1F2C5F2D),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.label,
    required this.value,
    required this.color,
    required this.background,
  });

  final String label;
  final String value;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: <Widget>[
          Text(
            label,
            style: const TextStyle(
              fontFamily: AppFonts.body,
              fontSize: 11,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontFamily: AppFonts.body,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _UsedBody extends StatelessWidget {
  const _UsedBody({required this.ticket});

  final Ticket ticket;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        children: <Widget>[
          const Opacity(
            opacity: 0.5,
            child: SizedBox(width: 48, height: 48, child: QrCodeView()),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                ticket.reference,
                style: const TextStyle(
                  fontFamily: AppFonts.body,
                  fontSize: 12,
                  color: AppColors.muted,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${ticket.adults} adult${ticket.adults > 1 ? 's' : ''} \u00b7 Entry used',
                style: const TextStyle(
                  fontFamily: AppFonts.body,
                  fontSize: 13,
                  color: AppColors.charcoal,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
