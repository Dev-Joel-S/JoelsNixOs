{ pkgs, ... }:
let
  moon-router = pkgs.writeShellScript "moon-router" ''
    export HOME=/home/omny
    cd "$HOME"
    exec ${pkgs.openssh}/bin/ssh -4 -o ConnectTimeout=10 \
      -o ServerAliveInterval=10 -o ServerAliveCountMax=3 \
      root@HOST.com 'sh -s' < ${./moon-remote.sh}
  '';

  moonstart = pkgs.writeShellScriptBin "moonstart" ''
    HOST="HOST.com"
    WAIT_SECONDS=40

    notify() {
        notify-send -a "Stream" "$@" 2>/dev/null || :
   ...
  '';
in {
  environment.systemPackages = [ moonstart ];

  security.sudo.extraRules = [{
    users = [ "USER" ];
    runAs = "omny";
    commands = [{ command = "${moon-router} \"\""; options = []; }];
  }];
}
