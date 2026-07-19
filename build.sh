#!/bin/bash
# 1. パッケージのインストール
sudo apt update
sudo apt install -y bc binutils-gold bison build-essential ccache ecj fastjar file flex g++ gawk gcc-arm* gettext git help2man libbsd-dev libelf-dev liblzma-dev libncurses-dev libssl-dev mtd-utils meson mold mtd-utils ninja-build pbzip2 pigz pkg-config python3-dev python3-setuptools rsync subversion swig texinfo time u-boot-tools unzip wget xsltproc xxd zlib1g-dev zstd

# 2. ソースコードの取得
git clone https://git.openwrt.org/openwrt/openwrt.git
cd openwrt/
git checkout v25.12.5
git switch -c my-v25.12.5

# 3. フィードの更新
./scripts/feeds update -a
./scripts/feeds install -a

# 4. 設定ファイルの取得と反映
wget https://downloads.openwrt.org/releases/25.12.5/targets/mediatek/mt7622/config.buildinfo -O .config
echo "CONFIG_TARGET_MULTI_PROFILE=y" >> .config
echo "CONFIG_TARGET_DEVICE_mediatek_mt7622_DEVICE_buffalo_wsr-3200ax4s=y" >> .config
make defconfig

# 5. カスタムファイルの取得と設定の追加
wget https://pastebin.com/raw/yQTBrDaA -O ./target/linux/mediatek/dts/mt7622-buffalo-wsr-3200ax4s.dts
echo "CONFIG_MTD_VIRT_CONCAT=y" >> ./target/linux/mediatek/mt7622/config-6.12
echo  5721f98a447ca737b75326f25e62c50c > ./vermagic

# 6. ファイルの書き換え（viの手間を無くして全自動化）
sed -i 's|grep '\''=\[ym\]'\'' \$(LINUX_DIR)/\.config\.set \| LC_ALL=C sort \| \$(MKHASH) md5 > \$(LINUX_DIR)/\.vermagic|cp $(TOPDIR)/vermagic $(LINUX_DIR)/.vermagic|' ./include/kernel-defaults.mk

sed -i 's|STAMP_BUILT:=\$(STAMP_BUILT)_\$(shell \$(SCRIPT_DIR)/kconfig\.pl \$(LINUX_DIR)/\.config \| \$(MKHASH) md5)|STAMP_BUILT:=$(STAMP_BUILT)_$(shell cat $(LINUX_DIR)/.vermagic)|' ./package/kernel/linux/Makefile


# 7. ビルドの実行
make defconfig
make -j$(nproc) world

