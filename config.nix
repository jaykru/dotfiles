# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # package settings
  nixpkgs = {
    config = {
      allowUnfree = true; # :-((((
      mpv.youtubeSupport = true;
    };
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "kushiel"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicnant.
  networking.networkmanager.enable = true;

  # Select internationalisation properties.
  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };

  time.timeZone = "America/Los_Angeles";

  environment.systemPackages = with pkgs; [
    ed
    termite
    scrot
    haskellPackages.hledger
    haskellPackages.hledger-ui
    haskellPackages.hledger-web
    bc
    chromium
    androidenv.platformTools
    drive
    emacs
    file
    git
    gnupg
    keybase
    mlton
    mpd
    mpv
    mu
    offlineimap
    openssl
    jre9
    pavucontrol
    polybar
    powertop
    plan9port
    python3
    qutebrowser
    firefox
    radare2
    rofi
    qemu
    rtorrent
    sbcl
#    signal-desktop
    tdesktop #telegram-desktop
    rtorrent
    tcpdump
    smlnj
    steam
    stow
    sxhkd
    texlive.combined.scheme-full
    windowmaker
    zathura
    coq
    youtube-dl
    rlwrap
    rxvt_unicode-with-plugins
    w3m
    gnumake
    ranger
    plan9port
    go
    rustc
    htop
    pinentry
    dunst
    polybar
  ];

  programs.bash.enableCompletion = true;
  nixpkgs.config.pulseaudio = true;
  programs.gnupg.agent = { enable = true; enableSSHSupport = true; };
  

  powerManagement = {
    enable = true;
    powertop.enable = true;
  };
  
  services = {
    openssh.enable = true;
    avahi = {
      enable = true;
      hostName = "kushiel";
      browseDomains = [];
      nssmdns = true;
    };

    openafsClient = {
	    enable = true;
	    cellName = "reed.edu";
    };
    
    # for ledger nano s
    udev.extraRules = 
    ''
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="2581", ATTRS{idProduct}=="1b7c", MODE="0660", TAG+="uaccess", TAG+="udev-acl", GROUP="users"
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="2581", ATTRS{idProduct}=="2b7c", MODE="0660", TAG+="uaccess", TAG+="udev-acl", GROUP="users" 
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="2581", ATTRS{idProduct}=="3b7c", MODE="0660", TAG+="uaccess", TAG+="udev-acl", GROUP="users"
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="2581", ATTRS{idProduct}=="4b7c", MODE="0660", TAG+="uaccess", TAG+="udev-acl", GROUP="users"
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="2581", ATTRS{idProduct}=="1807", MODE="0660", TAG+="uaccess", TAG+="udev-acl", GROUP="users"
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="2581", ATTRS{idProduct}=="1808", MODE="0660", TAG+="uaccess", TAG+="udev-acl", GROUP="users"
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="2c97", ATTRS{idProduct}=="0000", MODE="0660", TAG+="uaccess", TAG+="udev-acl", GROUP="users"
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="2c97", ATTRS{idProduct}=="0001", MODE="0660", TAG+="uaccess", TAG+="udev-acl", GROUP="users"
      
    '';
    printing.enable = true;
    acpid.enable = true; 
    # hopefully will resolve screen tearing?
#    compton = {
#      enable          = true;
    #   fade            = true;
    #   inactiveOpacity = "0.9";
    #   shadow          = true;
    #   fadeDelta       = 4;
#    };

    
    xserver = {
      enable = true;
      layout = "us";
      libinput.enable = true;
#      inputClassSections = [
#      ''
#        Identifier "evdev touchpad off"
#        MatchIsTouchpad "on"
#        MatchDevicePath "/dev/input/event*"
#        Driver "evdev"
#        Option "Ignore" "true"
#      ''
#      ];
       displayManager.sddm = {
         enable = true;
       };
      desktopManager.plasma5.enable = true;
      #windowManager.windowmaker.enable = true;
      #windowManager.bspwm.enable = true;
    };

    gnome3.tracker.enable = true;
    
    mpd = {
      enable = true;
      user = "j";
      group = "users";
      startWhenNeeded = true;
      musicDirectory = "/home/j/goo/music";
      dataDir = "/home/j/.mpd";
      extraConfig = ''
        log_level "verbose"

        audio_output {
           type            "pulse"
           name            "Local MPD"
           server	   "127.0.0.1"
        }
      '';
   }; 
  };
  


  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.j = {
    isNormalUser = true;
    home = "/home/j";
    description = "Jay Kruer";
    extraGroups = ["wheel" "audio" "networkmanager"];
    uid = 1000;
  };

  systemd.user.services.emacs = {
    description = "Emacs: the extensible, self-documenting text editorn";


    serviceConfig = {
      Type      = "forking";
      #fixes PATH issues
      ExecStart = "${pkgs.bash}/bin/bash -c 'source ${config.system.build.setEnvironment}; exec emacs --daemon'";
      #ExecStart = "${pkgs.emacs}/bin/emacs --daemon";
      ExecStop  = "${pkgs.emacs}/bin/emacsclient --eval (kill-emacs)";
      Restart   = "always";
    };

    # I want the emacs service to be started with the rest of the user services
    wantedBy = [ "default.target" ];

  };

  environment.variables."EDITOR" = "${pkgs.emacs}/bin/emacslient";

  system.stateVersion = "18.03";

  hardware = {
    pulseaudio = {
      enable = true;
      support32Bit = true;
      package = pkgs.pulseaudioFull;
      extraConfig =
      ''
        #load-module module-esound-protocol-tcp
        load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1
        #load-module module-zeroconf-publish
      '';
    };
    cpu.intel.updateMicrocode = true;
    bluetooth.enable = true;
    trackpoint = { 
      emulateWheel = true;
      sensitivity = 255;
      speed = 255;
    };
    opengl = {
      driSupport = true;
      driSupport32Bit = true;
    };
  };

  fonts = {
  	enableFontDir = true;
	  enableGhostscriptFonts = true;
	  fonts = with pkgs; [
	    corefonts
	    inconsolata
	    unifont
	    go-font
      font-droid
	    noto-fonts
      noto-fonts-cjk
      font-awesome-ttf
	  ];
  };

  krb5 = {
    enable = true;
    domainRealm = "REED.EDU";
    defaultRealm = "REED.EDU";
    kdc = "kerberos-1.reed.edu\nkdc=kerberos-2.reed.edu"; #Lol nixos
    kerberosAdminServer = "kerberos-1.reed.edu";
  };
}
