{ pkgs }: {
  deps = [
    pkgs.xorg.xorgserver
    pkgs.xvfb-run
    pkgs.x11vnc
    pkgs.chromium
    pkgs.openbox
    pkgs.xdotool
    pkgs.python3
    pkgs.python312Packages.websockify
  ];
}
