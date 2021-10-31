# Notes for installing Arch Linux

This is a supplement to the [installation guide] available in the Arch Wiki.
These tips are not exhaustive.


## Set up live USB installer

Use cat, it's safer than dd and easier to remember:

    sudo -i
    cat /path/to/archlinux.iso > /dev/sd<X>; sync
    exit


If that doesn't work try [Unetbootin] or the openSUSE [imagewriter] instead.
For Windows, [Rufus] seems reliable.


## Boot live installer

Need to know firmware settings access key
(look up manufacturer/motherboard manual),
often F2, <Delete> or F12.
Press during boot, before OS starts.
In firmware settings, change to UEFI boot mode if not default.
Select the USB as first boot option.
Might need to use Legacy boot mode if that doesn't work.
Usually need to disable secure boot.


## Partitioning and formatting

Use GPT if booting in UEFI mode, it will allow windows dual-boot if necessary.
UEFI has superseded BIOS;
most PC's will boot with UEFI unless in Legacy mode.
The `systemd-boot` bootloader (recommended) requires UEFI.

In `fdisk`, create a GPT table with `g` before adding the partitions.

For UEFI, remember to format the boot partition as FAT32:

    mkfs.vfat -F32 -n EFI /dev/<boot_partition>


Label the root partition using `-L` instead:

    mkfs.ext4 -L ROOT /dev/<root_partition>


Initialise the swap partition as well:

    mkswap /dev/<swap_partition>
    swaplabel -L SWAP /dev/<swap_partition>


Check the labels:

    ls -l /dev/disk/by-label


## Mount the drives

Remember to mount the boot partition (IMPORTANT!)

    mkdir /mnt/boot
    mount /dev/<boot_partition> /mnt/boot


Necessary mount point depends on bootloader, /mnt/boot is for systemd-boot.

Remember, swap isn't mounted like that, just do `swapon /dev/<swap_partition>`.

Check with `lsblk -f`.


## Example pacstrap command

**NOTE: Use `intel-ucode` or `amd-ucode` depending on processor.**
**NOTE: `iwd` is for wireless adapters, not needed for ethernet setups.**

Something like this:

    pacstrap /mnt base base-devel linux linux-firmware intel-ucode neovim iwd sudo reflector zsh zsh-completions man-db


To get the python host for neovim working, you also need `python-pynvim`.


## Networking and wifi using iwd/iwctl

Don't use real name(s) or hardware name(s) for `/etc/hostname`.
Use something short, only needs to be unique among LAN devices.
All lowercase, something like "tango" or "crimson".
Don't use location names, see also <https://tools.ietf.org/html/rfc1178>.

For wifi, create the file `/etc/systemd/network/20-wireless.network` with:

    [Match]
    Name=wlan0

    [Network]
    DHCP=yes
    IPv6PrivacyExtensions=yes


**NOTE: Change `wlan0` to match whatever is reported by `iwctl station list`.**

Enable the network daemon with `systemctl enable systemd-networkd`.
Enable the DNS daemon with `systemctl enable systemd-resolved`.
Enable the wireless interface with `systemctl enable iwd`.
Use `iwctl` to connect to networks.

*TODO: Wireless certificates (?) , `crda` ...*


## Configure systemd-boot

*TODO: Tips for EFISTUB as an alternative*

After chrooting into `/mnt`, run `bootctl --path=/boot install`.
If you mounted the boot partition somewhere else, change the path accordingly.

Set up automatic bootloader updates by creating the file

`/etc/pacman.d/hooks/100-systemd-boot.hook` with:
    [Trigger]
    Type = Package
    Operation = Upgrade
    Target = systemd

    [Action]
    Description = Updating systemd-boot
    When = PostTransaction
    Exec = /usr/bin/bootctl update


**NOTE: Only works if secure boot is disabled, otherwise check the wiki...**

Next edit `/boot/loader/loader.conf` to contain:

    default arch.conf
    timeout 4
    console-mode max
    editor no


If it works, comment out the `timeout 4` line later to stop seeing the menu.

Now create `/boot/loader/entries/arch.conf` with:

    title Arch Linux
    linux /vmlinuz-linux
    initrd /intel-ucode.img
    initrd /initramfs-linux.img
    options root="LABEL=ROOT" rw loglevel=3 quiet splash


For HiDPI screens, add `fbcon=font:TER16x32` to the options.


## Troubleshooting

> No /sys/firmware/efi/ directory

Turn off CSM in firmware settings.


> Can't boot

Maybe the boot partition isn't being mounted.
Try going from the `genfstab` section again, this time use `-L` and
check that `/mnt/etc/fstab` has labels instead of UUID codes.
Or, replace the codes with the partition device names like `/dev/mmcblk0p1` etc.

If you had to fiddle with things to get the boot working, double check that all
the necessary images are in `/boot`, e.g. `ls /boot`:

    EFI initramfs-linux-fallback.img initramfs-linux.img intel-ucode.img loader vmlinuz-linux


Otherwise reinstall the packages (change the *-ucode* to match processor manufacturer):

    pacman -S linux linux-firmware intel-ucode


## Minimal post-install setup

Get `zsh-completions`, set zsh as default shell with `chsh -s /bin/zsh` and relog.

Set up reflector for automatic mirrorlist refreshing by editing
`/etc/xdg/reflector/reflector.conf` and setting the desired countries.
Then enable and start `reflector.service` as well as `reflector.timer` daemons.

For laptops, it's worth getting `tlp` and enabling `tlp.service` (power saving).

To allow `sudo` for all users added to the `wheel` group, edit
`/etc/sudoers` and uncomment `%wheel ALL=(ALL) ALL`.

Make admin user who also uses zsh shell by default:

    useradd -m -G wheel -s /bin/zsh <name>
    passwd <name>


Install `git` and set up a minimal, convenient `~/.gitconfig`, e.g.:

    [user]
        name = <name>
        email = <name>@<provider.com>
    ; Fill out and uncomment to set up git send-email.
    ; Requires perl-authen-sasl perl-net-smtp-ssl and perl-mime-tools packages.
    ; [sendemail]
    ;     smtpServer = <server>
    ;     smtpServerPort = <port>
    ;     smtpUser = <name>@<provider.com>
    ;     smtpEncryption = tls
    [url "https://aur.archlinux.org/"]
        insteadOf = "aur:"
    ; Requires openssh package.
    ; [url "ssh://aur@aur.archlinux.org/"]
    ;     pushInsteadOf = "https://aur.archlinux.org/"
    ; [url "git@github.com:"]
    ;     pushInsteadOf = "https://github.com/"
    ; [url "git@git.sr.ht:"]
    ;     pushInsteadOf = "https://git.sr.ht/"
    [pull]
        ff = only
    [init]
        defaultBranch = <branch_name>
    [alias]
        s = status --short
        l = log --all --decorate --oneline --graph
        c = commit
        d = diff
        last = log -1 HEAD
        unstage = reset HEAD --
        nuke = !sh -c 'git branch -d $1 && git push origin :$1' -


Set a better login greeter, change `/etc/issue` to:

    \d \t (\U) \n:\l


## Timers and backups

Get `pacman-contrib` and `systemctl enable --now paccache.timer`, to clean
old pacman cache.

Verify that `fstrim` is installed and `systemctl enable --now fstrim.timer`,
to prolong life of SSD drives.

Make sure the `reflector.timer` is running (see above).

Get `logrotate` and `systemctl enable --now logrotate.timer`,
to rotate (clean) log files weekly (optional).

*TODO: Notes about backup timers*
*TODO: Notes about copying files via ssh*
*TODO: Notes about rsync and physical backups (see backup alias)*


## Firewall and hardening (recommended)

You might want to install and enable AppArmor, some apps provide profiles...
It probably can't hurt, but it's also not very useful without aduting and creating profiles.
Check the [AppArmor wiki article] for instructions.

For the userspace, there is bubblewrap.
Create a script, and run (but it will take some time to become familiar with the options).
Might also want to create new .desktop files (e.g. in .local/share/applications) to run the scripts.

Some examples at: <https://github.com/darrenldl/sandboxing>.

Install `ufw` for firewall, verify that `iptables.service` is disabled,
enable and start `ufw.service` and run:

    ufw default reject
    ufw allow from 192.168.0.0/24
    ufw limit ssh
    ufw enable


Also allow the Tor port if you want:

    ufw allow 9050


Edit `/etc/sysctl.d/51-kexec-restrict.conf` to contain
`kernel.kexec_load_disabled = 1` to disable switching kernels at runtime.

Unless setting up a server, edit `/etc/sysctl.d/99-network.conf` to contain:

    net.ipv4.tcp_syncookies = 1
    net.ipv4.conf.default.rp_filter = 1
    net.ipv4.conf.all.rp_filter = 1
    net.ipv4.conf.all.accept_redirects = 0
    net.ipv4.conf.default.accept_redirects = 0
    net.ipv4.conf.all.secure_redirects = 0
    net.ipv4.conf.default.secure_redirects = 0
    net.ipv6.conf.all.accept_redirects = 0
    net.ipv6.conf.default.accept_redirects = 0
    net.ipv4.conf.all.send_redirects = 0
    net.ipv4.conf.default.send_redirects = 0


source: <https://wiki.archlinux.org/index.php/Sysctl#TCP/IP_stack_hardening>


## Better font rendering (recommended)

After installing some good fonts like `ttf-liberation` and `noto-fonts` (check
the other notes files for recommendations), enable some `freetype2` preset options:

    sudo ln -s /usr/share/fontconfig/conf.avail/70-no-bitmaps.conf /etc/fonts/conf.d
    sudo ln -s /usr/share/fontconfig/conf.avail/10-sub-pixel-rgb.conf /etc/fonts/conf.d
    sudo ln -s /usr/share/fontconfig/conf.avail/11-lcdfilter-default.conf /etc/fonts/conf.d


## Importing dotfiles (optional)

Install a ssh program like `openssh` if you don't have one, and set up the `sshd` service.
Edit `/etc/ssh/sshd_config` and uncomment the line:

    HostKey /etc/ssh/ssh_host_ed25519_key

and edit other things if you want, check the Arch wiki [SSH protection] article for some ideas.

After enabling and starting the `sshd` service, try to connect via another machine:

    ssh <admin>@<LAN_ip_of_new_computer>

The LAN ip is what comes after "src" in `ip route`.

Copy PGP keys to the new machine with `scp`:

    gpg --export-secret-keys >keyfile
    scp keyfile <user@new_machine>:

and import them on the other side:

    ssh <user@new_machine>
    gpg --import keyfile
    rm keyfile

Get `pass` to manage passwords, and set up a password store:

    pass init "<key_id>"

Generate a password for a new ssh key, e.g.:

    pass generate "ssh/sourcehut@$HOST"

Set up a new key for the remote host that holds the dotfiles, e.g. sourcehut:

    ssh-keygen -t ed25519 -C "sourcehut@$HOST" -f ~/.ssh/sourcehut -P $( pass ssh/sourcehut@$HOST )

Next ssh needs to be told where to find the keys, so make a `~/.ssh/config`:

    Host *
        AddKeysToAgent yes
    Host aur.archlinux.org
        User aur
        IdentityFile ~/.ssh/aur
    Host git.sr.ht
        IdentityFile ~/.ssh/sourcehut


Use yadm to clone the dotfiles with:

    yadm clone <remote_repository>

and resolve local conflicts if necessary.

Generate another key for pushing to AUR if necessary.
Add the PUBLIC key to the account holding your remote dotfile repo.


## Automatically start graphical server (optional)

Add the following to ~/.zprofile.more
(and make sure it is sourced from ~/.zprofile):

    # vim:ft=zsh
    if [[ -z "$WAYLAND_DISPLAY" ]] && [[ $(tty) = /dev/tty1 ]]; then
        <command to start compositor>
    fi


To automatically set the login user for tty1:

    sudo mkdir /etc/systemd/system/getty@tty1.service.d
    sudoedit /etc/systemd/system/getty@tty1.service.d/override.conf


Add the contents:

    [Service]
    ExecStart=
    ExecStart=-/sbin/agetty -n -o <username> %I


Make sure the `getty@tty1` service is enabled.


[installation guide]: https://wiki.archlinux.org/index.php/Installation_guide
[unetbootin]: https://aur.archlinux.org/packages/unetbootin/
[imagewriter]: https://aur.archlinux.org/packages/imagewriter/
[rufus]: http://rufus.ie/
[AppArmor wiki article]: (https://wiki.archlinux.org/title/AppArmor)
[SSH protection]: (https://wiki.archlinux.org/title/OpenSSH#Protection)
