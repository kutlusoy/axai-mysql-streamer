# AxAI MySQL Streamer  

**Author:** Ali Kutlusoy – <https://axai.at>  

A lightweight **AnythingLLM Custom Skill** that lets your LLM run pre‑defined MySQL queries and stream the results back as plain‑text or JSON. The skill is containerised, configurable via environment variables, and can be deployed **as a separate service** or **inside the same container** that runs AnythingLLM.

---  

## 🎯 What It Does  

| Feature | Description |
| ------- | ----------- |
| **Pre‑defined queries** | Store SQL files in `queries/`. Each file becomes a selectable action in the LLM. |
| **Dynamic DB connection** | Host, user, password, and database are supplied via `.env` – no code changes needed. |
| **Streaming results** | Large result sets are streamed line‑by‑line to the LLM, avoiding memory bloat. |
| **JSON or plain‑text output** | Choose `outputFormat=json` or `outputFormat=text` per query. |
| **Dockerised** | Runs in a minimal Node 20 Alpine image (≈30 MB). |
| **Extensible** | Add a new `.sql` file → no restart required. |

---  

## 📦 Quick Start (Docker – separate container)

```bash
# 1️⃣ Clone the repo
git clone https://github.com/your‑org/axai-mysql-streamer.git
cd axai-mysql-streamer

# 2️⃣ Copy the sample env file and edit the values
cp .env.example .env
#   Edit .env → set DB_HOST, DB_PORT, DB_USER, DB_PASSWORD, DB_NAME, etc.

# 3️⃣ Build & run the container
docker compose up -d   # (or docker build & docker run, see INSTALL.md)

# 4️⃣ Verify the service is alive
curl http://localhost:3000/health
# → {"status":"ok","version":"1.0.0"}

# 🛠️ How to Use It Inside AnythingLLM
1. Open AnythingLLM → Settings → Custom Skills.
2. Click “Add New Skill”.
3. Manifest URL – http://<host-or-ip>:3000/skill-manifest.json If you run the skill in the same container, use http://host.docker.internal:3000/skill-manifest.json.
4. Endpoint URL – http://<host-or-ip>:3000/run (same rule as above).
5. Click Save. The skill appears in the “Available Skills” list.

Now you can call the skill from any chat, e.g.:

```
/run AxAI MySQL Streamer GetAllCustomers
```

The LLM will send the request, the skill streams the rows back, and the model can continue the conversation with the data.

# 🔧 Extending the Skill
1. Add a new SQL file to queries/ (e.g., GetTopProducts.sql).
2. (Optional) Add a description in the file’s first comment line – this will be shown in the skill’s UI.
3. Reload the manifest in AnythingLLM (Settings → Custom Skills → Reload).
4. The new action is instantly available – no container rebuild needed.

# 🛡️ Security & Best Practices
| Recommendation | Why |
| ------- | ----------- |
|ever store production credentials in the repo – keep them only in .env or Docker secrets.||
|Use a dedicated MySQL user with only SELECT privileges for the tables you need.||
|Restrict network access – expose port 3000 only to the host or internal Docker network.||
|Enable TLS on your MySQL server and set DB_SSL=true if needed.||
|Limit query runtime – add max_execution_time in MySQL or enforce a timeout in the Node wrapper.||
| ------- | ----------- |

# 📜 License
MIT License – feel free to fork, adapt, and contribute back!

# 🙏 Acknowledgements
Thanks to the AnythingLLM community for providing the custom‑skill framework and to the open‑source ecosystem that makes building lightweight data bridges possible.