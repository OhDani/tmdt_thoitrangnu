// lib/core/config/api.dart
class ApiConfig {
  // nếu chạy trên mobile emulator: dùng IP máy dev hoặc tunnel.
  // ví dụ khi backend chạy local và test trên Android emulator: 10.0.2.2
  static const String BASE_URL = "http://192.168.1.8:3000"; //chỉnh theo môi trường
  // Auth
  static const String AUTH_LOGIN = "/api/auth/login";
  static const String AUTH_REGISTER = "/api/auth/register";
  static const String USER_CHANGE_PASSWORD = "/api/user/change-password";
  static const String AUTH_FORGOT_PASSWORD = "/api/auth/forgot-password"; 
  static const String AUTH_RESET_PASSWORD = "/api/auth/reset-password";   

  // Categories
  static const String CATEGORIES = "/api/category";

  // Products
  static const String PRODUCTS = "/api/products";
  static const String PRODUCT_BY_ID = "/api/products"; // + /:id

  // Vouchers
  static const String VOUCHERS = "/api/voucher";
  static const String APPLY_VOUCHER = "/api/voucher/apply";

  // User
  static const String USER_PROFILE = "/api/user/me";
  static const String USER_UPDATE = "/api/user/update";
  static const String USER_ADDRESS = "/api/user/address";

  // Cart & Orders
  static const String CART = "/api/cart";
  static const String ORDERS = "/api/orders";

  static String cancelOrder(String orderId) => "/api/orders/$orderId/cancel";

  // Wishlist
  static const String WISHLIST = "/api/wishlist";

  // Upload
  static const String UPLOAD = "/api/upload";
  static const String UPLOAD_AVATAR = "/api/upload/avatar";

  // Notification endpoints
  static const String NOTIFICATIONS = '/api/notifications';
  static const String NOTIFICATIONS_UNREAD_COUNT =
      '/api/notifications/unread-count';
  static const String NOTIFICATIONS_READ_ALL = '/api/notifications/read-all';

  static String notificationRead(String id) => '/api/notifications/$id/read';
  static String deleteNotification(String id) => '/api/notifications/$id';

  // Reviews
  static const String REVIEWS = "/api/reviews";
  static const String MY_REVIEWS = "/api/reviews/my-reviews";

  static String productReviews(String productId) =>
      "/api/reviews/product/$productId";
  static String canReview(String productId) =>
      "/api/reviews/can-review/$productId";
  static String updateReview(String reviewId) => "/api/reviews/$reviewId";
  static String deleteReview(String reviewId) => "/api/reviews/$reviewId";

  // PAYMENT ENDPOINTS
  static const String PAYMENT_VNPAY_CREATE = "/api/payment/vnpay/create";
  static const String PAYMENT_VNPAY_CALLBACK = "/api/payment/vnpay/callback";
  static const String PAYMENT_VNPAY_IPN = "/api/payment/vnpay/ipn";
  
  static String paymentInfo(String paymentId) => "/api/payment/$paymentId";

  // THÊM MỚI - PAYMENT INTENT
  static const String PAYMENT_INTENT_CREATE = "/api/payment/intent/create";
  static String paymentIntent(String id) => "/api/payment/intent/$id";
  static String cancelPaymentIntent(String id) => "/api/payment/intent/$id/cancel";

  static const String PAYMENT_INTENT_PENDING_PAID = "/api/payment/intent/pending-paid";
  // THÊM MỚI - ORDER FROM INTENT
  static const String ORDERS_FROM_INTENT = "/api/orders/create-from-intent";

  // AI Image Search
  static const String SEARCH_BY_IMAGE = "/api/products/search-by-image";

}
