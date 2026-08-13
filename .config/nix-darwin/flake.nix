{
  description = "Main system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";

    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };

    mac-app-util.url = "github:hraban/mac-app-util";

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
    };
  };

  outputs = inputs@{
        self
      , nix-darwin
      , nixpkgs
      , nix-homebrew
      , homebrew-core
      , homebrew-cask
      , mac-app-util
      , zen-browser
      , ...
    }:

  let
    username = "evgnskv";
    hostPlatform = "aarch64-darwin";

    configuration = { pkgs, config, ... }:

  let
    omlx-app = pkgs.stdenv.mkDerivation rec {
      pname = "omlx-app";
      version = "0.5.1";

      src = pkgs.fetchurl {
        url = "https://github.com/jundot/omlx/releases/download/v${version}/oMLX-${version}-macos26-27.dmg";
        sha256 = "sha256-CkSvyaJQcPfrWyjJeqP00gTrQGaZfJe06+deVKEepWE=";
      };

      sourceRoot = ".";
      __noChroot = true;
      dontPatch = true;
      dontConfigure = true;
      dontBuild = true;
      dontFixup = true;
      dontUpdateAutotoolsGnuConfigScripts = true;

      unpackPhase = ''
        mkdir -p ./mnt
        /usr/bin/hdiutil attach -readonly -mountpoint ./mnt -nobrowse -quiet $src
      '';

      installPhase = ''
        mkdir -p $out/Applications
        cp -R ./mnt/oMLX.app $out/Applications/oMLX.app
        /usr/bin/hdiutil detach ./mnt -quiet
      '';
    };

    cluely = pkgs.stdenv.mkDerivation rec {
      pname = "com.cluely.app";
      version = "latest";

      src = pkgs.fetchurl {
        url = "https://api.v2.cluely.com/desktop-download/mac/latest.dmg?glass=bisect";
        sha256 = "sha256-OCwEsCTkr1uKumvWUR4YvjjGImgiXw/xdxb3HAZApug=";
      };

      nativeBuildInputs = [
        pkgs.undmg
      ];

      sourceRoot = ".";

      unpackPhase = ''
        undmg $src
      '';

      installPhase = ''
        mkdir -p $out/Applications
        cp -R 'Cluely (New).app' $out/Applications/Cluely.app
      '';
    };

    altserver = pkgs.stdenv.mkDerivation rec {
      pname = "AltServer";
      version = "latest";

      src = pkgs.fetchurl {
        url = "https://cdn.altstore.io/file/altstore/altserver.zip";
        sha256 = "sha256-4InubJKI6Ql+NXCDlCEiakxGfOKYF7vFyE6xPzwksHY=";
      };

      nativeBuildInputs = [ pkgs.unzip ];
      sourceRoot = ".";

      dontPatch = true;
      dontConfigure = true;
      dontBuild = true;
      dontFixup = true;
      dontUpdateAutotoolsGnuConfigScripts = true;

      unpackPhase = ''
        unzip $src
      '';

      installPhase = ''
        mkdir -p $out/Applications
        cp -R AltServer.app $out/Applications/AltServer.app
      '';
    };

      in {

      system.primaryUser = username;
      system.startup.chime = false;

      # Touch ID
      security.pam.services.sudo_local.touchIdAuth = true;
      security.pam.services.sudo_local.reattach = true;

      services.openssh = {
        enable = true;

        extraConfig = ''
          PubkeyAuthentication yes
          AuthenticationMethods publickey
          PasswordAuthentication no
          KbdInteractiveAuthentication no
          PermitEmptyPasswords no
          PermitRootLogin no
        '';
      };

      system.defaults = {

        # Finder
        finder.FXPreferredViewStyle = "Nlsv";
        finder.FXEnableExtensionChangeWarning = false;
        finder.ShowPathbar = true;
        finder.AppleShowAllFiles = true;
        finder.AppleShowAllExtensions = true;
        NSGlobalDomain.AppleShowAllFiles = true;
        NSGlobalDomain.AppleShowAllExtensions = true;
        NSGlobalDomain.AppleShowScrollBars = "Always";

        # Mission Control
        spaces.spans-displays = true;
        #universalaccess.reduceMotion = true;
        NSGlobalDomain.NSWindowShouldDragOnGesture = true;
        NSGlobalDomain.NSAutomaticWindowAnimationsEnabled = false;
        dock.expose-group-apps = true;

        # Dock
        dock.static-only = true;
        dock.autohide = true;

        # Visuals
        NSGlobalDomain.AppleInterfaceStyle = "Dark";

        # Menu bar
        controlcenter.AirDrop = false;
        controlcenter.Bluetooth = false;
        controlcenter.Display = false;
        controlcenter.NowPlaying = false;
        controlcenter.Sound = false;
        controlcenter.BatteryShowPercentage = true;

        # Hot corner
        dock.wvous-tl-corner = 1;
        dock.wvous-tr-corner = 1;
        dock.wvous-bl-corner = 1;
        dock.wvous-br-corner = 1;

        # Typing
        NSGlobalDomain."com.apple.keyboard.fnState" = true;
        NSGlobalDomain.NSAutomaticCapitalizationEnabled = false;
        NSGlobalDomain.NSAutomaticDashSubstitutionEnabled = false;
        NSGlobalDomain.NSAutomaticInlinePredictionEnabled = false;
        NSGlobalDomain.NSAutomaticPeriodSubstitutionEnabled = false;
        NSGlobalDomain.NSAutomaticQuoteSubstitutionEnabled = false;
        NSGlobalDomain.NSAutomaticSpellingCorrectionEnabled = false;

        # Clock
        menuExtraClock.FlashDateSeparators = true;
        menuExtraClock.Show24Hour = true;
        menuExtraClock.ShowDate = 2;
        menuExtraClock.ShowDayOfWeek = false;

      };

      homebrew = {
        enable = true;
        onActivation = {
          autoUpdate = true;
          upgrade = true;
          cleanup = "zap";
        };

        brews = [
          "socktainer"
          ];

        casks = [
          "ghostty"
          "shortcat"
          "tunnelblick"
          "tailscale-app"
          "telegram-desktop"
          "obs"
          ];

        masApps = {
        #   "Apple Numbers" = 361304891;
        #   "Apple Keynote" = 361285480;
          };

      };

      environment.systemPackages =
        [
          pkgs.coreutils
          pkgs.ncdu

          pkgs.iproute2mac
          pkgs.wget
          pkgs.jq
          pkgs.yq

          pkgs.oh-my-zsh
          pkgs.fzf
          pkgs.ripgrep
          pkgs.lsd

          pkgs.stow
          pkgs.pam-reattach

          pkgs.container
          pkgs.podman
          pkgs.docker
          pkgs.devpod
        # pkgs.qemu
        # pkgs.libvirt

      	  pkgs.tmux
      	  pkgs.neovim
          pkgs.oh-my-zsh
          pkgs.macmon
      	  pkgs.aerospace
          pkgs.shortcat

          pkgs.keepassxc
          pkgs.obsidian
          pkgs.anki-bin
          pkgs.libreoffice-bin

          pkgs.itsycal
          pkgs.hidden-bar


        # omlx-app

         (inputs.zen-browser.packages."${hostPlatform}".beta-unwrapped.override {
           policies = {
             DisableAppUpdate = true;
             Preferences = {
                "security.webauthn.enable_macos_passkeys" = {
                  Value = true;
                  Status = "default";
                };
                "browser.ctrlTab.sortByRecentlyUsed" = {
                  Value = true;
                  Status = "default";
                };
              };
             ExtensionSettings = {
              "search@kagi.com" = {
                install_url = "https://addons.mozilla.org/firefox/downloads/latest/kagi-search-for-firefox/latest.xpi";
                installation_mode = "force_installed";
              };
               "uBlock0@raymondhill.net" = {
                 install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
                 installation_mode = "force_installed";
               };
               "idcac-pub@guus.ninja" = {
                 install_url = "https://addons.mozilla.org/firefox/downloads/latest/istilldontcareaboutcookies/latest.xpi";
                 installation_mode = "force_installed";
               };
                "vimium-c@gdh1995.cn" = {
                  install_url = "https://addons.mozilla.org/firefox/downloads/latest/vimium-c/latest.xpi";
                  installation_mode = "force_installed";
                };
             };
           };
         })

        ];

        programs.zsh = {
          enable = true;
          interactiveShellInit = ''
            export ZSH="${pkgs.oh-my-zsh}/share/oh-my-zsh"
            source "$ZSH/oh-my-zsh.sh"
          '';
        };

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";
      nixpkgs.config.allowUnfree = true;
    # nixpkgs.config.allowBroken = true;
    # nixpkgs.config.allowUnsupportedSystem = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;

      # The platform the configuration will be used on.
      # nixpkgs.hostPlatform = "aarch64-darwin";
      nixpkgs.hostPlatform = "${hostPlatform}";
        
    };
  in
  {

    darwinConfigurations."Workstation" = nix-darwin.lib.darwinSystem {
      modules = [
        configuration
        mac-app-util.darwinModules.default
        nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            # Install Homebrew under the default prefix
            enable = true;

            # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
            enableRosetta = true;

            # User owning the Homebrew prefix
            user = username;

            # Automatically migrate existing Homebrew installations
            autoMigrate = true;

            # Optional: Declarative tap management
            taps = {
              "homebrew/homebrew-core" = homebrew-core;
              "homebrew/homebrew-cask" = homebrew-cask;
            };

            # Optional: Enable fully-declarative tap management
            #
            # With mutableTaps disabled, taps can no longer be added imperatively with `brew tap`.
            mutableTaps = false;
          };
        }
            ({config, ...}: {
              homebrew.taps = builtins.attrNames config.nix-homebrew.taps;
            })
       ];
    };
  };
}
