#!/bin/bash

#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#==#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#
#> Config

PROMPT_OFFSET=1
TITLE_LENGTH=80
DEEPTHOUGHT_FILE=deepthought

#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#==#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#

#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#==#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#
#> Bash Color (printable)

red="\x1b[38;5;196m"
green="\x1b[38;5;82m"
blue="\x1b[38;5;75m"
orange="\x1b[38;5;214m"
blink="\x1b[5m"

reset="\x1b[0m"

SUCCESS="[${green}+${reset}] "
FAILED="[${red}-${reset}] "

UL="\xe2\x95\x94"
HO="\xe2\x95\x90"
UR="\xe2\x95\x97"
VE="\xe2\x95\x91"
LL="\xe2\x95\x9a"
LR="\xe2\x95\x9d"
HEART="${blink}\xe2\x99\xa5${reset}"

DEEP_SEC_COLOR=${green}

#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#==#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#

#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#==#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#
#> REPORT

function echo_deep_section() {
	vertical_offset=$(printf "%0.s${HO}" $(seq 1 ${TITLE_LENGTH}))
	center_off=$(( ${TITLE_LENGTH} - ${#1}))
	center_splited=$(( ${center_off} / 2 ))
	if [ $(( ${center_off} % 2)) == 0 ]; then
		CL=$(printf "%0.s " $(seq 1 ${center_splited}))
		CR=$(printf "%0.s " $(seq 1 ${center_splited}))
	else
		CL=$(printf "%0.s " $(seq 1 ${center_splited}))
		CR=$(printf "%0.s " $(seq 1 ${center_splited}) 1)
	fi
	printf "${DEEP_SEC_COLOR}${UL}${vertical_offset}${UR}\n" >> ${DEEPTHOUGHT_FILE}
	printf "${VE}${CL}${reset}${1}${DEEP_SEC_COLOR}${CR}${VE}\n" >> ${DEEPTHOUGHT_FILE}
	printf "${LL}${vertical_offset}${LR}${reset}\n" >> ${DEEPTHOUGHT_FILE}
}

function	append_to_deep()
{
	local	level=${1}
	local	msg=${2}

	if [ "${level}" == "1" ]; then
		offset_tab="\t"
	elif [ "${level}" == "2" ]; then
		offset_tab="\t\t"
	else
		offset_tab=""
	fi
	msg="$(echo "${msg}" | sed "s|^|${offset_tab}|")"
	printf "${msg}" >> ${DEEPTHOUGHT_FILE}
}

function	create_report()
{
	[ -f ${DEEPTHOUGHT_FILE} ] && rm -f ${DEEPTHOUGHT_FILE}
	echo_deep_section "MINISHELL"
}


#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#==#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#

#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#==#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#
#> TEST

function	clean_out_user()
{
	out_user="$(echo "${1}" | sed -E "/.*${END_PROMPT}.*/d")"
}

function	is_the_same_report()
{
	append_to_deep 0 "\`${red}${1}${reset}':\n"
	append_to_deep 1 "$(diff <(echo "${out_expected}") <(echo "${out_user}"))"
	append_to_deep 0 "\n\n"
}

function	is_the_same()
{
	local	out_expected
	local	return_value_expected
	local	return_value_user

	out_expected=$(${1} 2>&1)
	return_value_expected=${?}
	out_user="$(echo ${1} | ${EXEC_PATH} 2>&1)"
	return_value_user=${?}
	clean_out_user "${out_user}"
	is_the_same_report "${1}"
}

#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#==#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#
#> MAIN

function main()
{
	create_report
	is_the_same "cd /root"
	is_the_same "cd /test"
}

main

#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#==#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#
