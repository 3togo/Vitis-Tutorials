#! /bin/bash
ret=$(ldd /opt/xilinx/xrt/bin/unwrapped/xclbinutil)
if [[ "$ret" == *"not found"* ]]; then
    echo "$ret"
    echo "reinstall xrt!"
    echo "https://www.xilinx.com/products/boards-and-kits/alveo/u50.html#gettingStarted"
    exit
fi
