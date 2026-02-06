# 📚 Media Server Setup

This repository contains all scripts, configurations, and Docker Compose files to set up a complete **home media server** with:

- Radarr (Movies)
- Sonarr (TV Shows)
- Prowlarr (Indexers)
- Jellyfin (Media Server)
- Jellyseerr (Requests)
- Homarr (Dashboard)
- Bazarr (Subtitles)
- Maintainerr (Cleanup / Quality Enforcement)
- Recyclarr (Standardize formats)
- qBittorrent (Torrent client)

---

## 🖥️ System & User Configuration

- **Recommended OS:** Linux Mint XFCE Edition
- **Username:** `media` (used for auto-login and Docker permissions)
- **Hostname:** `mediaserver` (used for mDNS / internal URLs)

---

## 📝 Scripts Overview

All scripts are located in the `scripts/` folder. Before running, make them executable:

```bash
sudo chmod +x scripts/*
```

### 1. `arr1-folders-and-docker.sh`

- Creates the folder structure for torrents and media
- Ensures directories have proper permissions based on your `.env` (`PUID` / `PGID`).
- Installs Docker Engine, CLI, and Docker Compose plugin.
- Adds user `media` to the `docker` group so you can run Docker commands **without `sudo`**.
- Starts Docker service on boot.
- You will need to `logout` or `reboot` after


### 2. `docker compose up -d`

Once folders are created and Docker is installed, go to the folder containing the compose file and run:

```bash
docker compose up -d
```

- This will start all services in detached mode.
- The first startup may take a few minutes while containers initialize.

### 3. `arr2-xfce-firefox-kiosk.sh` or `arr2-xfce-chromium-kiosk.sh`

- Choose either browser to run in kiosk mode. Not both


## ✅ First-Boot ARR Checklist (based on TRaSH-Guides)

### 🔹 Step 1 – Set authentication (optional but smart)

- Set a password for:
    - qBittorrent (get the temp password with cmd `docker log qbittorrent`
    - Radarr
    - Sonarr
    - Readarr
    - Prowlarr
    - Jellyseerr

---

### 🔹 Step 2 – Configure qBittorrent

1. Open qBittorrent
2. Create categories:
    - `movies` → `/data/torrents/movies`
    - `tv` → `/data/torrents/tv`
    - `books` → `/data/torrents/books`
3. Disable:
    - “Create subfolder for torrents with multiple files” (TRaSH recommends off)

---

### 🔹 Step 3 – Configure Prowlarr

1. Add indexers **only here**
2. Settings → Apps → Add:
    - Radarr → `http://radarr:7878`
    - Sonarr → `http://sonarr:8989`
    - Readarr → `http://readarr:8787`
3. Sync indexers to all ARR apps

---

### 🔹 Step 4 – Configure ARR apps

In **Radarr / Sonarr / Readarr**:

- **Media Management**
    - Enable **Hardlinks**
    - Disable “Copy files instead of moving”
- **Root folders**
    - Radarr → `/movies`
    - Sonarr → `/tv`
    - Readarr → `/books`
- **Download Clients**
    - Add qBittorrent
    - Host: `qbittorrent`
    - Category: `movies` / `tv` / `books`

---

### 🔹 Step 5 – Add Recyclarr (if enabled)

- Configure Recyclarr config file if necessary
- Run once to sync profiles
- Verify profiles appear in ARR apps

Recyclarr is used to **automatically manage quality profiles, custom formats, and scoring** in Radarr and Sonarr using the TRaSH-Guides best practices.

### 1️⃣ Copy the configuration file

Copy the provided `recyclarr.yml` file into the Recyclarr config directory:

```
cp recyclarr.yml config/recyclarr/recyclarr.yml
```

Edit the file and replace the following values with your own API keys:

- `YOUR_RADARR_API_KEY`
- `YOUR_SONARR_API_KEY`

You can find these keys in:

- **Radarr → Settings → General**
- **Sonarr → Settings → General**

---

### 2️⃣ Run Recyclarr

From the directory containing your `docker-compose.yml`, run:

```
docker compose run --rm recyclarrsync
```

This will:

- Create quality definitions
- Create quality profiles
- Create custom formats
- Assign scores automatically

⚠️ **Do not manually edit profiles created by Recyclarr** — they will be overwritten on the next sync.

---

### 3️⃣ Configure Radarr (Movies)

In **Radarr**:

1. Go to **Settings → Profiles**
2. Select `TRaSH-HD` as the default profile
3. Ensure **Upgrades are allowed**
4. When adding movies:
    - Use the `TRaSH-HD` profile
    - Enable monitoring as desired

---

### 4️⃣ Configure Sonarr (TV & Anime)

In **Sonarr**:

### Standard TV Series

1. Go to **Settings → Profiles**
2. Set `TRaSH-HD` as the default profile
3. When adding a show:
    - Series Type: `Standard`
    - Profile: `TRaSH-HD`

### Anime Series

1. When adding an anime:
    - Set **Series Type = Anime**
    - Select **Profile = TRaSH-Anime-720p**
2. Ensure anime series are **not using standard TV profiles**

---

### 🔹 Step 6 – Jellyfin

- Add media libraries:
    - Movies → `/media/movies`
    - TV → `/media/tv`
    - Books → `/media/books`
- Generate API key

---

### 🔹 Step 7 – Jellyseerr

- Connect Jellyfin using:
    - URL: `http://jellyfin:8096`
- Map Radarr / Sonarr services

---

### 🔹 Step 8 – Homarr

- Add tiles pointing to:
    - Radarr, Sonarr, Jellyfin, Jellyseerr, etc.
- Optional: add health checks

## ⚙️ Linking ARR Applications

After the stack is running, log in to the web UIs of each application and link them together. Recommended URLs based on Docker Compose service names:

| Application | URL (Browser) |
| --- | --- |
| Radarr | `http://mediaserver:7878` |
| Sonarr | `http://mediaserver:8989` |
| Readarr | `http://mediaserver:8787` |
| Prowlarr | `http://mediaserver:9696` |
| Jellyfin | `http://mediaserver:8096` |
| Jellyseerr | `http://mediaserver:5055` |
| Homarr | `http://mediaserver:7575` |
| Bazarr | `http://mediaserver:6767` |
| qBittorrent | `http://mediaserver:8080` |

### Linking Steps:

1. **ARR → Prowlarr**
    - In Radarr / Sonarr / Readarr → Settings → Indexers → Add → Prowlarr.
    - Use `http://prowlarr:9696` and the API key from Prowlarr settings.
2. **ARR → qBittorrent**
    - In Radarr / Sonarr / Readarr → Settings → Download Clients → Add → qBittorrent.
    - Host: `qbittorrent`, Port: `8080`, user/password as configured.
3. **Jellyseerr → Jellyfin**
    - In Jellyseerr → Settings → Media Server → Add Jellyfin.
    - URL: `http://jellyfin:8096`, API key from Jellyfin.
4. **ARR → Jellyfin (Optional for library monitoring)**
    - Some ARR apps can update Jellyfin libraries after download. Use `http://jellyfin:8096` as the server URL.

---

## 🔧 Accessing Services

- On the same network, you can use:
- `http://mediaserver:<port>`
    - Ports match those in Docker Compose.
- If you enabled `avahi-daemon`, you can also use:
- `http://mediaserver.local:<port>`

---

## ⚠️ Notes / Tips

- Ensure your `.env` is properly set with `ARRPATH`, `PUID`, `PGID`, `TZ`.
- Permissions: Docker containers use `PUID` / `PGID` to access media/torrent folders.
- Desktop / kiosk: Firefox auto-launches Homarr. Use the desktop icon to reopen if needed.

- Logs: Config folders contain logs and DB files. Consider backups for persistence.
