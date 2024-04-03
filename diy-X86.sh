#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part1.sh
# Description: OpenWrt DIY script part 1 (Before Update feeds)
#

echo "开始 DIY 配置……"
echo "========================="

# 添加源
# sed -i '$a src-git helloworld https://github.com/fw876/helloworld;main' feeds.conf.default
#sed -i '$a src-git helloworld https://github.com/fw876/helloworld' feeds.conf.default
#sed -i '$a src-git xiaorouji https://github.com/xiaorouji/openwrt-passwall-packages' feeds.conf.default
#sed -i '$a src-git passwall https://github.com/xiaorouji/openwrt-passwall' feeds.conf.default

# 切换内核版本
# sed -i 's/KERNEL_PATCHVER:=5.15/KERNEL_PATCHVER:=5.4/g' ./target/linux/x86/Makefile

# 修改openwrt登陆地址,把下面的10.10.10.254修改成你需要的
sed -i 's/192.168.1.1/10.10.10.254/g' package/base-files/files/bin/config_generate

# 修改主机名字，把Unicorn修改成你喜欢的（不能纯数字或者使用中文）
sed -i "/uci commit system/i\uci set system.@system[0].hostname='Unicorn'" package/lean/default-settings/files/zzz-default-settings
sed -i "s/hostname='OpenWrt'/hostname='Unicorn'/g" ./package/base-files/files/bin/config_generate

function merge_package(){
    # 参数1是分支名,参数2是库地址。所有文件下载到openwrt/package/openwrt-packages路径。
    # 同一个仓库下载多个文件夹直接在后面跟文件名或路径，空格分开。
    trap 'rm -rf "$tmpdir"' EXIT
    branch="$1" curl="$2" && shift 2
    rootdir="$PWD"
    localdir=package/openwrt-packages
    [ -d "$localdir" ] || mkdir -p "$localdir"
    tmpdir="$(mktemp -d)" || exit 1
    git clone -b "$branch" --depth 1 --filter=blob:none --sparse "$curl" "$tmpdir"
    cd "$tmpdir"
    git sparse-checkout init --cone
    git sparse-checkout set "$@"
    mv -f "$@" "$rootdir"/"$localdir" && cd "$rootdir"
}
merge_package master https://github.com/vernesong/OpenClash luci-app-openclash
merge_package main https://github.com/Lienol/openwrt-package luci-app-filebrowser
merge_package main https://github.com/xiaorouji/openwrt-passwall luci-app-passwall
# merge_package master https://github.com/v2rayA/v2raya-openwrt v2raya luci-app-v2raya
merge_package master https://github.com/fw876/helloworld luci-app-ssr-plus dns2tcp lua-neturl mosdns redsocks2 shadow-tls shadowsocksr-libev tuic-client xray-core xray-plugin
merge_package main https://github.com/xiaorouji/openwrt-passwall-packages brook chinadns-ng dns2socks gn hysteria ipt2socks microsocks naiveproxy pdnsd-alt shadowsocks-rust simple-obfs sing-box ssocks tcping trojan-go trojan-plus trojan v2ray-core v2ray-plugin

# drop mosdns and v2ray-geodata packages that come with the source
find ./ | grep Makefile | grep v2ray-geodata | xargs rm -f
find ./ | grep Makefile | grep mosdns | xargs rm -f
git clone https://github.com/sbwml/luci-app-mosdns -b v5 package/mosdns
git clone https://github.com/sbwml/v2ray-geodata package/v2ray-geodata

# git clone  https://github.com/gdy666/luci-app-lucky.git package/lucky
# git clone https://github.com/sbwml/openwrt-alist.git package/openwrt-alist
git clone https://github.com/UnblockNeteaseMusic/luci-app-unblockneteasemusic.git package/luci-app-unblockneteasemusic

# Update feeds
./scripts/feeds update -a

# 修改 xxx 为默认主题,可根据你喜欢的修改成其他的（不选择那些会自动改变为默认主题的主题才有效果）
# sed -i 's/luci-theme-bootstrap/luci-theme-xxx/g' feeds/luci/collections/luci/Makefile

# 删除包
# rm -rf feeds/luci/themes/luci-theme-argon
rm -rf feeds/packages/multimedia/UnblockNeteaseMusic
rm -rf feeds/luci/applications/luci-app-unblockmusic
rm -rf feeds/packages/multimedia/UnblockNeteaseMusic-Go
rm -rf feeds/packages/net/mosdns
rm -rf feeds/luci/applications/luci-app-mosdns

# luci-app-argon-config
# git clone https://github.com/jerrykuku/luci-app-argon-config.git package/luci-app-argon-config
sed -i 's/system/services/g'  feeds/luci/applications/luci-app-argon-config/luasrc/controller/argon-config.lua

# luci-app-design-config
sed -i 's/system/services/g'  feeds/luci/applications/luci-app-design-config/luasrc/controller/*.lua

# 调整VPN服务到VPN菜单
# v2ray服务
sed -i 's/services/vpn/g' feeds/luci/applications/luci-app-v2ray-server/luasrc/controller/*.lua
sed -i 's/services/vpn/g' feeds/luci/applications/luci-app-v2ray-server/luasrc/model/cbi/v2ray_server/*.lua
sed -i 's/services/vpn/g' feeds/luci/applications/luci-app-v2ray-server/luasrc/view/v2ray_server/*.htm
# wireguard
sed -i 's/status/vpn/g' feeds/luci/applications/luci-app-wireguard/luasrc/controller/wireguard.lua
sed -i 's/92/2/g' feeds/luci/applications/luci-app-wireguard/luasrc/controller/wireguard.lua
# frps
sed -i 's/services/vpn/g' feeds/luci/applications/luci-app-frps/luasrc/controller/*.lua
sed -i 's/services/vpn/g' feeds/luci/applications/luci-app-frps/luasrc/model/cbi/frps/*.lua
sed -i 's/services/vpn/g' feeds/luci/applications/luci-app-frps/luasrc/view/frps/*.htm
# frpc
sed -i 's/services/vpn/g' feeds/luci/applications/luci-app-frpc/luasrc/controller/*.lua
sed -i 's/services/vpn/g' feeds/luci/applications/luci-app-frpc/luasrc/model/cbi/frp/*.lua
sed -i 's/services/vpn/g' feeds/luci/applications/luci-app-frpc/luasrc/view/frp/*.htm
# 花生壳内网穿透
sed -i 's/services/vpn/g' feeds/luci/applications/luci-app-phtunnel/luasrc/controller/oray/*.lua
sed -i 's/services/vpn/g' feeds/luci/applications/luci-app-phtunnel/luasrc/model/cbi/oray/*.lua
sed -i 's/services/vpn/g' feeds/luci/applications/luci-app-phtunnel/luasrc/view/oray/*.htm
# 蒲公英组网
sed -i 's/services/vpn/g' feeds/luci/applications/luci-app-pgyvpn/luasrc/controller/*.lua
sed -i 's/services/vpn/g' feeds/luci/applications/luci-app-pgyvpn/luasrc/model/cbi/*.lua
sed -i 's/services/vpn/g' feeds/luci/applications/luci-app-pgyvpn/luasrc/view/pgyvpn/*.htm

# 调整阿里云盘到存储菜单
sed -i 's/services/nas/g' package/luci-app-aliyundrive-webdav/luci-app-aliyundrive-webdav/luasrc/controller/*.lua
sed -i 's/services/nas/g' package/luci-app-aliyundrive-webdav/luci-app-aliyundrive-webdav/luasrc/model/cbi/aliyundrive-webdav/*.lua
sed -i 's/services/nas/g' package/luci-app-aliyundrive-webdav/luci-app-aliyundrive-webdav/luasrc/view/aliyundrive-webdav/*.htm

# 调整upnp到网络菜单
sed -i 's/services/network/g' feeds/luci/applications/luci-app-upnp/luasrc/controller/*.lua
sed -i 's/services/network/g' feeds/luci/applications/luci-app-upnp/luasrc/model/cbi/upnp/*.lua
sed -i 's/services/network/g' feeds/luci/applications/luci-app-upnp/luasrc/view/*.htm

# 修改插件名字
sed -i 's/"阿里云盘 WebDAV"/"阿里云盘"/g' package/luci-app-aliyundrive-webdav/luci-app-aliyundrive-webdav/po/zh-cn/aliyundrive-webdav.po
sed -i 's/WireGuard 状态/WireGuard/g' feeds/luci/applications/luci-app-wireguard/po/zh-cn/wireguard.po

./scripts/feeds install -a

echo "========================="
echo " DIY2 配置完成……"
