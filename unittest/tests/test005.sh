source "${BASH_SOURCE%/*}"/../setup.sh

# Test that mapping can be disabled by setting g:godiff_mapping to '' it in .vimrc

cat >>$vimtestdir/.vimrc <<EOL
	let g:godiff_mapping = ''
EOL

cat >>$vimtestdir/test.vim <<EOL

call append("$", "abcdefghijklmnopqrstuvw")
call append("$", "abcdefghijkLmnopqrstuvw")
execute "normal 2ggyyjgd"
$sleep_cmd

let m = getmatches()
call assert_equal(0, len(m))

EOL

HOME=$vimtestdir vim -X a.txt

popd > /dev/null
source "${BASH_SOURCE%/*}"/../tear_down.sh
exit 0

vim:tw=78:ts=4:ft=vim:
