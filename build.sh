#!/bin/bash

# ================= COLOR =================
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
white='\033[0m'

# ================= PATH =================
DEFCONFIG=msm8937-perf_defconfig
ROOTDIR=$(pwd)
OUTDIR="$ROOTDIR/out/arch/arm64/boot"
ANYKERNEL_DIR="$ROOTDIR/AnyKernel"
KIMG_DTB="$OUTDIR/Image.gz-dtb"
KIMG="$OUTDIR/Image.gz"

# ========== TOOLCHAIN (AZURE CLANG) ===========
export PATH="$ROOTDIR/azure-clang/bin:$PATH"

# ================= INFO =================
KERNEL_NAME="ReLIFE"
DEVICE="Mi8937"

DATE_TITLE=$(TZ=Asia/Jakarta date +"%d%m%Y")
TIME_TITLE=$(TZ=Asia/Jakarta date +"%H%M%S")
BUILD_DATETIME=$(TZ=Asia/Jakarta date +"%d %B %Y")

BUILD_TIME="unknown"
KERNEL_VERSION="unknown"
TC_INFO="unknown"
IMG_USED="unknown"
MD5_HASH="unknown"
ZIP_NAME=""

clone_anykernel() {
    if [ ! -d "$ANYKERNEL_DIR" ]; then
        echo -e "$yellow[+] Cloning AnyKernel3...$white"
        git clone https://github.com/rahmatsobrian/AnyKernel3.git "$ANYKERNEL_DIR" || exit 1
    fi
}

get_toolchain_info() {
    if command -v clang >/dev/null 2>&1; then
        TC_INFO=$(clang --version | head -n1)
    else
        TC_INFO="unknown"
    fi
}

get_kernel_version() {
    VERSION=$(grep -E '^VERSION =' Makefile | awk '{print $3}')
    PATCHLEVEL=$(grep -E '^PATCHLEVEL =' Makefile | awk '{print $3}')
    SUBLEVEL=$(grep -E '^SUBLEVEL =' Makefile | awk '{print $3}')
    KERNEL_VERSION="${VERSION}.${PATCHLEVEL}.${SUBLEVEL}"
}

build_kernel() {

    echo -e "$yellow[+] Cleaning out...$white"
    rm -rf out
    mkdir -p out

    echo -e "$yellow[+] Toolchain info...$white"
    get_toolchain_info

    echo -e "$yellow[+] Preparing defconfig...$white"
    make O=out ARCH=arm64 ${DEFCONFIG} || exit 1

    # 🔥 Override LOCALVERSION secara aman
    export LOCALVERSION="-ReLIFE"

    BUILD_START=$(date +%s)

    echo -e "$yellow[+] Building kernel...$white"
    make -j$(nproc --all) \
      O=out \
      ARCH=arm64 \
      CC=clang \
      LD=ld.lld \
      LLVM=1 \
      LLVM_IAS=1 \
      CROSS_COMPILE=aarch64-linux-gnu- \
      CROSS_COMPILE_ARM32=arm-linux-gnueabi- || exit 1

    BUILD_END=$(date +%s)
    DIFF=$((BUILD_END - BUILD_START))
    BUILD_TIME="$((DIFF / 60)) min $((DIFF % 60)) sec"

    get_kernel_version

    ZIP_NAME="${KERNEL_NAME}-${DEVICE}-${KERNEL_VERSION}-${DATE_TITLE}-${TIME_TITLE}.zip"
}

pack_kernel() {
    clone_anykernel
    cd "$ANYKERNEL_DIR" || exit 1

    rm -f Image* *.zip

    if [ -f "$KIMG_DTB" ]; then
        cp "$KIMG_DTB" Image.gz-dtb
        IMG_USED="Image.gz-dtb"
    elif [ -f "$KIMG" ]; then
        cp "$KIMG" Image.gz
        IMG_USED="Image.gz"
    else
        echo -e "$red[!] Kernel image not found$white"
        exit 1
    fi

    zip -r9 "$ZIP_NAME" . -x ".git*" "README.md"
    MD5_HASH=$(md5sum "$ZIP_NAME" | awk '{print $1}')

    echo -e "$green[✓] Zip created: $ZIP_NAME$white"
}

build_kernel
pack_kernel
