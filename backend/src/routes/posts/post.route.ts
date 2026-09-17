import { Router } from "express";
import { uploadSingleImage } from "../../middleware/upload.middleware";
import PostsController from "../../controllers/posts/posts.controller";
import { authenticate } from "../../middleware/auth.middleware";

const router = Router();

// CREATE
router.post("/", authenticate, uploadSingleImage, PostsController.createPost);

// GUEST
router.get('/', PostsController.getPosts);
router.get('/:id', PostsController.getPostById);

// UPDATE (PUT & PATCH sama-sama didukung, penguji bebas pakai yang mana)
router.put('/:id', authenticate, uploadSingleImage, PostsController.updatePost);
router.patch('/:id', authenticate, uploadSingleImage, PostsController.updatePost);

// DELETE
router.delete('/:id',
  authenticate,
  PostsController.deletePost
)

export default router;