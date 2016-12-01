source "${BASH_SOURCE%/*}"/../setup.sh

# Test odd visual range

cat >>$vimtestdir/.vimrc <<EOL
EOL

cat >>$vimtestdir/test.vim <<EOL

call append("$", "abcdeghijkl1234567abcdefgh")
call append("$", "ijkl1234mnopqrstuv")
call append("$", "")
call append("$", "abcdeghijkl54321abcdefgh")
call append("$", "ijkl54321mnopqrstuv")
execute "normal 2gg4lvj11ly3j"

execute "normal vj12lgd"
$sleep_cmd

let m = getmatches()
call assert_equal(6, len(m))
call assert_equal([[5, 5, 7] , 'GoDiffIdentic'], [m[0].pos1, m[0].group])
call assert_equal([[5, 12, 5], 'GoDiffChanged'], [m[1].pos1, m[1].group])
call assert_equal([[5, 17, 8], 'GoDiffIdentic'], [m[2].pos1, m[2].group])
call assert_equal([[6, 1, 4] , 'GoDiffIdentic'], [m[3].pos1, m[3].group])
call assert_equal([[6, 5, 5] , 'GoDiffChanged'], [m[4].pos1, m[4].group])
call assert_equal([[6, 10, 8], 'GoDiffIdentic'], [m[5].pos1, m[5].group])


execute "normal gdhvj14lgd"
$sleep_cmd

let m = getmatches()
call assert_equal(8, len(m))
call assert_equal([[5, 4, 1] , 'GoDiffChanged'], [m[0].pos1, m[0].group])
call assert_equal([[5, 5, 7] , 'GoDiffIdentic'], [m[1].pos1, m[1].group])
call assert_equal([[5, 12, 5], 'GoDiffChanged'], [m[2].pos1, m[2].group])
call assert_equal([[5, 17, 8], 'GoDiffIdentic'], [m[3].pos1, m[3].group])
call assert_equal([[6, 1, 4] , 'GoDiffIdentic'], [m[4].pos1, m[4].group])
call assert_equal([[6, 5, 5] , 'GoDiffChanged'], [m[5].pos1, m[5].group])
call assert_equal([[6, 10, 8], 'GoDiffIdentic'], [m[6].pos1, m[6].group])
call assert_equal([[6, 18, 1], 'GoDiffChanged'], [m[7].pos1, m[7].group])


execute "normal gd2lvj10lgd"
$sleep_cmd

let m = getmatches()
call assert_equal(8, len(m))
call assert_equal([[5, 6, 1] , 'GoDiffRemoved'], [m[0].pos1, m[0].group])
call assert_equal([[5, 7, 5] , 'GoDiffIdentic'], [m[1].pos1, m[1].group])
call assert_equal([[5, 12, 5], 'GoDiffChanged'], [m[2].pos1, m[2].group])
call assert_equal([[5, 17, 8], 'GoDiffIdentic'], [m[3].pos1, m[3].group])
call assert_equal([[6, 1, 4] , 'GoDiffIdentic'], [m[4].pos1, m[4].group])
call assert_equal([[6, 5, 5] , 'GoDiffChanged'], [m[5].pos1, m[5].group])
call assert_equal([[6, 10, 6], 'GoDiffIdentic'], [m[6].pos1, m[6].group])
call assert_equal([[6, 16, 1], 'GoDiffRemoved'], [m[7].pos1, m[7].group])

execute "normal hvj12lgd"
$sleep_cmd

let m = getmatches()
call assert_equal(6, len(m))
call assert_equal([[5, 5, 7] , 'GoDiffIdentic'], [m[0].pos1, m[0].group])
call assert_equal([[5, 12, 5], 'GoDiffChanged'], [m[1].pos1, m[1].group])
call assert_equal([[5, 17, 8], 'GoDiffIdentic'], [m[2].pos1, m[2].group])
call assert_equal([[6, 1, 4] , 'GoDiffIdentic'], [m[3].pos1, m[3].group])
call assert_equal([[6, 5, 5] , 'GoDiffChanged'], [m[4].pos1, m[4].group])
call assert_equal([[6, 10, 8], 'GoDiffIdentic'], [m[5].pos1, m[5].group])

EOL

HOME=$vimtestdir vim -X a.txt

popd > /dev/null
source "${BASH_SOURCE%/*}"/../tear_down.sh
exit 0

vim:tw=78:ts=4:ft=vim:
