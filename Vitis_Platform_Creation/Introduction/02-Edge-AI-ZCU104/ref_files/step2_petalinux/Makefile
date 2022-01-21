# Copyright 2020 Xilinx Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

ROOT_DIR=$(realpath $(dir $(lastword $(MAKEFILE_LIST))))
ABS_BUILD_PATH=$(ROOT_DIR)/build
PETALINUX_PROJ_NAME=petalinux
ABS_SW_PATH=$(ABS_BUILD_PATH)/$(PETALINUX_PROJ_NAME)
PETALINUX_DIR=$(ABS_SW_PATH)
BD_TCL=system_step0.tcl
ABS_BD_TCL=$(ROOT_DIR)/$(BD_TCL)
PETALINUX_CONFIG=$(PETALINUX_DIR)/project-spec/configs/config
PETALINUX_ROOTFS_CONFIG=$(PETALINUX_DIR)/project-spec/configs/rootfs_config
# refer to https://www.cnblogs.com/hankfu/p/14074595.html
VER=2021.2
ARCH=aarch64
PETA=/opt/xilinx/peta/$(VER)
PRE_MIRROR=$(PETA)/downloads
PRE_MIRROR_CFG=CONFIG_PRE_MIRROR_URL=\"file://$(PRE_MIRROR)\"
ARCH_DIR=$(PETA)/sstate/$(ARCH)
ARCH_CFG=CONFIG_YOCTO_LOCAL_SSTATE_FEEDS_URL=\"$(ARCH_DIR)\"
BSP_CFG=$(PETALINUX_DIR)/project-spec/meta-user/conf/petalinuxbsp.conf
DL_DIR=/home/$(USER)/plnx-workspace/$(VER)/downloads
SSTATE_DIR=/home/$(USER)/plnx-workspace/$(VER)/sstate-cache/$(ARCH)
ONLINE=

.PHONY: all get_xsa petalinux clean main


all: get_xsa petalinux_proj petalinux_build petalinux_build_sdk
main: get_xsa petalinux_proj petalinux_build

get_xsa:
	cd $(ROOT_DIR); cp ../step1_vivado/build/vivado/*hw.xsa .


update_dtsi:
	@cp -f system-user.dtsi $(PETALINUX_DIR)/project-spec/meta-user/recipes-bsp/device-tree/files/system-user.dtsi

update_sstate_dl_dir:
ifeq ("$(wildcard $(DL_DIR))", "")
	mkdir -p $(DL_DIR)
endif
ifeq ("$(wildcard $(SSTATE_DIR))", "")
	mkdir -p $(SSTATE_DIR)
endif
	echo 'DL_DIR="$(DL_DIR)"' >> $(BSP_CFG)
	echo 'SSTATE_DIR="$(SSTATE_DIR)"' >> $(BSP_CFG)

update_config:
	# PetaLinux Config: Use EXT4 as rootfs format
	echo "CONFIG_SUBSYSTEM_ROOTFS_EXT4=y" >> $(PETALINUX_CONFIG)
	# PetaLinux Config: Use ZCU104 device tree
	echo 'CONFIG_SUBSYSTEM_MACHINE_NAME="zcu104-revc"' >> $(PETALINUX_CONFIG)
	echo 'CONFIG_YOCTO_MACHINE_NAME="zcu104-zynqmp"' >> $(PETALINUX_CONFIG)
	# For GCC < 6.0, enable prebuilt build tools
	echo "CONFIG_YOCTO_BUILDTOOLS_EXTENDED=y" >> $(PETALINUX_CONFIG)

ifneq ("$(wildcard $(PRE_MIRROR))", "")
	echo $(PRE_MIRROR_CFG) >> $(PETALINUX_CONFIG)
else
	ONLINE=1
endif
ifneq ("$(wildcard $(ARCH_DIR))", "")
	echo "$(ARCH_CFG)" >> $(PETALINUX_CONFIG)
	echo "CONFIG_YOCTO_NETWORK_SSTATE_FEEDS=y" >> $(PETALINUX_CONFIG)
else
	ONLINE=1
endif

ifndef ONLINE
	echo 'CONFIG_YOCTO_NETWORK_SSTATE_FEEDS_URL="http://petalinux.xilinx.com/sswreleases/rel-v${PETALINUX_VER%%.*}/$(ARCH)/sstate-cache"' >> $(PETALINUX_CONFIG)
	echo 'CONFIG_YOCTO_BB_NO_NETWORK=y' >> $(PETALINUX_CONFIG)
else
	echo "ONLINE MODE......"
endif



update_rootfs_config:
	# PetaLinux Rootfs: Enable XRT
	echo 'CONFIG_xrt=y' >> $(PETALINUX_ROOTFS_CONFIG)
	# echo 'CONFIG_xrt-dev=y' >> $(PETALINUX_ROOTFS_CONFIG)
	# PetaLinux Rootfs: Enable DNF
	echo 'CONFIG_dnf=y' >> $(PETALINUX_ROOTFS_CONFIG)
	echo 'CONFIG_imagefeature-package-management=y' >> $(PETALINUX_ROOTFS_CONFIG)
	# PetaLinux Rootfs: Enable packages for EoU
	echo 'CONFIG_e2fsprogs-resize2fs=y' >> $(PETALINUX_ROOTFS_CONFIG)
	echo 'CONFIG_parted=y' >> $(PETALINUX_ROOTFS_CONFIG)
	echo 'CONFIG_resize-part=y' >> $(PETALINUX_ROOTFS_CONFIG)
	# PetaLinux Rootfs: Enable Vitis AI demo dependencies
	echo 'CONFIG_packagegroup-petalinux-opencv=y' >> $(PETALINUX_ROOTFS_CONFIG)
	echo 'CONFIG_mesa-megadriver=y' >> $(PETALINUX_ROOTFS_CONFIG)
	echo 'CONFIG_packagegroup-petalinux-x11=y' >> $(PETALINUX_ROOTFS_CONFIG)
	echo 'CONFIG_packagegroup-petalinux-v4lutils=y' >> $(PETALINUX_ROOTFS_CONFIG)
	echo 'CONFIG_packagegroup-petalinux-matchbox=y' >> $(PETALINUX_ROOTFS_CONFIG)

petalinux_proj:
	echo "ABS_BUILD_PATH = $(ABS_BUILD_PATH)"
ifeq ("$(wildcard $(ABS_BUILD_PATH))", "")
	echo "CREATE"
	mkdir -p $(ABS_BUILD_PATH);cd $(ABS_BUILD_PATH); petalinux-create -t project --template zynqMP --force -n $(PETALINUX_PROJ_NAME)
	echo "UPDATE_CONFIG"
	$(MAKE) -f $(lastword $(MAKEFILE_LIST)) update_config
	echo "CONFIG"
	petalinux-config -p $(PETALINUX_DIR) --get-hw-description=$(ROOT_DIR) --silentconfig
	echo "UPDATE ROOTFS"
	$(MAKE) -f $(lastword $(MAKEFILE_LIST)) update_rootfs_config
	echo "UPDATE DTSI"
	$(MAKE) -f $(lastword $(MAKEFILE_LIST)) update_dtsi
	#echo "CONFIG AGAIN"
	#petalinux-config -p $(PETALINUX_DIR) --silentconfig
endif

petalinux_build:
	$(MAKE) -f $(lastword $(MAKEFILE_LIST)) update_config
	echo "CONFIG AGAIN"
	petalinux-config -p $(PETALINUX_DIR) --silentconfig
	echo "BUILD"
	petalinux-build -s mrproper -p $(PETALINUX_DIR)
	cd $(PETALINUX_DIR) && petalinux-package --boot --u-boot --force

petalinux_build_sdk:
	petalinux-build -s mrproper -p $(PETALINUX_DIR) --sdk
	cd $(PETALINUX_DIR) && petalinux-package --sysroot

clean:
	$(RM) -r $(ABS_BUILD_PATH) vivado*.log vivado*.jou *.xsa
	#$(RM) -r  vivado*.log vivado*.jou *.xsa
