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
"			The register contents is always inserted characterwise,
"			regardless of the register type. 
" INSTALLATION:
" DEPENDENCIES:
"   - CompleteHelper.vim autoload script. 
"
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
"	003	05-Oct-2011	ENH: Add number of lines to completion menu
"				text. 
"				Add references to following registers with the
"				same contents to the first match, like: 
"				"", "3, "e contents
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

    if stridx(l:matchObj.word, "\n") == -1
	" Incomplete line, characterwise insert. 
    else
	" Determine number of inserted lines. 
	let l:insertedLineNum = len(split(l:matchObj.word[0:-2], "\n", 1))
	let l:matchObj.menu .= printf(' (%d line%s)', l:insertedLineNum, (l:insertedLineNum == 1 ? '' : 's'))
    endif
    return CompleteHelper#Abbreviate(l:matchObj)
endfunction
function! RegisterComplete#FindMatches( pattern )
    let l:matches = map(s:GetMatchingRegisters(a:pattern), 's:RegisterToMatchObject(v:val)')

    " Add references to following registers with the same contents to the first
    " match, and remove the duplicate match; because match.dup isn't set, Vim
    " won't show the duplicates, anyway. 
    let l:ii = 0
    while l:ii < len(l:matches)
	let l:jj = l:ii + 1
	while l:jj < len(l:matches)
	    if l:matches[l:ii].word ==# l:matches[l:jj].word 
		let l:matches[l:ii].menu = l:matches[l:ii].menu[0:1] . ', ' . l:matches[l:jj].menu[0:1] . l:matches[l:ii].menu[2:]
		call remove(l:matches, l:jj)
	    endif
	    let l:jj += 1
	endwhile
	let l:ii += 1
    endwhile

    return l:matches
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
