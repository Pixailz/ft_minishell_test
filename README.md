# minishell_unit_test
test unitaire sur notre version de minishell

## TO TEST
- `ca't' -e file`
- `ca't -e' "file.txt"`
- `cat -e "fi"le`
- `cat -e "fi"'le'`
- `sleep 3 | cat file`
- `echo pass | grep 'ass'`
- `echo test1 | echo test2`
- `echoo pass | cat file`
- `cat | cat -e`
- `cat | ls | cat`
- `ping -c4 google.com | cat -e`
- `grep -oE "a|b" | cat -e`
- `cat -e | grep -o "ass"`
- `cat | cat -e | cat -e`
- `echo pass | grep -o ass | cat -e`
- `echo pass | cat1 file | cat2 file`
- `< file cat | < file cat`
- `< file cat > outfile | < file cat`
- `< file cat > outfile1 | < file cat >> outfile2`
- `< file cat > file1 | < file cat -e > file2 | < file cat -e > file3 | < file cat -e >> file4`
- `< file cat > file1 | cat >> file2`
- `< file cat -e > file1 | < filee grep a1 > file2`
- `< file cat -e > file1 | < file grep a1 > file2`
	- with file2 chmod 000
- `echo "test > test"`
- `ech$O test`
- `echo pass1 > file pass2`
- `echo pass >>file1 | echo pass >> file2`

### wildcard
1. `touch cat; echo pass1 > echo; echo pass2 > pass`
2. `*`

should output
`pass1 pass2`

1. echo "ft*fd*.c"
