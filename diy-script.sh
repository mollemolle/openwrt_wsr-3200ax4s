#!/bin/bash

# カーネル設定の追加
if ls ./target/linux/mediatek/mt7622/config-* 1> /dev/null 2>&1; then
  for conf in ./target/linux/mediatek/mt7622/config-*; do
    echo "CONFIG_MTD_VIRT_CONCAT=y" >> "$conf"
  done
fi

# vermagic の固定化処理
echo "5721f98a447ca737b75326f25e62c50c" > ./vermagic
sed -i 's|^[[:space:]]*grep.*\.config\.set.*\.vermagic.*|cp $(TOPDIR)/vermagic $(LINUX_DIR)/.vermagic|' ./include/kernel-defaults.mk
sed -i 's|^[[:space:]]*STAMP_BUILT:=.*kconfig\.pl.*|STAMP_BUILT:=$(STAMP_BUILT)_$(shell cat $(LINUX_DIR)/.vermagic)|' ./package/kernel/linux/Makefile
