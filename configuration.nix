# NixOS-Konfiguration. Lanzaboote wird in flake.nix eingebunden.
{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./omny.nix
    ./moon.nix
    ./security.nix
  ];

    hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-compute-runtime
    ];
  };

  hardware.cpu.intel.npu.enable = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Bootloader: lanzaboote (Secure Boot) ersetzt systemd-boot
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
    autoGenerateKeys.enable = true;
    configurationLimit = 10;
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.initrd.kernelModules = [ "xe" ];

  # LUKS: Passwort oder YubiKey (FIDO2 mit PIN), grafisch ueber Plymouth
  boot.initrd.systemd.enable = true;
  boot.initrd.luks.devices."luks-91e9483d-831d-4927-842c-e993d361fa8d".crypttabExtraOpts = [ "fido2-device=auto" "tries=0" ];
    boot.plymouth = {
    enable = true;
    theme = "wired";
    themePackages = [
      (pkgs.runCommand "plymouth-theme-wired" { } ''
        dir=$out/share/plymouth/themes/wired
        mkdir -p $dir
        cp ${./plymouth-wired}/* $dir/
        chmod -R u+w $dir
        sed -i "s|@THEMEDIR@|$dir|g" $dir/wired.plymouth
      '')
    ];
  };
  boot.plymouth.font = "${pkgs.dejavu_fonts}/share/fonts/truetype/DejaVuSansMono.ttf";
  boot.consoleLogLevel = 0;
  boot.initrd.verbose = false;

  # Swap und Hibernate
  swapDevices = lib.mkForce [ { device = "/swap/swapfile"; } ];
  boot.resumeDevice = "/dev/mapper/luks-91e9483d-831d-4927-842c-e993d361fa8d";
  #Da
  boot.kernelParams = [ "quiet" "splash" "resume_offset=3586666"  "secretmem.enable=0" ];
  services.power-profiles-daemon.enable = true;


#LAVD
  services.scx = {
    enable = true;
    scheduler = "scx_lavd";
    extraArgs = [ "--autopilot" ];
  };

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  networking.networkmanager.plugins = [ pkgs.networkmanager-openvpn ];
  time.timeZone = "Europe/Berlin";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.displayManager.autoLogin = {
    enable = true;
    user = "USER";
  };
  systemd.services.display-manager.preStart = ''
    ${pkgs.coreutils}/bin/sleep 5
  '';

  services.howdy = {
    enable = true;
    settings.video = {
      device_path = "/dev/video2";
      dark_threshold = 85;
    };
  };
  security.pam.howdy.enable = false;
  security.pam.services.kde.howdy = {
    enable = true;
    control = "sufficient";
  };

  services.desktopManager.plasma6.enable = true;
  services.xserver.xkb = {
    layout = "de";
    variant = "";
  };

  systemd.user.tmpfiles.users.USER.rules = [
    "f+ %h/.config/ksplashrc 0644 - - - [KSplash]\\nEngine=KSplashQML\\nTheme=Lain\\n"
  ];


  #Shell
  console.keyMap = "de";
  services.printing.enable = true;

  environment.etc."xdg/kitty/kitty.conf".text = ''
  map ctrl+c copy_to_clipboard
  map ctrl+v paste_from_clipboard
  map ctrl+shift+c send_text all \x03
  map ctrl+shift+v send_text all \x16
'';
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  services.fprintd.enable = true;
  security.pam.services.sudo.fprintAuth = true;
  security.pam.services.sddm.fprintAuth = false;
  security.pam.services.login.fprintAuth = false;

  security.pam.services.sudo.rules.auth.fprintd.args = [ "timeout=10" "max-tries=1" ];

  programs.zsh = {
  enable = true;
  enableCompletion = true;

  autosuggestions.enable = true;
  syntaxHighlighting.enable = true;

  histSize = 50000;

  setOptions = [
    "HIST_IGNORE_ALL_DUPS"
    "SHARE_HISTORY"
    "HIST_FCNTL_LOCK"
  ];

  shellAliases = {
    l = "eza";
    ll = "eza -lah --git";
    la = "eza -a";
    lt = "eza --tree --level=2";
    lta = "eza --tree --level=3 -a";

    g = "git";
    gs = "git status";
    gd = "git diff";
    gl = "git log --oneline --graph --decorate";
    lg = "lazygit";

    nd = "nix develop";
    ns = "nix shell";
    nr = "nix run";

    ports = "ss -tulpn";
    top = "btop";
    cat = "bat";
  };

  interactiveShellInit = ''
    # fzf
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_DEFAULT_OPTS='--height=40% --layout=reverse --border --info=inline'
    export FZF_CTRL_T_OPTS='--preview "bat --color=always --style=numbers --line-range=:200 {}"'

    # zoxide
    eval "$(zoxide init zsh)"

    # Atuin – nach fzf laden, damit Ctrl-R bei Atuin landet
    eval "$(atuin init zsh)"

    # nix-your-shell
    nix-your-shell zsh | source /dev/stdin

    # Yazi: beim Beenden in das gewählte Verzeichnis wechseln
    function y() {
      local tmp="$(mktemp -t yazi-cwd.XXXXXX)"
      yazi "$@" --cwd-file="$tmp"
      if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        builtin cd -- "$cwd"
      fi
      rm -f -- "$tmp"
    }
  '';
  };

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    gtk3 glib libepoxy fontconfig libGL libxml2_13
  ];

  # LD_PRELOAD-Patch fuer OVMS: fuegt das von Zed verlangte id-Feld ein
  environment.etc."ovms/libovms-id.so".source = "${pkgs.runCommandCC "ovms-id" { } ''
    mkdir -p $out/lib
    $CC -O2 -shared -fPIC -o $out/lib/libovms-id.so ${./ovms-id.c} -ldl
  ''}/lib/libovms-id.so";

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  users.users."USER" = {
    isNormalUser = true;
    description = "USER";
    shell = pkgs.zsh;
    extraGroups = [ "networkmanager" "wheel" "wireshark" "dialout" "docker" ];
    packages = with pkgs; [
      kdePackages.kate
    ];
  };

  fonts.packages = with pkgs; [ nerd-fonts.ubuntu-mono ];

#Firewall
  networking.firewall.allowedTCPPorts = [ 53317 ];
  networking.firewall.allowedUDPPorts = [ 53317 ];
  programs.localsend.enable = true;
  programs.kdeconnect.enable = true;
  programs.firefox.enable = true;
  programs.steam.enable = true;
  services.udev.extraRules = ''
  SUBSYSTEM=="hidraw", KERNEL=="hidraw*", ATTRS{idVendor}=="046d", TAG+="uaccess"
  SUBSYSTEM=="hidraw", KERNEL=="hidraw*", KERNELS=="0005:046D:*", TAG+="uaccess"
'';
  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark;
  };
  programs.amnezia-vpn.enable = true;

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [
    "openssl-1.1.1w"
  ];

  # Die bisherige systemPackages-Liste steht jetzt in packages.json.
  programs.nixstore = {
    enable = true;
    flake = "/etc/nixos";
    packagesFile = ./packages.json;
    packagesFilePath = "/etc/nixos/packages.json";
    terminalCommand = "${pkgs.kitty}/bin/kitty --class nixstore --title NixStore";
  };

  # Snapper: niedrigere Limits, Cleanup jede Stunde
  services.snapper = {
    snapshotInterval = "hourly";
    cleanupInterval = "1h";
    configs.home = {
      SUBVOLUME = "/home";
      ALLOW_USERS = [ "USER" ];
      TIMELINE_CREATE = true;
      TIMELINE_CLEANUP = true;
      TIMELINE_LIMIT_HOURLY = 5;
      TIMELINE_LIMIT_DAILY = 5;
      TIMELINE_LIMIT_WEEKLY = 2;
      TIMELINE_LIMIT_MONTHLY = 1;
      TIMELINE_LIMIT_YEARLY = 0;
    };
    configs.root = {
      SUBVOLUME = "/";
      TIMELINE_CREATE = true;
      TIMELINE_CLEANUP = true;
      TIMELINE_LIMIT_HOURLY = 3;
      TIMELINE_LIMIT_DAILY = 3;
      TIMELINE_LIMIT_WEEKLY = 1;
      TIMELINE_LIMIT_MONTHLY = 0;
      TIMELINE_LIMIT_YEARLY = 0;
      NUMBER_CLEANUP = true;
      NUMBER_LIMIT = "10";
    };
  };

  environment.shellAliases.rebuild =
    "sudo snapper -c root create -c number -d 'vor rebuild' && sudo nixos-rebuild switch";

    environment.shellAliases.update =
    "sudo systemd-inhibit --what=idle:sleep:handle-lid-switch --why='NixOS Update' sh -c 'nix flake update --flake /etc/nixos && snapper -c root create -c number -d \"vor update\" && nixos-rebuild switch'";

  environment.sessionVariables.SUDO_EDITOR = "nvim";

  services.keyd = {
    enable = true;
    keyboards.default = {
      ids = [ "*" ];
      settings.main = {
        "leftshift+leftmeta+f23" = "print";
      };
    };
  };

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  # Tastatur: der Controller verschluckt bei Fn+C das Loslassen von C.
  # Der Treiber erzeugt deshalb selbst ein Loslassen fuer C (Scancode 2e).
  services.udev.extraHwdb = ''
    evdev:name:AT Translated Set 2 keyboard:*
     KEYBOARD_KEY_2e=!c
  '';

  virtualisation.podman.enable = true;
  virtualisation.docker.enable = true;


  xdg.mime = {
    enable = true;
    defaultApplications."x-scheme-handler/termius" =
      [ "termius-app.desktop" ];
  };

  #Fan
    services.thinkfan = {
    enable = true;

    sensors = [
      {
        type = "hwmon";
        query = "/sys/class/hwmon";
        name = "coretemp";
        indices = [ 1 2 6 10 14 34 35 36 37 ];
      }
      {
        type = "hwmon";
        query = "/sys/class/hwmon";
        name = "thinkpad";
        indices = [ 1 3 5 6 7 ];
      }
      {
        type = "hwmon";
        query = "/sys/class/hwmon";
        name = "nvme";
        indices = [ 1 ];
      }
    ];

    fans = [
      {
        type = "tpacpi";
        query = "/proc/acpi/ibm/fan";
      }
    ];

    # Stufe / herunterregeln unter / hochregeln über (°C)
    levels = [
      [ 0               0  55 ]
      [ 1              48  62 ]
      [ 2              57  67 ]
      [ 3              62  72 ]
      [ 5              67  77 ]
      [ 7              72  85 ]
      [ "level auto"   80  32767 ]
    ];
  };

     environment.systemPackages = [
    (pkgs.writeShellScriptBin "ruhezustand" ''
      ${pkgs.procps}/bin/pkill -u "$USER" -f bitwarden
      for i in $(${pkgs.coreutils}/bin/seq 1 20); do
        ${pkgs.gnugrep}/bin/grep -q disk /sys/power/state && break
        ${pkgs.coreutils}/bin/sleep 0.5
      done
      systemctl hibernate
    '')
  ];

  #USB

  boot.kernel.sysctl = {
    "vm.dirty_background_bytes" = 16777216;
    "vm.dirty_bytes" = 4294967296;
    "vm.dirty_writeback_centisecs" = 100;
    "vm.dirty_expire_centisecs" = 100;
  };

  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  # Nicht beim Update auf eine neue NixOS-Version aendern.
  system.stateVersion = "26.05";
}
