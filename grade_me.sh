#!/bin/bash
: 'Author:     Pixailz'
: 'created:    20/10/2022 13:49:43'
: 'updated:    27/10/2022 07:07:36'

#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#==#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#
#> CONFIG

TITLE_LENGTH=60
SCRIPT_NAME=${0##*/}
SCRIPT_DIR=$(cd ${0%/*} && pwd)
DEEPTHOUGHT_FILE=${SCRIPT_DIR}/deepthought
PRINT_OFFSET_STR="\t"

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
INFO="[${blue}*${reset}] "
WARN="[${orange}*${reset}] "

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
	SUCCESS="[+] "
	FAILED="[-] "
	INFO="[*] "
	WARN="[*] "
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
	vertical_offset=$(printf "%0.s${HO}" $(seq 3 ${TITLE_LENGTH}))
	center_off=$(( ${TITLE_LENGTH} - ${#1}))
	center_splited=$(( (${center_off} - 2) / 2 ))
	if [ $(( ${center_off} % 2)) == 0 ]; then
		CL=$(printf "%0.s " $(seq 1 ${center_splited}))
		CR=$(printf "%0.s " $(seq 1 ${center_splited}))
	else
		CL=$(printf "%0.s " $(seq 1 ${center_splited}))
		CR=$(printf "%0.s " $(seq 1 ${center_splited}) 1)
	fi
	if [ "${2}" == "1" ]; then
		printf "${DEEP_SEC_COLOR}${UL}${vertical_offset}${UR}\n" >> ${DEEPTHOUGHT_FILE}
		printf "${VE}${CL}${reset}${1}${DEEP_SEC_COLOR}${CR}${VE}\n" >> ${DEEPTHOUGHT_FILE}
		printf "${LL}${vertical_offset}${LR}${reset}\n" >> ${DEEPTHOUGHT_FILE}
	fi
	printf "${DEEP_SEC_COLOR}${UL}${vertical_offset}${UR}\n"
	printf "${VE}${CL}${reset}${1}${DEEP_SEC_COLOR}${CR}${VE}\n"
	printf "${LL}${vertical_offset}${LR}${reset}\n"
}

function	echo_deep()
{
	local	offset=${1}
	local	mode=${2}
	local	msg=${3}
	local	deepthought_out=${4}
	local	first_part=""

	offset_tab=""
	while [ "${offset}" != "0" ]; do
		offset_tab="${offset_tab}${PRINT_OFFSET_STR}"
		offset=$((${offset} - 1))
	done
	if [ "${mode}" == "-1" ]; then
		first_part="${msg}"
	elif [ "${mode}" == "0" ]; then
		first_part="${FAILED}${msg}"
	elif [ "${mode}" == "1" ]; then
		first_part="${SUCCESS}${msg}"
	elif [ "${mode}" == "2" ]; then
		first_part="${INFO}${msg}"
	elif [ "${mode}" == "3" ]; then
		first_part="${WARN}${msg}"
	fi
	msg=$(printf "${first_part}" | sed "s|^|${offset_tab}|")
	if [ "${deepthought_out}" == "1" ]; then
		printf "${msg}\n" >> ${DEEPTHOUGHT_FILE}
	else
		printf "${msg}\n"
	fi
}

function	reset_deepfile()
{
	[ -f ${DEEPTHOUGHT_FILE} ] && rm -f ${DEEPTHOUGHT_FILE}
	echo_deep_section "MINISHELL tester (pix)." 1
}

#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#==#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#

#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#==#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#
#> TEST

function	clean_out_user_cmd()
{
	# remove the ansi escaped character, should begin with \001 and finish with \002
	out_user="$(echo "${1}" | sed "s/\o001.*\o002//g")"
	# catch minishell return value
	return_value_user=$(echo "${out_user}" | sed -nE 's/return_value=([0-9]{1,3})/\1/p')
	# remove line with the command and the three last command
	out_user="$(echo "${out_user}" | tail -n +2 | head -n -3 )"
}

function	report_out()
{
	if [ "${out_expected}" == "${out_user}" ]; then
		echo_deep 1 1 "diff ok" 1
	else
		echo_deep 3 0 "diff not ok"
		echo_deep 1 0 "diff not ok" 1
		echo_deep 2 -1 "${green}expected${reset}:" 1
		echo_deep 3 -1 "${out_expected}" 1
		echo_deep 2 -1 "${red}yours${reset}:" 1
		echo_deep 3 -1 "${out_user}" 1
	fi
}

function	report_return_value()
{
	if [ "${same_return_value}" == "1" ]; then
		echo_deep 1 1 "return value are the same" 1
	else
		echo_deep 3 0 "return value are not the same"
		echo_deep 1 0 "return value are not the same" 1
		echo_deep 2 -1 "${green}expected${reset}(${return_value_expected}) \
| ${red}yours${reset}:(${return_value_user})" 1
	fi
}

function	same_out_and_return()
{
	local	out_expected
	local	out_user_exec=${2}
	local	return_value_expected
	local	same_return_value

	# exec real bash
	out_expected=$(bash -c "${1}" 2>&1)
	# catch real bash return value
	return_value_expected=${?}
	# exec minishell
	if [ "${out_user_exec}" == "1" ]; then
		exec_command="bash -c \"${1}\""
	elif [ "${out_user_exec}" == "2" ]; then
		exec_command="./minishell\n${1}"
	else
		exec_command=""
	fi
	out_user="$(echo -e "${exec_command}\necho return_value=\$?" | ${EXEC_PATH} 2>&1)"
	# clean prompt output
	clean_out_user_cmd "${out_user}" "${1}"
	# check if return value match
	same_return_value=0
	if [ "${return_value_expected}" == "${return_value_user}" ]; then
		same_return_value=1
	fi
	# report test
	if [ "${same_return_value}" == 0 ] || [ "${out_expected}" != "${out_user}" ]; then
		echo_deep 2 3 "\`${blue}${1}${reset}'"
	fi
	echo_deep 0 3 "\`${blue}${1}${reset}'" 1
	report_return_value ${same_return_value}
	report_out

}

#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#==#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#

#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#==#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#
# TEST

##<-- EXEC PERM
function	permission_exec_setup_create_file()
{
	local	permissions=${1}
	local	file_path=${2}

	[ -f ${file_path} ] || [ -d ${file_path} ] && rm -rf ${file_path}
	echo "echo pass" > ${file_path}
	chmod ${permissions} ${file_path}
}
function	permission_exec_setup()
{
	# me: ---, groups: ---, others: --- (false)
	permission_exec_setup_create_file 000 ./test/exec_00
	# me: --x, groups: ---, others: --- (false)
	permission_exec_setup_create_file 100 ./test/exec_01
	# me: -w-, groups: ---, others: --- (false)
	permission_exec_setup_create_file 200 ./test/exec_02
	# me: -wx, groups: ---, others: --- (false)
	permission_exec_setup_create_file 300 ./test/exec_03
	# me: -wx, groups: ---, others: --- (false)
	permission_exec_setup_create_file 400 ./test/exec_04
	# me: r-x, groups: ---, others: --- (true)
	permission_exec_setup_create_file 500 ./test/exec_05
	# me: rw-, groups: ---, others: --- (false)
	permission_exec_setup_create_file 600 ./test/exec_06
	# me: rwx, groups: ---, others: --- (true)
	permission_exec_setup_create_file 700 ./test/exec_07
}

function permission_exec_start()
{
	same_out_and_return "./test/exec_00" 1
	same_out_and_return "./test/exec_01" 1
	same_out_and_return "./test/exec_02" 1
	same_out_and_return "./test/exec_03" 1
	same_out_and_return "./test/exec_04" 1
	same_out_and_return "./test/exec_05" 1
	same_out_and_return "./test/exec_06" 1
	same_out_and_return "./test/exec_07" 1
}

##--> Permission file execve will launch
function	permission_exec()
{
	permission_exec_setup
	permission_exec_start
}

##<-- cd part
function	cd_section()
{
	# 1: Permission Denied
	same_out_and_return "cd /root"
	# 1: No such file or directory
	same_out_and_return "cd /test"
}
##-->

##<-- parsing part
function	parsing_section()
{
	echo pass > test/file
	same_out_and_return "ca't' -e test/file"
	same_out_and_return "ca't -e' \"test/file\""
	same_out_and_return "cat -e \"test/'fi'le\""
	same_out_and_return "cat -e \"test/'fi'\"le\"\""
}
#-->

##<-- pipe section

function	pipe_section()
{
	same_out_and_return "echo pass | cat -e"
	same_out_and_return "echo pass | cat -e | cat -e | cat -e | cat -e | cat -e | cat -e"
	# same_out_and_return "ls -laR / | head -n 10"
	same_out_and_return "cat /etc/os-release | head -n 10"
	same_out_and_return "cat /dev/urandom | head -c 10 | xxd"
}

##->

##<-- exit

function	exit_section()
{
	# 1: exit without args should return last $?
	same_out_and_return "cd /root"
	same_out_and_return "exit 123" "./minishell"
	same_out_and_return "exit 1 1"
	same_out_and_return "exit a 1"
	same_out_and_return "exit 1 a"
	same_out_and_return "exit 255"
	same_out_and_return "exit 256"
}

##-->

function	test_entry()
{
	echo_deep 0 3 "basic part"
	echo_deep 1 2 "Permission section"
	permission_exec
	echo_deep 1 2 "Cd section"
	cd_section
	echo_deep 1 2 "Parsing section"
	parsing_section
	echo_deep 1 2 "Pipe section"
	pipe_section
	echo_deep 0 3 "built-in"
	echo_deep 1 2 "exit"
	exit_section
}

#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#==#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#

#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#==#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#
#> MAIN


function	prepare_test()
{
	reset_deepfile
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
	test_entry
	clean_test
}

# main entry
main

#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#==#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#
