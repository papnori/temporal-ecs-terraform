# Local Temporal Server with ngrok 🌐

[![Temporal](https://img.shields.io/badge/Temporal-000000?style=for-the-badge&logo=temporal&logoColor=white)](https://temporal.io/)
[![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white)](https://www.docker.com/)
[![ngrok](https://img.shields.io/badge/ngrok-1F1E37?style=for-the-badge&logo=ngrok&logoColor=white)](https://ngrok.com/)

> **Run a local Temporal server and expose it securely to the internet using ngrok — perfect for development and testing with remote workers.**

This setup allows you to self-host a Temporal server on your local machine while making it accessible to your AWS ECS workers or any remote client. Great for development, testing, and learning without needing Temporal Cloud. 🚀

---

## ✨ What This Does

- 🏗️ **Local Temporal Server** — Full Temporal server running in Docker
- 🌐 **Internet Exposure** — ngrok tunnel makes it accessible from anywhere
- 🔐 **Secure Connection** — Encrypted tunnel via ngrok
- 📊 **Web UI Access** — Temporal Web UI on `localhost:8233`
- 🎯 **gRPC Endpoint** — Temporal server on port `7233` (tunneled via ngrok)

---

## 📋 Prerequisites

Before you begin, ensure you have:

- 🐳 **Docker & Docker Compose** installed ([Get Docker](https://docs.docker.com/get-docker/))
- 🔑 **ngrok account** (free tier works perfectly) — [Sign up here](https://ngrok.com/)
- 🎫 **ngrok authtoken** from your [ngrok dashboard](https://dashboard.ngrok.com/get-started/your-authtoken)

---

## 🚀 Quick Start

### 1. Configure ngrok Authentication

Copy the sample environment file and add your ngrok authtoken:

```bash
cd local-temporal-server
cp .sample_env .env
```

Edit `.env` and replace `your_ngrok_authtoken_here` with your actual ngrok authtoken:

```bash
NGROK_AUTHTOKEN=your_actual_ngrok_authtoken_here
```

> **Note:** Never commit your `.env` file to version control! It's already in `.gitignore`.

### 2. Start the Services

Launch both Temporal and ngrok with a single command:

```bash
docker compose up
```

This will:
- ✅ Start Temporal server on port `7233` (gRPC) and `8233` (Web UI)
- ✅ Start ngrok and create a secure tunnel to port `7233`
- ✅ Display the public ngrok URL in the logs

### 3. Get Your Public URL

Find your ngrok forwarding URL in one of two ways:

**Option A: Attach to the running Ngrok container** to check the logs by running `docker attach  local-temporal-server-ngrok-1`
```bash
$  docker attach  local-temporal-server-ngrok-1
ngrok

Session Status                online                                                                                                                                                                                                                                                                                
Account                       Nora (Plan: Free)                                                                                                                                                                                                                                                                    
Version                       3.30.0                                                                                                                                                                                                                                                                                
Region                        Europe (Frankfurt)                                                                                                                                                                                                                                                                     
Latency                       122ms                                                                                                                                                                                                                                                                                 
Web Interface                 http://0.0.0.0:4040                                                                                                                                                                                                                                                                   
Forwarding                    https://something-something.ngrok-free.app -> http://localhost:7233                                                                                                                                                                                                             
                                                                                                                                                                                                                                                                                                                    
Connections                   ttl     opn     rt1     rt5     p50     p90                                                                                                                                                                                                                                           
                              0       0       0.00    0.00    0.00    0.00        
```

**Option B: Visit the ngrok dashboard**
- Go to [ngrok dashboard](https://dashboard.ngrok.com/cloud-edge/endpoints)
- Find your active endpoint (e.g., `https://something-something.ngrok-free.app`)

### 4. Access Temporal

#### Local Access (Web UI)
Open your browser and visit:
```
http://localhost:8233
```

> [!NOTE]
> Web UI is only accessible from your local machine.

#### Remote Access (Workers/Clients)
Use the ngrok URL as your Temporal server endpoint:


**Configuration for AWS Secrets Manager:**
```json
{
  "TEMPORAL_NAMESPACE": "default",
  "TEMPORAL_SERVER_ENDPOINT": "something-something.ngrok-free.app"
}
```

---

## 📁 Project Structure

```
local-temporal-server/
├── .env                  # Your ngrok authtoken (DO NOT commit!)
├── .sample_env           # Template for .env file
├── docker-compose.yml    # Docker Compose configuration
└── README.md            # This file
```

---

## 🔧 Configuration Details

### Docker Compose Services

**Temporal Server:**
- **Image:** `temporalio/auto-setup:latest`
- **Ports:**
  - `7233` — gRPC endpoint (for workers/clients)
  - `8233` — Web UI
- **Environment:** Default namespace configured
- **Persistence:** SQLite (ephemeral, for development only)

**ngrok:**
- **Image:** `ngrok/ngrok:latest`
- **Function:** Creates secure tunnel to port `7233`
- **Authentication:** Uses `NGROK_AUTHTOKEN` from `.env`
- **URL:** Dynamic, shown in logs and dashboard

---

## 🛠️ Common Tasks

### View Logs

```bash
# All services
docker compose logs -f

# Temporal only
docker compose logs -f temporal

# ngrok only
docker compose logs -f ngrok
```

### Restart Services

```bash
docker compose restart
```

### Stop Services

```bash
docker compose down
```

### Stop and Remove All Data

```bash
docker compose down -v
```

---

## 🔍 Troubleshooting

### ngrok URL Not Appearing

- ✅ Verify your authtoken is correct in `.env`
- ✅ Check ngrok logs: `docker compose logs ngrok`
- ✅ Ensure your ngrok account is active
- ✅ Try restarting: `docker compose restart ngrok`

### Can't Connect to Temporal

- ✅ Verify Temporal is running: `docker compose ps`
- ✅ Check Temporal logs: `docker compose logs temporal`
- ✅ Ensure port `7233` isn't blocked by firewall
- ✅ Test local connection: `telnet localhost 7233`

### Workers Can't Connect via ngrok

- ✅ Verify the ngrok URL is correct (check dashboard)
- ✅ Ensure you're using the correct port from ngrok URL
- ✅ Check your AWS security groups allow outbound connections
- ✅ Verify NAT Gateway routing in your VPC

---

## 💡 Tips & Best Practices

### For Development

- 🎯 **Use this setup for:** Development, testing, proof-of-concepts
- ⚠️ **Don't use for:** Production workloads (use Temporal Cloud or self-hosted in AWS)
- 💾 **Data persistence:** This uses SQLite in-memory — data is lost when containers stop
- 🔄 **Restart policy:** Containers stop when you close Docker Compose

### For Production Testing

If you want persistent data for extended testing:

1. Add a volume to the Temporal service in `docker-compose.yml`:
   ```yaml
   temporal:
     volumes:
       - temporal-data:/etc/temporal
   
   volumes:
     temporal-data:
   ```

2. Configure proper database backend (PostgreSQL recommended)

### Security Considerations

- 🔐 ngrok free tier creates public URLs — anyone with the URL can connect
- 🎫 Consider upgrading to ngrok paid tier for password protection
- 🚫 Never use this setup for sensitive production data
- 🔒 Rotate your ngrok authtoken periodically

---

## 🔗 Integration with Main Project

This local Temporal server integrates seamlessly with the main [temporal-ecs-terraform](../) project:

1. **Start this local server** using the steps above
2. **Get your ngrok URL** from logs or dashboard
3. **Update AWS Secrets Manager** with the ngrok endpoint:
   ```json
   {
     "TEMPORAL_NAMESPACE": "default",
     "TEMPORAL_SERVER_ENDPOINT": "your-ngrok-url.ngrok.io",
     "TEMPORAL_SERVER_PORT": "12345"
   }
   ```
4. **Deploy your ECS workers** — they'll connect to your local Temporal server via the ngrok tunnel

This is perfect for testing infrastructure changes without using Temporal Cloud credits! 💰

---

## 📚 Additional Resources

- [Temporal Documentation](https://docs.temporal.io/)
- [ngrok Documentation](https://ngrok.com/docs)
- [Docker Compose Reference](https://docs.docker.com/compose/)
- [Main Project Guide](../README.md)
- [Full Blog Tutorial](../Archive/my_life_achievement.md)

---

## 🤝 Contributing

Found an issue or have a suggestion? Feel free to open a PR or issue in the [main repository](https://github.com/papnori/temporal-ecs-terraform).

---

## 📧 Questions?

- LinkedIn: [@norapap753](https://www.linkedin.com/in/norapap753/)
- Project: [Skinsight.me](https://skinsight.me/) 💜

---

<div align="center">

**Happy local development! 🚀**

Made with ☕️ and ✨ by Nora

</div>

