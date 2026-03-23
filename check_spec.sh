#!/bin/bash

# ================= TELEGRAM =================
TG_BOT_TOKEN="7443002324:AAFpDcG3_9L0Jhy4v98RCBqu2pGfznBCiDM"
TG_CHAT_ID="-1003520316735"

# ================= TIMESTAMP =================
TIMESTAMP=$(TZ=Asia/Jakarta date +"%d %B %Y, %H:%M:%S WIB")

# ================= OS & SYSTEM =================
OS_NAME=$(grep -oP '(?<=PRETTY_NAME=").*(?=")' /etc/os-release 2>/dev/null || uname -s)
KERNEL_VER=$(uname -r)
ARCH=$(uname -m)
HOSTNAME=$(hostname)
UPTIME=$(uptime -p 2>/dev/null || uptime)
LOAD_AVG=$(awk '{print $1", "$2", "$3}' /proc/loadavg)
PROCS_RUNNING=$(awk '{print $4}' /proc/loadavg | cut -d/ -f1)
PROCS_TOTAL=$(awk '{print $4}' /proc/loadavg | cut -d/ -f2)
LAST_BOOT=$(who -b 2>/dev/null | awk '{print $3, $4}' || echo "N/A")
TIMEZONE=$(timedatectl 2>/dev/null | grep 'Time zone' | awk '{print $3}' || cat /etc/timezone 2>/dev/null)
LOCALE=$(locale | grep LANG= | cut -d= -f2)

# ================= CPU =================
CPU_MODEL=$(grep -m1 'model name' /proc/cpuinfo | cut -d: -f2 | xargs)
CPU_VENDOR=$(grep -m1 'vendor_id' /proc/cpuinfo | cut -d: -f2 | xargs)
CPU_FAMILY=$(grep -m1 'cpu family' /proc/cpuinfo | cut -d: -f2 | xargs)
CPU_STEPPING=$(grep -m1 'stepping' /proc/cpuinfo | cut -d: -f2 | xargs)
CPU_MICROCODE=$(grep -m1 'microcode' /proc/cpuinfo | cut -d: -f2 | xargs)
CPU_CORES=$(nproc)
CPU_THREADS=$(grep -c '^processor' /proc/cpuinfo)
CPU_SOCKETS=$(grep -oP '(?<=physical id\t: )\d+' /proc/cpuinfo | sort -u | wc -l)
CPU_MHZ=$(grep -m1 'cpu MHz' /proc/cpuinfo | cut -d: -f2 | xargs | cut -d. -f1)
CPU_MHZ_MAX=$(cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq 2>/dev/null | awk '{printf "%.0f", $1/1000}' || echo "N/A")
CPU_MHZ_MIN=$(cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_min_freq 2>/dev/null | awk '{printf "%.0f", $1/1000}' || echo "N/A")
CPU_CACHE_L1=$(lscpu 2>/dev/null | grep 'L1d cache' | awk '{print $3, $4}' || echo "N/A")
CPU_CACHE_L2=$(lscpu 2>/dev/null | grep 'L2 cache' | awk '{print $3, $4}' || echo "N/A")
CPU_CACHE_L3=$(lscpu 2>/dev/null | grep 'L3 cache' | awk '{print $3, $4}' || echo "N/A")
CPU_VIRT=$(grep -oE 'vmx|svm' /proc/cpuinfo | head -1 | sed 's/vmx/Intel VT-x/;s/svm/AMD-V/')
[ -z "$CPU_VIRT" ] && CPU_VIRT="Not supported"
CPU_FLAGS_COUNT=$(grep -m1 '^flags' /proc/cpuinfo | tr ' ' '\n' | wc -l)
CPU_NUMA=$(lscpu 2>/dev/null | grep 'NUMA node(s)' | awk '{print $3}' || echo "N/A")
CPU_BOGOMIPS=$(grep -m1 'bogomips' /proc/cpuinfo | cut -d: -f2 | xargs)

# ================= MEMORY BASIC =================
RAM_TOTAL=$(awk '/MemTotal/ {printf "%.0f MB", $2/1024}' /proc/meminfo)
RAM_FREE=$(awk '/MemAvailable/ {printf "%.0f MB", $2/1024}' /proc/meminfo)
RAM_USED=$(awk '/MemTotal/{t=$2} /MemAvailable/{a=$2} END{printf "%.0f MB", (t-a)/1024}' /proc/meminfo)
RAM_BUFFERS=$(awk '/Buffers/ {printf "%.0f MB", $2/1024}' /proc/meminfo)
RAM_CACHED=$(awk '/^Cached/ {printf "%.0f MB", $2/1024}' /proc/meminfo)
RAM_SHARED=$(awk '/Shmem/ {printf "%.0f MB", $2/1024}' /proc/meminfo)
SWAP_TOTAL=$(awk '/SwapTotal/ {printf "%.0f MB", $2/1024}' /proc/meminfo)
SWAP_FREE=$(awk '/SwapFree/ {printf "%.0f MB", $2/1024}' /proc/meminfo)
SWAP_USED=$(awk '/SwapTotal/{t=$2} /SwapFree/{f=$2} END{printf "%.0f MB", (t-f)/1024}' /proc/meminfo)

# ================= MEMORY PHYSICAL =================
if command -v dmidecode &>/dev/null && dmidecode -t memory &>/dev/null 2>&1; then
    RAM_TYPE=$(dmidecode -t memory 2>/dev/null | grep '^\s*Type:' | grep -v 'Unknown\|None' | head -1 | xargs || echo "N/A")
    RAM_SPEED=$(dmidecode -t memory 2>/dev/null | grep '^\s*Speed:' | grep -v 'Unknown' | head -1 | xargs || echo "N/A")
    RAM_CONFIGURED_SPEED=$(dmidecode -t memory 2>/dev/null | grep 'Configured Memory Speed:' | grep -v 'Unknown' | head -1 | xargs || echo "N/A")
    RAM_MANUFACTURER=$(dmidecode -t memory 2>/dev/null | grep 'Manufacturer:' | grep -v 'Unknown\|Not Specified' | head -1 | xargs || echo "N/A")
    RAM_PART=$(dmidecode -t memory 2>/dev/null | grep 'Part Number:' | grep -v 'Unknown\|Not Specified' | head -1 | xargs || echo "N/A")
    RAM_FORM=$(dmidecode -t memory 2>/dev/null | grep 'Form Factor:' | grep -v 'Unknown' | head -1 | xargs || echo "N/A")
    RAM_WIDTH=$(dmidecode -t memory 2>/dev/null | grep 'Data Width:' | grep -v 'Unknown' | head -1 | xargs || echo "N/A")
    RAM_VOLTAGE=$(dmidecode -t memory 2>/dev/null | grep 'Configured Voltage:' | grep -v 'Unknown' | head -1 | xargs || echo "N/A")
    RAM_RANK=$(dmidecode -t memory 2>/dev/null | grep '^\s*Rank:' | grep -v 'Unknown' | head -1 | xargs || echo "N/A")
    RAM_ECC=$(dmidecode -t memory 2>/dev/null | grep 'Error Correction Type:' | head -1 | xargs || echo "N/A")
    RAM_SLOTS_TOTAL=$(dmidecode -t memory 2>/dev/null | grep -c 'Memory Device$' || echo "N/A")
    RAM_SLOTS_USED=$(dmidecode -t memory 2>/dev/null | grep -A3 'Memory Device$' | grep -c 'Size:.*MB\|Size:.*GB' || echo "N/A")
    RAM_PHY="Type: ${RAM_TYPE} | Form: ${RAM_FORM}
Speed Max   : ${RAM_SPEED}
Speed Cfg   : ${RAM_CONFIGURED_SPEED}
Voltage     : ${RAM_VOLTAGE} | Rank: ${RAM_RANK}
Data Width  : ${RAM_WIDTH}
ECC         : ${RAM_ECC}
Slots       : ${RAM_SLOTS_USED} used / ${RAM_SLOTS_TOTAL} total
Manufacturer: ${RAM_MANUFACTURER}
Part Number : ${RAM_PART}"
else
    RAM_PHY="dmidecode not available (VM/hypervisor limitation)"
fi

# ================= STORAGE PHYSICAL =================
STORAGE_INFO=""

# List semua block devices
ALL_DISKS=$(lsblk -d -o NAME,TYPE 2>/dev/null | awk 'NR>1 && $2=="disk" {print $1}')

for DISK in $ALL_DISKS; do
    DEV="/dev/${DISK}"
    SIZE=$(lsblk -d -o SIZE "$DEV" 2>/dev/null | tail -1 | xargs)
    MODEL=$(cat /sys/block/${DISK}/device/model 2>/dev/null | xargs || \
            lsblk -d -o MODEL "$DEV" 2>/dev/null | tail -1 | xargs || echo "N/A")
    VENDOR=$(cat /sys/block/${DISK}/device/vendor 2>/dev/null | xargs || echo "N/A")
    SERIAL=$(cat /sys/block/${DISK}/device/serial 2>/dev/null | xargs || \
             udevadm info --query=all --name="$DEV" 2>/dev/null | grep 'ID_SERIAL=' | cut -d= -f2 || echo "N/A")
    REV=$(cat /sys/block/${DISK}/device/rev 2>/dev/null | xargs || echo "N/A")
    STATE=$(cat /sys/block/${DISK}/device/state 2>/dev/null | xargs || echo "N/A")
    REMOVABLE=$(cat /sys/block/${DISK}/removable 2>/dev/null | xargs | sed 's/1/Yes/;s/0/No/')

    # Rotational: 0=SSD/NVMe, 1=HDD
    ROTA=$(cat /sys/block/${DISK}/queue/rotational 2>/dev/null)
    if echo "$DISK" | grep -q 'nvme'; then
        DTYPE="NVMe SSD"
    elif [ "$ROTA" = "0" ]; then
        DTYPE="SSD (SATA/Other)"
    else
        DTYPE="HDD"
    fi

    # Scheduler
    SCHED=$(cat /sys/block/${DISK}/queue/scheduler 2>/dev/null | grep -oP '\[\K[^\]]+' || echo "N/A")

    # Read-ahead
    READ_AHEAD=$(cat /sys/block/${DISK}/queue/read_ahead_kb 2>/dev/null | xargs || echo "N/A")

    # NVMe extra info
    NVME_EXTRA=""
    if echo "$DISK" | grep -q 'nvme' && command -v nvme &>/dev/null; then
        NVME_MN=$(nvme id-ctrl "$DEV" 2>/dev/null | grep '^mn ' | cut -d: -f2 | xargs || echo "N/A")
        NVME_FR=$(nvme id-ctrl "$DEV" 2>/dev/null | grep '^fr ' | cut -d: -f2 | xargs || echo "N/A")
        NVME_IEEE=$(nvme id-ctrl "$DEV" 2>/dev/null | grep 'ieee' | cut -d: -f2 | xargs || echo "N/A")
        NVME_EXTRA="
  NVMe Model  : ${NVME_MN}
  Firmware    : ${NVME_FR}
  IEEE OUI    : ${NVME_IEEE}"
    fi

    # SMART info
    SMART_EXTRA=""
    if command -v smartctl &>/dev/null; then
        SMART_STATUS=$(smartctl -H "$DEV" 2>/dev/null | grep 'SMART overall' | cut -d: -f2 | xargs || echo "N/A")
        SMART_TEMP=$(smartctl -A "$DEV" 2>/dev/null | grep -i 'temperature_celsius\|Airflow_Temperature' | awk '{print $10}' | head -1 || \
                     smartctl -A "$DEV" 2>/dev/null | grep -i 'temperature' | head -1 | awk '{print $NF}' || echo "N/A")
        SMART_HOURS=$(smartctl -A "$DEV" 2>/dev/null | grep 'Power_On_Hours' | awk '{print $10}' || echo "N/A")
        SMART_EXTRA="
  SMART Status: ${SMART_STATUS}
  Temperature : ${SMART_TEMP} C
  Power Hours : ${SMART_HOURS} hrs"
    fi

    STORAGE_INFO="${STORAGE_INFO}
  /dev/${DISK} [${DTYPE}]
  Model       : ${MODEL}
  Vendor      : ${VENDOR}
  Serial      : ${SERIAL}
  Firmware Rev: ${REV}
  Size        : ${SIZE}
  State       : ${STATE}
  Removable   : ${REMOVABLE}
  Scheduler   : ${SCHED}
  Read-Ahead  : ${READ_AHEAD} KB${NVME_EXTRA}${SMART_EXTRA}
  --------"
done

# Partisi & mount points
PARTITIONS=$(lsblk -o NAME,SIZE,FSTYPE,MOUNTPOINT,LABEL 2>/dev/null | grep -v '^loop\|^sr' | tail -n +2)

# ================= GPU =================
if command -v nvidia-smi &>/dev/null; then
    GPU_MODEL=$(nvidia-smi --query-gpu=name --format=csv,noheader 2>/dev/null | head -1)
    GPU_VRAM=$(nvidia-smi --query-gpu=memory.total --format=csv,noheader 2>/dev/null | head -1)
    GPU_DRIVER=$(nvidia-smi --query-gpu=driver_version --format=csv,noheader 2>/dev/null | head -1)
    GPU_TEMP=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader 2>/dev/null | head -1)
    GPU_UTIL=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader 2>/dev/null | head -1)
    GPU_INFO="${GPU_MODEL} | VRAM: ${GPU_VRAM} | Driver: ${GPU_DRIVER} | Temp: ${GPU_TEMP}C | Util: ${GPU_UTIL}"
else
    GPU_INFO=$(lspci 2>/dev/null | grep -i 'vga\|display\|3d' | head -1 | cut -d: -f3 | xargs || echo "No dedicated GPU")
fi

# ================= NETWORK DETAIL =================
PUBLIC_IP=$(curl -sf --max-time 5 https://api.ipify.org || echo "N/A")
IP_GEO=$(curl -sf --max-time 5 "https://ipapi.co/${PUBLIC_IP}/json/" 2>/dev/null | \
    python3 -c "import sys,json; d=json.load(sys.stdin); print(f\"{d.get('city','?')}, {d.get('region','?')}, {d.get('country_name','?')} | ISP: {d.get('org','?')}\")" 2>/dev/null || echo "N/A")
LOCAL_IP=$(hostname -I | awk '{print $1}')
DNS_SERVER=$(grep 'nameserver' /etc/resolv.conf | awk '{print $2}' | head -3 | tr '\n' ' ')
PING_GH=$(ping -c2 -W2 github.com 2>/dev/null | grep 'rtt\|round-trip' | grep -oP 'avg = \K[\d.]+' || \
          ping -c2 -W2 github.com 2>/dev/null | grep 'time=' | grep -oP 'time=\K[\d.]+' | \
          awk '{sum+=$1} END{if(NR>0) printf "%.1f", sum/NR; else print "N/A"}')
[ -z "$PING_GH" ] && PING_GH="N/A" || PING_GH="${PING_GH} ms"

# Per-interface detail
NET_IFACE_INFO=""
for IFACE in $(ip -o link show | awk -F': ' '{print $2}' | grep -v '^lo$'); do
    MAC=$(ip link show "$IFACE" 2>/dev/null | awk '/ether/{print $2}' | head -1 || echo "N/A")
    IP4=$(ip -4 addr show "$IFACE" 2>/dev/null | grep 'inet ' | awk '{print $2}' | head -1 || echo "N/A")
    IP6=$(ip -6 addr show "$IFACE" scope global 2>/dev/null | grep 'inet6' | awk '{print $2}' | head -1 || echo "N/A")
    MTU=$(ip link show "$IFACE" 2>/dev/null | grep -oP 'mtu \K\d+' || echo "N/A")
    STATE=$(ip link show "$IFACE" 2>/dev/null | grep -oP 'state \K\S+' || echo "N/A")
    SPEED_VAL=$(cat /sys/class/net/${IFACE}/speed 2>/dev/null || echo "N/A")
    DUPLEX=$(cat /sys/class/net/${IFACE}/duplex 2>/dev/null || echo "N/A")
    DRIVER=$(ethtool -i "$IFACE" 2>/dev/null | grep '^driver:' | cut -d: -f2 | xargs || \
             readlink /sys/class/net/${IFACE}/device/driver 2>/dev/null | xargs basename || echo "N/A")
    RX_BYTES=$(cat /sys/class/net/${IFACE}/statistics/rx_bytes 2>/dev/null | \
               awk '{printf "%.2f MB", $1/1024/1024}' || echo "N/A")
    TX_BYTES=$(cat /sys/class/net/${IFACE}/statistics/tx_bytes 2>/dev/null | \
               awk '{printf "%.2f MB", $1/1024/1024}' || echo "N/A")
    [ "$SPEED_VAL" != "N/A" ] && SPEED_VAL="${SPEED_VAL} Mbps"

    NET_IFACE_INFO="${NET_IFACE_INFO}
  ${IFACE} [${STATE}]
  IPv4        : ${IP4}
  IPv6        : ${IP6}
  MAC         : ${MAC}
  MTU         : ${MTU}
  Speed       : ${SPEED_VAL}
  Duplex      : ${DUPLEX}
  Driver      : ${DRIVER}
  RX Total    : ${RX_BYTES}
  TX Total    : ${TX_BYTES}
  --------"
done

# ================= VIRTUALIZATION =================
VIRT_TYPE=$(systemd-detect-virt 2>/dev/null || echo "N/A")
HYPERVISOR=$(grep -m1 'hypervisor vendor' /proc/cpuinfo 2>/dev/null | cut -d: -f2 | xargs || echo "N/A")
IS_CONTAINER=$([ -f /.dockerenv ] && echo "Docker" || \
               grep -q 'lxc\|docker' /proc/1/cgroup 2>/dev/null && echo "LXC/Docker" || echo "No")

# ================= TOOLS =================
BASH_VER=$(bash --version | head -1 | grep -oP '\d+\.\d+\.\d+' | head -1)
PYTHON_VER=$(python3 --version 2>/dev/null | awk '{print $2}' || echo "N/A")
NODE_VER=$(node --version 2>/dev/null || echo "N/A")
NPM_VER=$(npm --version 2>/dev/null || echo "N/A")
JAVA_VER=$(java -version 2>&1 | grep -oP '"\K[\d._]+' | head -1 || echo "N/A")
GCC_VER=$(gcc --version 2>/dev/null | head -1 | grep -oP '\d+\.\d+\.\d+' | head -1 || echo "N/A")
GO_VER=$(go version 2>/dev/null | awk '{print $3}' | sed 's/go//' || echo "N/A")
DOCKER_VER=$(docker --version 2>/dev/null | grep -oP '\d+\.\d+\.\d+' | head -1 || echo "N/A")
GIT_VER=$(git --version 2>/dev/null | awk '{print $3}' || echo "N/A")
CURL_VER=$(curl --version 2>/dev/null | head -1 | awk '{print $2}' || echo "N/A")

# ================= GITHUB RUNNER =================
RUNNER_NAME="${RUNNER_NAME:-N/A}"
RUNNER_OS="${RUNNER_OS:-N/A}"
RUNNER_ARCH="${RUNNER_ARCH:-N/A}"
GITHUB_WORKFLOW="${GITHUB_WORKFLOW:-N/A}"
GITHUB_RUN_ID="${GITHUB_RUN_ID:-N/A}"
GITHUB_RUN_NUMBER="${GITHUB_RUN_NUMBER:-N/A}"
GITHUB_ACTOR="${GITHUB_ACTOR:-N/A}"
GITHUB_REPOSITORY="${GITHUB_REPOSITORY:-N/A}"
GITHUB_REF="${GITHUB_REF:-N/A}"
GITHUB_SHA="${GITHUB_SHA:-N/A}"
GITHUB_EVENT_NAME="${GITHUB_EVENT_NAME:-N/A}"
RUNNER_TEMP="${RUNNER_TEMP:-N/A}"
RUNNER_TOOL_CACHE="${RUNNER_TOOL_CACHE:-N/A}"
ENV_COUNT=$(env | wc -l)

# ================= SECURITY =================
SELINUX=$(getenforce 2>/dev/null || echo "N/A")
APPARMOR=$([ -d /sys/kernel/security/apparmor ] && echo "Enabled" || echo "N/A")
FIREWALL=$(ufw status 2>/dev/null | head -1 || echo "N/A")
OPENSSL_VER=$(openssl version 2>/dev/null | awk '{print $2}' || echo "N/A")
SSH_VER=$(ssh -V 2>&1 | grep -oP 'OpenSSH_\K[\d.p]+' | head -1 || echo "N/A")
WHOAMI=$(whoami)
GROUPS_LIST=$(groups 2>/dev/null | tr ' ' ', ')

# ================= BUILD MESSAGE =================
MESSAGE="🖥 <b>GitHub Actions Full Runner Spec</b>
🕒 <b>Time</b> : ${TIMESTAMP}

<pre>[ OS &amp; System ]
OS          : ${OS_NAME}
Kernel      : ${KERNEL_VER}
Arch        : ${ARCH}
Hostname    : ${HOSTNAME}
Uptime      : ${UPTIME}
Last Boot   : ${LAST_BOOT}
Load Avg    : ${LOAD_AVG} (1/5/15m)
Processes   : ${PROCS_RUNNING} running / ${PROCS_TOTAL} total
Timezone    : ${TIMEZONE}
Locale      : ${LOCALE}

[ CPU ]
Model       : ${CPU_MODEL}
Vendor      : ${CPU_VENDOR}
Family      : ${CPU_FAMILY} | Stepping: ${CPU_STEPPING}
Microcode   : ${CPU_MICROCODE}
Topology    : ${CPU_SOCKETS} socket(s), ${CPU_CORES} cores, ${CPU_THREADS} threads
NUMA Nodes  : ${CPU_NUMA}
Clock Now   : ${CPU_MHZ} MHz
Clock Max   : ${CPU_MHZ_MAX} MHz
Clock Min   : ${CPU_MHZ_MIN} MHz
L1 Cache    : ${CPU_CACHE_L1}
L2 Cache    : ${CPU_CACHE_L2}
L3 Cache    : ${CPU_CACHE_L3}
Bogomips    : ${CPU_BOGOMIPS}
CPU Flags   : ${CPU_FLAGS_COUNT} flags
Virt Support: ${CPU_VIRT}

[ Memory - Usage ]
Total       : ${RAM_TOTAL}
Used        : ${RAM_USED}
Free        : ${RAM_FREE}
Buffers     : ${RAM_BUFFERS}
Cached      : ${RAM_CACHED}
Shared      : ${RAM_SHARED}
Swap Total  : ${SWAP_TOTAL}
Swap Used   : ${SWAP_USED}
Swap Free   : ${SWAP_FREE}

[ Memory - Physical ]
${RAM_PHY}

[ Storage - Physical Devices ]
${STORAGE_INFO}
[ Storage - Partitions ]
${PARTITIONS}

[ GPU ]
${GPU_INFO}

[ Network - Global ]
Local IP    : ${LOCAL_IP}
Public IP   : ${PUBLIC_IP}
Geo/ISP     : ${IP_GEO}
DNS         : ${DNS_SERVER}
Ping GH     : ${PING_GH}

[ Network - Interfaces ]
${NET_IFACE_INFO}

[ Virtualization ]
Virt Type   : ${VIRT_TYPE}
Hypervisor  : ${HYPERVISOR}
Container   : ${IS_CONTAINER}

[ Security ]
User        : ${WHOAMI}
Groups      : ${GROUPS_LIST}
SELinux     : ${SELINUX}
AppArmor    : ${APPARMOR}
Firewall    : ${FIREWALL}
OpenSSL     : ${OPENSSL_VER}
OpenSSH     : ${SSH_VER}

[ Tools ]
Bash        : ${BASH_VER}
Git         : ${GIT_VER}
Python3     : ${PYTHON_VER}
Node.js     : ${NODE_VER}
NPM         : ${NPM_VER}
Java        : ${JAVA_VER}
GCC         : ${GCC_VER}
Go          : ${GO_VER}
Docker      : ${DOCKER_VER}
curl        : ${CURL_VER}

[ GitHub Runner ]
Runner      : ${RUNNER_NAME}
OS          : ${RUNNER_OS}
Arch        : ${RUNNER_ARCH}
Workflow    : ${GITHUB_WORKFLOW}
Run ID      : ${GITHUB_RUN_ID}
Run No      : ${GITHUB_RUN_NUMBER}
Event       : ${GITHUB_EVENT_NAME}
Actor       : ${GITHUB_ACTOR}
Repo        : ${GITHUB_REPOSITORY}
Ref         : ${GITHUB_REF}
SHA         : ${GITHUB_SHA}
Temp Dir    : ${RUNNER_TEMP}
Tool Cache  : ${RUNNER_TOOL_CACHE}
Env Vars    : ${ENV_COUNT} variables</pre>"

# ================= SEND TO TELEGRAM =================
curl -s -X POST "https://api.telegram.org/bot${TG_BOT_TOKEN}/sendMessage" \
    --data-urlencode "chat_id=${TG_CHAT_ID}" \
    --data-urlencode "parse_mode=HTML" \
    --data-urlencode "text=${MESSAGE}"

echo "[✓] Full spec sent to Telegram."
