1. Tipe Data
- String → nyimpen teks (judul, isi artikel, nama author)
- int → nyimpen angka bulat (id artikel, id kategori, jumlah view)
- double → nyimpen angka koma (progress draf 0.5, rating 4.5)
- bool → nyimpen ya/tidak (loading: true/false, published: true/false)
- List → nyimpen banyak data berurutan (daftar artikel, daftar kategori)
- Set → nyimpen data unik, gak boleh dobel (bookmark artikel)
- Map → nyimpen pasangan key-value (response JSON dari API)
- Future → nyimpen hasil yang belar nanti (ngambil data dari internet)
- Custom class (Post, Category, Article) → bikin model data sendiri biar rapi

2. Deklarasi Variabel
- const → nilai udah pasti dari awal, gak pernah berubah (nama app: "InkBlog")
- final → diisi sekali aja, setelah itu gak bisa diganti (controller, list artikel, warna)
- var → buat variabel lokal di dalam fungsi, Dart sendiri nebak tipenya (index tab, query search)
- late → variabel yang pasti diisi nanti, biasanya di initState (controller form)

3. Widget
- Semua tampilan di Flutter itu widget
- Ada widget layout: Column (vertikal), Row (horizontal), Stack (tumpang tindih)
- Ada widget list: ListView (scroll biasa), CustomScrollView + SliverList (scroll kompleks)
- Ada widget input: TextField (ketik teks), Form (validasi), Dropdown (pilih kategori), Switch (toggle on/off)
- Ada widget tampil: Text (teks), Image (gambar), Card (kotak), Chip (label kecil)
- Extract Widget → pecah widget besar jadi widget kecil biar gak berantakan (di main.dart ada 13 widget kecil)

4. Stateful vs Stateless
- StatelessWidget → UI gak berubah, cuma nampilin parameter yang dikirim (header, card, chip, nav bar)
- StatefulWidget → UI bisa berubah, punya setState() (halaman home load data, halaman detail like/bookmark, halaman form)
- Perbedaan: Stateless cuma punya build(), Stateful punya State class + initState() + setState() + dispose()

5. Input Form
- Form + GlobalKey → wadah validasi sekaligus
- TextFormField + validator → input teks dengan aturan (wajib diisi, max 100 karakter)
- TextEditingController → ambil/set nilai text field dari kode
- DropdownButtonFormField → pilih satu dari daftar (kategori: Teknologi, Desain, Pemrograman)
- SwitchListTile → toggle on/off (notifikasi, izinkan komentar)
- RadioListTile → pilih satu opsi (visibilitas: publik / hanya link)
- showDatePicker → kalender pilih tanggal

6. Navigator
- push() → buka halaman baru, tumpuk di atas (ke detail artikel, ke edit, ke explore)
- pop() → tutup halaman sekarang, balik ke halaman sebelumnya (back button, setelah save/delete)
- await push() → buka halaman tunggu sampai selesai, baru lanjut (bottom nav biar bisa reset index)
- Kirim data: lewat constructor (DetailPage(article: article)), ambil di halaman tujuan pakai widget.article

7. Package
- http → request ke API (GET, POST, PUT, DELETE)
- google_fonts → pakai font Manrope & Newsreader tanpa download file font
- intl → format tanggal/angka
- cupertino_icons → icon tambahan style iOS
- Semua di pubspec.yaml, dipakai via import di file yang butuh

8. Asset & Fonts
- Gambar: 20+ file JPG di folder assets/image/ (cover artikel, foto profil, kategori)
- Dipakai: Image.asset('assets/image/foto.jpg') + fallback icon kalau gagal load
- Font: lewat package google_fonts, dipakai via helper manrope() & newsreader() di shared.dart
- Daftar asset di pubspec.yaml bagian flutter.assets

9. REST API
- File api.dart berisi fungsi CRUD:
- getPosts() → GET /posts → ambil semua artikel
- getCategories() → GET /categories → ambil kategori
- createPost() → POST /posts → kirim artikel baru
- updatePost() → PUT /posts/:id → update artikel
- deletePost() → DELETE /posts/:id → hapus artikel
- Pakai package http, kirim/terima JSON, cek status code (200 OK, 201 Created, 400 Error, 404 Not Found, 500 Server Error)
- Backend: Express.js + PostgreSQL, pakai parameterized query (aman dari SQL injection)

10. Implementasi API di UI
- Home (main.dart): initState → _loadPosts() → getPosts() → setState → tampil list pakai SliverList. Ada pull-to-refresh, loading spinner, error retry, empty state.
- Artikel Saya (artikel_saya.dart): fetch semua → filter author "Setya" → tab filter (Semua/Published/Draf) → hapus panggil deletePost() → setState hapus lokal.
- Artikel Baru (artikel_baru.dart): form validasi → tombol simpan → createPost() → sukses → pop() balik ke list.
- Edit Artikel (edit_artikel.dart): terima id lewat constructor → form prefill → tombol simpan → updatePost(id, ...) → sukses → pop().
- Jelajah (jelajah.dart): fetch semua → search + filter kategori + sort populer → tampil grid card.
- Semua pakai try-catch + toast feedback (SnackBar).

- api.dart = Jembatan ke backend. Berisi model data + fungsi CRUD (getPosts, createPost, updatePost, deletePost, getCategories). Pakai package  http.

- api.dart = Jembatan ke backend. Model data + fungsi CRUD (getPosts, createPost, updatePost, deletePost, getCategories). Pakai http.

- artikel_baru.dart = Halaman Buat Artikel Baru. Form lengkap + validasi Form. Submit → kirim ke API (createPost).

- artikel_saya.dart = Halaman "Artikel Saya". Ambil artikel dari API → filter user "Setya" → tab (Semua/Published/Draf). Bisa hapus & edit.

- edit_artikel.dart = Halaman Edit Artikel. Terima id → isi form otomatis → submit → update ke API (updatePost).

- jelajah.dart = Halaman Jelajah/Explore. Ambil semua artikel → search + filter kategori + sort → tampil grid. Bisa bookmark.

- main.dart = Entry point + Halaman Beranda. Jalankan app, load artikel, tampil list + featured + search + filter + bookmark + bottom nav. Berisi Detail Artikel.

- profile.dart = Halaman Profil. UI statis: foto, bio, statistik, menu pengaturan, logout.

- shared.dart = Helper bersama. Fungsi font manrope() & newsreader(), class AppColors (semua warna). Dipakai semua file UI.