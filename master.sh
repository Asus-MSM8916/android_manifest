#!/bin/bash

PATHMASTER_PWD=$(pwd)/master_pwd
PATHMASTER_SETTINGS=$PATHMASTER_PWD/mdata
PATHMASTER_OUT=default

FILEMASTER_LM=$PATHMASTER_PWD/.repo/local_manifests/local_manifest.xml

REPOMASTER_JSON=default
CONFIGMASTER_JSON_DATETIME=default
CONFIGMASTER_JSON_FILENAME=default
CONFIGMASTER_JSON_ID=default
CONFIGMASTER_JSON_TYPE=default
CONFIGMASTER_JSON_REL=default
CONFIGMASTER_JSON_URL=default
CONFIGMASTER_JSON_JSON=default

CONFIGMASTER_LANG=default
CONFIGMASTER_ANDROID=default
CONFIGMASTER_RECOVERY=default
CONFIGMASTER_DEVICE=default

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
    LANGMASTER_ERR_0000="Warning: your system does not support apt. You need to install build packages manually. Press any key to continue..."
    LANGMASTER_ERR_0001="Error: no such ROM"
    LANGMASTER_ERR_0002="Error: no such device"
    LANGMASTER_ERR_0003="Error: no ROM manifest"
    LANGMASTER_ERR_0004="Error: no device manifest"
    LANGMASTER_ERR_0005="Error: no such sync type"
    LANGMASTER_ERR_0006="Error: sync failed"
    LANGMASTER_ERR_0007="Error: build failed"
    LANGMASTER_0000="Choose ROM"
    LANGMASTER_0001="Choose device"
    LANGMASTER_0002="Add OpenGapps (y)?"
    LANGMASTER_0003="Syncing OpenGapps"
    LANGMASTER_0004="Update sources (y)?"
    LANGMASTER_0005="Choose sync type"
    LANGMASTER_0006="1 - Fast"
    LANGMASTER_0007="2 - Slow"
    LANGMASTER_0008="3 - Forced"
    LANGMASTER_0009="Build android (y)?"
    LANGMASTER_0010="Install build packages (y)?"
    LANGMASTER_0011="Create release (y)?"
    LANGMASTER_0012="Use this number for release: "
}

function LoadLangRU {
    LANGMASTER_ERR_0000="Внимание: Ваша система не поддерживает apt. Вам придётся установить сборочные пакеты вручную. Нажмите любую клавишу для продолжения..."
    LANGMASTER_ERR_0001="Ошибка: такой прошивки нет"
    LANGMASTER_ERR_0002="Ошибка: такого устройства нет"
    LANGMASTER_ERR_0003="Ошибка: прошивка не проинициализирована"
    LANGMASTER_ERR_0004="Ошибка: устройство не проинициализировано"
    LANGMASTER_ERR_0005="Ошибка: нет такого типа синхронизации"
    LANGMASTER_ERR_0006="Ошибка: синхронизация не удалась"
    LANGMASTER_ERR_0007="Ошибка: сборка не удалась"
    LANGMASTER_0000="Выберите прошивку"
    LANGMASTER_0001="Выберите устройство"
    LANGMASTER_0002="Добавить OpenGapps (y)?"
    LANGMASTER_0003="Синхронизация OpenGapps"
    LANGMASTER_0004="Обновить исходный код (y)?"
    LANGMASTER_0005="Выберите тип синхронизации"
    LANGMASTER_0006="1 - Быстрая"
    LANGMASTER_0007="2 - Медленная"
    LANGMASTER_0008="3 - Принудительная"
    LANGMASTER_0009="Собрать Android (y)?"
    LANGMASTER_0010="Установить сборочные пакеты (y)?"
    LANGMASTER_0011="Опубликовать релиз (y)?"
    LANGMASTER_0012="Используйте этот номер при релизе: "
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
            CONFIGMASTER_LANG=EN
            ;;
        1)
            CONFIGMASTER_LANG=RU
            ;;
        *)
            echo "Error: no such language"
            echo ""
            exit
            ;;
    esac
    echo "LANG=$CONFIGMASTER_LANG" >> $PATHMASTER_SETTINGS
    LoadLang$CONFIGMASTER_LANG
}

function SetupPackages {
    ClearLogo
    if [ -f /bin/apt ]; then
        echo $LANGMASTER_0010
        echo ""
        CHOICE=default
        read -s -n 1 CHOICE
        if [ $CHOICE == y ]; then
            sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get install -y git-core gnupg flex bison gperf build-essential zip curl zlib1g-dev gcc-multilib g++-multilib libc6-dev-i386 lib32ncurses5-dev x11proto-core-dev libx11-dev lib32z-dev libgl1-mesa-dev libxml2-utils xsltproc unzip git imagemagick openjdk-8-jdk python maven git-lfs meld ghex libssl-dev libncurses5 && sudo apt-get autoremove -y
            curl https://storage.googleapis.com/git-repo-downloads/repo > repo
            chmod a+x repo
            sudo mv repo /bin/repo
        fi
    else
        echo $LANGMASTER_ERR_0000
        echo ""
        read -s -n 1 NULL
    fi
}

function SetupAndroid {
    ClearLogo
    echo $LANGMASTER_0000
    echo ""
    echo "1 - TWRP"
    echo "2 - LineageOS 16.0"
    echo "3 - LineageOS 17.1"
    echo ""
    CHOICE=default
    read -s -n 1 CHOICE
    case $CHOICE in
        1)
            CONFIGMASTER_ANDROID=p
            CONFIGMASTER_NUM=16.0
            CONFIGMASTER_RECOVERY=y
            repo init --depth=1 -u git://github.com/minimal-manifest-twrp/platform_manifest_twrp_omni.git -b twrp-9.0
            ;;
        2)
            CONFIGMASTER_ANDROID=p
            CONFIGMASTER_NUM=16.0
            CONFIGMASTER_RECOVERY=n
            repo init --depth=1 -u git://github.com/LineageOS/android.git -b lineage-16.0
            ;;
        3)
            CONFIGMASTER_ANDROID=q
            CONFIGMASTER_NUM=17.1
            CONFIGMASTER_RECOVERY=n
            repo init --depth=1 -u git://github.com/LineageOS/android.git -b lineage-17.1
            ;;
        *)
            echo $LANGMASTER_ERR_0001
            echo ""
            exit
            ;;
    esac
    echo "ANDROID=$CONFIGMASTER_ANDROID" >> $PATHMASTER_SETTINGS
    echo "RECOVERY=$CONFIGMASTER_RECOVERY" >> $PATHMASTER_SETTINGS
    echo "NUM=$CONFIGMASTER_NUM" >> $PATHMASTER_SETTINGS
}

function SetupDevice {
    ClearLogo
    mkdir -p $PATHMASTER_PWD/.repo/local_manifests/
    touch $FILEMASTER_LM
    echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" >> $FILEMASTER_LM
    echo "<manifest>" >> $FILEMASTER_LM
    echo $LANGMASTER_0001
    echo ""
    echo "1 - Z00xD"
    echo ""
    CHOICE=default
    read -s -n 1 CHOICE
    case $CHOICE in
        1)
            CONFIGMASTER_DEVICE=Z00xD
            REPOMASTER_JSON=Asus-MSM8916
            echo "  <!-- ASUS ZenFone 2 Laser ZE500KL ZE500KG -->" >> $FILEMASTER_LM
            if [ $CONFIGMASTER_RECOVERY == y ]; then
                echo "  <project name=\"Asus-MSM8916/android_device_asus_Z00xD-twrp\" path=\"device/asus/Z00xD\" revision=\"9.x-twrp\" remote=\"github\" />" >> $FILEMASTER_LM
            else
                case $CONFIGMASTER_ANDROID in
                p)
                    echo "  <project name=\"Asus-MSM8916/android_device_asus_Z00xD\" path=\"device/asus/Z00xD\" revision=\"lineage-16.0\" remote=\"github\" />" >> $FILEMASTER_LM
                    echo "  <project name=\"Asus-MSM8916/android_device_asus_msm8916-common\" path=\"device/asus/msm8916-common\" revision=\"lineage-16.0\" remote=\"github\" />" >> $FILEMASTER_LM
                    echo "  <project name=\"Asus-MSM8916/android_kernel_asus_msm8916\" path=\"kernel/asus/msm8916\" revision=\"9.x-staging\" remote=\"github\" />" >> $FILEMASTER_LM
                    echo "  <project name=\"Asus-MSM8916/android_vendor_asus\" path=\"vendor/asus\" revision=\"9.x\" remote=\"github\" />" >> $FILEMASTER_LM
                    echo "  <project name=\"kdrag0n/aarch64-elf-gcc\" path=\"prebuilts/gcc/linux-x86/aarch64/aarch64-elf\" revision=\"9.x\" remote=\"github\" />" >> $FILEMASTER_LM
                    ;;
                q)
                    echo "  <project name=\"Asus-MSM8916/android_device_asus_Z00xD\" path=\"device/asus/Z00xD\" revision=\"lineage-17.1\" remote=\"github\" />" >> $FILEMASTER_LM
                    echo "  <project name=\"Asus-MSM8916/android_device_asus_msm8916-common\" path=\"device/asus/msm8916-common\" revision=\"lineage-17.1\" remote=\"github\" />" >> $FILEMASTER_LM
                    echo "  <project name=\"Asus-MSM8916/android_kernel_asus_msm8916\" path=\"kernel/asus/msm8916\" revision=\"10.x\" remote=\"github\" />" >> $FILEMASTER_LM
                    echo "  <project name=\"Asus-MSM8916/android_vendor_asus\" path=\"vendor/asus\" revision=\"lineage-17.1\" remote=\"github\" />" >> $FILEMASTER_LM
                    echo "  <project name=\"kdrag0n/aarch64-elf-gcc\" path=\"prebuilts/gcc/linux-x86/aarch64/aarch64-elf\" revision=\"9.x\" remote=\"github\" />" >> $FILEMASTER_LM
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
            echo $LANGMASTER_ERR_0002
            echo ""
            exit
            ;;
    esac
    echo "DEVICE=$CONFIGMASTER_DEVICE" >> $PATHMASTER_SETTINGS
    echo "REPO=$REPOMASTER_JSON" >> $PATHMASTER_SETTINGS
}

function SetupOpenGapps {
    ClearLogo
    echo $LANGMASTER_0002
    echo ""
    CHOICE=default
    read -s -n 1 CHOICE
    if [ $CHOICE == y ]; then
        echo "  <!-- OpenGapps -->" >> $FILEMASTER_LM
        echo "  <remote name=\"opengapps\" fetch=\"https://github.com/opengapps/\" />" >> $FILEMASTER_LM
        echo "  <remote name=\"opengapps-gitlab\" fetch=\"https://gitlab.opengapps.org/opengapps/\" />" >> $FILEMASTER_LM
        echo "  <project path=\"vendor/opengapps/build\" name=\"aosp_build\" revision=\"master\" remote=\"opengapps\" />" >> $FILEMASTER_LM
        echo "  <project path=\"vendor/opengapps/sources/all\" name=\"all\" clone-depth=\"1\" revision=\"master\" remote=\"opengapps-gitlab\" />" >> $FILEMASTER_LM
        echo "  <!-- arm64 depends on arm -->" >> $FILEMASTER_LM
        echo "  <project path=\"vendor/opengapps/sources/arm\" name=\"arm\" clone-depth=\"1\" revision=\"master\" remote=\"opengapps-gitlab\" />" >> $FILEMASTER_LM
        echo "  <project path=\"vendor/opengapps/sources/arm64\" name=\"arm64\" clone-depth=\"1\" revision=\"master\" remote=\"opengapps-gitlab\" />" >> $FILEMASTER_LM
        echo "  <project path=\"vendor/opengapps/sources/x86\" name=\"x86\" clone-depth=\"1\" revision=\"master\" remote=\"opengapps-gitlab\" />" >> $FILEMASTER_LM
        echo "  <project path=\"vendor/opengapps/sources/x86_64\" name=\"x86_64\" clone-depth=\"1\" revision=\"master\" remote=\"opengapps-gitlab\" />" >> $FILEMASTER_LM
    fi
}

function SyncGapps {
    ClearLogo
    echo $LANGMASTER_0003
    echo "1/5"
    echo ""
    cd $PATHMASTER_PWD/vendor/opengapps/sources/all
    git lfs pull
    echo "2/5"
    echo ""
    cd $PATHMASTER_PWD/vendor/opengapps/sources/arm
    git lfs pull
    echo "3/5"
    echo ""
    cd $PATHMASTER_PWD/vendor/opengapps/sources/arm64
    git lfs pull
    echo "4/5"
    echo ""
    cd $PATHMASTER_PWD/vendor/opengapps/sources/x86
    git lfs pull
    echo "5/5"
    echo ""
    cd $PATHMASTER_PWD/vendor/opengapps/sources/x86_64
    git lfs pull
    cd $PATHMASTER_PWD/
}

function FixQcomCaf_p {
    ClearLogo
    sed -i "s/zd/ld/g" $PATHMASTER_PWD/hardware/qcom/display-caf/msm8916/libhdmi/hdmi.cpp
    sed -i "s/zd/ld/g" $PATHMASTER_PWD/hardware/qcom/display-caf/msm8916/libqdutils/idle_invalidator.cpp
    sed -i "s/zd/ld/g" $PATHMASTER_PWD/hardware/qcom/audio-caf/msm8916/hal/audio_hw.c
}

function FixQcomCaf_q {
    ClearLogo
    sed -i "s/zd/ld/g" $PATHMASTER_PWD/hardware/qcom-caf/msm8916/display/libhdmi/hdmi.cpp
    sed -i "s/zd/ld/g" $PATHMASTER_PWD/hardware/qcom-caf/msm8916/display/libqdutils/idle_invalidator.cpp
    sed -i "s/zd/ld/g" $PATHMASTER_PWD/hardware/qcom-caf/msm8916/audio/hal/audio_hw.c
}

function SyncAll {
    ClearLogo
    if [ ! -d $PATHMASTER_PWD/.repo/ ]; then
        echo $LANGMASTER_ERR_0003
    fi
    if [ ! -d $PATHMASTER_PWD/.repo/local_manifests/ ]; then
        echo $LANGMASTER_ERR_0004
    fi
    rm -rf $PATHMASTER_PWD/hardware/qcom/display-caf/msm8916/
    rm -rf $PATHMASTER_PWD/hardware/qcom/audio-caf/msm8916/
    rm -rf $PATHMASTER_PWD/hardware/qcom-caf/msm8916/display/
    rm -rf $PATHMASTER_PWD/hardware/qcom-caf/msm8916/audio/
    rm -rf $PATHMASTER_PWD/packages/apps/Updater/
    echo $LANGMASTER_0005
    echo ""
    echo $LANGMASTER_0006
    echo $LANGMASTER_0007
    echo $LANGMASTER_0008
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
            echo $LANGMASTER_ERR_0005
            echo ""
            exit
            ;;
    esac
    if [ ! -d $PATHMASTER_PWD/device/ ]; then
        echo $LANGMASTER_ERR_0006
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
    lunch
    brunch $TARGET_PRODUCT-$TARGET_BUILD_VARIANT -j $(nproc)
}

function CreateRelease {
    cd $PATHMASTER_OUT
    git clone https://github.com/$REPOMASTER_JSON/lineage_OTA $PATHMASTER_OUT/masterotadir
    CONFIGMASTER_JSON_DATETIME=$(cat $PATHMASTER_OUT/system/build.prop | grep ro.build.date.utc=)
    CONFIGMASTER_JSON_DATETIME=${CONFIGMASTER_JSON_DATETIME:18}
    CONFIGMASTER_JSON_FILENAME=$(ls $PATHMASTER_OUT/ | grep lineage-*$CONFIGMASTER_DEVICE.zip | grep -v md5sum)
    CONFIGMASTER_JSON_ID=$(md5sum $PATHMASTER_OUT/$CONFIGMASTER_JSON_FILENAME)
    CONFIGMASTER_JSON_ID=${CONFIGMASTER_JSON_ID%% *}
    if [ "$(ls | grep UNOFFICIAL)" == "" ]; then
        CONFIGMASTER_JSON_TYPE=OFFICIAL
    else
        CONFIGMASTER_JSON_TYPE=UNOFFICIAL
    fi
    CONFIGMASTER_JSON_SIZE=$(stat -c%s $PATHMASTER_OUT/$CONFIGMASTER_JSON_FILENAME)
    CONFIGMASTER_JSON_REL=$(cat $PATHMASTER_OUT/masterotadir/masterdata | grep "$CONFIGMASTER_DEVICE"_$CONFIGMASTER_ANDROID)
    CONFIGMASTER_JSON_REL=${CONFIGMASTER_JSON_REL:$((${#CONFIGMASTER_DEVICE}+3))}
    sed -i "s/"$CONFIGMASTER_DEVICE"_$CONFIGMASTER_ANDROID-$CONFIGMASTER_JSON_REL/"$CONFIGMASTER_DEVICE"_$CONFIGMASTER_ANDROID-$(($CONFIGMASTER_JSON_REL+1))/" $PATHMASTER_OUT/masterotadir/masterdata
    CONFIGMASTER_JSON_URL="https://github.com/$REPOMASTER_JSON/lineage_OTA/releases/download/"$CONFIGMASTER_NUM"_$(($CONFIGMASTER_JSON_REL+1))/$CONFIGMASTER_JSON_FILENAME"
    CONFIGMASTER_JSON_JSON=$PATHMASTER_OUT/masterotadir/"$CONFIGMASTER_DEVICE"_$CONFIGMASTER_ANDROID.json
    rm -rf $CONFIGMASTER_JSON_JSON
    touch $CONFIGMASTER_JSON_JSON
    echo "{" >> $CONFIGMASTER_JSON_JSON
    echo "  \"response\": [" >> $CONFIGMASTER_JSON_JSON
    echo "    {" >> $CONFIGMASTER_JSON_JSON
    echo "      \"datetime\": $CONFIGMASTER_JSON_DATETIME," >> $CONFIGMASTER_JSON_JSON
    echo "      \"filename\": \"$CONFIGMASTER_JSON_FILENAME\"," >> $CONFIGMASTER_JSON_JSON
    echo "      \"id\": \"$CONFIGMASTER_JSON_ID\"," >> $CONFIGMASTER_JSON_JSON
    echo "      \"romtype\": \"$CONFIGMASTER_JSON_TYPE\"," >> $CONFIGMASTER_JSON_JSON
    echo "      \"size\": $CONFIGMASTER_JSON_SIZE," >> $CONFIGMASTER_JSON_JSON
    echo "      \"url\": \"$CONFIGMASTER_JSON_URL\"," >> $CONFIGMASTER_JSON_JSON
    echo "      \"version\": \"$CONFIGMASTER_NUM\"" >> $CONFIGMASTER_JSON_JSON
    echo "    }" >> $CONFIGMASTER_JSON_JSON
    echo "  ]" >> $CONFIGMASTER_JSON_JSON
    echo "}" >> $CONFIGMASTER_JSON_JSON
    cd $PATHMASTER_OUT/masterotadir
    git add $CONFIGMASTER_JSON_JSON
    git commit -m "[MASTERSCRIPT] New release for $CONFIGMASTER_DEVICE android $CONFIGMASTER_NUM version $(($CONFIGMASTER_JSON_REL+1))"
    git push
    rm -rf $PATHMASTER_OUT/masterotadir/
    echo $LANGMASTER_0012
    echo "$CONFIGMASTER_NUM"_$(($CONFIGMASTER_JSON_REL+1))
    echo ""
    cd $PATHMASTER_PWD
}

function LoadSettings {
    ClearLogo
    CONFIGMASTER_LANG=$(cat $PATHMASTER_SETTINGS | grep LANG)
    CONFIGMASTER_LANG=${CONFIGMASTER_LANG:5}
    LoadLang$CONFIGMASTER_LANG
    CONFIGMASTER_ANDROID=$(cat $PATHMASTER_SETTINGS | grep ANDROID)
    CONFIGMASTER_ANDROID=${CONFIGMASTER_ANDROID:8}
    CONFIGMASTER_NUM=$(cat $PATHMASTER_SETTINGS | grep NUM)
    CONFIGMASTER_NUM=${CONFIGMASTER_NUM:4}
    CONFIGMASTER_RECOVERY=$(cat $PATHMASTER_SETTINGS | grep RECOVERY)
    CONFIGMASTER_RECOVERY=${CONFIGMASTER_RECOVERY:9}
    CONFIGMASTER_DEVICE=$(cat $PATHMASTER_SETTINGS | grep DEVICE)
    CONFIGMASTER_DEVICE=${CONFIGMASTER_DEVICE:7}
    REPOMASTER_JSON=$(cat $PATHMASTER_SETTINGS | grep REPO)
    REPOMASTER_JSON=${REPOMASTER_JSON:5}
    echo "LANGUAGE $CONFIGMASTER_LANG"
    echo "ANDROID $CONFIGMASTER_ANDROID"
    echo "NUM $CONFIGMASTER_NUM"
    echo "RECOVERY $CONFIGMASTER_RECOVERY"
    echo "DEVICE $CONFIGMASTER_DEVICE"
    echo "REPO $REPOMASTER_JSON"
}

if [ -f $PATHMASTER_SETTINGS ]; then
    ClearLogo
    echo "Would you like to (l)oad settings file or to (r)emove it?"
    echo ""
    CHOICE=default
    read -s -n 1 CHOICE
    case $CHOICE in
        l)
            cd $PATHMASTER_PWD
            LoadSettings
            ;;
        r)
            rm -rf $PATHMASTER_PWD
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
    rm -rf $PATHMASTER_PWD
    mkdir -p $PATHMASTER_PWD
    cd $PATHMASTER_PWD
    touch $PATHMASTER_SETTINGS

    SetupLanguage
    SetupPackages
    SetupAndroid
    SetupDevice
    if [ $CONFIGMASTER_RECOVERY == n ]; then
        SetupOpenGapps
    fi
    echo "</manifest>" >> $FILEMASTER_LM
fi

if [ -d $PATHMASTER_PWD/device/ ]; then
    ClearLogo
    echo $LANGMASTER_0004
    echo ""
    CHOICE=default
    read -s -n 1 CHOICE
    if [ $CHOICE == y ]; then
        SyncAll
        FixQcomCaf_$CONFIGMASTER_ANDROID
        if [ -d $PATHMASTER_PWD/vendor/opengapps/ ]; then
            SyncGapps
        fi
        if [ $CONFIGMASTER_RECOVERY == n ]; then
            sed -i "s/https:\/\/download.lineageos.org\/api\/v1\/{device}\/{type}\/{incr}/https:\/\/raw.githubusercontent.com\/$REPOMASTER_JSON\/lineage_OTA\/master\/{device}_$CONFIGMASTER_ANDROID.json/" $PATHMASTER_PWD/packages/apps/Updater/res/values/strings.xml
        fi
    fi
else
    SyncAll
    FixQcomCaf_$CONFIGMASTER_ANDROID
    if [ -d $PATHMASTER_PWD/vendor/opengapps/ ]; then
        SyncGapps
    fi
    if [ $CONFIGMASTER_RECOVERY == n ]; then
        sed -i "s/https:\/\/download.lineageos.org\/api\/v1\/{device}\/{type}\/{incr}/https:\/\/raw.githubusercontent.com\/$REPOMASTER_JSON\/lineage_OTA\/master\/{device}_$CONFIGMASTER_ANDROID.json/" $PATHMASTER_PWD/packages/apps/Updater/res/values/strings.xml
    fi
fi

echo $LANGMASTER_0009
echo ""
CHOICE=n
read -s -n 1 CHOICE
if [ $CHOICE == y ]; then
    BuildAndroid
fi

ClearLogo
PATHMASTER_OUT=$PATHMASTER_PWD/out/target/product/$CONFIGMASTER_DEVICE
if [ -f $PATHMASTER_OUT/lineage-*$CONFIGMASTER_DEVICE.zip ]; then
    echo $LANGMASTER_0011
    echo ""
    CHOICE=n
    read -s -n 1 CHOICE
    if [ $CHOICE == y ]; then
        CreateRelease
    fi
else
    echo $LANGMASTER_ERR_0007
    ""
    exit
fi
