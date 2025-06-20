import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/provider/preference_settings_provider.dart';
import '../screens/simple_cache_management.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<PreferenceSettingsProvider>(
        builder: (context, prefProvider, child) {
          final isDarkTheme = prefProvider.isDarkTheme;

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDarkTheme
                    ? [const Color(0xFF1a1a2e), const Color(0xFF16213e)]
                    : [const Color(0xFFf8f9fa), Colors.white],
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
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF667eea),
                            const Color(0xFF764ba2),
                          ],
                        ),
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
                  iconTheme: const IconThemeData(color: Colors.white),
                ),

                // Settings Content
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Appearance Section
                        _buildSectionHeader(
                            'Appearance', Icons.palette, isDarkTheme),
                        _buildSettingsCard(
                          isDarkTheme: isDarkTheme,
                          children: [
                            _buildSwitchTile(
                              icon: isDarkTheme
                                  ? Icons.dark_mode
                                  : Icons.light_mode,
                              title: 'Dark Theme',
                              subtitle: 'Toggle between light and dark themes',
                              value: isDarkTheme,
                              onChanged: (value) =>
                                  prefProvider.enableDarkTheme(value),
                              isDarkTheme: isDarkTheme,
                              color: const Color(0xFF9C27B0),
                            ),
                            _buildSliderTile(
                              icon: Icons.format_size,
                              title: 'Arabic Font Size',
                              subtitle:
                                  '${prefProvider.arabicFontSize.round()}px',
                              value: prefProvider.arabicFontSize,
                              min: 14.0,
                              max: 32.0,
                              divisions: 18,
                              onChanged: (value) =>
                                  prefProvider.setArabicFontSize(value),
                              isDarkTheme: isDarkTheme,
                              color: const Color(0xFF4CAF50),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Reading Settings
                        _buildSectionHeader(
                            'Reading Experience', Icons.menu_book, isDarkTheme),
                        _buildSettingsCard(
                          isDarkTheme: isDarkTheme,
                          children: [
                            _buildSwitchTile(
                              icon: Icons.nightlight_round,
                              title: 'Night Reading Mode',
                              subtitle: 'Dim screen for comfortable reading',
                              value: prefProvider.isNightReadingMode,
                              onChanged: (value) =>
                                  prefProvider.enableNightReadingMode(value),
                              isDarkTheme: isDarkTheme,
                              color: const Color(0xFF673AB7),
                            ),
                            _buildSwitchTile(
                              icon: Icons.translate,
                              title: 'Show Translation',
                              subtitle: 'Display verse translations',
                              value: prefProvider.showTranslation,
                              onChanged: (value) =>
                                  prefProvider.toggleTranslation(value),
                              isDarkTheme: isDarkTheme,
                              color: const Color(0xFF2196F3),
                            ),
                            if (prefProvider.showTranslation)
                              _buildDropdownTile(
                                icon: Icons.language,
                                title: 'Translation Language',
                                subtitle: PreferenceSettingsProvider
                                            .availableTranslations[
                                        prefProvider.selectedTranslation] ??
                                    'Select',
                                options: PreferenceSettingsProvider
                                    .availableTranslations,
                                currentValue: prefProvider.selectedTranslation,
                                onChanged: (value) =>
                                    prefProvider.setSelectedTranslation(value),
                                isDarkTheme: isDarkTheme,
                                color: const Color(0xFF2196F3),
                              ),
                            _buildSwitchTile(
                              icon: Icons.book,
                              title: 'Show Tafsir',
                              subtitle: 'Display scholarly commentary',
                              value: prefProvider.showTafsir,
                              onChanged: (value) =>
                                  prefProvider.toggleTafsir(value),
                              isDarkTheme: isDarkTheme,
                              color: const Color(0xFFFF9800),
                            ),
                            if (prefProvider.showTafsir)
                              _buildDropdownTile(
                                icon: Icons.school,
                                title: 'Tafsir Source',
                                subtitle:
                                    PreferenceSettingsProvider.availableTafsir[
                                            prefProvider.selectedTafsir] ??
                                        'Select',
                                options:
                                    PreferenceSettingsProvider.availableTafsir,
                                currentValue: prefProvider.selectedTafsir,
                                onChanged: (value) =>
                                    prefProvider.setSelectedTafsir(value),
                                isDarkTheme: isDarkTheme,
                                color: const Color(0xFFFF9800),
                              ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Storage & Cache
                        _buildSectionHeader(
                            'Storage & Offline', Icons.storage, isDarkTheme),
                        _buildSettingsCard(
                          isDarkTheme: isDarkTheme,
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
                              isDarkTheme: isDarkTheme,
                              color: const Color(0xFF607D8B),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // About Section
                        _buildSectionHeader(
                            'About', Icons.info_outline, isDarkTheme),
                        _buildSettingsCard(
                          isDarkTheme: isDarkTheme,
                          children: [
                            _buildNavigationTile(
                              icon: Icons.info,
                              title: 'App Information',
                              subtitle: 'Version, credits, and acknowledgments',
                              onTap: () => _showAboutDialog(context),
                              isDarkTheme: isDarkTheme,
                              color: const Color(0xFF795548),
                            ),
                            _buildNavigationTile(
                              icon: Icons.help_outline,
                              title: 'Help & Support',
                              subtitle: 'Get help using the app',
                              onTap: () => _showHelpDialog(context),
                              isDarkTheme: isDarkTheme,
                              color: const Color(0xFF009688),
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

  Widget _buildSectionHeader(String title, IconData icon, bool isDarkTheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF667eea),
                  const Color(0xFF764ba2),
                ],
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
              color: isDarkTheme ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard({
    required bool isDarkTheme,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDarkTheme
              ? [const Color(0xFF2a2a3e), const Color(0xFF1e1e2e)]
              : [Colors.white, const Color(0xFFf8f9fa)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDarkTheme
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 3),
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
    required bool isDarkTheme,
    required Color color,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isDarkTheme ? Colors.white : Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: isDarkTheme ? Colors.white70 : Colors.grey[600],
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
    required bool isDarkTheme,
    required Color color,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isDarkTheme ? Colors.white : Colors.black87,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(
              color: isDarkTheme ? Colors.white70 : Colors.grey[600],
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
    required Map<String, String> options,
    required String currentValue,
    required Function(String) onChanged,
    required bool isDarkTheme,
    required Color color,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isDarkTheme ? Colors.white : Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: isDarkTheme ? Colors.white70 : Colors.grey[600],
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: isDarkTheme ? Colors.white70 : Colors.grey[600],
      ),
      onTap: () => _showOptionSelector(
        title: title,
        options: options,
        currentValue: currentValue,
        onChanged: onChanged,
        color: color,
        isDarkTheme: isDarkTheme,
      ),
    );
  }

  Widget _buildNavigationTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isDarkTheme,
    required Color color,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isDarkTheme ? Colors.white : Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: isDarkTheme ? Colors.white70 : Colors.grey[600],
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: isDarkTheme ? Colors.white70 : Colors.grey[600],
      ),
      onTap: onTap,
    );
  }

  void _showOptionSelector({
    required String title,
    required Map<String, String> options,
    required String currentValue,
    required Function(String) onChanged,
    required Color color,
    required bool isDarkTheme,
  }) {
    // This would show a modal bottom sheet with options
    // Implementation similar to the one in surah_reader.dart
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Quran App'),
        content: const Text(
          'A comprehensive digital companion for reading the Holy Quran.\n\n'
          'Features:\n'
          '• Complete Quran with audio\n'
          '• Multiple translations\n'
          '• Prayer times\n'
          '• Offline reading\n'
          '• Bookmarks and progress tracking\n\n'
          'Version 1.0.0',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
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
        content: const Text(
          'How to use the app:\n\n'
          '• Tap on any Surah to start reading\n'
          '• Use the audio button to listen to recitations\n'
          '• Long-press verses to bookmark them\n'
          '• Access settings from the main menu\n'
          '• Download content for offline reading\n\n'
          'For support, please contact us through the app store.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
