# Arch linux maintenance notes

## Pacman issues

If an update fails on an older Arch Linux machine,
try syncing only the keyring package first:

    sudo pacman -S archlinux-keyring

## Can't get past POST

If the computer can't get past POST
(BIOS splash appears, but you can't log in to the system after that for some reason)
then it usually means that either the Linux kernel is broken for your hardware,
or your graphics drivers are causing issues.
The system is still recoverable (so long as USB boot it possible, which is usually true).
You will need a live USB with the Arch Linux installer on it.
Boot from the USB and mount the broken system:

```
mount /dev/<home_partition> /mnt
mount /dev/<boot_partition> /mnt/boot
mount -t proc proc /mnt/proc
mount -t sysfs sys /mnt/sys
mount -o bind /dev /mnt/dev
```

where `/dev/<{home,boot}_partition>` are the partition names of the
home and boot file systems on your hard drive.
Then log into the broken system with `chroot /mnt`.
Finally, diagnose and fix the problem, by e.g. downgrading packages.
To downgrade e.g. the Linux kernel, use a command of the form

```
pacman -U /var/cache/pacman/pkg/linux-<version>.pkg.tar.zst
```
