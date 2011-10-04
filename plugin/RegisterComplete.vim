" RegisterComplete.vim: Insert mode completion for register contents. 
"
" DESCRIPTION:
"   This plugin offers quick access to stored register contents, provided you
"   know a part of the contents, but not the register where it's stored. This is
"   especially useful for the named registers "1.."9 filled by changes and
"   deletions, where content is continuously shifted. 
"
" USAGE:
"								    *i_CTRL-X_@*
" <i_CTRL-X_@>		Find registers whose contents match the keyword before
"			the cursor. First, a match at the beginning is tried; if
"			that returns no results, it may match anywhere. 
" INSTALLATION:
" DEPENDENCIES:
" CONFIGURATION:
" INTEGRATION:
" LIMITATIONS:
" ASSUMPTIONS:
" KNOWN PROBLEMS:
" TODO:
"
" Copyright: (C) 2011 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'. 
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS 
"	002	07-Aug-2009	Using a map-expr instead of i_CTRL-O to set
"				'completefunc', as the temporary leave of insert
"				mode caused a later repeat via '.' to only
"				insert the completed fragment, not the entire
"				inserted text.  
"	001	13-Aug-2008	file creation

" Avoid installing twice or when in unsupported Vim version. 
if exists('g:loaded_RegisterComplete') || (v:version < 700)
    finish
endif
let g:loaded_RegisterComplete = 1

if ! exists('g:RegisterComplete_Registers')
    let g:RegisterComplete_Registers = '"0123456789-abcdefghijklmnopqrstuvwxyz*+/'
endif

function! s:GetMatchingRegisters( pattern )
    " Use default comparison operator here to honor the 'ignorecase' setting. 
    return filter(split(g:RegisterComplete_Registers, '\zs'), 'getreg(v:val) =~ a:pattern')
endfunction
function! s:RegisterToMatchObject( register )
    let l:matchObj = {}
    let l:matchObj.word = getreg(a:register)
    let l:matchObj.menu = '"' . a:register
    return CompleteHelper#Abbreviate(l:matchObj)
endfunction
function! RegisterComplete#FindMatches( pattern )
    return map(s:GetMatchingRegisters(a:pattern), 's:RegisterToMatchObject(v:val)')
endfunction
function! RegisterComplete#RegisterComplete( findstart, base )
    if a:findstart
	" Locate the start of the keyword. 
	let l:startCol = searchpos('\k*\%#', 'bn', line('.'))[1]
	if l:startCol == 0
	    let l:startCol = col('.')
	endif
	return l:startCol - 1 " Return byte index, not column. 
    else
	" Find matches starting with (after optional non-keyword characters) a:base. 
	let l:matches = RegisterComplete#FindMatches('^\%(\k\@!.\)*\V' . escape(a:base, '\'))
	if empty(l:matches)
	    " Find matches containing a:base. 
	    let l:matches = RegisterComplete#FindMatches('\V' . escape(a:base, '\'))
	endif
	return l:matches
    endif
endfunction

function! s:RegisterCompleteExpr()
    set completefunc=RegisterComplete#RegisterComplete
    return "\<C-x>\<C-u>"
endfunction
inoremap <expr> <Plug>(RegisterComplete) <SID>RegisterCompleteExpr()
if ! hasmapto('<Plug>(RegisterComplete)', 'i')
    imap <C-x>@ <Plug>(RegisterComplete)
endif

" vim: set sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
