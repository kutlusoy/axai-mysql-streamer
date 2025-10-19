// ──────────────────────────────────────────────────────────────
// AxAI MySQL Streamer – AnythingLLM Custom Skill
// Author: Ali Kutlusoy (https://axai.at)
// ──────────────────────────────────────────────────────────────

import express from "express";
import mysql from "mysql2/promise";
import fs from "node:fs/promises";
import path from "node:path";
import dotenv from "dotenv";
import pino from "pino";
import pinoHttp from "pino-http";

// Load .env (runtime configuration)
dotenv.config();

const logger = pino({ level: process.env.LOG_LEVEL || "info" });
const httpLogger = pinoHttp({ logger });

const app = express();
app.use(express.json());
app.use(httpLogger);

// ------------------------------------------------------------------
// MySQL connection pool – created once at start‑up
// ------------------------------------------------------------------
const pool = mysql.createPool({
  host: process.env.MYSQL_HOST,
  port: Number(process.env.MYSQL_PORT) || 3306,
  user: process.env.MYSQL_USER,
  password: process.env.MYSQL_PASSWORD,
  database: process.env.MYSQL_DATABASE,
  waitForConnections: true,
  connectionLimit: 50,
  queueLimit: 0,
  namedPlaceholders: true,
});

// ------------------------------------------------------------------
// Helper: load a SQL file and extract its queryKey (first comment)
// ------------------------------------------------------------------
async function loadQuery(queryKey) {
  const queriesPath = path.resolve("src", "queries");
  const files = await fs.readdir(queriesPath);

  for (const file of files) {
    if (!file.endsWith(".sql")) continue;
    const fullPath = path.join(queriesPath, file);
    const content = await fs.readFile(fullPath, "utf8");
    const firstLine = content.split("\n")[0].trim();

    // Expected format: -- queryKey: <key>
    const match = firstLine.match(/^--\s*queryKey\s*:\s*(\S+)$/i);
    if (match && match[1] === queryKey) {
      return content; // entire SQL (including placeholders)
    }
  }

  throw new Error(`Query with key "${queryKey}" not found in src/queries`);
}

// ------------------------------------------------------------------
// Helper: Parse German date formats to YYYY-MM-DD and handle time ranges
// ------------------------------------------------------------------
function parseDate(input, isEndDate = false) {
  if (!input) return null;

  // Remove any existing time components
  let dateStr = input.split(' ')[0];
  
  // Format: DD.MM.YYYY
  if (dateStr.match(/^\d{1,2}\.\d{1,2}\.\d{4}$/)) {
    const [day, month, year] = dateStr.split('.');
    dateStr = `${year}-${month.padStart(2, '0')}-${day.padStart(2, '0')}`;
  }

  // Format: YYYY-MM
  if (dateStr.match(/^\d{4}-\d{2}$/)) {
    if (isEndDate) {
      return `${dateStr}-31`; // Let MySQL handle month end
    }
    return `${dateStr}-01`;
  }

  // Format: YYYY-MM-DD (already correct)
  if (dateStr.match(/^\d{4}-\d{2}-\d{2}$/)) {
    // Already in correct format
  } else {
    // Try to parse other formats
    const date = new Date(dateStr);
    if (!isNaN(date.getTime())) {
      const year = date.getFullYear();
      const month = String(date.getMonth() + 1).padStart(2, '0');
      const day = String(date.getDate()).padStart(2, '0');
      dateStr = `${year}-${month}-${day}`;
    }
  }

  // Add time component for proper datetime comparison
  if (isEndDate) {
    return `${dateStr} 23:59:59`;
  } else {
    return `${dateStr} 00:00:00`;
  }
}

// ------------------------------------------------------------------
// Helper: Split customer name into words for search
// ------------------------------------------------------------------
function splitCustomerName(name) {
  if (!name) return { word1: null, word2: null, word3: null, word4: null };

  const words = name.trim().split(/\s+/);
  return {
    word1: words[0] || null,
    word2: words[1] || null,
    word3: words[2] || null,
    word4: words[3] || null,
  };
}

// ------------------------------------------------------------------
// Endpoint: GET / (Health Check)
// ------------------------------------------------------------------
app.get("/", (req, res) => {
  res.json({ status: "ok", version: "1.0.0" });
});

// ------------------------------------------------------------------
// Endpoint: GET /skill-manifest.json (used by AnythingLLM)
// ------------------------------------------------------------------
app.get("/skill-manifest.json", (req, res) => {
  res.sendFile(path.resolve("skill-manifest.json"));
});

// ------------------------------------------------------------------
// Endpoint: POST /run
// ------------------------------------------------------------------
app.post("/run", async (req, res) => {
  let { queryKey, parameters = {} } = req.body;

  if (!queryKey) {
    return res.status(400).json({ error: "`queryKey` is required" });
  }

  try {
    // 1️⃣ Load the SQL text
    const sql = await loadQuery(queryKey);

    // 2️⃣ Handle date conversion with proper time ranges
    if (parameters.start_date) {
      parameters.start_date = parseDate(parameters.start_date, false);
    }
    if (parameters.end_date) {
      parameters.end_date = parseDate(parameters.end_date, true);
    }

    // 3️⃣ Set default dates to current year if not provided
    const currentYear = new Date().getFullYear();
    if (!parameters.start_date) {
      parameters.start_date = `${currentYear}-01-01 00:00:00`;
    }
    if (!parameters.end_date) {
      parameters.end_date = `${currentYear}-12-31 23:59:59`;
    }

    // 4️⃣ Handle customer name splitting
    if (parameters.Kundenname) {
      const words = splitCustomerName(parameters.Kundenname);
      parameters = { ...parameters, ...words };
    }

    // 5️⃣ Execute the query using the pool
    const [rows] = await pool.execute(sql, parameters);

    // 6️⃣ Stream the rows as a JSON array
    res.setHeader("Content-Type", "application/json");
    res.write("[");
    for (let i = 0; i < rows.length; i++) {
      const chunk = JSON.stringify(rows[i]);
      if (i > 0) res.write(`,${chunk}`);
      else res.write(chunk);
    }
    res.write("]");
    res.end();
  } catch (err) {
    logger.error(err, "Failed to run query");
    res.status(500).json({ error: err.message });
  }
});

// ------------------------------------------------------------------
// Start server
// ------------------------------------------------------------------
const PORT = Number(process.env.PORT) || 3000;
app.listen(PORT, () => {
  logger.info(`AxAI MySQL Streamer listening on port ${PORT}`);
});
