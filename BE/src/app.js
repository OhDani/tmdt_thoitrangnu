import express from "express";
import cors from "cors";
import cookieParser from "cookie-parser";

// import routes
import authRoutes from "./routes/auth.routes.js";
import userRoutes from "./routes/user.routes.js";
import categoryRoutes from "./routes/category.routes.js";
import productRoutes from "./routes/product.routes.js";
import uploadRoutes from "./routes/upload.routes.js";
import cartRoutes from "./routes/cart.routes.js";
import orderRoutes from "./routes/order.routes.js";
import reviewRoutes from "./routes/review.routes.js";
import errorHandler from "./middlewares/error.middleware.js";
import adminRoutes from "./routes/admin.routes.js";
import wishlistRoutes from "./routes/wishlist.routes.js";
import voucherRoutes from "./routes/voucher.routes.js";
import notificationRoutes from "./routes/notification.routes.js";
import adminUserRoutes from "./routes/admin_users.routes.js";
import paymentRoutes from "./routes/payment.routes.js";
import paymentIntentRoutes from "./routes/payment_intent.routes.js";
import imageSearchRoutes from "./routes/imageSearch.routes.js";

const app = express();

// middleware
app.use(cors());
app.use(express.json());
app.use(cookieParser());
app.use(errorHandler);
// test endpoint
app.get("/", (req, res) => {
  res.json({ message: "API is running!" });
});

// ROUTES
app.use("/api/auth", authRoutes);
app.use("/api/user", userRoutes);
app.use("/api/category", categoryRoutes);
app.use("/api/products", productRoutes);
app.use("/api/upload", uploadRoutes);
app.use("/api/cart", cartRoutes);
app.use("/api/orders", orderRoutes);
app.use("/api/reviews", reviewRoutes);
app.use("/api/admin", adminRoutes);
app.use("/api/admin", adminUserRoutes);     // route quản lý user mới
app.use("/api/wishlist", wishlistRoutes);
app.use("/api/voucher", voucherRoutes);
app.use("/api/notifications", notificationRoutes);
app.use("/api/payment", paymentRoutes);
app.use("/api/payment/intent", paymentIntentRoutes);
app.use("/api/products", imageSearchRoutes);

export default app;
