source "${BASH_SOURCE%/*}"/../setup.sh

# Test that mapping can be changed (here to F4) by setting it in .vimrc

cat >>$vimtestdir/.vimrc <<EOL
	let g:godiff_mapping = '<F4>'
EOL

cat >>$vimtestdir/test.vim <<EOL

call append("$", "abcdefghijklmnopqrstuvw")
call append("$", "abcdefghijkLmnopqrstuvw")
execute "normal 2ggyyj\<F4>"
$sleep_cmd

let m = getmatches()
call assert_equal(3, len(m))
call assert_equal([[3, 1, 11], 'GoDiffIdentic'], [m[0].pos1, m[0].group])
call assert_equal([[3, 12, 1], 'GoDiffChanged'], [m[1].pos1, m[1].group])
call assert_equal([[3, 13, 11], 'GoDiffIdentic'], [m[2].pos1, m[2].group])

EOL

HOME=$vimtestdir vim -X a.txt

popd > /dev/null
source "${BASH_SOURCE%/*}"/../tear_down.sh
exit 0

vim:tw=78:ts=4:ft=vim:
