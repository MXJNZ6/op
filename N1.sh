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

rm -rf package/custom; mkdir package/custom


# Update feeds
./scripts/feeds update -a
# 删除包
rm -rf feeds/packages/multimedia/UnblockNeteaseMusic
rm -rf feeds/luci/applications/luci-app-unblockmusic
rm -rf feeds/luci/applications/luci-app-unblockneteasemusic
rm -rf feeds/luci/applications/luci-app-openclash
rm -rf feeds/packages/multimedia/UnblockNeteaseMusic-Go

# 修改openwrt登陆地址,把下面的10.10.10.254修改成你需要的
sed -i 's/192.168.1.1/10.10.10.254/g' package/base-files/files/bin/config_generate

# 修改主机名字，把Unicorn修改成你喜欢的（不能纯数字或者使用中文）
sed -i "/uci commit system/i\uci set system.@system[0].hostname='Unicorn'" package/lean/default-settings/files/zzz-default-settings
sed -i "s/hostname='OpenWrt'/hostname='Unicorn'/g" ./package/base-files/files/bin/config_generate

merge_package https://github.com/vernesong/OpenClash OpenClash/luci-app-openclash
git clone https://github.com/UnblockNeteaseMusic/luci-app-unblockneteasemusic.git package/luci-app-unblockneteasemusic
rm -rf package/luci-app-amlogic
git clone https://github.com/ophub/luci-app-amlogic.git package/luci-app-amlogic
git clone -b js https://github.com/sirpdboy/luci-theme-kucat.git  package/luci-theme-kucat
git clone https://github.com/sirpdboy/luci-app-advancedplus.git  package/luci-app-advancedplus

./scripts/feeds install -a
./scripts/feeds install -f luci-app-amlogic

echo "========================="
echo " DIY 配置完成……"
