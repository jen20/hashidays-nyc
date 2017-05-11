PROMPT_COLOR_SET="\[\033[34m\]"
PROMPT_BOLD_SET="\[\033[1m\]"
PROMPT_BOLD_RESET="\[\033[0m\]"

if [ "`id -u`" -ne 0 ] && [ -x /usr/local/bin/dynamicMOTD.sh ]; then
	/usr/local/bin/dynamicMOTD.sh
fi

if [ -e "/etc/hashistack-motd/environment" ]; then
	PROMPT_ENVIRONMENT=$(cat /etc/hashistack-motd/environment)
else
	PROMPT_ENVIRONMENT="Unknown Environment"
fi

if [ -e "/etc/hashistack-motd/region" ]; then
	PROMPT_REGION=" :: $(cat /etc/hashistack-motd/region)"
fi

if echo "${PROMPT_ENVIRONMENT}" | grep "Production" > /dev/null 2>&1; then
	PROMPT_COLOR_SET='\e[31m'
fi

if echo "${PROMPT_ENVIRONMENT}" | grep "Staging" > /dev/null 2>&1; then
	PROMPT_COLOR_SET='\e[33m'
fi

PS1="
${PROMPT_COLOR_SET}${PROMPT_BOLD_SET}[\t]${PROMPT_COLOR_SET} ${PROMPT_ENVIRONMENT}${PROMPT_BOLD_RESET}${PROMPT_COLOR_SET}${PROMPT_REGION} :: ${debian_chroot:+($debian_chroot)}\u@\h${PROMPT_BOLD_RESET} 
${PROMPT_BOLD_SET}\w${PROMPT_BOLD_RESET} $ "
