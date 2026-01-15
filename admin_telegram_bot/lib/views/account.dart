import 'package:flutter/material.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          // --- Header Section (Edit, Avatar, Nama) ---
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {},
                child: const Text(
                  "Edit",
                  style: TextStyle(
                    color: Color(0xFF5E5CE6), // Warna ungu kebiruan
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Avatar Image
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF1C1C1E), width: 2),
            ),
            child: const CircleAvatar(
              radius: 50,
              backgroundColor: Color(
                0xFFFFC0CB,
              ), // Warna pink background avatar
              child: Text('AM'), // Ganti dengan foto asli
            ),
          ),
          const SizedBox(height: 15),

          // Nama User
          const Text(
            "Ethan Walker",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 5),

          // Handle / Username
          const Text(
            "@Mannxstore_bot",
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 30),

          // --- Group Menu 1 ---
          _buildMenuContainer(
            children: [
              _buildMenuItem(
                icon: Icons.person,
                title: "Personal Information",
                color: const Color(0xFF5E5CE6),
              ),
              _buildDivider(),
              _buildMenuItem(
                icon: Icons.notifications,
                title: "Notifications",
                color: const Color(0xFF5E5CE6),
              ),
              _buildDivider(),
              _buildMenuItem(
                icon: Icons.storage,
                title: "Storage",
                color: const Color(0xFF5E5CE6),
              ),
              _buildDivider(),
              _buildMenuItem(
                icon: Icons.subscriptions,
                title: "Subscriptions",
                color: const Color(0xFF5E5CE6),
              ),
              _buildDivider(),
              _buildMenuItem(
                icon: Icons.color_lens,
                title: "Appearance",
                color: const Color(0xFF5E5CE6),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // --- Group Menu 2 ---
          _buildMenuContainer(
            children: [
              _buildMenuItem(
                icon: Icons.article,
                title: "Documentation",
                color: const Color(0xFF5E5CE6),
              ),
              _buildDivider(),
              _buildMenuItem(
                icon: Icons.security,
                title: "Security",
                color: const Color(0xFF5E5CE6),
              ),
              _buildDivider(),
              _buildMenuItem(
                icon: Icons.help,
                title: "Help",
                color: const Color(0xFF5E5CE6),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // --- Log Out Button ---
          GestureDetector(
            onTap: () {
              // Aksi Log Out
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1E), // Warna kartu abu gelap
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Text(
                  "Log Out",
                  style: TextStyle(
                    color: Color(0xFFFF453A), // Warna Merah iOS
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 100), // Ruang ekstra untuk scroll
        ],
      ),
    );
  }
}

Widget _buildMenuContainer({required List<Widget> children}) {
  return Container(
    decoration: BoxDecoration(
      color: const Color(
        0xFF1C1C1E,
      ), // Warna kartu (sedikit lebih terang dari bg)
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(children: children),
  );
}

Widget _buildMenuItem({
  required IconData icon,
  required String title,
  required Color color,
}) {
  return ListTile(
    leading: Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2), // Background transparan ikon
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 20),
    ),
    title: Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
    ),
    trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
    onTap: () {},
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
  );
}

// Widget Helper: Garis Pembatas (Divider)
Widget _buildDivider() {
  return const Divider(
    color: Color(0xFF2C2C2E),
    height: 1,
    thickness: 1,
    indent: 60, // Memberi jarak dari kiri agar rapi
  );
}
