import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hearbat/streaks/streaks_provider.dart';

class StreakBadge extends StatelessWidget {
  const StreakBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<StreakProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const SizedBox(
            width: 40,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          );
        }

        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.local_fire_department, color: Colors.orange),
              const SizedBox(width: 4),
              Text(
                '${provider.currentStreak}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
