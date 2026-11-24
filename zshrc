#
# ~/.zshrc
#

# 1. Wenn nicht interaktiv, mache nichts (verhindert Fehler bei Skripten)
[[ $- != *i* ]] && return

# 2. Standard-Editor festlegen
export EDITOR=nvim
export VISUAL=nvim
# 3. Sinnvolle Aliase für Minimal-Setups
alias ls='ls --color=auto'
alias ll='ls -la --color=auto' # Sehr praktisch für versteckte Dateien und Rechte-Übersicht
alias grep='grep --color=auto'
alias whereami='pwd'
alias sudo='sudo '
alias nconf="kate /etc/nixos/configuration.nix"
alias applist="sudo nvim /etc/nixos/packages.json"

alias tools='printf "%s\n" \
"=== CLI TOOLS ===" \
"" \
"fd <name>        Dateisuche" \
"rg <text>        Textsuche mit ripgrep" \
"fzf              Interaktive Fuzzy-Suche" \
"btop             Systemmonitor" \
"dust             Speicherverbrauch von Ordnern" \
"duf              Datenträgerübersicht" \
"procs            Moderner ps-Ersatz" \
"delta            Schönere Git-Diffs" \
"hyperfine        Befehle benchmarken" \
"watchexec        Befehl bei Dateiänderung starten" \
"just             Command Runner / justfile" \
"zoxide / z       Schnelles cd zu häufigen Ordnern" \
"atuin            Shell-History, Ctrl-R" \
"eza              Moderner ls-Ersatz" \
"bat              cat mit Syntax Highlighting" \
"lazygit          Git TUI" \
"jq               JSON bearbeiten" \
"tldr <cmd>       Kurze Befehlsbeispiele" \
"yazi / y         Terminal-Dateimanager" \
"nix-your-shell   Bessere Nix-Shell-Integration" \
"nom              Nix Output Monitor" \
"" \
"=== TOOLS ===" \
"sshm:            startet omny als User omny mit deinem SSH-Schlüssel" \
"moonstart:       Firewall am Router öffnen, PC wecken, Moonlight starten" \
"quickscan:       ClamAV nur für Dateien der letzten 7 Tage, dauert kurz" \
"virusscan:       ClamAV über ganz /home, dauert Stunden" \
"audit:           Lynis prüft das System" \
"vulns:           vulnix sucht Pakete mit bekannten Sicherheitslücken" \
"scan:            Vollscan, Lynis und vulnix hintereinander" \
"" \
"=== DEINE ALIASES ===" \
"" \
"l                eza" \
"ll               eza -lah --git" \
"la               eza -a" \
"lt               eza --tree --level=2" \
"lta              eza --tree --level=3 -a" \
"g                git" \
"gs               git status" \
"gd               git diff" \
"gl               git log --oneline --graph --decorate" \
"lg               lazygit" \
"nd               nix develop" \
"ns               nix shell" \
"nr               nix run" \
"ports            ss -tulpn" \
"top              btop" \
"cat              bat" \
"" \
"=== NVIM ===" \
"" \
"i                Insert Mode" \
"Esc              Normal Mode" \
"v                Visual Mode" \
"V                Zeilen markieren" \
"Ctrl-v           Block markieren" \
"" \
"h/j/k/l          links/runter/hoch/rechts" \
"w                nächstes Wort" \
"b                vorheriges Wort" \
"0                Zeilenanfang" \
"$                Zeilenende" \
"gg               Dateianfang" \
"G                Dateiende" \
"Ctrl-d           halbe Seite runter" \
"Ctrl-u           halbe Seite hoch" \
"" \
"dd               Zeile löschen" \
"yy               Zeile kopieren" \
"p                einfügen" \
"u                rückgängig" \
"Ctrl-r           wiederholen" \
"ciw              Wort ersetzen" \
"diw              Wort löschen" \
"x                Zeichen löschen" \
".                letzte Änderung wiederholen" \
"" \
"/text            suchen" \
"n                nächster Treffer" \
"N                vorheriger Treffer" \
"*                Wort unter Cursor suchen" \
"" \
":w               speichern" \
":q               beenden" \
":wq              speichern + beenden" \
":q!              ohne Speichern beenden" \
":%s/alt/neu/g    global ersetzen" \
":vsp             vertikal teilen" \
":sp              horizontal teilen" \
":Tutor           eingebautes Vim-Tutorial"'

autoload -Uz compinit && compinit
# 4. Plugins für Komfort (zsh-autosuggestions und zsh-syntax-highlighting)
# WICHTIG: syntax-highlighting sollte immer als letztes Plugin geladen werden
#source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
#source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# 5. Starship Initialisierung
# Starship übernimmt das komplette Design deiner Befehlszeile
eval "$(starship init zsh)"

# 6. Fastfetch beim Start anzeigen
# Das sorgt dafür, dass du jedes Mal deine Systeminfos siehst, wenn du ein Terminal öffnest
fastfetch

# Speicherort und Größe der History definieren
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

# Smarte History-Optionen aktivieren
setopt APPEND_HISTORY          # Hängt neue Befehle an die Datei an, statt sie zu überschreiben
setopt SHARE_HISTORY           # Teilt die History live zwischen allen offenen Terminal-Tabs/Fenstern
setopt HIST_IGNORE_DUPS        # Speichert aufeinanderfolgende identische Befehle nur einmal
setopt HIST_IGNORE_SPACE       # Ignoriert Befehle, die mit einem Leerzeichen beginnen (perfekt, um Passwörter nicht in der History zu leaken)
setopt INC_APPEND_HISTORY      # Speichert den Befehl sofort nach dem Ausführen, nicht erst beim Beenden der Zsh

export PATH="/home/USER/.cargo/bin:$PATH"

# Created by `pipx` on 2026-09-09 15:35:24
export PATH="$PATH:/home/USER/.local/bin"
export TERMINAL=kitty
bindkey -M viins '^[[3~' delete-char
alias ssh='kitten ssh'
