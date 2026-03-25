# 🚀 Ultimate Neovim Setup 

*Read this in other languages: [English](README.md) | [Українська](README.uk.md)*

---

#### A blazing fast, modular, and headache-free Neovim configuration manager. 
#### It detects your OS, installs required dependencies, hooks up the Neovim Nightly binary, and symlinks the configs. Zero stress, 100% Lua.

## 🌟 Features
- **Auto OS Detection:** Natively supports `macOS`, `Arch`, `Debian/Ubuntu`, and `Fedora`.
- **Dependency Management:** Automatically installs missing tools (`ripgrep`, `fd`, `unzip`, `gcc`, etc.).
- **Nightly Binary:** Keeps you on the bleeding edge (0.11+) by fetching the pre-built binary.
- **Auto-Updates:** Just like Oh My Zsh, it will periodically check for updates on terminal startup.
- **Multiple Flavors:** Choose between `nvim-full` (IDE-like experience) or `nvim-minimal` (lightweight Netrw setup).

---

## 🛠 Prerequisites
You only need `git` and `curl` installed to clone this repo. The script will handle the rest!

---

## 📦 Installation

**1. Clone the repository**
```bash
git clone [https://github.com/MaksOk1/nvim-setup.git](https://github.com/MaksOk1/nvim-setup.git) ~/.nvim-setup
cd ~/.nvim-setup
```

**2. Make the scripts executable**
```bash
chmod +x ./*.sh ./scripts/*.sh
```

**3. Run the installer**
```bash
./install.sh
```

---

## ℹ️ What exactly happens during installation?

### Depending on your OS, the script runs the respective package manager:
- **🍎 macOS:** Prompts to install Xcode CLI Tools (if missing), installs Homebrew (if missing), and uses `brew install`.
- **🐧 Debian/Ubuntu:** Uses `apt-get` and handles package naming quirks (like `fd-find` -> `fd`).
- **🐧 Arch Linux:** Uses `pacman` and correctly pulls the base-devel group.
- **🎩 Fedora:** Uses `dnf` and pulls `@development-tools`.

#### After dependencies are met, it *installs **Neovim Nightly** to `/usr/local/bin/nvim`*, backs up your *existing `~/.config/nvim`*, and symlinks the chosen flavor.

---

## 🔄 Updates

### **Auto-Update:**
During installation, you can opt-in for auto-updates. The script will inject a hook into your `~/.bashrc` or `~/.zshrc` that runs every 7 days, doing a silent `git pull`.

### **Manual Update:**
Just **navigate to the folder** *(clonned from git)* and **pull**:
```bash
cd ~/.nvim-setup && git pull origin main
```

---

## 👥 Multi-user & Root Support

#### If you want to use this config for `root` (e.g., when editing system files via `sudo -e` or `sudo nvim`), you have two options:

### **Option 1: Quick Symlink (*Recommended*)**
*Simply map the `root`'s Neovim config to your `user`'s repository:*
```bash
sudo ln -s /home/<user>/.nvim-setup/nvim-full /root/.config/nvim
```

### **Option 2: Independent Install**
If you want a totally separate environment for root (to avoid mixed plugin ownership):
```bash
sudo bash -c "git clone [https://github.com/MaksOk1/nvim-setup.git](https://github.com/MaksOk1/nvim-setup.git) /root/.nvim-setup && cd /root/.nvim-setup && chmod +x *.sh scripts/*.sh && ./install.sh"
```
*(**Note:** Be careful with lazy.nvim downloading plugins as `root`, it might mess with your `user`'s cache if paths cross).*

---

## 🗑 Uninstallation

### Don't like it? Breakup is *easy*.

```bash
cd ~/.nvim-setup
./uninstall.sh
```

This will remove the symlink, offer to delete the *Neovim Nightly binary*, and prompt to *restore your previous configuration backup*.

---

## 🎨 Notes on Fonts

### To make the UI (lualine, neo-tree) look spectacular, you **must** use a Nerd Font in your terminal emulator (e.g., [JetBrainsMono Nerd Font](https://www.nerdfonts.com/)).

---

## 📬 Let's Connect

> ### 💬 If **anything** goes wrong or you just want to chat: 
> #### 📧: **[*maksymzikii@gmail.com*](mailto:maksymzikii@gmail.com)**

### **Happy Hacking!** 💻✨
---