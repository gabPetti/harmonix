{ pkgs, ... }:

{
  # Enable Bluetooth hardware service
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true; # Automatically power on the Bluetooth controller on boot
    
    settings = {
      General = {
        # Shows battery status of connected Bluetooth devices (headphones, controllers)
        Experimental = true;
        
        # FastConnectable improves re-connection speed for paired devices
        FastConnectable = true;
        
        # Enables modern Bluetooth Low Energy (BLE) privacy/address randomization
        Privacy = "device";
      };
    };
  };

  # Blueman provides the graphical interface and tray management daemon
  services.blueman.enable = true;

  # Ensure PipeWire is configured to handle Bluetooth audio codecs (A2DP, LDAC, AAC, AptX)
  services.pipewire = {
    wireplumber.configPackages = [
      (pkgs.writeTextDir "share/wireplumber/bluetooth.lua.d/51-bluez-config.lua" ''
        bluez_monitor.properties = {
          ["bluez5.enable-sbc-xq"] = true,
          ["bluez5.enable-msbc"] = true,
          ["bluez5.enable-hw-volume"] = true,
          ["bluez5.headset-roles"] = "[ hsp hfp dscp ]",
        }
      '')
    ];
  };

  # Install command-line tools for manual debugging/pairing
  environment.systemPackages = with pkgs; [
    bluez         # Provides standard bluetoothctl CLI tool
    bluez-tools   # Extra utility scripts
  ];
}
