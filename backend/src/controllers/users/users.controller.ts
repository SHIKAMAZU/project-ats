import { Request, Response } from "express";
import {
  userIdSchema,
  userPostParamsSchema,
} from "../../validations/posts.validation";
import { categoriesTable, postsTable } from "../../config/schema";
import { and, desc, eq } from "drizzle-orm";
import { db } from "../../config/db";

export class UsersController {
  // USER : Get All data(posts)
  getPostsByUserId = async (req: Request, res: Response) => {
    try {
      const validatedParams = userIdSchema.parse(req.params);

      const { userId } = validatedParams;

      const rows = await db
        .select({ post: postsTable, category: categoriesTable.name })
        .from(postsTable)
        .leftJoin(categoriesTable, eq(postsTable.categoryId, categoriesTable.id))
        .where(
          and(
            eq(postsTable.userId, userId),
            eq(postsTable.status, "published"),
          ),
        )
        .orderBy(desc(postsTable.createdAt));

      const posts = rows.map((r) => ({ ...r.post, category: r.category ?? '' }));

      return res.status(200).json({
        success: true,
        message: "User posts retrieved successfully",
        data: {
          posts,
        },
      });
    } catch (error: any) {
      console.error("Get posts by user ID error:", error);

      return res.status(500).json({
        success: false,
        message: "Internal server error",
        error: error.message,
      });
    }
  };

  // USER : Get post by Id
  getUserPost = async (req: Request, res: Response) => {
    try {
      const validatedParams = userPostParamsSchema.parse(req.params);
      const { userId, postId } = validatedParams;

      const [post] = await db
        .select()
        .from(postsTable)
        .where(
          and(
            eq(postsTable.id, postId),
            eq(postsTable.userId, userId),
            eq(postsTable.status, "published"),
          ),
        );

      if (!post) {
        return res.status(404).json({
          success: false,
          message: "Post not found",
        });
      }

      return res.status(200).json({
        success: true,
        message: "Post retrieved successfully",
        data: {
          post,
        },
      });
    } catch (error: any) {
      console.error("Get user post error:", error);

      return res.status(500).json({
        success: false,
        message: "Internal server error",
        error: error.message,
      });
    }
  };
}

export default new UsersController();
