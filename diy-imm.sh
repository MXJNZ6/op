#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#
echo "开始 DIY 配置……"
echo "========================="


git clone -b js https://github.com/sirpdboy/luci-theme-kucat.git  package/luci-theme-kucat
git clone https://github.com/sirpdboy/luci-app-advancedplus.git  package/luci-app-advancedplus
echo "src-git nikki https://github.com/nikkinikki-org/OpenWrt-nikki.git;main" >> "feeds.conf.default"
# Update feeds
./scripts/feeds update -a
./scripts/feeds install -a
﻿#
# 添加 gettext 补丁修复
echo "更新 gettext 补丁..."
mkdir -p package/libs/gettext-full/patches
cat > package/libs/gettext-full/patches/200-libunistring-missing-link.patch <<'EOF'
--- a/autogen.sh
+++ b/autogen.sh
@@ -104,6 +104,7 @@ if ! $skip_gnulib; then
     getopt-gnu
     gettext-h
     havelib
+    libunistring-optional
     memmove
     noreturn
     progname

--- a/gettext-runtime/src/Makefile.am  
+++ b/gettext-runtime/src/Makefile.am
@@ -43,7 +43,7 @@ envsubst_SOURCES = envsubst.c

 # Link dependencies.
 # Need @LTLIBICONV@ because striconv.c uses iconv().
-LDADD = ../gnulib-lib/libgrt.a @LTLIBINTL@ @LTLIBICONV@ $(WOE32_LDADD)
+LDADD = ../gnulib-lib/libgrt.a $(LTLIBUNISTRING) @LTLIBINTL@ @LTLIBICONV@ $(WOE32_LDADD)

 # Specify installation directory, for --enable-relocatable.
 gettext_CFLAGS = -DINSTALLDIR=$(bindir_c_make)

--- a/gettext-tools/src/msgcmp.c
+++ b/gettext-tools/src/msgcmp.c
@@ -107,7 +107,7 @@ main (int argc, char *argv[])
   /* Set program name for messages.  */
   set_program_name (argv[0]);
   error_print_progname = maybe_print_progname;
-  bindtextdomain ("bison-runtime", relocate (BISON_LOCALEDIR));
+  bindtextdomain ("bison-runtime", relocate (LOCALEDIR));
   bindtextdomain (PACKAGE, relocate (LOCALEDIR));
   textdomain (PACKAGE);
EOF

echo "========================="
echo " DIY 配置完成……"
