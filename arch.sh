#!/usr/bin/env bash


pacman -Syu --needed --noconfirm intel-ucode dosfstools arch-install-scripts linux-zen-headers nvidia-dkms nouveau
genfstab -p -U / > /etc/fstab



systemctl enable fstrim.timer

sed -i 's/GRUB_DEFAULT=0/GRUB_DEFAULT=saved/' /etc/default/grub
sed -i 's/#GRUB_SAVEDEFAULT="true"/GRUB_SAVEDEFAULT="true"/' /etc/default/grub
sed -E 's/GRUB_CMDLINE_LINUX_DEFAULT="(.*) quiet"/GRUB_CMDLINE_LINUX_DEFAULT="\1"/' /etc/default/grub
echo "" >> /mnt/etc/default/grub
grub-install /dev/sda
grub-mkconfig -o "/boot/grub/grub.cfg"

sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers

pacman -Syu --needed --noconfirm intel-ucode dosfstools arch-install-scripts linux-zen-headers nvidia-dkms nouveau reflector git bluedevil breeze-gtk discover drkonqi kdeplasma-addons kinfocenter kscreen ksysguard kwayland-integration plasma-browser-integration sddm plasma-desktop plasma-nm plasma-pa plasma-thunderbolt plasma-workspace-wallpapers powerdevil sddm-kcm user-manager xdg-desktop-portal-kde breeze-grub kde-gtk-config plasma-wayland-session kcron ksystemlog dolphin dolphin-plugins kate kdialog kfind khelpcenter konsole kwrite gwenview kcolorchooser kdegraphics-thumbnailers kolourpaint kruler spectacle dragon ffmpegthumbs kdenetwork-filesharing kget krdc zeroconf-ioslave kio-extras kapptemplate kcachegrind kompare ark filelight kcalc kdf yakuake bleachbit
systemctl enable sddm.service
sudo bash -c "echo -e \"fraction\nfraction\nfraction\nfraction\n\" | su assem -c \"cd /home/assem && git clone https://aur.archlinux.org/yay.git && (cd yay && makepkg -si --noconfirm) && rm -rf yay\""
sudo yay -S google-chrome
