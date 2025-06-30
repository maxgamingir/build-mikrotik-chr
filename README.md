# Build MikroTik CHR

Automates the download, configuration, and deployment of MikroTik CHR (Cloud Hosted Router) images using Node.js and SSH.

This tool customizes RouterOS settings such as:

- IP address
- DNS configuration
- User credentials
- License activation

It builds a bootable image, injects a custom `autorun.scr` script, and writes the modified CHR image to a remote KVM/QEMU host automatically.

---

## 🚀 Features

- SSH connection to KVM/QEMU host
- Dynamic RouterOS config injection
- License activation using MikroTik account
- DNS and NAT setup
- Fully scriptable `.env`-driven configuration

---

## 🧰 Requirements

### ✅ For All Platforms

- **[Node.js](https://nodejs.org/)** (v16 or later)
- **[Git](https://git-scm.com/)** (for cloning the repository)
- A remote **Ubuntu-based KVM/QEMU host** with root SSH access

---

### 💻 Windows Installation Guide

#### 🔧 Install Node.js:

1. Go to: https://nodejs.org/
2. Download the **LTS version** for Windows
3. Run the installer and complete setup
4. Verify installation:
   ```powershell
   node -v
   npm -v
   ```

## ⚙️ Usage

Follow these steps to set up and run the MikroTik CHR deployment tool:

1. **Clone the repository and install dependencies**

   ```bash
   git clone https://github.com/maxgamingir/build-mikrotik-chr.git
   cd build-mikrotik-chr
   npm install
   cp env.example .env
   edit .env file
   node server.js
   ```
