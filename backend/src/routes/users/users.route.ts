import { Router } from "express";
import UsersController from "../../controllers/users/users.controller";
import { authenticate } from "../../middleware/auth.middleware";

const router = Router();

// User : Get all data(posts)
router.get('/:userId', authenticate, UsersController.getPostsByUserId);

// User : Get data by Id
router.get('/:userId/posts/:postId', authenticate, UsersController.getUserPost);

export default router;