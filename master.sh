#!/bin/bash

PATH_PWD=$(pwd)/master_pwd
PATH_SETTINGS=$PATH_PWD/mdata

FILE_LM=$PATH_PWD/.repo/local_manifests/local_manifest.xml

CONFIG_LANG=default
CONFIG_ANDROID=default
CONFIG_RECOVERY=default
CONFIG_DEVICE=default

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

function LoadLangEN {
    LANG_ERR_0000="Warning: your system does not support apt. You need to install build packages manually. Press any key to continue..."
    LANG_ERR_0001="Error: no such ROM"
    LANG_ERR_0002="Error: no such device"
    LANG_ERR_0003="Error: no ROM manifest"
    LANG_ERR_0004="Error: no device manifest"
    LANG_ERR_0005="Error: no such sync type"
    LANG_ERR_0006="Error: sync failed"
    LANG_0000="Choose ROM"
    LANG_0001="Choose device"
    LANG_0002="Add OpenGapps (y)?"
    LANG_0003="Syncing OpenGapps"
    LANG_0004="Update sources (y)?"
    LANG_0005="Choose sync type"
    LANG_0006="1 - Fast"
    LANG_0007="2 - Slow"
    LANG_0008="3 - Forced"
    LANG_0009="Build android (y)?"
}

function LoadLangRU {
    LANG_ERR_0000="Внимание: Ваша система не поддерживает apt. Вам придётся установить сборочные пакеты вручную. Нажмите любую клавишу для продолжения..."
    LANG_ERR_0001="Ошибка: такой прошивки нет"
    LANG_ERR_0002="Ошибка: такого устройства нет"
    LANG_ERR_0003="Ошибка: прошивка не проинициализирована"
    LANG_ERR_0004="Ошибка: устройство не проинициализировано"
    LANG_ERR_0005="Ошибка: нет такого типа синхронизации"
    LANG_ERR_0006="Ошибка: синхронизация не удалась"
    LANG_0000="Выберите прошивку"
    LANG_0001="Выберите устройство"
    LANG_0002="Добавить OpenGapps (y)?"
    LANG_0003="Синхронизация OpenGapps"
    LANG_0004="Обновить исходный код (y)?"
    LANG_0005="Выберите тип синхронизации"
    LANG_0006="1 - Быстрая"
    LANG_0007="2 - Медленная"
    LANG_0008="3 - Принудительная"
    LANG_0009="Собрать Android (y)?"
}

function SetupLanguage {
    ClearLogo
    echo "Language setup"
    echo ""
    echo "0 - English"
    echo "1 - Русский"
    echo ""
    CHOICE=default
    read -s -n 1 CHOICE
    case $CHOICE in
        0)
            CONFIG_LANG=EN
            ;;
        1)
            CONFIG_LANG=RU
            ;;
        *)
            echo "Error: no such language"
            echo ""
            exit
            ;;
    esac
    echo "LANG=$CONFIG_LANG" >> $PATH_SETTINGS
    LoadLang$CONFIG_LANG
}

function SetupPackages {
    ClearLogo
    if [ -f /bin/apt ]; then
        sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get install -y git-core gnupg flex bison gperf build-essential zip curl zlib1g-dev gcc-multilib g++-multilib libc6-dev-i386 lib32ncurses5-dev x11proto-core-dev libx11-dev lib32z-dev libgl1-mesa-dev libxml2-utils xsltproc unzip git imagemagick openjdk-8-jdk python maven git-lfs meld ghex libssl-dev libncurses5 && sudo apt-get autoremove -y
        curl https://storage.googleapis.com/git-repo-downloads/repo > repo
        chmod a+x repo
        sudo mv repo /bin/repo
    else
        echo $LANG_ERR_0000
        echo ""
        read -s -n 1 NULL
    fi
}

function SetupAndroid {
    ClearLogo
    echo $LANG_0000
    echo ""
    echo "1 - TWRP"
    echo "2 - LineageOS 16.0"
    echo "3 - LineageOS 17.1"
    echo ""
    CHOICE=default
    read -s -n 1 CHOICE
    case $CHOICE in
        1)
            CONFIG_ANDROID=p
            CONFIG_RECOVERY=y
            repo init --depth=1 -u git://github.com/minimal-manifest-twrp/platform_manifest_twrp_omni.git -b twrp-9.0
            ;;
        2)
            CONFIG_ANDROID=p
            CONFIG_RECOVERY=n
            repo init --depth=1 -u git://github.com/LineageOS/android.git -b lineage-16.0
            ;;
        3)
            CONFIG_ANDROID=q
            CONFIG_RECOVERY=n
            repo init --depth=1 -u git://github.com/LineageOS/android.git -b lineage-17.1
            ;;
        *)
            echo $LANG_ERR_0001
            echo ""
            exit
            ;;
    esac
    echo "ANDROID=$CONFIG_ANDROID" >> $PATH_SETTINGS
    echo "RECOVERY=$CONFIG_RECOVERY" >> $PATH_SETTINGS
}

function SetupDevice {
    ClearLogo
    mkdir -p $PATH_PWD/.repo/local_manifests/
    touch $FILE_LM
    echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" >> $FILE_LM
    echo "<manifest>" >> $FILE_LM
    echo $LANG_0001
    echo ""
    echo "1 - Z00xD"
    echo ""
    CHOICE=default
    read -s -n 1 CHOICE
    case $CHOICE in
        1)
            CONFIG_DEVICE=Z00xD
            echo "  <!-- ASUS ZenFone 2 Laser ZE500KL ZE500KG -->" >> $FILE_LM
            if [ $CONFIG_RECOVERY == y ]; then
                echo "  <project name=\"Asus-MSM8916/android_device_asus_Z00xD-twrp\" path=\"device/asus/Z00xD\" revision=\"9.x-twrp\" remote=\"github\" />" >> $FILE_LM
            else
                case $CONFIG_ANDROID in
                p)
                    echo "  <project name=\"Asus-MSM8916/android_device_asus_Z00xD\" path=\"device/asus/Z00xD\" revision=\"lineage-16.0\" remote=\"github\" />" >> $FILE_LM
                    echo "  <project name=\"Asus-MSM8916/android_device_asus_msm8916-common\" path=\"device/asus/msm8916-common\" revision=\"lineage-16.0\" remote=\"github\" />" >> $FILE_LM
                    echo "  <project name=\"Asus-MSM8916/android_kernel_asus_msm8916\" path=\"kernel/asus/msm8916\" revision=\"9.x-staging\" remote=\"github\" />" >> $FILE_LM
                    echo "  <project name=\"Asus-MSM8916/android_vendor_asus\" path=\"vendor/asus\" revision=\"9.x\" remote=\"github\" />" >> $FILE_LM
                    echo "  <project name=\"kdrag0n/aarch64-elf-gcc\" path=\"prebuilts/gcc/linux-x86/aarch64/aarch64-elf\" revision=\"9.x\" remote=\"github\" />" >> $FILE_LM
                    ;;
                q)
                    echo "  <project name=\"Asus-MSM8916/android_device_asus_Z00xD\" path=\"device/asus/Z00xD\" revision=\"lineage-17.1\" remote=\"github\" />" >> $FILE_LM
                    echo "  <project name=\"Asus-MSM8916/android_device_asus_msm8916-common\" path=\"device/asus/msm8916-common\" revision=\"lineage-17.1\" remote=\"github\" />" >> $FILE_LM
                    echo "  <project name=\"Asus-MSM8916/android_kernel_asus_msm8916\" path=\"kernel/asus/msm8916\" revision=\"10.x\" remote=\"github\" />" >> $FILE_LM
                    echo "  <project name=\"Asus-MSM8916/android_vendor_asus\" path=\"vendor/asus\" revision=\"lineage-17.1\" remote=\"github\" />" >> $FILE_LM
                    echo "  <project name=\"kdrag0n/aarch64-elf-gcc\" path=\"prebuilts/gcc/linux-x86/aarch64/aarch64-elf\" revision=\"9.x\" remote=\"github\" />" >> $FILE_LM
                    ;;
                *)
                    echo "Error: internal error"
                    echo ""
                    exit
                    ;;
                esac
            fi
            ;;
        *)
            echo $LANG_ERR_0002
            echo ""
            exit
            ;;
    esac
    echo "DEVICE=$CONFIG_DEVICE" >> $PATH_SETTINGS
}

function SetupOpenGapps {
    ClearLogo
    echo $LANG_0002
    echo ""
    CHOICE=default
    read -s -n 1 CHOICE
    if [ $CHOICE == y ]; then
        echo "  <!-- OpenGapps -->" >> $FILE_LM
        echo "  <remote name=\"opengapps\" fetch=\"https://github.com/opengapps/\" />" >> $FILE_LM
        echo "  <remote name=\"opengapps-gitlab\" fetch=\"https://gitlab.opengapps.org/opengapps/\" />" >> $FILE_LM
        echo "  <project path=\"vendor/opengapps/build\" name=\"aosp_build\" revision=\"master\" remote=\"opengapps\" />" >> $FILE_LM
        echo "  <project path=\"vendor/opengapps/sources/all\" name=\"all\" clone-depth=\"1\" revision=\"master\" remote=\"opengapps-gitlab\" />" >> $FILE_LM
        echo "  <!-- arm64 depends on arm -->" >> $FILE_LM
        echo "  <project path=\"vendor/opengapps/sources/arm\" name=\"arm\" clone-depth=\"1\" revision=\"master\" remote=\"opengapps-gitlab\" />" >> $FILE_LM
        echo "  <project path=\"vendor/opengapps/sources/arm64\" name=\"arm64\" clone-depth=\"1\" revision=\"master\" remote=\"opengapps-gitlab\" />" >> $FILE_LM
        echo "  <project path=\"vendor/opengapps/sources/x86\" name=\"x86\" clone-depth=\"1\" revision=\"master\" remote=\"opengapps-gitlab\" />" >> $FILE_LM
        echo "  <project path=\"vendor/opengapps/sources/x86_64\" name=\"x86_64\" clone-depth=\"1\" revision=\"master\" remote=\"opengapps-gitlab\" />" >> $FILE_LM
    fi
}

function SyncGapps {
    ClearLogo
    echo $LANG_0003
    echo "1/5"
    echo ""
    cd $PATH_PWD/vendor/opengapps/sources/all
    git lfs pull
    echo "2/5"
    echo ""
    cd $PATH_PWD/vendor/opengapps/sources/arm
    git lfs pull
    echo "3/5"
    echo ""
    cd $PATH_PWD/vendor/opengapps/sources/arm64
    git lfs pull
    echo "4/5"
    echo ""
    cd $PATH_PWD/vendor/opengapps/sources/x86
    git lfs pull
    echo "5/5"
    echo ""
    cd $PATH_PWD/vendor/opengapps/sources/x86_64
    git lfs pull
    cd $PATH_PWD/
}

function FixQcomCaf_p {
    ClearLogo
    sed -i "s/zd/ld/g" $VAR_LOCAL_PATH/hardware/qcom/display-caf/msm8916/libhdmi/hdmi.cpp
    sed -i "s/zd/ld/g" $VAR_LOCAL_PATH/hardware/qcom/display-caf/msm8916/libqdutils/idle_invalidator.cpp
    sed -i "s/zd/ld/g" $VAR_LOCAL_PATH/hardware/qcom/audio-caf/msm8916/hal/audio_hw.c
}

function FixQcomCaf_q {
    ClearLogo
    sed -i "s/zd/ld/g" $VAR_LOCAL_PATH/hardware/qcom-caf/msm8916/display/libhdmi/hdmi.cpp
    sed -i "s/zd/ld/g" $VAR_LOCAL_PATH/hardware/qcom-caf/msm8916/display/libqdutils/idle_invalidator.cpp
    sed -i "s/zd/ld/g" $VAR_LOCAL_PATH/hardware/qcom-caf/msm8916/audio/hal/audio_hw.c
}

function SyncAll {
    ClearLogo
    if [ ! -d $PATH_PWD/.repo/ ]; then
        echo $LANG_ERR_0003
    fi
    if [ ! -d $PATH_PWD/.repo/local_manifests/ ]; then
        echo $LANG_ERR_0004
    fi
    rm -rf $PATH_PWD/hardware/qcom/display-caf/msm8916/
    rm -rf $PATH_PWD/hardware/qcom/audio-caf/msm8916/
    rm -rf $PATH_PWD/hardware/qcom-caf/msm8916/display/
    rm -rf $PATH_PWD/hardware/qcom-caf/msm8916/audio/
    echo $LANG_0005
    echo ""
    echo $LANG_0006
    echo $LANG_0007
    echo $LANG_0008
    echo ""
    CHOICE=default
    read -s -n 1 CHOICE
    case $CHOICE in
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
            echo $LANG_ERR_0005
            echo ""
            exit
            ;;
    esac
    if [ ! -d $PATH_PWD/device/ ]; then
        echo $LANG_ERR_0006
        echo ""
        exit
    fi
}

function BuildAndroid {
    ClearLogo
    . build/envsetup.sh
    export LC_ALL=C
    export WITHOUT_CHECK_API=true
    make installclean -j $(nproc)
    lunch -j $(nproc)
    brunch $TARGET_PRODUCT-$TARGET_BUILD_VARIANT -j $(nproc)
}

function LoadSettings {
    ClearLogo
    CONFIG_LANG=$(cat $PATH_SETTINGS | grep LANG)
    CONFIG_LANG=${CONFIG_LANG:5}
    LoadLang$CONFIG_LANG
    CONFIG_ANDROID=$(cat $PATH_SETTINGS | grep ANDROID)
    CONFIG_ANDROID=${CONFIG_ANDROID:8}
    CONFIG_RECOVERY=$(cat $PATH_SETTINGS | grep RECOVERY)
    CONFIG_RECOVERY=${CONFIG_RECOVERY:9}
    CONFIG_DEVICE=$(cat $PATH_SETTINGS | grep DEVICE)
    CONFIG_DEVICE=${CONFIG_DEVICE:7}
    echo "LANGUAGE $CONFIG_LANG"
    echo "ANDROID $CONFIG_ANDROID"
    echo "RECOVERY $CONFIG_RECOVERY"
    echo "DEVICE $CONFIG_DEVICE"
}

if [ -f $PATH_SETTINGS ]; then
    ClearLogo
    echo "Would you like to (l)oad settings file or to (r)emove it?"
    echo ""
    CHOICE=default
    read -s -n 1 CHOICE
    case $CHOICE in
        l)
            cd $PATH_PWD
            LoadSettings
            ;;
        r)
            rm -rf $PATH_PWD
            echo "Done"
            echo ""
            exit
            ;;
        *)
            echo "Error: no such action"
            echo ""
            exit
            ;;
    esac
else
    rm -rf $PATH_PWD
    mkdir -p $PATH_PWD
    cd $PATH_PWD
    touch $PATH_SETTINGS

    SetupLanguage
    SetupPackages
    SetupAndroid
    SetupDevice
    if [ $CONFIG_RECOVERY == n ]; then
        SetupOpenGapps
    fi
    echo "</manifest>" >> $FILE_LM
fi

if [ -d $PATH_PWD/device/ ]; then
    ClearLogo
    echo $LANG_0004
    echo ""
    CHOICE=default
    read -s -n 1 CHOICE
    if [ $CHOICE == y ]; then
        SyncAll
        FixQcomCaf_$CONFIG_ANDROID
        if [ -d $PATH_PWD/vendor/opengapps/ ]; then
            SyncGapps
        fi
        if [ $CONFIG_RECOVERY == n ]; then
            sed -i "s/https:\/\/download.lineageos.org\/api\/v1\/{device}\/{type}\/{incr}/https:\/\/raw.githubusercontent.com\/$VAR_JSON_REPO\/lineage_OTA\/master\/{device}_$CONFIG_ANDROID_VERSION.json/" $VAR_LOCAL_PATH/packages/apps/Updater/res/values/strings.xml
        fi
    fi
else
    SyncAll
    FixQcomCaf_$CONFIG_ANDROID
    if [ -d $PATH_PWD/vendor/opengapps/ ]; then
        SyncGapps
    fi
    if [ $CONFIG_RECOVERY == n ]; then
        sed -i "s/https:\/\/download.lineageos.org\/api\/v1\/{device}\/{type}\/{incr}/https:\/\/raw.githubusercontent.com\/$VAR_JSON_REPO\/lineage_OTA\/master\/{device}_$CONFIG_ANDROID_VERSION.json/" $VAR_LOCAL_PATH/packages/apps/Updater/res/values/strings.xml
    fi
fi

echo $LANG_0009
echo ""
CHOICE=n
read -s -n 1 CHOICE
if [ $CHOICE == y ]; then
    BuildAndroid
fi
