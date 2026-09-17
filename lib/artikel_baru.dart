import 'package:flutter/material.dart';

import 'api.dart';
import 'shared.dart';

class ArtikelBaruPage extends StatefulWidget {
  const ArtikelBaruPage({super.key});

  @override
  State<ArtikelBaruPage> createState() => _ArtikelBaruPageState();
}

class _ArtikelBaruPageState extends State<ArtikelBaruPage> {
  static const List<String> _suggestedTags = [
    'PenulisPemula',
    'TipsBelajar',
    'CeritaPertama',
  ];

  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;
  late final TextEditingController _tagController;
  late final TextEditingController _imageUrlController;

  /// Batas maksimal artikel sesuai permintaan: 5.
  static const int maxArticles = 5;

  List<Category> _categories = [];
  bool _loadingCategories = true;
  String _selectedCategory = 'Teknologi';
  bool _showWelcome = true;
  bool _isPublic = true;
  bool _allowComments = true;
  int _charCount = 0;
  final List<String> _tags = ['PenulisPemula'];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _bodyController = TextEditingController();
    _tagController = TextEditingController();
    _imageUrlController = TextEditingController();
    _titleController.addListener(() {
      setState(() => _charCount = _titleController.text.length);
    });
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final cats = await getCategories();
      if (!mounted) return;
      setState(() {
        _categories = cats;
        _loadingCategories = false;
        if (_categories.isNotEmpty) {
          _selectedCategory = _categories.first.name;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingCategories = false);
      _showToast('Gagal memuat kategori: $e', icon: Icons.error_outline);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _tagController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  int get _wordCount => _bodyController.text.trim().isEmpty
      ? 0
      : _bodyController.text.trim().split(RegExp(r'\s+')).length;

  int get _readMinutes => _wordCount > 0 ? (_wordCount / 180).ceil() : 0;

  void _showToast(String message, {IconData icon = Icons.check_circle}) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: DefaultTextStyle(
          style: manrope(
            size: 13,
            weight: FontWeight.w600,
            color: AppColors.inverseOnSurface,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: AppColors.primaryFixed),
              const SizedBox(width: 8),
              Flexible(child: Text(message)),
            ],
          ),
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        backgroundColor: AppColors.inverseSurface,
      ),
    );
  }

  void _addTag(String name) {
    final clean = name.replaceAll('#', '').trim();
    if (clean.isEmpty) return;
    if (_tags.contains(clean)) return;
    setState(() => _tags.add(clean));
  }

  Future<void> _publish() async {
    if (_titleController.text.trim().isEmpty) {
      _showToast('Isi judul artikel terlebih dahulu', icon: Icons.error_outline);
      return;
    }
    final imageUrl = _imageUrlController.text.trim();
    if (imageUrl.isEmpty) {
      _showToast('Isi URL gambar sampul (Cloudinary) dulu', icon: Icons.error_outline);
      return;
    }
    if (!(imageUrl.startsWith('http://') || imageUrl.startsWith('https://'))) {
      _showToast('URL gambar harus diawali http:// atau https://', icon: Icons.error_outline);
      return;
    }

    try {
      // Batasi maksimal 5 artikel.
      final existing = await getPosts();
      if (existing.length >= maxArticles) {
        _showToast('Maksimal $maxArticles artikel, hapus dulu kalau mau nambah', icon: Icons.error_outline);
        return;
      }
      final categoryId = _getCategoryId(_selectedCategory);
      await createPost(
        title: _titleController.text.trim(),
        content: _bodyController.text.trim(),
        categoryId: categoryId,
        author: 'Setya',
        image: imageUrl,
        status: 'published',
      );
      _showToast('Artikel berhasil dipublikasikan!');
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      _showToast('Gagal: $e', icon: Icons.error_outline);
    }
  }

  int _getCategoryId(String categoryName) {
    try {
      return _categories
          .firstWhere((c) => c.name == categoryName)
          .id;
    } catch (_) {
      return _categories.isNotEmpty ? _categories.first.id : 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  if (_showWelcome) ...[
                    _buildWelcomeBanner(),
                    const SizedBox(height: 12),
                  ],
                  _buildCoverSection(),
                  const SizedBox(height: 20),
                  _buildTitleSection(),
                  const SizedBox(height: 20),
                  _buildCategorySection(),
                  const SizedBox(height: 20),
                  _buildTagSection(),
                  const SizedBox(height: 20),
                  _buildEditorSection(),
                  const SizedBox(height: 20),
                  _buildPublishSettings(),
                  const SizedBox(height: 20),
                  _buildActions(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
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
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 6, 16, 6),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  size: 22,
                  color: AppColors.onSurfaceVariant,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              Text(
                'Artikel Baru',
                style: manrope(
                  size: 15,
                  weight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              const Spacer(),
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
        ),
      ),
    );
  }

  Widget _buildWelcomeBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.edit_note,
              size: 20,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selamat Datang di Ruang Tulis!',
                  style: manrope(
                    size: 13,
                    weight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Tuangkan gagasan, kisah, atau keahlianmu. Pembaca menantikan sudut pandang autentikmu.',
                  style: manrope(
                    size: 13,
                    weight: FontWeight.w400,
                    color: AppColors.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _showWelcome = false),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.close, size: 18, color: AppColors.outline),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoverSection() {
    final previewUrl = _imageUrlController.text.trim();
    final hasPreview = previewUrl.startsWith('http://') || previewUrl.startsWith('https://');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.image, size: 16, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(
                  'Sampul Artikel (wajib URL)',
                  style: manrope(
                    size: 13,
                    weight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
            Text(
              'Rasio 16:9 disarankan',
              style: manrope(size: 11, color: AppColors.outline),
            ),
          ],
        ),
        const SizedBox(height: 8),
        AspectRatio(
          aspectRatio: 16 / 9,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: hasPreview
                ? Image.network(
                    previewUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => const Center(
                      child: Icon(Icons.broken_image, size: 40, color: AppColors.outline),
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add_photo_alternate, size: 40, color: AppColors.primary),
                      const SizedBox(height: 8),
                      Text(
                        'Preview muncul setelah tempel URL Cloudinary',
                        style: manrope(size: 12, color: AppColors.onSurfaceVariant),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: _imageUrlController,
            keyboardType: TextInputType.url,
            onChanged: (_) => setState(() {}),
            style: manrope(size: 13, color: AppColors.onSurface),
            decoration: InputDecoration(
              hintText: 'Tempel URL Cloudinary, mis. https://res.cloudinary.com/.../cover.jpg',
              hintStyle: manrope(size: 12, color: AppColors.outline),
              prefixIcon: const Icon(Icons.link, size: 18, color: AppColors.primary),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Judul Tulisan',
              style: manrope(
                size: 13,
                weight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
            Text(
              '$_charCount/100',
              style: manrope(size: 11, color: AppColors.outline),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
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
          child: TextField(
            controller: _titleController,
            maxLength: 100,
            maxLines: null,
            style: newsreader(
              size: 20,
              weight: FontWeight.w500,
              color: AppColors.onSurface,
            ),
            decoration: InputDecoration(
              hintText: 'Tuliskan judul artikel pertamamu di sini...',
              hintStyle: newsreader(
                size: 20,
                weight: FontWeight.w500,
                color: AppColors.outlineVariant,
              ),
              border: InputBorder.none,
              counterText: '',
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Pilih Kategori Utama',
              style: manrope(
                size: 13,
                weight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
            Text(
              'Wajib (Pilih 1)',
              style: manrope(
                size: 11,
                weight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _loadingCategories
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              )
            : SizedBox(
                width: double.infinity,
                child: Wrap(
                  spacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    for (final category in _categories)
                      GestureDetector(
                        onTap: () =>
                            setState(() => _selectedCategory = category.name),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: category.name == _selectedCategory
                                ? AppColors.primary
                                : AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: category.name == _selectedCategory
                                ? const [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 4,
                                      offset: Offset(0, 1),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Text(
                            category.name,
                            style: manrope(
                              size: 11,
                              weight: FontWeight.w600,
                              color: category.name == _selectedCategory
                                  ? AppColors.onPrimary
                                  : AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
      ],
    );
  }

  Widget _buildTagSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Topik & Tag Tambahan',
          style: manrope(
            size: 13,
            weight: FontWeight.w700,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(10),
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
              Text(
                '#',
                style: manrope(
                  size: 14,
                  weight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _tagController,
                  onSubmitted: (value) {
                    _addTag(value);
                    _tagController.clear();
                  },
                  style: manrope(size: 14, color: AppColors.onSurface),
                  decoration: InputDecoration(
                    hintText: 'Ketik tag lalu tekan enter...',
                    hintStyle: manrope(size: 14, color: AppColors.outlineVariant),
                    border: InputBorder.none,
                    isCollapsed: true,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              'Saran Populer:',
              style: manrope(size: 11, color: AppColors.outline),
            ),
            for (final tag in _suggestedTags)
              GestureDetector(
                onTap: () => _addTag(tag),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '#$tag',
                    style: manrope(
                      size: 11,
                      color: AppColors.secondary,
                    ),
                  ),
                ),
              ),
          ],
        ),
        if (_tags.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final tag in _tags)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '#$tag',
                        style: manrope(
                          size: 11,
                          weight: FontWeight.w700,
                          color: AppColors.onSecondaryFixed,
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () => setState(() => _tags.remove(tag)),
                        child: Icon(
                          Icons.close,
                          size: 14,
                          color: AppColors.onSecondaryFixed.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildEditorSection() {
    return Container(
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
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _buildEditorToolbar(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _bodyController,
                  minLines: 10,
                  maxLines: null,
                  onChanged: (_) => setState(() {}),
                  style: newsreader(
                    size: 19,
                    weight: FontWeight.w400,
                    color: AppColors.onSurface,
                    height: 1.7,
                    letterSpacing: 0.005,
                  ),
                  decoration: InputDecoration(
                    hintText:
                        'Mulai ketik paragraf pertamamu di sini... Ceritakan latar belakang, ide utama, atau pengalaman berhargamu.',
                    hintStyle: newsreader(
                      size: 19,
                      weight: FontWeight.w400,
                      color: AppColors.outlineVariant,
                      height: 1.7,
                    ),
                    border: InputBorder.none,
                    isCollapsed: true,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.only(top: 8),
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Color(0x0A0F172A)),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.timer_outlined,
                        size: 14,
                        color: AppColors.outline,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$_readMinutes mnt baca',
                        style: manrope(size: 11, color: AppColors.outline),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '\u2022',
                        style: manrope(size: 11, color: AppColors.outline),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$_wordCount kata',
                        style: manrope(size: 11, color: AppColors.outline),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.tertiaryFixed,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Tersimpan otomatis',
                          style: manrope(
                            size: 11,
                            weight: FontWeight.w600,
                            color: AppColors.tertiaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditorToolbar() {
    Widget divider() => Container(
          width: 1,
          height: 16,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          color: AppColors.outlineVariant,
        );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: const BoxDecoration(color: AppColors.surfaceContainerLow),
      child: Row(
        children: [
          _ToolBtn(
            icon: Icons.format_bold,
            onTap: () => _showToast('Format tebal'),
          ),
          _ToolBtn(
            icon: Icons.format_italic,
            onTap: () => _showToast('Format miring'),
          ),
          divider(),
          _ToolBtn(
            label: 'H2',
            onTap: () => _showToast('Subjudul H2'),
          ),
          _ToolBtn(
            label: 'H3',
            onTap: () => _showToast('Subjudul H3'),
          ),
          divider(),
          _ToolBtn(
            icon: Icons.format_quote,
            onTap: () => _showToast('Kutipan'),
          ),
          _ToolBtn(
            icon: Icons.format_list_bulleted,
            onTap: () => _showToast('Daftar'),
          ),
          _ToolBtn(
            icon: Icons.link,
            onTap: () => _showToast('Tautan'),
          ),
          const Spacer(),
          _ToolBtn(
            icon: Icons.add_photo_alternate,
            iconColor: AppColors.primary,
            onTap: () => _showToast('Sisipkan gambar'),
          ),
        ],
      ),
    );
  }

  Widget _buildPublishSettings() {
    return Container(
      padding: const EdgeInsets.all(14),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.tune, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Pengaturan Distribusi',
                style: manrope(
                  size: 13,
                  weight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _VisibilityOption(
            icon: Icons.public,
            iconBg: AppColors.primary.withValues(alpha: 0.1),
            iconColor: AppColors.primary,
            title: 'Publik',
            subtitle: 'Tersedia untuk seluruh komunitas InkBlog',
            selected: _isPublic,
            onTap: () => setState(() => _isPublic = true),
          ),
          const SizedBox(height: 8),
          _VisibilityOption(
            icon: Icons.link,
            iconBg: AppColors.secondaryContainer,
            iconColor: AppColors.onSecondaryFixed,
            title: 'Hanya yang memiliki tautan',
            subtitle: 'Hanya orang dengan tautan yang dapat membaca',
            selected: !_isPublic,
            onTap: () => setState(() => _isPublic = false),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.chat_outlined,
                      size: 18,
                      color: AppColors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Izinkan tanggapan & komentar',
                      style: manrope(
                        size: 13,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () =>
                      setState(() => _allowComments = !_allowComments),
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: _allowComments
                          ? AppColors.primary
                          : AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: _allowComments
                        ? const Icon(
                            Icons.check,
                            size: 16,
                            color: AppColors.onPrimary,
                          )
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return GestureDetector(
      onTap: _publish,
      child: Container(
        width: double.infinity,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            'Simpan',
            style: manrope(
              size: 14,
              weight: FontWeight.w700,
              color: AppColors.onPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class _ToolBtn extends StatelessWidget {
  final IconData? icon;
  final String? label;
  final Color? iconColor;
  final VoidCallback onTap;

  const _ToolBtn({this.icon, this.label, this.iconColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
        ),
        alignment: Alignment.center,
        child: icon != null
            ? Icon(
                icon,
                size: 18,
                color: iconColor ?? AppColors.onSurfaceVariant,
              )
            : Text(
                label!,
                style: newsreader(
                  size: label == 'H2' ? 15 : 13,
                  weight: FontWeight.w500,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
      ),
    );
  }
}

class _VisibilityOption extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _VisibilityOption({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(10),
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
              width: 28,
              height: 28,
              decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
              child: Icon(icon, size: 16, color: iconColor),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: manrope(
                      size: 13,
                      weight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: manrope(size: 12, color: AppColors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? AppColors.primary : AppColors.outlineVariant,
                  width: 2,
                ),
              ),
              child: selected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}