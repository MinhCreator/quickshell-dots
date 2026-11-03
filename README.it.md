<p align="center"><a href="README.md">🇬🇧 English</a> · 🇮🇹 Italiano</p>

# quickshell-dots

Una shell desktop completa fatta con Quickshell, per niri e Hyprland. Un'unica installazione, le stesse scorciatoie e gli stessi quattro stili su tutti e due i compositor.

> ### ⚠️ Leggi qui prima di aprire una issue
>
> Questo non è un progetto per tutti. L'ho fatto perché mi andava, e funziona sul mio portatile. Non nasce per essere un prodotto: niente roadmap, niente supporto, niente promesse.
>
> 🤝 E non l'ho fatto nemmeno da solo: è un lavoro a 4 mani con Claude (la versione free, sì, davvero). Io decido cosa voglio, Claude scrive il codice, io lo rompo, Claude lo ripara. Ripetere.
>
> - Su casa tua non funziona? Complimenti, hai trovato una nuova funzione. Non è un problema mio 🫡
> - Pull request e idee sono benvenute, ma posso rispondere tra tre settimane o mai.
> - È tutto MIT: fai un fork, piegalo, rendilo tuo. È proprio questo il punto.
> - Provato su niri e Hyprland su Arch. Tutto il resto: il tester ora sei tu.

## Perché esiste

Non mi piacevano molto le shell che c'erano, e le rice che trovavo su GitHub non erano mai davvero mie. Così ho iniziato a costruirmi la mia.

L'ispirazione viene da **SaneAspect**: sono partito dai suoi video. Per quanto ne so, lui le sue shell le fa a mano, senza IA, il contrario di quello che ho fatto io qui. Il suo corso non l'ho comprato (sono povero 💸), quindi ho imparato quello che ho potuto da ciò che è gratis, e il resto l'ho colmato con Claude.

Non ti va bene che sia fatto con un'IA? Nessun problema. Ci sono tantissime shell bellissime scritte da persone: vai a usare quelle, e dai prima un'occhiata al canale di SaneAspect. Io sono solo uno dei tanti, e questa è solo roba mia.

### Crediti

**SaneAspect**: un ragazzo che fa ottimi tutorial che aiutano le persone a imparare Quickshell, e lo fa molto bene. Vai a vedere il suo canale.

## Screenshot

<!-- Qui lascia la tua sezione Screenshot com'è: Vertical, Dashboard, Island, selettori di stile e wallpaper. -->

## Cosa trovi

- **4 stili** da cambiare al volo (`Alt+S` apre il selettore, oppure `Mod+Alt+1..4`): **Island** (pillole fluttuanti che si espandono), **Classic** (barra a tutta larghezza), **Dashboard** (una pillola che diventa pagine; con `Alt+V` scegli la versione *Attaccata*, una barra fusa con il bordo alto) e **Vertical** (barra laterale con pannelli attaccati).
- Launcher con preferiti, menu power, schermata di blocco, centro notifiche con Non disturbare, calendario con promemoria, timer e cronometro.
- Impostazioni rapide: Wi-Fi, Bluetooth, audio, schermo, monitor (posizione, scala, rotazione), layout tastiera, Game Mode ed Eco Mode.
- Selettore wallpaper; i colori di tutta la shell (e di Firefox, con Pywalfox) seguono lo sfondo tramite pywal.
- Screenshot e registrazione schermo (con richiesta del nome e scelta dell'audio), player multimediale con spettro audio in tempo reale.
- OSD volume / luminosità, cronologia appunti.
- Modalità **chiaro / scuro** (`Mod+Alt+T`): rigenera la palette pywal con `wal -l`, così shell, kitty e Firefox diventano chiari o scuri insieme.
- **10 temi per modalità** (`Alt+T` apre il selettore dalla pillola): non toccano pywal, cambiano solo come la shell usa i suoi colori (accento, sfondo, bordi, testo). Classic, Vivid, Complement, Triad, Analog, Mono, Tinted, Sober, Contrast, Neon. Leggeri: nessun effetto pesante.

## Installazione

```sh
git clone https://github.com/mohamedmousamm777-eng/quickshell-dots
cd quickshell-dots
sh install.sh
```

L'installer ti dice cosa sta facendo a ogni passo e ti chiede **come** installare:

| Modalità | Cosa fa ai tuoi config | Quando sceglierla |
|---|---|---|
| **Leggera** (`--light`) | Non sostituisce niente. Copia accanto ai tuoi file i tasti della shell (`quickshell.kdl` / `quickshell-binds.lua`), **senza i tasti che usi già**, e aggiunge in fondo al tuo `config.kdl` / `hyprland.lua` un piccolo blocco tra due commenti (gli `include`/`require` e l'avvio della shell). | Hai già un tuo config e vuoi tenerlo. È anche la scelta con `--yes`. |
| **Completa** (`--full`) | Installa i nostri `config.kdl` / `hyprland.lua`, quelli degli screenshot. Prima chiede e salva un backup dei tuoi. | Parti da zero o vuoi esattamente l'aspetto degli screenshot. |

Cosa fa, in ordine:

1. riconosce niri e/o Hyprland (oppure usa `--niri`, `--hyprland`, `--all`);
2. controlla i programmi necessari e ti propone di installare quelli mancanti (Arch: pacman, più yay/paru per i pacchetti AUR);
3. cerca altre shell (noctalia, caelestia, DankMaterialShell, illogical-impulse...) e, se sei d'accordo, le ferma e sposta le loro impostazioni nel backup (con `--purge` disinstalla anche i loro pacchetti);
4. salva un backup di tutto ciò che tocca in `~/.config/quickshell-backup-DATA`, poi installa la shell e la parte di compositor;
5. prepara la cartella dei wallpaper e registra Pywalfox;
6. avvia la shell, se sei dentro una sessione niri / Hyprland.

Opzioni: `--light`, `--full`, `--uninstall`, `--yes` (non chiede niente), `--no-deps` (salta il controllo dei programmi), `--no-others` (non cerca altre shell), `--purge`, `--no-start`. `sh install.sh --help` le elenca tutte.

### Modalità leggera: i tasti in conflitto

Prima di scrivere `quickshell.kdl` / `quickshell-binds.lua`, l'installer legge i tuoi config (tutti i `*.kdl` di `~/.config/niri`, tutti i `*.lua` di `~/.config/hypr`) e toglie dal file della shell i tasti che usi già. `Super+R`, `Mod+R` e `super+r` sono lo stesso tasto; l'ordine dei modificatori non conta.

Alla fine ti elenca i tasti saltati (e li salva in `~/.config/quickshell/skipped-binds.txt`). Quelle funzioni restano raggiungibili dalla shell stessa e da terminale con `qs ipc call` (vedi sotto).

Limiti noti: per Hyprland riconosce le forme `"SUPER + R"` e `mainMod .. " + R"`; un tasto costruito in altro modo (per esempio con una variabile di un ciclo `for`) viene lasciato com'è. Se qualcosa va storto, l'installer controlla il risultato con `niri validate` (e `luac -p`, se installato) e rimette il tuo file com'era.

### Aggiornare e disinstallare

Rilanciare `sh install.sh` aggiorna: il blocco viene riscritto, mai duplicato.

```sh
sh install.sh --uninstall
```

toglie il blocco dai tuoi config, i file della shell e `~/.config/quickshell` (tutto finisce prima nel backup). Dopo un'installazione **completa** ti chiede se rimettere i tuoi config originali. Wallpaper, colori pywal e pacchetti non vengono toccati.

## Servono

quickshell, awww (o swww), pywal, jq, grim, slurp, wf-recorder, ffmpeg, wireplumber, playerctl, brightnessctl, cava, cliphist, wl-mirror, imagemagick, libnotify, inotify-tools, xdg-user-dirs, e in più, se vuoi, python-pywalfox (AUR) per Firefox. L'installer lo registra (`pywalfox install`); poi installi una volta l'estensione da [addons.mozilla.org](https://addons.mozilla.org/firefox/addon/pywalfox/). Pywalfox legge i colori che pywal scrive in `~/.cache/wal/`.

## Wallpaper

Metti le immagini in `<Immagini>/Wallpapers` (ad esempio `~/Immagini/Wallpapers` o `~/Pictures/Wallpapers`, la cartella la crea l'installer), poi premi `Alt+W`.

## Scorciatoie

`Mod` = Super. Uguali su niri e Hyprland. Nella modalità leggera, i tasti che usavi già restano tuoi (vedi sopra).

| Tasti | Azione |
|---|---|
| `Mod+R` / `Alt+R` | launcher |
| `Mod+M` / `Alt+P` | menu power |
| `Alt+W` | selettore wallpaper |
| `Alt+L` | blocca lo schermo |
| `Alt+I` | risorse di sistema |
| `Alt+Tab` | mostra i workspace |
| `Alt+G` | Game Mode |
| `Alt+E` | Eco Mode |
| `Alt+D` | Non disturbare |
| `Mod+Space` | layout tastiera successivo |
| `Alt+S` | selettore degli stili |
| `Alt+T` | selettore temi (frecce = anteprima, Invio applica, Esc annulla, Tab chiaro/scuro) |
| `Alt+V` | versione della Dashboard (Pillola / Attaccata) |
| `Mod+Alt+T` | alterna chiaro / scuro |
| `Mod+Alt+1..4` | Island / Classic / Dashboard / Vertical |
| `Print` | menu screenshot e registrazione |
| `Mod+H` / `Mod+Shift+H` / `Mod+Ctrl+H` | screenshot: schermo / area / finestra |
| `Mod+Alt+H` / `Mod+Alt+Shift+H` | registra schermo / area (premi ancora per fermare) |
| `Mod+Alt+P` | pausa registrazione |
| `Mod+Return` / `Mod+F` / `Mod+E` | kitty, firefox, nautilus |
| `Mod+Q` / `Mod+V` | chiudi / fluttuante |
| `Mod+Ctrl+F` / `Mod+Shift+F` | schermo intero / massimizza |
| `Mod+C` / `Mod+-` / `Mod+W` | centra / più stretta / più larga |
| `Mod+frecce` / `Mod+Shift+frecce` | focus / sposta |
| `Mod+1..0` / `Mod+Shift+1..0` | workspace / sposta la finestra lì |
| `Mod+Shift+E` | esci dal compositor |

**Solo niri:** `Mod+Tab` overview, `Mod+J` larghezze predefinite, `Mod+,` `Mod+.` colonne.
**Solo Hyprland:** `Mod+Tab` fissa i workspace, `Mod+J` cambia divisione, `Mod+P` pseudo, `Mod+S` scratchpad.

### Le scorciatoie della shell, una per una

Quelle che non si spiegano da sole.

#### Stile: `Alt+S` e `Mod+Alt+1..4`
`Alt+S` apre il selettore dei quattro stili (Island, Classic, Dashboard, Vertical). `Mod+Alt+1`, `2`, `3`, `4` saltano direttamente a Island, Classic, Dashboard, Vertical senza aprire niente. Da terminale: `qs ipc call style set side` (esempio).

#### Dashboard: `Alt+V`
Vale per lo stile Dashboard: alterna la versione **Pillola** (una pillola che diventa pagine) e quella **Attaccata** (una barra fusa con il bordo alto).

#### Temi: `Alt+T`
Apre il selettore dei temi dalla pillola. Ci sono 10 temi per modalità (Classic, Vivid, Complement, Triad, Analog, Mono, Tinted, Sober, Contrast, Neon). Nel selettore: **frecce** per l'anteprima, **Invio** applica, **Esc** annulla, **Tab** passa tra chiaro e scuro. I temi non toccano pywal: cambiano solo come la shell usa i colori (accento, sfondo, bordi, testo).
Da terminale: `qs ipc call theme toggle`, `qs ipc call theme set <nome>`, `qs ipc call theme mode <dark|light|toggle>`.

#### Chiaro / scuro: `Mod+Alt+T`
Alterna chiaro e scuro rigenerando la palette pywal con `wal -l`: shell, kitty e Firefox (con Pywalfox) cambiano insieme. A differenza di `Alt+T`, questo cambia la palette, non solo l'uso dei colori.

#### Screenshot e registrazione: `Print`, `Mod+H`, `Mod+Alt+H`, `Mod+Alt+P`
`Print` apre il menu screenshot e registrazione. In diretta: `Mod+H` screenshot dello schermo, `Mod+Shift+H` di un'area, `Mod+Ctrl+H` di una finestra. `Mod+Alt+H` registra lo schermo, `Mod+Alt+Shift+H` un'area; premendo di nuovo la stessa combinazione la registrazione si ferma. `Mod+Alt+P` mette in pausa. La registrazione chiede il nome del file e la scelta dell'audio.

#### Modalità: `Alt+G`, `Alt+E`, `Alt+D`
`Alt+G` Game Mode, `Alt+E` Eco Mode, `Alt+D` Non disturbare. Game Mode ed Eco Mode si trovano anche nelle impostazioni rapide; Non disturbare riguarda il centro notifiche.

#### Pannelli: `Alt+W`, `Alt+L`, `Alt+I`, `Alt+Tab`
`Alt+W` selettore wallpaper (le immagini vanno in `<Immagini>/Wallpapers`), `Alt+L` blocca lo schermo, `Alt+I` risorse di sistema, `Alt+Tab` mostra i workspace.

#### Tutto da terminale: `qs ipc call`
Ogni funzione della shell è anche un comando: `qs ipc call <target> <funzione>`. È il modo per usare una funzione il cui tasto era già tuo (modalità leggera), o per assegnarle un tasto a mano nel tuo config.

## Com'è fatto il repository

```
quickshell/   la shell  ->  ~/.config/quickshell
niri/         config.kdl, quickshell.kdl (+ file gestiti dalla shell)
hypr/         hyprland.lua, quickshell-binds.lua (+ file gestito dalla shell)
installer/    i moduli dell'installer (comune, dipendenze, altre shell, leggera, completa, disinstallazione)
install.sh
```

`quickshell-outputs.*` e `quickshell-tweaks.kdl` li scrive la shell da sola (pagina Monitors, Game/Eco Mode): non cancellarli.

## Ripristino

Tutto ciò che l'installer ha sostituito o tolto è in `~/.config/quickshell-backup-DATA`. Per tornare indietro in modo ordinato: `sh install.sh --uninstall`.

## Licenza

MIT
