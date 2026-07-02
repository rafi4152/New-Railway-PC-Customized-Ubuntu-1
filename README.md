❌❌❌ Problem ❌❌❌

Ubuntu 24.04 XFCE + TightVNC + noVNC + Google Chrome


A lightweight Ubuntu 24.04 LTS desktop running inside Docker with XFCE, TightVNC, noVNC and Google Chrome.

Features

- Ubuntu 24.04 LTS
- XFCE Desktop Environment
- TightVNC Server
- noVNC (Browser Access)
- Google Chrome Stable
- Desktop User (Passwordless sudo)
- Desktop Shortcuts
- "All Apps" Launcher
- Automatic Desktop Shortcut Sync
- Git
- Curl
- Wget
- Nano
- Vim
- Neovim
- Build Essential Tools
- ZIP / Unzip / 7zip
- X11 Utilities
- DBus Support

---

Project Structure

.
├── Dockerfile
├── start.sh
└── README.md

---

Ports

Port| Description
5901| TightVNC
6080| noVNC (Browser Access)

---

Default Settings

Setting| Value
Username| desktop
Home| /home/desktop
Timezone| Asia/Dhaka
Resolution| 1366x768
Color Depth| 24-bit
VNC Password| changeme

---

Build

docker build -t ubuntu24-xfce-vnc .

---

Run

docker run -it --rm \
-p 5901:5901 \
-p 6080:6080 \
ubuntu24-xfce-vnc

---

Browser Access

Open:

http://localhost:6080/vnc.html

---

VNC Client

Host

localhost

Port

5901

Password

changeme

---

Desktop

The desktop automatically includes:

- All Apps
- Google Chrome
- Terminal
- Files
- Home Folder

When new GUI applications are installed, their desktop launchers are synchronized automatically.

---

Installing More Software

Update package list

sudo apt update

Install software

sudo apt install package-name

Examples

sudo apt install firefox

sudo apt install vlc

sudo apt install gimp

sudo apt install libreoffice

---

Useful Commands

Update

sudo apt update

Upgrade

sudo apt upgrade -y

Clean cache

sudo apt autoremove -y
sudo apt clean

---

Railway Deployment

1. Create a GitHub repository.
2. Upload:
   - Dockerfile
   - start.sh
   - README.md
3. Import the repository into Railway.
4. Railway will automatically build the Docker image.
5. Expose port 6080 (or configure the public port as required by your deployment).
6. Open the generated Railway URL to access the desktop.

---

Customization

You can change:

- Screen Resolution
- Color Depth
- VNC Password
- VNC Port
- noVNC Port
- Timezone

through the environment variables in the Dockerfile.

---

Requirements

- Docker
- Linux, macOS or Windows with Docker Desktop
- amd64 (x86_64) architecture

---

License

This project is provided as-is for educational and personal use.
