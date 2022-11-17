环境准备
1. 需要一台 linux 主机， 可以是 x86或arm64架构，可以是物理机或虚拟机（但不支持win10自带的linux环境），需要具备root权限， 并且具备以下基本命令（只列出命令名，不列出命令所在的包名，因不同linux发行版的软件包名、软件包安装命令各有不同，请自己查询)： 
    losetup、lsblk(版本>=2.33)、blkid、uuidgen、fdisk、parted、mkfs.vfat、mkfs.ext4、mkfs.btrfs (列表不一定完整，打包过程中若发生错误，请自行检查输出结果并添加缺失的命令）

对于性能过剩的盒子，可以先安装 Armbian 系统，再安装 KVM 虚拟机实现多系统使用。其中 `OpenWrt` 系统的编译可以使用本仓库的 [mk_qemu-aarch64_img.sh](mk_qemu-aarch64_img.sh) 脚本进行制作，其安装与使用说明详见 [qemu-aarch64-readme.md](https://github.com/unifreq/openwrt_packit/blob/master/files/qemu-aarch64/qemu-aarch64-readme.md) 文档，更多系统如 Debian、Ubuntu、OpenSUSE、ArchLinux、Centos、Gentoo、KyLin、UOS 等可在相关网站查阅安装与使用说明。
