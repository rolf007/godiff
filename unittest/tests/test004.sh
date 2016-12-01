source "${BASH_SOURCE%/*}"/../setup.sh

# Test v:register

cat >>$vimtestdir/.vimrc <<EOL
EOL

cat >>$vimtestdir/test.vim <<EOL

call append("$", "Roses are red")
call append("$", "Violets are blue")
call append("$", "Nothing compares to you")

" first copy 'Roses are red to register a
execute "normal 2gg\"ayy"
" then copy 'Nothing compares' to default register
execute "normal 4ggyy"
" then compare register a to 'Violets are blue'
execute "normal 3gg\"agd"
" finally paste default register to check that it hasn't been modified
execute "normal p"
$sleep_cmd

let m = getmatches()
call assert_equal(3, len(m))
call assert_equal([[3, 1, 6], 'GoDiffChanged'], [m[0].pos1, m[0].group])                                                            
call assert_equal([[3, 7, 6], 'GoDiffIdentic'], [m[1].pos1, m[1].group])
call assert_equal([[3, 13, 4], 'GoDiffChanged'], [m[2].pos1, m[2].group])
call assert_equal(['','Roses are red', 'Violets are blue', 'Nothing compares to you', 'Nothing compares to you'], getline(1, '$'))

" Now do the same with visual
" compare register a to 'Violets are blue'
execute "normal 3ggV\"agd"
" again paste default register to check that it hasn't been modified
execute "normal p"
$sleep_cmd

let m = getmatches()
call assert_equal(3, len(m))
call assert_equal([[3, 1, 6], 'GoDiffChanged'], [m[0].pos1, m[0].group])                                                            
call assert_equal([[3, 7, 6], 'GoDiffIdentic'], [m[1].pos1, m[1].group])
call assert_equal([[3, 13, 4], 'GoDiffChanged'], [m[2].pos1, m[2].group])
call assert_equal(['','Roses are red', 'Violets are blue', 'Nothing compares to you', 'Nothing compares to you', 'Nothing compares to you'], getline(1, '$'))

EOL

HOME=$vimtestdir vim -X a.txt

popd > /dev/null
source "${BASH_SOURCE%/*}"/../tear_down.sh
exit 0

vim:tw=78:ts=4:ft=vim:
