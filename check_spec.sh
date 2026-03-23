#!/bin/bash

# ================= TELEGRAM =================
TG_BOT_TOKEN="7443002324:AAFpDcG3_9L0Jhy4v98RCBqu2pGfznBCiDM"
TG_CHAT_ID="-1003520316735"

# ================= OS & KERNEL =================
OS_NAME=$(grep -oP '(?<=PRETTY_NAME=").*(?=")' /etc/os-release 2>/dev/null || uname -s)
KERNEL_VER=$(uname -r)
ARCH=$(uname -m)
UPTIME=$(uptime -p 2>/dev/null || uptime)
LOAD_AVG=$(awk '{print $1", "$2", "$3}' /proc/loadavg)
TIMESTAMP=$(TZ=Asia/Jakarta date +"%d %B %Y, %H:%M:%S WIB")

# ================= CPU =================
CPU_MODEL=$(grep -m1 'model name' /proc/cpuinfo | cut -d: -f2 | xargs)
CPU_CORES=$(nproc)
CPU_THREADS=$(grep -c '^processor' /proc/cpuinfo)
CPU_MHZ=$(grep -m1 'cpu MHz' /proc/cpuinfo | cut -d: -f2 | xargs | cut -d. -f1)
CPU_CACHE=$(grep -m1 'cache size' /proc/cpuinfo | cut -d: -f2 | xargs)
CPU_VIRT=$(grep -oE 'vmx|svm' /proc/cpuinfo | head -1 | sed 's/vmx/Intel VT-x/;s/svm/AMD-V/')
[ -z "$CPU_VIRT" ] && CPU_VIRT="Not supported"

# ================= MEMORY =================
RAM_TOTAL=$(awk '/MemTotal/ {printf "%.0f MB", $2/1024}' /proc/meminfo)
RAM_FREE=$(awk '/MemAvailable/ {printf "%.0f MB", $2/1024}' /proc/meminfo)
RAM_USED=$(awk '/MemTotal/{t=$2} /MemAvailable/{a=$2} END{printf "%.0f MB", (t-a)/1024}' /proc/meminfo)
SWAP_TOTAL=$(awk '/SwapTotal/ {printf "%.0f MB", $2/1024}' /proc/meminfo)
SWAP_FREE=$(awk '/SwapFree/ {printf "%.0f MB", $2/1024}' /proc/meminfo)

# ================= DISK =================
DISK_TOTAL=$(df -h / | awk 'NR==2 {print $2}')
DISK_USED=$(df -h / | awk 'NR==2 {print $3}')
DISK_FREE=$(df -h / | awk 'NR==2 {print $4}')
DISK_USE_PCT=$(df -h / | awk 'NR==2 {print $5}')
DISK_TMP_FREE=$(df -h /tmp 2>/dev/null | awk 'NR==2 {print $4}' || echo "N/A")

# ================= GPU =================
if command -v nvidia-smi &>/dev/null; then
    GPU_MODEL=$(nvidia-smi --query-gpu=name --format=csv,noheader 2>/dev/null | head -1)
    GPU_VRAM=$(nvidia-smi --query-gpu=memory.total --format=csv,noheader 2>/dev/null | head -1)
    GPU_DRIVER=$(nvidia-smi --query-gpu=driver_version --format=csv,noheader 2>/dev/null | head -1)
    GPU_INFO="${GPU_MODEL} | VRAM: ${GPU_VRAM} | Driver: ${GPU_DRIVER}"
else
    GPU_INFO="No NVIDIA GPU detected"
fi

# ================= NETWORK =================
PUBLIC_IP=$(curl -sf --max-time 5 https://api.ipify.org || echo "N/A")
HOSTNAME=$(hostname)
INTERFACES=$(ip -o link show | awk -F': ' '{print $2}' | grep -v lo | tr '\n' ' ')
DNS_SERVER=$(grep 'nameserver' /etc/resolv.conf | awk '{print $2}' | head -3 | tr '\n' ' ')
PING_GH=$(ping -c1 -W2 github.com 2>/dev/null | grep 'time=' | grep -oP 'time=\K[\d.]+' | head -1)
[ -z "$PING_GH" ] && PING_GH="N/A" || PING_GH="${PING_GH} ms"

# ================= TOOLS VERSION =================
BASH_VER=$(bash --version | head -1 | grep -oP '\d+\.\d+\.\d+' | head -1)
PYTHON_VER=$(python3 --version 2>/dev/null | awk '{print $2}' || echo "N/A")
NODE_VER=$(node --version 2>/dev/null || echo "N/A")
NPM_VER=$(npm --version 2>/dev/null || echo "N/A")
JAVA_VER=$(java -version 2>&1 | grep -oP '"\K[\d._]+' | head -1 || echo "N/A")
GCC_VER=$(gcc --version 2>/dev/null | head -1 | grep -oP '\d+\.\d+\.\d+' | head -1 || echo "N/A")
GO_VER=$(go version 2>/dev/null | awk '{print $3}' | sed 's/go//' || echo "N/A")
RUBY_VER=$(ruby --version 2>/dev/null | awk '{print $2}' || echo "N/A")
DOCKER_VER=$(docker --version 2>/dev/null | grep -oP '\d+\.\d+\.\d+' | head -1 || echo "N/A")
GIT_VER=$(git --version 2>/dev/null | awk '{print $3}' || echo "N/A")
CURL_VER=$(curl --version 2>/dev/null | head -1 | awk '{print $2}' || echo "N/A")
JQ_VER=$(jq --version 2>/dev/null || echo "N/A")

# ================= GITHUB RUNNER =================
RUNNER_NAME="${RUNNER_NAME:-N/A}"
RUNNER_OS="${RUNNER_OS:-N/A}"
RUNNER_ARCH="${RUNNER_ARCH:-N/A}"
GITHUB_ACTIONS="${GITHUB_ACTIONS:-false}"
GITHUB_WORKFLOW="${GITHUB_WORKFLOW:-N/A}"
GITHUB_RUN_ID="${GITHUB_RUN_ID:-N/A}"
GITHUB_RUN_NUMBER="${GITHUB_RUN_NUMBER:-N/A}"
GITHUB_ACTOR="${GITHUB_ACTOR:-N/A}"
GITHUB_REPOSITORY="${GITHUB_REPOSITORY:-N/A}"
GITHUB_REF="${GITHUB_REF:-N/A}"
GITHUB_SHA="${GITHUB_SHA:-N/A}"
GITHUB_EVENT_NAME="${GITHUB_EVENT_NAME:-N/A}"
ENV_COUNT=$(env | wc -l)

# ================= BUILD MESSAGE =================
MESSAGE="🖥 <b>GitHub Actions Runner Spec</b>
🕒 <b>Time</b> : ${TIMESTAMP}

<pre>[ OS &amp; System ]
OS        : ${OS_NAME}
Kernel    : ${KERNEL_VER}
Arch      : ${ARCH}
Uptime    : ${UPTIME}
Load Avg  : ${LOAD_AVG} (1/5/15m)

[ CPU ]
Model     : ${CPU_MODEL}
Cores     : ${CPU_CORES} cores / ${CPU_THREADS} threads
Speed     : ${CPU_MHZ} MHz
Cache     : ${CPU_CACHE}
Virt      : ${CPU_VIRT}

[ Memory ]
Total     : ${RAM_TOTAL}
Used      : ${RAM_USED}
Free      : ${RAM_FREE}
Swap Tot  : ${SWAP_TOTAL}
Swap Free : ${SWAP_FREE}

[ Disk ]
Root Tot  : ${DISK_TOTAL}
Root Used : ${DISK_USED} (${DISK_USE_PCT})
Root Free : ${DISK_FREE}
/tmp Free : ${DISK_TMP_FREE}

[ GPU ]
${GPU_INFO}

[ Network ]
Hostname  : ${HOSTNAME}
Public IP : ${PUBLIC_IP}
Interface : ${INTERFACES}
DNS       : ${DNS_SERVER}
Ping GH   : ${PING_GH}

[ Tools ]
Bash      : ${BASH_VER}
Git       : ${GIT_VER}
Python3   : ${PYTHON_VER}
Node.js   : ${NODE_VER}
NPM       : ${NPM_VER}
Java      : ${JAVA_VER}
GCC       : ${GCC_VER}
Go        : ${GO_VER}
Ruby      : ${RUBY_VER}
Docker    : ${DOCKER_VER}
curl      : ${CURL_VER}
jq        : ${JQ_VER}

[ GitHub Runner ]
Runner    : ${RUNNER_NAME}
OS        : ${RUNNER_OS}
Arch      : ${RUNNER_ARCH}
GH Actions: ${GITHUB_ACTIONS}
Workflow  : ${GITHUB_WORKFLOW}
Run ID    : ${GITHUB_RUN_ID}
Run No    : ${GITHUB_RUN_NUMBER}
Event     : ${GITHUB_EVENT_NAME}
Actor     : ${GITHUB_ACTOR}
Repo      : ${GITHUB_REPOSITORY}
Ref       : ${GITHUB_REF}
SHA       : ${GITHUB_SHA}
Env Vars  : ${ENV_COUNT} variables</pre>"

# ================= SEND TO TELEGRAM =================
curl -s -X POST "https://api.telegram.org/bot${TG_BOT_TOKEN}/sendMessage" \
    --data-urlencode "chat_id=${TG_CHAT_ID}" \
    --data-urlencode "parse_mode=HTML" \
    --data-urlencode "text=${MESSAGE}"

echo "[✓] Spec sent to Telegram."
