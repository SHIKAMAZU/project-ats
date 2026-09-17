import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'api.dart';
import 'artikel_saya.dart';
import 'profile.dart';
import 'shared.dart';

class ExploreArticle {
  final String title;
  final String category;
  final String author;
  final String authorInitials;
  final String readTime;
  final String views;
  final String imageAsset;

  const ExploreArticle({
    required this.title,
    required this.category,
    required this.author,
    required this.authorInitials,
    required this.readTime,
    required this.views,
    required this.imageAsset,
  });
}

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _activeCategory = 'Semua';
  String _activeSort = 'Terbaru';
  final Set<String> _bookmarks = {};
  List<ExploreArticle> _articles = [];
  bool _loading = true;
  String? _error;

  final List<String> _categories = [
    'Semua',
    'Teknologi',
    'Desain',
    'Pemrograman',
  ];

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
        _articles = posts.map((p) => ExploreArticle(
              title: p.title,
              category: p.category.isEmpty ? 'Umum' : p.category,
              author: p.author,
              authorInitials: p.author.isNotEmpty ? p.author[0].toUpperCase() : '?',
              readTime: _formatReadTime(p.content),
              views: _formatViews(p.id),
              imageAsset: p.image.isEmpty ? 'assets/image/prog1.jpg' : p.image,
            )).toList();
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

  String _formatReadTime(String content) {
    var minutes = (content.runes.length / 300).ceil();
    if (minutes < 1) minutes = 1;
    return '$minutes mnt baca';
  }

  String _formatViews(int id) {
    final views = (id * 317) % 9000 + 500;
    if (views >= 1000) {
      return '${(views / 1000).toStringAsFixed(1)}k';
    }
    return views.toString();
  }

  List<ExploreArticle> get _filteredArticles {
    var list = _articles;

    if (_activeCategory != 'Semua') {
      list = list.where((a) => a.category == _activeCategory).toList();
    }

    if (_searchQuery.isNotEmpty) {
      var q = _searchQuery.toLowerCase();
      list = list
          .where(
            (a) =>
                a.title.toLowerCase().contains(q) ||
                a.author.toLowerCase().contains(q),
          )
          .toList();
    }

    if (_activeSort == 'Populer' || _activeSort == 'Paling Banyak Dibaca') {
      list = List.from(list);
      list.sort((a, b) {
        double va = double.tryParse(a.views.replaceAll('k', '')) ?? 0;
        double vb = double.tryParse(b.views.replaceAll('k', '')) ?? 0;
        return vb.compareTo(va);
      });
    }

    return list;
  }

  void _toggleBookmark(String title) {
    setState(() {
      if (_bookmarks.contains(title)) {
        _bookmarks.remove(title);
      } else {
        _bookmarks.add(title);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayed = _filteredArticles;

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
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        _buildEditorialIntro(),
                        const SizedBox(height: 20),
                        _buildSearchBar(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                  _buildCategoryPills(),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildSortTabs(),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _loading
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : _error != null
                            ? Center(
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
                            : displayed.isEmpty
                                ? _buildEmptyState()
                                : Column(
                                    children: List.generate(displayed.length, (i) {
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 12),
                                        child: _ArticleCard(
                                          article: displayed[i],
                                          isBookmarked: _bookmarks.contains(
                                            displayed[i].title,
                                          ),
                                          onBookmarkTap: () =>
                                              _toggleBookmark(displayed[i].title),
                                        ),
                                      );
                                    }),
                                  ),
                  ),
                  const SizedBox(height: 24),
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
      bottomNavigationBar: _buildBottomNav(1),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                'InkBlog',
                style: newsreader(
                  size: 24,
                  weight: FontWeight.w500,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_outlined,
                  size: 24,
                  color: AppColors.onSurfaceVariant,
                ),
                onPressed: () {},
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

  Widget _buildEditorialIntro() {
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
            const SizedBox(width: 8),
            Text(
              'GAZET TERKURASI',
              style: manrope(
                size: 11,
                weight: FontWeight.w700,
                color: AppColors.primary,
                letterSpacing: 0.04,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Jelajah',
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
          'Temukan cerita terbaik dari berbagai bidang terkurasi',
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

  Widget _buildSearchBar() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1)),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (val) => setState(() => _searchQuery = val),
        style: manrope(size: 14, color: AppColors.onSurface),
        decoration: InputDecoration(
          hintText: 'Cari berdasarkan judul, kata kunci, atau penulis...',
          hintStyle: manrope(size: 14, color: AppColors.outline),
          prefixIcon: const Icon(
            Icons.search,
            size: 20,
            color: AppColors.outline,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Icons.close,
                    size: 18,
                    color: AppColors.outline,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildCategoryPills() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: _categories.map((cat) {
          final isSelected = cat == _activeCategory;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: GestureDetector(
                onTap: () => setState(() => _activeCategory = cat),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  height: 32,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: isSelected
                        ? const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 1),
                            ),
                          ]
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    cat,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: manrope(
                      size: 11,
                      weight: isSelected ? FontWeight.w700 : FontWeight.w600,
                      color: isSelected
                          ? AppColors.onPrimary
                          : AppColors.secondary,
                      letterSpacing: 0.04,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSortTabs() {
    final sorts = ['Terbaru', 'Populer', 'Paling Banyak Dibaca'];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: sorts.map((s) {
          final isSelected = s == _activeSort;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _activeSort = s),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.surfaceContainerLowest
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: isSelected
                      ? const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 1),
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  s,
                  style: manrope(
                    size: 13,
                    weight: FontWeight.w600,
                    color: isSelected ? AppColors.primary : AppColors.secondary,
                    letterSpacing: 0.02,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: AppColors.secondaryContainer,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_stories,
              size: 24,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Cerita tidak ditemukan',
            style: newsreader(size: 20, weight: FontWeight.w500, color: AppColors.onSurface),
          ),
          const SizedBox(height: 8),
          Text(
            'Kami tidak menemukan artikel yang cocok. Coba cari dengan kata kunci lain atau atur ulang filter Anda.',
            textAlign: TextAlign.center,
            style: manrope(
              size: 14,
              weight: FontWeight.w400,
              color: AppColors.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              _searchController.clear();
              setState(() {
                _searchQuery = '';
                _activeCategory = 'Semua';
              });
            },
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
              child: Text(
                'Atur ulang filter',
                style: manrope(
                  size: 13,
                  weight: FontWeight.w600,
                  color: AppColors.onPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(int activeIndex) {
    final items = [
      _NavData(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Beranda'),
      _NavData(icon: Icons.explore_outlined, activeIcon: Icons.explore, label: 'Jelajah'),
      _NavData(icon: Icons.edit_note, activeIcon: Icons.edit_note, label: 'Artikel Saya'),
      _NavData(icon: Icons.person_outlined, activeIcon: Icons.person, label: 'Profil'),
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
              final item = items[i];
              final isActive = i == activeIndex;
              return GestureDetector(
                onTap: () {
                  if (i == 0) {
                    Navigator.of(context)
                        .popUntil((route) => route.isFirst);
                  } else if (i == 2) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ArtikelSayaPage(),
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
                          Icon(
                            isActive ? item.activeIcon : item.icon,
                            size: 22,
                            color: isActive
                                ? AppColors.primary
                                : AppColors.secondary,
                          ),
                          ],
                      ),
                      const SizedBox(height: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          item.label,
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

class _NavData {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavData({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

class _ArticleCard extends StatelessWidget {
  final ExploreArticle article;
  final bool isBookmarked;
  final VoidCallback onBookmarkTap;

  const _ArticleCard({
    required this.article,
    required this.isBookmarked,
    required this.onBookmarkTap,
  });

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
      child: Row(
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: AppColors.surfaceContainerHigh,
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                (article.imageAsset.startsWith('http')
                    ? Image.network(
                        article.imageAsset,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, stack) => const Center(
                          child: Icon(Icons.broken_image, color: AppColors.outline),
                        ),
                      )
                    : Image.asset(
                        article.imageAsset,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, stack) => const Center(
                          child: Icon(Icons.image, color: AppColors.outline),
                        ),
                      )),
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: onBookmarkTap,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest.withValues(
                          alpha: 0.9,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isBookmarked
                            ? Icons.bookmark
                            : Icons.bookmark_border,
                        size: 14,
                        color: isBookmarked
                            ? AppColors.primary
                            : AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ],
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
                        article.category.toUpperCase(),
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
                        article.readTime,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: manrope(
                          size: 11,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  article.title,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${article.author} • ${article.readTime}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: manrope(
                          size: 11,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.visibility_outlined,
                          size: 14,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          article.views,
                          style: manrope(
                            size: 11,
                            weight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
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