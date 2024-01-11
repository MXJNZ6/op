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

# 添加源
# sed -i '$a src-git helloworld https://github.com/fw876/helloworld;main' feeds.conf.default
#sed -i '$a src-git helloworld https://github.com/fw876/helloworld' feeds.conf.default
#sed -i '$a src-git xiaorouji https://github.com/xiaorouji/openwrt-passwall-packages' feeds.conf.default
#sed -i '$a src-git passwall https://github.com/xiaorouji/openwrt-passwall' feeds.conf.default

echo "开始 DIY 配置……"
echo "========================="

function merge_package(){
    repo=`echo $1 | rev | cut -d'/' -f 1 | rev`
    pkg=`echo $2 | rev | cut -d'/' -f 1 | rev`
    # find package/ -follow -name $pkg -not -path "package/custom/*" | xargs -rt rm -rf
    git clone --depth=1 --single-branch $1
    mv $2 package/custom/
    rm -rf $repo
}
function drop_package(){
    find package/ -follow -name $1 -not -path "package/custom/*" | xargs -rt rm -rf
}
function merge_feed(){
    if [ ! -d "feed/$1" ]; then
        echo >> feeds.conf.default
        echo "src-git $1 $2" >> feeds.conf.default
    fi
    ./scripts/feeds update $1
    ./scripts/feeds install -a -p $1
}
rm -rf package/custom; mkdir package/custom

# 切换内核版本
# sed -i 's/KERNEL_PATCHVER:=5.15/KERNEL_PATCHVER:=5.4/g' ./target/linux/x86/Makefile

merge_package https://github.com/vernesong/OpenClash OpenClash/luci-app-openclash
# 编译 po2lmo (如果有po2lmo可跳过)
pushd package/custom/luci-app-openclash/tools/po2lmo
make && sudo make install
popd

merge_package https://github.com/xiaorouji/openwrt-passwall openwrt-passwall/luci-app-passwall
merge_package https://github.com/fw876/helloworld helloworld/luci-app-ssr-plus
merge_package https://github.com/xiaorouji/openwrt-passwall-packages openwrt-passwall-packages/brook
merge_package https://github.com/xiaorouji/openwrt-passwall-packages openwrt-passwall-packages/chinadns-ng
merge_package https://github.com/xiaorouji/openwrt-passwall-packages openwrt-passwall-packages/dns2socks
merge_package https://github.com/fw876/helloworld helloworld/dns2tcp
merge_package https://github.com/xiaorouji/openwrt-passwall-packages openwrt-passwall-packages/gn
merge_package https://github.com/xiaorouji/openwrt-passwall-packages openwrt-passwall-packages/hysteria
merge_package https://github.com/xiaorouji/openwrt-passwall-packages openwrt-passwall-packages/ipt2socks
merge_package https://github.com/fw876/helloworld helloworld/lua-neturl
merge_package https://github.com/xiaorouji/openwrt-passwall-packages openwrt-passwall-packages/microsocks
merge_package https://github.com/fw876/helloworld helloworld/mosdns
merge_package https://github.com/xiaorouji/openwrt-passwall-packages openwrt-passwall-packages/naiveproxy
merge_package https://github.com/fw876/helloworld helloworld/redsocks2
merge_package https://github.com/fw876/helloworld helloworld/shadow-tls
merge_package https://github.com/xiaorouji/openwrt-passwall-packages openwrt-passwall-packages/pdnsd-alt
merge_package https://github.com/xiaorouji/openwrt-passwall-packages openwrt-passwall-packages/shadowsocks-rust
merge_package https://github.com/fw876/helloworld helloworld/shadowsocksr-libev
merge_package https://github.com/xiaorouji/openwrt-passwall-packages openwrt-passwall-packages/simple-obfs
merge_package https://github.com/xiaorouji/openwrt-passwall-packages openwrt-passwall-packages/sing-box
merge_package https://github.com/xiaorouji/openwrt-passwall-packages openwrt-passwall-packages/ssocks
merge_package https://github.com/xiaorouji/openwrt-passwall-packages openwrt-passwall-packages/tcping
merge_package https://github.com/xiaorouji/openwrt-passwall-packages openwrt-passwall-packages/trojan-go
merge_package https://github.com/xiaorouji/openwrt-passwall-packages openwrt-passwall-packages/trojan-plus
merge_package https://github.com/xiaorouji/openwrt-passwall-packages openwrt-passwall-packages/trojan
merge_package https://github.com/fw876/helloworld helloworld/tuic-client
merge_package https://github.com/xiaorouji/openwrt-passwall-packages openwrt-passwall-packages/v2ray-core
merge_package https://github.com/fw876/helloworld helloworld/v2ray-geodata
merge_package https://github.com/xiaorouji/openwrt-passwall-packages openwrt-passwall-packages/v2ray-plugin
merge_package https://github.com/fw876/helloworld helloworld/xray-core
merge_package https://github.com/fw876/helloworld helloworld/xray-plugin

# filebrowser
merge_package https://github.com/Lienol/openwrt-package openwrt-package/luci-app-filebrowser

# v2raya
merge_package https://github.com/v2rayA/v2raya-openwrt v2raya-openwrt/v2raya
merge_package https://github.com/v2rayA/v2raya-openwrt v2raya-openwrt/luci-app-v2raya

# svn co https://github.com/vernesong/OpenClash/trunk/luci-app-openclash package/luci-app-openclash
# svn co https://github.com/Lienol/openwrt-package/trunk/luci-app-filebrowser package/luci-app-filebrowser

# git clone https://github.com/sbwml/luci-app-mosdns package/mosdns
# git clone https://github.com/sbwml/openwrt-alist.git package/openwrt-alist
git clone https://github.com/UnblockNeteaseMusic/luci-app-unblockneteasemusic.git package/luci-app-unblockneteasemusic

# git clone -b 18.06 https://github.com/jerrykuku/luci-theme-argon.git package/luci-theme-argon
# git clone  https://github.com/gdy666/luci-app-lucky.git package/lucky

# 修改openwrt登陆地址,把下面的10.10.10.254修改成你想要的就可以了
sed -i 's/192.168.1.1/10.10.10.254/g' package/base-files/files/bin/config_generate

# 修改主机名字，把Unicorn修改你喜欢的就行（不能纯数字或者使用中文）
sed -i "/uci commit system/i\uci set system.@system[0].hostname='Unicorn'" package/lean/default-settings/files/zzz-default-settings
sed -i "s/hostname='OpenWrt'/hostname='Unicorn'/g" ./package/base-files/files/bin/config_generate

# Update feeds
./scripts/feeds update -a

# 删除包
# rm -rf feeds/luci/themes/luci-theme-argon
rm -rf feeds/packages/multimedia/UnblockNeteaseMusic
rm -rf feeds/luci/applications/luci-app-unblockmusic
rm -rf feeds/packages/multimedia/UnblockNeteaseMusic-Go

# mosdns
rm -rf feeds/packages/net/mosdns
rm -rf feeds/luci/applications/luci-app-mosdns
merge_package https://github.com/sbwml/luci-app-mosdns luci-app-mosdns
merge_package https://github.com/sbwml/luci-app-mosdns luci-app-mosdns/mosdns

# 修改 xxx 为默认主题,可根据你喜欢的修改成其他的（不选择那些会自动改变为默认主题的主题才有效果）
# sed -i 's/luci-theme-bootstrap/luci-theme-xxx/g' feeds/luci/collections/luci/Makefile

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

./scripts/feeds update -a
./scripts/feeds install -a

echo "========================="
echo " DIY2 配置完成……"
