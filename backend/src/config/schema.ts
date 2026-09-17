import { pgTable, pgEnum, serial, integer, varchar, text, timestamp } from "drizzle-orm/pg-core";

export const USER_ROLES = ["user", "admin"] as const;
export const userRoleEnum = pgEnum("user_role", USER_ROLES);

export const POST_STATUS = ["delete", "published"] as const;
export const postStatusEnum = pgEnum("post_status", POST_STATUS);


// USERS
export const usersTable = pgTable("users", {
  id: serial("id").primaryKey(),
  username: varchar("username", { length: 50 }).notNull(),
  email: varchar("email", { length: 100 }).notNull().unique(),
  password: varchar("password", { length: 255 }).notNull(),
  role: userRoleEnum("role").notNull().default("user"),
  createdAt: timestamp("created_at").defaultNow(),
  updatedAt: timestamp("updated_at").defaultNow(),
});


// CATEGORIES
export const categoriesTable = pgTable("categories", {
  id: serial("id").primaryKey(),
  name: varchar("name", { length: 100 }).notNull().unique(),
});


// POSTS
export const postsTable = pgTable("posts", {
  id: serial("id").primaryKey(),
  userId: integer("user_id").notNull().references(() => usersTable.id, { onDelete: "cascade" }),
  categoryId: integer("category_id").references(() => categoriesTable.id, { onDelete: "set null" }),
  title: varchar("title", { length: 255 }).notNull(),
  content: text("content").notNull(),
  imageUrl: text("image_url"), // Kolom untuk simpan URL gambar
  imagePublicId: varchar("image_public_id", { length: 255 }), // Kolom untuk simpan Public ID Cloudinary
  status: postStatusEnum("status").notNull().default("published"),
  createdAt: timestamp("created_at").defaultNow(),
  updatedAt: timestamp("updated_at").defaultNow(),
});


// COMMENTS
export const commentsTable = pgTable("comments", {
  id: serial("id").primaryKey(),
  postId: integer("post_id").notNull().references(() => postsTable.id, { onDelete: "cascade" }),
  userId: integer("user_id").notNull().references(() => usersTable.id, { onDelete: "cascade" }),
  comment: text("comment").notNull(),
  createdAt: timestamp("created_at").defaultNow(),
  updatedAt: timestamp("updated_at").defaultNow(),
});
