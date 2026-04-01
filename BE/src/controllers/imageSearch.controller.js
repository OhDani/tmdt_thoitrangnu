import { GoogleGenerativeAI } from "@google/generative-ai";
import Product from "../models/Product.js";
import dotenv from "dotenv";
dotenv.config();

// Log để debug (xóa sau khi verify)
console.log("🔑 GEMINI_API_KEY:", process.env.GEMINI_API_KEY ? "OK (" + process.env.GEMINI_API_KEY.slice(0, 8) + "...)" : "❌ MISSING");

// Khởi tạo Gemini AI
const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

// POST /api/products/search-by-image
export const searchByImage = async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ message: "Vui lòng gửi ảnh để tìm kiếm" });
    }

    console.log("📸 Received image:", req.file.originalname, req.file.mimetype, req.file.size, "bytes");

    // ---- BƯỚC 1: Lấy danh sách sản phẩm từ DB ----
    const allProducts = await Product.find()
      .populate("category", "name slug")
      .select("_id name description category");

    if (allProducts.length === 0) {
      return res.json({
        analysis: "Không tìm thấy sản phẩm nào trong cửa hàng.",
        products: [],
      });
    }

    // Tạo context text gửi cho AI
    const productContext = allProducts
      .map(
        (p) =>
          `ID: ${p._id} | Tên: ${p.name} | Danh mục: ${p.category?.name || "Chưa phân loại"} | Mô tả: ${p.description || "Không có mô tả"}`
      )
      .join("\n");

    // ---- BƯỚC 2: Gọi Gemini Vision - dùng thẳng buffer từ multer ----
    const model = genAI.getGenerativeModel({ model: "gemini-2.5-flash" });

    const prompt = `
Bạn là AI chuyên gia thời trang nữ. Hãy phân tích hình ảnh và tìm sản phẩm phù hợp nhất.

DANH SÁCH SẢN PHẨM HIỆN CÓ:
${productContext}

NHIỆM VỤ:
1. Phân tích loại trang phục trong ảnh (váy, áo, quần, đầm, v.v.)
2. Nhận diện màu sắc chủ đạo
3. Nhận diện phong cách (công sở, dạo phố, dự tiệc, thể thao, v.v.)
4. Chọn TỐI ĐA 6 sản phẩm phù hợp nhất từ danh sách đã cung cấp

LƯU Ý QUAN TRỌNG:
- Chỉ chọn ID từ danh sách đã cung cấp ở trên, tuyệt đối không tự tạo ID mới
- Nếu không tìm được sản phẩm phù hợp, trả về mảng rỗng cho matchedProductIds
- Trả về ĐÚNG định dạng JSON bên dưới, không thêm markdown hay giải thích

ĐỊNH DẠNG JSON CẦN TRẢ VỀ:
{
  "analysis": "Mô tả ngắn gọn về trang phục trong ảnh (ví dụ: Váy midi màu đỏ, phong cách dự tiệc)",
  "matchedProductIds": ["id1", "id2", "id3"]
}
`;

    // Dùng thẳng buffer từ multer, không cần upload Cloudinary hay fetch lại
    const imageBase64 = req.file.buffer.toString("base64");

    console.log("🤖 Calling Gemini...");
    const result = await model.generateContent([
      prompt,
      {
        inlineData: {
          data: imageBase64,
          mimeType: req.file.mimetype,
        },
      },
    ]);

    const rawText = result.response.text().trim();
    console.log("🤖 Gemini raw response:", rawText);

    // ---- BƯỚC 3: Parse JSON từ Gemini ----
    let geminiResult;
    try {
      // Loại bỏ markdown code block nếu Gemini trả về kèm
      const cleaned = rawText
        .replace(/```json\s*/gi, "")
        .replace(/```\s*/gi, "")
        .trim();
      geminiResult = JSON.parse(cleaned);
    } catch (parseError) {
      console.error("❌ Parse Gemini response error:", rawText);
      return res.status(500).json({
        message: "AI không thể xử lý ảnh này. Vui lòng thử ảnh khác.",
      });
    }

    // ---- BƯỚC 4: Lấy sản phẩm từ DB theo ID Gemini trả về ----
    const matchedIds = geminiResult.matchedProductIds || [];
    let matchedProducts = [];

    if (matchedIds.length > 0) {
      matchedProducts = await Product.find({
        _id: { $in: matchedIds },
      }).populate("category", "name slug");
    }

    console.log(`✅ Found ${matchedProducts.length} matching products`);

    return res.json({
      analysis: geminiResult.analysis || "Đã phân tích ảnh thành công",
      products: matchedProducts,
    });
  } catch (err) {
    console.error("❌ Image search error details:", err.message);
    console.error("❌ Full error:", err);
    return res.status(500).json({ message: err.message });
  }
};
