#!/bin/bash
function logo {
    clear

    echo "╔╗──╔╗╔══╗╔╗──╔╗╔══╗╔══╗─╔╗╔══╗"
    echo "║║──║║║╔═╝║║──║║║╔╗║║╔╗║╔╝║║╔═╝"
    echo "║╚╗╔╝║║╚═╗║╚╗╔╝║║╚╝║║╚╝║╚╗║║╚═╗"
    echo "║╔╗╔╗║╚═╗║║╔╗╔╗║║╔╗║╚═╗║─║║║╔╗║"
    echo "║║╚╝║║╔═╝║║║╚╝║║║╚╝║╔═╝║─║║║╚╝║"
    echo "╚╝──╚╝╚══╝╚╝──╚╝╚══╝╚══╝─╚╝╚══╝"
    echo ""
}

function syncer {
    if [ ! -d $XPATH/.repo/ ]; then
        echo "!!! NO ROM MANIFEST INITIALIZED !!!"
        exit
    fi
    if [ ! -d $XPATH/.repo/local_manifests/ ]; then
        echo "!!! NO DEVICE TREE INITIALIZED !!!"
        exit
    fi

    logo
    echo "-----------SYNC TYPE-----------"
    echo ""
    echo "1 - Fast sync"
    echo "2 - Slow sync"
    echo "3 - Forced sync"

    read -s -n 1 XCHOICE

    logo
    echo "------------SYNCING------------"
    echo "--------------ROM--------------"

    case $XCHOICE in
        1)
            repo sync -f -c -q -j $(nproc) --no-tags
            ;;
        2)
            repo sync -f -c -q -j 4 --no-tags
            ;;
        3)
            repo sync -f -c -q -j $(nproc) --no-tags --force-sync --no-clone-bundle
            ;;
        *)
            echo "WAT?"
            exit
            ;;
    esac

    if [ ! -d $XPATH/hardware/qcom/ ]; then
        echo "!!! SYNC ERROR !!!"
        exit
    fi
    
    logo
    echo "------------SYNCING------------"
    echo "----QCOM CAF HARDWARE FIXES----"
    
    cd $XPATH/hardware/qcom/display-caf/msm8916
    curl https://github.com/YaAlex3/android_hardware_qcom_display/commit/81ff90e84f82f95674f4bb0d1a51db2ce123eeef.patch | git am
    cd $XPATH/hardware/qcom/audio-caf/msm8916
    curl https://github.com/YaAlex3/android_hardware_qcom_audio/commit/82c5cd225e57c21f3475766a5069626b365e66a9.patch | git am

    if [ ! -d $XPATH/vendor/opengapps/ ]; then
        echo "NO GAPPS SYNCED"
    fi
    
    logo
    echo "------------SYNCING------------"
    echo "-----------GAPPS 1/5-----------"
    
    cd $XPATH/vendor/opengapps/sources/all
    git lfs pull
    
    logo
    echo "------------SYNCING------------"
    echo "-----------GAPPS 2/5-----------"
    
    cd $XPATH/vendor/opengapps/sources/arm
    git lfs pull
    
    logo
    echo "------------SYNCING------------"
    echo "-----------GAPPS 3/5-----------"
    
    cd $XPATH/vendor/opengapps/sources/arm64
    git lfs pull
    
    logo
    echo "------------SYNCING------------"
    echo "-----------GAPPS 4/5-----------"
    
    cd $XPATH/vendor/opengapps/sources/x86
    git lfs pull
    
    logo
    echo "------------SYNCING------------"
    echo "-----------GAPPS 5/5-----------"
    
    cd $XPATH/vendor/opengapps/sources/x86_64
    git lfs pull
    
    logo
    echo "-------------DONE.-------------"
}

XPATH=$(pwd)

logo
echo "--------------ROM--------------"
echo ""
echo "0 - Skip setup"
echo "1 - LineageOS 16"
echo "2 - LineageOS 16 (disk space saving)"

read -s -n 1 XCHOICE

clear

case $XCHOICE in
    0)
        syncer
        exit
        ;;
    1)
        repo init -u git://github.com/LineageOS/android.git -b lineage-16.0
        ;;
    2)
        repo init --depth=1 -u git://github.com/LineageOS/android.git -b lineage-16.0
        ;;
    *)
        echo "WAT?"
        exit
        ;;
esac

if [ ! -d $XPATH/.repo/ ]; then
    echo "!!! NO ROM MANIFEST INITIALIZED !!!"
    exit
fi

logo
echo "----------DEVICE TREE----------"
echo ""
echo "1 - Z00ED"
echo "2 - Z00ED GAPPS"

read -s -n 1 XCHOICE

clear

case $XCHOICE in
    1)
        git clone https://github.com/Asus-MSM8916/android_manifest.git -b lineage-16.0-Z00ED
        ;;
    2)
        git clone https://github.com/Asus-MSM8916/android_manifest.git -b lineage-16.0-Z00ED-gapps
        ;;
    *)
        echo "WAT?"
        exit
        ;;
esac

if [ ! -d $XPATH/android_manifest/ ]; then
    echo "!!! NO DEVICE TREE INITIALIZED !!!"
    exit
fi

mv $XPATH/android_manifest/local_manifests/ $XPATH/.repo/local_manifests/
rm -rf $XPATH/android_manifest/

syncer
