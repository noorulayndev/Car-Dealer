import 'package:car_dealer_portfolio/screens/auth_screen.dart';
import 'package:car_dealer_portfolio/screens/my_enquiries_screen.dart';
import 'package:car_dealer_portfolio/screens/test_drive_bookings_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../screens/favorites_screen.dart';
import '../services/favorite_service.dart';
import '../services/firebase_service.dart';
import '../theme/app_theme.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  Stream<int> _collectionCountStream({
    required String collectionName,
    required String userId,
  }) {
    return FirebaseFirestore.instance
        .collection(collectionName)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: AppTheme.cream,
      appBar: AppBar(
        backgroundColor: AppTheme.royalNavy,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: const Text(
          'My Account',
          style: AppTheme.titleTextStyle,
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                _ProfileCard(),
                const SizedBox(height: 16),
                _StatsRow(userId: userId),
                const SizedBox(height: 16),
                _SectionHeader('My Activity'),
                _ActivitySection(userId: userId),
                const SizedBox(height: 16),
                _LogoutButton(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    final name = user?.displayName ?? 'User';
    final email = user?.email ?? 'No Email';
    final photoUrl = user?.photoURL;

    final initials = name.isNotEmpty
        ? name.trim().split(' ').map((e) => e[0]).take(2).join().toUpperCase()
        : 'U';

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: const Color(0xFF1A73E8).withOpacity(0.1),
            backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
            child: photoUrl == null
                ? Text(
              initials,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A73E8),
              ),
            )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  email,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF43A047).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Verified Member',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF43A047),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final String? userId;

  const _StatsRow({
    required this.userId,
  });

  Stream<int> _countStream(String collectionName) {
    if (userId == null) {
      return Stream<int>.value(0);
    }

    return FirebaseFirestore.instance
        .collection(collectionName)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Set<String>>(
      valueListenable: FavoriteService.favoriteIds,
      builder: (context, favoriteIds, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'Saved Cars',
                  value: favoriteIds.length.toString(),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: StreamBuilder<int>(
                  stream: _countStream('test_drive_bookings'),
                  builder: (context, snapshot) {
                    return _StatCard(
                      label: 'Test Drives',
                      value: '${snapshot.data ?? 0}',
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: StreamBuilder<int>(
                  stream: _countStream('leads'),
                  builder: (context, snapshot) {
                    return _StatCard(
                      label: 'Enquiries',
                      value: '${snapshot.data ?? 0}',
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A73E8),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade500,
          ),
        ),
      ),
    );
  }
}

class _ActivitySection extends StatelessWidget {
  final String? userId;

  const _ActivitySection({
    required this.userId,
  });

  Stream<int> _countStream(String collectionName) {
    if (userId == null) {
      return Stream<int>.value(0);
    }

    return FirebaseFirestore.instance
        .collection(collectionName)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Set<String>>(
      valueListenable: FavoriteService.favoriteIds,
      builder: (context, favoriteIds, _) {
        return StreamBuilder<int>(
          stream: _countStream('test_drive_bookings'),
          builder: (context, testDriveSnapshot) {
            return StreamBuilder<int>(
              stream: _countStream('leads'),
              builder: (context, enquirySnapshot) {
                final testDriveCount = testDriveSnapshot.data ?? 0;
                final enquiryCount = enquirySnapshot.data ?? 0;

                return _MenuSection(
                  items: [

                    _MenuItem(
                      icon: Icons.directions_car_outlined,
                      iconColor: const Color(0xFF1A73E8),
                      label: 'Test Drive Appointments',
                      badge: testDriveCount.toString(),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const TestDriveBookingsScreen(),
                          ),
                        );
                      },
                    ),
                    _MenuItem(
                      icon: Icons.chat_bubble_outline,
                      iconColor: const Color(0xFF7B1FA2),
                      label: 'My Enquiries',
                      badge: enquiryCount.toString(),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MyEnquiriesScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}

class _MenuItem {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String? badge;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.iconColor,
    required this.label,
    this.badge,
    required this.onTap,
  });
}

class _MenuSection extends StatelessWidget {
  final List<_MenuItem> items;

  const _MenuSection({
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: items.map((item) {
          return ListTile(
            leading: Icon(
              item.icon,
              color: item.iconColor,
            ),
            title: Text(item.label),
            trailing: item.badge != null
                ? CircleAvatar(
              radius: 12,
              backgroundColor: const Color(0xFF1A73E8),
              child: Text(
                item.badge!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                ),
              ),
            )
                : const Icon(Icons.chevron_right),
            onTap: item.onTap,
          );
        }).toList(),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: OutlinedButton.icon(
        onPressed: () => _showLogoutDialog(context),
        icon: const Icon(
          Icons.logout,
          color: Color(0xFFE53935),
        ),
        label: const Text(
          'Log Out',
          style: TextStyle(
            color: Color(0xFFE53935),
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
          side: const BorderSide(
            color: Color(0xFFE53935),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await GoogleSignIn().signOut();
                await FirebaseAuth.instance.signOut();

                if (context.mounted) {
                  Navigator.of(context).pop(); // close dialog
                  Navigator.of(context).pop();

                  /*
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const AuthScreen()),
                    (route) => false,
                  );
                  */
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.of(context).pop();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Logout failed: $e')),
                  );
                }
              }
            },
            child: const Text(
              'Log Out',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
