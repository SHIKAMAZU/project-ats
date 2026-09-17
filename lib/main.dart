import 'package:flutter/material.dart';

import 'api.dart';
import 'artikel_saya.dart';
import 'jelajah.dart';
import 'profile.dart';
import 'shared.dart';

class Article {
  final String title, category, author, readTime, date, imageAsset, excerpt, badge;
  const Article({
    required this.title,
    required this.category,
    required this.author,
    required this.readTime,
    required this.date,
    required this.imageAsset,
    required this.excerpt,
    this.badge = '',
  });
}

const String appName = 'InkBlog';
const String greetingName = 'Setya';

void main() {
  runApp(const InkBlogApp());
}

class InkBlogApp extends StatelessWidget {
  const InkBlogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary, brightness: Brightness.light),
        scaffoldBackgroundColor: AppColors.surface,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Article> _articles = [];
  Article? _featured;
  bool _loading = true;
  String? _error;

  final List<String> _categories = const ['Semua', 'Teknologi', 'Desain', 'Pemrograman'];

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
      await ensureDemoSession();
      final posts = await getPosts();
      if (!mounted) return;
      setState(() {
        _articles = posts.map(_toArticle).toList();
        final featured = _articles.where((a) => a.title.contains('Minimalis'));
        _featured = featured.isNotEmpty
            ? featured.first
            : (_articles.isNotEmpty ? _articles.first : null);
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

  Article _toArticle(Post p) {
    return Article(
      title: p.title,
      category: p.category.isEmpty ? 'Umum' : p.category,
      author: p.author,
      readTime: _formatReadTime(p.content),
      date: _formatDate(p.createdAt),
      imageAsset: p.image.isEmpty ? 'assets/image/prog1.jpg' : p.image,
      excerpt: p.content,
      badge: (p.author == greetingName && p.status == 'draft') ? 'Draf' : (p.author == greetingName ? 'Anda' : ''),
    );
  }

  String _formatReadTime(String content) {
    var minutes = (content.runes.length / 300).ceil();
    if (minutes < 1) minutes = 1;
    return '$minutes mnt baca';
  }

  String _formatDate(String createdAt) {
    final dt = DateTime.tryParse(createdAt);
    if (dt == null) return '';
    const bulan = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${dt.day} ${bulan[dt.month - 1]}';
  }

  int _selectedCategory = 0;
  int _bottomNavIndex = 0;
  final Set<String> _bookmarks = {};
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  List<Article> get _filteredArticles {
    var list = _articles;
    if (_selectedCategory != 0) {
      var cat = _categories[_selectedCategory];
      list = list.where((a) => a.category == cat).toList();
    }
    if (_searchQuery.isNotEmpty) {
      var q = _searchQuery.toLowerCase();
      list = list.where((a) =>
        a.title.toLowerCase().contains(q) ||
        a.author.toLowerCase().contains(q) ||
        a.category.toLowerCase().contains(q) ||
        a.excerpt.toLowerCase().contains(q)
      ).toList();
    }
    return list;
  }

  bool get _featuredBookmarked => _featured != null && _bookmarks.contains(_featured!.title);

  void _toggleFeaturedBookmark() {
    if (_featured == null) return;
    setState(() {
      var title = _featured!.title;
      if (_bookmarks.contains(title)) {
        _bookmarks.remove(title);
        _showToast('Dihapus dari daftar bacaan', Icons.bookmark_remove);
      } else {
        _bookmarks.add(title);
        _showToast('Disimpan ke daftar bacaan!', Icons.bookmark);
      }
    });
  }

  void _showToast(String msg, IconData icon) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: DefaultTextStyle(
          style: const TextStyle(color: AppColors.inverseOnSurface, fontSize: 13, fontWeight: FontWeight.w600),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 18, color: AppColors.primaryFixed),
            const SizedBox(width: 8),
            Flexible(child: Text(msg)),
          ]),
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: AppColors.inverseSurface,
      ),
    );
  }

  void _openDetail(Article article) {
    Navigator.push(context, MaterialPageRoute(
      builder: (context) => ArticleDetailPage(article: article),
    ));
  }

  @override
  Widget build(BuildContext context) {
    var displayed = _filteredArticles;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadPosts,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
        SliverAppBar(
          pinned: true,
          floating: true,
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: AppColors.surface.withValues(alpha: 0.85),
          surfaceTintColor: Colors.transparent,
          toolbarHeight: 64,
          title: const Text(appName, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500, color: AppColors.onSurface)),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined, size: 24, color: AppColors.onSurfaceVariant),
              onPressed: () => _showToast('Tidak ada notifikasi baru', Icons.notifications_outlined),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: CircleAvatar(radius: 16, backgroundColor: AppColors.primary, child: Icon(Icons.person, size: 18, color: Colors.white)),
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 8),
              const _GreetingHeader(),
              const SizedBox(height: 16),
              _SearchBar(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val),
                onSubmitted: (val) {
                  if (val.trim().isNotEmpty) {
                    _showToast('Mencari "$val"', Icons.search);
                  }
                },
              ),
              const SizedBox(height: 20),
              if (_featured != null) ...[
                _FeaturedArticleSection(
                  isBookmarked: _featuredBookmarked,
                  onBookmarkTap: _toggleFeaturedBookmark,
                  imageAsset: _featured!.imageAsset,
                  onTap: () => _openDetail(_featured!),
                ),
                const SizedBox(height: 20),
              ],
              _CategoryChips(
                categories: _categories,
                selectedIndex: _selectedCategory,
                onSelected: (index) {
                  setState(() => _selectedCategory = index);
                  _showToast('Difilter berdasarkan ${_categories[index]}', Icons.filter_list);
                },
              ),
              const SizedBox(height: 20),
              Row(children: [
                const Text('Artikel Terbaru', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                const SizedBox(width: 6),
                Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
              ]),
              const SizedBox(height: 8),
            ]),
          ),
        ),
        if (_loading)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_error != null)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.cloud_off, size: 40, color: AppColors.outline),
                  const SizedBox(height: 8),
                  const Text('Gagal memuat artikel', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
                  const SizedBox(height: 4),
                  Text(_error!, style: const TextStyle(fontSize: 12, color: AppColors.outline), textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  FilledButton(onPressed: _loadPosts, child: const Text('Coba lagi')),
                ]),
              ),
            ),
          )
        else if (displayed.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: Text('Belum ada artikel', style: TextStyle(fontSize: 15, color: AppColors.onSurfaceVariant))),
          )
        else
          SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              var article = displayed[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ArticleCard(
                  article: article,
                  isBookmarked: _bookmarks.contains(article.title),
                  onBookmarkTap: () {
                    setState(() {
                      if (_bookmarks.contains(article.title)) {
                        _bookmarks.remove(article.title);
                        _showToast('Dihapus dari daftar bacaan', Icons.bookmark_remove);
                      } else {
                        _bookmarks.add(article.title);
                        _showToast('Disimpan ke daftar bacaan!', Icons.bookmark);
                      }
                    });
                  },
                  onTap: () => _openDetail(article),
                ),
              );
            }, childCount: displayed.length),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
          ],
        ),
      ),
      bottomNavigationBar: _BottomNavBar(
        selectedIndex: _bottomNavIndex,
        onTap: (index) async {
          setState(() => _bottomNavIndex = index);
          if (index == 1) {
            await Navigator.push(context, MaterialPageRoute(builder: (context) => const ExplorePage()));
          } else if (index == 2) {
            await Navigator.push(context, MaterialPageRoute(builder: (context) => const ArtikelSayaPage()));
          } else if (index == 3) {
            await Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilePage()));
          }
          if (mounted) setState(() => _bottomNavIndex = 0);
        },
      ),
    );
  }
}

class _GreetingHeader extends StatelessWidget {
  const _GreetingHeader();

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Selamat pagi, $greetingName', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500, color: AppColors.onSurface)),
      const SizedBox(height: 4),
      const Text('Temukan cerita yang menginspirasi harimu', style: TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant)),
    ]);
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;

  const _SearchBar({required this.controller, required this.onChanged, required this.onSubmitted});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1))],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        style: const TextStyle(fontSize: 14, color: AppColors.onSurface),
        decoration: const InputDecoration(
          hintText: 'Cari artikel, topik, atau penulis...',
          hintStyle: TextStyle(fontSize: 14, color: AppColors.outline),
          prefixIcon: Icon(Icons.search, size: 20, color: AppColors.outline),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}

class _FeaturedArticleSection extends StatelessWidget {
  final bool isBookmarked;
  final VoidCallback onBookmarkTap;
  final VoidCallback onTap;
  final String imageAsset;

  const _FeaturedArticleSection({required this.isBookmarked, required this.onBookmarkTap, required this.onTap, required this.imageAsset});

  @override
  Widget build(BuildContext context) {
    IconData bookmarkIcon;
    if (isBookmarked) {
      bookmarkIcon = Icons.bookmark;
    } else {
      bookmarkIcon = Icons.bookmark_border;
    }

    Color bookmarkColor;
    if (isBookmarked) {
      bookmarkColor = AppColors.primary;
    } else {
      bookmarkColor = AppColors.onSurface;
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('ARTIKEL UTAMA', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.secondary, letterSpacing: 0.5)),
      const SizedBox(height: 8),
      GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(children: [
            SizedBox(
              height: 224,
              width: double.infinity,
              child: Stack(fit: StackFit.expand, children: [
                _ArticleImage(src: imageAsset, iconSize: 48),
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.transparent, Color(0x990B1C30)]),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('Desain & UI', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: onBookmarkTap,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(bookmarkIcon, size: 20, color: bookmarkColor),
                    ),
                  ),
                ),
                const Positioned(
                  bottom: 12,
                  left: 12,
                  right: 12,
                  child: Text(
                    'Seni Desain Produk Minimalis di 2025',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: AppColors.surface, height: 1.3),
                  ),
                ),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Row(children: [
                  const CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.surfaceContainerHigh,
                    child: Icon(Icons.person, size: 18, color: AppColors.outline),
                  ),
                  const SizedBox(width: 8),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                    Text('Setya', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
                    Text('6 mnt baca • 2 jam lalu', style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                  ]),
                ]),
                const Icon(Icons.arrow_forward, size: 20, color: AppColors.primary),
              ]),
            ),
          ]),
        ),
      ),
    ]);
  }
}

class _CategoryChips extends StatelessWidget {
  final List<String> categories;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const _CategoryChips({required this.categories, required this.selectedIndex, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('KATEGORI', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.secondary, letterSpacing: 0.5)),
      const SizedBox(height: 8),
      Center(
        child: Wrap(spacing: 8, runSpacing: 8, alignment: WrapAlignment.center, children: List.generate(categories.length, (index) {
          var isSelected = index == selectedIndex;

          Color chipColor;
          if (isSelected) {
            chipColor = AppColors.primary;
          } else {
            chipColor = AppColors.surfaceContainer;
          }

          List<BoxShadow> chipShadow = [];
          if (isSelected) {
            chipShadow.add(const BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1)));
          }

          FontWeight chipWeight;
          if (isSelected) {
            chipWeight = FontWeight.w700;
          } else {
            chipWeight = FontWeight.w500;
          }

          Color chipTextColor;
          if (isSelected) {
            chipTextColor = AppColors.onPrimary;
          } else {
            chipTextColor = AppColors.onSurfaceVariant;
          }

          return GestureDetector(
            onTap: () => onSelected(index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(color: chipColor, borderRadius: BorderRadius.circular(20), boxShadow: chipShadow),
              child: Text(categories[index], style: TextStyle(fontSize: 13, fontWeight: chipWeight, color: chipTextColor)),
            ),
          );
        })),
      ),
    ]);
  }
}

class _ArticleCard extends StatelessWidget {
  final Article article;
  final bool isBookmarked;
  final VoidCallback onBookmarkTap;
  final VoidCallback onTap;

  const _ArticleCard({required this.article, required this.isBookmarked, required this.onBookmarkTap, required this.onTap});

  bool get _isBlueCard {
    const blueSet = {
      'AI dan Masa Depan Pengembangan Perangkat Lunak',
      'Blockchain Beyond Crypto',
      'Tips UI/UX untuk Pemula',
      'Color Theory dalam Desain Digital',
      'React vs Flutter: Mana yang Dipilih?',
    };
    return blueSet.contains(article.title);
  }

  IconData _bookmarkIcon() {
    if (isBookmarked) {
      return Icons.bookmark;
    }
    return Icons.bookmark_border;
  }

  Color _bookmarkColor() {
    if (isBookmarked) {
      return AppColors.primary;
    }
    return AppColors.outline;
  }

  List<Widget> _metaChips() {
    List<Widget> w = [];
    w.add(Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: AppColors.secondaryContainer, borderRadius: BorderRadius.circular(12)),
      child: Text(article.category, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.onSecondaryFixed)),
    ));
    w.add(const SizedBox(width: 8));
    w.add(Text(article.date, style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)));
    return w;
  }

  @override
  Widget build(BuildContext context) {
    if (_isBlueCard) {
      return _buildSplitCard(context);
    }
    return _buildCompactCard(context);
  }

  Widget _buildCompactCard(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1))],
        ),
        child: Row(children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: AppColors.surfaceContainerHigh),
            clipBehavior: Clip.antiAlias,
            child: Stack(fit: StackFit.expand, children: [
              _ArticleImage(src: article.imageAsset),
              if (article.badge.isNotEmpty)
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(4)),
                    child: Text(article.badge, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.onPrimary)),
                  ),
                ),
            ]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(article.category.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary, letterSpacing: 0.5)),
                if (article.date.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  Container(width: 3, height: 3, decoration: const BoxDecoration(color: AppColors.outlineVariant, shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  Text(article.date, style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                ],
              ]),
              const SizedBox(height: 4),
              Text(article.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.onSurface, height: 1.3)),
              const SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Expanded(
                  child: Text('${article.author} • ${article.readTime}', style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant), overflow: TextOverflow.ellipsis),
                ),
                GestureDetector(onTap: onBookmarkTap, child: Icon(_bookmarkIcon(), size: 20, color: _bookmarkColor())),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _buildSplitCard(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: _metaChips()),
                const SizedBox(height: 8),
                Text(article.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.onSurface, height: 1.3)),
                const SizedBox(height: 4),
                Text(article.excerpt, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant, height: 1.4)),
              ]),
            ),
            const SizedBox(width: 12),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: AppColors.surfaceContainerHigh),
              clipBehavior: Clip.antiAlias,
              child: _ArticleImage(src: article.imageAsset),
            ),
          ]),
          const SizedBox(height: 10),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(children: [
              CircleAvatar(
                radius: 10,
                backgroundColor: AppColors.surfaceDim,
                child: Text(article.author.substring(0, 1), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.onSurfaceVariant)),
              ),
              const SizedBox(width: 6),
              Text(article.author, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
              const SizedBox(width: 6),
              Text('• ${article.readTime}', style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
            ]),
            GestureDetector(onTap: onBookmarkTap, child: Icon(_bookmarkIcon(), size: 20, color: _bookmarkColor())),
          ]),
        ]),
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _BottomNavBar({required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: AppColors.surface, boxShadow: [BoxShadow(color: Color(0x0A0F172A), blurRadius: 16, offset: Offset(0, -4))]),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            _NavItem(icon: Icons.home, label: 'Beranda', isActive: selectedIndex == 0, onTap: () => onTap(0)),
            _NavItem(icon: Icons.explore, label: 'Jelajah', isActive: selectedIndex == 1, onTap: () => onTap(1)),
            _NavItem(icon: Icons.edit_note, label: 'Artikel Saya', isActive: selectedIndex == 2, onTap: () => onTap(2), iconShift: 2),
            _NavItem(icon: Icons.person, label: 'Profil', isActive: selectedIndex == 3, onTap: () => onTap(3)),
          ]),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final double iconShift;

  const _NavItem({required this.icon, required this.label, required this.isActive, required this.onTap, this.iconShift = 0});

  @override
  Widget build(BuildContext context) {
    var activeColor = AppColors.primary;
    var inactiveColor = AppColors.secondary;

    Color iconColor;
    if (isActive) {
      iconColor = activeColor;
    } else {
      iconColor = inactiveColor;
    }

    FontWeight labelWeight;
    if (isActive) {
      labelWeight = FontWeight.w700;
    } else {
      labelWeight = FontWeight.w500;
    }

    Color dotColor;
    if (isActive) {
      dotColor = activeColor;
    } else {
      dotColor = Colors.transparent;
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Stack(clipBehavior: Clip.none, children: [
            Transform.translate(
              offset: Offset(iconShift, 0),
              child: Icon(icon, size: 22, color: iconColor),
            ),
          ]),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: labelWeight, color: iconColor)),
          const SizedBox(height: 2),
          Container(width: 4, height: 4, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
        ]),
      ),
    );
  }
}

class _ArticleImage extends StatelessWidget {
  final String src;
  final double iconSize;

  const _ArticleImage({required this.src, this.iconSize = 24});

  @override
  Widget build(BuildContext context) {
    Widget placeholder = Container(
      color: AppColors.surfaceContainerHigh,
      child: Center(child: Icon(Icons.image, size: iconSize, color: AppColors.outline)),
    );

    if (src.startsWith('http')) {
      return Image.network(src, fit: BoxFit.cover, errorBuilder: (c, e, s) => placeholder);
    } else if (src.isNotEmpty) {
      return Image.asset(src, fit: BoxFit.cover, errorBuilder: (c, e, s) => placeholder);
    }
    return placeholder;
  }
}

class ArticleDetailPage extends StatefulWidget {
  final Article article;
  const ArticleDetailPage({super.key, required this.article});

  @override
  State<ArticleDetailPage> createState() => _ArticleDetailPageState();
}

class _ArticleDetailPageState extends State<ArticleDetailPage> {
  bool _isLiked = false;
  bool _isSaved = false;

  Article get article => widget.article;

  void _showToast(String msg, IconData icon) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: DefaultTextStyle(
          style: const TextStyle(color: AppColors.inverseOnSurface, fontSize: 13, fontWeight: FontWeight.w600),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 18, color: AppColors.primaryFixed),
            const SizedBox(width: 8),
            Flexible(child: Text(msg)),
          ]),
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: AppColors.inverseSurface,
      ),
    );
  }

  void _toggleSaved() {
    setState(() {
      if (_isSaved) {
        _isSaved = false;
      } else {
        _isSaved = true;
      }
    });
    if (_isSaved) {
      _showToast('Disimpan ke daftar bacaan!', Icons.bookmark);
    } else {
      _showToast('Dihapus dari daftar bacaan', Icons.bookmark_remove);
    }
  }

  void _toggleLiked() {
    setState(() {
      if (_isLiked) {
        _isLiked = false;
      } else {
        _isLiked = true;
      }
    });
    if (_isLiked) {
      _showToast('Kamu menyukai artikel ini', Icons.favorite);
    } else {
      _showToast('Suka dihapus', Icons.favorite);
    }
  }

  String _formatNumber(int value) {
    if (value >= 1000) {
      int quotient = (value / 1000).toInt();
      int remainder = value % 1000;
      String suffix = 'rb';
      if (remainder >= 100) {
        int desimal = (remainder / 100).toInt();
        return '$quotient,$desimal$suffix';
      }
      return '$quotient$suffix';
    }
    return '$value';
  }

  Widget _body(String text) {
    return Text(text, style: const TextStyle(fontSize: 15, color: AppColors.onSurface, height: 1.7));
  }

  @override
  Widget build(BuildContext context) {
    var likes = (article.title.length * 137) % 900 + 120;
    var views = likes * 7;
    var comments = (likes / 9).toInt();

    IconData saveIcon;
    if (_isSaved) {
      saveIcon = Icons.bookmark;
    } else {
      saveIcon = Icons.bookmark_border;
    }

    String saveLabel;
    if (_isSaved) {
      saveLabel = 'Tersimpan';
    } else {
      saveLabel = 'Simpan';
    }

    Color likeBoxColor;
    if (_isLiked) {
      likeBoxColor = const Color(0xFFFFDAD6);
    } else {
      likeBoxColor = AppColors.surfaceContainerLow;
    }

    IconData likeIcon;
    if (_isLiked) {
      likeIcon = Icons.favorite;
    } else {
      likeIcon = Icons.favorite_border;
    }

    Color likeColor;
    if (_isLiked) {
      likeColor = const Color(0xFFBA1A1A);
    } else {
      likeColor = AppColors.onSurfaceVariant;
    }

    String likeLabel;
    if (_isLiked) {
      likeLabel = 'Disukai • ${_formatNumber(likes + 1)}';
    } else {
      likeLabel = 'Sukai artikel ini';
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        title: const Text('Detail Artikel'),
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            height: 210,
            width: double.infinity,
            child: Stack(fit: StackFit.expand, children: [
              _ArticleImage(src: article.imageAsset, iconSize: 48),
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Color(0x990B1C30)]),
                ),
              ),
              Positioned(
                left: 12,
                bottom: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.surfaceContainerLowest.withValues(alpha: 0.9), borderRadius: BorderRadius.circular(20)),
                  child: Text(article.category.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
                ),
              ),
            ]),
          ),
        ),
        const SizedBox(height: 16),
        Row(children: [
          const Icon(Icons.schedule, size: 14, color: AppColors.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(article.readTime, style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
          const SizedBox(width: 12),
          const Icon(Icons.calendar_today_outlined, size: 13, color: AppColors.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(article.date, style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
        ]),
        const SizedBox(height: 12),
        Text(article.title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w600, color: AppColors.onSurface, height: 1.25)),
        const SizedBox(height: 12),
        Row(children: [
          const CircleAvatar(radius: 18, backgroundColor: AppColors.surfaceContainerHigh, child: Icon(Icons.person, size: 20, color: AppColors.primary)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(article.author, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
              const Text('Penulis InkBlog', style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
            ]),
          ),
          GestureDetector(
            onTap: () => _showToast('Kamu mengikuti penulis ini', Icons.person_add),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(20)),
              child: const Text('Ikuti', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.onPrimary)),
            ),
          ),
        ]),
        const SizedBox(height: 16),
        Row(children: [
          _DetailStatChip(icon: Icons.visibility_outlined, label: '${_formatNumber(views)} dilihat'),
          const SizedBox(width: 8),
          _DetailStatChip(icon: Icons.favorite_border, label: '${_formatNumber(likes)} suka'),
          const SizedBox(width: 8),
          _DetailStatChip(icon: Icons.comment_outlined, label: '${_formatNumber(comments)} komentar'),
        ]),
        const SizedBox(height: 20),
        Text(article.excerpt, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.onSurface, height: 1.7)),
        const SizedBox(height: 16),
        const _DetailSectionHeader(title: 'Mengapa Topik Ini Penting'),
        const SizedBox(height: 8),
        _body('Dalam ekosistem digital yang berkembang cepat, memahami topik ini bukan sekadar tren, melainkan kebutuhan. Banyak praktisi mulai mengadopsi pendekatan ini untuk meningkatkan kualitas hasil dan efisiensi kerja mereka.'),
        const SizedBox(height: 16),
        const _DetailSectionHeader(title: 'Konsep Dasar yang Perlu Dipahami'),
        const SizedBox(height: 8),
        _body('Mulailah dari prinsip paling sederhana: konsistensi. Entah itu alur data, antarmuka, atau kode, konsistensi membantu orang lain memahami apa yang kamu bangun. Setelah itu, biasakan mendokumentasikan setiap keputusan kecil tersebut.'),
        const SizedBox(height: 20),
        const _DetailQuote(text: '"Sebuah karya yang baik tidak lahir dari satu kali percobaan, tapi dari banyak iterasi yang sabar."'),
        const SizedBox(height: 20),
        const _DetailSectionHeader(title: 'Poin Penting'),
        const SizedBox(height: 8),
        const _DetailBullet(icon: Icons.check_circle, text: 'Pahami kebutuhan sebelum menentukan solusi yang dipakai.'),
        const _DetailBullet(icon: Icons.check_circle, text: 'Gunakan prinsip sederhana dan modular agar mudah dikembangkan.'),
        const _DetailBullet(icon: Icons.check_circle, text: 'Evaluasi secara berkala dan jangan takut melakukan perubahan kecil.'),
        const _DetailBullet(icon: Icons.check_circle, text: 'Belajar dari komunitas dan sumber terpercaya untuk mempercepat wawasan.'),
        const SizedBox(height: 20),
        const _DetailSectionHeader(title: 'Tag Terkait'),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: [
          _DetailTagChip(label: '#${article.category}'),
          const _DetailTagChip(label: '#Panduan'),
          const _DetailTagChip(label: '#Pemula'),
          const _DetailTagChip(label: '#Tips'),
        ]),
        const SizedBox(height: 24),
        Row(children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _toggleSaved,
              icon: Icon(saveIcon, size: 18),
              label: Text(saveLabel),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.onSurface,
                side: const BorderSide(color: AppColors.outlineVariant),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _showToast('Link artikel berhasil disalin', Icons.check),
              icon: const Icon(Icons.share_outlined, size: 18),
              label: const Text('Bagikan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                elevation: 0,
              ),
            ),
          ),
        ]),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _toggleLiked,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(color: likeBoxColor, borderRadius: BorderRadius.circular(12)),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(likeIcon, size: 18, color: likeColor),
              const SizedBox(width: 8),
              Text(likeLabel, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: likeColor)),
            ]),
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(16)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('TENTANG PENULIS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.secondary, letterSpacing: 0.5)),
            const SizedBox(height: 12),
            Row(children: [
              const CircleAvatar(radius: 24, backgroundColor: AppColors.primaryFixed, child: Icon(Icons.person, size: 26, color: AppColors.primary)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(article.author, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
                  Row(children: const [
                    Text('12 artikel', style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                    Padding(padding: EdgeInsets.symmetric(horizontal: 6), child: Text('•', style: TextStyle(color: AppColors.outlineVariant))),
                    Text('2.4rb pengikut', style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                  ]),
                ]),
              ),
            ]),
            const SizedBox(height: 12),
            const Text('Menulis tentang teknologi, desain, dan pengembangan diri. Membagikan praktik terbaik agar topik rumit terasa mudah dipahami.', style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant, height: 1.5)),
          ]),
        ),
        const SizedBox(height: 16),
      ]),
    );
  }
}

class _DetailStatChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _DetailStatChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(16)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: AppColors.onSurfaceVariant),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant)),
      ]),
    );
  }
}

class _DetailSectionHeader extends StatelessWidget {
  final String title;

  const _DetailSectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(width: 4, height: 18, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 8),
      Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
    ]);
  }
}

class _DetailBullet extends StatelessWidget {
  final IconData icon;
  final String text;

  const _DetailBullet({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 14, color: AppColors.onSurface, height: 1.5))),
      ]),
    );
  }
}

class _DetailQuote extends StatelessWidget {
  final String text;

  const _DetailQuote({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryFixed,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryFixedDim),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Icon(Icons.format_quote, size: 28, color: AppColors.primary),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic, fontWeight: FontWeight.w500, color: AppColors.onSecondaryFixed, height: 1.6))),
      ]),
    );
  }
}

class _DetailTagChip extends StatelessWidget {
  final String label;

  const _DetailTagChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: AppColors.surfaceContainer, borderRadius: BorderRadius.circular(16)),
      child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
    );
  }
}