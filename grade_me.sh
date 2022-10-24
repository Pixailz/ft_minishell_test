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
	local	msg=${2}

	if [ "${1}" == "1" ]; then
		offset_tab="\t"
	elif [ "${1}" == "2" ]; then
		offset_tab="\t\t"
	else
		offset_tab=""
	fi
	msg="$(echo "${msg}" | sed "s|^|${offset_tab}|")"
	printf "${msg}\n" >> ${DEEPTHOUGHT_FILE}
}

function	append_to_deep_pass()
{
	if [ "${1}" == "1" ]; then
		offset_tab="\t"
	elif [ "${1}" == "2" ]; then
		offset_tab="\t\t"
	else
		offset_tab=""
	fi
	if [ "${3}" == "success" ]; then
		msg="${SUCCESS}${2}"
	else
		msg="${FAILED}${2}"
	fi
	msg=$(printf "${msg}" | sed "s|^|${offset_tab}|")
	printf "${msg}\n" >> ${DEEPTHOUGHT_FILE}
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
	out_user="$(echo "${1}" | grep -v -e "${2}" -e "exit")"
	out_user="$(echo "${out_user}" | sed "s/\o001.*\o002//g")"
}

function	report_same_file()
{
	diff_out="$(diff <(echo "${out_expected}") <(echo "${out_user}"))"
	if [ -z "${diff_out}" ]; then
		append_to_deep_pass 1 "\`${green}${1}${reset}' diff ok" success
	else
		append_to_deep_pass 1 "\`${red}${1}${reset}'\n${diff_out}" failed
	fi
}

function	is_the_same_report()
{
	if [ "${2}" == "1" ]; then
		append_to_deep_pass 0 "return value are the same" success
	else
		append_to_deep_pass 0 "return value are not the same" failed
	fi
	report_same_file "${1}"
	append_to_deep ""
}

function	is_the_same()
{
	local	out_expected
	local	return_value_expected
	local	return_value_user
	local	same_return_value

	# exec real bash
	out_expected=$(bash -c "${1}" 2>&1)
	# catch real bash return value
	return_value_expected=${?}
	# exec minishell
	out_user="$(echo ${1} | ${EXEC_PATH} 2>&1)"
	# catch minishell return value
	return_value_user=${?}
	# clean prompt output
	clean_out_user "${out_user}" "${1}"
	# check if return value match
	if [ "${return_value_expected}" == "${return_value_user}" ]; then
		same_return_value=1
	else
		same_return_value=0
	fi
	# report test
	is_the_same_report "${1}" "${same_return_value}"
}

#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#==#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#
#> MAIN

EXEC_PATH="${1}"

function prepare_test()
{
	create_report
	clean_test
	mkdir test
}

function clean_test()
{
	[ -d test ] || [ -f test ] && rm -rf test
}

function test_command()
{
	is_the_same "cd /root"
	is_the_same "cd /test"
	is_the_same "echo pass"
	echo pass > test/file
	is_the_same "ca't' -e test/file"
	is_the_same "ca't -e' \"test/file\""
	is_the_same "cat -e \"test/'fi'le\""
	is_the_same "cat -e \"test/'fi'\"le\"\""

}

function main()
{
	prepare_test
	test_command
	clean_test
}

main

#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#==#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#
