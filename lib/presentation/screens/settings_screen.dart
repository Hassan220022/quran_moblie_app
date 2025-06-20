import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/preference_settings_provider.dart';
import '../providers/enhanced_theme_provider.dart';
import '../../core/utils/app_theme.dart';
import '../../services/accessibility_service.dart';
import 'simple_cache_management.dart';
import 'notification_settings_screen.dart';
import 'accessibility_settings_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer2<PreferenceSettingsProvider, EnhancedThemeProvider>(
        builder: (context, prefProvider, themeProvider, child) {
          final colorScheme = Theme.of(context).colorScheme;
          final isDarkTheme = themeProvider.isDarkTheme(context);

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDarkTheme
                    ? [colorScheme.surface, colorScheme.surfaceContainerHighest]
                    : [
                        colorScheme.surface,
                        colorScheme.surfaceContainerHighest
                      ],
              ),
            ),
            child: CustomScrollView(
              slivers: [
                // App Bar
                SliverAppBar(
                  expandedHeight: 120,
                  floating: false,
                  pinned: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  automaticallyImplyLeading: false,
                  flexibleSpace: FlexibleSpaceBar(
                    title: const Text(
                      'Settings',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: themeProvider.currentGradient,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.settings,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),

                // Settings Content
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Theme & Appearance Section
                        _buildSectionHeader(
                            'Theme & Appearance', Icons.palette, colorScheme),
                        _buildSettingsCard(
                          colorScheme: colorScheme,
                          children: [
                            _buildSwitchTile(
                              icon: isDarkTheme
                                  ? Icons.dark_mode
                                  : Icons.light_mode,
                              title: 'Dark Theme',
                              subtitle: 'Toggle between light and dark themes',
                              value:
                                  themeProvider.themeMode == ThemeMode.dark ||
                                      (themeProvider.themeMode ==
                                              ThemeMode.system &&
                                          isDarkTheme),
                              onChanged: (value) {
                                themeProvider.setThemeMode(
                                    value ? ThemeMode.dark : ThemeMode.light);
                              },
                              colorScheme: colorScheme,
                              color: colorScheme.primary,
                            ),
                            _buildDropdownTile(
                              icon: Icons.color_lens,
                              title: 'Theme Style',
                              subtitle: themeProvider.themeStyle.name,
                              onTap: () =>
                                  _showThemeStyleDialog(context, themeProvider),
                              colorScheme: colorScheme,
                              color: colorScheme.secondary,
                            ),
                            _buildDropdownTile(
                              icon: Icons.font_download,
                              title: 'Arabic Font',
                              subtitle: themeProvider.arabicFont.displayName,
                              onTap: () =>
                                  _showArabicFontDialog(context, themeProvider),
                              colorScheme: colorScheme,
                              color: colorScheme.tertiary,
                            ),
                            _buildSliderTile(
                              icon: Icons.format_size,
                              title: 'Font Scale',
                              subtitle:
                                  '${(themeProvider.fontScale * 100).round()}%',
                              value: themeProvider.fontScale,
                              min: 0.7,
                              max: 2.0,
                              divisions: 13,
                              onChanged: (value) =>
                                  themeProvider.setFontScale(value),
                              colorScheme: colorScheme,
                              color: colorScheme.primary,
                            ),
                            _buildSwitchTile(
                              icon: Icons.contrast,
                              title: 'High Contrast',
                              subtitle:
                                  'Improve readability with higher contrast',
                              value: themeProvider.isHighContrast,
                              onChanged: (value) =>
                                  themeProvider.setHighContrast(value),
                              colorScheme: colorScheme,
                              color: colorScheme.error,
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Accessibility Section
                        _buildSectionHeader('Accessibility',
                            Icons.accessibility_new, colorScheme),
                        _buildSettingsCard(
                          colorScheme: colorScheme,
                          children: [
                            _buildSwitchTile(
                              icon: Icons.record_voice_over,
                              title: 'Text-to-Speech',
                              subtitle: 'Enable voice reading of content',
                              value: AccessibilityService().isTtsEnabled,
                              onChanged: (value) =>
                                  AccessibilityService().setTtsEnabled(value),
                              colorScheme: colorScheme,
                              color: colorScheme.primary,
                            ),
                            _buildSwitchTile(
                              icon: Icons.animation,
                              title: 'Reduce Animations',
                              subtitle:
                                  'Minimize motion for better accessibility',
                              value: themeProvider.reduceAnimations,
                              onChanged: (value) =>
                                  themeProvider.setReduceAnimations(value),
                              colorScheme: colorScheme,
                              color: colorScheme.secondary,
                            ),
                            _buildSwitchTile(
                              icon: Icons.vibration,
                              title: 'Haptic Feedback',
                              subtitle: 'Feel vibrations for interactions',
                              value: themeProvider.enableHaptics,
                              onChanged: (value) =>
                                  themeProvider.setEnableHaptics(value),
                              colorScheme: colorScheme,
                              color: colorScheme.tertiary,
                            ),
                            _buildNavigationTile(
                              icon: Icons.accessibility_new,
                              title: 'Advanced Accessibility',
                              subtitle: 'TTS settings, voice controls & more',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const AccessibilitySettingsScreen(),
                                  ),
                                );
                              },
                              colorScheme: colorScheme,
                              color: colorScheme.primary,
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Reading Experience Section
                        _buildSectionHeader(
                            'Reading Experience', Icons.menu_book, colorScheme),
                        _buildSettingsCard(
                          colorScheme: colorScheme,
                          children: [
                            _buildSliderTile(
                              icon: Icons.format_size,
                              title: 'Arabic Text Size',
                              subtitle:
                                  '${prefProvider.arabicFontSize.round()}px',
                              value: prefProvider.arabicFontSize,
                              min: 14.0,
                              max: 32.0,
                              divisions: 18,
                              onChanged: (value) =>
                                  prefProvider.setArabicFontSize(value),
                              colorScheme: colorScheme,
                              color: colorScheme.primary,
                            ),
                            _buildSwitchTile(
                              icon: Icons.nightlight_round,
                              title: 'Night Reading Mode',
                              subtitle: 'Dim screen for comfortable reading',
                              value: prefProvider.isNightReadingMode,
                              onChanged: (value) =>
                                  prefProvider.enableNightReadingMode(value),
                              colorScheme: colorScheme,
                              color: colorScheme.secondary,
                            ),
                            _buildSwitchTile(
                              icon: Icons.translate,
                              title: 'Show Translation',
                              subtitle: 'Display verse translations',
                              value: prefProvider.showTranslation,
                              onChanged: (value) =>
                                  prefProvider.toggleTranslation(value),
                              colorScheme: colorScheme,
                              color: colorScheme.tertiary,
                            ),
                            if (prefProvider.showTranslation)
                              _buildDropdownTile(
                                icon: Icons.language,
                                title: 'Translation Language',
                                subtitle: PreferenceSettingsProvider
                                            .availableTranslations[
                                        prefProvider.selectedTranslation] ??
                                    'Select',
                                onTap: () => _showTranslationDialog(
                                    context, prefProvider),
                                colorScheme: colorScheme,
                                color: colorScheme.tertiary,
                              ),
                            _buildSwitchTile(
                              icon: Icons.book,
                              title: 'Show Tafsir',
                              subtitle: 'Display scholarly commentary',
                              value: prefProvider.showTafsir,
                              onChanged: (value) =>
                                  prefProvider.toggleTafsir(value),
                              colorScheme: colorScheme,
                              color: colorScheme.primary,
                            ),
                            if (prefProvider.showTafsir)
                              _buildDropdownTile(
                                icon: Icons.school,
                                title: 'Tafsir Source',
                                subtitle:
                                    PreferenceSettingsProvider.availableTafsir[
                                            prefProvider.selectedTafsir] ??
                                        'Select',
                                onTap: () =>
                                    _showTafsirDialog(context, prefProvider),
                                colorScheme: colorScheme,
                                color: colorScheme.primary,
                              ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Notifications & Alerts Section
                        _buildSectionHeader('Notifications & Alerts',
                            Icons.notifications, colorScheme),
                        _buildSettingsCard(
                          colorScheme: colorScheme,
                          children: [
                            _buildNavigationTile(
                              icon: Icons.notification_important,
                              title: 'Prayer Notifications',
                              subtitle: 'Configure prayer time alerts',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const NotificationSettingsScreen(),
                                  ),
                                );
                              },
                              colorScheme: colorScheme,
                              color: colorScheme.primary,
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Storage & Cache Section
                        _buildSectionHeader(
                            'Storage & Offline', Icons.storage, colorScheme),
                        _buildSettingsCard(
                          colorScheme: colorScheme,
                          children: [
                            _buildNavigationTile(
                              icon: Icons.cloud_download,
                              title: 'Cache Management',
                              subtitle: 'Manage offline content and storage',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const SimpleCacheManagementScreen(),
                                  ),
                                );
                              },
                              colorScheme: colorScheme,
                              color: colorScheme.secondary,
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Quick Actions Section
                        _buildSectionHeader(
                            'Quick Actions', Icons.flash_on, colorScheme),
                        _buildSettingsCard(
                          colorScheme: colorScheme,
                          children: [
                            _buildActionTile(
                              icon: Icons.mosque,
                              title: 'Apply Islamic Theme',
                              subtitle: 'Set Islamic theme with Arabic fonts',
                              onTap: () => themeProvider.applyIslamicPreset(),
                              colorScheme: colorScheme,
                              color: colorScheme.primary,
                            ),
                            _buildActionTile(
                              icon: Icons.accessibility,
                              title: 'Enable Accessibility Mode',
                              subtitle:
                                  'High contrast, large fonts, reduced motion',
                              onTap: () =>
                                  themeProvider.enableAccessibilityMode(),
                              colorScheme: colorScheme,
                              color: colorScheme.secondary,
                            ),
                            _buildActionTile(
                              icon: Icons.restore,
                              title: 'Reset to Defaults',
                              subtitle:
                                  'Restore all settings to default values',
                              onTap: () => _showResetDialog(
                                  context, themeProvider, prefProvider),
                              colorScheme: colorScheme,
                              color: colorScheme.error,
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // About Section
                        _buildSectionHeader(
                            'About', Icons.info_outline, colorScheme),
                        _buildSettingsCard(
                          colorScheme: colorScheme,
                          children: [
                            _buildNavigationTile(
                              icon: Icons.info,
                              title: 'App Information',
                              subtitle: 'Version, credits, and acknowledgments',
                              onTap: () => _showAboutDialog(context),
                              colorScheme: colorScheme,
                              color: colorScheme.primary,
                            ),
                            _buildNavigationTile(
                              icon: Icons.help_outline,
                              title: 'Help & Support',
                              subtitle: 'Get help using the app',
                              onTap: () => _showHelpDialog(context),
                              colorScheme: colorScheme,
                              color: colorScheme.secondary,
                            ),
                          ],
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(
      String title, IconData icon, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard({
    required ColorScheme colorScheme,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    required ColorScheme colorScheme,
    required Color color,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: color,
      ),
    );
  }

  Widget _buildSliderTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required Function(double) onChanged,
    required ColorScheme colorScheme,
    required Color color,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            activeColor: color,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required ColorScheme colorScheme,
    required Color color,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: colorScheme.onSurfaceVariant,
      ),
      onTap: onTap,
    );
  }

  Widget _buildNavigationTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required ColorScheme colorScheme,
    required Color color,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: colorScheme.onSurfaceVariant,
      ),
      onTap: onTap,
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required ColorScheme colorScheme,
    required Color color,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: Icon(
        Icons.play_arrow,
        color: color,
      ),
      onTap: onTap,
    );
  }

  // Dialog methods
  void _showThemeStyleDialog(
      BuildContext context, EnhancedThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Theme Style'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: AppThemeStyle.values.length,
            itemBuilder: (context, index) {
              final style = AppThemeStyle.values[index];
              return RadioListTile<AppThemeStyle>(
                title: Text(style.name),
                value: style,
                groupValue: themeProvider.themeStyle,
                onChanged: (value) {
                  if (value != null) {
                    themeProvider.setThemeStyle(value);
                    Navigator.pop(context);
                  }
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showArabicFontDialog(
      BuildContext context, EnhancedThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Arabic Font'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: ArabicFontFamily.values.length,
            itemBuilder: (context, index) {
              final font = ArabicFontFamily.values[index];
              return RadioListTile<ArabicFontFamily>(
                title: Text(font.displayName),
                value: font,
                groupValue: themeProvider.arabicFont,
                onChanged: (value) {
                  if (value != null) {
                    themeProvider.setArabicFont(value);
                    Navigator.pop(context);
                  }
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showTranslationDialog(
      BuildContext context, PreferenceSettingsProvider prefProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Translation'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: PreferenceSettingsProvider.availableTranslations.length,
            itemBuilder: (context, index) {
              final key = PreferenceSettingsProvider.availableTranslations.keys
                  .elementAt(index);
              final value =
                  PreferenceSettingsProvider.availableTranslations[key]!;
              return RadioListTile<String>(
                title: Text(value),
                value: key,
                groupValue: prefProvider.selectedTranslation,
                onChanged: (selectedKey) {
                  if (selectedKey != null) {
                    prefProvider.setSelectedTranslation(selectedKey);
                    Navigator.pop(context);
                  }
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showTafsirDialog(
      BuildContext context, PreferenceSettingsProvider prefProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Tafsir'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: PreferenceSettingsProvider.availableTafsir.length,
            itemBuilder: (context, index) {
              final key = PreferenceSettingsProvider.availableTafsir.keys
                  .elementAt(index);
              final value = PreferenceSettingsProvider.availableTafsir[key]!;
              return RadioListTile<String>(
                title: Text(value),
                value: key,
                groupValue: prefProvider.selectedTafsir,
                onChanged: (selectedKey) {
                  if (selectedKey != null) {
                    prefProvider.setSelectedTafsir(selectedKey);
                    Navigator.pop(context);
                  }
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(
      BuildContext context,
      EnhancedThemeProvider themeProvider,
      PreferenceSettingsProvider prefProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text(
          'Are you sure you want to reset all settings to their default values? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              themeProvider.resetToDefaults();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings reset to defaults')),
              );
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Quran App'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  'A comprehensive digital companion for reading the Holy Quran.'),
              SizedBox(height: 16),
              Text('Features:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('• Complete Quran with audio recitations'),
              Text('• Multiple translations and tafsir'),
              Text('• Prayer times and Qibla direction'),
              Text('• Islamic calendar and events'),
              Text('• Offline reading capabilities'),
              Text('• Community features and sharing'),
              Text('• Advanced accessibility support'),
              Text('• Customizable themes and fonts'),
              Text('• Reading progress tracking'),
              Text('• Intelligent bookmarks'),
              SizedBox(height: 16),
              Text('Version 2.0.0',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('Built with Flutter and Material 3 Design'),
              Text('Powered by Al-Quran Cloud API'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('How to use the app:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('• Tap on any Surah to start reading'),
              Text('• Use the audio button to listen to recitations'),
              Text('• Long-press verses to bookmark them'),
              Text('• Swipe between pages for smooth navigation'),
              Text('• Access quick settings from the bottom navigation'),
              Text('• Download content for offline reading'),
              Text('• Use voice commands for hands-free operation'),
              SizedBox(height: 16),
              Text('Accessibility:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('• Enable text-to-speech for voice reading'),
              Text('• Adjust font sizes and contrast'),
              Text('• Reduce animations for motion sensitivity'),
              Text('• Use high contrast mode for better visibility'),
              SizedBox(height: 16),
              Text('For support, please contact us through the app store.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
