import z from "zod";

export const createPostSchema = z.object({
  userId: z.coerce.number().int().positive(),

  categoryId: z.coerce.number().int().positive().optional(),

  imageUrl: z.string().max(500).optional(),

  title: z
    .string()
    .min(3, "Title minimal 3 karakter")
    .max(255, "Title maksimal 255 karakter"),

  content: z
    .string()
    .min(10, "Content minimal 10 karakter"),
});

export const postIdSchema = z.object({
  id: z.coerce.number().int().positive(),
});

export const userIdSchema = z.object({
  userId: z.coerce.number().int().positive(),
});

export const userPostParamsSchema = z.object({
  userId: z.coerce.number().int().positive(),
  postId: z.coerce.number().int().positive(),
});



export const updatePostParamsSchema = z.object({
  id: z.coerce.number().int().positive(),
});

export const updatePostSchema = z.object({
  categoryId: z.coerce.number().int().positive().optional(),

  imageUrl: z.string().max(500).optional(),

  title: z
    .string()
    .min(3, "Title minimal 3 karakter")
    .max(255, "Title maksimal 255 karakter")
    .optional(),

  content: z
    .string()
    .min(10, "Content minimal 10 karakter")
    .optional(),
});