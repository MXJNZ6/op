#!/bin/bash

echo "开始 DIY 配置……"
echo "========================="

# 定义合并仓库函数
merge_package() {
    if [[ $# -lt 3 ]]; then
        echo "参数错误：需要至少3个参数（分支、仓库地址、目标目录）" >&2
        return 1
    fi
    local branch="$1"
    local repo_url="$2"
    local target_dir="$3"
    shift 3
    local pull_files=("$@")

    mkdir -p "$target_dir" || {
        echo "创建目标目录 $target_dir 失败" >&2
        return 1
    }

    local tmpdir=$(mktemp -d)
    trap 'rm -rf "$tmpdir"' EXIT

    echo "拉取仓库：$repo_url（分支：$branch）"
    git clone -b "$branch" --depth 1 --filter=blob:none --sparse "$repo_url" "$tmpdir" || {
        echo "克隆仓库 $repo_url 失败" >&2
        return 1
    }

    cd "$tmpdir" || {
        echo "进入临时目录 $tmpdir 失败" >&2
        return 1
    }
    git sparse-checkout init --cone || {
        echo "初始化稀疏克隆失败" >&2
        return 1
    }
    git sparse-checkout set "${pull_files[@]}" || {
        echo "设置拉取文件失败：${pull_files[*]}" >&2
        return 1
    }

    for file in "${pull_files[@]}"; do
        if [[ -e "$file" ]]; then
            mv -f "$file" "$OLDPWD/$target_dir/" || {
                echo "移动 $file 到 $target_dir 失败" >&2
                return 1
            }
        else
            echo "警告：$file 在仓库中不存在，跳过" >&2
        fi
    }
    cd "$OLDPWD" || return 1
}

# 添加自定义源
echo "src-git nikki https://github.com/nikkinikki-org/OpenWrt-nikki.git;main" >> "feeds.conf.default"

# 克隆独立插件
git clone --depth 1 https://github.com/fw876/helloworld.git package/ssr || {
    echo "克隆 helloworld 失败" >&2
    exit 1
}

git clone --depth 1 https://github.com/jerrykuku/luci-theme-argon.git package/luci-theme-argon || {
    echo "克隆 luci-theme-argon 失败" >&2
    exit 1
}

git clone --depth 1 -b js https://github.com/sirpdboy/luci-theme-kucat.git package/luci-theme-kucat || {
    echo "克隆 luci-theme-kucat 失败" >&2
    exit 1
}

git clone --depth 1 https://github.com/sirpdboy/luci-app-advancedplus.git package/luci-app-advancedplus || {
    echo "克隆 luci-app-advancedplus 失败" >&2
    exit 1
}

# 拉取特定文件夹
merge_package "master" "https://github.com/vernesong/OpenClash.git" "package/luci-app-openclash" "luci-app-openclash" || {
    echo "拉取 OpenClash 失败" >&2
    exit 1
}

merge_package "main" "https://github.com/Lienol/openwrt-package" "package/luci-app-filebrowser" "luci-app-filebrowser" || {
    echo "拉取 luci-app-filebrowser 失败" >&2
    exit 1
}

merge_package "openwrt-23.05" "https://github.com/immortalwrt/luci.git" "package/luci-app-docker" "applications/luci-app-docker" || {
    echo "拉取 luci-app-docker 失败" >&2
    exit 1
}

# 更新feeds索引
./scripts/feeds update -a || {
    echo "更新 feeds 失败" >&2
    exit 1
}

# 处理冲突包
# 【mosdns相关整体操作】
rm -rf feeds/packages/net/mosdns
rm -rf feeds/luci/applications/luci-app-mosdns
find ./ -name "Makefile" -path "*v2ray-geodata*" -delete
find ./ -name "Makefile" -path "*mosdns*" -delete
git clone --depth 1 -b v5 https://github.com/sbwml/luci-app-mosdns package/mosdns || {
    echo "克隆 luci-app-mosdns 失败" >&2
    exit 1
}
git clone --depth 1 https://github.com/sbwml/v2ray-geodata package/v2ray-geodata || {
    echo "克隆 v2ray-geodata 失败" >&2
    exit 1
}

# 【其他冲突包处理】
rm -rf feeds/luci/themes/luci-theme-argon
rm -rf feeds/packages/multimedia/UnblockNeteaseMusic
rm -rf feeds/luci/applications/luci-app-unblockmusic
rm -rf feeds/packages/multimedia/UnblockNeteaseMusic-Go

# 【补充其他插件】
git clone --depth 1 https://github.com/gdy666/luci-app-lucky.git package/lucky || {
    echo "克隆 luci-app-lucky 失败" >&2
    exit 1
}

git clone --depth 1 https://github.com/sbwml/openwrt-alist.git package/openwrt-alist || {
    echo "克隆 openwrt-alist 失败" >&2
    exit 1
}

git clone --depth 1 https://github.com/UnblockNeteaseMusic/luci-app-unblockneteasemusic.git package/luci-app-unblockneteasemusic || {
    echo "克隆 luci-app-unblockneteasemusic 失败" >&2
    exit 1
}

# 修改系统配置
# 修改默认IP
sed -i 's/192.168.1.1/10.10.10.254/g' package/base-files/files/bin/config_generate || {
    echo "修改默认IP失败" >&2
    exit 1
}

# 修改主机名
sed -i "/uci commit system/i\uci set system.@system[0].hostname='Unicorn'" package/lean/default-settings/files/zzz-default-settings || {
    echo "修改主机名失败（zzz-default-settings）" >&2
    exit 1
}
sed -i "s/hostname='OpenWrt'/hostname='Unicorn'/g" package/base-files/files/bin/config_generate || {
    echo "修改主机名失败（config_generate）" >&2
    exit 1
}

# 调整插件菜单和名称
sed -i 's/system/services/g' package/luci-app-argon-config/luasrc/controller/argon-config.lua || {
    echo "调整 argon-config 菜单失败（非致命错误）" >&2
}

sed -i 's/status/vpn/g' feeds/luci/applications/luci-app-wireguard/luasrc/controller/wireguard.lua || {
    echo "调整 WireGuard 菜单失败（非致命错误）" >&2
}
sed -i 's/92/2/g' feeds/luci/applications/luci-app-wireguard/luasrc/controller/wireguard.lua || {
    echo "调整 WireGuard 排序失败（非致命错误）" >&2
}

sed -i 's/services/nas/g' package/luci-app-aliyundrive-webdav/luasrc/controller/*.lua || {
    echo "调整阿里云盘菜单失败（非致命错误）" >&2
}
sed -i 's/services/nas/g' package/luci-app-aliyundrive-webdav/luasrc/model/cbi/aliyundrive-webdav/*.lua || {
    echo "调整阿里云盘配置菜单失败（非致命错误）" >&2
}
sed -i 's/services/nas/g' package/luci-app-aliyundrive-webdav/luasrc/view/aliyundrive-webdav/*.htm || {
    echo "调整阿里云盘视图菜单失败（非致命错误）" >&2
}

sed -i 's/services/network/g' feeds/luci/applications/luci-app-upnp/luasrc/controller/*.lua || {
    echo "调整 upnp 菜单失败（非致命错误）" >&2
}
sed -i 's/services/network/g' feeds/luci/applications/luci-app-upnp/luasrc/model/cbi/upnp/*.lua || {
    echo "调整 upnp 配置菜单失败（非致命错误）" >&2
}

sed -i 's/"阿里云盘 WebDAV"/"阿里云盘"/g' package/luci-app-aliyundrive-webdav/po/zh-cn/aliyundrive-webdav.po || {
    echo "修改阿里云盘名称失败（非致命错误）" >&2
}
sed -i 's/WireGuard 状态/WireGuard/g' feeds/luci/applications/luci-app-wireguard/po/zh-cn/wireguard.po || {
    echo "修改 WireGuard 名称失败（非致命错误）" >&2
}

# 最后安装所有feeds包
./scripts/feeds install -a || {
    echo "安装 feeds 失败" >&2
    exit 1
}

# 编译安装po2lmo工具
if [ -d "package/luci-app-openclash/tools/po2lmo" ]; then
    echo "开始编译 po2lmo 工具..."
    pushd package/luci-app-openclash/tools/po2lmo || {
        echo "进入 po2lmo 目录失败" >&2
        exit 1
    }
    make && sudo make install || {
        echo "po2lmo 编译或安装失败" >&2
        exit 1
    }
    popd || exit 1
    echo "po2lmo 安装完成"
else
    echo "错误：未找到 po2lmo 目录，请检查 luci-app-openclash 是否拉取成功" >&2
    exit 1
fi

echo "========================="
echo "DIY 配置完成……"
