import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'api.dart';
import 'shared.dart';

class EditArtikelPage extends StatefulWidget {
  final int id;
  final String title;
  final String category;
  final bool isDraft;
  final String? imageAsset;

  const EditArtikelPage({
    super.key,
    required this.id,
    required this.title,
    required this.category,
    required this.isDraft,
    this.imageAsset,
  });

  @override
  State<EditArtikelPage> createState() => _EditArtikelPageState();
}

class _EditArtikelPageState extends State<EditArtikelPage> {
  static const List<String> _coverOptions = [
    'assets/image/prog1.jpg',
    'assets/image/tech1.jpg',
    'assets/image/design2.jpg',
    'assets/image/design3.jpg',
  ];

  static const String _bodyPlaceholder =
      'Dengan dirilisnya Tailwind CSS v4, ekosistem frontend modern mengambil '
      'lompatan besar ke depan. Engine baru Oxy membawa kompilasi super cepat '
      'tanpa konfigurasi JavaScript yang rumit.\n\n'
      'Arsitektur zero-configuration berbasis file CSS murni ini menyederhanakan '
      'cara kita mengelola utility classes pada skala enterprise. Kecepatan build '
      'meningkat hampir 10x lipat berkat integrasi native Rust engine di balik layar.\n\n'
      'Bagi pengembang yang terbiasa dengan postcss dan tailwind.config.js, transisi '
      'ini mungkin terasa revolusioner sekaligus membebaskan...';

  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;
  late final TextEditingController _imageUrlController;
  List<Category> _categories = [];
  bool _loadingCategories = true;
  late String _selectedCategory;
  late bool _isPublished;
  late String? _coverAsset;
  late int _charCount;
  final List<String> _tags = ['#TailwindCSS', '#Frontend', '#WebDev'];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.category;
    _isPublished = !widget.isDraft;
    _coverAsset = widget.imageAsset ?? _coverOptions.first;
    _charCount = widget.title.length;
    _titleController = TextEditingController(text: widget.title);
    _bodyController = TextEditingController(text: _bodyPlaceholder);
    final initialImage = widget.imageAsset ?? '';
    _imageUrlController = TextEditingController(
      text: initialImage.startsWith('http') ? initialImage : '',
    );
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
        // Pastikan selectedCategory valid, kalau tidak pakai yang pertama
        if (!_categories.any((c) => c.name == _selectedCategory) &&
            _categories.isNotEmpty) {
          _selectedCategory = _categories.first.name;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingCategories = false);
      _showToast('Gagal memuat kategori: $e');
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  int get _wordCount => _bodyController.text.trim().isEmpty
      ? 0
      : _bodyController.text.trim().split(RegExp(r'\s+')).length;

  int get _readMinutes => math.max(1, (_wordCount / 150).ceil());

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

  Future<void> _save() async {
    final imageUrl = _imageUrlController.text.trim();
    if (imageUrl.isEmpty) {
      _showToast('Isi URL gambar sampul (Cloudinary) dulu');
      return;
    }
    if (!(imageUrl.startsWith('http://') || imageUrl.startsWith('https://'))) {
      _showToast('URL gambar harus diawali http:// atau https://');
      return;
    }
    try {
      final categoryId = _getCategoryId(_selectedCategory);
      await updatePost(
        id: widget.id,
        title: _titleController.text.trim(),
        content: _bodyController.text.trim(),
        categoryId: categoryId,
        author: 'Setya',
        image: imageUrl,
        status: _isPublished ? 'published' : 'draft',
      );
      _showToast('Perubahan berhasil diperbarui!');
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      _showToast('Gagal: $e');
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

  void _toggleVisibility() {
    setState(() => _isPublished = !_isPublished);
  }

  void _changeCover() {
    final index = _coverAsset == null
        ? 0
        : _coverOptions.indexOf(_coverAsset!);
    setState(() {
      _coverAsset = _coverOptions[(index + 1) % _coverOptions.length];
    });
  }

  void _removeCover() {
    setState(() => _coverAsset = null);
  }

  Future<void> _addTag() async {
    final controller = TextEditingController();
    final tag = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Tambah Tag',
          style: newsreader(
            size: 20,
            weight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: manrope(size: 14, color: AppColors.onSurface),
          decoration: InputDecoration(
            hintText: 'Contoh: #React',
            hintStyle: manrope(size: 14, color: AppColors.outline),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Batal',
              style: manrope(
                size: 13,
                weight: FontWeight.w700,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text),
            child: Text(
              'Tambah',
              style: manrope(
                size: 13,
                weight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
    controller.dispose();
    if (tag != null && tag.trim().isNotEmpty) {
      final formatted = tag.trim().startsWith('#')
          ? tag.trim()
          : '#${tag.trim()}';
      setState(() => _tags.add(formatted));
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
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoPill(),
                  const SizedBox(height: 16),
                  _buildCoverSection(),
                  const SizedBox(height: 20),
                  _buildTitleSection(),
                  const SizedBox(height: 20),
                  _buildCategorySection(),
                  const SizedBox(height: 20),
                  _buildTagsSection(),
                  const SizedBox(height: 20),
                  _buildEditorSection(),
                  const SizedBox(height: 20),
                  _buildStatusSection(),
                  const SizedBox(height: 20),
                  _buildActionsSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final hasDraft = !_isPublished;
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
          padding: const EdgeInsets.fromLTRB(8, 6, 12, 6),
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
              const SizedBox(width: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Edit Artikel',
                          style: manrope(
                            size: 15,
                            weight: FontWeight.w700,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryContainer,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '#8492',
                            style: manrope(
                              size: 11,
                              weight: FontWeight.w700,
                              color: AppColors.onSecondaryFixed,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _isPublished
                                ? AppColors.primary
                                : AppColors.secondary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          hasDraft ? 'STATUS: DRAF' : 'STATUS: DITERBITKAN',
                          style: manrope(
                            size: 10,
                            weight: FontWeight.w700,
                            color: AppColors.onSurfaceVariant,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(
    String title, {
    String? hint,
    Color hintColor = AppColors.onSurfaceVariant,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: manrope(
            size: 13,
            weight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
        if (hint != null)
          Text(
            hint,
            style: manrope(size: 11, weight: FontWeight.w400, color: hintColor),
          ),
      ],
    );
  }

  Widget _buildInfoPill() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Perubahan yang disimpan akan langsung terbarui di feed publik pembaca.',
              style: manrope(
                size: 11,
                weight: FontWeight.w400,
                color: AppColors.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoverSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('Gambar Sampul', hint: 'Rasio 16:9 • Maks 5MB'),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: 208,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (_coverAsset == null)
                  Container(
                    color: AppColors.surfaceContainer,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.image,
                          size: 40,
                          color: AppColors.outlineVariant,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Belum ada sampul',
                          style: manrope(
                            size: 12,
                            color: AppColors.outline,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Builder(
                    builder: (context) {
                      final url = _imageUrlController.text.trim();
                      final useNetwork = url.startsWith('http://') || url.startsWith('https://');
                      if (useNetwork) {
                        return Image.network(
                          url,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: AppColors.surfaceContainer,
                            child: const Center(
                              child: Icon(Icons.broken_image, size: 40, color: AppColors.outline),
                            ),
                          ),
                        );
                      }
                      return Image.asset(
                        _coverAsset!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: AppColors.surfaceContainer,
                          child: const Center(
                            child: Icon(
                              Icons.image,
                              size: 40,
                              color: AppColors.outline,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          AppColors.onSurface.withValues(alpha: 0.8),
                          AppColors.onSurface.withValues(alpha: 0.2),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.onSurface.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Aktif',
                      style: manrope(
                        size: 11,
                        weight: FontWeight.w700,
                        color: AppColors.surface,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 12,
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: _changeCover,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLowest
                                .withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(8),
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
                                Icons.add_photo_alternate,
                                size: 16,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Ganti Sampul',
                                style: manrope(
                                  size: 11,
                                  weight: FontWeight.w600,
                                  color: AppColors.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _removeCover,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLowest
                                .withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.delete,
                            size: 16,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
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
              hintText: 'Tempel URL Cloudinary (wajib)',
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
        _buildSectionLabel('Judul Artikel', hint: '$_charCount/100'),
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
              hintText: 'Tulis judul artikel yang memikat...',
              hintStyle: newsreader(
                size: 20,
                weight: FontWeight.w500,
                color: AppColors.outline,
              ),
              border: InputBorder.none,
              counterText: '',
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
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
        _buildSectionLabel(
          'Kategori Utama',
          hint: 'Pilih satu',
          hintColor: AppColors.primary,
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
                  runSpacing: 8,
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
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: category.name == _selectedCategory
                                ? AppColors.primary
                                : AppColors.surfaceContainerHigh,
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
                              weight: category.name == _selectedCategory
                                  ? FontWeight.w700
                                  : FontWeight.w500,
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

  Widget _buildTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Topik & Tag Terkait',
          style: manrope(
            size: 13,
            weight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
              for (final tag in _tags)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        tag,
                        style: manrope(
                          size: 11,
                          weight: FontWeight.w500,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () => setState(() => _tags.remove(tag)),
                        child: const Icon(
                          Icons.close,
                          size: 14,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              GestureDetector(
                onTap: _addTag,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.add, size: 14, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        'Tambah Tag',
                        style: manrope(
                          size: 11,
                          weight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
                ],
              ),
),
      ),
      ],
    );
  }

  Widget _buildEditorSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel(
          'Konten Artikel',
          hint: 'Mode Editorial',
          hintColor: AppColors.primary,
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
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              _buildEditorToolbar(),
              Container(
                constraints: const BoxConstraints(minHeight: 220),
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _bodyController,
                  minLines: 9,
                  maxLines: null,
                  style: newsreader(
                    size: 19,
                    weight: FontWeight.w400,
                    color: AppColors.onSurface,
                    height: 1.7,
                    letterSpacing: 0.005,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Tulis gagasan mendalam Anda di sini...',
                    hintStyle: newsreader(
                      size: 19,
                      weight: FontWeight.w400,
                      color: AppColors.outline,
                      height: 1.7,
                    ),
                    border: InputBorder.none,
                    isCollapsed: true,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: const BoxDecoration(color: AppColors.surfaceContainerLow),
                child: Row(
                  children: [
                    const Icon(
                      Icons.timer_outlined,
                      size: 14,
                      color: AppColors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '~$_readMinutes mnt baca ($_wordCount kata)',
                      style: manrope(
                        size: 11,
                        weight: FontWeight.w400,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    Flexible(
                      child: Text(
                        'Disimpan: 20 Okt, 14:30 WIB',
                        textAlign: TextAlign.right,
                        overflow: TextOverflow.ellipsis,
                        style: manrope(
                          size: 11,
                          weight: FontWeight.w400,
                          color: AppColors.onSurfaceVariant,
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
    );
  }

  Widget _buildEditorToolbar() {
    Widget divider() => Container(
          width: 1,
          height: 20,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          color: AppColors.outlineVariant,
        );

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: const BoxDecoration(color: AppColors.surfaceContainerLow),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _ToolButton(
              label: 'B',
              bold: true,
              onTap: () => _showToast('Format tebal segera hadir'),
            ),
            _ToolButton(
              label: 'I',
              italic: true,
              onTap: () => _showToast('Format miring segera hadir'),
            ),
            divider(),
            _ToolButton(
              label: 'H2',
              onTap: () => _showToast('Subjudul H2 segera hadir'),
            ),
            _ToolButton(
              label: 'H3',
              onTap: () => _showToast('Subjudul H3 segera hadir'),
            ),
            divider(),
            _ToolButton(
              icon: Icons.format_quote,
              onTap: () => _showToast('Kutipan segera hadir'),
            ),
            _ToolButton(
              icon: Icons.link,
              onTap: () => _showToast('Tautan segera hadir'),
            ),
            _ToolButton(
              icon: Icons.format_list_bulleted,
              onTap: () => _showToast('Daftar poin segera hadir'),
            ),
            _ToolButton(
              icon: Icons.code,
              onTap: () => _showToast('Blok kode segera hadir'),
            ),
            divider(),
            _ToolButton(
              icon: Icons.undo,
              onTap: () => _showToast('Batalkan segera hadir'),
            ),
            _ToolButton(
              icon: Icons.redo,
              onTap: () => _showToast('Ulangi segera hadir'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Status & Pengaturan Visibilitas',
          style: manrope(
            size: 13,
            weight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildVisibilityCard()),
            const SizedBox(width: 8),
            Expanded(child: _buildPerformanceCard()),
          ],
        ),
      ],
    );
  }

  Widget _buildVisibilityCard() {
    return Container(
      padding: const EdgeInsets.all(14),
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
            children: [
              Text(
                'VISIBILITAS',
                style: manrope(
                  size: 11,
                  weight: FontWeight.w600,
                  color: AppColors.onSurfaceVariant,
                  letterSpacing: 0.3,
                ),
              ),
              const Spacer(),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _isPublished ? AppColors.primary : AppColors.secondary,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _isPublished ? 'Diterbitkan' : 'Draf Disimpan',
            style: newsreader(
              size: 18,
              weight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            _isPublished ? 'Terlihat oleh semua' : 'Hanya terlihat oleh Anda',
            style: manrope(
              size: 11,
              weight: FontWeight.w400,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _toggleVisibility,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.swap_horiz,
                    size: 14,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _isPublished ? 'Ubah ke Draf' : 'Publikasikan',
                    style: manrope(
                      size: 11,
                      weight: FontWeight.w600,
                      color: AppColors.primary,
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

  Widget _buildPerformanceCard() {
    return Container(
      padding: const EdgeInsets.all(14),
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
            children: [
              Text(
                'PERFORMA',
                style: manrope(
                  size: 11,
                  weight: FontWeight.w600,
                  color: AppColors.onSurfaceVariant,
                  letterSpacing: 0.3,
                ),
              ),
              const Spacer(),
              const Icon(Icons.insights, size: 16, color: AppColors.primary),
            ],
          ),
          const SizedBox(height: 10),
          const _StatRow(label: 'Dibaca', value: '1.240×'),
          const SizedBox(height: 6),
          const _StatRow(label: 'Suka', value: '84'),
          const SizedBox(height: 6),
          const _StatRow(label: 'Komentar', value: '12'),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.trending_up, size: 14, color: AppColors.primary),
              const SizedBox(width: 4),
              Text(
                '+18% pekan ini',
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
    );
  }

  Widget _buildActionsSection() {
    return Column(
      children: [
        GestureDetector(
          onTap: _save,
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.done_all, size: 20, color: AppColors.onPrimary),
                const SizedBox(width: 8),
                Text(
                  'Simpan Perubahan',
                  style: manrope(
                    size: 13,
                    weight: FontWeight.w700,
                    color: AppColors.onPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ToolButton extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final bool bold;
  final bool italic;
  final VoidCallback onTap;

  const _ToolButton({
    this.label,
    this.icon,
    this.bold = false,
    this.italic = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: icon != null ? 32 : null,
        height: 32,
        padding: label != null
            ? const EdgeInsets.symmetric(horizontal: 8)
            : EdgeInsets.zero,
        alignment: Alignment.center,
        child: icon != null
            ? Icon(icon, size: 18, color: AppColors.onSurfaceVariant)
            : Text(
                label!,
                style: manrope(
                  size: 13,
                  weight: bold ? FontWeight.w700 : FontWeight.w600,
                  color: AppColors.onSurfaceVariant,
                  style: italic ? FontStyle.italic : FontStyle.normal,
                ),
              ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: manrope(
            size: 11,
            weight: FontWeight.w400,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: manrope(
            size: 13,
            weight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
      ],
    );
  }
}