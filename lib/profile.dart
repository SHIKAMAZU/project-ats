import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'artikel_saya.dart';
import 'jelajah.dart';
import 'shared.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static const String _name = 'Setya';
  static const String _username = '@setya';
  static const String _location = 'Indonesia';
  static const String _bio =
      'Menulis seputar teknologi, coding, dan keseharian kerja. '
      'Di waktu luang, biasanya membaca buku atau mampir ke kafe favorit.';
  static const int _totalArtikel = 6;
  static const int _diterbitkan = 4;
  static const int _draf = 2;
  static const String _dibaca = '14.2k';

  void _showToast(String message, {IconData icon = Icons.check_circle}) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, size: 16, color: AppColors.inversePrimary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: manrope(
                  size: 13,
                  weight: FontWeight.w600,
                  color: AppColors.inverseOnSurface,
                ),
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: AppColors.inverseSurface,
      ),
    );
  }

  Future<void> _confirmSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.inverseSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.fromLTRB(20, 16, 8, 16),
        content: Row(
          children: [
            const Icon(Icons.help_outline, size: 18, color: AppColors.inversePrimary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Yakin ingin keluar dari InkBlog?',
                style: manrope(
                  size: 13,
                  weight: FontWeight.w600,
                  color: AppColors.inverseOnSurface,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'YA, KELUAR',
              style: manrope(size: 11, weight: FontWeight.w700, color: AppColors.error),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 16, color: AppColors.outlineVariant),
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _showToast('Berhasil keluar dengan aman. Sampai jumpa!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 64,
              bottom: 24,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _buildTopUtilityBar(),
                  const SizedBox(height: 24),
                  _buildProfileHero(),
                  const SizedBox(height: 24),
                  _buildMetricsGrid(),
                  const SizedBox(height: 24),
                  _buildSectionLabel('Menulis & Membaca'),
                  const SizedBox(height: 8),
                  _buildMejaRedaksi(),
                  const SizedBox(height: 24),
                  _buildSectionLabel('Pengaturan'),
                  const SizedBox(height: 8),
                  _buildPengaturan(),
                  const SizedBox(height: 24),
                  _buildSignOutButton(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  color: AppColors.surface.withValues(alpha: 0.85),
                  child: SafeArea(
                    bottom: false,
                    child: SizedBox(
                      height: 64,
                      child: _buildHeader(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'InkBlog',
            style: newsreader(size: 24, weight: FontWeight.w500, color: AppColors.onSurface),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () => _showToast('Tidak ada notifikasi baru'),
                child: Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.notifications_outlined,
                    size: 22,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.surfaceContainerHigh,
                child: ClipOval(
                  child: Image.asset(
                    'assets/image/profile.jpg',
                    width: 32,
                    height: 32,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) =>
                        const Icon(Icons.person, size: 18, color: AppColors.outline),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopUtilityBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'PROFIL EDITOR',
                style: manrope(
                  size: 11,
                  weight: FontWeight.w700,
                  color: AppColors.onSurfaceVariant,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => _showToast('Pengaturan segera hadir'),
          child: Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.surfaceContainer,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.tune, size: 20, color: AppColors.onSurface),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileHero() {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 112,
              height: 112,
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: AppColors.surfaceContainerLow,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/image/profile.jpg',
                  width: 104,
                  height: 104,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, stack) => Container(
                    color: AppColors.surfaceContainerHigh,
                    alignment: Alignment.center,
                    child: const Icon(Icons.person, size: 48, color: AppColors.outline),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 4,
              right: 4,
              child: GestureDetector(
                onTap: () => _showToast('Ubah foto profil'),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1)),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.photo_camera, size: 16, color: AppColors.onPrimary),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _name,
              style: newsreader(size: 26, weight: FontWeight.w600, color: AppColors.onSurface),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.verified, size: 18, color: AppColors.primary),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _username,
              style: manrope(size: 13, weight: FontWeight.w600, color: AppColors.secondary),
            ),
            Text(
              '  •  ',
              style: manrope(size: 13, color: AppColors.secondary),
            ),
            Text(
              _location,
              style: manrope(size: 13, weight: FontWeight.w600, color: AppColors.secondary),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            _bio,
            textAlign: TextAlign.center,
            style: manrope(size: 14, color: AppColors.onSurfaceVariant, height: 1.5),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _showToast('Edit Bio segera hadir'),
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1)),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.edit, size: 18, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text(
                        'Edit Bio',
                        style: manrope(size: 13, weight: FontWeight.w600, color: AppColors.onSurface),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _showToast('Bagikan profil'),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1)),
                  ],
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.share, size: 18, color: AppColors.onSurface),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricsGrid() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1)),
        ],
      ),
      child: Row(
        children: [
          _buildMetricCell(_totalArtikel.toString(), 'Total Artikel', AppColors.onSurface),
          const SizedBox(width: 8),
          _buildMetricCell(_diterbitkan.toString(), 'Diterbitkan', AppColors.primary),
          const SizedBox(width: 8),
          _buildMetricCell(_draf.toString(), 'Draf', AppColors.tertiary),
          const SizedBox(width: 8),
          _buildMetricCell(_dibaca, 'Dibaca', AppColors.onSurface),
        ],
      ),
    );
  }

  Widget _buildMetricCell(String value, String label, Color valueColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: newsreader(size: 24, weight: FontWeight.w600, color: valueColor),
            ),
            const SizedBox(height: 2),
            Text(
              label.toUpperCase(),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: manrope(
                size: 11,
                weight: FontWeight.w700,
                color: AppColors.secondary,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text.toUpperCase(),
        style: manrope(
          size: 11,
          weight: FontWeight.w700,
          color: AppColors.secondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildMejaRedaksi() {
    return Column(
      children: [
        _buildMenuItem(
          icon: Icons.article,
          iconBg: AppColors.surfaceContainerHigh,
          iconColor: AppColors.primary,
          title: 'Artikel Saya',
          subtitle: 'Kelola semua artikel tertulis & draf...',
          trailing: _buildTrailingWithBadge(
            '6',
            AppColors.secondaryContainer,
            AppColors.onSecondaryFixed,
          ),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ArtikelSayaPage()),
          ),
        ),
        const SizedBox(height: 8),
        _buildMenuItem(
          icon: Icons.bookmark,
          iconBg: AppColors.surfaceContainerHigh,
          iconColor: AppColors.primary,
          title: 'Artikel Tersimpan / Markah',
          subtitle: 'Daftar bacaan terkurasi',
          trailing: _buildTrailingWithBadge(
            '12',
            AppColors.surfaceContainer,
            AppColors.onSurfaceVariant,
          ),
          onTap: () => _showToast('Artikel tersimpan segera hadir'),
        ),
        const SizedBox(height: 8),
        _buildMenuItem(
          icon: Icons.auto_graph,
          iconBg: AppColors.surfaceContainerHigh,
          iconColor: AppColors.tertiary,
          title: 'Riwayat & Statistik Baca',
          subtitle: 'Streak membaca mingguan: 4 hari',
          trailing: const Icon(Icons.chevron_right, size: 20, color: AppColors.outline),
          onTap: () => _showToast('Riwayat & Statistik segera hadir'),
        ),
      ],
    );
  }

  Widget _buildPengaturan() {
    return Column(
      children: [
        _buildMenuItem(
          icon: Icons.notifications_active,
          iconBg: AppColors.surfaceContainer,
          iconColor: AppColors.onSurfaceVariant,
          title: 'Preferensi Notifikasi',
          subtitle: 'Frekuensi ringkasan & sebutan',
          trailing: const Icon(Icons.chevron_right, size: 20, color: AppColors.outline),
          onTap: () => _showToast('Preferensi notifikasi segera hadir'),
        ),
        const SizedBox(height: 8),
        _buildMenuItem(
          icon: Icons.security,
          iconBg: AppColors.surfaceContainer,
          iconColor: AppColors.onSurfaceVariant,
          title: 'Pengaturan & Keamanan Akun',
          subtitle: 'Kunci sandi, 2FA, perangkat aktif',
          trailing: const Icon(Icons.chevron_right, size: 20, color: AppColors.outline),
          onTap: () => _showToast('Pengaturan & Keamanan segera hadir'),
        ),
        const SizedBox(height: 8),
        _buildMenuItem(
          icon: Icons.info_outline,
          iconBg: AppColors.surfaceContainer,
          iconColor: AppColors.onSurfaceVariant,
          title: 'Tentang InkBlog',
          subtitle: 'Versi 2.4.0 • Ketentuan & Privasi',
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'v2.4.0',
                  style: manrope(size: 10, weight: FontWeight.w700, color: AppColors.onSurfaceVariant),
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right, size: 20, color: AppColors.outline),
            ],
          ),
          onTap: () => _showToast('Tentang InkBlog'),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Widget trailing,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 22, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: manrope(size: 13, weight: FontWeight.w600, color: AppColors.onSurface),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: manrope(size: 13, color: AppColors.secondary),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildTrailingWithBadge(String text, Color bgColor, Color textColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            text,
            style: manrope(size: 11, weight: FontWeight.w700, color: textColor),
          ),
        ),
        const SizedBox(width: 4),
        const Icon(Icons.chevron_right, size: 20, color: AppColors.outline),
      ],
    );
  }

  Widget _buildSignOutButton() {
    return GestureDetector(
      onTap: _confirmSignOut,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.errorContainer.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.logout, size: 18, color: AppColors.onErrorContainer),
            SizedBox(width: 8),
            Text(
              'Keluar',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.onErrorContainer),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    final items = [
      (Icons.home_outlined, Icons.home, 'Beranda'),
      (Icons.explore_outlined, Icons.explore, 'Jelajah'),
      (Icons.edit_note, Icons.edit_note, 'Artikel Saya'),
      (Icons.person_outlined, Icons.person, 'Profil'),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(color: Color(0x0A0F172A), blurRadius: 16, offset: Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final icon = items[i].$1;
              final activeIcon = items[i].$2;
              final label = items[i].$3;
              final isActive = i == 3;
              return GestureDetector(
                onTap: () {
                  if (i == 0) {
                    Navigator.of(context)
                        .popUntil((route) => route.isFirst);
                  } else if (i == 1) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ExplorePage()),
                    );
                  } else if (i == 2) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ArtikelSayaPage()),
                    );
                  }
                },
                behavior: HitTestBehavior.opaque,
                child: SizedBox(
                  width: 64,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isActive ? activeIcon : icon,
                        size: 22,
                        color: isActive ? AppColors.primary : AppColors.secondary,
                      ),
                      const SizedBox(height: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          label,
                          maxLines: 1,
                          style: manrope(
                            size: 11,
                            weight: isActive ? FontWeight.w700 : FontWeight.w500,
                            color: isActive ? AppColors.primary : AppColors.secondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isActive ? AppColors.primary : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
