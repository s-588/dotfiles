# Dotfiles installation

## Grub configuration

Grub config contain some settings and kernel parameters

```
sudo cp ./settings/grub/grub /etc/default/grub
```

## Kernel modules

```
sudo cp ./settings/kernel/.config /usr/src/linux/.config
sudo emerge gentoo-kernel --config
```

## Keyboard layout

I use real programmer dvorak btw

```
sudo cp ./settings/keyboard/evdev.xml /usr/share/X11/xkb/rules/evdev.xml
sudo cp ./settings/keyboard/rpd.map.gz /usr/share/keymaps/i386/dvorak/
sudo cp ./settings/keyboard/vconsole.conf /etc/vconsole.conf
```

# Shell

## Zsh

```
sudo emerge --ignore-default-opts app-shells/zsh app-shells/zsh-completions app-shells/zsh-syntax-highlighting
cp -r ./software/zsh/.* ~/
sudo chsh me -s /bin/zsh
```

## Fish

```
sudo emerge --ignore-default-opts app-shells/fish
cp -r ./software/fish ~/.config/
```

## Bash

```
sudo emerge --ignore-default-opts app-shells/bash-completion
cp ./software/bash/.bashrc ~/
```

# Window manager

## Hyprland

```
sudo emerge --ignore-default-opts gui-apps/hypridle gui-apps/hyprlock gui-apps/hyprpaper gui-apps/hyprshot gui-apps/kanshi gui-apps/waybar gui-apps/wl-clipboard gui-apps/wofi gui-libs/xdg-desktop-portal-hyprland gui-wm/hyprland app-misc/brightnessctl media-sound/playerctl
cp -r ./software/hypr ~/.config/
```

## i3

```
sudo emerge --ignore-default-opts x11-misc/dmenu x11-misc/dunst x11-misc/i3blocks x11-misc/i3lock-color x11-misc/i3status x11-misc/picom x11-misc/polybar x11-misc/rofi x11-misc/xcb x11-misc/xclip x11-misc/xwallpaper x11-wm/i3
cp -r ./software/i3 ~/.config/
```

# Vim

```
sudo cp ./settings/portage/package.use/tmux /etc/portage/package.use/
sudo cp ./settings/portage/package.use/node /etc/portage/package.use/
sudo cp ./settings/portage/package.use/noto-emoji /etc/portage/package.use/
sudo emerge  --ignore-default-opts app-emacs/rg app-editors/neovim sys-apps/fd sys-apps/ripgrep app-misc/tmux luarocks dev-vcs/git net-libs/nodejs media-fonts/fontawesome media-fonts/noto-emoji
cp -r ./software/tmux/.* ~/
cp -r ./software/nvim ~/.config/
```
