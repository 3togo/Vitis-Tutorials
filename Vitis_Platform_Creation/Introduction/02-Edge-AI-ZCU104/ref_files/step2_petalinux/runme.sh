#! /bin/bash
#https://blog.csdn.net/lulugay/article/details/99715402
#https://www.fpgadeveloper.com/how-to-install-petalinux-2020.1/
#install pentalinux w.r.t above
PACKAGES="iproute2 gcc g++ net-tools libncurses5-dev zlib1g:i386 libssl-dev flex bison libselinux1 xterm autoconf libtool texinfo zlib1g-dev gcc-multilib build-essential screen pax gawk python3 python3-pexpect python3-pip python3-git python3-jinja2 xz-utils debianutils iputils-ping libegl1-mesa libsdl1.2-dev pylint3 cpio"
MISSING=$(dpkg --get-selections $PACKAGES 2>&1 | grep -v 'install$' | awk '{ print $6 }')
echo "Number of missing packages = ${#MISSING}"
# Optional check here to skip bothering with apt-get if $MISSING is empty
[[ ! -z $MISSING ]] && sudo apt-get install $MISSING
diff -u /bin/sh /bin/bash > /dev/null
if [[ $? -ne 0 ]]; then
    chsh -s /bin/bash
    sudo rm /bin/sh
    sudo ln -sf /bin/bash /bin/sh
fi
VER=2021.2
mdir=/opt/petalinux/$VER
cmds=()
cmds+=("mkdir -p $mdir")
cmds+=("~/Downloads/petalinux-v$VER-final-installer.run -d $mdir")
for cmd in "${cmds[@]}"; do
    echo $cmd
done

