"=============================================================================
" FILE: sls.vim
"
" original is vimshell's ls.vim
"
" License: MIT license  {{{
"     Permission is hereby granted, free of charge, to any person obtaining
"     a copy of this software and associated documentation files (the
"     "Software"), to deal in the Software without restriction, including
"     without limitation the rights to use, copy, modify, merge, publish,
"     distribute, sublicense, and/or sell copies of the Software, and to
"     permit persons to whom the Software is furnished to do so, subject to
"     the following conditions:
"
"     The above copyright notice and this permission notice shall be included
"     in all copies or substantial portions of the Software.
"
"     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"     OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"     MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"     IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"     CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
"     TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"     SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}
"=============================================================================

let s:command = {
      \ 'name' : 'sls',
      \ 'kind' : 'internal',
      \ 'description' : 'sls [{argument}...]',
      \}

function! vimshell#commands#sls#define()
  return s:command
endfunction

function! s:command.execute(args, context)
  let files = map(split(glob("*"), ''), 
                 \'isdirectory(v:val) ? v:val . "/" : v:val')

  if len(a:args) != 0 && a:args[0] == '-la'
    call s:la(files)
  else
    call s:ls(files)
  endif
  execute "normal G"
endfunction

function! s:ls(files)
  let files = a:files
  let max = max(map(copy(files), 'strdisplaywidth(v:val)')) + 2
  let ret = join(files, '  ')
  if strdisplaywidth(ret) < winwidth(0)
    call append(line("."), ret)
    return
  else
    let ret = ''
  endif

  let list = []

  for f in files
    let f = s:ljust(f, max)
    if strdisplaywidth(ret) + strdisplaywidth(f) > winwidth(0)
      call add(list, s:trim_tail(ret))
      let ret = f
    else
      let ret .= f
    endif
  endfor
  call add(list, s:trim_tail(ret))
  call append(line("."), list)
endfunction

function! s:la(files)
  let files = a:files
  let max = max(map(copy(files), 'strdisplaywidth(v:val)')) + 2
  let list = []
  for f in files
    let line = s:ljust(f, max) . strftime("%Y.%m.%d %T", getftime(f))
    if !isdirectory(f)
      let line .=  '  ' . getfsize(f)
    endif
    call add(list, line)
  endfor
  call append(line("."), list)
endfunction

function! s:ljust(s, max)
  let s = a:s
  while strdisplaywidth(s) < a:max
    let s .= ' '
  endwhile
  return s
endfunction

function! s:trim_tail(msg)
  return substitute(a:msg, '\s\+$', '', '')
endfunction

