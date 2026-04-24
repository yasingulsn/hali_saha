import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/theme.dart';
import '../login_screen.dart';

class ProfilTab extends StatelessWidget {
  const ProfilTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final user = auth.currentUser;
        final isIsletme = auth.kullaniciTipi == 'ISLETME';

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
                child: _buildProfileHeader(user, isIsletme)),
            SliverToBoxAdapter(child: _buildStatsRow(isIsletme)),
            SliverToBoxAdapter(child: _buildMenuSection(context, auth)),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        );
      },
    );
  }

  Widget _buildProfileHeader(dynamic user, bool isIsletme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppTheme.primaryGreen.withOpacity(0.15),
                  AppTheme.primaryGreen.withOpacity(0.04),
                ],
              ),
            ),
            child: Center(
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppTheme.primaryGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryGreen.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(
                  isIsletme ? Icons.store_rounded : Icons.person_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user?.adSoyad ?? 'Kullanıcı',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user?.email ?? '',
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: isIsletme
                  ? AppTheme.accentPurple.withOpacity(0.12)
                  : AppTheme.primaryGreen.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isIsletme
                    ? AppTheme.accentPurple.withOpacity(0.2)
                    : AppTheme.primaryGreen.withOpacity(0.2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isIsletme ? Icons.verified_rounded : Icons.shield_rounded,
                  size: 14,
                  color: isIsletme
                      ? AppTheme.accentPurple
                      : AppTheme.primaryGreen,
                ),
                const SizedBox(width: 6),
                Text(
                  isIsletme ? 'İşletme Hesabı' : 'Oyuncu Hesabı',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isIsletme
                        ? AppTheme.accentPurple
                        : AppTheme.primaryGreen,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(bool isIsletme) {
    final stats = isIsletme
        ? [
            ('Sahalar', '0'),
            ('Rezervasyon', '0'),
            ('Puan', '0.0'),
          ]
        : [
            ('Maçlar', '0'),
            ('Takımlar', '0'),
            ('Puan', '0.0'),
          ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: AppTheme.cardDark,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppTheme.primaryGreen.withOpacity(0.06),
          ),
        ),
        child: Row(
          children: stats.map((s) {
            return Expanded(
              child: Column(
                children: [
                  Text(
                    s.$2,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    s.$1,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textSecondary.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context, AuthProvider auth) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.edit_rounded,
            label: 'Profili Düzenle',
            color: AppTheme.primaryGreen,
            onTap: () {},
          ),
          _buildMenuItem(
            icon: Icons.notifications_none_rounded,
            label: 'Bildirimler',
            color: AppTheme.lightOrange,
            onTap: () {},
          ),
          _buildMenuItem(
            icon: Icons.security_rounded,
            label: 'Güvenlik',
            color: AppTheme.lightGreen,
            onTap: () {},
          ),
          _buildMenuItem(
            icon: Icons.help_outline_rounded,
            label: 'Yardım & Destek',
            color: AppTheme.textSecondary,
            onTap: () {},
          ),
          _buildMenuItem(
            icon: Icons.info_outline_rounded,
            label: 'Hakkında',
            color: AppTheme.textSecondary,
            onTap: () {},
          ),
          const SizedBox(height: 8),
          _buildMenuItem(
            icon: Icons.devices_rounded,
            label: 'Tüm Cihazlardan Çıkış',
            color: AppTheme.accentCoral,
            onTap: () {},
          ),
          _buildMenuItem(
            icon: Icons.logout_rounded,
            label: 'Çıkış Yap',
            color: AppTheme.errorRed,
            onTap: () => _cikisYap(context, auth),
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: color.withOpacity(isDestructive ? 0.08 : 0.1),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDestructive
                          ? AppTheme.errorRed
                          : AppTheme.textPrimary,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppTheme.textSecondary.withOpacity(0.3),
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _cikisYap(BuildContext context, AuthProvider auth) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Çıkış Yap',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        content: const Text(
          'Hesabınızdan çıkış yapmak istediğinize emin misiniz?',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'İptal',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.errorRed.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text(
                'Çıkış Yap',
                style: TextStyle(
                  color: AppTheme.errorRed,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await auth.cikis();
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }
}
