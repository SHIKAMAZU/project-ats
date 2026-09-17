import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'api.dart';
import 'artikel_baru.dart';
import 'edit_artikel.dart';
import 'jelajah.dart';
import 'profile.dart';
import 'shared.dart';

enum PostStatus { published, draft }

class MyPost {
  final int id;
  final String title;
  final String category;
  final String imageAsset;
  final PostStatus status;
  final String date;
  final String views;
  final String readTime;
  final double draftProgress;
  final String lastUpdated;

  const MyPost({
    required this.id,
    required this.title,
    required this.category,
    required this.imageAsset,
    required this.status,
    this.date = '',
    this.views = '',
    this.readTime = '',
    this.draftProgress = 0,
    this.lastUpdated = '',
  });
}

class ArtikelSayaPage extends StatefulWidget {
  const ArtikelSayaPage({super.key});

  @override
  State<ArtikelSayaPage> createState() => _ArtikelSayaPageState();
}

class _ArtikelSayaPageState extends State<ArtikelSayaPage> {
  List<MyPost> _posts = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final posts = await getPosts();
      if (!mounted) return;
      setState(() {
        _posts = posts
            .where((p) => p.author.toLowerCase() == 'setya')
            .map((p) => MyPost(
                  id: p.id,
                  title: p.title,
                  category: p.category.isEmpty ? 'Umum' : p.category,
                  imageAsset: p.image.isEmpty ? 'assets/image/prog1.jpg' : p.image,
                  status: p.status == 'draft' ? PostStatus.draft : PostStatus.published,
                  date: _formatDate(p.createdAt),
                  views: '${_formatViews(p.id)} tayangan',
                  readTime: _formatReadTime(p.content),
                ))
            .toList();
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  String _formatDate(String createdAt) {
    final dt = DateTime.tryParse(createdAt);
    if (dt == null) return '';
    const bulan = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${dt.day} ${bulan[dt.month - 1]}';
  }

  String _formatReadTime(String content) {
    var minutes = (content.runes.length / 300).ceil();
    if (minutes < 1) minutes = 1;
    return '$minutes mnt baca';
  }

  String _formatViews(int id) {
    return ((id * 317) % 9000 + 500).toString();
  }

  List<MyPost> get _filteredPosts => List.from(_posts);

  void _showToast(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: manrope(size: 13, weight: FontWeight.w600),
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: const Color(0xFF213145),
      ),
    );
  }

  Future<void> _confirmDelete(MyPost post) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Hapus artikel?',
          style: newsreader(size: 20, weight: FontWeight.w600, color: AppColors.onSurface),
        ),
        content: Text(
          post.status == PostStatus.draft
              ? 'Apakah Anda yakin ingin menghapus draf artikel ini?'
              : 'Apakah Anda yakin ingin menghapus artikel ini?',
          style: manrope(size: 14, color: AppColors.onSurfaceVariant, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Batal',
              style: manrope(size: 13, weight: FontWeight.w700, color: AppColors.onSurfaceVariant),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'Hapus',
              style: manrope(size: 13, weight: FontWeight.w700, color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await deletePost(post.id);
        setState(() {
          _posts.remove(post);
        });
        _showToast('Artikel berhasil dihapus');
      } catch (e) {
        _showToast('Gagal hapus: $e');
      }
    }
  }

  void _openEditor(MyPost post) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditArtikelPage(
          id: post.id,
          title: post.title,
          category: post.category,
          isDraft: post.status == PostStatus.draft,
          imageAsset: post.imageAsset,
        ),
      ),
    );
    if (mounted) _loadPosts();
  }

  Future<void> _openCreate() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ArtikelBaruPage()),
    );
    if (mounted) _loadPosts();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredPosts;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _loadPosts,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 64,
                bottom: 16,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildWelcomeHeader(),
                    const SizedBox(height: 12),
                    _buildAddButton(),
                    const SizedBox(height: 16),
                    if (_loading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (_error != null)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            children: [
                              const Icon(Icons.cloud_off, size: 40, color: AppColors.outline),
                              const SizedBox(height: 8),
                              Text('Gagal memuat artikel', style: manrope(size: 15, weight: FontWeight.w600, color: AppColors.onSurface)),
                              const SizedBox(height: 4),
                              Text(_error!, style: manrope(size: 12, color: AppColors.outline), textAlign: TextAlign.center),
                              const SizedBox(height: 12),
                              FilledButton(onPressed: _loadPosts, child: const Text('Coba lagi')),
                            ],
                          ),
                        ),
                      )
                    else if (filtered.isEmpty)
                      _buildEmptyState()
                    else
                      ...filtered.map(
                        (p) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _PostCard(
                            post: p,
                            onDelete: () => _confirmDelete(p),
                            onEdit: () => _openEditor(p),
                            onAction: (label) => _showToast(label),
                          ),
                        ),
                      ),
                  ],
                ),
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
                    child: SizedBox(height: 64, child: _buildHeader()),
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
              IconButton(
                icon: const Icon(
                  Icons.notifications_outlined,
                  size: 24,
                  color: AppColors.onSurfaceVariant,
                ),
                onPressed: () => _showToast('Tidak ada notifikasi baru'),
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
                    errorBuilder: (ctx, err, stack) => const Icon(
                      Icons.person,
                      size: 18,
                      color: AppColors.outline,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
              Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'MEJA PENULIS',
                  style: manrope(
                    size: 11,
                    weight: FontWeight.w700,
                    color: AppColors.secondary,
                    letterSpacing: 0.04,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Artikel Saya',
              style: newsreader(
                size: 26,
                weight: FontWeight.w600,
                color: AppColors.onSurface,
                letterSpacing: -0.015,
                height: 1.0,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Kelola, edit, dan publikasikan artikel pribadi Anda',
              style: manrope(
                size: 14,
                weight: FontWeight.w400,
                color: AppColors.onSurfaceVariant,
                height: 1.5,
              ),
            ),
      ],
    );
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: _openCreate,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add, size: 18, color: AppColors.onPrimary),
            const SizedBox(width: 6),
            Text(
              'Tambah artikel baru',
              style: manrope(
                size: 13,
                weight: FontWeight.w700,
                color: AppColors.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: AppColors.surfaceContainer,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.border_color,
              size: 32,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Ingin menulis sesuatu yang baru?',
            style: newsreader(
              size: 20,
              weight: FontWeight.w500,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Anda belum membuat postingan di kategori ini. Wujudkan ide dan perspektif terbaik Anda.',
            textAlign: TextAlign.center,
            style: manrope(
              size: 14,
              weight: FontWeight.w400,
              color: AppColors.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _openCreate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.edit_note,
                    size: 18,
                    color: AppColors.onPrimary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Tambah artikel baru',
                    style: manrope(
                      size: 13,
                      weight: FontWeight.w600,
                      color: AppColors.onPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
          BoxShadow(
            color: Color(0x0A0F172A),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
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
              final isActive = i == 2;
              return GestureDetector(
                onTap: () {
                  if (i == 0) {
                    Navigator.of(context)
                        .popUntil((route) => route.isFirst);
                  } else if (i == 1) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ExplorePage(),
                      ),
                    );
                  } else if (i == 3) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfilePage(),
                      ),
                    );
                  }
                },
                behavior: HitTestBehavior.opaque,
                child: SizedBox(
                  width: 64,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Transform.translate(
                            offset: Offset(i == 2 ? 2 : 0, 0),
                            child: Icon(
                              isActive ? activeIcon : icon,
                              size: 22,
                              color: isActive
                                  ? AppColors.primary
                                  : AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          label,
                          maxLines: 1,
                          style: manrope(
                            size: 11,
                            weight: isActive
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isActive
                                ? AppColors.primary
                                : AppColors.secondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.primary
                              : Colors.transparent,
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

class _PostCard extends StatelessWidget {
  final MyPost post;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final ValueChanged<String> onAction;

  const _PostCard({
    required this.post,
    required this.onDelete,
    required this.onEdit,
    required this.onAction,
  });

  bool get _isDraft => post.status == PostStatus.draft;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: post.imageAsset.startsWith('http')
                    ? Image.network(
                        post.imageAsset,
                        width: 96,
                        height: 96,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, stack) => Container(
                          width: 96,
                          height: 96,
                          color: AppColors.surfaceContainer,
                          child: const Icon(Icons.broken_image, size: 28, color: AppColors.outline),
                        ),
                      )
                    : Image.asset(
                        post.imageAsset,
                  width: 96,
                  height: 96,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, stack) => Container(
                    width: 96,
                    height: 96,
                    color: AppColors.surfaceContainer,
                    child: const Icon(
                      Icons.image,
                      size: 28,
                      color: AppColors.outline,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            post.category.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: manrope(
                              size: 11,
                              weight: FontWeight.w600,
                              color: AppColors.primary,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 3,
                          height: 3,
                          decoration: const BoxDecoration(
                            color: AppColors.outlineVariant,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            _isDraft ? 'Draf' : 'Diterbitkan',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: manrope(
                              size: 11,
                              weight: FontWeight.w600,
                              color: _isDraft
                                  ? AppColors.secondary
                                  : AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      post.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: manrope(
                        size: 14,
                        weight: FontWeight.w500,
                        color: AppColors.onSurface,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_isDraft) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Progres draf',
                            style: manrope(
                              size: 11,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            '${(post.draftProgress * 100).round()}% tertulis',
                            style: manrope(
                              size: 11,
                              weight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: post.draftProgress,
                          minHeight: 4,
                          backgroundColor: AppColors.surfaceContainer,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.primary,
                          ),
                        ),
                      ),
                    ] else
                      Text(
                        '${post.date} • ${post.views} • ${post.readTime}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: manrope(
                          size: 11,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.only(top: 8),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0x0A0F172A))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => onAction(
                    _isDraft
                        ? 'Membuka revisi draf'
                        : 'Membuka wawasan artikel',
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                        Icon(
                          _isDraft ? Icons.history : Icons.bar_chart,
                          size: 15,
                          color: AppColors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _isDraft ? 'Revisi' : 'Wawasan',
                          style: manrope(
                            size: 12,
                            weight: FontWeight.w600,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: onEdit,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: _isDraft
                              ? AppColors.primary
                              : AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: _isDraft
                              ? const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 4,
                                    offset: Offset(0, 1),
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _isDraft ? Icons.create : Icons.edit,
                              size: 15,
                              color: _isDraft
                                  ? AppColors.onPrimary
                                  : AppColors.onSurface,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _isDraft ? 'Lanjutkan Menulis' : 'Edit',
                              style: manrope(
                                size: 12,
                                weight: FontWeight.w600,
                                color: _isDraft
                                    ? AppColors.onPrimary
                                    : AppColors.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: onDelete,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: AppColors.errorContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.delete,
                          size: 17,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}