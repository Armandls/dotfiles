# Waybar

### Full Dekstop
<img width="2880" height="1800" alt="full_desktop_waybar" src="https://github.com/user-attachments/assets/c9ee976f-83c0-4dfd-95c5-a5d0de4bc33c" />

### Showcase
https://github.com/user-attachments/assets/150b7b3d-9b5d-4a0f-a7a4-47977d99e9e5

---

### Structure

```
waybar/
├── config.jsonc                     # Entry point, loads all modules
├── style.css                        # Main stylesheet
├── modules/                         # Each module in its own file
│   ├── audio.jsonc
│   ├── battery.jsonc
│   ├── bluetooth.jsonc
│   ├── clock.jsonc
│   ├── groups.jsonc                 # Drawer grouping
│   ├── system.jsonc                 # CPU, RAM, temperature
│   └── workspace.jsonc
└── tokens/                          # CSS variables
    ├── colors.css                   < edit colors here
    ├── batt-clock.css
    ├── state.css
    ├── widget.css
    └── workspace.css
```

---

>[!IMPORTANT]
>Open file `waybar/modules/clock`, and change this;

```bash
{
  "clock": {
    "timezone": "REGION/CITY",
    "format": "󰃱 <span size='11pt'>{:%H.%M }</span>",
    "format-alt": "󰃱 <span size='11pt'>{:%d %B %Y}</span>",
    "tooltip-format": "<tt><small>{calendar}</small></tt>"
  }
}
```

---

### Modules

| Module | Interaction | Action |
| --- | --- | --- |
---

### Colors

Edit `tokens/colors.css` to match your preference.

> [!TIP]
> For automatic color generation from your wallpaper, see `.config/matugen` and `.config/zsh`.

---

### Dependencies

| Package | Purpose |
| --- | --- |
| [Waybar](https://github.com/Alexays/Waybar) | Status bar |
| [pipewire](https://wiki.archlinux.org/title/PipeWire) / [pulseaudio](https://wiki.archlinux.org/title/PulseAudio) | Audio |

---

### Install

```bash
git clone https://github.com/haikal-hakim/athena.git
cd athena
cp -r .config/waybar ~/.config/waybar
```
---

## Acknowledgments
* **[Waybar](https://github.com/Alexays/Waybar)** - Created by **Alexays**. Huge thanks for this amazing and highly customizable status bar.
* All the contributors who have made Waybar what it is today.
* I personally customized this configuration to fit the **Athena** desktop.

---
Developed by Muhammad Haikal Hakim.
