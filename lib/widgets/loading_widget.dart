// lib/widgets/loading_widget.dart

import 'package:flutter/material.dart';
import 'package:music_up/l10n/app_localizations.dart';
import 'package:music_up/theme/app_theme.dart';

/// Wiederverwendbares Loading Widget
class LoadingWidget extends StatelessWidget {
  final String? message;
  final double? size;

  const LoadingWidget({
    super.key,
    this.message,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size ?? 50,
            height: size ?? 50,
            child: const CircularProgressIndicator(),
          ),
          const SizedBox(height: 16),
          Text(
            message ?? l10n.loading,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

/// Skeleton-Loading für Listen
class SkeletonListItem extends StatelessWidget {
  const SkeletonListItem({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.charcoal,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.grey[400],
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        title: Container(
          height: 16,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[400],
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        subtitle: Container(
          height: 14,
          width: 150,
          margin: const EdgeInsets.only(top: 8),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}

/// Loading-Liste mit mehreren Skeleton-Items
class SkeletonLoadingList extends StatelessWidget {
  final int itemCount;
  
  const SkeletonLoadingList({super.key, this.itemCount = 5});
  
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: (context, index) => const SkeletonListItem(),
    );
  }
}