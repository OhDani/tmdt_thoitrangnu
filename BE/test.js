import { GoogleGenerativeAI } from "@google/generative-ai";
import dotenv from "dotenv";
dotenv.config();

console.log("Testing with key:", process.env.GEMINI_API_KEY.substring(0, 10) + "...");

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
const model = genAI.getGenerativeModel({ model: "gemini-2.5-flash" });

async function run() {
  try {
    console.log("Calling model...");
    const result = await model.generateContent("Hello");
    console.log("SUCCESS:", result.response.text());
  } catch (error) {
    console.error("ERROR FULL:", error);
  }
}
run();
