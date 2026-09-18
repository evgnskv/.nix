## Initial setup

### Setting up nix
https://nix.dev/install-nix

#### Install command:
```sh
curl -L https://nixos.org/nix/install | sh
```
#### Confirmation:
```
nix --version
```

### Setting up nix-darwin
https://github.com/nix-darwin/nix-darwin

#### Creating folder:
```sh
stow -d "$HOME/.nix" -t "$HOME/.config" .config
```

#### Installing nix-darwin:
```sh
nix build --extra-experimental-features "nix-command flakes" ~/.config/nix-darwin#darwinConfigurations.Workstation.system
mv /etc/nix/nix.conf /etc/nix/nix.conf.before-nix-darwin
sudo ./result/sw/bin/darwin-rebuild activate

sudo env PATH="$PATH" darwin-rebuild switch --flake ~/.config/nix-darwin#Workstation
darwin-version
```

#### Rebuild:
```sh
sudo env PATH="$PATH" USER="$USER" darwin-rebuild switch \
    --flake ~/.config/nix-darwin#Workstation \
        && nix-collect-garbage -d \
        && nix store optimise
```

#### Get app hashsum:
```sh
nix store prefetch-file \
    --hash-type sha256 \
    https://github.com/jundot/omlx/releases/download/v0.5.1/oMLX-0.5.1-macos26-27.dmg
```
