import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../data/repositories/providers.dart';
import '../../shared/widgets/reusable_widgets.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsNotifierProvider);
    final settingsNotifier = ref.read(settingsNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            // Appearance Section
            const SectionHeader(title: 'Appearance'),
            Card(
              child: Column(
                children: [
                  RadioListTile<String>(
                    title: const Text('System Default'),
                    value: 'system',
                    groupValue: settings.themeMode,
                    onChanged: (val) {
                      if (val != null) {
                        settingsNotifier.updateSettings(settings.copyWith(themeMode: val));
                      }
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Light Mode'),
                    value: 'light',
                    groupValue: settings.themeMode,
                    onChanged: (val) {
                      if (val != null) {
                        settingsNotifier.updateSettings(settings.copyWith(themeMode: val));
                      }
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Dark Mode'),
                    value: 'dark',
                    groupValue: settings.themeMode,
                    onChanged: (val) {
                      if (val != null) {
                        settingsNotifier.updateSettings(settings.copyWith(themeMode: val));
                      }
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Meditation Preferences Section
            const SectionHeader(title: 'Meditation Preferences'),
            Card(
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Default Session Length'),
                    subtitle: Text('${settings.defaultDurationMinutes} minutes'),
                    trailing: DropdownButton<int>(
                      value: settings.defaultDurationMinutes,
                      underline: const SizedBox.shrink(),
                      items: [3, 5, 10].map((mins) {
                        return DropdownMenuItem<int>(
                          value: mins,
                          child: Text('$mins mins'),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          settingsNotifier.updateSettings(settings.copyWith(defaultDurationMinutes: val));
                        }
                      },
                    ),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Breathing Sound Cues'),
                    subtitle: const Text('Gentle audio chime during breathing exercise'),
                    value: settings.breathingSoundEnabled,
                    onChanged: (val) {
                      settingsNotifier.updateSettings(settings.copyWith(breathingSoundEnabled: val));
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Storage & Local Data Section
            const SectionHeader(title: 'Storage & Data Management'),
            Card(
              child: Column(
                children: [
                  const ListTile(
                    leading: Icon(Icons.folder_outlined, color: AppColors.primarySage),
                    title: Text('Bundled & Downloaded Assets'),
                    subtitle: Text('All core sessions are stored locally (Offline First)'),
                    trailing: Text('Bundled'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    title: const Text('Clear Session History'),
                    subtitle: const Text('Reset local history and activity logs'),
                    onTap: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (dialogContext) => AlertDialog(
                          title: const Text('Clear Session History?'),
                          content: const Text('This will remove all recorded session logs from local storage. Your favorites will be kept.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(dialogContext, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
                              onPressed: () => Navigator.pop(dialogContext, true),
                              child: const Text('Clear Data'),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        await ref.read(historyNotifierProvider.notifier).clearHistoryRecords();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Session history cleared successfully.')),
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Information & Privacy Section
            const SectionHeader(title: 'Information & Privacy'),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.info_outline, color: AppColors.primarySage),
                    title: const Text('About Find Your Calm'),
                    subtitle: const Text('Version 1.0.0 • Offline Guided Meditation'),
                    onTap: () {
                      showAboutDialog(
                        context: context,
                        applicationName: 'Find Your Calm',
                        applicationVersion: '1.0.0',
                        applicationIcon: const Icon(Icons.spa, size: 48, color: AppColors.deepForest),
                        children: [
                          const SizedBox(height: 16),
                          const Text(
                            'Find Your Calm is a beginner-friendly meditation app designed to help you relax, practice mindfulness, improve focus, and prepare for sleep through offline exercises.',
                          ),
                        ],
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.privacy_tip_outlined, color: AppColors.primarySage),
                    title: const Text('Privacy & Wellbeing Policy'),
                    subtitle: const Text('100% private, local data storage'),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (dialogContext) => AlertDialog(
                          title: const Text('Privacy & Wellbeing Policy'),
                          content: const SingleChildScrollView(
                            child: Text(
                              'Find Your Calm is built with an offline-first philosophy.\n\n'
                              '• No Personal Data Collection: All meditation statistics, favorites, and settings stay on your device.\n'
                              '• Health Disclaimer: Exercises are for relaxation and mindfulness only and do not replace professional mental health care or medical advice.\n'
                              '• No Tracking: No ad SDKs or third-party trackers are used.',
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(dialogContext),
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
