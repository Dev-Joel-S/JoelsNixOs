{ config, pkgs, inputs, ... }:
let
  omny = inputs.omnyssh.packages.${pkgs.stdenv.hostPlatform.system}.default;
  omny-run = pkgs.writeShellScript "omny-run" ''
    export HOME=/home/omny
    cd "$HOME"
    exec ${omny}/bin/omny
  '';
in {
  users.users.omny = {
    isNormalUser = true;
    home = "/home/omny";
    homeMode = "700";
  };

  security.sudo.extraRules = [{
    users = [ "USER" ];
    runAs = "omny";
    commands = [{ command = "${omny-run} \"\""; options = []; }];
  }];

  environment.shellAliases.sshm = "sudo -u omny ${omny-run}";
}
