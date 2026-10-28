# 🍏 MacBook Automated Provisioning & Bootstrap Suite

Reproducible, automated provisioning configurations for setting up a brand-new or freshly wiped Apple Silicon or Intel MacBook.

---

## ⚡ Zero to Hero: One-Line Install

On any fresh Mac, open **Terminal** (`Command + Space` -> type `Terminal`) and paste:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/el-j/mac-setup/main/install.sh)"
```

---

## 📦 What Gets Installed & Configured

### 🖥️ Applications:
- 🌐 **Brave Browser** - Privacy-first web browser.
- 💻 **Visual Studio Code** - Industry standard code editor.
- 🎨 **Canva Desktop** - Design & creative publishing app.
- 🏬 **Applite** - Clean, free, open-source App Store for Mac apps and Homebrew packages.
- 📟 **iTerm2** - High-performance terminal emulator with Dracula color scheme.
- ⚡ **Raycast** - Spotlight replacement & clipboard manager.
- 🪟 **Rectangle** - Window snapping shortcuts.
- 📦 **The Unarchiver** - Universal archive extractor (zip, rar, 7z).
- 🔤 **JetBrains Mono Nerd Font** - Glyphs & developer icons for terminal and editor.

### 💻 Developer Experience & Shell (Zsh + Dracula):
- **Oh My Zsh** core framework.
- **Starship Prompt** with customized Dracula styling showing Git branch status and language runtimes (Node, Rust, Python, Go).
- **zsh-autosuggestions**: Fish-like predictive autocompletions as you type.
- **zsh-syntax-highlighting**: Live green/red command validation.
- **iTerm2 Dracula Theme**: Automatically imported palette.
- **Modern CLI Aliases**: `ls` -> `eza`, `cat` -> `bat`, `top` -> `btop`, `z` -> `zoxide`.

### 🖌️ Complete ArtCraft Creative Suite:
- 🚀 **ArtCraft Launcher** - Suite manager & background auto-updater.
- 📄 **PdfCraft** - Open-source PDF workbench (read, split, merge, annotate, secure).
- 📐 **VectorCraft** - Fast, pure-Rust vector illustration app (Illustrator alternative).
- 🖼️ **PhotoCraft** - Layered photo & raster image editor (Photoshop alternative).
- 📝 **WordCraft** - Native, clean-room word processor with native `.docx` support.
- 📊 **GridCraft** - High-performance native spreadsheet (Excel alternative).
- 📰 **DesignCraft** - Page layout & publishing app (InDesign alternative).
- 📽️ **DeckCraft** - Dynamic presentation & slide builder.

### 🧹 Clean Minimalist Dock:
- Wipes all Apple stock bloat (TV, Maps, News, Podcasts, Keynote, Pages).
- Pins: Brave, VS Code, iTerm2, Applite, Canva, and the ArtCraft suite.

---

## 🔄 Re-running Updates

```bash
cd ~/.mac-setup
git pull
ansible-playbook playbook.yml
```