import express from "express";
import { upload } from "../middlewares/upload.middleware.js";
import { searchByImage } from "../controllers/imageSearch.controller.js";

const router = express.Router();

// Public — không cần đăng nhập
// POST /api/products/search-by-image
router.post("/search-by-image", upload.single("image"), searchByImage);

export default router;
