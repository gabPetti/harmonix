{ pkgs, ... }:

{
  # OWASP ZAP -- the intercepting proxy/scanner for web app testing. Launched
  # as `zap`; its own workspace lives in ~/.ZAP, which it creates itself.
  home.packages = with pkgs; [
    zap
  ];
}
