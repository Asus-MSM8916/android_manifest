#!/bin/bash
function syncer {
    if [ ! -d $XPATH/.repo/ ]; then
        echo "!!! SYNC ERROR !!!"
        exit
    fi
    repo sync -f -c -q -j $(nproc) --no-tags

    if [ ! -d $XPATH/hardware/qcom/ ]; then
        echo "!!! SYNC ERROR !!!"
        exit
    fi
    cd $XPATH/hardware/qcom/display-caf/msm8916
    curl https://github.com/YaAlex3/android_hardware_qcom_display/commit/81ff90e84f82f95674f4bb0d1a51db2ce123eeef.patch | git am
    cd $XPATH/hardware/qcom/audio-caf/msm8916
    curl https://github.com/YaAlex3/android_hardware_qcom_audio/commit/82c5cd225e57c21f3475766a5069626b365e66a9.patch | git am

    if [ ! -d $XPATH/vendor/opengapps/ ]; then
        echo "NO GAPPS SYNCED"
    fi
    cd $XPATH/vendor/opengapps/sources/all
    git lfs pull
    cd $XPATH/vendor/opengapps/sources/arm
    git lfs pull
    cd $XPATH/vendor/opengapps/sources/arm64
    git lfs pull
    cd $XPATH/vendor/opengapps/sources/x86
    git lfs pull
    cd $XPATH/vendor/opengapps/sources/x86_64
    git lfs pull
}

XPATH=$(pwd)

clear

echo "╔╗──╔╗╔══╗╔╗──╔╗╔══╗╔══╗─╔╗╔══╗"
echo "║║──║║║╔═╝║║──║║║╔╗║║╔╗║╔╝║║╔═╝"
echo "║╚╗╔╝║║╚═╗║╚╗╔╝║║╚╝║║╚╝║╚╗║║╚═╗"
echo "║╔╗╔╗║╚═╗║║╔╗╔╗║║╔╗║╚═╗║─║║║╔╗║"
echo "║║╚╝║║╔═╝║║║╚╝║║║╚╝║╔═╝║─║║║╚╝║"
echo "╚╝──╚╝╚══╝╚╝──╚╝╚══╝╚══╝─╚╝╚══╝"
echo ""
echo "--------------ROM--------------"
echo ""
echo "0 - Skip setup"
echo "1 - LineageOS 16"

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
esac

if [ ! -d $XPATH/.repo/ ]; then
    echo "!!! NO ROM MANIFEST INITIALIZED !!!"
    exit
fi

clear

echo "╔╗──╔╗╔══╗╔╗──╔╗╔══╗╔══╗─╔╗╔══╗"
echo "║║──║║║╔═╝║║──║║║╔╗║║╔╗║╔╝║║╔═╝"
echo "║╚╗╔╝║║╚═╗║╚╗╔╝║║╚╝║║╚╝║╚╗║║╚═╗"
echo "║╔╗╔╗║╚═╗║║╔╗╔╗║║╔╗║╚═╗║─║║║╔╗║"
echo "║║╚╝║║╔═╝║║║╚╝║║║╚╝║╔═╝║─║║║╚╝║"
echo "╚╝──╚╝╚══╝╚╝──╚╝╚══╝╚══╝─╚╝╚══╝"
echo ""
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
esac

if [ ! -d $XPATH/android_manifest/ ]; then
    echo "!!! NO DEVICE TREE INITIALIZED !!!"
    exit
fi

mv $XPATH/android_manifest/local_manifests/ $XPATH/.repo/local_manifests/
rm -rf $XPATH/android_manifest/

clear

echo "╔╗──╔╗╔══╗╔╗──╔╗╔══╗╔══╗─╔╗╔══╗"
echo "║║──║║║╔═╝║║──║║║╔╗║║╔╗║╔╝║║╔═╝"
echo "║╚╗╔╝║║╚═╗║╚╗╔╝║║╚╝║║╚╝║╚╗║║╚═╗"
echo "║╔╗╔╗║╚═╗║║╔╗╔╗║║╔╗║╚═╗║─║║║╔╗║"
echo "║║╚╝║║╔═╝║║║╚╝║║║╚╝║╔═╝║─║║║╚╝║"
echo "╚╝──╚╝╚══╝╚╝──╚╝╚══╝╚══╝─╚╝╚══╝"
echo ""
echo "---------START SYNCING---------"
echo ""

syncer
