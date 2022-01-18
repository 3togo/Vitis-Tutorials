vitis_dir=/opt/Xilinx
petalinux_dir=/opt/focal/PetaLinux
settings=()
settings+=("$vitis_dir/Vitis/2021.2/settings64.sh")
settings+=("$petalinux_dir/2021.2/settings.sh")
for setting in "${settings[@]}"; do
    [[ ! -f $setting ]] && echo "$setting cannot be found!" && exit 1 
    #echo -e "\n$setting\n"
    cmd="source $setting"
    echo $cmd
    $cmd
done
make -C step2_petalinux petalinux_build
make -C step2_petalinux petalinux_build_sdk
make -C step3_pfm all
