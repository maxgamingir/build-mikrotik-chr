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
# build-mikrotik-chr
