#!/usr/bin/env bash

printBannerNarrow() {
	local distroName=$1
	local distroVersion=$2
	local kernelVersion=$3
	local ip=$4
	local currentUser=$5
	local sysInfoMemoryUsage=$6
	local sysInfoUptime=$7
	local sysInfoDisk=$8
	local sysInfoSwap=$9
	local sysInfoUsers=${10}
	local sysInfoProcesses=${11}
	local sysInfoLoad=${12}
	local environmentName=${13}
	local regionName=${14}
	local color=${15}

	setterm -linewrap off
	echo -e "${color}"
    echo -e "        Joyent HashiStack Demo"
	echo -e "\e[39m"
	setterm -linewrap on

	cat <<-EOF
     Environment: ${environmentName}
          Region: ${regionName}
      IP Address: ${ip}
            User: ${currentUser}
   
    Distribution: ${distroName} ${distroVersion}
          Kernel: ${kernelVersion}
   
   System Uptime: ${sysInfoUptime}
     System Load: ${sysInfoLoad}
   
    Memory Usage: ${sysInfoMemoryUsage}
      Usage on /: ${sysInfoDisk}
      Swap Usage: ${sysInfoSwap}
   
     Local Users: ${sysInfoUsers}
       Processes: ${sysInfoProcesses}
EOF
}

printBannerWide() {
	local distroName=$1
	local distroVersion=$2
	local kernelVersion=$3
	local ip=$4
	local currentUser=$5
	local sysInfoMemoryUsage=$6
	local sysInfoUptime=$7
	local sysInfoDisk=$8
	local sysInfoSwap=$9
	local sysInfoUsers=${10}
	local sysInfoProcesses=${11}
	local sysInfoLoad=${12}
	local environmentName=${13}
	local regionName=${14}
	local color=${15}

	local reset="\e[39m"
	
	setterm -linewrap off
    echo
    echo -e "${color}                   ███████████████"
    echo -e "             ███████████████████████████"
    echo -e "          █████████████████████████████████"
    echo -e "        █████████████████████████████████████"
    echo -e "      █████████████████████████████████████████"
    echo -e "    ██████████████████         ██████████████████"
    echo -e "   ███████████████████         ███████████████████"
    echo -e "  ████████████████████         ████████████████████"
    echo -e " █████████████████████         █████████████████████"
    echo -e " █████████████████████         █████████████████████     ${reset}Environment: ${environmentName}${color}"
    echo -e "██████████████████████         ██████████████████████         ${reset}Region: ${regionName}${color}"
    echo -e "██████████                                 ██████████     ${reset}IP Address: ${ip}${color}"
    echo -e "██████████                                 ██████████           ${reset}User: ${currentUser}${color}"
    echo -e "██████████                                 ██████████"
    echo -e " █████████████████████         █████████████████████    ${reset}Distribution: ${distroName} ${distroVersion}${color}"
    echo -e " █████████████████████         █████████████████████          ${reset}Kernel: ${kernelVersion}${color}"
    echo -e "  ████████████████████         ████████████████████"
    echo -e "   ███████████████████         ███████████████████"
    echo -e "    ██████████████████         ██████████████████"
    echo -e "     █████████████████         █████████████████"
    echo -e "       ███████████████████████████████████████"
    echo -e "         ███████████████████████████████████"
    echo -e "           ███████████████████████████████"
    echo -e "              █████████████████████████"
    echo -e "                    █████████████"
	echo -e "\e[39m"
	setterm -linewrap on

	printf "           Memory Usage:\t%s\t\tSystem Uptime:\t%s\n" "${sysInfoMemoryUsage}" "${sysInfoUptime}"
	printf "             Usage On /:\t%s\t\t   Swap Usage:\t%s\n" "${sysInfoDisk}" "${sysInfoSwap}"
	printf "            Local Users:\t%s\t\t    Processes:\t%s\n" "${sysInfoUsers}" "${sysInfoProcesses}"
	printf "            System Load:\t%s\n" "${sysInfoLoad}" 
}

# Source LSB Release info if available
[ -r /etc/lsb-release ] && . /etc/lsb-release

# Otherwise fall back to using the lsb_release utility
if [ -z "$DISTRIB_ID" ] && [ -x /usr/bin/lsb_release ]; then
	DISTRIB_ID=$(lsb_release -s -i)
fi

if [ -z "$DISTRIB_RELEASE" ] && [ -x /usr/bin/lsb_release ]; then
	DISTRIB_RELEASE=$(lsb_release -s -r)
fi

if [ -e "/etc/hashistack-motd/environment" ]; then
	env_name=$(cat /etc/hashistack-motd/environment)
else
	env_name="Unknown Environment"
fi

if [ -e "/etc/hashistack-motd/region" ]; then
	region_name=$(cat /etc/hashistack-motd/region)
else
	region_name=$(curl --silent --location http://169.254.169.254/latest/meta-data/placement/availability-zone | sed 's/.$//')
fi

color='\e[34m'

if echo "${env_name}" | grep "Production" > /dev/null 2>&1; then
	color='\e[31m'
fi

if echo "${env_name}" | grep "Staging" > /dev/null 2>&1; then
	color='\e[33m'
fi

load=$(uptime | sed 's/.*load average: //')
root_usage=$(df -h / | awk '/\// {print $(NF-1)}')
memory_usage=$(free -m | awk '/Mem:/ { printf("%3.1f%%", $3/$2*100) }')
swap_usage=$(free -m | awk '/Swap:/ { if ($2 + 0 != 0) { printf("%3.1f%%", $3/$2*100); } else { printf("0%% (0 total)"); } }')
users=$(users | wc -w)
time=$(uptime | grep -ohe 'up .*' | sed 's/,/\ hours/g' | awk '{ printf $2" "$3 }')
processes=$(ps aux | wc -l)
ip=$(ifconfig $(route | grep default | awk '{ print $8 }') | grep "inet addr" | awk -F: '{print $2}' | awk '{print $1}')

if [ "$(tput cols)" -le "76" ]; then
	printBannerNarrow "${DISTRIB_ID}" "${DISTRIB_RELEASE}" "$(uname -r)" "${ip}" "$(whoami)" "${memory_usage}" "${time}" "${root_usage}" "${swap_usage}" "${users}" "${processes}" "${load}" "${env_name}" "${region_name}" "${color}"
else
	printBannerWide "${DISTRIB_ID}" "${DISTRIB_RELEASE}" "$(uname -r)" "${ip}" "$(whoami)" "${memory_usage}" "${time}" "${root_usage}" "${swap_usage}" "${users}" "${processes}" "${load}" "${env_name}" "${region_name}" "${color}"
fi
