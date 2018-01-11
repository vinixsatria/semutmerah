define Build/senao-factory-image
	$(eval board=$(word 1,$(1)))
	$(eval rootfs=$(word 2,$(1)))

	mkdir -p $@.senao

	touch $@.senao/before-upgrade.sh
	touch $@.senao/FWINFO-$(BOARDNAME)-OpenWrt-v9.9.9-$(REVISION).txt
	$(CP) $(IMAGE_KERNEL) $@.senao/openwrt-senao-$(board)-uImage-lzma.bin
	$(CP) $(rootfs) $@.senao/openwrt-senao-$(board)-root.squashfs

	$(TAR) -c \
		--numeric-owner --owner=0 --group=0 --sort=name \
		$(if $(SOURCE_DATE_EPOCH),--mtime="@$(SOURCE_DATE_EPOCH)") \
		-C $@.senao . | gzip -9nc > $@

	rm -rf $@.senao
endef


define Device/eap350
  DEVICE_TITLE := EnGenius EAP350
  BOARDNAME := EAP350
  IMAGE_SIZE := 5952k
  KERNEL_SIZE := 1536k
  IMAGES += factory.bin
  MTDPARTS := spi0.0:256k(u-boot)ro,64k(u-boot-env),320k(custom)ro,5952k(firmware),1536k(failsafe)ro,64k(art)ro
  IMAGE/factory.bin/squashfs := append-rootfs | pad-rootfs | senao-factory-image eap350 $$$$@
  IMAGE/sysupgrade.bin := append-kernel | pad-to $$$$(KERNEL_SIZE) | append-rootfs | pad-rootfs | check-size $$$$(IMAGE_SIZE)
endef
TARGET_DEVICES += eap350

define Device/ens202ext
  DEVICE_TITLE := EnGenius ENS202EXT
  BOARDNAME := ENS202EXT
  DEVICE_PACKAGES := rssileds
  KERNEL_SIZE := 1536k
  IMAGE_SIZE := 13632k
  IMAGES += factory.bin
  MTDPARTS := spi0.0:256k(u-boot)ro,64k(u-boot-env),320k(custom)ro,1536k(kernel),12096k(rootfs),2048k(failsafe)ro,64k(art)ro,13632k@0xa0000(firmware)
  IMAGE/factory.bin/squashfs := append-rootfs | pad-rootfs | senao-factory-image ens202ext $$$$@
  IMAGE/sysupgrade.bin := append-kernel | pad-to $$$$(KERNEL_SIZE) | append-rootfs | pad-rootfs | check-size $$$$(IMAGE_SIZE)
endef
TARGET_DEVICES += ens202ext
