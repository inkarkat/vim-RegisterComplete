" RegisterComplete.vim: Insert mode completion for register contents.
"
" DEPENDENCIES:
"   - Requires Vim 7.0 or higher.
"   - RegisterComplete.vim autoload script
"
" Copyright: (C) 2008-2012 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
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

" Avoid installing twice or when in unsupported Vim version.
if exists('g:loaded_RegisterComplete') || (v:version < 700)
    finish
endif
let g:loaded_RegisterComplete = 1

"- configuration ---------------------------------------------------------------

if ! exists('g:RegisterComplete_Registers')
    let g:RegisterComplete_Registers = '"0123456789-abcdefghijklmnopqrstuvwxyz*+/'
endif


"- mappings --------------------------------------------------------------------

inoremap <silent> <expr> <Plug>(RegisterComplete) RegisterComplete#Expr()
if ! hasmapto('<Plug>(RegisterComplete)', 'i')
    imap <C-x>@ <Plug>(RegisterComplete)
endif

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
