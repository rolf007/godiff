vimtestdir=$(mktemp -d)
mkdir $vimtestdir/.vim
cp -r ~/.vim/bundle/godiff/* $vimtestdir/.vim

succes_cmd=${succes_cmd:-"echom \"unittest succeded\""}
sleep_cmd=${sleep_cmd:-"redraw | sleep 2000m"}

cat >$vimtestdir/.vimrc <<EOL
syntax on
set laststatus=2
set errorformat=%f\ line\ %l:\ %m
nnoremap q :qall!<CR>
set tabstop=4

call timer_start(500, {-> <SID>Test()})

function! s:Test()
	source test.vim
	cgetexpr v:errors
	if len(v:errors)
		copen
	else
		$succes_cmd
	endif
endfunction
EOL

pushd $vimtestdir > /dev/null

return
vim:tw=78:ts=4:ft=vim:
