#!/bin/bash

echo "开始 DIY 配置……"
echo "========================="

# 添加源
echo "src-git nikki https://github.com/nikkinikki-org/OpenWrt-nikki.git;main" >> "feeds.conf.default"

# 定义函数：从仓库拉取单个文件夹
pull_folder_from_repo() {
    local repo_url="$1"
    local branch="$2"
    local folder_path="$3"
    local target_dir="$4"

    local temp_repo=$(mktemp -d)
    trap 'rm -rf "$temp_repo"' EXIT

    # 稀疏克隆
    git clone --depth 1 --branch "$branch" --filter=blob:none --sparse "$repo_url" "$temp_repo" || {
        echo "Failed to clone repository: $repo_url" >&2
        return 1
    }
    cd "$temp_repo" || return 1
    git sparse-checkout init --cone || {
        echo "Failed to initialize sparse-checkout" >&2
        return 1
    }
    git sparse-checkout set "$folder_path" || {
        echo "Failed to set sparse-checkout path: $folder_path" >&2
        return 1
    }
    # 移动文件夹（确保目标目录存在）
    mkdir -p "$target_dir"
    mv "$folder_path" "$target_dir/" || {
        echo "Failed to move folder: $folder_path" >&2
        return 1
    }
    cd - >/dev/null
}

# 克隆相关仓库
clone_repos() {
    local repos=("$@")
    for ((i=0; i<${#repos[@]}; i+=2)); do
        local repo_url="${repos[$i]}"
        local target_dir="${repos[$i+1]}"
        git clone --depth 1 "$repo_url" "$target_dir" || {
            echo "Failed to clone $repo_url to $target_dir" >&2
            return 1
        }
    done
}

# 克隆仓库
clone_repos \
    https://github.com/fw876/helloworld.git package/ssr \
    https://github.com/jerrykuku/luci-theme-argon.git package/luci-theme-argon \
    https://github.com/sirpdboy/luci-theme-kucat.git -b js package/luci-theme-kucat \
    https://github.com/sirpdboy/luci-app-advancedplus.git package/luci-app-advancedplus \
    https://github.com/sbwml/luci-app-mosdns -b v5 package/mosdns \
    https://github.com/sbwml/v2ray-geodata package/v2ray-geodata \
    https://github.com/gdy666/luci-app-lucky.git package/lucky \
    https://github.com/sbwml/openwrt-alist.git package/openwrt-alist \
    https://github.com/UnblockNeteaseMusic/luci-app-unblockneteasemusic.git package/luci-app-unblockneteasemusic

# 拉取特定文件夹
pull_folder_from_repo "https://github.com/vernesong/OpenClash.git" "master" "luci-app-openclash" "package/luci-app-openclash"
pull_folder_from_repo "https://github.com/Lienol/openwrt-package" "main" "luci-app-filebrowser" "package/luci-app-filebrowser"
pull_folder_from_repo "https://github.com/immortalwrt/luci.git" "openwrt-23.05" "applications/luci-app-docker" "package/luci-app-docker"

# 修改默认IP
sed -i 's/192.168.1.1/10.10.10.254/g' package/base-files/files/bin/config_generate

# 修改主机名
sed -i "/uci commit system/i\uci set system.@system[0].hostname='Unicorn'" package/lean/default-settings/files/zzz-default-settings
sed -i "s/hostname='OpenWrt'/hostname='Unicorn'/g" package/base-files/files/bin/config_generate

# 处理mosdns相关包
rm -rf feeds/packages/net/mosdns
rm -rf feeds/luci/applications/luci-app-mosdns
find ./ -name "Makefile" -path "*v2ray-geodata*" -delete
find ./ -name "Makefile" -path "*mosdns*" -delete

# 批量替换
batch_sed_replace() {
    local dirs=("$@")
    local search="$2"
    local replace="$3"
    for dir in "${dirs[@]}"; do
        find "$dir" -type f -exec sed -i "s/$search/$replace/g" {} + || {
            echo "Failed to sed in $dir" >&2
            return 1
        }
    done
}

# 调整菜单配置
batch_sed_replace "package/luci-app-argon-config/luasrc/controller" "system" "services"
batch_sed_replace "feeds/luci/applications/luci-app-wireguard/luasrc/controller" "status" "vpn"
batch_sed_replace "feeds/luci/applications/luci-app-wireguard/luasrc/controller" "92" "2"

# 调整阿里云盘菜单
aliyun_menu_dirs=(
    "package/luci-app-aliyundrive-webdav/luci-app-aliyundrive-webdav/luasrc/controller"
    "package/luci-app-aliyundrive-webdav/luci-app-aliyundrive-webdav/luasrc/model/cbi/aliyundrive-webdav"
    "package/luci-app-aliyundrive-webdav/luci-app-aliyundrive-webdav/luasrc/view/aliyundrive-webdav"
)
batch_sed_replace "${aliyun_menu_dirs[@]}" "services" "nas"

# 调整upnp菜单
upnp_menu_dirs=(
    "feeds/luci/applications/luci-app-upnp/luasrc/controller"
    "feeds/luci/applications/luci-app-upnp/luasrc/model/cbi/upnp"
    "feeds/luci/applications/luci-app-upnp/luasrc/view"
)
batch_sed_replace "${upnp_menu_dirs[@]}" "services" "network"

# 修改插件名称
batch_sed_replace "package/luci-app-aliyundrive-webdav/luci-app-aliyundrive-webdav/po/zh-cn" '"阿里云盘 WebDAV"' '"阿里云盘"'
batch_sed_replace "feeds/luci/applications/luci-app-wireguard/po/zh-cn" "WireGuard 状态" "WireGuard"

# 删除冲突包
rm -rf feeds/luci/themes/luci-theme-argon
rm -rf feeds/packages/multimedia/UnblockNeteaseMusic
rm -rf feeds/luci/applications/luci-app-unblockmusic
rm -rf feeds/packages/multimedia/UnblockNeteaseMusic-Go

# 安装软件包
./scripts/feeds install -a

echo "========================="
echo "DIY 配置完成……"
