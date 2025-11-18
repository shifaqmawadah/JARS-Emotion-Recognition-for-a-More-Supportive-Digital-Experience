import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../login_page.dart'; // adjust the path if needed

class OthersPage extends StatefulWidget {
  const OthersPage({super.key});

  @override
  State<OthersPage> createState() => _OthersPageState();
}

class _OthersPageState extends State<OthersPage> {
  String? avatarUrl;
  String userName = "Anonymous";
  bool isDarkTheme = false;
  Color primaryColor = Colors.purple.shade400;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              Text(
                "Profile & Settings",
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 24),

              // Avatar + Name
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey.shade300,
                backgroundImage:
                    avatarUrl != null ? NetworkImage(avatarUrl!) : null,
                child: avatarUrl == null
                    ? const Icon(Icons.person, size: 50)
                    : null,
              ),
              const SizedBox(height: 12),
              Text(
                userName,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 24),

              Expanded(
                child: ListView(
                  children: [
                    _buildListTile(
                      icon: Icons.edit,
                      title: "Edit Profile",
                      onTap: _editProfileDialog,
                    ),
                    _buildListTile(
                      icon: Icons.color_lens,
                      title: "Theme",
                      subtitle: "Toggle dark/light mode & primary color",
                      onTap: _themeDialog,
                    ),
                    _buildListTile(
                      icon: Icons.photo,
                      title: "Gallery",
                      subtitle: "View your saved images",
                      onTap: () {},
                    ),
                    _buildListTile(
                      icon: Icons.info,
                      title: "About JARS",
                      subtitle: "Learn more about this app",
                      onTap: _showAboutDialog,
                    ),
                    _buildListTile(
                      icon: Icons.policy,
                      title: "Privacy Policy",
                      subtitle: "Read how we protect your data",
                      onTap: () {},
                    ),
                    _buildListTile(
                      icon: Icons.feedback,
                      title: "Send Feedback",
                      subtitle: "Tell us how we can improve",
                      onTap: () {},
                    ),
                    _buildListTile(
                      icon: Icons.logout,
                      title: "Logout",
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const LoginPage()),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Text(
                "v1.0.0",
                style: GoogleFonts.poppins(color: Colors.black38, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, color: primaryColor),
        title: Text(title, style: GoogleFonts.poppins(color: Colors.black)),
        subtitle: subtitle != null
            ? Text(subtitle,
                style: GoogleFonts.poppins(color: Colors.black54, fontSize: 12))
            : null,
        onTap: onTap,
      ),
    );
  }

  // ===== Edit Profile Dialog =====
  void _editProfileDialog() async {
    String tempName = userName;
    String? tempAvatar = avatarUrl;

    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Edit Profile"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () {
                  setDialogState(() {
                    tempAvatar =
                        "https://i.pravatar.cc/150?img=${DateTime.now().millisecondsSinceEpoch % 70}";
                  });
                },
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey.shade300,
                  backgroundImage:
                      tempAvatar != null ? NetworkImage(tempAvatar!) : null,
                  child: tempAvatar == null ? const Icon(Icons.person) : null,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(labelText: "Display Name"),
                controller: TextEditingController(text: tempName),
                onChanged: (val) => tempName = val,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  userName = tempName;
                  avatarUrl = tempAvatar;
                });
                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }

  // ===== Theme Dialog =====
  void _themeDialog() async {
    bool tempDark = isDarkTheme;
    Color tempColor = primaryColor;

    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Theme Settings"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                title: const Text("Dark Mode"),
                value: tempDark,
                onChanged: (val) => setDialogState(() => tempDark = val),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text("Primary Color: "),
                  ...[
                    Colors.purple.shade400,
                    Colors.orange.shade400,
                    Colors.green.shade400
                  ].map((c) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => setDialogState(() => tempColor = c),
                          child: CircleAvatar(backgroundColor: c, radius: 14),
                        ),
                      ))
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  isDarkTheme = tempDark;
                  primaryColor = tempColor;
                });
                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("About JARS"),
        content: const Text(
            "JARS is your personal mood diary that helps track emotions, "
            "reflect through writing, and discover content that matches your mood."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          )
        ],
      ),
    );
  }
}
