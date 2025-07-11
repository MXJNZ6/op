#!/bin/bash

echo "开始 DIY 配置……"
echo "========================="

# 添加源，可根据需要取消注释
# sed -i '$a src - git nas https://github.com/linkease/nas - packages.git;master' feeds.conf.default
# sed -i '$a src - git nas_luci https://github.com/linkease/nas - packages - luci.git;main' feeds.conf.default

# 将源添加到 feeds.conf.default
echo "src - git nikki https://github.com/nikkinikki - org/OpenWrt - nikki.git;main" >> "feeds.conf.default"

# 更新软件源，确保新添加的源能被正确拉取
./scripts/feeds update -a

# 定义函数：从指定仓库特定分支拉取单个文件夹并移动到目标目录
pull_folder_from_repo() {
    local repo_url="$1"
    local branch="$2"
    local folder_path="$3"
    local target_dir="$4"

    local temp_repo=$(mktemp -d)
    trap 'rm -rf "$temp_repo"' EXIT

    git clone --depth 1 --branch "$branch" --filter=blob:none --sparse "$repo_url" "$temp_repo"
    if [ $? -ne 0 ]; then
        echo "Failed to clone repository" >&2
        return 1
    fi
    cd "$temp_repo"
    git sparse - checkout init --cone
    if [ $? -ne 0 ]; then
        echo "Failed to initialize sparse - checkout" >&2
        return 1
    fi
    git sparse - checkout set "$folder_path"
    if [ $? -ne 0 ]; then
        echo "Failed to set sparse - checkout paths" >&2
        return 1
    fi
    mkdir -p "$target_dir"
    mv "$folder_path" "$target_dir"
    cd..
}

# 定义批量克隆仓库函数
clone_repos() {
    local repos=("$@")
    for ((i = 0; i < ${#repos[@]}; i += 2)); do
        git clone ${repos[$i]} ${repos[$i + 1]}
        if [ $? -ne 0 ]; then
            echo "Failed to clone repository: ${repos[$i]}" >&2
            return 1
        fi
    done
}

# 克隆相关仓库到 package 目录
clone_repos \
    https://github.com/fw876/helloworld.git package/ssr \
    https://github.com/jerrykuku/luci - theme - argon.git package/luci - theme - argon \
    https://github.com/sirpdboy/luci - theme - kucat.git -b js package/luci - theme - kucat \
    https://github.com/sirpdboy/luci - app - advancedplus.git package/luci - app - advancedplus \
    https://github.com/sbwml/luci - app - mosdns -b v5 package/mosdns \
    https://github.com/sbwml/v2ray - geodata package/v2ray - geodata \
    https://github.com/gdy666/luci - app - lucky.git package/lucky \
    https://github.com/sbwml/openwrt - alist.git package/openwrt - alist \
    https://github.com/UnblockNeteaseMusic/luci - app - unblockneteasemusic.git package/luci - app - unblockneteasemusic


# 从指定仓库拉取特定文件夹
pull_folder_from_repo "https://github.com/vernesong/OpenClash.git" "master" "luci - app - openclash" "openclash/luci - app - openclash"
pull_folder_from_repo "https://github.com/Lienol/openwrt - package" "main" "luci - app - filebrowser" "openwrt - package/luci - app - filebrowser"
pull_folder_from_repo "https://github.com/immortalwrt/luci.git" "openwrt - 23.05" "applications/luci - app - docker" "immortalwrt/luci - app - docker"


# 修改 openwrt 登陆地址
# 将 10.10.10.254 修改为所需地址
sed -i 's/192.168.1.1/10.10.10.254/g' package/base - files/files/bin/config_generate

# 修改主机名字
# 将 Unicorn 修改为喜欢的名字（不能纯数字或者使用中文）
sed -i "/uci commit system/i\uci set system.@system[0].hostname='Unicorn'" package/lean/default - settings/files/zzz - default - settings
sed -i "s/hostname='OpenWrt'/hostname='Unicorn'/g"./package/base - files/files/bin/config_generate


# 处理 mosdns 相关包
rm -rf feeds/packages/net/mosdns
rm -rf feeds/luci/applications/luci - app - mosdns
find./ | grep Makefile | grep v2ray - geodata | xargs rm -f
find./ | grep Makefile | grep mosdns | xargs rm -f


# 定义批量 sed 替换函数
batch_sed_replace() {
    local dirs=("$1")
    local search="$2"
    local replace="$3"
    for dir in "${dirs[@]}"; do
        find "$dir" -type f -exec sed -i 's/'"$search"'/'"$replace"'/g' {} +
        if [ $? -ne 0 ]; then
            echo "Failed to sed replace in $dir" >&2
            return 1
        fi
    done
}

# 修改 luci - app - argon - config 相关配置
batch_sed_replace "package/luci - app - argon - config/luasrc/controller" "system" "services"

# 修改 luci - app - design - config 相关配置，代码被注释，可根据需要取消注释
# batch_sed_replace "feeds/luci/applications/luci - app - design - config/luasrc/controller" "system" "services"

# 修改 wireguard 相关配置
batch_sed_replace "feeds/luci/applications/luci - app - wireguard/luasrc/controller" "status" "vpn"
batch_sed_replace "feeds/luci/applications/luci - app - wireguard/luasrc/controller" "92" "2"

# 调整阿里云盘到存储菜单相关配置
aliyun_menu_dirs=(
    "package/luci - app - aliyundrive - webdav/luci - app - aliyundrive - webdav/luasrc/controller"
    "package/luci - app - aliyundrive - webdav/luci - app - aliyundrive - webdav/luasrc/model/cbi/aliyundrive - webdav"
    "package/luci - app - aliyundrive - webdav/luci - app - aliyundrive - webdav/luasrc/view/aliyundrive - webdav"
)
batch_sed_replace "${aliyun_menu_dirs[@]}" "services" "nas"

# 调整 upnp 到网络菜单相关配置
upnp_menu_dirs=(
    "feeds/luci/applications/luci - app - upnp/luasrc/controller"
    "feeds/luci/applications/luci - app - upnp/luasrc/model/cbi/upnp"
    "feeds/luci/applications/luci - app - upnp/luasrc/view"
)
batch_sed_replace "${upnp_menu_dirs[@]}" "services" "network"


# 修改插件名字
batch_sed_replace "package/luci - app - aliyundrive - webdav/luci - app - aliyundrive - webdav/po/zh - cn" '"阿里云盘 WebDAV"' '"阿里云盘"'
batch_sed_replace "feeds/luci/applications/luci - app - wireguard/po/zh - cn" 'WireGuard 状态' 'WireGuard'


# 删除相关包
rm -rf feeds/luci/themes/luci - theme - argon
rm -rf feeds/packages/multimedia/UnblockNeteaseMusic
rm -rf feeds/luci/applications/luci - app - unblockmusic
rm -rf feeds/packages/multimedia/UnblockNeteaseMusic - Go


# 安装更新后的软件包
./scripts/feeds install -a

echo "========================="
echo " DIY 配置完成……"
