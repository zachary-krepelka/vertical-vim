" FILENAME: vertical.vim
" AUTHOR: Zachary Krepelka
" DATE: Thursday, February 22nd, 2024
" ABOUT: Vertical motions for the Vim text editor
" ORIGIN: https://github.com/zachary-krepelka/vertical-vim.git
" UPDATED: Friday, February 28th, 2025 at 11:55 PM

" Variables  {{{1

if exists('g:loaded_vertical_vim')

	finish

endif

let g:loaded_vertical_vim = 1

let s:leader = get(g:, 'vertical_vim_map_prefix', 'z')
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

function! s:repeat(curr_direction)

	if empty(s:save)
		call s:notify_misuse()
		return
	end

	let s:pivot = xor(s:prev_direction, a:curr_direction)

	let s:prev_direction = a:curr_direction

	let l:args = copy(s:save)

	if a:curr_direction
		let l:args[2] = !l:args[2]
	endif

	call call('s:find', l:args)

endfunction

function! s:notify_misuse()

	" This function plays an audible beep. See :help echoerr

	exe "normal \<Esc>"

endfunction

" Mappings {{{1

let s:map_data =
\ {
\ 	'n': {
\ 		'f' : [0, 0, 0],
\ 		't' : [1, 0, 0],
\ 		'F' : [0, 1, 0],
\ 		'T' : [1, 1, 0]
\ 	},
\ 	'o': {
\ 		'f' : [0, 0, 1],
\ 		't' : [1, 0, 1],
\ 		'F' : [0, 1, 1],
\ 		'T' : [1, 1, 1]
\ 	},
\ 	'v': {
\ 		'f' : [0, 0, 1],
\ 		't' : [1, 0, 1],
\ 		'F' : [0, 1, 1],
\ 		'T' : [1, 1, 1]
\ 	}
\ }

for [mode, motion_data] in items(s:map_data)
	for [motion, spec] in items(motion_data)
		exe mode .. "noremap <silent>" s:leader .. motion
		\ ":<C-U>call call('<SID>find',[getcharstr()]+"
		\ .. string(spec+[1]) .. ")<CR>"
	endfor
endfor

noremap <silent> <Space>; :<C-U>call <SID>repeat(0)<CR>
noremap <silent> <Space>, :<C-U>call <SID>repeat(1)<CR>

" Menus {{{1

if has("gui_running") && has("menu") && &go =~# 'm'

	amenu <silent> &Plugin.Vertical\ Vim.&Help :tab help vertical-vim<CR>

endif
