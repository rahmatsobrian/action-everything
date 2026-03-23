#!/bin/bash

# ================= TELEGRAM =================
TG_BOT_TOKEN="7443002324:AAFpDcG3_9L0Jhy4v98RCBqu2pGfznBCiDM"
TG_CHAT_ID="-1003520316735"

# ================= COLLECT SPEC =================

# OS Info
OS_NAME=$(grep -oP '(?<=PRETTY_NAME=").*(?=")' /etc/os-release 2>/dev/null || uname -s)
KERNEL_VER=$(uname -r)
ARCH=$(uname -m)

# CPU
CPU_MODEL=$(grep -m1 'model name' /proc/cpuinfo | cut -d: -f2 | xargs)
CPU_CORES=$(nproc)
CPU_THREADS=$(grep -c '^processor' /proc/cpuinfo)
CPU_MHZ=$(grep -m1 'cpu MHz' /proc/cpuinfo | cut -d: -f2 | xargs | cut -d. -f1)

# RAM
RAM_TOTAL=$(awk '/MemTotal/ {printf "%.0f MB", $2/1024}' /proc/meminfo)
RAM_FREE=$(awk '/MemAvailable/ {printf "%.0f MB", $2/1024}' /proc/meminfo)

# Disk
DISK_TOTAL=$(df -h / | awk 'NR==2 {print $2}')
DISK_USED=$(df -h / | awk 'NR==2 {print $3}')
DISK_FREE=$(df -h / | awk 'NR==2 {print $4}')

# Network
PUBLIC_IP=$(curl -sf --max-time 5 https://api.ipify.org || echo "N/A")
HOSTNAME=$(hostname)

# Runner Identity
RUNNER_NAME="${RUNNER_NAME:-N/A}"
RUNNER_OS="${RUNNER_OS:-N/A}"
RUNNER_ARCH="${RUNNER_ARCH:-N/A}"
GITHUB_ACTIONS="${GITHUB_ACTIONS:-false}"
GITHUB_WORKFLOW="${GITHUB_WORKFLOW:-N/A}"
GITHUB_RUN_ID="${GITHUB_RUN_ID:-N/A}"
GITHUB_ACTOR="${GITHUB_ACTOR:-N/A}"
GITHUB_REPOSITORY="${GITHUB_REPOSITORY:-N/A}"

# Timestamp WIB
TIMESTAMP=$(TZ=Asia/Jakarta date +"%d %B %Y, %H:%M:%S WIB")

# ================= BUILD MESSAGE (HTML) =================
MESSAGE="🖥 <b>GitHub Actions Runner Spec</b>

🕒 <b>Time</b> : ${TIMESTAMP}

<pre>[ OS &amp; Kernel ]
OS      : ${OS_NAME}
Kernel  : ${KERNEL_VER}
Arch    : ${ARCH}

[ CPU ]
Model   : ${CPU_MODEL}
Cores   : ${CPU_CORES} cores / ${CPU_THREADS} threads
Speed   : ${CPU_MHZ} MHz

[ Memory ]
Total   : ${RAM_TOTAL}
Free    : ${RAM_FREE}

[ Disk (/) ]
Total   : ${DISK_TOTAL}
Used    : ${DISK_USED}
Free    : ${DISK_FREE}

[ Network ]
Hostname  : ${HOSTNAME}
Public IP : ${PUBLIC_IP}

[ Runner Info ]
Runner Name : ${RUNNER_NAME}
Runner OS   : ${RUNNER_OS}
Runner Arch : ${RUNNER_ARCH}
GH Actions  : ${GITHUB_ACTIONS}
Workflow    : ${GITHUB_WORKFLOW}
Run ID      : ${GITHUB_RUN_ID}
Actor       : ${GITHUB_ACTOR}
Repository  : ${GITHUB_REPOSITORY}</pre>"

# ================= SEND TO TELEGRAM =================
curl -s -X POST "https://api.telegram.org/bot${TG_BOT_TOKEN}/sendMessage" \
    --data-urlencode "chat_id=${TG_CHAT_ID}" \
    --data-urlencode "parse_mode=HTML" \
    --data-urlencode "text=${MESSAGE}"

echo "[✓] Spec sent to Telegram."
