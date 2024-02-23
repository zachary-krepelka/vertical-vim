" FILENAME: vertical.vim
" AUTHOR: Zachary Krepelka
" DATE: Thursday, February 22nd, 2024
" ABOUT: Vertical motions for the Vim text editor
" ORIGIN: https://github.com/zachary-krepelka/vertical-vim.git
" UPDATED: Friday, February 23rd, 2024 at 6:05 PM

" Variables  {{{1

if exists('g:loaded_vertical_vim')

	finish

endif

let g:loaded_vertical_vim = 1

let s:pivot = 0
let s:prev_direction = 0
let s:save = []

" Functions {{{1

function! s:find(target, clusivity, direction, visual, update)

	if a:update
		let s:save = [a:target, a:clusivity, a:direction, a:visual, 0]
	endif

	let flags = a:direction ? 'b' : ''

	let nudge = !a:update && a:clusivity && !s:pivot ? 1 : 0

	" Bug here. Need to account for previous visual selection anchor.

	if a:visual
		let start = [line('.'), virtcol('.')]
	endif

	for i in range(v:count1 + l:nudge)
		call search(s:match_in_cusor_column(a:target), l:flags)
	endfor

	if a:clusivity
		exe 'norm' (a:direction ? 'j' : 'k')
	endif

	if a:visual
		let end = [line('.'), virtcol('.')]
		call call('s:block', l:start + l:end)
	endif

endfunction

function! s:repeat(curr_direction)

	let s:pivot = xor(s:prev_direction, a:curr_direction)

	let s:prev_direction = a:curr_direction

	let l:args = copy(s:save)

	if a:curr_direction
		let l:args[2] = !l:args[2]
	endif

	call call('s:find', l:args)

endfunction

function! s:match_in_cusor_column(char)

	" This function returns a regular expression that matches the specified
	" character only within the cursor's current column.

	return '\%' .. virtcol('.') .. 'v' .. s:char_to_regex(a:char)

	" See :help /\%v

endfunction

function! s:char_to_regex(char)

	return '[' .. substitute(a:char, '[\\^]', {m -> '\' .. m[0]}, '') .. ']'

	" It's easier to wrap the character in a character class since there are
	" fewer metacharacters to escape. As far as I know, this should match
	" for any provided ascii character.

endfunction

function s:block(x1, y1, x2, y2)

	let p1 = a:x1 .. 'G' .. a:y1 .. '|'

	let p2 = a:x2 .. 'G' .. a:y2 .. '|'

	exe 'norm' l:p1 .. "\<C-Q>" .. l:p2

endfunction

" Mappings {{{1

noremap <silent> <Space>; :<C-U>call <SID>repeat(0)<CR>
noremap <silent> <Space>, :<C-U>call <SID>repeat(1)<CR>

nnoremap <silent> <Space>f :<C-U>call <SID>find(getcharstr(), 0, 0, 0, 1)<CR>
nnoremap <silent> <Space>F :<C-U>call <SID>find(getcharstr(), 0, 1, 0, 1)<CR>
nnoremap <silent> <Space>t :<C-U>call <SID>find(getcharstr(), 1, 0, 0, 1)<CR>
nnoremap <silent> <Space>T :<C-U>call <SID>find(getcharstr(), 1, 1, 0, 1)<CR>

onoremap <silent> <Space>f :<C-U>call <SID>find(getcharstr(), 0, 0, 1, 1)<CR>
onoremap <silent> <Space>F :<C-U>call <SID>find(getcharstr(), 0, 1, 1, 1)<CR>
onoremap <silent> <Space>t :<C-U>call <SID>find(getcharstr(), 1, 0, 1, 1)<CR>
onoremap <silent> <Space>T :<C-U>call <SID>find(getcharstr(), 1, 1, 1, 1)<CR>

vnoremap <silent> <Space>f :<C-U>call <SID>find(getcharstr(), 0, 0, 1, 1)<CR>
vnoremap <silent> <Space>F :<C-U>call <SID>find(getcharstr(), 0, 1, 1, 1)<CR>
vnoremap <silent> <Space>t :<C-U>call <SID>find(getcharstr(), 1, 0, 1, 1)<CR>
vnoremap <silent> <Space>T :<C-U>call <SID>find(getcharstr(), 1, 1, 1, 1)<CR>
