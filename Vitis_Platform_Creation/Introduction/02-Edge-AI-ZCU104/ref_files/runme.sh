#! /bin/bash
cd "$(dirname $0)"
vitis_dir=/opt/Xilinx
petalinux_dir=/opt/focal/PetaLinux
peta="step2_petalinux/build/petalinux"
function check_xrt() {
    ret=$(ldd /opt/xilinx/xrt/bin/unwrapped/xclbinutil)
    if [[ "$ret" == *"not found"* ]]; then
        echo "$ret"
        exit
    fi
}


function install_missing() {
    # sudo dpkg-reconfigure dash
    # sudo apt install libtool autoconf texinfo gcc-multilib netstat-nat net-tools libtinfo5
    PACKAGES=" libboost-all-dev autoconf libtool texinfo iproute2 gcc g++ net-tools libncurses5-dev zlib1g:i386 libssl-dev flex bison libselinux1 xterm autoconf libtool texinfo zlib1g-dev gcc-multilib build-essential screen pax gawk python3-pexpect python3-pip python3-git python3-jinja2 xz-utils debianutils iputils-ping libegl1-mesa libsdl1.2-dev pylint3 cpio tftpd-hpa libtinfo5 "
    #MISSING=$(apt -qq list $PACKAGES 2>/dev/null |grep -v installed|awk -F '/' '{ print $1 }')
    MISSING=$(dpkg --get-selections $PACKAGES 2>&1 | grep -v 'install$' | awk '{ print $6 }')

    echo "MISSING = $MISSING"
    tftp_conf="/etc/default/tftpd-hpa"
    mconf="TFTP_DIRECTORY=\"/tftpboot\""
    [[ ! -f $tftp_conf ]] && echo "$tftp_conf not found " && exit 1
    if ! grep -q $mconf "$tftp_conf"; then
        cmd="sudo sed -i 's|TFTP_DIRECTORY=\".*\"|TFTP_DIRECTORY=\"/tftpboot\"|g' /etc/default/tftpd-hpa"
        echo $cmd
        eval $cmd
    fi


    # Optional check here to skip bothering with apt-get if $MISSING is empty

    [[ ! -z $MISSING ]] && sudo apt-get install -y $MISSING
}


function delete_lock() {
    mfiles=()
    for mfile in bitbake.lock hashserve.sock bitbake.sock; do
        mfiles+=("step2_petalinux/build/petalinux/build/$mfile")
    done
    mfiles+=("step2_petalinux/build/petalinux/build/cache/prserv.sqlite3")
    for mfile in "${mfiles[@]}"; do
        #echo $mfile
        if [ -f $mfile ]; then
            cmd="rm $mfile"
            echo $cmd
            $cmd
        fi
    done

    #exit 0
}

function setup_source() {
    settings=()
    settings+=("$vitis_dir/Vitis/2021.2/settings64.sh")
    settings+=("$petalinux_dir/2021.2/settings.sh")
    for setting in "${settings[@]}"; do
        [[ ! -f $setting ]] && echo "$setting cannot be found!" && exit 1
        #echo -e "\n$setting\n"
        cmd="source $setting"
        echo $cmd
        $cmd
        [[ "$?" -ne "0" ]] && echo "failed" && exit $?
    done
    #exit 0
}

function making() {
    echo "arg1 = $1"
    if [ "$1" == "all" ]; then
        cmd="make all"
        echo $cmd
        $cmd
    else
        procs=("step2_petalinux petalinux_build" "step2_petalinux petalinux_build_sdk" "step3_pfm all")
        for proc in "${procs[@]}"; do
            cmd="make -C $proc"
            echo $cmd
            $cmd
            [[ "$?" -ne "0" ]] && echo "failed" && exit $?
        done
    fi
}

function cp_to_boot() {
    boot="step3_pfm/boot"
    [[ ! -d $boot ]] && echo "$boot not found" && exit 1

    for mfile in zynqmp_fsbl.elf pmufw.elf bl31.elf u-boot-dtb.elf system.dtb ; do
        mfile="$peta/images/linux/$mfile"
        [[ ! -f $mfile  ]] && echo "$mfile not found" && exit 1
        cmd="cp $mfile $boot"
        echo $cmd
        $cmd
    done

    sd_dir="step3_pfm/sd_dir"
    [[ ! -d $sd_dir ]] && echo "$sd_dir not found" && exit 1
    for mfile in boot.scr system.dtb; do
        mfile="$peta/images/linux/$mfile"
        [[ ! -f $mfile  ]] && echo "$mfile not found" && exit 1
        cmd="cp $mfile $sd_dir"
        echo $cmd
        $cmd
    done

    sw_comp="step3_pfm/sw_comp"
    [[ ! -d $sw_comp ]] && echo "$sw_comp not found" && exit 1
    for mfile in rootfs.ext4 Image; do
        mfile="$peta/images/linux/$mfile"
        [[ ! -f $mfile  ]] && echo "$mfile not found" && exit 1
        cmd="cp $mfile $sw_comp"
        echo $cmd
        $cmd
    done
}


install_missing
delete_lock
setup_source
making $1
cp_to_boot
source /opt/Xilinx/Vivado/2021.2/settings64.sh
make
