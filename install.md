# Install Guide

This guide is meant to outline how to install NixOS onto computer with a few requirements.
Those are:

* encrypted partition
* uefi support

As time goes on these requirements may grow, but this document is meant to outline how to properly install and configure NixOS around these. The current version of NixOS at the time of writing is `15.09`.

## Prerequisites

You have the ISO for NixOS on your bootable media device. e.g. USB, CD, DVD, etc.
You also have the configuration files you want from this repo. You can possibly put them on another media device, ideally USB unless you have two disc readers in your computer. You can also download the repo with `curl` or `wget`. I'll be showing how to do that below.

```shell
wget "https://gitlab.com/seanstrom/nix-files/repository/archive.zip?ref=master" -O nix-files.zip
```

This will download the configuration files as a zip. Hopefully the install will be able to unzip it.

## Disk Partitions

* bios boot partition 100M
* efi boot partition 200M
* encrypted partition

```
$ gdisk /dev/sda

n       # new partition
<enter> # default partition #
<enter> # default start location
+100M   # size 100MB
ef02    # type boot

n       # new partition
<enter> # default partition #
<enter> # default start location
+512M   # size 512MB
ef00    # type boot

n       # new partition
<enter> # default partition #
<enter> # default start location
<enter> # size remaining space
<enter> # type default

w       # write partitions
y       # confirm
```

```


