source "${BASH_SOURCE%/*}"/../setup.sh

cat >>$vimtestdir/.vimrc <<EOL
EOL

cat >>$vimtestdir/test.vim <<EOL

call append("$", "static inline struct shmid_kernel *shm_obtain_object(struct ipc_namespace *ns, int id)")
call append("$", "{")
call append("$", "        struct kern_ipc_perm *ipcp = ipc_obtain_object_idr(&shm_ids(ns), id);")
call append("$", "")
call append("$", "        if (IS_ERR(ipcp))")
call append("$", "                return ERR_CAST(ipcp);")
call append("$", "")
call append("$", "        return container_of(ipcp, struct shmid_kernel, shm_perm);")
call append("$", "}")
call append("$", "")
call append("$", "static inline struct shmid_kernel *shm_obtain_object_check(struct ipc_namespace *ns, int id)")
call append("$", "{")
call append("$", "        struct kern_ipc_perm *ipcp = ipc_obtain_object_check(&shm_ids(ns), id);")
call append("$", "")
call append("$", "        if (IS_ERR(ipcp))")
call append("$", "                return ERR_CAST(ipcp);")
call append("$", "")
call append("$", "        return container_of(ipcp, struct shmid_kernel, shm_perm);")
call append("$", "}")
execute "normal 2gg9yy10j9gd"
$sleep_cmd

let m = getmatches()
call assert_equal(11, len(m))
call assert_equal([[12, 1, 52] , 'GoDiffIdentic'], [m[0].pos1, m[0].group])
call assert_equal([[12, 53, 6] , 'GoDiffChanged'], [m[1].pos1, m[1].group])
call assert_equal([[12, 59, 34], 'GoDiffIdentic'], [m[2].pos1, m[2].group])
call assert_equal([[13, 1, 1]  , 'GoDiffIdentic'], [m[3].pos1, m[3].group])
call assert_equal([[14, 1, 55] , 'GoDiffIdentic'], [m[4].pos1, m[4].group])
call assert_equal([[14, 56, 5] , 'GoDiffChanged'], [m[5].pos1, m[5].group])
call assert_equal([[14, 61, 19], 'GoDiffIdentic'], [m[6].pos1, m[6].group])
call assert_equal([[16, 1, 25] , 'GoDiffIdentic'], [m[7].pos1, m[7].group])
call assert_equal([[17, 1, 38] , 'GoDiffIdentic'], [m[8].pos1, m[8].group])
call assert_equal([[19, 1, 65] , 'GoDiffIdentic'], [m[9].pos1, m[9].group])
call assert_equal([[20, 1, 1]  , 'GoDiffIdentic'], [m[10].pos1, m[10].group])

execute "normal gd9yy10k9gd"
$sleep_cmd
let m = getmatches()
call assert_equal(11, len(m))
call assert_equal([[2, 1, 51] , 'GoDiffIdentic'], [m[0].pos1, m[0].group])
call assert_equal([[2, 52, 2] , 'GoDiffRemoved'], [m[1].pos1, m[1].group])
call assert_equal([[2, 54, 33], 'GoDiffIdentic'], [m[2].pos1, m[2].group])
call assert_equal([[3, 1, 1]  , 'GoDiffIdentic'], [m[3].pos1, m[3].group])
call assert_equal([[4, 1, 55] , 'GoDiffIdentic'], [m[4].pos1, m[4].group])
call assert_equal([[4, 56, 3] , 'GoDiffChanged'], [m[5].pos1, m[5].group])
call assert_equal([[4, 59, 19], 'GoDiffIdentic'], [m[6].pos1, m[6].group])
call assert_equal([[6, 1, 25] , 'GoDiffIdentic'], [m[7].pos1, m[7].group])
call assert_equal([[7, 1, 38] , 'GoDiffIdentic'], [m[8].pos1, m[8].group])
call assert_equal([[9, 1, 65] , 'GoDiffIdentic'], [m[9].pos1, m[9].group])
call assert_equal([[10, 1, 1]  , 'GoDiffIdentic'], [m[10].pos1, m[10].group])

EOL

HOME=$vimtestdir vim -X a.txt

popd > /dev/null
source "${BASH_SOURCE%/*}"/../tear_down.sh
exit 0

vim:tw=78:ts=4:ft=vim:
