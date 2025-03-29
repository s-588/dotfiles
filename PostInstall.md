# Post install

## Must have packages

```
emerge --ask --newuse sudo eselect-repository htop app-admin/sudo app-portage/cfg-update media-sound/alsa-utils sys-apps/pciutils sys-apps/usbutils app-portage/gentoolkit app-arch/7zip dev-vcs/git
```

## Adding new user

```
useradd -m -G wheel,audio,video,usb -s /bin/bash me
passwd me
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers
passwd -dl root
su me
cd
mkdir Downloads Documents
```

## Guru overlay

```
sudo emerge --newuse app-eselect/eselect-repository
sudo eselect repository enable guru
sudo emerge --sync guru
```

## Use git in portage

Change portage to git instead of rsync

```
sudo eselect repository disable gentoo
sudo eselect repository enable gentoo
sudo rm -r /var/db/repos/gentoo
sudo emaint sync -r gentoo
```

## Pipewire

You need to have pulseaudio USE flag in make.conf

```
echo "media-video/pipewire pipewire-alsa" | sudo tee -a /etc/portage/package.use/pipewire >> /dev/null
sudo emerge pipewire pulseaudio wireplumber
sudo usermod -rG audio,pipewire me
systemctl --user disable --now pulseaudio.socket pulseaudio.service
systemctl --user enable --now pipewire-pulse.socket wireplumber.service pipewire.service
```

## Virtualization

I use Qemu/KVM with virt-manager for virtualization

```
echo "app-emulation/qemu opengl alsa gtk keyutils ncurses pipewire plugins spice udev usb usbredir virgl vte zstd" | sudo tee -a /etc/portage/package.use/qemu >> /dev/null
echo "app-emulation/libvirt udev qemu virt-network nfs nbd parted policykit pcap numa fuse macvtap vepa" | sudo tee -a /etc/portage/package.use/libvirt >> /dev/null
echo "app-emulation/virt-manager gui policykit" | sudo tee -a /etc/portage/package.use/virt-manager >> /dev/null
sudo emerge qemu libvirt virt-manager
sudo mkdir -p /etc/polkit-l/localauthority/50-local.d
echo "[Allow group libvirt management permissions]
Identity=unix-group:libvirt
Action=org.libvirt.unix.manage
ResultAny=yes
ResultInactive=yes
ResultActive=yes" | sudo tee -a /etc/polkit-l/localauthority/50-local.d/org.libvirt.unix.manage.pkla >> /dev/null
sudo gpasswd me kvm
sudo gpasswd me libvirt
sudo systemctl enable --now libvirtd
```

## Flatpak with flathub

```
emerge --ask sys-apps/flatpak
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
```

### Power management

```
sudo emerge --ask --newuse sys-power/cpupower sys-power/powertop sys-power/thermald sys-power/tlp
sudo systemctl enable --now thermald tlp
sudo tlp start
```

Now unplug your AC adapter and calibrate powertop:

```
sudo powertop --calibrate
sudo powertop --auto-tune
```
