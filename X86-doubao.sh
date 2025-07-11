#!/bin/bash

echo "开始 DIY 配置……"
echo "========================="

function merge_package() {
    if [[ $# -lt 4 ]]; then
        echo "错误: 至少需要4个参数 (分支名 仓库URL 本地目标目录 远程路径...)" >&2
        return 1
    fi

    local branch="$1"
    local repo_url="$2"
    local target_dir="$3"
    shift 3
    local remote_paths=("$@")

    trap 'rm -rf "$tmpdir"' EXIT
    local rootdir="$PWD"
    local tmpdir="$(mktemp -d)" || exit 1

    # 创建目标目录
    mkdir -p "$target_dir" || {
        echo "错误: 创建目标目录 $target_dir 失败" >&2
        return 1
    }

    # 克隆仓库（只获取指定路径）
    echo "正在克隆仓库 $repo_url (分支: $branch)..."
    git clone -b "$branch" --depth 1 --filter=blob:none --sparse "$repo_url" "$tmpdir" || {
        echo "错误: 克隆仓库失败" >&2
        return 1
    }

    cd "$tmpdir" || {
        echo "错误: 进入临时目录失败" >&2
        return 1
    }

    # 设置稀疏检出路径
    git sparse-checkout init --cone || {
        echo "错误: 初始化稀疏检出失败" >&2
        return 1
    }
    
    # 添加所有要拉取的远程路径
    for path in "${remote_paths[@]}"; do
        git sparse-checkout set --no-cone "$path" || {
            echo "错误: 设置稀疏检出路径 $path 失败" >&2
            return 1
        }
    done

    # 移动文件到目标目录
    echo "正在移动文件到 $target_dir..."
    for path in "${remote_paths[@]}"; do
        if [[ -e "$path" ]]; then
            # 获取路径的基本名称（最后一个目录名）
            local base_name=$(basename "$path")
            # 移动到目标目录下
            mv -f "$path" "$rootdir/$target_dir/" || {
                echo "错误: 移动 $path 到 $target_dir 失败" >&2
                return 1
            }
            echo "已成功拉取: $path -> $target_dir/$base_name"
        else
            echo "警告: 远程路径 $path 不存在" >&2
        fi
    done

    cd "$rootdir" || return 1
    echo "操作完成!"
}

# Update feeds
./scripts/feeds update -a

# 添加源
git clone https://github.com/fw876/helloworld.git package/ssr
git clone https://github.com/jerrykuku/luci-theme-argon.git  package/luci-theme-argon
git clone -b js https://github.com/sirpdboy/luci-theme-kucat.git  package/luci-theme-kucat
git clone https://github.com/sirpdboy/luci-app-advancedplus.git  package/luci-app-advancedplus

# 修改openwrt登陆地址,把下面的10.10.10.254修改成你需要的
sed -i 's/192.168.1.1/10.10.10.254/g' package/base-files/files/bin/config_generate

# 修改主机名字，把Unicorn修改成你喜欢的（不能纯数字或者使用中文）
sed -i "/uci commit system/i\uci set system.@system[0].hostname='Unicorn'" package/lean/default-settings/files/zzz-default-settings
sed -i "s/hostname='OpenWrt'/hostname='Unicorn'/g" ./package/base-files/files/bin/config_generate

rm -rf feeds/luci/applications/luci-app-openclash
merge_package master https://github.com/vernesong/OpenClash.git openwrt-openclash luci-app-openclash
pushd openwrt-openclash/luci-app-openclash/tools/po2lmo
make && sudo make install
popd

merge_package openwrt-23.05 https://github.com/immortalwrt/luci.git immortalwrt applications/luci-app-docker


#mosdns
rm -rf feeds/packages/net/mosdns
rm -rf feeds/luci/applications/luci-app-mosdns
find ./ | grep Makefile | grep v2ray-geodata | xargs rm -f
find ./ | grep Makefile | grep mosdns | xargs rm -f
git clone https://github.com/sbwml/luci-app-mosdns -b v5 package/mosdns
git clone https://github.com/sbwml/v2ray-geodata package/v2ray-geodata

git clone https://github.com/UnblockNeteaseMusic/luci-app-unblockneteasemusic.git package/luci-app-unblockneteasemusic

# 删除包
rm -rf feeds/luci/themes/luci-theme-argon
rm -rf feeds/luci/themes/luci-theme-argon-mod
rm -rf feeds/packages/multimedia/UnblockNeteaseMusic
rm -rf feeds/luci/applications/luci-app-unblockmusic
rm -rf feeds/packages/multimedia/UnblockNeteaseMusic-Go


# wireguard
# sed -i 's/status/vpn/g' feeds/luci/applications/luci-app-wireguard/luasrc/controller/wireguard.lua
# sed -i 's/92/2/g' feeds/luci/applications/luci-app-wireguard/luasrc/controller/wireguard.lua

# 调整upnp到网络菜单
sed -i 's/services/network/g' feeds/luci/applications/luci-app-upnp/luasrc/controller/*.lua
sed -i 's/services/network/g' feeds/luci/applications/luci-app-upnp/luasrc/model/cbi/upnp/*.lua
sed -i 's/services/network/g' feeds/luci/applications/luci-app-upnp/luasrc/view/*.htm

./scripts/feeds install -a -f

echo "========================="
echo " DIY2 配置完成……"
