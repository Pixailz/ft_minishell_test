# minishell_unit_test
test unitaire sur notre version de minishell

## TO TEST
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
