import cors from 'cors';
import dotenv from 'dotenv';
import express from 'express';

import authRouter from './routes/auth/auth.route';
import postRouter from './routes/posts/post.route';
import UsersRouter from './routes/users/users.route';
import { db } from './config/db';
import { categoriesTable } from './config/schema';

dotenv.config();

const app = express();
const PORT = Number(process.env.PORT ?? 3000);

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.use('/api/v1/auth', authRouter);
app.use('/api/v1/posts', postRouter);
app.use('/api/v1/users', UsersRouter);

// Kategori dibaca dari tabel categories (PostgreSQL).
// Kalau tabel masih kosong (fresh migrate), isi otomatis
// dengan 6 kategori default sesuai soal agar dropdown Flutter langsung jalan.
const DEFAULT_CATEGORIES = [
  'Teknologi',
  'Desain',
  'Pemrograman',
  'Cerita & Refleksi',
  'Bisnis',
  'Gaya Hidup',
];

app.get('/api/v1/categories', async (_req, res) => {
  try {
    let cats = await db.select().from(categoriesTable);
    if (cats.length === 0) {
      await db
        .insert(categoriesTable)
        .values(DEFAULT_CATEGORIES.map((name) => ({ name })))
        .onConflictDoNothing({ target: categoriesTable.name });
      cats = await db.select().from(categoriesTable);
    }
    res.status(200).json(cats);
  } catch (error) {
    console.error('Get categories error:', error);
    res.status(500).json({ success: false, message: 'Terjadi kesalahan pada server' });
  }
});

app.get('/', (req, res) => {
    res.send("Hello World");
});

app.listen(PORT, () => {
    console.log(`Server running on http://localhost:${PORT}`);
});