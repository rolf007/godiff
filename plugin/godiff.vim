" Vim GoDiff 1.3 December 2016
" A plugin to quickly compare two sections of text with colors
" Installation:
"     Use Pathogen or Vundle
"     (or just copy the files into your vim dirs 'plugin', 'auotoload', 'doc' etc)
" Author:
"   Rolf Asmund

let s:active = 0
let s:matches = []

if !exists('g:godiff_mapping')
	let g:godiff_mapping = 'gd'
endif

execute "vnoremap <silent> " . g:godiff_mapping . " :<c-u>call <SID>GoDiffVisual(v:register)<CR>"
execute "nnoremap <silent> " . g:godiff_mapping . " :<c-u>call <SID>GoDiffNormal()<CR>"

function! s:Diff_LongestMatchingSubsection(a, a0, a1, b, b0, b1)
	let ret = [a:a0, a:b0, 0]
	let runs = {}
	for i in range(a:a0, a:a1-1)
		let new_runs = {}
		for j in range(a:b0, a:b1-1)
			if a:a[i] == a:b[j]
				let k = get(runs, j-1, 0) + 1
				let new_runs[j] = k
				if k > ret[2]
					let ret = [i-k+1,j-k+1,k]
				endif
			endif
		endfor
		let runs = new_runs
	endfor
	return ret
endfunction

function! s:GoDiffVisual(register)
" simple text-diff algorithm inspired by:
" http://pynash.org/2013/02/26/diff-in-50-lines.html
	if s:active
		call s:GoDiffStop()
	endif
	"threshold: how small sections should be considered a match?
	let threshold = 5
	" a = content of yank-/put-register (reg-0)
	" b = content of visually selected range
	let a=getreg(a:register)
	try
		let save_reg_0 = @0
		silent normal! gvy
	finally
		let b=@0
		let @0 = save_reg_0
	endtry
	" now compare the two strings a and b

	" c is result of comparison and determines the coloring of b
	" '0' = no match
	" '1' = left hand edge of match
	" '2' = match
	" '3' = right hand edge of match
	let c = repeat('0', len(b))
	" opens is a list of section pairs to be investigated.
	" initially, both strings a and b are entirely uninvestigated.
	let opens = [[0, len(a), 0, len(b)]]
	while len(opens)
		" take one section pair out of the list, and find the longest matching
		" subsection
		let a0 = opens[-1][0]
		let a1 = opens[-1][1]
		let b0 = opens[-1][2]
		let b1 = opens[-1][3]
		let opens = opens[:-2]
		let longest = <SID>Diff_LongestMatchingSubsection(a, a0, a1, b, b0, b1)
		if longest[2] > threshold
			" mark in c, how it matched
			let beg = (longest[0] == 0 && longest[1] == 0) ? '2' : '1'
			let end = (longest[0]+longest[2] == len(a) && longest[1]+longest[2] == len(b)) ? '2' : '3'
			let start = (longest[1] == 0) ? '' : c[0:longest[1]-1]
			let c = start . beg . repeat('2', longest[2]-2) . end . c[longest[1] + longest[2]:-1]
			" append sections on both sides of the match to the list of
			" sections to be investigated
			if longest[0] - a0 > threshold && longest[1] - b0 > threshold
				call add(opens, [a0, longest[0], b0, longest[1]])
			endif
			if a1 - (longest[0] + longest[2]) > threshold && b1 - (longest[1] + longest[2]) > threshold
				call add(opens, [longest[0] + longest[2], a1, longest[1] + longest[2], b1])
			endif
		endif
	endwhile
	" fix-up edge matches 
	for i in range(0, len(c)-2)
		if c[i] == '3' && c[i+1] == '0' && b[i+1] != "\x0a"
			let c = c[:i-1] . '2' . c[i+1:]
		endif
		if c[i] == '0' && c[i+1] == '1' && b[i] != "\x0a"
			let c = c[:i] . '2' . c[i+2:]
		endif
	endfor
	" now apply the coloring
	" get selections start-line and start-column in l0 and c0
	let l0 = line("'<")
	let c0 = col("'<")
	" we colorize one char at a time
	let i = 0
	while b[i] == "\x0a"
		let c0 = 1
		let l0 = l0 + 1
		let i = i + 1
	endwhile
	hi GoDiffChanged term=reverse cterm=bold ctermfg=White ctermbg=Red guifg=White guibg=Red
	hi GoDiffRemoved term=reverse cterm=bold ctermfg=White ctermbg=Blue guifg=White guibg=Blue
	hi GoDiffIdentic term=reverse cterm=bold ctermfg=White ctermbg=Green guifg=White guibg=Green
	let l = 0
	let oc0 = c0
	let ol0 = l0
	while i < len(c)
		let col = c[i] == '0' ? 'GoDiffChanged' : (c[i] == '2' ? 'GoDiffIdentic': 'GoDiffRemoved')
		if l != 0 && (ol0 != l0 || ocol != col)
			call add(s:matches, matchaddpos(ocol, [[ol0, oc0-l+1, l]]))
			let l = 0
		endif
		let l = l+1
		let oc0 = c0
		let ol0 = l0
		let ocol = col
		let c0 = c0 + 1
		let i = i + 1
		while b[i] == "\x0a"
			let c0 = 1
			let l0 = l0 + 1
			let i = i + 1
		endwhile
	endwhile
	call add(s:matches, matchaddpos(ocol, [[ol0, oc0-l+1, l]]))
	let s:active = 1
endfunction

function! s:GoDiffStop()
	for m in s:matches
		call matchdelete(m)
	endfor
	let s:matches = []
	let s:active = 0
endfunction

function! s:GoDiffNormal()
	if s:active
		" if active, then stop and return to normal
		call s:GoDiffStop()
	else
		" if not active, do a linewise diff
		let register = v:register
		if v:count > 1
			silent execute "normal! V" . (v:count - 1) . "j\<esc>"
		else
			silent execute "normal! V\<esc>"
		endif
		call s:GoDiffVisual(register)
	endif
endfunction
