" Usage: Unite qf	"unite quickfix result
" Usage: Unite qf:enc=utf-8 "iconv(getqflist(),enc,&enc)
" Usage: Unite qf:enc=utf-8:ex= "show prompt for ex-command (ex. grep, vimgrep, make)
" Usage: Unite qf:enc=utf-8:ex=grep\ vim\ ~/vimfiles/* "specify ex-command

let s:save_cpo = &cpo
set cpo&vim

function! unite#sources#qf#define()"{{{
  return s:source
endfunction"}}}

let s:source = {
      \ 'name': 'qf'
      \ }

function! s:source.complete(args, context, arglead, cmdline, cursorpos)
  let arglead = matchstr(a:arglead, '[:^]\zs.\+$')
  let options=['enc=', 'ex=']
  return filter(options, 'stridx(v:val, arglead)>=0')
endfunction

function! s:source.gather_candidates(args, context) "{{{
  let l:enc = ''
  for l:arg in a:args
    " 		let l:match = matchlist(l:arg, '\(\k\+\)\s*=\s*\([a-zA-Z0-9.!?_ /\\-*]*\)')
    let l:match = matchlist(l:arg, '\(\k\+\)\s*=\s*\(.*\)')
    if len(l:match) > 0
      execute 'let l:' . l:match[1] . " = \'" . l:match[2] . "\'"
    endif
  endfor
  if exists('l:ex')
    execute 'new +'.substitute(empty(l:ex)?input('Ex-command: '):l:ex, ' ', '\\ ', 'g')
    bdelete
  endif
  return map(getqflist(), '{
        \ "word": bufname(v:val.bufnr) . "|" . v:val.lnum . "| " .
        \	(empty(l:enc) ? v:val.text : iconv(v:val.text,l:enc,&encoding)),
        \ "source": "qf",
        \ "kind": "jump_list",
        \ "action__path": bufname(v:val.bufnr),
        \ "action__line": v:val.lnum,
        \ "action__pattern": v:val.pattern,
        \ "is_multiline" : 1,
        \ }')
endfunction "}}}

let &cpo = s:save_cpo
unlet s:save_cpo

" vim:set foldmethod=marker:
