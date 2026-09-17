# InkBlog - ATS MAPIL

Platform blog mobile untuk artikel Teknologi, Desain, dan Pemrograman.
Tugas Assessment Sumatif Tengah Semester (ATS) MAPIL XI RPL - SMK Taruna Bhakti.

Stack: Flutter (frontend) + Express.js `/api/v1` (backend) + PostgreSQL `db_blog_app`.

## Struktur repo

- `lib/` - Flutter: `main.dart` (Beranda + Detail), `api.dart` (REST `getPosts/getCategories/createPost/updatePost/deletePost/login/register`), `jelajah.dart`, `artikel_saya.dart`, `artikel_baru.dart`, `edit_artikel.dart`, `profile.dart`, `shared.dart`
- `backend/` - Express: `src/index.ts` (`/api/v1/auth, /posts, /users, /categories`), Drizzle + `pg`, Cloudinary upload
- `backend/.env.example` - contoh env (DB + JWT + Cloudinary). Jangan push `.env` asli.
- `assets/image/` - cover artikel + foto profil

## Cara jalan

Frontend:
```powershell
flutter pub get
flutter run
```

Backend:
```powershell
cd backend
npm install
npm run dev
```

API: `http://localhost:3000/api/v1`

## Branching

- `main` - stabil siap dinilai
- `develop` - integrasi fitur
- `feature/frontend-ui` - UI Beranda, Jelajah, Profil
- `feature/backend-api` - integrasi Express
- `feature/crud-posts` - tambah, edit, hapus artikel
- `feature/database` - tabel `users, categories, posts, comments`
