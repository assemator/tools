#!/usr/bin/env bash

genfstab -p -U /mnt > /mnt/etc/fstab

arch-chroot /mnt pacman -Syu --needed --noconfirm intel-ucode dosfstools arch-install-scripts linux-zen-headers nvidia-dkms nouveau

arch-chroot /mnt systemctl enable fstrim.timer

arch-chroot /mnt sed -i 's/GRUB_DEFAULT=0/GRUB_DEFAULT=saved/' /etc/default/grub
arch-chroot /mnt sed -i 's/#GRUB_SAVEDEFAULT="true"/GRUB_SAVEDEFAULT="true"/' /etc/default/grub
arch-chroot /mnt sed -E 's/GRUB_CMDLINE_LINUX_DEFAULT="(.*) quiet"/GRUB_CMDLINE_LINUX_DEFAULT="\1"/' /etc/default/grub
echo "" >> /mnt/etc/default/grub
arch-chroot /mnt grub-install /dev/sda
arch-chroot /mnt grub-mkconfig -o "/boot/grub/grub.cfg"

arch-chroot /mnt sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers

arch-chroot /mnt pacman -Syu --needed --noconfirm intel-ucode dosfstools arch-install-scripts linux-zen-headers nvidia-dkms nouveau reflector git bluedevil breeze-gtk discover drkonqi kdeplasma-addons kinfocenter kscreen ksysguard kwayland-integration plasma-browser-integration sddm plasma-desktop plasma-nm plasma-pa plasma-thunderbolt plasma-workspace-wallpapers powerdevil sddm-kcm user-manager xdg-desktop-portal-kde breeze-grub kde-gtk-config plasma-wayland-session kcron ksystemlog dolphin dolphin-plugins kate kdialog kfind khelpcenter konsole kwrite gwenview kcolorchooser kdegraphics-thumbnailers kolourpaint kruler spectacle dragon ffmpegthumbs kdenetwork-filesharing kget krdc zeroconf-ioslave kio-extras kapptemplate kcachegrind kompare ark filelight kcalc kdf yakuake bleachbit
arch-chroot /mnt systemctl enable sddm.service
arch-chroot /mnt sudo bash -c "echo -e \"fraction\nfraction\nfraction\nfraction\n\" | su assem -c \"cd /home/assem && git clone https://aur.archlinux.org/yay.git && (cd yay && makepkg -si --noconfirm) && rm -rf yay\""
arch-chroot /mnt sudo yay -S google-chrome
