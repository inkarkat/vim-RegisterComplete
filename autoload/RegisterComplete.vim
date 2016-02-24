" RegisterComplete.vim: Insert mode completion for register contents.
"
" DEPENDENCIES:
"   - CompleteHelper.vim autoload script
"   - CompleteHelper/Abbreviate.vim autoload script
"
" Copyright: (C) 2008-2014 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"	005	18-Dec-2014	Move away from deprecated
"				CompleteHelper#Abbreviate().
"	004	20-Aug-2012	Split off functions into separate autoload
"				script and documentation into dedicated help
"				file.
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
    return CompleteHelper#Abbreviate#Word(l:matchObj)
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

function! RegisterComplete#Expr()
    set completefunc=RegisterComplete#RegisterComplete
    return "\<C-x>\<C-u>"
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
