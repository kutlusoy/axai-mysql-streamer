
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
  // Enable named placeholders for easier binding:
  // e.g. SELECT * FROM users WHERE id = :userId
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
// Endpoint: POST /run
// ------------------------------------------------------------------
app.post("/run", async (req, res) => {
  const { queryKey, parameters = {} } = req.body;

  if (!queryKey) {
    return res.status(400).json({ error: "`queryKey` is required" });
  }

  try {
    // 1️⃣ Load the SQL text
    const sql = await loadQuery(queryKey);

    // 2️⃣ Execute the query using the pool
    const [rows] = await pool.execute(sql, parameters);

    // 3️⃣ Stream the rows as a JSON array (useful for large results)
    // 3a – set proper headers
    res.setHeader("Content-Type", "application/json");
    // 3b – start array
    res.write("[");
    for (let i = 0; i < rows.length; i++) {
      const chunk = JSON.stringify(rows[i]);
      if (i > 0) res.write(`,${chunk}`);
      else res.write(chunk);
    }
    // 3c – close array
    res.write("]");
    res.end();
  } catch (err) {
    logger.error(err, "Failed to run query");
    res.status(500).json({ error: err.message });
  }
});

// ------------------------------------------------------------------
// Health check (AnythingLLM uses this for service discovery)
// ------------------------------------------------------------------
app.get("/", (req, res) => {
  res.json({ status: "ok", version: "1.0.0" });
});

// ------------------------------------------------------------------
// Start server
// ------------------------------------------------------------------
const PORT = Number(process.env.PORT) || 3000;
app.listen(PORT, () => {
  logger.info(`AxAI MySQL Streamer listening on port ${PORT}`);
});
