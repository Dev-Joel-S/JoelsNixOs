{ config, pkgs, ... }:
let
  quickscan = pkgs.writeShellScriptBin "quickscan" ''
    list=$(mktemp)
    ${pkgs.findutils}/bin/find "$HOME" /tmp -xdev -type f -mtime -7 \
      -not -path "$HOME/.cache/*" \
      -not -path "$HOME/.local/share/containers/*" 2>/dev/null > "$list"
    echo "Scanne $(wc -l < "$list") Dateien der letzten 7 Tage..."
    ${pkgs.clamav}/bin/clamdscan --multiscan --fdpass --infected --file-list="$list" 2>&1 \
      | grep -v -e cli_realpath -e "Not supported file type"
    rm -f "$list"
    echo "Fertig."
  '';
in
{
  services.clamav = {
    daemon.enable = true;
    updater.enable = true;
    clamonacc.enable = true;
    daemon.settings = {
      OnAccessPrevention = true;
      OnAccessIncludePath = "/home/USER/Downloads";
      ExcludePath = "^/home/USER/\\.local/share/containers/";
    };
  };

  services.portmaster.enable = true;
  documentation.nixos.enable = false;

  environment.systemPackages = [ pkgs.lynis pkgs.vulnix quickscan ];

  environment.shellAliases = {
    virusscan = "sudo clamdscan --multiscan --fdpass --infected /home";
    audit = "sudo lynis audit system";
    vulns = "vulnix --system";
    scan = "sudo clamdscan --multiscan --fdpass --infected /home; sudo lynis audit system; vulnix --system";
  };

  boot.blacklistedKernelModules = [ "dccp" "sctp" "rds" "tipc" ];

  boot.kernel.sysctl = {
    "dev.tty.ldisc_autoload" = 0;
    "fs.protected_fifos" = 2;
    "fs.protected_regular" = 2;
    "fs.suid_dumpable" = 0;
    "kernel.kptr_restrict" = 2;
    "net.core.bpf_jit_harden" = 2;
    "net.ipv4.conf.all.send_redirects" = 0;
    "net.ipv4.conf.default.send_redirects" = 0;
    "net.ipv4.conf.all.accept_redirects" = 0;
    "net.ipv4.conf.default.accept_redirects" = 0;
    "net.ipv6.conf.all.accept_redirects" = 0;
    "net.ipv6.conf.default.accept_redirects" = 0;
  };
}
