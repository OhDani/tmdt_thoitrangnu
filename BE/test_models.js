import fs from 'fs';
import dotenv from 'dotenv';
dotenv.config();

async function run() {
  const res = await fetch('https://generativelanguage.googleapis.com/v1beta/models?key=' + process.env.GEMINI_API_KEY);
  const data = await res.json();
  fs.writeFileSync('models.json', JSON.stringify(data, null, 2));
}
run();
