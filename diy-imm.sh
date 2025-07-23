#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-imm.sh
# Description: OpenWrt DIY script with error fixes
#

echo "开始执行自定义配置及错误修复……"
echo "========================="

# 1. 安装主题和插件
git clone -b js https://github.com/sirpdboy/luci-theme-kucat.git  package/luci-theme-kucat
git clone https://github.com/sirpdboy/luci-app-advancedplus.git  package/luci-app-advancedplus
echo "src-git nikki https://github.com/nikkinikki-org/OpenWrt-nikki.git;main" >> "feeds.conf.default"

# 2. 更新 feeds 并安装
./scripts/feeds update -a

# 3. 修复 python3-netifaces 依赖问题
echo "修复 python3-netifaces 依赖缺失..."
MQTTLED_MAKEFILE="package/feeds/packages/mqttled/Makefile"
if [ -f "$MQTTLED_MAKEFILE" ]; then
    # 检查是否存在该依赖
    if grep -q "+python3-netifaces" "$MQTTLED_MAKEFILE"; then
        # 搜索系统中是否有可用的 netifaces 包
        NETIFACES_PKG=$(./scripts/feeds search netifaces | grep -E "python3?-netifaces" | awk '{print $1}')
        if [ -n "$NETIFACES_PKG" ]; then
            # 替换为系统中存在的包名
            sed -i "s/+python3-netifaces/+$NETIFACES_PKG/g" "$MQTTLED_MAKEFILE"
            echo "已将依赖替换为: $NETIFACES_PKG"
        else
            # 若不存在，移除该依赖
            sed -i "s/+python3-netifaces//g" "$MQTTLED_MAKEFILE"
            echo "系统中无 netifaces 包，已移除依赖"
        fi
    fi
else
    echo "未找到 mqttled 包的 Makefile，跳过依赖修复"
fi

# 4. 修复 mbedTLS 配置错误
echo "修复 mbedTLS 配置..."
MBEDTLS_CONFIG="package/libs/mbedtls/config-defaults.mk"
if [ -f "$MBEDTLS_CONFIG" ]; then
    # 添加必要的配置项（确保不重复添加）
    add_config() {
        local key=$1
        local value=$2
        if ! grep -q "^$key=$value" "$MBEDTLS_CONFIG"; then
            echo "$key=$value" >> "$MBEDTLS_CONFIG"
            echo "添加 mbedTLS 配置: $key=$value"
        fi
    }
    
    add_config "CONFIG_MBEDTLS_CTR_DRBG_C" "y"
    add_config "CONFIG_MBEDTLS_ECDSA_C" "y"
    add_config "CONFIG_MBEDTLS_ECP_C" "y"
    add_config "CONFIG_MBEDTLS_SSL_PROTO_DTLS" "y"
    add_config "CONFIG_MBEDTLS_SSL_PROTO_TLS1_2" "y"
    add_config "CONFIG_MBEDTLS_SSL_PROTO_TLS1_3" "y"
    add_config "CONFIG_MBEDTLS_ECP_MAX_BITS" "256"
else
    echo "未找到 mbedTLS 配置文件，跳过配置修复"
fi

# 5. 调整 upnp 菜单位置
echo "调整 upnp 菜单到网络分类..."
sed -i 's/services/network/g' feeds/luci/applications/luci-app-upnp/luasrc/controller/*.lua
sed -i 's/services/network/g' feeds/luci/applications/luci-app-upnp/luasrc/model/cbi/upnp/*.lua
sed -i 's/services/network/g' feeds/luci/applications/luci-app-upnp/luasrc/view/*.htm

# 6. 安装所有 feeds 包
./scripts/feeds install -a

echo "========================="
echo "自定义配置及错误修复完成！"
