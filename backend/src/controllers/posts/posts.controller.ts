import { Request, Response } from "express";
import {
  createPostSchema,
  postIdSchema,
  updatePostParamsSchema,
  updatePostSchema,
} from "../../validations/posts.validation";
import { db } from "../../config/db";
import { categoriesTable, postsTable } from "../../config/schema";
import { and, desc, eq } from "drizzle-orm";
import { deleteFromCloudinary, uploadToCloudinary } from "../../services/cloudinary.service";

export class PostsController {
  createPost = async (req: Request, res: Response) => {
    try {
      const validatedData = createPostSchema.parse(req.body);
      const { userId, title, content, categoryId, imageUrl: bodyImageUrl } = validatedData;

      let imageUrl: string | undefined = bodyImageUrl;
      let imagePublicId: string | undefined;

      if (req.file) {
        const uploadResult = await uploadToCloudinary(req.file.buffer);
        imageUrl = uploadResult.secure_url;
        imagePublicId = uploadResult.public_id;
      }

      const [insertedPost] = await db
        .insert(postsTable)
        .values({ userId, categoryId, title, content, imageUrl, imagePublicId })
        .returning({ id: postsTable.id });

      const newPost = await db.query.postsTable.findFirst({
        where: eq(postsTable.id, insertedPost.id),
      });

      return res.status(201).json({
        success: true,
        message: "Post created successfully",
        data: { post: newPost },
      });
    } catch (error) {
      console.error("Create post error:", error);
      return res.status(500).json({
        success: false,
        message: "Terjadi kesalahan pada server",
        error: error instanceof Error ? error.message : error,
      });
    }
  };

  // GUEST : Get Posts
  getPosts = async (req: Request, res: Response) => {
    try {
      const rows = await db
        .select({ post: postsTable, category: categoriesTable.name })
        .from(postsTable)
        .leftJoin(categoriesTable, eq(postsTable.categoryId, categoriesTable.id))
        .where(eq(postsTable.status, "published"))
        .orderBy(desc(postsTable.createdAt));

      const posts = rows.map((r) => ({ ...r.post, category: r.category ?? '' }));

      return res.status(200).json({
        success: true,
        message: "Get Posts Successfully",
        data: { posts },
      });
    } catch (error) {
      console.error("Get posts error:", error);
      return res.status(500).json({
        success: false,
        message: "Terjadi kesalahan pada server",
        error: error instanceof Error ? error.message : error,
      });
    }
  };

  // GUEST : Get Post By ID
  getPostById = async (req: Request, res: Response) => {
    try {
      const validatedParams = postIdSchema.parse(req.params);
      const { id } = validatedParams;

      const [row] = await db
        .select({ post: postsTable, category: categoriesTable.name })
        .from(postsTable)
        .leftJoin(categoriesTable, eq(postsTable.categoryId, categoriesTable.id))
        .where(and(eq(postsTable.id, id), eq(postsTable.status, "published")));

      if (!row) {
        return res.status(404).json({
          success: false,
          message: "Post Not Found",
        });
      }

      const post = { ...row.post, category: row.category ?? '' };

      return res.status(200).json({
        success: true,
        message: "Post retrieved successfully",
        data: { post },
      });
    } catch (error) {
      console.error("Get post by id error:", error);
      return res.status(500).json({
        success: false,
        message: "Terjadi kesalahan pada server",
        error: error instanceof Error ? error.message : error,
      });
    }
  };

  // UPDATE
  updatePost = async (req: Request, res: Response) => {
    try {
      // 1. VALIDATE PARAMS
      const validatedParams = updatePostParamsSchema.parse(req.params);
      const { id } = validatedParams;

      // 2. VALIDATE BODY
      const validatedData = updatePostSchema.parse(req.body);
      const { title, content, categoryId, imageUrl: bodyImageUrl } = validatedData;

      // 3. CEK POST
      const [existingPost] = await db
        .select()
        .from(postsTable)
        .where(eq(postsTable.id, id));

      if (!existingPost) {
        return res.status(404).json({
          success: false,
          message: "Post not found",
        });
      }

      // 4. SIAPKAN DATA UPDATE (sampul dari app menimpa kalau dikirim)
      let imageUrl = bodyImageUrl ?? existingPost.imageUrl;
      let imagePublicId = existingPost.imagePublicId;

      // 5. JIKA ADA IMAGE BARU
      if (req.file) {
        const uploadResult = await uploadToCloudinary(req.file.buffer);
        imageUrl = uploadResult.secure_url;
        imagePublicId = uploadResult.public_id;

        // HAPUS IMAGE LAMA
        if (existingPost.imagePublicId) {
          await deleteFromCloudinary(existingPost.imagePublicId);
        }
      }

      // 6. UPDATE DATABASE
      await db
        .update(postsTable)
        .set({
          ...(title !== undefined && { title }),
          ...(content !== undefined && { content }),
          ...(categoryId !== undefined && { categoryId }),
          ...((req.file || bodyImageUrl !== undefined) && { imageUrl, imagePublicId }),
        })
        .where(eq(postsTable.id, id));

      // 7. AMBIL DATA TERBARU
      const [updatedPost] = await db
        .select()
        .from(postsTable)
        .where(eq(postsTable.id, id));

      // 8. RESPONSE
      return res.status(200).json({
        success: true,
        message: "Post updated successfully",
        data: { post: updatedPost },
      });
    } catch (error: any) {
      console.error("Update post error:", error);
      return res.status(500).json({
        success: false,
        message: "Internal server error",
        error: error.message,
      });
    }
  };

  // DELETE
  deletePost = async (req: Request, res: Response) => {
    try {
      const validatedParams = postIdSchema.parse(req.params);
      const { id } = validatedParams;

      const existingPost = await db.query.postsTable.findFirst({
        where: eq(postsTable.id, id),
      });

      if (!existingPost) {
        return res.status(404).json({
          success: false,
          message: "Post not found",
        });
      }

      await db.update(postsTable).set({ status: "delete" }).where(eq(postsTable.id, id));

      return res.status(200).json({
        success: true,
        message: "Post deleted successfully",
      });
    } catch (error: any) {
      console.error("Delete post error:", error);
      return res.status(500).json({
        success: false,
        message: "Internal server error",
        error: error.message,
      });
    }
  };
}

export default new PostsController();