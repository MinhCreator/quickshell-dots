<p align="center">🇬🇧 English · <a href="README.it.md">🇮🇹 Italiano</a></p>

# quickshell-dots

A complete desktop shell built with Quickshell, for niri and Hyprland. One install, the same shortcuts and the same four styles on both compositors.

> ### ⚠️ Read this before opening an issue
>
> This is not a project for everyone. I made it because I felt like it, and it works on my laptop. It is not meant to be a product: no roadmap, no support, no promises.
>
> 🤝 And I did not make it alone either: it is a four-hands job with Claude (the free version, yes, really). I decide what I want, Claude writes the code, I break it, Claude fixes it. Repeat.
>
> - Does not work on your machine? Congratulations, you found a new feature. Not my problem 🫡
> - Pull requests and ideas are welcome, but I may answer in three weeks or never.
> - It is all MIT: fork it, bend it, make it yours. That is exactly the point.
> - Tested on niri and Hyprland on Arch. Everything else: you are the tester now.

## Why it exists

I did not really like the shells that were out there, and the rices I found on GitHub were never truly mine. So I started building my own.

The inspiration comes from **SaneAspect**: I started from his videos. As far as I know, he makes his shells by hand, without AI, the opposite of what I did here. I did not buy his course (I am broke 💸), so I learned what I could from what is free, and filled the rest with Claude.

Not OK with it being made with an AI? No problem. There are plenty of beautiful shells written by people: go use those, and check out SaneAspect's channel first. I am just one of many, and this is just my stuff.

### Credits

**SaneAspect**: a guy who makes great tutorials that help people learn Quickshell, and does it very well. Go check his channel.

## Screenshots

<!-- Keep your existing Screenshots section here: Vertical, Dashboard, Island, style and wallpaper pickers. -->

## What you get

- **4 styles** you can switch on the fly (`Alt+S` opens the picker, or `Mod+Alt+1..4`): **Island** (floating pills that expand), **Classic** (full-width bar), **Dashboard** (a pill that turns into pages; with `Alt+V` you pick the *Attached* version, a bar fused with the top edge) and **Vertical** (side bar with attached panels).
- Launcher with favorites, power menu, lock screen, notification center with Do Not Disturb, calendar with reminders, timer and stopwatch.
- Quick settings: Wi-Fi, Bluetooth, audio, display, monitors (position, scale, rotation), keyboard layout, Game Mode and Eco Mode.
- Wallpaper picker; the colors of the whole shell (and of Firefox, with Pywalfox) follow the wallpaper through pywal.
- Screenshots and screen recording (asks for a name and an audio choice), media player with a real-time audio spectrum.
- Volume / brightness OSD, clipboard history.
- **Light / dark** mode (`Mod+Alt+T`): regenerates the pywal palette with `wal -l`, so shell, kitty and Firefox turn light or dark together.
- **10 themes per mode** (`Alt+T` opens the picker from the pill): they do not touch pywal, they only change how the shell uses its colors (accent, background, borders, text). Classic, Vivid, Complement, Triad, Analog, Mono, Tinted, Sober, Contrast, Neon. Lightweight: no heavy effects.

## Installation

```sh
git clone https://github.com/mohamedmousamm777-eng/quickshell-dots
cd quickshell-dots
sh install.sh
```

The installer tells you what it is doing at every step and asks **how** to install:

| Mode | What it does to your configs | When to pick it |
|---|---|---|
| **Light** (`--light`) | Replaces nothing. Puts the shell's keybinds next to your files (`quickshell.kdl` / `quickshell-binds.lua`), **without the keys you already use**, and adds a small block between two comments at the end of your `config.kdl` / `hyprland.lua` (the `include`/`require` lines and the shell autostart). | You already have your own config and want to keep it. Also the choice with `--yes`. |
| **Full** (`--full`) | Installs our `config.kdl` / `hyprland.lua`, the ones in the screenshots. Asks first and backs yours up. | You start from scratch or want exactly the look of the screenshots. |

What it does, in order:

1. detects niri and/or Hyprland (or use `--niri`, `--hyprland`, `--all`);
2. checks the required programs and offers to install the missing ones (Arch: pacman, plus yay/paru for AUR packages);
3. looks for other shells (noctalia, caelestia, DankMaterialShell, illogical-impulse...) and, if you agree, stops them and moves their settings into the backup (`--purge` also uninstalls their packages);
4. backs up everything it touches in `~/.config/quickshell-backup-DATE`, then installs the shell and the compositor part;
5. prepares the wallpaper folder and registers Pywalfox;
6. starts the shell, if you are inside a niri / Hyprland session.

Options: `--light`, `--full`, `--uninstall`, `--yes` (asks nothing), `--no-deps` (skip the programs check), `--no-others` (do not look for other shells), `--purge`, `--no-start`. `sh install.sh --help` lists them all.

### Light mode: conflicting keys

Before writing `quickshell.kdl` / `quickshell-binds.lua`, the installer reads your configs (every `*.kdl` in `~/.config/niri`, every `*.lua` in `~/.config/hypr`) and removes from the shell's file the keys you already use. `Super+R`, `Mod+R` and `super+r` are the same key; the order of the modifiers does not matter.

At the end it lists the skipped keys (and saves them in `~/.config/quickshell/skipped-binds.txt`). Those functions stay reachable from the shell itself and from a terminal with `qs ipc call` (see below).

Known limits: for Hyprland it understands `"SUPER + R"` and `mainMod .. " + R"`; a key built any other way (for example from a `for` loop variable) is left as it is. If something goes wrong, the installer checks the result with `niri validate` (and `luac -p`, if installed) and puts your file back as it was.

### Updating and uninstalling

Running `sh install.sh` again updates: the block is rewritten, never duplicated.

```sh
sh install.sh --uninstall
```

removes the block from your configs, the shell's files and `~/.config/quickshell` (everything goes into the backup first). After a **full** install it asks whether to put your original configs back. Wallpapers, pywal colors and packages are left alone.

## Requirements

quickshell, awww (or swww), pywal, jq, grim, slurp, wf-recorder, ffmpeg, wireplumber, playerctl, brightnessctl, cava, cliphist, wl-mirror, imagemagick, libnotify, inotify-tools, xdg-user-dirs, and optionally python-pywalfox (AUR) for Firefox. The installer registers it (`pywalfox install`); then you install the extension once from [addons.mozilla.org](https://addons.mozilla.org/firefox/addon/pywalfox/). Pywalfox reads the colors pywal writes in `~/.cache/wal/`.

## Wallpapers

Put your images in `<Pictures>/Wallpapers` (for example `~/Pictures/Wallpapers`, the installer creates the folder), then press `Alt+W`.

## Shortcuts

`Mod` = Super. Same on niri and Hyprland. In light mode, the keys you already used stay yours (see above).

| Keys | Action |
|---|---|
| `Mod+R` / `Alt+R` | launcher |
| `Mod+M` / `Alt+P` | power menu |
| `Alt+W` | wallpaper picker |
| `Alt+L` | lock the screen |
| `Alt+I` | system resources |
| `Alt+Tab` | show the workspaces |
| `Alt+G` | Game Mode |
| `Alt+E` | Eco Mode |
| `Alt+D` | Do Not Disturb |
| `Mod+Space` | next keyboard layout |
| `Alt+S` | style picker |
| `Alt+T` | theme picker (arrows = preview, Enter applies, Esc cancels, Tab light/dark) |
| `Alt+V` | Dashboard version (Pill / Attached) |
| `Mod+Alt+T` | toggle light / dark |
| `Mod+Alt+1..4` | Island / Classic / Dashboard / Vertical |
| `Print` | screenshot and recording menu |
| `Mod+H` / `Mod+Shift+H` / `Mod+Ctrl+H` | screenshot: screen / area / window |
| `Mod+Alt+H` / `Mod+Alt+Shift+H` | record screen / area (press again to stop) |
| `Mod+Alt+P` | pause recording |
| `Mod+Return` / `Mod+F` / `Mod+E` | kitty, firefox, nautilus |
| `Mod+Q` / `Mod+V` | close / floating |
| `Mod+Ctrl+F` / `Mod+Shift+F` | fullscreen / maximize |
| `Mod+C` / `Mod+-` / `Mod+W` | center / narrower / wider |
| `Mod+arrows` / `Mod+Shift+arrows` | focus / move |
| `Mod+1..0` / `Mod+Shift+1..0` | workspace / move the window there |
| `Mod+Shift+E` | quit the compositor |

**niri only:** `Mod+Tab` overview, `Mod+J` preset widths, `Mod+,` `Mod+.` columns.
**Hyprland only:** `Mod+Tab` pins the workspaces, `Mod+J` changes the split, `Mod+P` pseudo, `Mod+S` scratchpad.

### The shell's shortcuts, one by one

The ones that do not explain themselves.

#### Style: `Alt+S` and `Mod+Alt+1..4`
`Alt+S` opens the picker for the four styles (Island, Classic, Dashboard, Vertical). `Mod+Alt+1`, `2`, `3`, `4` jump straight to Island, Classic, Dashboard, Vertical without opening anything. From a terminal: `qs ipc call style set side` (example).

#### Dashboard: `Alt+V`
For the Dashboard style: switches between the **Pill** version (a pill that turns into pages) and the **Attached** one (a bar fused with the top edge).

#### Themes: `Alt+T`
Opens the theme picker from the pill. There are 10 themes per mode (Classic, Vivid, Complement, Triad, Analog, Mono, Tinted, Sober, Contrast, Neon). In the picker: **arrows** preview, **Enter** applies, **Esc** cancels, **Tab** switches between light and dark. Themes do not touch pywal: they only change how the shell uses the colors (accent, background, borders, text).
From a terminal: `qs ipc call theme toggle`, `qs ipc call theme set <name>`, `qs ipc call theme mode <dark|light|toggle>`.

#### Light / dark: `Mod+Alt+T`
Toggles light and dark by regenerating the pywal palette with `wal -l`: shell, kitty and Firefox (with Pywalfox) change together. Unlike `Alt+T`, this changes the palette, not just how the colors are used.

#### Screenshots and recording: `Print`, `Mod+H`, `Mod+Alt+H`, `Mod+Alt+P`
`Print` opens the screenshot and recording menu. Directly: `Mod+H` screenshots the screen, `Mod+Shift+H` an area, `Mod+Ctrl+H` a window. `Mod+Alt+H` records the screen, `Mod+Alt+Shift+H` an area; pressing the same combination again stops the recording. `Mod+Alt+P` pauses. Recording asks for the file name and an audio choice.

#### Modes: `Alt+G`, `Alt+E`, `Alt+D`
`Alt+G` Game Mode, `Alt+E` Eco Mode, `Alt+D` Do Not Disturb. Game Mode and Eco Mode are also in the quick settings; Do Not Disturb belongs to the notification center.

#### Panels: `Alt+W`, `Alt+L`, `Alt+I`, `Alt+Tab`
`Alt+W` wallpaper picker (images go in `<Pictures>/Wallpapers`), `Alt+L` locks the screen, `Alt+I` system resources, `Alt+Tab` shows the workspaces.

#### Everything from a terminal: `qs ipc call`
Every function of the shell is also a command: `qs ipc call <target> <function>`. It is the way to use a function whose key was already yours (light mode), or to bind it by hand in your own config.

## Repository layout

```
quickshell/   the shell  ->  ~/.config/quickshell
niri/         config.kdl, quickshell.kdl (+ files managed by the shell)
hypr/         hyprland.lua, quickshell-binds.lua (+ file managed by the shell)
installer/    the installer modules (common, dependencies, other shells, light, full, uninstall)
install.sh
```

`quickshell-outputs.*` and `quickshell-tweaks.kdl` are written by the shell itself (Monitors page, Game/Eco Mode): do not delete them.

## Restoring

Everything the installer replaced or removed is in `~/.config/quickshell-backup-DATE`. To go back in an orderly way: `sh install.sh --uninstall`.

## License

MIT
