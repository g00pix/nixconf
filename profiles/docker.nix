{ pkgs, ... }:

{
  virtualisation.docker.enable = true;
  virtualisation.docker.autoPrune.enable = true;
  environment.systemPackages = with pkgs; [
    docker-compose
  ];
}
