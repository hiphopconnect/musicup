import 'package:flutter/material.dart';
import 'package:music_up/theme/design_system.dart';

class CounterBar extends StatelessWidget {
  final int vinyl;
  final int cd;
  final int cassette;
  final int digitalMedium; // Medium: "Digital"
  final int digitalYes; // Flag: digital == true
  final int digitalNo; // Flag: digital == false

  const CounterBar({
    super.key,
    required this.vinyl,
    required this.cd,
    required this.cassette,
    required this.digitalMedium,
    required this.digitalYes,
    required this.digitalNo,
  });

  @override
  Widget build(BuildContext context) {
    final txtStyle = Theme.of(context).textTheme.bodySmall;

    Widget item(String label, int value, {IconData? icon}) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14),
            const SizedBox(width: 6),
          ],
          Text('$label: $value', style: txtStyle),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.all(DS.md),
      child: Column(
        children: [
          Wrap(
            spacing: DS.lg,
            runSpacing: DS.xs,
            alignment: WrapAlignment.center,
            children: [
              item('Vinyl', vinyl, icon: Icons.album),
              item('CD', cd, icon: Icons.disc_full),
              item('Cassette', cassette, icon: Icons.view_agenda),
              item('Digital', digitalMedium, icon: Icons.cloud_download),
            ],
          ),
          const SizedBox(height: DS.xs),
          Wrap(
            spacing: DS.lg,
            runSpacing: DS.xs,
            alignment: WrapAlignment.center,
            children: [
              item('Digital Yes', digitalYes, icon: Icons.cloud_done),
              item('Digital No', digitalNo, icon: Icons.cloud_off),
            ],
          ),
        ],
      ),
    );
  }
}
