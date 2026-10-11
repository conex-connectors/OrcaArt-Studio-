import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';

class VideoAdjSheet extends StatelessWidget {
  const VideoAdjSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final planTier = s.bal('plan_tier');
    final tier = planTier < 0 ? 0 : planTier;
    const ratios = ['9:16', '16:9', '1:1', '4:5', '21:9'];
    const qualities = ['480p', '720p', '1080p'];
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Video settings', style: Theme.of(context).textTheme.titleLarge),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(s.marketing ? 'Marketing agent' : 'Creative agent'),
                subtitle: Text(s.marketing ? 'Videos are made as ads' : 'Original content, no ads'),
                value: s.marketing,
                onChanged: (v) => s.updateVideo(m: v),
              ),
              Text('Duration: ${s.duration}s  (${s.creditCost} credit${s.creditCost == 1 ? '' : 's'} used)'),
              Slider(value: s.duration.toDouble(), min: 1, max: 3600, onChanged: (v) => s.updateVideo(d: v.round())),
              const Text('Quality'),
              Wrap(
                spacing: 8,
                children: [
                  for (var i = 0; i < 3; i++)
                    ChoiceChip(
                      label: Text(i > tier ? '${qualities[i]} (locked)' : qualities[i]),
                      selected: s.quality == i,
                      onSelected: (_) {
                        if (i > tier) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Upgrade your plan to unlock this quality.')));
                        } else {
                          s.updateVideo(q: i);
                        }
                      },
                    ),
                ],
              ),
              const SizedBox(height: 12),
              const Text('Ratio'),
              Wrap(
                spacing: 8,
                children: [
                  for (final r in ratios) ChoiceChip(label: Text(r), selected: s.ratio == r, onSelected: (_) => s.updateVideo(r: r)),
                ],
              ),
              const SizedBox(height: 12),
              Text('Quantity: ${s.quantity}'),
              Slider(value: s.quantity.toDouble(), min: 1, max: 100, divisions: 99, onChanged: (v) => s.updateVideo(n: v.round())),
              const SizedBox(height: 8),
              SizedBox(width: double.infinity, child: FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Save'))),
            ],
          ),
        ),
      ),
    );
  }
}
