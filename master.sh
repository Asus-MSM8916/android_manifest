#!/bin/bash

VAR_LOCAL_PATH=$(pwd)
VAR_LM_PATH=$VAR_LOCAL_PATH/.repo/local_manifests/local_manifest.xml
VAR_JSON_REPO=LineageOS
CONFIG_ANDROID_VERSION=x
CONFIG_OS_SUPPORTED=n
# Default language
LANG_HAS_SOURCES="Found sources. Build (b), sync and build (y) or remove (n)?"
LANG_DELETING="Deleting..."
LANG_ERROR_ACTION="Error: no such action"
LANG_ASKSETUP="Would you like to install Android build packages (y)?"
LANG_WARN_OS="Warning: unsupported OS. Do you have apt (y)?"
LANG_INSTALLING="Installing packages..."
LANG_HAS_REPO="Found repo. Sync (y) or remove (n)?"
LANG_CHOOSE_ROM="Choose ROM"
LANG_ERROR_ROM="Error: no such ROM"
LANG_CHOOSE_DEVICE="Choose device"
LANG_ERROR_DEVICE="Error: no such device"
LANG_ADD_GAPPS="Would you like to add Gapps (y)?"
LANG_NO_REPO="Error: no repo manifest"
LANG_NO_DEVICE="Error: no device manifest"
LANG_SYNC_TYPE="Choose sync type"
LANG_SYNC_FAST="1 - Fast sync"
LANG_SYNC_SLOW="2 - Slow sync"
LANG_SYNC_FORCED="3 - Forced sync"
LANG_ERROR_TYPE="Error: no such sync type"
LANG_SYNC_ROM="Syncing ROM..."
LANG_SYNC_GAPPS="Syncing Gapps..."
LANG_SYNC_DONE="Syncing done"
LANG_BUILD="Would you like to build ROM (y)?"
LANG_BUILDING="Building..."
LANG_BUILDING_COMPLETE="Building complete"

function ClearLogo {
    clear
    echo "╔══╦══╦╗╔╦══╗╔╗──╔╦══╦╗──╔╗"
    echo "║╔╗║╔═╣║║║╔═╝║║──║║╔═╣║──║║"
    echo "║╚╝║╚═╣║║║╚═╗║╚╗╔╝║╚═╣╚╗╔╝║"
    echo "║╔╗╠═╗║║║╠═╗║║╔╗╔╗╠═╗║╔╗╔╗║"
    echo "║║║╠═╝║╚╝╠═╝║║║╚╝║╠═╝║║╚╝║║"
    echo "╚╝╚╩══╩══╩══╝╚╝──╚╩══╩╝──╚╝"
    echo ""
}

function LangRu {
    LANG_HAS_SOURCES="Обнаружен исходный код. Собрать (b), синхронизировать и собрать (y) или удалить (n)?"
    LANG_DELETING="Удаление..."
    LANG_ERROR_ACTION="Ошибка: нет такого действия"
    LANG_ASKSETUP="Установить пакеты для сборки Android (y)?"
    LANG_WARN_OS="Внимание: неподдерживаемая ОС. У Вас есть apt (y)?"
    LANG_INSTALLING="Установка пакетов..."
    LANG_HAS_REPO="Найден repo. Синхронизировать (y) или удалить (n)?"
    LANG_CHOOSE_ROM="Выберите прошивку"
    LANG_ERROR_ROM="Ошибка: нет такой прошивки"
    LANG_CHOOSE_DEVICE="Выберите устройство"
    LANG_ERROR_DEVICE="Ошибка: нет такого устройства"
    LANG_ADD_GAPPS="Добавить Gapps (y)?"
    LANG_NO_REPO="Ошибка: repo manifest не найден"
    LANG_NO_DEVICE="Ошибка: device manifest не найден"
    LANG_SYNC_TYPE="Выберите тип синхронизации"
    LANG_SYNC_FAST="1 - Быстрая"
    LANG_SYNC_SLOW="2 - Медленная"
    LANG_SYNC_FORCED="3 - Принудительная"
    LANG_ERROR_TYPE="Ошибка: нет такого типа синхронизации"
    LANG_SYNC_ROM="Синхронизация прошивки..."
    LANG_SYNC_GAPPS="Синхронизация Gapps..."
    LANG_BUILD="Собрать прошивку (y)?"
    LANG_BUILDING="Сборка прошивки..."
    LANG_BUILDING_COMPLETE="Сборка завершена"
}

function PrepareSystem {
    ClearLogo
    if [ ! "$(uname -a | grep Ubuntu)" == "" ]; then
        CONFIG_OS_SUPPORTED=y
    else
        echo $LANG_WARN_OS
        echo ""
        SH_CHOICE=n
        read -s -n 1 SH_CHOICE
    fi
    if [ $CONFIG_OS_SUPPORTED == y ] || [ $SH_CHOICE == y ]; then
        echo $LANG_INSTALLING
        echo ""
        sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get install -y git-core gnupg flex bison gperf build-essential zip curl zlib1g-dev gcc-multilib g++-multilib libc6-dev-i386 lib32ncurses5-dev x11proto-core-dev libx11-dev lib32z-dev libgl1-mesa-dev libxml2-utils xsltproc unzip git imagemagick openjdk-8-jdk python maven git-lfs meld ghex libssl-dev libncurses5 && sudo apt-get autoremove -y
        curl https://storage.googleapis.com/git-repo-downloads/repo > repo
        chmod a+x repo
        sudo mv repo /bin/repo
    fi
}

# ROM should be declared here
function InitROM {
    ClearLogo
    echo $LANG_CHOOSE_ROM
    echo ""
    echo "1 - TWRP"
    echo "2 - LineageOS 16.0"
    echo "3 - LineageOS 17.1"
    echo ""
    SH_CHOICE=0
    read -s -n 1 SH_CHOICE
    case $SH_CHOICE in
        1)
            CONFIG_ANDROID_VERSION=t
            repo init --depth=1 -u git://github.com/minimal-manifest-twrp/platform_manifest_twrp_omni.git -b twrp-9.0
            ;;
        2)
            CONFIG_ANDROID_VERSION=p
            repo init --depth=1 -u git://github.com/LineageOS/android.git -b lineage-16.0
            ;;
        3)
            CONFIG_ANDROID_VERSION=q
            repo init --depth=1 -u git://github.com/LineageOS/android.git -b lineage-17.1
            ;;
        *)
            echo $LANG_ERROR_ROM
            echo ""
            exit
            ;;
    esac
}

# Device should be declared here
function InitDevice {
    mkdir -p $VAR_LOCAL_PATH/.repo/local_manifests/
    touch $VAR_LM_PATH
    echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" >> $VAR_LM_PATH
    echo "<manifest>" >> $VAR_LM_PATH
    ClearLogo
    echo $LANG_CHOOSE_DEVICE
    echo ""
    echo "1 - Z00xD"
    echo ""
    SH_CHOICE=0
    read -s -n 1 SH_CHOICE
    case $SH_CHOICE in
        1)
            echo "  <!-- ASUS ZenFone 2 Laser ZE500KL ZE500KG -->" >> $VAR_LM_PATH
            VAR_JSON_REPO=Asus-MSM8916
            case $CONFIG_ANDROID_VERSION in
                p)
                    echo "  <project name=\"Asus-MSM8916/android_device_asus_Z00xD\" path=\"device/asus/Z00xD\" revision=\"lineage-16.0\" remote=\"github\" />" >> $VAR_LM_PATH
                    echo "  <project name=\"Asus-MSM8916/android_device_asus_msm8916-common\" path=\"device/asus/msm8916-common\" revision=\"lineage-16.0\" remote=\"github\" />" >> $VAR_LM_PATH
                    echo "  <project name=\"Asus-MSM8916/android_kernel_asus_msm8916\" path=\"kernel/asus/msm8916\" revision=\"9.x-staging\" remote=\"github\" />" >> $VAR_LM_PATH
                    echo "  <project name=\"Asus-MSM8916/android_vendor_asus\" path=\"vendor/asus\" revision=\"9.x\" remote=\"github\" />" >> $VAR_LM_PATH
                    echo "  <project name=\"kdrag0n/aarch64-elf-gcc\" path=\"prebuilts/gcc/linux-x86/aarch64/aarch64-elf\" revision=\"9.x\" remote=\"github\" />" >> $VAR_LM_PATH
                    ;;
                q)
                    echo "  <project name=\"Asus-MSM8916/android_device_asus_Z00xD\" path=\"device/asus/Z00xD\" revision=\"lineage-17.1\" remote=\"github\" />" >> $VAR_LM_PATH
                    echo "  <project name=\"Asus-MSM8916/android_device_asus_msm8916-common\" path=\"device/asus/msm8916-common\" revision=\"lineage-17.1\" remote=\"github\" />" >> $VAR_LM_PATH
                    echo "  <project name=\"Asus-MSM8916/android_kernel_asus_msm8916\" path=\"kernel/asus/msm8916\" revision=\"10.x\" remote=\"github\" />" >> $VAR_LM_PATH
                    echo "  <project name=\"Asus-MSM8916/android_vendor_asus\" path=\"vendor/asus\" revision=\"lineage-17.1\" remote=\"github\" />" >> $VAR_LM_PATH
                    echo "  <project name=\"kdrag0n/aarch64-elf-gcc\" path=\"prebuilts/gcc/linux-x86/aarch64/aarch64-elf\" revision=\"9.x\" remote=\"github\" />" >> $VAR_LM_PATH
                    ;;
                t)
                    echo "  <project name=\"Asus-MSM8916/android_device_asus_Z00xD-twrp\" path=\"device/asus/Z00xD\" revision=\"9.x-twrp\" remote=\"github\" />" >> $VAR_LM_PATH
                    ;;
                *)
                    echo "Error: internal error"
                    echo ""
                    exit
                    ;;
            esac
            ;;
        *)
            echo $LANG_ERROR_DEVICE
            echo ""
            exit
            ;;
    esac
}

function AddGapps {
    ClearLogo
    echo $LANG_ADD_GAPPS
    echo ""
    SH_CHOICE=n
    read -s -n 1 SH_CHOICE
    if [ $SH_CHOICE == y ]; then
        echo "  <!-- OpenGapps -->" >> $VAR_LM_PATH
        echo "  <remote name=\"opengapps\" fetch=\"https://github.com/opengapps/\" />" >> $VAR_LM_PATH
        echo "  <remote name=\"opengapps-gitlab\" fetch=\"https://gitlab.opengapps.org/opengapps/\" />" >> $VAR_LM_PATH
        echo "  <project path=\"vendor/opengapps/build\" name=\"aosp_build\" revision=\"master\" remote=\"opengapps\" />" >> $VAR_LM_PATH
        echo "  <project path=\"vendor/opengapps/sources/all\" name=\"all\" clone-depth=\"1\" revision=\"master\" remote=\"opengapps-gitlab\" />" >> $VAR_LM_PATH
        echo "  <!-- arm64 depends on arm -->" >> $VAR_LM_PATH
        echo "  <project path=\"vendor/opengapps/sources/arm\" name=\"arm\" clone-depth=\"1\" revision=\"master\" remote=\"opengapps-gitlab\" />" >> $VAR_LM_PATH
        echo "  <project path=\"vendor/opengapps/sources/arm64\" name=\"arm64\" clone-depth=\"1\" revision=\"master\" remote=\"opengapps-gitlab\" />" >> $VAR_LM_PATH
        echo "  <project path=\"vendor/opengapps/sources/x86\" name=\"x86\" clone-depth=\"1\" revision=\"master\" remote=\"opengapps-gitlab\" />" >> $VAR_LM_PATH
        echo "  <project path=\"vendor/opengapps/sources/x86_64\" name=\"x86_64\" clone-depth=\"1\" revision=\"master\" remote=\"opengapps-gitlab\" />" >> $VAR_LM_PATH
    fi
}

function SyncOpenGapps {
    ClearLogo
    echo $LANG_SYNC_GAPPS
    echo "1/5"
    echo ""
    cd $VAR_LOCAL_PATH/vendor/opengapps/sources/all
    git lfs pull
    echo "2/5"
    echo ""
    cd $VAR_LOCAL_PATH/vendor/opengapps/sources/arm
    git lfs pull
    echo "3/5"
    echo ""
    cd $VAR_LOCAL_PATH/vendor/opengapps/sources/arm64
    git lfs pull
    echo "4/5"
    echo ""
    cd $VAR_LOCAL_PATH/vendor/opengapps/sources/x86
    git lfs pull
    echo "5/5"
    echo ""
    cd $VAR_LOCAL_PATH/vendor/opengapps/sources/x86_64
    git lfs pull
    cd $VAR_LOCAL_PATH/
}

function FixQcomCaf16 {
    sed -i "s/zd/ld/g" $VAR_LOCAL_PATH/hardware/qcom/display-caf/msm8916/libhdmi/hdmi.cpp
    sed -i "s/zd/ld/g" $VAR_LOCAL_PATH/hardware/qcom/display-caf/msm8916/libqdutils/idle_invalidator.cpp
    sed -i "s/zd/ld/g" $VAR_LOCAL_PATH/hardware/qcom/audio-caf/msm8916/hal/audio_hw.c
}

function FixQcomCaf17 {
    sed -i "s/zd/ld/g" $VAR_LOCAL_PATH/hardware/qcom-caf/msm8916/display/libhdmi/hdmi.cpp
    sed -i "s/zd/ld/g" $VAR_LOCAL_PATH/hardware/qcom-caf/msm8916/display/libqdutils/idle_invalidator.cpp
    sed -i "s/zd/ld/g" $VAR_LOCAL_PATH/hardware/qcom-caf/msm8916/audio/hal/audio_hw.c
}

function SyncRepo {
    if [ ! -d $VAR_LOCAL_PATH/.repo/ ]; then
        echo $LANG_NO_REPO
    fi
    if [ ! -d $VAR_LOCAL_PATH/.repo/local_manifests/ ]; then
        echo $LANG_NO_DEVICE
    fi
    rm -rf $VAR_LOCAL_PATH/hardware/qcom/display-caf/msm8916/
    rm -rf $VAR_LOCAL_PATH/hardware/qcom/audio-caf/msm8916/
    rm -rf $VAR_LOCAL_PATH/hardware/qcom-caf/msm8916/display/
    rm -rf $VAR_LOCAL_PATH/hardware/qcom-caf/msm8916/audio/
    ClearLogo
    echo $LANG_SYNC_TYPE
    echo ""
    echo $LANG_SYNC_FAST
    echo $LANG_SYNC_SLOW
    echo $LANG_SYNC_FORCED
    echo ""
    SH_CHOICE=0
    read -s -n 1 SH_CHOICE
    echo $LANG_SYNC_ROM
    echo ""
    case $SH_CHOICE in
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
            echo $LANG_ERROR_TYPE
            echo ""
            exit
            ;;
    esac
    case $CONFIG_ANDROID_VERSION in
        t)
            FixQcomCaf16
            ;;
        p)
            FixQcomCaf16
            ;;
        q)
            FixQcomCaf17
            ;;
        *)
            echo "Error: internal error"
            echo ""
            exit
            ;;
    esac
    if [ -d $VAR_LOCAL_PATH/vendor/opengapps/ ]; then
        SyncOpenGapps
    fi
    if [ ! $CONFIG_ANDROID_VERSION == t ]; then
        sed -i "s/https:\/\/download.lineageos.org\/api\/v1\/{device}\/{type}\/{incr}/https:\/\/raw.githubusercontent.com\/$VAR_JSON_REPO\/lineage_OTA\/master\/{device}_$CONFIG_ANDROID_VERSION.json/" $VAR_LOCAL_PATH/packages/apps/Updater/res/values/strings.xml
    fi
}

function BuildAndroid {
    ClearLogo
    echo $LANG_BUILDING
    echo ""
    . build/envsetup.sh
    export LC_ALL=C
    export WITHOUT_CHECK_API=true
    make installclean -j $(nproc)
    lunch -j $(nproc)
    brunch $TARGET_PRODUCT-$TARGET_BUILD_VARIANT -j $(nproc)
    echo $LANG_BUILDING_COMPLETE
    echo ""
    exit
}

# Cleanup
rm -rf $VAR_LOCAL_PATH/.git/
rm -rf $VAR_LOCAL_PATH/README.md

# Language
ClearLogo
echo "Select language"
echo ""
echo "0 - English"
echo "1 - Russian"
echo ""
SH_CHOICE=x
read -s -n 1 SH_CHOICE
case $SH_CHOICE in
    0)
        ;;
    1)
        LangRu
        ;;
    *)
        echo "Error: no such language"
        echo ""
        exit
        ;;
esac

# System setup
ClearLogo
echo $LANG_ASKSETUP
echo ""
SH_CHOICE=n
read -s -n 1 SH_CHOICE
if [ $SH_CHOICE == y ]; then
    PrepareSystem
fi

# Has sources
if [ -d $VAR_LOCAL_PATH/device/ ]; then
    ClearLogo
    echo $LANG_HAS_SOURCES
    echo ""
    SH_CHOICE=x
    read -s -n 1 SH_CHOICE
    case $SH_CHOICE in
        b)
            BuildAndroid
            ;;
        y)
            SyncRepo
            BuildAndroid
            ;;
        n)
            echo $LANG_DELETING
            echo ""
            ls | grep -v master.sh | xargs rm -rf
            ;;
        *)
            echo $LANG_ERROR_ACTION
            echo ""
            exit
            ;;
    esac
fi

# Has repo
if [ -d $VAR_LOCAL_PATH/.repo/ ]; then
    ClearLogo
    echo $LANG_HAS_REPO
    echo ""
    SH_CHOICE=x
    read -s -n 1 SH_CHOICE
    case $SH_CHOICE in
        y)
            SyncRepo
            BuildAndroid
            ;;
        n)
            echo $LANG_DELETING
            echo ""
            rm -rf $VAR_LOCAL_PATH/.repo/
            ;;
        *)
            echo $LANG_ERROR_ACTION
            echo ""
            exit
            ;;
    esac
fi

InitROM
InitDevice
if [ ! $CONFIG_ANDROID_VERSION == t ]; then
    AddGapps
fi
echo "</manifest>" >> $VAR_LM_PATH
SyncRepo

ClearLogo
echo $LANG_SYNC_DONE
echo ""
echo $LANG_BUILD
echo ""
SH_CHOICE=n
read -s -n 1 SH_CHOICE
if [ $SH_CHOICE == y ]; then
    BuildAndroid
fi
