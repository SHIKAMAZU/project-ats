import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

// Backend Express sekarang jalan di :3000 dengan prefix /api/v1.
// (Dulu: http://localhost:5000 tanpa prefix.)
// Untuk Android emulator pakai 'http://10.0.2.2:3000/api/v1'.
const String baseUrl = 'http://localhost:3000/api/v1';

/// Sesi auth sederhana (in-memory).
/// Diisi otomatis oleh [login]/[register], dipakai oleh
/// [createPost]/[updatePost]/[deletePost] sebagai header Bearer.
class AuthSession {
  static String? token;
  static int userId = 1; // default dev = user "Setya"
  static String username = 'Setya';

  static Map<String, String> headers({bool json = true}) {
    final h = <String, String>{};
    if (json) h['Content-Type'] = 'application/json';
    if (token != null && token!.isNotEmpty) {
      h['Authorization'] = 'Bearer $token';
    }
    return h;
  }

  static void clear() {
    token = null;
  }
}

class AppUser {
  final int id;
  final String username;
  final String email;
  final String role;

  const AppUser({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: _asInt(json['id']),
      username: (json['username'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
      role: (json['role'] as String?) ?? 'user',
    );
  }
}

Future<AppUser> register({
  required String username,
  required String email,
  required String password,
}) async {
  final res = await http.post(
    Uri.parse('$baseUrl/auth/register'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'username': username, 'email': email, 'password': password}),
  );
  if (res.statusCode != 201) {
    throw Exception('Gagal register (${res.statusCode}): ${_serverMessage(res.body)}');
  }
  final body = jsonDecode(res.body) as Map<String, dynamic>;
  final user = AppUser.fromJson((body['data']?['user'] ?? {}) as Map<String, dynamic>);
  AuthSession.userId = user.id;
  AuthSession.username = user.username;
  return user;
}

Future<AppUser> login({required String email, required String password}) async {
  final res = await http.post(
    Uri.parse('$baseUrl/auth/login'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'email': email, 'password': password}),
  );
  if (res.statusCode != 200) {
    throw Exception('Gagal login (${res.statusCode}): ${_serverMessage(res.body)}');
  }
  final body = jsonDecode(res.body) as Map<String, dynamic>;
  final data = (body['data'] ?? {}) as Map<String, dynamic>;
  AuthSession.token = data['token'] as String?;
  final user = AppUser.fromJson((data['user'] ?? {}) as Map<String, dynamic>);
  AuthSession.userId = user.id;
  AuthSession.username = user.username;
  return user;
}

/// Login otomatis akun demo agar create/update/delete langsung jalan
/// tanpa layar login. GET list/detail tetap bisa sebagai tamu kalau
/// backend mati atau akun belum ada — jadi fungsi ini tidak pernah throw.
Future<void> ensureDemoSession() async {
  if (AuthSession.token != null && AuthSession.token!.isNotEmpty) return;
  const email = 'setya@tes.id';
  const password = 'rahasia1';
  try {
    await login(email: email, password: password);
  } catch (_) {
    try {
      await register(username: 'setya', email: email, password: password);
      await login(email: email, password: password);
    } catch (_) {
      // mode tamu: list/detail tetap jalan, tulis butuh backend + akun
    }
  }
}

class Category {
  final int id;
  final String name;

  const Category({required this.id, required this.name});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: _asInt(json['id']),
      name: (json['name'] as String?) ?? '',
    );
  }
}

class Post {
  final int id;
  final int userId;
  final String title;
  final String content;
  final String author;
  final String image;
  final String createdAt;
  final String category;
  final String status;

  const Post({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.author,
    required this.image,
    required this.createdAt,
    required this.category,
    required this.status,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    final uid = _asInt(json['userId'] ?? json['user_id']);
    // Backend tidak join tabel users, jadi nama author diturunkan:
    // pakai field author/username kalau ada, kalau userId cocok dengan
    // sesi saat ini pakai username sesi (default "Setya"), sisanya "User <id>".
    final rawAuthor = (json['author'] ?? json['username']) as String?;
    final author = (rawAuthor != null && rawAuthor.isNotEmpty)
        ? rawAuthor
        : (uid == AuthSession.userId ? AuthSession.username : 'User $uid');
    return Post(
      id: _asInt(json['id']),
      userId: uid,
      title: (json['title'] as String?) ?? '',
      content: (json['content'] as String?) ?? '',
      author: author,
      image: (json['imageUrl'] ?? json['image_url'] ?? json['image']) as String? ?? '',
      createdAt: (json['createdAt'] ?? json['created_at'])?.toString() ?? '',
      category: (json['category'] as String?) ?? '',
      status: (json['status'] as String?) ?? 'published',
    );
  }
}

/// Backend tidak punya tabel categories — endpoint
/// GET /api/v1/categories mengembalikan list statis dari index.ts.
/// Kalau backend mati, kembalikan list statis lokal agar dropdown
/// form (artikel_baru / edit_artikel) tetap bisa dipakai.
Future<List<Category>> getCategories() async {
  const fallback = [
    Category(id: 1, name: 'Teknologi'),
    Category(id: 2, name: 'Desain'),
    Category(id: 3, name: 'Pemrograman'),
  ];
  try {
    final res = await http.get(Uri.parse('$baseUrl/categories'));
    if (res.statusCode != 200) return fallback;
    final decoded = jsonDecode(res.body);
    final List<dynamic> data;
    if (decoded is List) {
      data = decoded;
    } else if (decoded is Map<String, dynamic>) {
      final inner = decoded['data'];
      if (inner is List) {
        data = inner;
      } else if (inner is Map && inner['categories'] is List) {
        data = inner['categories'] as List<dynamic>;
      } else {
        return fallback;
      }
    } else {
      return fallback;
    }
    return data.map((e) => Category.fromJson(e as Map<String, dynamic>)).toList();
  } catch (_) {
    return fallback;
  }
}

List<Post> _parsePostList(String body) {
  final decoded = jsonDecode(body);
  if (decoded is List) {
    return decoded.map((e) => Post.fromJson(e as Map<String, dynamic>)).toList();
  }
  final map = decoded as Map<String, dynamic>;
  final data = map['data'] as Map<String, dynamic>? ?? {};
  final posts = (data['posts'] ?? data['post'] ?? []) as List<dynamic>;
  return posts.map((e) => Post.fromJson(e as Map<String, dynamic>)).toList();
}

Post _parsePost(String body) {
  final decoded = jsonDecode(body) as Map<String, dynamic>;
  final data = decoded['data'] as Map<String, dynamic>?;
  final postJson = (data?['post'] ?? decoded) as Map<String, dynamic>;
  return Post.fromJson(postJson);
}

Future<List<Post>> getPosts() async {
  final res = await http.get(Uri.parse('$baseUrl/posts'));
  if (res.statusCode != 200) {
    throw Exception('Gagal memuat artikel (${res.statusCode})');
  }
  return _parsePostList(res.body);
}

Future<Post> getPostById(int id) async {
  final res = await http.get(Uri.parse('$baseUrl/posts/$id'));
  if (res.statusCode != 200) {
    throw Exception('Gagal memuat artikel (${res.statusCode})');
  }
  return _parsePost(res.body);
}

/// Endpoint: GET /api/v1/users/:userId (butuh login).
Future<List<Post>> getPostsByUserId(int userId, {String? token}) async {
  final t = token ?? AuthSession.token;
  final res = await http.get(
    Uri.parse('$baseUrl/users/$userId'),
    headers: {
      if (t != null && t.isNotEmpty) 'Authorization': 'Bearer $t',
    },
  );
  if (res.statusCode != 200) {
    throw Exception('Gagal memuat artikel user (${res.statusCode})');
  }
  return _parsePostList(res.body);
}

Future<Post> createPost({
  required String title,
  required String content,
  required int categoryId,
  required String author,
  String image = '',
  String status = 'published',
  int? userId,
  String? token,
  String? imagePath,
}) async {
  // categoryId/author dikirim apa adanya; backend menyimpan
  // categoryId sebagai FK ke tabel categories.
  final uid = userId ?? AuthSession.userId;
  final t = token ?? AuthSession.token;
  final authHeader = (t != null && t.isNotEmpty) ? {'Authorization': 'Bearer $t'} : <String, String>{};

  final file = imagePath != null && imagePath.isNotEmpty ? File(imagePath) : null;
  if (file != null && await file.exists()) {
    final req = http.MultipartRequest('POST', Uri.parse('$baseUrl/posts'));
    req.headers.addAll(authHeader);
    req.fields['userId'] = '$uid';
    req.fields['categoryId'] = '$categoryId';
    req.fields['title'] = title;
    req.fields['content'] = content;
    req.files.add(await http.MultipartFile.fromPath('image', file.path));
    final streamed = await req.send();
    final body = await streamed.stream.bytesToString();
    if (streamed.statusCode != 201) {
      throw Exception('Gagal menyimpan artikel (${streamed.statusCode}): ${_serverMessage(body)}');
    }
    return _parsePost(body);
  }

  final res = await http.post(
    Uri.parse('$baseUrl/posts'),
    headers: {...AuthSession.headers(), ...authHeader},
    body: jsonEncode({'userId': uid, 'categoryId': categoryId, 'title': title, 'content': content, 'imageUrl': image}),
  );
  if (res.statusCode != 201) {
    throw Exception('Gagal menyimpan artikel (${res.statusCode}): ${_serverMessage(res.body)}');
  }
  return _parsePost(res.body);
}

Future<Post> updatePost({
  required int id,
  required String title,
  required String content,
  required int categoryId,
  required String author,
  String image = '',
  String status = 'published',
  String? token,
  String? imagePath,
}) async {
  // Backend memakai PATCH /api/v1/posts/:id
  // (title/content/categoryId + file image opsional).
  final t = token ?? AuthSession.token;
  final authHeader = (t != null && t.isNotEmpty) ? {'Authorization': 'Bearer $t'} : <String, String>{};

  final file = imagePath != null && imagePath.isNotEmpty ? File(imagePath) : null;
  if (file != null && await file.exists()) {
    final req = http.MultipartRequest('PATCH', Uri.parse('$baseUrl/posts/$id'));
    req.headers.addAll(authHeader);
    req.fields['title'] = title;
    req.fields['content'] = content;
    req.fields['categoryId'] = '$categoryId';
    req.files.add(await http.MultipartFile.fromPath('image', file.path));
    final streamed = await req.send();
    final body = await streamed.stream.bytesToString();
    if (streamed.statusCode != 200) {
      throw Exception('Gagal mengubah artikel (${streamed.statusCode}): ${_serverMessage(body)}');
    }
    return _parsePost(body);
  }

  final res = await http.patch(
    Uri.parse('$baseUrl/posts/$id'),
    headers: {...AuthSession.headers(), ...authHeader},
    body: jsonEncode({'title': title, 'content': content, 'categoryId': categoryId, 'imageUrl': image}),
  );
  if (res.statusCode != 200) {
    throw Exception('Gagal mengubah artikel (${res.statusCode}): ${_serverMessage(res.body)}');
  }
  return _parsePost(res.body);
}

Future<void> deletePost(int id, {String? token}) async {
  // Backend soft-delete (status -> "delete"), butuh header Bearer.
  final t = token ?? AuthSession.token;
  final res = await http.delete(
    Uri.parse('$baseUrl/posts/$id'),
    headers: {
      if (t != null && t.isNotEmpty) 'Authorization': 'Bearer $t',
    },
  );
  if (res.statusCode != 200 && res.statusCode != 204) {
    throw Exception('Gagal menghapus artikel (${res.statusCode}): ${_serverMessage(res.body)}');
  }
}

// ---------- helper ----------

int _asInt(dynamic v) {
  if (v is int) return v;
  if (v is String) return int.tryParse(v) ?? 0;
  if (v is num) return v.toInt();
  return 0;
}

String _serverMessage(String body) {
  try {
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) {
      final m = (decoded['message'] ?? decoded['error'])?.toString();
      if (m != null && m.isNotEmpty) return m;
    }
    return body.length > 200 ? '${body.substring(0, 200)}...' : body;
  } catch (_) {
    return body.length > 200 ? '${body.substring(0, 200)}...' : body;
  }
}
