#!/bin/bash
: 'Author:     Pixailz'
: 'created:    20/10/2022 13:49:43'
: 'updated:    27/10/2022 07:07:36'

#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#==#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#
#> CONFIG

PROMPT_OFFSET=1
TITLE_LENGTH=80
SCRIPT_NAME=${0##*/}
SCRIPT_DIR=$(cd ${0%/*} && pwd)
DEEPTHOUGHT_FILE=${SCRIPT_DIR}/deepthought

#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#==#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#

#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#==#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#
#> BASH COLOR

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

DEEP_SEC_COLOR=${green}

function	remove_color()
{
	red=""
	green=""
	blue=""
	orange=""
	blink=""
	reset=""
	SUCCESS="[+]"
	FAILED="[-]"
	DEEP_SEC_COLOR=""
}

#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#==#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#

#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#==#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#
#> PARSE ARGS

function	usage()
{
	printf "${SCRIPT_NAME}: ${SCRIPT_NAME} PATH...\n"
	printf "unit test for minishell project\n"
	printf "\n"
	printf "  -q, --no-color\t\tremove color to the deepthought\n"
	printf "\n"
	printf "  -h, --help\t\t\tdisplay this help and exit\n"
	exit
}

function	error_parse()
{
	printf "${SCRIPT_NAME}: ${1}\n"
	printf "Try '${SCRIPT_NAME} --help' for more information.\n"
	exit
}

function	parse_args()
{
	local	TMP_PATH

	while [ ! -z ${1} ]; do
		case ${1} in
			-q|--no-color)
				NO_COLOR=yes
				;;
			-h|--help)
				usage
				;;
			*)
				[[ "${1}" =~ --?.* ]] && error_parse "invalid options -- '${1}'"
				TMP_PATH=$(realpath ${1})
				[ ! -f "${TMP_PATH}" ] && error_parse "${1}: no such file"
				EXEC_PATH=${TMP_PATH}
				;;
		esac
		shift
	done
}

function	post_parse_args()
{
	[ "${NO_COLOR}" == "yes" ] && remove_color
	[ ! "${EXEC_PATH}" ] && error_parse "missing operand"
}

parse_args ${@}
post_parse_args

#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#==#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#

#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#==#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#
#> REPORT

function	echo_deep_section() {
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
	# remove line with the command and the line with the exit
	out_user="$(echo "${1}" | grep -v -e "${2}" -e "exit")"
	# remove the ansi escaped character, should begin with \001 and finish with \002
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

#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#==#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#
#> BASIC TEST

function	basic_command()
{
	is_the_same "cd /root"
	is_the_same "cd /test"
	is_the_same "echo pass"
}

function	basic_parsing()
{
	echo pass > test/file
	is_the_same "ca't' -e test/file"
	is_the_same "ca't -e' \"test/file\""
	is_the_same "cat -e \"test/'fi'le\""
	is_the_same "cat -e \"test/'fi'\"le\"\""
}

function	basic_test_entry()
{
	basic_command
	basic_parsing
}

#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#==#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#

#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#==#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#
#> MAIN

function	prepare_test()
{
	create_report
	clean_test
	# create a dir test
	mkdir test
}

function	clean_test()
{
	# if directory or file test exists remove it
	[ -d test ] || [ -f test ] && rm -rf test
}

function	main()
{
	prepare_test
	basic_test_entry
	clean_test
}

# main entry
main

#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#==#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#
