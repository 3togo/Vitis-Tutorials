
function making() {
    echo "arg1 = $1"
    if [ "$1" == "all" ]; then
        cmd="make all"
        echo $cmd
        $cmd
    else
        procs=("petalinux_build" "petalinux_build_sdk")
        for proc in "${procs[@]}"; do
            cmd="make $proc"
            echo $cmd
            $cmd
            [[ "$?" -ne "0" ]] && echo "failed" && exit $?
        done
    fi
}

source /opt/focal/PetaLinux/2021.2/settings.sh
making $1
