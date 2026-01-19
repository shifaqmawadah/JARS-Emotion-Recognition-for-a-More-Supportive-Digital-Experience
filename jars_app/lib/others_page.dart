import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../login_page.dart';
import '../new_entry_page.dart'; 
import '../all_entries.dart'; 
import 'theme_page.dart';
import '../theme_manager.dart';

class OthersPage extends StatefulWidget {
  final String currentMood;
  final Color baseMoodColor;
  final String userEmail;
  final List<Map<String, String>> diaryEntries; 

  const OthersPage({
    super.key,
    required this.currentMood,
    required this.baseMoodColor,
    required this.userEmail,
    required this.diaryEntries, 
  });

  @override
  State<OthersPage> createState() => _OthersPageState();
}

class _OthersPageState extends State<OthersPage> {
  String? avatarUrl;
  String userName = "Anonymous";
  final ThemeManager _themeManager = ThemeManager.instance;

  @override
  void initState() {
    super.initState();
    _extractUsernameFromEmail();
    _themeManager.addListener(_onThemeChanged);
  }

  void _extractUsernameFromEmail() {
    if (widget.userEmail.isNotEmpty) {
      final emailParts = widget.userEmail.split('@');
      if (emailParts.isNotEmpty) {
        String extractedName = emailParts[0];
        if (extractedName.isNotEmpty) {
          extractedName = extractedName[0].toUpperCase() + 
                         extractedName.substring(1).toLowerCase();
          extractedName = extractedName.replaceAll('.', ' ');
          extractedName = extractedName.replaceAll('_', ' ');
          
          setState(() {
            userName = extractedName;
          });
        }
      }
    }
  }

  void _onThemeChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _themeManager.removeListener(_onThemeChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = _themeManager.getThemeColor(widget.baseMoodColor);
    
    final textColor = _themeManager.getContrastingTextColor(themeColor);

    final isGradientMagic = _themeManager.selectedPaletteIndex == 7;
    final Gradient? themeGradient = isGradientMagic 
        ? _themeManager.getThemeGradient(widget.baseMoodColor)
        : null;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: themeColor,
        elevation: 0,
        title: Text("Others", style: GoogleFonts.poppins(color: textColor)),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
        iconTheme: IconThemeData(color: textColor),
      ),
      body: SafeArea(
        child: Container(
          decoration: isGradientMagic
              ? BoxDecoration(
                  gradient: themeGradient,
                )
              : null,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                
                // Mood indicator with theme color
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: themeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: themeColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: themeColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          "Current Mood: ${widget.currentMood}",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: themeColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // User email display
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: isGradientMagic 
                        ? Colors.white.withOpacity(0.9)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: isGradientMagic 
                        ? Border.all(color: Colors.white.withOpacity(0.3))
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.email, 
                        size: 16, 
                        color: isGradientMagic 
                            ? themeColor 
                            : Colors.grey.shade600
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          widget.userEmail,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: isGradientMagic 
                                ? themeColor 
                                : Colors.grey.shade700,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Profile card
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isGradientMagic 
                        ? Colors.white.withOpacity(0.9)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isGradientMagic ? 0.03 : 0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: isGradientMagic 
                        ? Border.all(color: Colors.white.withOpacity(0.3))
                        : null,
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: isGradientMagic 
                            ? themeColor.withOpacity(0.1)
                            : Colors.grey.shade100,
                        backgroundImage:
                            avatarUrl != null ? NetworkImage(avatarUrl!) : null,
                        child: avatarUrl == null
                            ? Icon(
                                Icons.person, 
                                size: 50, 
                                color: isGradientMagic 
                                    ? themeColor 
                                    : themeColor
                              )
                            : null,
                      ),
                      const SizedBox(height: 16),

                      Container(
                        constraints: const BoxConstraints(maxHeight: 80),
                        child: SingleChildScrollView(
                          physics: const NeverScrollableScrollPhysics(),
                          child: Column(
                            children: [
                              Text(
                                userName,
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: isGradientMagic 
                                      ? Colors.grey.shade800 
                                      : Colors.grey.shade800,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: themeColor.withOpacity(isGradientMagic ? 0.15 : 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "Theme: ${_getThemeName(_themeManager.selectedPaletteIndex)}",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: themeColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        constraints: const BoxConstraints(maxHeight: 40),
                        child: SingleChildScrollView(
                          physics: const NeverScrollableScrollPhysics(),
                          child: Text(
                            _getThemeDescription(_themeManager.selectedPaletteIndex),
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: isGradientMagic 
                                  ? themeColor.withOpacity(0.8)
                                  : Colors.grey.shade600,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Menu items
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      _buildModernTile(
                        icon: Icons.edit,
                        title: "Edit Profile",
                        subtitle: "Change your name and avatar",
                        onTap: _editProfileDialog,
                        themeColor: themeColor,
                        isGradientMagic: isGradientMagic,
                      ),
                      if (widget.diaryEntries.isNotEmpty)
                        _buildModernTile(
                          icon: Icons.book,
                          title: "All Journal Entries",
                          subtitle: "View and search all your entries",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AllEntriesPage(
                                  diaryEntries: widget.diaryEntries,
                                  currentMood: widget.currentMood,
                                  baseMoodColor: widget.baseMoodColor,
                                  themeManager: _themeManager,
                                ),
                              ),
                            );
                          },
                          themeColor: themeColor,
                          isGradientMagic: isGradientMagic,
                        ),
                      _buildModernTile(
                        icon: Icons.color_lens,
                        title: "Theme Palette",
                        subtitle: "Customize your color theme",
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ThemePage(
                                selectedPalette: _themeManager.selectedPaletteIndex,
                                baseMoodColor: widget.baseMoodColor,
                                gradientColors: _themeManager.gradientColors,
                              ),
                            ),
                          );

                          if (result != null && result is Map) {
                            await _themeManager.setTheme(
                              result['paletteIndex'],
                              result['selectedColor'],
                              gradientColors: result['gradientColors'],
                            );
                          }
                        },
                        themeColor: themeColor,
                        isGradientMagic: isGradientMagic,
                      ),
                      _buildModernTile(
                        icon: Icons.notifications,
                        title: "Notifications",
                        subtitle: "Manage your notification settings",
                        onTap: () {
                          _showNotificationsDialog();
                        },
                        themeColor: themeColor,
                        isGradientMagic: isGradientMagic,
                      ),
                      _buildModernTile(
                        icon: Icons.security,
                        title: "Privacy & Security",
                        subtitle: "Control your data and privacy",
                        onTap: () {
                          _showPrivacyDialog();
                        },
                        themeColor: themeColor,
                        isGradientMagic: isGradientMagic,
                      ),
                      _buildModernTile(
                        icon: Icons.photo,
                        title: "Gallery",
                        subtitle: "View your saved images",
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Gallery feature coming soon!',
                                style: GoogleFonts.poppins(),
                              ),
                              backgroundColor: themeColor,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        themeColor: themeColor,
                        isGradientMagic: isGradientMagic,
                      ),
                      _buildModernTile(
                        icon: Icons.info,
                        title: "About JARS",
                        subtitle: "Learn more about this app",
                        onTap: _showAboutDialog,
                        themeColor: themeColor,
                        isGradientMagic: isGradientMagic,
                      ),
                      _buildModernTile(
                        icon: Icons.policy,
                        title: "Privacy Policy",
                        subtitle: "Read how we protect your data",
                        onTap: () {
                          _showPrivacyPolicy();
                        },
                        themeColor: themeColor,
                        isGradientMagic: isGradientMagic,
                      ),
                      _buildModernTile(
                        icon: Icons.feedback,
                        title: "Send Feedback",
                        subtitle: "Tell us how to improve",
                        onTap: () {
                          _showFeedbackDialog();
                        },
                        themeColor: themeColor,
                        isGradientMagic: isGradientMagic,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isGradientMagic 
                                ? Colors.white.withOpacity(0.3)
                                : Colors.grey.shade200,
                          ),
                        ),
                        child: _buildModernTile(
                          icon: Icons.logout,
                          title: "Logout",
                          onTap: () {
                            _showLogoutConfirmation();
                          },
                          themeColor: Colors.red,
                          isGradientMagic: isGradientMagic,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),

                // App version information
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  child: Column(
                    children: [
                      Text(
                        "JARS v1.0.0",
                        style: GoogleFonts.poppins(
                          color: isGradientMagic 
                              ? Colors.white.withOpacity(0.8)
                              : Colors.grey.shade400,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Emotional Wellness Companion",
                        style: GoogleFonts.poppins(
                          color: isGradientMagic 
                              ? Colors.white.withOpacity(0.7)
                              : Colors.grey.shade400,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required Color themeColor,
    required bool isGradientMagic,
    String? subtitle,
  }) {
    final backgroundColor = isGradientMagic 
        ? Colors.white.withOpacity(0.9)
        : Colors.white;
    final borderColor = isGradientMagic 
        ? Colors.white.withOpacity(0.3)
        : Colors.grey.shade100;
    final iconColor = themeColor;
    final titleColor = isGradientMagic 
        ? Colors.grey.shade800
        : Colors.grey.shade800;
    final subtitleColor = isGradientMagic 
        ? themeColor.withOpacity(0.8)
        : Colors.grey.shade500;
    final chevronColor = isGradientMagic 
        ? themeColor.withOpacity(0.7)
        : Colors.grey.shade400;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor, width: 1),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: themeColor.withOpacity(isGradientMagic ? 0.15 : 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        constraints: const BoxConstraints(maxHeight: 40),
                        child: SingleChildScrollView(
                          physics: const NeverScrollableScrollPhysics(),
                          child: Text(
                            title,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: titleColor,
                            ),
                          ),
                        ),
                      ),
                      if (subtitle != null) const SizedBox(height: 4),
                      if (subtitle != null)
                        Container(
                          constraints: const BoxConstraints(maxHeight: 30),
                          child: SingleChildScrollView(
                            physics: const NeverScrollableScrollPhysics(),
                            child: Text(
                              subtitle,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: subtitleColor,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: chevronColor,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getThemeName(int index) {
    final names = [
      "Bright & Vibrant",
      "Dark & Moody",
      "Pastel Dream",
      "Warm Sunset",
      "Cool Ocean",
      "Neon Glow",
      "Earth Tones",
      "Gradient Magic",
      "Custom Color"
    ];
    return index < names.length ? names[index] : "Default";
  }

  String _getThemeDescription(int index) {
    final descriptions = [
      "Vibrant colors for positive energy",
      "Muted tones for calm reflection",
      "Soft pastels for gentle moods",
      "Warm tones like a sunset",
      "Cool blues for tranquility",
      "Bold neon for high energy",
      "Natural earth-inspired colors",
      "Beautiful gradient effects",
      "Your personal favorite color"
    ];
    return index < descriptions.length ? descriptions[index] : "Default theme";
  }

  // Edit Profile
  void _editProfileDialog() async {
    String tempName = userName;
    String? tempAvatar = avatarUrl;

    await showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Edit Profile",
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    tempAvatar =
                        "https://i.pravatar.cc/150?img=${DateTime.now().millisecondsSinceEpoch % 70}";
                    if (mounted) {
                      setState(() {});
                    }
                  },
                  child: CircleAvatar(
                    radius: 40,
                    backgroundImage:
                        tempAvatar != null ? NetworkImage(tempAvatar!) : null,
                    child: tempAvatar == null 
                        ? Icon(Icons.person, size: 40, color: Colors.grey.shade400)
                        : null,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Tap to change avatar",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: TextEditingController(text: tempName),
                  decoration: InputDecoration(
                    labelText: "Display Name",
                    hintText: "Enter your name",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: _themeManager.getThemeColor(widget.baseMoodColor)
                      ),
                    ),
                  ),
                  onChanged: (val) => tempName = val,
                  maxLines: 3,
                  minLines: 1,
                ),
                const SizedBox(height: 8),
                Text(
                  "Email: ${widget.userEmail}",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Cancel",
                          style: GoogleFonts.poppins(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            userName = tempName;
                            avatarUrl = tempAvatar;
                          });
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _themeManager.getThemeColor(widget.baseMoodColor),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Save",
                          style: GoogleFonts.poppins(
                            color: _themeManager.getContrastingTextColor(
                              _themeManager.getThemeColor(widget.baseMoodColor)
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAboutDialog() {
    final themeColor = _themeManager.getThemeColor(widget.baseMoodColor);
    final textColor = _themeManager.getContrastingTextColor(themeColor);
    
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: themeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    Icons.psychology_alt,
                    size: 36,
                    color: themeColor,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "About JARS",
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Journaling, Awareness, Reflection & Support",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: themeColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "JARS helps you track emotions, reflect on your day, "
                  "and gain insights into your emotional patterns. "
                  "Your selected theme applies across all moods and screens.",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColor,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Got it",
                    style: GoogleFonts.poppins(
                      color: textColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showNotificationsDialog() {
    final themeColor = _themeManager.getThemeColor(widget.baseMoodColor);
    final textColor = _themeManager.getContrastingTextColor(themeColor);
    
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Notifications",
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Configure your notification preferences",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColor,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "OK",
                    style: GoogleFonts.poppins(
                      color: textColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPrivacyDialog() {
    final themeColor = _themeManager.getThemeColor(widget.baseMoodColor);
    final textColor = _themeManager.getContrastingTextColor(themeColor);
    
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Privacy & Security",
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Your data is stored locally on your device. "
                  "We don't collect personal information.",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColor,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Understood",
                    style: GoogleFonts.poppins(
                      color: textColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPrivacyPolicy() {
    final themeColor = _themeManager.getThemeColor(widget.baseMoodColor);
    final textColor = _themeManager.getContrastingTextColor(themeColor);
    
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Privacy Policy",
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "JARS values your privacy. All your diary entries "
                  "and mood data are stored locally on your device. "
                  "We don't share your data with third parties.",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColor,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "I Understand",
                    style: GoogleFonts.poppins(
                      color: textColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showFeedbackDialog() {
    final themeColor = _themeManager.getThemeColor(widget.baseMoodColor);
    final textColor = _themeManager.getContrastingTextColor(themeColor);
    
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Send Feedback",
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "We'd love to hear your thoughts and suggestions "
                  "to make JARS better for you!",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColor,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "OK",
                    style: GoogleFonts.poppins(
                      color: textColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutConfirmation() {
    final themeColor = _themeManager.getThemeColor(widget.baseMoodColor);
    final textColor = _themeManager.getContrastingTextColor(themeColor);
    
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          "Logout",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        content: Text(
          "Are you sure you want to logout?",
          style: GoogleFonts.poppins(
            color: Colors.grey.shade600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: GoogleFonts.poppins(
                color: Colors.grey.shade600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(
              "Logout",
              style: GoogleFonts.poppins(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}