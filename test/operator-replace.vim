let s:suite = themis#suite('operator-sandwich: replace:')

function! s:suite.before() abort  "{{{
  nmap sr <Plug>(operator-sandwich-replace)
  xmap sr <Plug>(operator-sandwich-replace)
endfunction
"}}}
function! s:suite.before_each() abort "{{{
  %delete
  set filetype=
  set whichwrap&
  set autoindent&
  silent! mapc!
  silent! ounmap ii
  silent! xunmap i{
  silent! xunmap a{
  call operator#sandwich#set_default()
  unlet! g:sandwich#recipes
  unlet! g:operator#sandwich#recipes
endfunction
"}}}
function! s:suite.after() abort "{{{
  call s:suite.before_each()
endfunction
"}}}

" Input
function! s:suite.input() abort "{{{
  let g:sandwich#recipes = []
  let g:operator#sandwich#recipes = [
        \   {'buns': ['(', ')']},
        \   {'buns': ['[', ']']},
        \ ]

  " #1
  call setline('.', '[foo]')
  normal 0sra[(
  call g:assert.equals(getline('.'), '(foo)', 'failed at #1')

  let g:sandwich#recipes = []
  let g:operator#sandwich#recipes = [
        \   {'buns': ['(', ')'], 'input': ['a', 'b']},
        \   {'buns': ['[', ']']},
        \ ]

  " #2
  call setline('.', '[foo]')
  normal 0sra[a
  call g:assert.equals(getline('.'), '(foo)', 'failed at #2')

  " #3
  call setline('.', '[foo]')
  normal 0sra[b
  call g:assert.equals(getline('.'), '(foo)', 'failed at #3')

  " #4
  call setline('.', '[foo]')
  normal 0sra[(
  call g:assert.equals(getline('.'), '(foo(', 'failed at #4')
endfunction
"}}}

" Filter
function! s:suite.filter_filetype() abort "{{{
  let g:sandwich#recipes = []
  let g:operator#sandwich#recipes = [
        \   {'buns': ['(', ')']},
        \   {'buns': ['[', ']'], 'filetype': ['vim'], 'input': ['(', ')']},
        \   {'buns': ['{', '}'], 'filetype': ['all']},
        \ ]

  " #5
  call setline('.', '{foo}')
  normal 0sra{(
  call g:assert.equals(getline('.'), '(foo)', 'failed at #5')

  " #6
  call setline('.', '(foo)')
  normal 0sra({
  call g:assert.equals(getline('.'), '{foo}', 'failed at #6')

  set filetype=vim

  " #7
  call setline('.', '{foo}')
  normal 0sra{(
  call g:assert.equals(getline('.'), '[foo]', 'failed at #7')

  " #8
  call setline('.', '(foo)')
  normal 0sra({
  call g:assert.equals(getline('.'), '{foo}', 'failed at #8')
endfunction
"}}}
function! s:suite.filter_kind() abort "{{{
  let g:sandwich#recipes = []
  let g:operator#sandwich#recipes = [
        \   {'buns': ['[', ']']},
        \   {'buns': ['(', ')']},
        \ ]

  " #9
  call setline('.', '[foo]')
  normal 0sra[(
  call g:assert.equals(getline('.'), '(foo)', 'failed at #9')

  let g:operator#sandwich#recipes = [
        \   {'buns': ['(', ')']},
        \   {'buns': ['{', '}'], 'input': ['[']},
        \   {'buns': ['[', ']'], 'kind': ['add']},
        \ ]

  " #10
  call setline('.', '(foo)')
  normal 0sra([
  call g:assert.equals(getline('.'), '{foo}', 'failed at #10')

  let g:operator#sandwich#recipes = [
        \   {'buns': ['(', ')']},
        \   {'buns': ['{', '}'], 'input': ['[']},
        \   {'buns': ['[', ']'], 'kind': ['delete']},
        \ ]

  " #11
  call setline('.', '(foo)')
  normal 0sra([
  call g:assert.equals(getline('.'), '{foo}', 'failed at #11')

  let g:operator#sandwich#recipes = [
        \   {'buns': ['(', ')']},
        \   {'buns': ['{', '}'], 'input': ['[']},
        \   {'buns': ['[', ']'], 'kind': ['replace']},
        \ ]

  " #12
  call setline('.', '(foo)')
  normal 0sra([
  call g:assert.equals(getline('.'), '[foo]', 'failed at #12')

  let g:operator#sandwich#recipes = [
        \   {'buns': ['(', ')']},
        \   {'buns': ['{', '}'], 'input': ['[']},
        \   {'buns': ['[', ']'], 'kind': ['operator']},
        \ ]

  " #13
  call setline('.', '(foo)')
  normal 0sra([
  call g:assert.equals(getline('.'), '[foo]', 'failed at #13')

  let g:operator#sandwich#recipes = [
        \   {'buns': ['(', ')']},
        \   {'buns': ['{', '}'], 'input': ['[']},
        \   {'buns': ['[', ']'], 'kind': ['all']},
        \ ]

  " #14
  call setline('.', '(foo)')
  normal 0sra([
  call g:assert.equals(getline('.'), '[foo]', 'failed at #14')
endfunction
"}}}
function! s:suite.filter_motionwise() abort "{{{
  let g:sandwich#recipes = []
  let g:operator#sandwich#recipes = [
        \   {'buns': ['(', ')']},
        \   {'buns': ['{', '}']},
        \   {'buns': ['[', ']'], 'input': ['{']},
        \ ]
  call operator#sandwich#set('add', 'line', 'linewise', 0)

  " #15
  call setline('.', '(foo)')
  normal 0sra({
  call g:assert.equals(getline('.'), '[foo]', 'failed at #15')

  " #16
  call setline('.', '(foo)')
  normal 0srVl{
  call g:assert.equals(getline('.'), '[foo]', 'failed at #16')

  " #17
  call setline('.', '(foo)')
  execute "normal 0sr\<C-v>a({"
  call g:assert.equals(getline('.'), '[foo]', 'failed at #17')

  let g:operator#sandwich#recipes = [
        \   {'buns': ['(', ')']},
        \   {'buns': ['{', '}']},
        \   {'buns': ['[', ']'], 'motionwise': ['all'], 'input': ['{']},
        \ ]

  " #18
  call setline('.', '(foo)')
  normal 0sra({
  call g:assert.equals(getline('.'), '[foo]', 'failed at #18')

  " #19
  call setline('.', '(foo)')
  normal 0srVl{
  call g:assert.equals(getline('.'), '[foo]', 'failed at #19')

  " #20
  call setline('.', '(foo)')
  execute "normal 0sr\<C-v>a({"
  call g:assert.equals(getline('.'), '[foo]', 'failed at #20')

  let g:operator#sandwich#recipes = [
        \   {'buns': ['(', ')']},
        \   {'buns': ['{', '}']},
        \   {'buns': ['[', ']'], 'motionwise': ['char'], 'input': ['{']},
        \ ]

  " #21
  call setline('.', '(foo)')
  normal 0sra({
  call g:assert.equals(getline('.'), '[foo]', 'failed at #21')

  " #22
  call setline('.', '(foo)')
  normal 0srVl{
  call g:assert.equals(getline('.'), '{foo}', 'failed at #22')

  " #23
  call setline('.', '(foo)')
  execute "normal 0sr\<C-v>a({"
  call g:assert.equals(getline('.'), '{foo}', 'failed at #23')

  let g:operator#sandwich#recipes = [
        \   {'buns': ['(', ')']},
        \   {'buns': ['{', '}']},
        \   {'buns': ['[', ']'], 'motionwise': ['line'], 'input': ['{']},
        \ ]

  " #24
  call setline('.', '(foo)')
  normal 0sra({
  call g:assert.equals(getline('.'), '{foo}', 'failed at #24')

  " #25
  call setline('.', '(foo)')
  normal 0srVl{
  call g:assert.equals(getline('.'), '[foo]', 'failed at #25')

  " #26
  call setline('.', '(foo)')
  execute "normal 0sr\<C-v>a({"
  call g:assert.equals(getline('.'), '{foo}', 'failed at #26')

  let g:operator#sandwich#recipes = [
        \   {'buns': ['(', ')']},
        \   {'buns': ['{', '}']},
        \   {'buns': ['[', ']'], 'motionwise': ['block'], 'input': ['{']},
        \ ]

  " #27
  call setline('.', '(foo)')
  normal 0sra({
  call g:assert.equals(getline('.'), '{foo}', 'failed at #27')

  " #28
  call setline('.', '(foo)')
  normal 0srVl{
  call g:assert.equals(getline('.'), '{foo}', 'failed at #28')

  " #29
  call setline('.', '(foo)')
  execute "normal 0sr\<C-v>a({"
  call g:assert.equals(getline('.'), '[foo]', 'failed at #29')
endfunction
"}}}
function! s:suite.filter_mode() abort "{{{
  let g:sandwich#recipes = []
  let g:operator#sandwich#recipes = [
        \   {'buns': ['(', ')']},
        \   {'buns': ['{', '}']},
        \   {'buns': ['[', ']'], 'input': ['{']},
        \ ]

  " #30
  call setline('.', '(foo)')
  normal 0sra({
  call g:assert.equals(getline('.'), '[foo]', 'failed at #30')

  " #31
  call setline('.', '(foo)')
  normal 0va(sr{
  call g:assert.equals(getline('.'), '[foo]', 'failed at #31')

  let g:operator#sandwich#recipes = [
        \   {'buns': ['(', ')']},
        \   {'buns': ['{', '}']},
        \   {'buns': ['[', ']'], 'mode': ['n'], 'input': ['{']},
        \ ]

  " #32
  call setline('.', '(foo)')
  normal 0sra({
  call g:assert.equals(getline('.'), '[foo]', 'failed at #32')

  " #33
  call setline('.', '(foo)')
  normal 0va(sr{
  call g:assert.equals(getline('.'), '{foo}', 'failed at #33')

  let g:operator#sandwich#recipes = [
        \   {'buns': ['(', ')']},
        \   {'buns': ['{', '}']},
        \   {'buns': ['[', ']'], 'mode': ['x'], 'input': ['{']},
        \ ]

  " #34
  call setline('.', '(foo)')
  normal 0sra({
  call g:assert.equals(getline('.'), '{foo}', 'failed at #34')

  " #35
  call setline('.', '(foo)')
  normal 0va(sr{
  call g:assert.equals(getline('.'), '[foo]', 'failed at #35')
endfunction
"}}}
function! s:suite.filter_action() abort "{{{
  let g:sandwich#recipes = []
  let g:operator#sandwich#recipes = [
        \   {'buns': ['(', ')']},
        \   {'buns': ['{', '}']},
        \   {'buns': ['[', ']'], 'input': ['{']},
        \ ]

  " #36
  call setline('.', '(foo)')
  normal 0sra({
  call g:assert.equals(getline('.'), '[foo]', 'failed at #36')

  " #37
  call setline('.', '[foo]')
  normal 0sra[(
  call g:assert.equals(getline('.'), '(foo)', 'failed at #37')

  let g:operator#sandwich#recipes = [
        \   {'buns': ['(', ')']},
        \   {'buns': ['{', '}']},
        \   {'buns': ['[', ']'], 'action': ['all'], 'input': ['{']},
        \ ]

  " #38
  call setline('.', '(foo)')
  normal 0sra({
  call g:assert.equals(getline('.'), '[foo]', 'failed at #38')

  " #39
  call setline('.', '[foo]')
  normal 0sra[(
  call g:assert.equals(getline('.'), '(foo)', 'failed at #39')

  let g:operator#sandwich#recipes = [
        \   {'buns': ['(', ')']},
        \   {'buns': ['{', '}']},
        \   {'buns': ['[', ']'], 'action': ['add'], 'input': ['{']},
        \ ]

  " #40
  call setline('.', '(foo)')
  normal 0sra({
  call g:assert.equals(getline('.'), '[foo]', 'failed at #40')

  " #41
  call setline('.', '[foo]')
  normal 0sra[(
  call g:assert.equals(getline('.'), '[foo]', 'failed at #41')

  let g:operator#sandwich#recipes = [
        \   {'buns': ['(', ')']},
        \   {'buns': ['{', '}']},
        \   {'buns': ['[', ']'], 'action': ['delete'], 'input': ['{']},
        \ ]

  " #42
  call setline('.', '(foo)')
  normal 0sra({
  call g:assert.equals(getline('.'), '{foo}', 'failed at #42')

  " #43
  call setline('.', '[foo]')
  normal 0sra[(
  call g:assert.equals(getline('.'), '(foo)', 'failed at #43')
endfunction
"}}}

" character-wise
function! s:suite.charwise_n_default_recipes() abort "{{{
  " #44
  call setline('.', '(foo)')
  normal 0sra([
  call g:assert.equals(getline('.'), '[foo]',      'failed at #44')
  call g:assert.equals(getpos('.'),  [0, 1, 2, 0], 'failed at #44')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #44')
  call g:assert.equals(getpos("']"), [0, 1, 6, 0], 'failed at #44')

  " #45
  call setline('.', '[foo]')
  normal 0sra[{
  call g:assert.equals(getline('.'), '{foo}',      'failed at #45')
  call g:assert.equals(getpos('.'),  [0, 1, 2, 0], 'failed at #45')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #45')
  call g:assert.equals(getpos("']"), [0, 1, 6, 0], 'failed at #45')

  " #46
  call setline('.', '{foo}')
  normal 0sra{<
  call g:assert.equals(getline('.'), '<foo>',      'failed at #46')
  call g:assert.equals(getpos('.'),  [0, 1, 2, 0], 'failed at #46')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #46')
  call g:assert.equals(getpos("']"), [0, 1, 6, 0], 'failed at #46')

  " #47
call setline('.', '<foo>')
  normal 0sra<(
  call g:assert.equals(getline('.'), '(foo)',      'failed at #47')
  call g:assert.equals(getpos('.'),  [0, 1, 2, 0], 'failed at #47')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #47')
  call g:assert.equals(getpos("']"), [0, 1, 6, 0], 'failed at #47')

  " #48
  call setline('.', '(foo)')
  normal 0sra(]
  call g:assert.equals(getline('.'), '[foo]',      'failed at #48')
  call g:assert.equals(getpos('.'),  [0, 1, 2, 0], 'failed at #48')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #48')
  call g:assert.equals(getpos("']"), [0, 1, 6, 0], 'failed at #48')

  " #49
  call setline('.', '[foo]')
  normal 0sra[}
  call g:assert.equals(getline('.'), '{foo}',      'failed at #49')
  call g:assert.equals(getpos('.'),  [0, 1, 2, 0], 'failed at #49')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #49')
  call g:assert.equals(getpos("']"), [0, 1, 6, 0], 'failed at #49')

  " #50
  call setline('.', '{foo}')
  normal 0sra{>
  call g:assert.equals(getline('.'), '<foo>',      'failed at #50')
  call g:assert.equals(getpos('.'),  [0, 1, 2, 0], 'failed at #50')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #50')
  call g:assert.equals(getpos("']"), [0, 1, 6, 0], 'failed at #50')

  " #51
  call setline('.', '<foo>')
  normal 0sra<)
  call g:assert.equals(getline('.'), '(foo)',      'failed at #51')
  call g:assert.equals(getpos('.'),  [0, 1, 2, 0], 'failed at #51')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #51')
  call g:assert.equals(getpos("']"), [0, 1, 6, 0], 'failed at #51')
endfunction
"}}}
function! s:suite.charwise_n_not_registered() abort "{{{
  " #52
  call setline('.', 'afooa')
  normal 0sriwb
  call g:assert.equals(getline('.'), 'bfoob',      'failed at #52')
  call g:assert.equals(getpos('.'),  [0, 1, 2, 0], 'failed at #52')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #52')
  call g:assert.equals(getpos("']"), [0, 1, 6, 0], 'failed at #52')

  " #53
  call setline('.', '+foo+')
  normal 0sr$*
  call g:assert.equals(getline('.'), '*foo*',      'failed at #53')
  call g:assert.equals(getpos('.'),  [0, 1, 2, 0], 'failed at #53')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #53')
  call g:assert.equals(getpos("']"), [0, 1, 6, 0], 'failed at #53')
endfunction
"}}}
function! s:suite.charwise_n_positioning() abort "{{{
  " #54
  call setline('.', '(foo)bar')
  normal 0sra([
  call g:assert.equals(getline('.'), '[foo]bar',   'failed at #54')
  call g:assert.equals(getpos('.'),  [0, 1, 2, 0], 'failed at #54')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #54')
  call g:assert.equals(getpos("']"), [0, 1, 6, 0], 'failed at #54')

  " #55
  call setline('.', 'foo(bar)')
  normal 0fbsra([
  call g:assert.equals(getline('.'), 'foo[bar]',   'failed at #55')
  call g:assert.equals(getpos('.'),  [0, 1, 5, 0], 'failed at #55')
  call g:assert.equals(getpos("'["), [0, 1, 4, 0], 'failed at #55')
  call g:assert.equals(getpos("']"), [0, 1, 9, 0], 'failed at #55')

  " #56
  call setline('.', 'foo(bar)baz')
  normal 0fbsra([
  call g:assert.equals(getline('.'), 'foo[bar]baz', 'failed at #56')
  call g:assert.equals(getpos('.'),  [0, 1, 5, 0],  'failed at #56')
  call g:assert.equals(getpos("'["), [0, 1, 4, 0],  'failed at #56')
  call g:assert.equals(getpos("']"), [0, 1, 9, 0],  'failed at #56')

  %delete

  onoremap ii :<C-u>call TextobjCoord(1, 4, 1, 10)<CR>
  call operator#sandwich#set('replace', 'char', 'cursor', 'keep')
  let g:operator#sandwich#recipes = [{'buns': ['((', '))'], 'input': ['(']}, {'buns': ['[', ']']}]

  " #57
  call setline('.', 'foo((bar))baz')
  normal 0srii[
  call g:assert.equals(getline('.'), 'foo[bar]baz', 'failed at #57')
  call g:assert.equals(getpos('.'),  [0, 1, 1, 0],  'failed at #57')
  call g:assert.equals(getpos("'["), [0, 1, 4, 0],  'failed at #57')
  call g:assert.equals(getpos("']"), [0, 1, 9, 0],  'failed at #57')

  " #58
  call setline('.', 'foo((bar))baz')
  normal 02lsrii[
  call g:assert.equals(getline('.'), 'foo[bar]baz', 'failed at #58')
  call g:assert.equals(getpos('.'),  [0, 1, 3, 0],  'failed at #58')
  call g:assert.equals(getpos("'["), [0, 1, 4, 0],  'failed at #58')
  call g:assert.equals(getpos("']"), [0, 1, 9, 0],  'failed at #58')

  " #59
  call setline('.', 'foo((bar))baz')
  normal 03lsrii[
  call g:assert.equals(getline('.'), 'foo[bar]baz', 'failed at #59')
  call g:assert.equals(getpos('.'),  [0, 1, 4, 0],  'failed at #59')
  call g:assert.equals(getpos("'["), [0, 1, 4, 0],  'failed at #59')
  call g:assert.equals(getpos("']"), [0, 1, 9, 0],  'failed at #59')

  " #60
  call setline('.', 'foo((bar))baz')
  normal 04lsrii[
  call g:assert.equals(getline('.'), 'foo[bar]baz', 'failed at #60')
  call g:assert.equals(getpos('.'),  [0, 1, 4, 0],  'failed at #60')
  call g:assert.equals(getpos("'["), [0, 1, 4, 0],  'failed at #60')
  call g:assert.equals(getpos("']"), [0, 1, 9, 0],  'failed at #60')

  " #61
  call setline('.', 'foo((bar))baz')
  normal 05lsrii[
  call g:assert.equals(getline('.'), 'foo[bar]baz', 'failed at #61')
  call g:assert.equals(getpos('.'),  [0, 1, 5, 0],  'failed at #61')
  call g:assert.equals(getpos("'["), [0, 1, 4, 0],  'failed at #61')
  call g:assert.equals(getpos("']"), [0, 1, 9, 0],  'failed at #61')

  " #62
  call setline('.', 'foo((bar))baz')
  normal 07lsrii[
  call g:assert.equals(getline('.'), 'foo[bar]baz', 'failed at #62')
  call g:assert.equals(getpos('.'),  [0, 1, 7, 0],  'failed at #62')
  call g:assert.equals(getpos("'["), [0, 1, 4, 0],  'failed at #62')
  call g:assert.equals(getpos("']"), [0, 1, 9, 0],  'failed at #62')

  " #63
  call setline('.', 'foo((bar))baz')
  normal 08lsrii[
  call g:assert.equals(getline('.'), 'foo[bar]baz', 'failed at #63')
  call g:assert.equals(getpos('.'),  [0, 1, 8, 0],  'failed at #63')
  call g:assert.equals(getpos("'["), [0, 1, 4, 0],  'failed at #63')
  call g:assert.equals(getpos("']"), [0, 1, 9, 0],  'failed at #63')

  " #64
  call setline('.', 'foo((bar))baz')
  normal 09lsrii[
  call g:assert.equals(getline('.'), 'foo[bar]baz', 'failed at #64')
  call g:assert.equals(getpos('.'),  [0, 1, 8, 0],  'failed at #64')
  call g:assert.equals(getpos("'["), [0, 1, 4, 0],  'failed at #64')
  call g:assert.equals(getpos("']"), [0, 1, 9, 0],  'failed at #64')

  " #65
  call setline('.', 'foo((bar))baz')
  normal 010lsrii[
  call g:assert.equals(getline('.'), 'foo[bar]baz', 'failed at #65')
  call g:assert.equals(getpos('.'),  [0, 1, 9, 0],  'failed at #65')
  call g:assert.equals(getpos("'["), [0, 1, 4, 0],  'failed at #65')
  call g:assert.equals(getpos("']"), [0, 1, 9, 0],  'failed at #65')

  " #66
  call setline('.', 'foo((bar))baz')
  normal 012lsrii[
  call g:assert.equals(getline('.'), 'foo[bar]baz', 'failed at #66')
  call g:assert.equals(getpos('.'),  [0, 1, 11, 0], 'failed at #66')
  call g:assert.equals(getpos("'["), [0, 1,  4, 0], 'failed at #66')
  call g:assert.equals(getpos("']"), [0, 1,  9, 0], 'failed at #66')

  " #67
  call setline('.', 'foo[[bar]]baz')
  normal 03lsrii(
  call g:assert.equals(getline('.'), 'foo(([bar]))baz', 'failed at #67')
  call g:assert.equals(getpos('.'),  [0, 1,  4, 0],     'failed at #67')
  call g:assert.equals(getpos("'["), [0, 1,  4, 0],     'failed at #67')
  call g:assert.equals(getpos("']"), [0, 1, 13, 0],     'failed at #67')

  " #68
  call setline('.', 'foo[[bar]]baz')
  normal 09lsrii(
  call g:assert.equals(getline('.'), 'foo(([bar]))baz', 'failed at #68')
  call g:assert.equals(getpos('.'),  [0, 1, 11, 0],     'failed at #68')
  call g:assert.equals(getpos("'["), [0, 1,  4, 0],     'failed at #68')
  call g:assert.equals(getpos("']"), [0, 1, 13, 0],     'failed at #68')

  ounmap ii
  call operator#sandwich#set('replace', 'char', 'cursor', 'inner_head')
  unlet g:operator#sandwich#recipes

  " #69
  set whichwrap=h,l
  call append(0, ['(foo', 'bar', 'baz)'])
  normal ggsr13l[
  call g:assert.equals(getline(1),   '[foo',       'failed at #69')
  call g:assert.equals(getline(2),   'bar',        'failed at #69')
  call g:assert.equals(getline(3),   'baz]',       'failed at #69')
  call g:assert.equals(getpos('.'),  [0, 1, 2, 0], 'failed at #69')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #69')
  call g:assert.equals(getpos("']"), [0, 3, 5, 0], 'failed at #69')
  set whichwrap&
endfunction
"}}}
function! s:suite.charwise_n_a_character() abort "{{{
  " #70
  call setline('.', '(a)')
  normal 0sra([
  call g:assert.equals(getline('.'), '[a]',        'failed at #70')
  call g:assert.equals(getpos('.'),  [0, 1, 2, 0], 'failed at #70')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #70')
  call g:assert.equals(getpos("']"), [0, 1, 4, 0], 'failed at #70')

  %delete

  " #71
  call append(0, ['(', 'a', ')'])
  normal ggsra([
  call g:assert.equals(getline(1),   '[',          'failed at #71')
  call g:assert.equals(getline(2),   'a',          'failed at #71')
  call g:assert.equals(getline(3),   ']',          'failed at #71')
  call g:assert.equals(getpos('.'),  [0, 2, 1, 0], 'failed at #71')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #71')
  call g:assert.equals(getpos("']"), [0, 3, 2, 0], 'failed at #71')

  %delete

  " #72
  call append(0, ['(a', ')'])
  normal ggsra([
  call g:assert.equals(getline(1),   '[a',         'failed at #72')
  call g:assert.equals(getline(2),   ']',          'failed at #72')
  call g:assert.equals(getpos('.'),  [0, 1, 2, 0], 'failed at #72')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #72')
  call g:assert.equals(getpos("']"), [0, 2, 2, 0], 'failed at #72')

  %delete

  " #73
  call append(0, ['(', 'a)'])
  normal ggsra([
  call g:assert.equals(getline(1),   '[',          'failed at #73')
  call g:assert.equals(getline(2),   'a]',         'failed at #73')
  call g:assert.equals(getpos('.'),  [0, 2, 1, 0], 'failed at #73')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #73')
  call g:assert.equals(getpos("']"), [0, 2, 3, 0], 'failed at #73')
endfunction
"}}}
function! s:suite.charwise_n_nothing_inside() abort "{{{
  " #74
  call setline('.', '()')
  normal 0sra([
  call g:assert.equals(getline('.'), '[]',         'failed at #74')
  call g:assert.equals(getpos('.'),  [0, 1, 2, 0], 'failed at #74')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #74')
  call g:assert.equals(getpos("']"), [0, 1, 3, 0], 'failed at #74')

  " #75
  call setline('.', 'foo()bar')
  normal 03lsra([
  call g:assert.equals(getline('.'), 'foo[]bar',   'failed at #75')
  call g:assert.equals(getpos('.'),  [0, 1, 5, 0], 'failed at #75')
  call g:assert.equals(getpos("'["), [0, 1, 4, 0], 'failed at #75')
  call g:assert.equals(getpos("']"), [0, 1, 6, 0], 'failed at #75')

  %delete

  " #76
  call append(0, ['(', ')'])
  normal ggsra([
  call g:assert.equals(getline(1),   '[',          'failed at #76')
  call g:assert.equals(getline(2),   ']',          'failed at #76')
  call g:assert.equals(getpos('.'),  [0, 2, 1, 0], 'failed at #76')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #76')
  call g:assert.equals(getpos("']"), [0, 2, 2, 0], 'failed at #76')
endfunction
"}}}
function! s:suite.charwise_n_count() abort "{{{
  " #77
  call setline('.', '([foo])')
  normal 02sr%[(
  call g:assert.equals(getline('.'), '[(foo)]',    'failed at #77')
  call g:assert.equals(getpos('.'),  [0, 1, 3, 0], 'failed at #77')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #77')
  call g:assert.equals(getpos("']"), [0, 1, 8, 0], 'failed at #77')

  " #78
  call setline('.', '[({foo})]')
  normal 03sr%{[(
  call g:assert.equals(getline('.'), '{[(foo)]}',   'failed at #78')
  call g:assert.equals(getpos('.'),  [0, 1,  4, 0], 'failed at #78')
  call g:assert.equals(getpos("'["), [0, 1,  1, 0], 'failed at #78')
  call g:assert.equals(getpos("']"), [0, 1, 10, 0], 'failed at #78')

  " #79
  call setline('.', '[foo ]bar')
  normal 0sr6l(
  call g:assert.equals(getline('.'), '(foo )bar',  'failed at #79')
  call g:assert.equals(getpos('.'),  [0, 1, 2, 0], 'failed at #79')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #79')
  call g:assert.equals(getpos("']"), [0, 1, 7, 0], 'failed at #79')

  " #80
  call setline('.', '[foo bar]')
  normal 0sr9l(
  call g:assert.equals(getline('.'), '(foo bar)',   'failed at #80')
  call g:assert.equals(getpos('.'),  [0, 1,  2, 0], 'failed at #80')
  call g:assert.equals(getpos("'["), [0, 1,  1, 0], 'failed at #80')
  call g:assert.equals(getpos("']"), [0, 1, 10, 0], 'failed at #80')

  " #81
  call setline('.', '{[foo bar]}')
  normal 02sr11l[(
  call g:assert.equals(getline('.'), '[(foo bar)]', 'failed at #81')
  call g:assert.equals(getpos('.'),  [0, 1,  3, 0], 'failed at #81')
  call g:assert.equals(getpos("'["), [0, 1,  1, 0], 'failed at #81')
  call g:assert.equals(getpos("']"), [0, 1, 12, 0], 'failed at #81')

  " #82
  call setline('.', 'foo{[bar]}baz')
  normal 03l2sr7l[(
  call g:assert.equals(getline('.'), 'foo[(bar)]baz', 'failed at #82')
  call g:assert.equals(getpos('.'),  [0, 1,  6, 0],   'failed at #82')
  call g:assert.equals(getpos("'["), [0, 1,  4, 0],   'failed at #82')
  call g:assert.equals(getpos("']"), [0, 1, 11, 0],   'failed at #82')

  " #83
  call setline('.', 'foo({[bar]})baz')
  normal 03l3sr9l{[(
  call g:assert.equals(getline('.'), 'foo{[(bar)]}baz', 'failed at #83')
  call g:assert.equals(getpos('.'),  [0, 1,  7, 0],     'failed at #83')
  call g:assert.equals(getpos("'["), [0, 1,  4, 0],     'failed at #83')
  call g:assert.equals(getpos("']"), [0, 1, 13, 0],     'failed at #83')
endfunction
"}}}
function! s:suite.charwise_n_breaking() abort "{{{
  set whichwrap=h,l

  let g:operator#sandwich#recipes = [
        \   {'buns': ["aa\naaa", "aaa\naa"], 'input':['a']},
        \   {'buns': ["bb\nbbb\nbb", "bb\nbbb\nbb"], 'input':['b']},
        \ ]

  " #84
  call append(0, ['aa', 'aaafooaaa', 'aa'])
  normal ggsr15l(
  call g:assert.equals(getline(1),   '(foo)',      'failed at #84')
  call g:assert.equals(getpos('.'),  [0, 1, 2, 0], 'failed at #84')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #84')
  call g:assert.equals(getpos("']"), [0, 1, 6, 0], 'failed at #84')

  %delete

  " #85
  call append(0, ['bb', 'bbb', 'bbfoobb', 'bbb', 'bb'])
  normal ggsr21l(
  call g:assert.equals(getline(1),   '(foo)',      'failed at #85')
  call g:assert.equals(getpos('.'),  [0, 1, 2, 0], 'failed at #85')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #85')
  call g:assert.equals(getpos("']"), [0, 1, 6, 0], 'failed at #85')

  %delete

  " #86
  call setline('.', '(foo)')
  normal 0sr5la
  call g:assert.equals(getline(1),   'aa',         'failed at #86')
  call g:assert.equals(getline(2),   'aaafooaaa',  'failed at #86')
  call g:assert.equals(getline(3),   'aa',         'failed at #86')
  call g:assert.equals(getpos('.'),  [0, 2, 4, 0], 'failed at #86')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #86')
  call g:assert.equals(getpos("']"), [0, 3, 3, 0], 'failed at #86')

  %delete

  " #87
  call setline('.', '(foo)')
  normal 0sr5lb
  call g:assert.equals(getline(1),   'bb',         'failed at #87')
  call g:assert.equals(getline(2),   'bbb',        'failed at #87')
  call g:assert.equals(getline(3),   'bbfoobb',    'failed at #87')
  call g:assert.equals(getline(4),   'bbb',        'failed at #87')
  call g:assert.equals(getline(5),   'bb',         'failed at #87')
  call g:assert.equals(getpos('.'),  [0, 3, 3, 0], 'failed at #87')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #87')
  call g:assert.equals(getpos("']"), [0, 5, 3, 0], 'failed at #87')

  %delete

  " #88
  call append(0, ['aa', 'aaafooaaa', 'aa'])
  normal ggsr15lb
  call g:assert.equals(getline(1),   'bb',         'failed at #88')
  call g:assert.equals(getline(2),   'bbb',        'failed at #88')
  call g:assert.equals(getline(3),   'bbfoobb',    'failed at #88')
  call g:assert.equals(getline(4),   'bbb',        'failed at #88')
  call g:assert.equals(getline(5),   'bb',         'failed at #88')
  call g:assert.equals(getpos('.'),  [0, 3, 3, 0], 'failed at #88')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #88')
  call g:assert.equals(getpos("']"), [0, 5, 3, 0], 'failed at #88')

  %delete

  " #89
  call append(0, ['bb', 'bbb', 'bbfoobb', 'bbb', 'bb'])
  normal ggsr21la
  call g:assert.equals(getline(1),   'aa',         'failed at #89')
  call g:assert.equals(getline(2),   'aaafooaaa',  'failed at #89')
  call g:assert.equals(getline(3),   'aa',         'failed at #89')
  call g:assert.equals(getpos('.'),  [0, 2, 4, 0], 'failed at #89')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #89')
  call g:assert.equals(getpos("']"), [0, 3, 3, 0], 'failed at #89')

  %delete

  " #90
  call append(0, ['aa', 'aaaaa', 'aaafooaaa', 'aaaaa', 'aa'])
  normal gg2sr27lbb
  call g:assert.equals(getline(1),   'bb',         'failed at #90')
  call g:assert.equals(getline(2),   'bbb',        'failed at #90')
  call g:assert.equals(getline(3),   'bbbb',       'failed at #90')
  call g:assert.equals(getline(4),   'bbb',        'failed at #90')
  call g:assert.equals(getline(5),   'bbfoobb',    'failed at #90')
  call g:assert.equals(getline(6),   'bbb',        'failed at #90')
  call g:assert.equals(getline(7),   'bbbb',       'failed at #90')
  call g:assert.equals(getline(8),   'bbb',        'failed at #90')
  call g:assert.equals(getline(9),   'bb',         'failed at #90')
  call g:assert.equals(getpos('.'),  [0, 5, 3, 0], 'failed at #90')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #90')
  call g:assert.equals(getpos("']"), [0, 9, 3, 0], 'failed at #90')

  %delete

  " #91
  call append(0, ['bb', 'bbb', 'bbbb', 'bbb', 'bbfoobb', 'bbb', 'bbbb', 'bbb', 'bb'])
  normal gg2sr39laa
  call g:assert.equals(getline(1),   'aa',         'failed at #91')
  call g:assert.equals(getline(2),   'aaaaa',      'failed at #91')
  call g:assert.equals(getline(3),   'aaafooaaa',  'failed at #91')
  call g:assert.equals(getline(4),   'aaaaa',      'failed at #91')
  call g:assert.equals(getline(5),   'aa',         'failed at #91')
  call g:assert.equals(getpos('.'),  [0, 3, 4, 0], 'failed at #91')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #91')
  call g:assert.equals(getpos("']"), [0, 5, 3, 0], 'failed at #91')

  %delete
  call operator#sandwich#set('replace', 'char', 'cursor', 'keep')
  onoremap ii :<C-u>call TextobjCoord(1, 4, 1, 8)<CR>

  " #92
  call setline('.', ['foo(bar)baz'])
  normal 0sriia
  call g:assert.equals(getline(1),   'fooaa',      'failed at #92')
  call g:assert.equals(getline(2),   'aaabaraaa',  'failed at #92')
  call g:assert.equals(getline(3),   'aabaz',      'failed at #92')
  call g:assert.equals(getpos('.'),  [0, 1, 1, 0], 'failed at #92')
  call g:assert.equals(getpos("'["), [0, 1, 4, 0], 'failed at #92')
  call g:assert.equals(getpos("']"), [0, 3, 3, 0], 'failed at #92')

  %delete

  " #93
  call setline('.', ['foo(bar)baz'])
  normal 02lsriia
  call g:assert.equals(getline(1),   'fooaa',      'failed at #93')
  call g:assert.equals(getline(2),   'aaabaraaa',  'failed at #93')
  call g:assert.equals(getline(3),   'aabaz',      'failed at #93')
  call g:assert.equals(getpos('.'),  [0, 1, 3, 0], 'failed at #93')
  call g:assert.equals(getpos("'["), [0, 1, 4, 0], 'failed at #93')
  call g:assert.equals(getpos("']"), [0, 3, 3, 0], 'failed at #93')

  %delete

  " #94
  call setline('.', ['foo(bar)baz'])
  normal 03lsriia
  call g:assert.equals(getline(1),   'fooaa',      'failed at #94')
  call g:assert.equals(getline(2),   'aaabaraaa',  'failed at #94')
  call g:assert.equals(getline(3),   'aabaz',      'failed at #94')
  call g:assert.equals(getpos('.'),  [0, 1, 4, 0], 'failed at #94')
  call g:assert.equals(getpos("'["), [0, 1, 4, 0], 'failed at #94')
  call g:assert.equals(getpos("']"), [0, 3, 3, 0], 'failed at #94')

  %delete

  " #95
  call setline('.', ['foo(bar)baz'])
  normal 04lsriia
  call g:assert.equals(getline(1),   'fooaa',      'failed at #95')
  call g:assert.equals(getline(2),   'aaabaraaa',  'failed at #95')
  call g:assert.equals(getline(3),   'aabaz',      'failed at #95')
  call g:assert.equals(getpos('.'),  [0, 2, 4, 0], 'failed at #95')
  call g:assert.equals(getpos("'["), [0, 1, 4, 0], 'failed at #95')
  call g:assert.equals(getpos("']"), [0, 3, 3, 0], 'failed at #95')

  %delete

  " #96
  call setline('.', ['foo(bar)baz'])
  normal 06lsriia
  call g:assert.equals(getline(1),   'fooaa',      'failed at #96')
  call g:assert.equals(getline(2),   'aaabaraaa',  'failed at #96')
  call g:assert.equals(getline(3),   'aabaz',      'failed at #96')
  call g:assert.equals(getpos('.'),  [0, 2, 6, 0], 'failed at #96')
  call g:assert.equals(getpos("'["), [0, 1, 4, 0], 'failed at #96')
  call g:assert.equals(getpos("']"), [0, 3, 3, 0], 'failed at #96')

  %delete

  " #97
  call setline('.', ['foo(bar)baz'])
  normal 07lsriia
  call g:assert.equals(getline(1),   'fooaa',      'failed at #97')
  call g:assert.equals(getline(2),   'aaabaraaa',  'failed at #97')
  call g:assert.equals(getline(3),   'aabaz',      'failed at #97')
  call g:assert.equals(getpos('.'),  [0, 2, 7, 0], 'failed at #97')
  call g:assert.equals(getpos("'["), [0, 1, 4, 0], 'failed at #97')
  call g:assert.equals(getpos("']"), [0, 3, 3, 0], 'failed at #97')

  %delete

  " #98
  call setline('.', ['foo(bar)baz'])
  normal 08lsriia
  call g:assert.equals(getline(1),   'fooaa',      'failed at #98')
  call g:assert.equals(getline(2),   'aaabaraaa',  'failed at #98')
  call g:assert.equals(getline(3),   'aabaz',      'failed at #98')
  call g:assert.equals(getpos('.'),  [0, 3, 3, 0], 'failed at #98')
  call g:assert.equals(getpos("'["), [0, 1, 4, 0], 'failed at #98')
  call g:assert.equals(getpos("']"), [0, 3, 3, 0], 'failed at #98')

  %delete

  " #99
  call setline('.', ['foo(bar)baz'])
  normal 010lsriia
  call g:assert.equals(getline(1),   'fooaa',      'failed at #99')
  call g:assert.equals(getline(2),   'aaabaraaa',  'failed at #99')
  call g:assert.equals(getline(3),   'aabaz',      'failed at #99')
  call g:assert.equals(getpos('.'),  [0, 3, 5, 0], 'failed at #99')
  call g:assert.equals(getpos("'["), [0, 1, 4, 0], 'failed at #99')
  call g:assert.equals(getpos("']"), [0, 3, 3, 0], 'failed at #99')

  %delete
  onoremap ii :<C-u>call TextobjCoord(1, 4, 3, 2)<CR>

  " #100
  call append(0, ['fooaa', 'aaabaraaa', 'aabaz'])
  normal ggsrii(
  call g:assert.equals(getline(1),   'foo(bar)baz', 'failed at #100')
  call g:assert.equals(getpos('.'),  [0, 1, 1, 0],  'failed at #100')
  call g:assert.equals(getpos("'["), [0, 1, 4, 0],  'failed at #100')
  call g:assert.equals(getpos("']"), [0, 1, 9, 0],  'failed at #100')

  %delete

  " #101
  call append(0, ['fooaa', 'aaabaraaa', 'aabaz'])
  normal gg2lsrii(
  call g:assert.equals(getline(1),   'foo(bar)baz', 'failed at #101')
  call g:assert.equals(getpos('.'),  [0, 1, 3, 0],  'failed at #101')
  call g:assert.equals(getpos("'["), [0, 1, 4, 0],  'failed at #101')
  call g:assert.equals(getpos("']"), [0, 1, 9, 0],  'failed at #101')

  %delete

  " #102
  call append(0, ['fooaa', 'aaabaraaa', 'aabaz'])
  normal gg3lsrii(
  call g:assert.equals(getline(1),   'foo(bar)baz', 'failed at #102')
  call g:assert.equals(getpos('.'),  [0, 1, 4, 0],  'failed at #102')
  call g:assert.equals(getpos("'["), [0, 1, 4, 0],  'failed at #102')
  call g:assert.equals(getpos("']"), [0, 1, 9, 0],  'failed at #102')

  %delete

  " #103
  call append(0, ['fooaa', 'aaabaraaa', 'aabaz'])
  normal gg4lsrii(
  call g:assert.equals(getline(1),   'foo(bar)baz', 'failed at #103')
  call g:assert.equals(getpos('.'),  [0, 1, 4, 0],  'failed at #103')
  call g:assert.equals(getpos("'["), [0, 1, 4, 0],  'failed at #103')
  call g:assert.equals(getpos("']"), [0, 1, 9, 0],  'failed at #103')

  %delete

  " #104
  call append(0, ['fooaa', 'aaabaraaa', 'aabaz'])
  normal ggjsrii(
  call g:assert.equals(getline(1),   'foo(bar)baz', 'failed at #104')
  call g:assert.equals(getpos('.'),  [0, 1, 4, 0],  'failed at #104')
  call g:assert.equals(getpos("'["), [0, 1, 4, 0],  'failed at #104')
  call g:assert.equals(getpos("']"), [0, 1, 9, 0],  'failed at #104')

  %delete

  " #105
  call append(0, ['fooaa', 'aaabaraaa', 'aabaz'])
  normal ggj2lsrii(
  call g:assert.equals(getline(1),   'foo(bar)baz', 'failed at #105')
  call g:assert.equals(getpos('.'),  [0, 1, 4, 0],  'failed at #105')
  call g:assert.equals(getpos("'["), [0, 1, 4, 0],  'failed at #105')
  call g:assert.equals(getpos("']"), [0, 1, 9, 0],  'failed at #105')

  %delete

  " #106
  call append(0, ['fooaa', 'aaabaraaa', 'aabaz'])
  normal ggj3lsrii(
  call g:assert.equals(getline(1),   'foo(bar)baz', 'failed at #106')
  call g:assert.equals(getpos('.'),  [0, 1, 5, 0],  'failed at #106')
  call g:assert.equals(getpos("'["), [0, 1, 4, 0],  'failed at #106')
  call g:assert.equals(getpos("']"), [0, 1, 9, 0],  'failed at #106')

  %delete

  " #107
  call append(0, ['fooaa', 'aaabaraaa', 'aabaz'])
  normal ggj5lsrii(
  call g:assert.equals(getline(1),   'foo(bar)baz', 'failed at #107')
  call g:assert.equals(getpos('.'),  [0, 1, 7, 0],  'failed at #107')
  call g:assert.equals(getpos("'["), [0, 1, 4, 0],  'failed at #107')
  call g:assert.equals(getpos("']"), [0, 1, 9, 0],  'failed at #107')

  %delete

  " #108
  call append(0, ['fooaa', 'aaabaraaa', 'aabaz'])
  normal ggj6lsrii(
  call g:assert.equals(getline(1),   'foo(bar)baz', 'failed at #108')
  call g:assert.equals(getpos('.'),  [0, 1, 8, 0],  'failed at #108')
  call g:assert.equals(getpos("'["), [0, 1, 4, 0],  'failed at #108')
  call g:assert.equals(getpos("']"), [0, 1, 9, 0],  'failed at #108')

  %delete

  " #109
  call append(0, ['fooaa', 'aaabaraaa', 'aabaz'])
  normal ggj8lsrii(
  call g:assert.equals(getline(1),   'foo(bar)baz', 'failed at #109')
  call g:assert.equals(getpos('.'),  [0, 1, 8, 0],  'failed at #109')
  call g:assert.equals(getpos("'["), [0, 1, 4, 0],  'failed at #109')
  call g:assert.equals(getpos("']"), [0, 1, 9, 0],  'failed at #109')

  %delete

  " #110
  call append(0, ['fooaa', 'aaabaraaa', 'aabaz'])
  normal gg2jsrii(
  call g:assert.equals(getline(1),   'foo(bar)baz', 'failed at #110')
  call g:assert.equals(getpos('.'),  [0, 1, 8, 0],  'failed at #110')
  call g:assert.equals(getpos("'["), [0, 1, 4, 0],  'failed at #110')
  call g:assert.equals(getpos("']"), [0, 1, 9, 0],  'failed at #110')

  %delete

  " #111
  call append(0, ['fooaa', 'aaabaraaa', 'aabaz'])
  normal gg2jlsrii(
  call g:assert.equals(getline(1),   'foo(bar)baz', 'failed at #111')
  call g:assert.equals(getpos('.'),  [0, 1, 8, 0],  'failed at #111')
  call g:assert.equals(getpos("'["), [0, 1, 4, 0],  'failed at #111')
  call g:assert.equals(getpos("']"), [0, 1, 9, 0],  'failed at #111')

  %delete

  " #112
  call append(0, ['fooaa', 'aaabaraaa', 'aabaz'])
  normal gg2j2lsrii(
  call g:assert.equals(getline(1),   'foo(bar)baz', 'failed at #112')
  call g:assert.equals(getpos('.'),  [0, 1, 9, 0],  'failed at #112')
  call g:assert.equals(getpos("'["), [0, 1, 4, 0],  'failed at #112')
  call g:assert.equals(getpos("']"), [0, 1, 9, 0],  'failed at #112')

  %delete

  " #113
  call append(0, ['fooaa', 'aaabaraaa', 'aabaz'])
  normal gg2j4lsrii(
  call g:assert.equals(getline(1),   'foo(bar)baz', 'failed at #113')
  call g:assert.equals(getpos('.'),  [0, 1, 11, 0], 'failed at #113')
  call g:assert.equals(getpos("'["), [0, 1,  4, 0], 'failed at #113')
  call g:assert.equals(getpos("']"), [0, 1,  9, 0], 'failed at #113')

  %delete

  " #114
  call append(0, ['fooaa', 'aaabaraaa', 'aabaz'])
  normal ggsriib
  call g:assert.equals(getline(1),   'foobb',      'failed at #114')
  call g:assert.equals(getline(2),   'bbb',        'failed at #114')
  call g:assert.equals(getline(3),   'bbbarbb',    'failed at #114')
  call g:assert.equals(getline(4),   'bbb',        'failed at #114')
  call g:assert.equals(getline(5),   'bbbaz',      'failed at #114')
  call g:assert.equals(getpos('.'),  [0, 1, 1, 0], 'failed at #114')
  call g:assert.equals(getpos("'["), [0, 1, 4, 0], 'failed at #114')
  call g:assert.equals(getpos("']"), [0, 5, 3, 0], 'failed at #114')

  %delete

  " #115
  call append(0, ['fooaa', 'aaabaraaa', 'aabaz'])
  normal gg2lsriib
  call g:assert.equals(getline(1),   'foobb',      'failed at #115')
  call g:assert.equals(getline(2),   'bbb',        'failed at #115')
  call g:assert.equals(getline(3),   'bbbarbb',    'failed at #115')
  call g:assert.equals(getline(4),   'bbb',        'failed at #115')
  call g:assert.equals(getline(5),   'bbbaz',      'failed at #115')
  call g:assert.equals(getpos('.'),  [0, 1, 3, 0], 'failed at #115')
  call g:assert.equals(getpos("'["), [0, 1, 4, 0], 'failed at #115')
  call g:assert.equals(getpos("']"), [0, 5, 3, 0], 'failed at #115')

  %delete

  " #116
  call append(0, ['fooaa', 'aaabaraaa', 'aabaz'])
  normal gg3lsriib
  call g:assert.equals(getline(1),   'foobb',      'failed at #116')
  call g:assert.equals(getline(2),   'bbb',        'failed at #116')
  call g:assert.equals(getline(3),   'bbbarbb',    'failed at #116')
  call g:assert.equals(getline(4),   'bbb',        'failed at #116')
  call g:assert.equals(getline(5),   'bbbaz',      'failed at #116')
  call g:assert.equals(getpos('.'),  [0, 1, 4, 0], 'failed at #116')
  call g:assert.equals(getpos("'["), [0, 1, 4, 0], 'failed at #116')
  call g:assert.equals(getpos("']"), [0, 5, 3, 0], 'failed at #116')

  %delete

  " #117
  call append(0, ['fooaa', 'aaabaraaa', 'aabaz'])
  normal gg4lsriib
  call g:assert.equals(getline(1),   'foobb',      'failed at #117')
  call g:assert.equals(getline(2),   'bbb',        'failed at #117')
  call g:assert.equals(getline(3),   'bbbarbb',    'failed at #117')
  call g:assert.equals(getline(4),   'bbb',        'failed at #117')
  call g:assert.equals(getline(5),   'bbbaz',      'failed at #117')
  call g:assert.equals(getpos('.'),  [0, 1, 5, 0], 'failed at #117')
  call g:assert.equals(getpos("'["), [0, 1, 4, 0], 'failed at #117')
  call g:assert.equals(getpos("']"), [0, 5, 3, 0], 'failed at #117')

  %delete

  " #118
  call append(0, ['fooaa', 'aaabaraaa', 'aabaz'])
  normal ggjsriib
  call g:assert.equals(getline(1),   'foobb',      'failed at #118')
  call g:assert.equals(getline(2),   'bbb',        'failed at #118')
  call g:assert.equals(getline(3),   'bbbarbb',    'failed at #118')
  call g:assert.equals(getline(4),   'bbb',        'failed at #118')
  call g:assert.equals(getline(5),   'bbbaz',      'failed at #118')
  call g:assert.equals(getpos('.'),  [0, 2, 1, 0], 'failed at #118')
  call g:assert.equals(getpos("'["), [0, 1, 4, 0], 'failed at #118')
  call g:assert.equals(getpos("']"), [0, 5, 3, 0], 'failed at #118')

  %delete

  " #119
  call append(0, ['fooaa', 'aaabaraaa', 'aabaz'])
  normal ggjlsriib
  call g:assert.equals(getline(1),   'foobb',      'failed at #119')
  call g:assert.equals(getline(2),   'bbb',        'failed at #119')
  call g:assert.equals(getline(3),   'bbbarbb',    'failed at #119')
  call g:assert.equals(getline(4),   'bbb',        'failed at #119')
  call g:assert.equals(getline(5),   'bbbaz',      'failed at #119')
  call g:assert.equals(getpos('.'),  [0, 2, 2, 0], 'failed at #119')
  call g:assert.equals(getpos("'["), [0, 1, 4, 0], 'failed at #119')
  call g:assert.equals(getpos("']"), [0, 5, 3, 0], 'failed at #119')

  %delete

  " #120
  call append(0, ['fooaa', 'aaabaraaa', 'aabaz'])
  normal ggj2lsriib
  call g:assert.equals(getline(1),   'foobb',      'failed at #120')
  call g:assert.equals(getline(2),   'bbb',        'failed at #120')
  call g:assert.equals(getline(3),   'bbbarbb',    'failed at #120')
  call g:assert.equals(getline(4),   'bbb',        'failed at #120')
  call g:assert.equals(getline(5),   'bbbaz',      'failed at #120')
  call g:assert.equals(getpos('.'),  [0, 2, 3, 0], 'failed at #120')
  call g:assert.equals(getpos("'["), [0, 1, 4, 0], 'failed at #120')
  call g:assert.equals(getpos("']"), [0, 5, 3, 0], 'failed at #120')

  %delete

  " #121
  call append(0, ['fooaa', 'aaabaraaa', 'aabaz'])
  normal ggj3lsriib
  call g:assert.equals(getline(1),   'foobb',      'failed at #121')
  call g:assert.equals(getline(2),   'bbb',        'failed at #121')
  call g:assert.equals(getline(3),   'bbbarbb',    'failed at #121')
  call g:assert.equals(getline(4),   'bbb',        'failed at #121')
  call g:assert.equals(getline(5),   'bbbaz',      'failed at #121')
  call g:assert.equals(getpos('.'),  [0, 3, 3, 0], 'failed at #121')
  call g:assert.equals(getpos("'["), [0, 1, 4, 0], 'failed at #121')
  call g:assert.equals(getpos("']"), [0, 5, 3, 0], 'failed at #121')

  %delete

  " #122
  call append(0, ['fooaa', 'aaabaraaa', 'aabaz'])
  normal ggj5lsriib
  call g:assert.equals(getline(1),   'foobb',      'failed at #122')
  call g:assert.equals(getline(2),   'bbb',        'failed at #122')
  call g:assert.equals(getline(3),   'bbbarbb',    'failed at #122')
  call g:assert.equals(getline(4),   'bbb',        'failed at #122')
  call g:assert.equals(getline(5),   'bbbaz',      'failed at #122')
  call g:assert.equals(getpos('.'),  [0, 3, 5, 0], 'failed at #122')
  call g:assert.equals(getpos("'["), [0, 1, 4, 0], 'failed at #122')
  call g:assert.equals(getpos("']"), [0, 5, 3, 0], 'failed at #122')

  %delete

  " #123
  call append(0, ['fooaa', 'aaabaraaa', 'aabaz'])
  normal ggj6lsriib
  call g:assert.equals(getline(1),   'foobb',      'failed at #123')
  call g:assert.equals(getline(2),   'bbb',        'failed at #123')
  call g:assert.equals(getline(3),   'bbbarbb',    'failed at #123')
  call g:assert.equals(getline(4),   'bbb',        'failed at #123')
  call g:assert.equals(getline(5),   'bbbaz',      'failed at #123')
  call g:assert.equals(getpos('.'),  [0, 3, 6, 0], 'failed at #123')
  call g:assert.equals(getpos("'["), [0, 1, 4, 0], 'failed at #123')
  call g:assert.equals(getpos("']"), [0, 5, 3, 0], 'failed at #123')

  %delete

  " #124
  call append(0, ['fooaa', 'aaabaraaa', 'aabaz'])
  normal ggj7lsriib
  call g:assert.equals(getline(1),   'foobb',      'failed at #124')
  call g:assert.equals(getline(2),   'bbb',        'failed at #124')
  call g:assert.equals(getline(3),   'bbbarbb',    'failed at #124')
  call g:assert.equals(getline(4),   'bbb',        'failed at #124')
  call g:assert.equals(getline(5),   'bbbaz',      'failed at #124')
  call g:assert.equals(getpos('.'),  [0, 3, 7, 0], 'failed at #124')
  call g:assert.equals(getpos("'["), [0, 1, 4, 0], 'failed at #124')
  call g:assert.equals(getpos("']"), [0, 5, 3, 0], 'failed at #124')

  %delete

  " #125
  call append(0, ['fooaa', 'aaabaraaa', 'aabaz'])
  normal ggj8lsriib
  call g:assert.equals(getline(1),   'foobb',      'failed at #125')
  call g:assert.equals(getline(2),   'bbb',        'failed at #125')
  call g:assert.equals(getline(3),   'bbbarbb',    'failed at #125')
  call g:assert.equals(getline(4),   'bbb',        'failed at #125')
  call g:assert.equals(getline(5),   'bbbaz',      'failed at #125')
  call g:assert.equals(getpos('.'),  [0, 3, 7, 0], 'failed at #125')
  call g:assert.equals(getpos("'["), [0, 1, 4, 0], 'failed at #125')
  call g:assert.equals(getpos("']"), [0, 5, 3, 0], 'failed at #125')

  %delete

  " #126
  call append(0, ['fooaa', 'aaabaraaa', 'aabaz'])
  normal gg2jsriib
  call g:assert.equals(getline(1),   'foobb',      'failed at #126')
  call g:assert.equals(getline(2),   'bbb',        'failed at #126')
  call g:assert.equals(getline(3),   'bbbarbb',    'failed at #126')
  call g:assert.equals(getline(4),   'bbb',        'failed at #126')
  call g:assert.equals(getline(5),   'bbbaz',      'failed at #126')
  call g:assert.equals(getpos('.'),  [0, 4, 1, 0], 'failed at #126')
  call g:assert.equals(getpos("'["), [0, 1, 4, 0], 'failed at #126')
  call g:assert.equals(getpos("']"), [0, 5, 3, 0], 'failed at #126')

  %delete

  " #127
  call append(0, ['fooaa', 'aaabaraaa', 'aabaz'])
  normal gg2jlsriib
  call g:assert.equals(getline(1),   'foobb',      'failed at #127')
  call g:assert.equals(getline(2),   'bbb',        'failed at #127')
  call g:assert.equals(getline(3),   'bbbarbb',    'failed at #127')
  call g:assert.equals(getline(4),   'bbb',        'failed at #127')
  call g:assert.equals(getline(5),   'bbbaz',      'failed at #127')
  call g:assert.equals(getpos('.'),  [0, 4, 2, 0], 'failed at #127')
  call g:assert.equals(getpos("'["), [0, 1, 4, 0], 'failed at #127')
  call g:assert.equals(getpos("']"), [0, 5, 3, 0], 'failed at #127')

  %delete

  " #128
  call append(0, ['fooaa', 'aaabaraaa', 'aabaz'])
  normal gg2j2lsriib
  call g:assert.equals(getline(1),   'foobb',      'failed at #128')
  call g:assert.equals(getline(2),   'bbb',        'failed at #128')
  call g:assert.equals(getline(3),   'bbbarbb',    'failed at #128')
  call g:assert.equals(getline(4),   'bbb',        'failed at #128')
  call g:assert.equals(getline(5),   'bbbaz',      'failed at #128')
  call g:assert.equals(getpos('.'),  [0, 5, 3, 0], 'failed at #128')
  call g:assert.equals(getpos("'["), [0, 1, 4, 0], 'failed at #128')
  call g:assert.equals(getpos("']"), [0, 5, 3, 0], 'failed at #128')

  %delete

  " #129
  call append(0, ['fooaa', 'aaabaraaa', 'aabaz'])
  normal gg2j4lsriib
  call g:assert.equals(getline(1),   'foobb',      'failed at #129')
  call g:assert.equals(getline(2),   'bbb',        'failed at #129')
  call g:assert.equals(getline(3),   'bbbarbb',    'failed at #129')
  call g:assert.equals(getline(4),   'bbb',        'failed at #129')
  call g:assert.equals(getline(5),   'bbbaz',      'failed at #129')
  call g:assert.equals(getpos('.'),  [0, 5, 5, 0], 'failed at #129')
  call g:assert.equals(getpos("'["), [0, 1, 4, 0], 'failed at #129')
  call g:assert.equals(getpos("']"), [0, 5, 3, 0], 'failed at #129')

  %delete
  onoremap ii :<C-u>call TextobjCoord(1, 4, 5, 2)<CR>

  " #130
  call append(0, ['foobb', 'bbb', 'bbbarbb', 'bbb', 'bbbaz'])
  normal ggsriia
  call g:assert.equals(getline(1),   'fooaa',      'failed at #130')
  call g:assert.equals(getline(2),   'aaabaraaa',  'failed at #130')
  call g:assert.equals(getline(3),   'aabaz',      'failed at #130')
  call g:assert.equals(getpos('.'),  [0, 1, 1, 0], 'failed at #130')
  call g:assert.equals(getpos("'["), [0, 1, 4, 0], 'failed at #130')
  call g:assert.equals(getpos("']"), [0, 3, 3, 0], 'failed at #130')

  %delete

  " #131
  call append(0, ['foobb', 'bbb', 'bbbarbb', 'bbb', 'bbbaz'])
  normal gg2lsriia
  call g:assert.equals(getline(1),   'fooaa',      'failed at #131')
  call g:assert.equals(getline(2),   'aaabaraaa',  'failed at #131')
  call g:assert.equals(getline(3),   'aabaz',      'failed at #131')
  call g:assert.equals(getpos('.'),  [0, 1, 3, 0], 'failed at #131')
  call g:assert.equals(getpos("'["), [0, 1, 4, 0], 'failed at #131')
  call g:assert.equals(getpos("']"), [0, 3, 3, 0], 'failed at #131')

  %delete

  " #132
  call append(0, ['foobb', 'bbb', 'bbbarbb', 'bbb', 'bbbaz'])
  normal gg3lsriia
  call g:assert.equals(getline(1),   'fooaa',      'failed at #132')
  call g:assert.equals(getline(2),   'aaabaraaa',  'failed at #132')
  call g:assert.equals(getline(3),   'aabaz',      'failed at #132')
  call g:assert.equals(getpos('.'),  [0, 1, 4, 0], 'failed at #132')
  call g:assert.equals(getpos("'["), [0, 1, 4, 0], 'failed at #132')
  call g:assert.equals(getpos("']"), [0, 3, 3, 0], 'failed at #132')

  %delete

  " #133
  call append(0, ['foobb', 'bbb', 'bbbarbb', 'bbb', 'bbbaz'])
  normal gg4lsriia
  call g:assert.equals(getline(1),   'fooaa',      'failed at #133')
  call g:assert.equals(getline(2),   'aaabaraaa',  'failed at #133')
  call g:assert.equals(getline(3),   'aabaz',      'failed at #133')
  call g:assert.equals(getpos('.'),  [0, 1, 5, 0], 'failed at #133')
  call g:assert.equals(getpos("'["), [0, 1, 4, 0], 'failed at #133')
  call g:assert.equals(getpos("']"), [0, 3, 3, 0], 'failed at #133')

  %delete

  " #134
  call append(0, ['foobb', 'bbb', 'bbbarbb', 'bbb', 'bbbaz'])
  normal ggjsriia
  call g:assert.equals(getline(1),   'fooaa',      'failed at #134')
  call g:assert.equals(getline(2),   'aaabaraaa',  'failed at #134')
  call g:assert.equals(getline(3),   'aabaz',      'failed at #134')
  call g:assert.equals(getpos('.'),  [0, 2, 1, 0], 'failed at #134')
  call g:assert.equals(getpos("'["), [0, 1, 4, 0], 'failed at #134')
  call g:assert.equals(getpos("']"), [0, 3, 3, 0], 'failed at #134')

  %delete

  " #135
  call append(0, ['foobb', 'bbb', 'bbbarbb', 'bbb', 'bbbaz'])
  normal ggjlsriia
  call g:assert.equals(getline(1),   'fooaa',      'failed at #135')
  call g:assert.equals(getline(2),   'aaabaraaa',  'failed at #135')
  call g:assert.equals(getline(3),   'aabaz',      'failed at #135')
  call g:assert.equals(getpos('.'),  [0, 2, 2, 0], 'failed at #135')
  call g:assert.equals(getpos("'["), [0, 1, 4, 0], 'failed at #135')
  call g:assert.equals(getpos("']"), [0, 3, 3, 0], 'failed at #135')

  %delete

  " #136
  call append(0, ['foobb', 'bbb', 'bbbarbb', 'bbb', 'bbbaz'])
  normal ggj2lsriia
  call g:assert.equals(getline(1),   'fooaa',      'failed at #136')
  call g:assert.equals(getline(2),   'aaabaraaa',  'failed at #136')
  call g:assert.equals(getline(3),   'aabaz',      'failed at #136')
  call g:assert.equals(getpos('.'),  [0, 2, 3, 0], 'failed at #136')
  call g:assert.equals(getpos("'["), [0, 1, 4, 0], 'failed at #136')
  call g:assert.equals(getpos("']"), [0, 3, 3, 0], 'failed at #136')

  %delete

  " #137
  call append(0, ['foobb', 'bbb', 'bbbarbb', 'bbb', 'bbbaz'])
  normal gg2jsriia
  call g:assert.equals(getline(1),   'fooaa',      'failed at #137')
  call g:assert.equals(getline(2),   'aaabaraaa',  'failed at #137')
  call g:assert.equals(getline(3),   'aabaz',      'failed at #137')
  call g:assert.equals(getpos('.'),  [0, 2, 3, 0], 'failed at #137')
  call g:assert.equals(getpos("'["), [0, 1, 4, 0], 'failed at #137')
  call g:assert.equals(getpos("']"), [0, 3, 3, 0], 'failed at #137')

  %delete

  " #138
  call append(0, ['foobb', 'bbb', 'bbbarbb', 'bbb', 'bbbaz'])
  normal gg2jlsriia
  call g:assert.equals(getline(1),   'fooaa',      'failed at #138')
  call g:assert.equals(getline(2),   'aaabaraaa',  'failed at #138')
  call g:assert.equals(getline(3),   'aabaz',      'failed at #138')
  call g:assert.equals(getpos('.'),  [0, 2, 3, 0], 'failed at #138')
  call g:assert.equals(getpos("'["), [0, 1, 4, 0], 'failed at #138')
  call g:assert.equals(getpos("']"), [0, 3, 3, 0], 'failed at #138')

  %delete

  " #139
  call append(0, ['foobb', 'bbb', 'bbbarbb', 'bbb', 'bbbaz'])
  normal gg2j2lsriia
  call g:assert.equals(getline(1),   'fooaa',      'failed at #139')
  call g:assert.equals(getline(2),   'aaabaraaa',  'failed at #139')
  call g:assert.equals(getline(3),   'aabaz',      'failed at #139')
  call g:assert.equals(getpos('.'),  [0, 2, 4, 0], 'failed at #139')
  call g:assert.equals(getpos("'["), [0, 1, 4, 0], 'failed at #139')
  call g:assert.equals(getpos("']"), [0, 3, 3, 0], 'failed at #139')

  %delete

  " #140
  call append(0, ['foobb', 'bbb', 'bbbarbb', 'bbb', 'bbbaz'])
  normal gg2j4lsriia
  call g:assert.equals(getline(1),   'fooaa',      'failed at #140')
  call g:assert.equals(getline(2),   'aaabaraaa',  'failed at #140')
  call g:assert.equals(getline(3),   'aabaz',      'failed at #140')
  call g:assert.equals(getpos('.'),  [0, 2, 6, 0], 'failed at #140')
  call g:assert.equals(getpos("'["), [0, 1, 4, 0], 'failed at #140')
  call g:assert.equals(getpos("']"), [0, 3, 3, 0], 'failed at #140')

  %delete

  " #141
  call append(0, ['foobb', 'bbb', 'bbbarbb', 'bbb', 'bbbaz'])
  normal gg2j5lsriia
  call g:assert.equals(getline(1),   'fooaa',      'failed at #141')
  call g:assert.equals(getline(2),   'aaabaraaa',  'failed at #141')
  call g:assert.equals(getline(3),   'aabaz',      'failed at #141')
  call g:assert.equals(getpos('.'),  [0, 2, 7, 0], 'failed at #141')
  call g:assert.equals(getpos("'["), [0, 1, 4, 0], 'failed at #141')
  call g:assert.equals(getpos("']"), [0, 3, 3, 0], 'failed at #141')

  %delete

  " #142
  call append(0, ['foobb', 'bbb', 'bbbarbb', 'bbb', 'bbbaz'])
  normal gg2j6lsriia
  call g:assert.equals(getline(1),   'fooaa',      'failed at #142')
  call g:assert.equals(getline(2),   'aaabaraaa',  'failed at #142')
  call g:assert.equals(getline(3),   'aabaz',      'failed at #142')
  call g:assert.equals(getpos('.'),  [0, 2, 8, 0], 'failed at #142')
  call g:assert.equals(getpos("'["), [0, 1, 4, 0], 'failed at #142')
  call g:assert.equals(getpos("']"), [0, 3, 3, 0], 'failed at #142')

  %delete

  " #143
  call append(0, ['foobb', 'bbb', 'bbbarbb', 'bbb', 'bbbaz'])
  normal gg3jsriia
  call g:assert.equals(getline(1),   'fooaa',      'failed at #143')
  call g:assert.equals(getline(2),   'aaabaraaa',  'failed at #143')
  call g:assert.equals(getline(3),   'aabaz',      'failed at #143')
  call g:assert.equals(getpos('.'),  [0, 3, 1, 0], 'failed at #143')
  call g:assert.equals(getpos("'["), [0, 1, 4, 0], 'failed at #143')
  call g:assert.equals(getpos("']"), [0, 3, 3, 0], 'failed at #143')

  %delete

  " #144
  call append(0, ['foobb', 'bbb', 'bbbarbb', 'bbb', 'bbbaz'])
  normal gg3jlsriia
  call g:assert.equals(getline(1),   'fooaa',      'failed at #144')
  call g:assert.equals(getline(2),   'aaabaraaa',  'failed at #144')
  call g:assert.equals(getline(3),   'aabaz',      'failed at #144')
  call g:assert.equals(getpos('.'),  [0, 3, 2, 0], 'failed at #144')
  call g:assert.equals(getpos("'["), [0, 1, 4, 0], 'failed at #144')
  call g:assert.equals(getpos("']"), [0, 3, 3, 0], 'failed at #144')

  %delete

  " #145
  call append(0, ['foobb', 'bbb', 'bbbarbb', 'bbb', 'bbbaz'])
  normal gg3j2lsriia
  call g:assert.equals(getline(1),   'fooaa',      'failed at #145')
  call g:assert.equals(getline(2),   'aaabaraaa',  'failed at #145')
  call g:assert.equals(getline(3),   'aabaz',      'failed at #145')
  call g:assert.equals(getpos('.'),  [0, 3, 2, 0], 'failed at #145')
  call g:assert.equals(getpos("'["), [0, 1, 4, 0], 'failed at #145')
  call g:assert.equals(getpos("']"), [0, 3, 3, 0], 'failed at #145')

  %delete

  " #146
  call append(0, ['foobb', 'bbb', 'bbbarbb', 'bbb', 'bbbaz'])
  normal gg4jsriia
  call g:assert.equals(getline(1),   'fooaa',      'failed at #146')
  call g:assert.equals(getline(2),   'aaabaraaa',  'failed at #146')
  call g:assert.equals(getline(3),   'aabaz',      'failed at #146')
  call g:assert.equals(getpos('.'),  [0, 3, 2, 0], 'failed at #146')
  call g:assert.equals(getpos("'["), [0, 1, 4, 0], 'failed at #146')
  call g:assert.equals(getpos("']"), [0, 3, 3, 0], 'failed at #146')

  %delete

  " #147
  call append(0, ['foobb', 'bbb', 'bbbarbb', 'bbb', 'bbbaz'])
  normal gg4jlsriia
  call g:assert.equals(getline(1),   'fooaa',      'failed at #147')
  call g:assert.equals(getline(2),   'aaabaraaa',  'failed at #147')
  call g:assert.equals(getline(3),   'aabaz',      'failed at #147')
  call g:assert.equals(getpos('.'),  [0, 3, 2, 0], 'failed at #147')
  call g:assert.equals(getpos("'["), [0, 1, 4, 0], 'failed at #147')
  call g:assert.equals(getpos("']"), [0, 3, 3, 0], 'failed at #147')

  %delete

  " #148
  call append(0, ['foobb', 'bbb', 'bbbarbb', 'bbb', 'bbbaz'])
  normal gg4j2lsriia
  call g:assert.equals(getline(1),   'fooaa',      'failed at #148')
  call g:assert.equals(getline(2),   'aaabaraaa',  'failed at #148')
  call g:assert.equals(getline(3),   'aabaz',      'failed at #148')
  call g:assert.equals(getpos('.'),  [0, 3, 3, 0], 'failed at #148')
  call g:assert.equals(getpos("'["), [0, 1, 4, 0], 'failed at #148')
  call g:assert.equals(getpos("']"), [0, 3, 3, 0], 'failed at #148')

  %delete

  " #149
  call append(0, ['foobb', 'bbb', 'bbbarbb', 'bbb', 'bbbaz'])
  normal gg4j4lsriia
  call g:assert.equals(getline(1),   'fooaa',      'failed at #149')
  call g:assert.equals(getline(2),   'aaabaraaa',  'failed at #149')
  call g:assert.equals(getline(3),   'aabaz',      'failed at #149')
  call g:assert.equals(getpos('.'),  [0, 3, 5, 0], 'failed at #149')
  call g:assert.equals(getpos("'["), [0, 1, 4, 0], 'failed at #149')
  call g:assert.equals(getpos("']"), [0, 3, 3, 0], 'failed at #149')

  ounmap ii
  call operator#sandwich#set('replace', 'char', 'cursor', 'inner_head')
  unlet! g:operator#sandwich#recipes
  set whichwrap&
endfunction
"}}}
function! s:suite.charwise_n_external_textobj() abort"{{{
  let g:sandwich#recipes = []
  let g:operator#sandwich#recipes = [
        \   {'external': ['i{', 'a{']},
        \   {'external': ['i[', 'a[']},
        \   {'external': ['i(', 'a(']},
        \   {'external': ['it', 'at']},
        \ ]

  " #150
  call setline('.', '{[(foo)]}')
  normal 02lsr5l"
  call g:assert.equals(getline('.'), '{["foo"]}', 'failed at #150')

  " #151
  call setline('.', '{[(foo)]}')
  normal 0lsr7l"
  call g:assert.equals(getline('.'), '{"(foo)"}', 'failed at #151')

  " #152
  call setline('.', '{[(foo)]}')
  normal 0sr9l"
  call g:assert.equals(getline('.'), '"[(foo)]"', 'failed at #152')

  " #153
  call setline('.', '<title>foo</title>')
  normal 0sr$"
  call g:assert.equals(getline('.'), '"foo"', 'failed at #153')

  unlet g:sandwich#recipes
  unlet g:operator#sandwich#recipes
endfunction
"}}}
function! s:suite.charwise_n_option_cursor() abort  "{{{
  """"" cursor
  """ inner_head
  " #154
  call setline('.', '(((foo)))')
  normal 0l2sr%[[
  call g:assert.equals(getline('.'), '([[foo]])',  'failed at #154')
  call g:assert.equals(getpos('.'),  [0, 1, 4, 0], 'failed at #154')

  " #155
  normal 0sra([
  call g:assert.equals(getline('.'), '[[[foo]]]',  'failed at #155')
  call g:assert.equals(getpos('.'),  [0, 1, 2, 0], 'failed at #155')

  """ keep
  " #156
  call operator#sandwich#set('replace', 'char', 'cursor', 'keep')
  call setline('.', '(((foo)))')
  normal 04l2sr2a([[
  call g:assert.equals(getline('.'), '([[foo]])',  'failed at #156')
  call g:assert.equals(getpos('.'),  [0, 1, 5, 0], 'failed at #156')

  " #157
  normal lsra([
  call g:assert.equals(getline('.'), '[[[foo]]]',  'failed at #157')
  call g:assert.equals(getpos('.'),  [0, 1, 6, 0], 'failed at #157')

  """ inner_tail
  " #158
  call operator#sandwich#set('replace', 'char', 'cursor', 'inner_tail')
  call setline('.', '(((foo)))')
  normal 04l2sr2a([[
  call g:assert.equals(getline('.'), '([[foo]])',  'failed at #158')
  call g:assert.equals(getpos('.'),  [0, 1, 6, 0], 'failed at #158')

  " #159
  normal hsra([
  call g:assert.equals(getline('.'), '[[[foo]]]',  'failed at #159')
  call g:assert.equals(getpos('.'),  [0, 1, 8, 0], 'failed at #159')

  """ front
  " #160
  call operator#sandwich#set('replace', 'char', 'cursor', 'front')
  call setline('.', '(((foo)))')
  normal 04l2sr2a([[
  call g:assert.equals(getline('.'), '([[foo]])',  'failed at #160')
  call g:assert.equals(getpos('.'),  [0, 1, 2, 0], 'failed at #160')

  " #161
  normal 3lsra([
  call g:assert.equals(getline('.'), '[[[foo]]]',  'failed at #161')
  call g:assert.equals(getpos('.'),  [0, 1, 1, 0], 'failed at #161')

  """ end
  " #162
  call operator#sandwich#set('replace', 'char', 'cursor', 'end')
  call setline('.', '(((foo)))')
  normal 04l2sr2a([[
  call g:assert.equals(getline('.'), '([[foo]])',  'failed at #162')
  call g:assert.equals(getpos('.'),  [0, 1, 8, 0], 'failed at #162')

  " #163
  normal 3hsra([
  call g:assert.equals(getline('.'), '[[[foo]]]',  'failed at #163')
  call g:assert.equals(getpos('.'),  [0, 1, 9, 0], 'failed at #163')

  call operator#sandwich#set('replace', 'char', 'cursor', 'inner_head')
endfunction
"}}}
function! s:suite.charwise_n_option_noremap() abort  "{{{
  """"" noremap
  let g:sandwich#recipes = []
  let g:operator#sandwich#recipes = [{'external': ['i{', 'a{']}]
  xnoremap i{ i(
  xnoremap a{ a(

  """ on
  " #164
  call setline('.', '{(foo)}')
  normal 0sr7l"
  call g:assert.equals(getline('.'), '"(foo)"', 'failed at #164')

  " #165
  call setline('.', '{(foo)}')
  normal 0lsr5l"
  call g:assert.equals(getline('.'), '{(foo)}', 'failed at #165')

  """ off
  " #166
  call operator#sandwich#set('replace', 'char', 'noremap', 0)
  call setline('.', '{(foo)}')
  normal 0sr7l"
  call g:assert.equals(getline('.'), '{(foo)}', 'failed at #166')

  " #167
  call setline('.', '{(foo)}')
  normal 0lsr5l"
  call g:assert.equals(getline('.'), '{"foo"}', 'failed at #167')

  unlet! g:sandwich#recipes
  unlet! g:operator#sandwich#recipes
  xunmap i{
  xunmap a{
  call operator#sandwich#set('replace', 'char', 'noremap', 1)
endfunction
"}}}
function! s:suite.charwise_n_option_regex() abort  "{{{
  let g:sandwich#recipes = []
  let g:operator#sandwich#recipes = [{'buns': ['\d\+', '\d\+']}]

  """ off
  " #168
  call setline('.', '\d\+foo\d\+')
  normal 0sr$"
  call g:assert.equals(getline('.'), '"foo"', 'failed at #168')

  " #169
  call setline('.', '888foo888')
  normal 0sr$"
  call g:assert.equals(getline('.'), '"88foo88"', 'failed at #169')

  """ on
  call operator#sandwich#set('replace', 'char', 'regex', 1)
  " #170
  call setline('.', '\d\+foo\d\+')
  normal 0sr$"
  call g:assert.equals(getline('.'), '\d\+foo\d\+', 'failed at #170')

  " #171
  call setline('.', '888foo888')
  normal 0sr$"
  call g:assert.equals(getline('.'), '"foo"', 'failed at #171')

  call operator#sandwich#set('replace', 'char', 'regex', 0)
  unlet! g:sandwich#recipes
  unlet! g:operator#sandwich#recipes
endfunction
"}}}
function! s:suite.charwise_n_option_skip_space() abort  "{{{
  """ on
  " #172
  call setline('.', '"foo"')
  normal 0sr$(
  call g:assert.equals(getline('.'), '(foo)', 'failed at #172')

  " #173
  call setline('.', ' "foo"')
  normal 0sr$(
  call g:assert.equals(getline('.'), ' (foo)', 'failed at #173')

  " #174
  call setline('.', '"foo" ')
  normal 0sr$(
  call g:assert.equals(getline('.'), '(foo) ', 'failed at #174')

  " #175
  " do not skip!
  call setline('.', ' "foo" ')
  normal 0sr$(
  call g:assert.equals(getline('.'), '("foo")', 'failed at #175')

  """ off
  call operator#sandwich#set('replace', 'char', 'skip_space', 0)
  " #176
  call setline('.', '"foo"')
  normal 0sr$(
  call g:assert.equals(getline('.'), '(foo)', 'failed at #176')

  " #177
  call setline('.', ' "foo"')
  normal 0sr$(
  call g:assert.equals(getline('.'), ' "foo"', 'failed at #177')

  " #178
  call setline('.', '"foo" ')
  normal 0sr$(
  call g:assert.equals(getline('.'), '"foo" ', 'failed at #178')

  " #179
  " do not skip!
  call setline('.', ' "foo" ')
  normal 0sr$(
  call g:assert.equals(getline('.'), '("foo")', 'failed at #179')

  call operator#sandwich#set('replace', 'char', 'skip_space', 1)
endfunction
"}}}
function! s:suite.charwise_n_option_skip_char() abort "{{{
  """ off
  " #180
  call setline('.', 'aa(foo)bb')
  normal 0sr$"
  call g:assert.equals(getline('.'), 'aa(foo)bb', 'failed at #180')

  """ on
  call operator#sandwich#set('replace', 'char', 'skip_char', 1)
  " #181
  call setline('.', 'aa(foo)bb')
  normal 0sr$"
  call g:assert.equals(getline('.'), 'aa"foo"bb', 'failed at #181')

  call operator#sandwich#set('replace', 'char', 'skip_char', 0)
endfunction
"}}}
function! s:suite.charwise_n_option_command() abort  "{{{
  call operator#sandwich#set('replace', 'char', 'command', ['normal! `[dv`]'])

  " #182
  call setline('.', '(foo)')
  normal 0sra("
  call g:assert.equals(getline('.'), '""', 'failed at #182')

  call operator#sandwich#set('replace', 'char', 'command', [])
endfunction
"}}}
function! s:suite.charwise_n_option_linewise() abort  "{{{
  set whichwrap=h,l
  call operator#sandwich#set('replace', 'char', 'linewise', 1)

  """ 1
  " #183
  call append(0, ['(', 'foo', ')'])
  normal ggsr7l[
  call g:assert.equals(getline(1),   '[',          'failed at #183')
  call g:assert.equals(getline(2),   'foo',        'failed at #183')
  call g:assert.equals(getline(3),   ']',          'failed at #183')
  call g:assert.equals(getpos('.'),  [0, 2, 1, 0], 'failed at #183')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #183')
  call g:assert.equals(getpos("']"), [0, 3, 2, 0], 'failed at #183')

  %delete

  " #184
  call append(0, ['(  ', 'foo', '  )'])
  normal ggsr11l[
  call g:assert.equals(getline(1),   '[',          'failed at #184')
  call g:assert.equals(getline(2),   'foo',        'failed at #184')
  call g:assert.equals(getline(3),   ']',          'failed at #184')
  call g:assert.equals(getpos('.'),  [0, 2, 1, 0], 'failed at #184')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #184')
  call g:assert.equals(getpos("']"), [0, 3, 2, 0], 'failed at #184')

  %delete

  " #185
  call append(0, ['(aa', 'foo', 'aa)'])
  normal ggsr11l[
  call g:assert.equals(getline(1),   '[aa',        'failed at #185')
  call g:assert.equals(getline(2),   'foo',        'failed at #185')
  call g:assert.equals(getline(3),   'aa]',        'failed at #185')
  call g:assert.equals(getpos('.'),  [0, 1, 2, 0], 'failed at #185')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #185')
  call g:assert.equals(getpos("']"), [0, 3, 4, 0], 'failed at #185')

  %delete

  " #186
  call append(0, ['(aa', 'foo', ')'])
  normal ggsr9l[
  call g:assert.equals(getline(1),   '[aa',        'failed at #186')
  call g:assert.equals(getline(2),   'foo',        'failed at #186')
  call g:assert.equals(getline(3),   ']',          'failed at #186')
  call g:assert.equals(getpos('.'),  [0, 1, 2, 0], 'failed at #186')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #186')
  call g:assert.equals(getpos("']"), [0, 3, 2, 0], 'failed at #186')

  %delete

  " #187
  call append(0, ['(', 'foo', 'aa)'])
  normal ggsr9l[
  call g:assert.equals(getline(1),   '[',          'failed at #187')
  call g:assert.equals(getline(2),   'foo',        'failed at #187')
  call g:assert.equals(getline(3),   'aa]',        'failed at #187')
  call g:assert.equals(getpos('.'),  [0, 2, 1, 0], 'failed at #187')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #187')
  call g:assert.equals(getpos("']"), [0, 3, 4, 0], 'failed at #187')

  %delete

  call operator#sandwich#set('replace', 'char', 'linewise', 2)

  """ 2
  " #188
  call append(0, ['(', 'foo', ')'])
  normal ggsr7l[
  call g:assert.equals(getline(1),   '[',          'failed at #188')
  call g:assert.equals(getline(2),   'foo',        'failed at #188')
  call g:assert.equals(getline(3),   ']',          'failed at #188')
  call g:assert.equals(getpos('.'),  [0, 2, 1, 0], 'failed at #188')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #188')
  call g:assert.equals(getpos("']"), [0, 3, 2, 0], 'failed at #188')

  %delete

  " #189
  call append(0, ['(  ', 'foo', '  )'])
  normal ggsr11l[
  call g:assert.equals(getline(1),   '[',          'failed at #189')
  call g:assert.equals(getline(2),   'foo',        'failed at #189')
  call g:assert.equals(getline(3),   ']',          'failed at #189')
  call g:assert.equals(getpos('.'),  [0, 2, 1, 0], 'failed at #189')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #189')
  call g:assert.equals(getpos("']"), [0, 3, 2, 0], 'failed at #189')

  %delete

  " #190
  call append(0, ['(aa', 'foo', 'aa)'])
  normal ggsr11l[
  call g:assert.equals(getline(1),   '[',          'failed at #190')
  call g:assert.equals(getline(2),   'foo',        'failed at #190')
  call g:assert.equals(getline(3),   ']',          'failed at #190')
  call g:assert.equals(getpos('.'),  [0, 2, 1, 0], 'failed at #190')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #190')
  call g:assert.equals(getpos("']"), [0, 3, 2, 0], 'failed at #190')

  %delete

  " #191
  " FIXME: I have no idea what is the expexted behavior.
  call append(0, ['aa', '(foo)', 'bb'])
  normal ggjsr5l[
  call g:assert.equals(getline(1),   'aa',         'failed at #191')
  call g:assert.equals(getline(2),   '[',          'failed at #191')
  call g:assert.equals(getline(3),   'bb',         'failed at #191')
  call g:assert.equals(getline(4),   '',           'failed at #191')
  call g:assert.equals(getpos('.'),  [0, 3, 1, 0], 'failed at #191')
  call g:assert.equals(getpos("'["), [0, 2, 1, 0], 'failed at #191')
  call g:assert.equals(getpos("']"), [0, 3, 1, 0], 'failed at #191')

  set whichwrap&
endfunction
"}}}
function! s:suite.charwise_n_option_query_once() abort  "{{{
  """"" query_once
  """ off
  " #192
  call setline('.', '"""foo"""')
  normal 03sr$([{
  call g:assert.equals(getline('.'), '([{foo}])',  'failed at #192')

  %delete

  """ on
  " #193
  call operator#sandwich#set('replace', 'char', 'query_once', 1)
  call setline('.', '"""foo"""')
  normal 03sr$(
  call g:assert.equals(getline('.'), '(((foo)))',  'failed at #193')

  call operator#sandwich#set('replace', 'char', 'query_once', 0)
endfunction
"}}}
function! s:suite.charwise_n_option_eval() abort "{{{
  """"" eval
  let g:operator#sandwich#recipes = [{'buns': ['1+1', '1+2'], 'input':['a']}]

  """ 0
  " #194
  call setline('.', '"foo"')
  normal 0sra"a
  call g:assert.equals(getline('.'), '1+1foo1+2',  'failed at #194')

  """ 1
  " #195
  call operator#sandwich#set('replace', 'char', 'eval', 1)
  call setline('.', '"foo"')
  normal 0sra"a
  call g:assert.equals(getline('.'), '2foo3',  'failed at #195')

  """ 2
  " This case cannot be tested since this option makes difference only in
  " dot-repeat.

  unlet! g:operator#sandwich#recipes
  call operator#sandwich#set('replace', 'char', 'eval', 0)
endfunction
"}}}

function! s:suite.charwise_x_default_recipes() abort "{{{
  " #196
  call setline('.', '(foo)')
  normal 0va(sr[
  call g:assert.equals(getline('.'), '[foo]',      'failed at #196')
  call g:assert.equals(getpos('.'),  [0, 1, 2, 0], 'failed at #196')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #196')
  call g:assert.equals(getpos("']"), [0, 1, 6, 0], 'failed at #196')

  " #197
  call setline('.', '[foo]')
  normal 0va[sr{
  call g:assert.equals(getline('.'), '{foo}',      'failed at #197')
  call g:assert.equals(getpos('.'),  [0, 1, 2, 0], 'failed at #197')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #197')
  call g:assert.equals(getpos("']"), [0, 1, 6, 0], 'failed at #197')

  " #198
  call setline('.', '{foo}')
  normal 0va{sr<
  call g:assert.equals(getline('.'), '<foo>',      'failed at #198')
  call g:assert.equals(getpos('.'),  [0, 1, 2, 0], 'failed at #198')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #198')
  call g:assert.equals(getpos("']"), [0, 1, 6, 0], 'failed at #198')

  " #199
  call setline('.', '<foo>')
  normal 0va<sr(
  call g:assert.equals(getline('.'), '(foo)',      'failed at #199')
  call g:assert.equals(getpos('.'),  [0, 1, 2, 0], 'failed at #199')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #199')
  call g:assert.equals(getpos("']"), [0, 1, 6, 0], 'failed at #199')

  " #200
  call setline('.', '(foo)')
  normal 0va(sr]
  call g:assert.equals(getline('.'), '[foo]',      'failed at #200')
  call g:assert.equals(getpos('.'),  [0, 1, 2, 0], 'failed at #200')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #200')
  call g:assert.equals(getpos("']"), [0, 1, 6, 0], 'failed at #200')

  " #201
  call setline('.', '[foo]')
  normal 0va[sr}
  call g:assert.equals(getline('.'), '{foo}',      'failed at #201')
  call g:assert.equals(getpos('.'),  [0, 1, 2, 0], 'failed at #201')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #201')
  call g:assert.equals(getpos("']"), [0, 1, 6, 0], 'failed at #201')

  " #202
  call setline('.', '{foo}')
  normal 0va{sr>
  call g:assert.equals(getline('.'), '<foo>',      'failed at #202')
  call g:assert.equals(getpos('.'),  [0, 1, 2, 0], 'failed at #202')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #202')
  call g:assert.equals(getpos("']"), [0, 1, 6, 0], 'failed at #202')

  " #203
  call setline('.', '<foo>')
  normal 0va<sr)
  call g:assert.equals(getline('.'), '(foo)',      'failed at #203')
  call g:assert.equals(getpos('.'),  [0, 1, 2, 0], 'failed at #203')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #203')
  call g:assert.equals(getpos("']"), [0, 1, 6, 0], 'failed at #203')
endfunction
"}}}
function! s:suite.charwise_x_not_registered() abort "{{{
  " #204
  call setline('.', 'afooa')
  normal 0viwsrb
  call g:assert.equals(getline('.'), 'bfoob',      'failed at #204')
  call g:assert.equals(getpos('.'),  [0, 1, 2, 0], 'failed at #204')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #204')
  call g:assert.equals(getpos("']"), [0, 1, 6, 0], 'failed at #204')

  " #205
  call setline('.', '+foo+')
  normal 0v$sr*
  call g:assert.equals(getline('.'), '*foo*',      'failed at #205')
  call g:assert.equals(getpos('.'),  [0, 1, 2, 0], 'failed at #205')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #205')
  call g:assert.equals(getpos("']"), [0, 1, 6, 0], 'failed at #205')
endfunction
"}}}
function! s:suite.charwise_x_positioning() abort "{{{
  " #206
  call setline('.', '(foo)bar')
  normal 0va(sr[
  call g:assert.equals(getline('.'), '[foo]bar',   'failed at #206')
  call g:assert.equals(getpos('.'),  [0, 1, 2, 0], 'failed at #206')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #206')
  call g:assert.equals(getpos("']"), [0, 1, 6, 0], 'failed at #206')

  " #207
  call setline('.', 'foo(bar)')
  normal 0fbva(sr[
  call g:assert.equals(getline('.'), 'foo[bar]',   'failed at #207')
  call g:assert.equals(getpos('.'),  [0, 1, 5, 0], 'failed at #207')
  call g:assert.equals(getpos("'["), [0, 1, 4, 0], 'failed at #207')
  call g:assert.equals(getpos("']"), [0, 1, 9, 0], 'failed at #207')

  " #208
  call setline('.', 'foo(bar)baz')
  normal 0fbva(sr[
  call g:assert.equals(getline('.'), 'foo[bar]baz', 'failed at #208')
  call g:assert.equals(getpos('.'),  [0, 1, 5, 0],  'failed at #208')
  call g:assert.equals(getpos("'["), [0, 1, 4, 0],  'failed at #208')
  call g:assert.equals(getpos("']"), [0, 1, 9, 0],  'failed at #208')

  " #209
  set whichwrap=h,l
  call append(0, ['(foo', 'bar', 'baz)'])
  normal ggv12lsr[
  call g:assert.equals(getline(1),   '[foo',       'failed at #209')
  call g:assert.equals(getline(2),   'bar',        'failed at #209')
  call g:assert.equals(getline(3),   'baz]',       'failed at #209')
  call g:assert.equals(getpos('.'),  [0, 1, 2, 0], 'failed at #209')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #209')
  call g:assert.equals(getpos("']"), [0, 3, 5, 0], 'failed at #209')
  set whichwrap&
endfunction
"}}}
function! s:suite.charwise_x_a_character() abort "{{{
  " #210
  call setline('.', '(a)')
  normal 0va(sr[
  call g:assert.equals(getline('.'), '[a]',        'failed at #210')
  call g:assert.equals(getpos('.'),  [0, 1, 2, 0], 'failed at #210')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #210')
  call g:assert.equals(getpos("']"), [0, 1, 4, 0], 'failed at #210')

  %delete

  " #211
  call append(0, ['(', 'a', ')'])
  normal ggva(sr[
  call g:assert.equals(getline(1),   '[',          'failed at #211')
  call g:assert.equals(getline(2),   'a',          'failed at #211')
  call g:assert.equals(getline(3),   ']',          'failed at #211')
  call g:assert.equals(getpos('.'),  [0, 2, 1, 0], 'failed at #211')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #211')
  call g:assert.equals(getpos("']"), [0, 3, 2, 0], 'failed at #211')

  %delete

  " #212
  call append(0, ['(a', ')'])
  normal ggva(sr[
  call g:assert.equals(getline(1),   '[a',         'failed at #212')
  call g:assert.equals(getline(2),   ']',          'failed at #212')
  call g:assert.equals(getpos('.'),  [0, 1, 2, 0], 'failed at #212')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #212')
  call g:assert.equals(getpos("']"), [0, 2, 2, 0], 'failed at #212')

  %delete

  " #213
  call append(0, ['(', 'a)'])
  normal ggva(sr[
  call g:assert.equals(getline(1),   '[',          'failed at #213')
  call g:assert.equals(getline(2),   'a]',         'failed at #213')
  call g:assert.equals(getpos('.'),  [0, 2, 1, 0], 'failed at #213')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #213')
  call g:assert.equals(getpos("']"), [0, 2, 3, 0], 'failed at #213')
endfunction
"}}}
function! s:suite.charwise_x_nothing_inside() abort "{{{
  " #214
  call setline('.', '()')
  normal 0va(sr[
  call g:assert.equals(getline('.'), '[]',         'failed at #214')
  call g:assert.equals(getpos('.'),  [0, 1, 2, 0], 'failed at #214')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #214')
  call g:assert.equals(getpos("']"), [0, 1, 3, 0], 'failed at #214')

  " #215
  call setline('.', 'foo()bar')
  normal 03lva(sr[
  call g:assert.equals(getline('.'), 'foo[]bar',   'failed at #215')
  call g:assert.equals(getpos('.'),  [0, 1, 5, 0], 'failed at #215')
  call g:assert.equals(getpos("'["), [0, 1, 4, 0], 'failed at #215')
  call g:assert.equals(getpos("']"), [0, 1, 6, 0], 'failed at #215')

  %delete

  " #216
  call append(0, ['(', ')'])
  normal ggva(sr[
  call g:assert.equals(getline(1),   '[',          'failed at #216')
  call g:assert.equals(getline(2),   ']',          'failed at #216')
  call g:assert.equals(getpos('.'),  [0, 2, 1, 0], 'failed at #216')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #216')
  call g:assert.equals(getpos("']"), [0, 2, 2, 0], 'failed at #216')
endfunction
"}}}
function! s:suite.charwise_x_count() abort "{{{
  " #217
  call setline('.', '([foo])')
  normal 0v%2sr[(
  call g:assert.equals(getline('.'), '[(foo)]',    'failed at #217')
  call g:assert.equals(getpos('.'),  [0, 1, 3, 0], 'failed at #217')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #217')
  call g:assert.equals(getpos("']"), [0, 1, 8, 0], 'failed at #217')

  " #218
  call setline('.', '[({foo})]')
  normal 0v%3sr{[(
  call g:assert.equals(getline('.'), '{[(foo)]}',   'failed at #218')
  call g:assert.equals(getpos('.'),  [0, 1,  4, 0], 'failed at #218')
  call g:assert.equals(getpos("'["), [0, 1,  1, 0], 'failed at #218')
  call g:assert.equals(getpos("']"), [0, 1, 10, 0], 'failed at #218')

  " #219
  call setline('.', '{[foo bar]}')
  normal 0v10l2sr[(
  call g:assert.equals(getline('.'), '[(foo bar)]', 'failed at #219')
  call g:assert.equals(getpos('.'),  [0, 1,  3, 0], 'failed at #219')
  call g:assert.equals(getpos("'["), [0, 1,  1, 0], 'failed at #219')
  call g:assert.equals(getpos("']"), [0, 1, 12, 0], 'failed at #219')

  " #220
  call setline('.', 'foo{[bar]}baz')
  normal 03lv6l2sr[(
  call g:assert.equals(getline('.'), 'foo[(bar)]baz', 'failed at #220')
  call g:assert.equals(getpos('.'),  [0, 1,  6, 0],   'failed at #220')
  call g:assert.equals(getpos("'["), [0, 1,  4, 0],   'failed at #220')
  call g:assert.equals(getpos("']"), [0, 1, 11, 0],   'failed at #220')

  " #221
  call setline('.', 'foo({[bar]})baz')
  normal 03lv8l3sr{[(
  call g:assert.equals(getline('.'), 'foo{[(bar)]}baz', 'failed at #221')
  call g:assert.equals(getpos('.'),  [0, 1,  7, 0],     'failed at #221')
  call g:assert.equals(getpos("'["), [0, 1,  4, 0],     'failed at #221')
  call g:assert.equals(getpos("']"), [0, 1, 13, 0],     'failed at #221')
endfunction
"}}}
function! s:suite.charwise_x_breaking() abort "{{{
  set whichwrap=h,l

  let g:operator#sandwich#recipes = [
        \   {'buns': ["aa\naaa", "aaa\naa"], 'input':['a']},
        \   {'buns': ["bb\nbbb\nbb", "bb\nbbb\nbb"], 'input':['b']},
        \ ]

  " #222
  call append(0, ['aa', 'aaafooaaa', 'aa'])
  normal ggv14lsr(
  call g:assert.equals(getline(1),   '(foo)',      'failed at #222')
  call g:assert.equals(getpos('.'),  [0, 1, 2, 0], 'failed at #222')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #222')
  call g:assert.equals(getpos("']"), [0, 1, 6, 0], 'failed at #222')

  %delete

  " #223
  call append(0, ['bb', 'bbb', 'bbfoobb', 'bbb', 'bb'])
  normal ggv20lsr(
  call g:assert.equals(getline(1),   '(foo)',      'failed at #223')
  call g:assert.equals(getpos('.'),  [0, 1, 2, 0], 'failed at #223')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #223')
  call g:assert.equals(getpos("']"), [0, 1, 6, 0], 'failed at #223')

  %delete

  " #224
  call setline('.', '(foo)')
  normal 0v4lsra
  call g:assert.equals(getline(1),   'aa',         'failed at #224')
  call g:assert.equals(getline(2),   'aaafooaaa',  'failed at #224')
  call g:assert.equals(getline(3),   'aa',         'failed at #224')
  call g:assert.equals(getpos('.'),  [0, 2, 4, 0], 'failed at #224')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #224')
  call g:assert.equals(getpos("']"), [0, 3, 3, 0], 'failed at #224')

  %delete

  " #225
  call setline('.', '(foo)')
  normal 0v4lsrb
  call g:assert.equals(getline(1),   'bb',         'failed at #225')
  call g:assert.equals(getline(2),   'bbb',        'failed at #225')
  call g:assert.equals(getline(3),   'bbfoobb',    'failed at #225')
  call g:assert.equals(getline(4),   'bbb',        'failed at #225')
  call g:assert.equals(getline(5),   'bb',         'failed at #225')
  call g:assert.equals(getpos('.'),  [0, 3, 3, 0], 'failed at #225')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #225')
  call g:assert.equals(getpos("']"), [0, 5, 3, 0], 'failed at #225')
endfunction
"}}}
function! s:suite.charwise_x_external_textobj() abort"{{{
  let g:sandwich#recipes = []
  let g:operator#sandwich#recipes = [
        \   {'external': ['i{', 'a{']},
        \   {'external': ['i[', 'a[']},
        \   {'external': ['i(', 'a(']},
        \   {'external': ['it', 'at']},
        \ ]

  " #226
  call setline('.', '{[(foo)]}')
  normal 02lv4lsr"
  call g:assert.equals(getline('.'), '{["foo"]}', 'failed at #226')

  " #227
  call setline('.', '{[(foo)]}')
  normal 0lv6lsr"
  call g:assert.equals(getline('.'), '{"(foo)"}', 'failed at #227')

  " #228
  call setline('.', '{[(foo)]}')
  normal 0v8lsr"
  call g:assert.equals(getline('.'), '"[(foo)]"', 'failed at #228')

  " #229
  call setline('.', '<title>foo</title>')
  normal 0v$sr"
  call g:assert.equals(getline('.'), '"foo"', 'failed at #229')

  unlet g:sandwich#recipes
  unlet g:operator#sandwich#recipes
endfunction
"}}}
function! s:suite.charwise_x_option_cursor() abort  "{{{
  """"" cursor
  """ inner_head
  " #230
  call setline('.', '(((foo)))')
  normal 0lv%2sr[[
  call g:assert.equals(getline('.'), '([[foo]])',  'failed at #230')
  call g:assert.equals(getpos('.'),  [0, 1, 4, 0], 'failed at #230')

  " #231
  normal 0va(sr[
  call g:assert.equals(getline('.'), '[[[foo]]]',  'failed at #231')
  call g:assert.equals(getpos('.'),  [0, 1, 2, 0], 'failed at #231')

  """ keep
  " #232
  call operator#sandwich#set('replace', 'char', 'cursor', 'keep')
  call setline('.', '(((foo)))')
  normal 0lva(2sr[[
  call g:assert.equals(getline('.'), '([[foo]])',  'failed at #232')
  call g:assert.equals(getpos('.'),  [0, 1, 8, 0], 'failed at #232')

  " #233
  normal va(sr[
  call g:assert.equals(getline('.'), '[[[foo]]]',  'failed at #233')
  call g:assert.equals(getpos('.'),  [0, 1, 9, 0], 'failed at #233')

  """ inner_tail
  " #234
  call operator#sandwich#set('replace', 'char', 'cursor', 'inner_tail')
  call setline('.', '(((foo)))')
  normal 0lva(2sr[[
  call g:assert.equals(getline('.'), '([[foo]])',  'failed at #234')
  call g:assert.equals(getpos('.'),  [0, 1, 6, 0], 'failed at #234')

  " #235
  normal va(sr[
  call g:assert.equals(getline('.'), '[[[foo]]]',  'failed at #235')
  call g:assert.equals(getpos('.'),  [0, 1, 8, 0], 'failed at #235')

  """ front
  " #236
  call operator#sandwich#set('replace', 'char', 'cursor', 'front')
  call setline('.', '(((foo)))')
  normal 0lva(2sr[[
  call g:assert.equals(getline('.'), '([[foo]])',  'failed at #236')
  call g:assert.equals(getpos('.'),  [0, 1, 2, 0], 'failed at #236')

  " #237
  normal va(sr[
  call g:assert.equals(getline('.'), '[[[foo]]]',  'failed at #237')
  call g:assert.equals(getpos('.'),  [0, 1, 1, 0], 'failed at #237')

  """ end
  " #238
  call operator#sandwich#set('replace', 'char', 'cursor', 'end')
  call setline('.', '(((foo)))')
  normal 0lva(2sr[[
  call g:assert.equals(getline('.'), '([[foo]])',  'failed at #238')
  call g:assert.equals(getpos('.'),  [0, 1, 8, 0], 'failed at #238')

  " #239
  normal va(sr[
  call g:assert.equals(getline('.'), '[[[foo]]]',  'failed at #239')
  call g:assert.equals(getpos('.'),  [0, 1, 9, 0], 'failed at #239')

  call operator#sandwich#set('replace', 'char', 'cursor', 'inner_head')
endfunction
"}}}
function! s:suite.charwise_x_option_noremap() abort  "{{{
  """"" noremap
  let g:sandwich#recipes = []
  let g:operator#sandwich#recipes = [{'external': ['i{', 'a{']}]
  xnoremap i{ i(
  xnoremap a{ a(

  """ on
  " #240
  call setline('.', '{(foo)}')
  normal 0v6lsr"
  call g:assert.equals(getline('.'), '"(foo)"', 'failed at #240')

  " #241
  call setline('.', '{(foo)}')
  normal 0lv4lsr"
  call g:assert.equals(getline('.'), '{(foo)}', 'failed at #241')

  """ off
  " #242
  call operator#sandwich#set('replace', 'char', 'noremap', 0)
  call setline('.', '{(foo)}')
  normal 0v6lsr"
  call g:assert.equals(getline('.'), '{(foo)}', 'failed at #242')

  " #243
  call setline('.', '{(foo)}')
  normal 0lv4lsr"
  call g:assert.equals(getline('.'), '{"foo"}', 'failed at #243')

  unlet! g:sandwich#recipes
  unlet! g:operator#sandwich#recipes
  xunmap i{
  xunmap a{
  call operator#sandwich#set('replace', 'char', 'noremap', 1)
endfunction
"}}}
function! s:suite.charwise_x_option_regex() abort  "{{{
  let g:sandwich#recipes = []
  let g:operator#sandwich#recipes = [{'buns': ['\d\+', '\d\+']}]

  """ off
  " #244
  call setline('.', '\d\+foo\d\+')
  normal 0v$sr"
  call g:assert.equals(getline('.'), '"foo"', 'failed at #244')

  " #245
  call setline('.', '888foo888')
  normal 0v$sr"
  call g:assert.equals(getline('.'), '"88foo88"', 'failed at #245')

  """ on
  call operator#sandwich#set('replace', 'char', 'regex', 1)
  " #246
  call setline('.', '\d\+foo\d\+')
  normal 0v$sr"
  call g:assert.equals(getline('.'), '\d\+foo\d\+', 'failed at #246')

  " #247
  call setline('.', '888foo888')
  normal 0v$sr"
  call g:assert.equals(getline('.'), '"foo"', 'failed at #247')

  call operator#sandwich#set('replace', 'char', 'regex', 0)
  unlet! g:sandwich#recipes
  unlet! g:operator#sandwich#recipes
endfunction
"}}}
function! s:suite.charwise_x_option_skip_space() abort  "{{{
  """ on
  " #248
  call setline('.', '"foo"')
  normal 0v$sr(
  call g:assert.equals(getline('.'), '(foo)', 'failed at #248')

  " #249
  call setline('.', ' "foo"')
  normal 0v$sr(
  call g:assert.equals(getline('.'), ' (foo)', 'failed at #249')

  " #250
  call setline('.', '"foo" ')
  normal 0v$sr(
  call g:assert.equals(getline('.'), '(foo) ', 'failed at #250')

  " #251
  " do not skip!
  call setline('.', ' "foo" ')
  normal 0v$sr(
  call g:assert.equals(getline('.'), '("foo")', 'failed at #251')

  """ off
  call operator#sandwich#set('replace', 'char', 'skip_space', 0)
  " #252
  call setline('.', '"foo"')
  normal 0v$sr(
  call g:assert.equals(getline('.'), '(foo)', 'failed at #252')

  " #253
  call setline('.', ' "foo"')
  normal 0v$sr(
  call g:assert.equals(getline('.'), ' "foo"', 'failed at #253')

  " #254
  call setline('.', '"foo" ')
  normal 0v$sr(
  call g:assert.equals(getline('.'), '"foo" ', 'failed at #254')

  " #255
  " do not skip!
  call setline('.', ' "foo" ')
  normal 0v$sr(
  call g:assert.equals(getline('.'), '("foo")', 'failed at #255')

  call operator#sandwich#set('replace', 'char', 'skip_space', 1)
endfunction
"}}}
function! s:suite.charwise_x_option_skip_char() abort "{{{
  """ off
  " #256
  call setline('.', 'aa(foo)bb')
  normal 0v$sr"
  call g:assert.equals(getline('.'), 'aa(foo)bb', 'failed at #256')

  """ on
  call operator#sandwich#set('replace', 'char', 'skip_char', 1)
  " #257
  call setline('.', 'aa(foo)bb')
  normal 0v$sr"
  call g:assert.equals(getline('.'), 'aa"foo"bb', 'failed at #257')

  call operator#sandwich#set('replace', 'char', 'skip_char', 0)
endfunction
"}}}
function! s:suite.charwise_x_option_command() abort  "{{{
  call operator#sandwich#set('replace', 'char', 'command', ['normal! `[dv`]'])

  " #258
  call setline('.', '(foo)')
  normal 0va(sr"
  call g:assert.equals(getline('.'), '""', 'failed at #258')

  call operator#sandwich#set('replace', 'char', 'command', [])
endfunction
"}}}
function! s:suite.charwise_x_option_linewise() abort  "{{{
  set whichwrap=h,l
  call operator#sandwich#set('replace', 'char', 'linewise', 1)

  """ 1
  " #259
  call append(0, ['(', 'foo', ')'])
  normal ggv6lsr[
  call g:assert.equals(getline(1),   '[',          'failed at #259')
  call g:assert.equals(getline(2),   'foo',        'failed at #259')
  call g:assert.equals(getline(3),   ']',          'failed at #259')
  call g:assert.equals(getpos('.'),  [0, 2, 1, 0], 'failed at #259')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #259')
  call g:assert.equals(getpos("']"), [0, 3, 2, 0], 'failed at #259')

  %delete

  " #260
  call append(0, ['(  ', 'foo', '  )'])
  normal ggv10lsr[
  call g:assert.equals(getline(1),   '[',          'failed at #260')
  call g:assert.equals(getline(2),   'foo',        'failed at #260')
  call g:assert.equals(getline(3),   ']',          'failed at #260')
  call g:assert.equals(getpos('.'),  [0, 2, 1, 0], 'failed at #260')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #260')
  call g:assert.equals(getpos("']"), [0, 3, 2, 0], 'failed at #260')

  %delete

  " #261
  call append(0, ['(aa', 'foo', 'aa)'])
  normal ggv10lsr[
  call g:assert.equals(getline(1),   '[aa',        'failed at #261')
  call g:assert.equals(getline(2),   'foo',        'failed at #261')
  call g:assert.equals(getline(3),   'aa]',        'failed at #261')
  call g:assert.equals(getpos('.'),  [0, 1, 2, 0], 'failed at #261')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #261')
  call g:assert.equals(getpos("']"), [0, 3, 4, 0], 'failed at #261')

  %delete

  " #262
  call append(0, ['(aa', 'foo', ')'])
  normal ggv8lsr[
  call g:assert.equals(getline(1),   '[aa',        'failed at #262')
  call g:assert.equals(getline(2),   'foo',        'failed at #262')
  call g:assert.equals(getline(3),   ']',          'failed at #262')
  call g:assert.equals(getpos('.'),  [0, 1, 2, 0], 'failed at #262')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #262')
  call g:assert.equals(getpos("']"), [0, 3, 2, 0], 'failed at #262')

  %delete

  " #263
  call append(0, ['(', 'foo', 'aa)'])
  normal ggv8lsr[
  call g:assert.equals(getline(1),   '[',          'failed at #263')
  call g:assert.equals(getline(2),   'foo',        'failed at #263')
  call g:assert.equals(getline(3),   'aa]',        'failed at #263')
  call g:assert.equals(getpos('.'),  [0, 2, 1, 0], 'failed at #263')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #263')
  call g:assert.equals(getpos("']"), [0, 3, 4, 0], 'failed at #263')

  %delete

  call operator#sandwich#set('replace', 'char', 'linewise', 2)

  """ 2
  " #264
  call append(0, ['(', 'foo', ')'])
  normal ggv6lsr[
  call g:assert.equals(getline(1),   '[',          'failed at #264')
  call g:assert.equals(getline(2),   'foo',        'failed at #264')
  call g:assert.equals(getline(3),   ']',          'failed at #264')
  call g:assert.equals(getpos('.'),  [0, 2, 1, 0], 'failed at #264')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #264')
  call g:assert.equals(getpos("']"), [0, 3, 2, 0], 'failed at #264')

  %delete

  " #265
  call append(0, ['(  ', 'foo', '  )'])
  normal ggv10lsr[
  call g:assert.equals(getline(1),   '[',          'failed at #265')
  call g:assert.equals(getline(2),   'foo',        'failed at #265')
  call g:assert.equals(getline(3),   ']',          'failed at #265')
  call g:assert.equals(getpos('.'),  [0, 2, 1, 0], 'failed at #265')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #265')
  call g:assert.equals(getpos("']"), [0, 3, 2, 0], 'failed at #265')

  %delete

  " #266
  call append(0, ['(aa', 'foo', 'aa)'])
  normal ggv10lsr[
  call g:assert.equals(getline(1),   '[',          'failed at #266')
  call g:assert.equals(getline(2),   'foo',        'failed at #266')
  call g:assert.equals(getline(3),   ']',          'failed at #266')
  call g:assert.equals(getpos('.'),  [0, 2, 1, 0], 'failed at #266')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #266')
  call g:assert.equals(getpos("']"), [0, 3, 2, 0], 'failed at #266')

  %delete

  " #267
  " FIXME: I have no idea what is the expexted behavior.
  call append(0, ['aa', '(foo)', 'bb'])
  normal ggjv4lsr[
  call g:assert.equals(getline(1),   'aa',         'failed at #267')
  call g:assert.equals(getline(2),   '[',          'failed at #267')
  call g:assert.equals(getline(3),   'bb',         'failed at #267')
  call g:assert.equals(getline(4),   '',           'failed at #267')
  call g:assert.equals(getpos('.'),  [0, 3, 1, 0], 'failed at #267')
  call g:assert.equals(getpos("'["), [0, 2, 1, 0], 'failed at #267')
  call g:assert.equals(getpos("']"), [0, 3, 1, 0], 'failed at #267')

  set whichwrap&
endfunction
"}}}

" line-wise
function! s:suite.linewise_n_default_recipes() abort "{{{
  " #268
  call setline('.', '(foo)')
  normal srVl[
  call g:assert.equals(getline('.'), '[foo]',      'failed at #268')
  call g:assert.equals(getpos('.'),  [0, 1, 2, 0], 'failed at #268')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #268')
  call g:assert.equals(getpos("']"), [0, 1, 6, 0], 'failed at #268')

  " #269
  call setline('.', '[foo]')
  normal srVl{
  call g:assert.equals(getline('.'), '{foo}',      'failed at #269')
  call g:assert.equals(getpos('.'),  [0, 1, 2, 0], 'failed at #269')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #269')
  call g:assert.equals(getpos("']"), [0, 1, 6, 0], 'failed at #269')

  " #270
  call setline('.', '{foo}')
  normal srVl<
  call g:assert.equals(getline('.'), '<foo>',      'failed at #270')
  call g:assert.equals(getpos('.'),  [0, 1, 2, 0], 'failed at #270')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #270')
  call g:assert.equals(getpos("']"), [0, 1, 6, 0], 'failed at #270')

  " #271
  call setline('.', '<foo>')
  normal srVl(
  call g:assert.equals(getline('.'), '(foo)',      'failed at #271')
  call g:assert.equals(getpos('.'),  [0, 1, 2, 0], 'failed at #271')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #271')
  call g:assert.equals(getpos("']"), [0, 1, 6, 0], 'failed at #271')

  %delete

  " #272
  call append(0, ['(', 'foo', ')'])
  normal ggsr2j]
  call g:assert.equals(getline(1),   '[',          'failed at #272')
  call g:assert.equals(getline(2),   'foo',        'failed at #272')
  call g:assert.equals(getline(3),   ']',          'failed at #272')
  call g:assert.equals(getpos('.'),  [0, 2, 1, 0], 'failed at #272')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #272')
  call g:assert.equals(getpos("']"), [0, 3, 2, 0], 'failed at #272')

  " #273
  call append(0, ['[', 'foo', ']'])
  normal ggsr2j}
  call g:assert.equals(getline(1),   '{',          'failed at #273')
  call g:assert.equals(getline(2),   'foo',        'failed at #273')
  call g:assert.equals(getline(3),   '}',          'failed at #273')
  call g:assert.equals(getpos('.'),  [0, 2, 1, 0], 'failed at #273')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #273')
  call g:assert.equals(getpos("']"), [0, 3, 2, 0], 'failed at #273')

  " #274
  call append(0, ['{', 'foo', '}'])
  normal ggsr2j>
  call g:assert.equals(getline(1),   '<',          'failed at #274')
  call g:assert.equals(getline(2),   'foo',        'failed at #274')
  call g:assert.equals(getline(3),   '>',          'failed at #274')
  call g:assert.equals(getpos('.'),  [0, 2, 1, 0], 'failed at #274')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #274')
  call g:assert.equals(getpos("']"), [0, 3, 2, 0], 'failed at #274')

  " #275
  call append(0, ['<', 'foo', '>'])
  normal ggsr2j)
  call g:assert.equals(getline(1),   '(',          'failed at #275')
  call g:assert.equals(getline(2),   'foo',        'failed at #275')
  call g:assert.equals(getline(3),   ')',          'failed at #275')
  call g:assert.equals(getpos('.'),  [0, 2, 1, 0], 'failed at #275')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #275')
  call g:assert.equals(getpos("']"), [0, 3, 2, 0], 'failed at #275')
endfunction
"}}}
function! s:suite.linewise_n_not_registered() abort "{{{
  " #276
  call setline('.', 'afooa')
  normal srVlb
  call g:assert.equals(getline('.'), 'bfoob',      'failed at #276')
  call g:assert.equals(getpos('.'),  [0, 1, 2, 0], 'failed at #276')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #276')
  call g:assert.equals(getpos("']"), [0, 1, 6, 0], 'failed at #276')

  " #277
  call setline('.', '+foo+')
  normal srVl*
  call g:assert.equals(getline('.'), '*foo*',      'failed at #277')
  call g:assert.equals(getpos('.'),  [0, 1, 2, 0], 'failed at #277')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #277')
  call g:assert.equals(getpos("']"), [0, 1, 6, 0], 'failed at #277')

  %delete

  " #276
  call append(0, ['a', 'foo', 'a'])
  normal ggsr2jb
  call g:assert.equals(getline(1),   'b',          'failed at #276')
  call g:assert.equals(getline(2),   'foo',        'failed at #276')
  call g:assert.equals(getline(3),   'b',          'failed at #276')
  call g:assert.equals(getpos('.'),  [0, 2, 1, 0], 'failed at #276')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #276')
  call g:assert.equals(getpos("']"), [0, 3, 2, 0], 'failed at #276')

  %delete

  " #277
  call append(0, ['+', 'foo', '+'])
  normal ggsr2j*
  call g:assert.equals(getline(1),   '*',          'failed at #277')
  call g:assert.equals(getline(2),   'foo',        'failed at #277')
  call g:assert.equals(getline(3),   '*',          'failed at #277')
  call g:assert.equals(getpos('.'),  [0, 2, 1, 0], 'failed at #277')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #277')
  call g:assert.equals(getpos("']"), [0, 3, 2, 0], 'failed at #277')
endfunction
"}}}
function! s:suite.linewise_n_positioning() abort "{{{
  " #278
  call append(0, ['(', 'foo', 'bar', 'baz', ')'])
  normal ggsrVa([
  call g:assert.equals(getline(1),   '[',          'failed at #278')
  call g:assert.equals(getline(2),   'foo',        'failed at #278')
  call g:assert.equals(getline(3),   'bar',        'failed at #278')
  call g:assert.equals(getline(4),   'baz',        'failed at #278')
  call g:assert.equals(getline(5),   ']',          'failed at #278')
  call g:assert.equals(getpos('.'),  [0, 2, 1, 0], 'failed at #278')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #278')
  call g:assert.equals(getpos("']"), [0, 5, 2, 0], 'failed at #278')

  %delete

  " #279
  call append(0, ['foo', '(', 'bar', ')', 'baz'])
  normal gg2jsrVa([
  call g:assert.equals(getline(1),   'foo',        'failed at #279')
  call g:assert.equals(getline(2),   '[',          'failed at #279')
  call g:assert.equals(getline(3),   'bar',        'failed at #279')
  call g:assert.equals(getline(4),   ']',          'failed at #279')
  call g:assert.equals(getline(5),   'baz',        'failed at #279')
  call g:assert.equals(getpos('.'),  [0, 3, 1, 0], 'failed at #279')
  call g:assert.equals(getpos("'["), [0, 2, 1, 0], 'failed at #279')
  call g:assert.equals(getpos("']"), [0, 4, 2, 0], 'failed at #279')

  %delete

  " #280
  call append(0, ['(foo', 'bar', 'baz)'])
  normal ggsrVa([
  call g:assert.equals(getline(1),   '[foo',       'failed at #280')
  call g:assert.equals(getline(2),   'bar',        'failed at #280')
  call g:assert.equals(getline(3),   'baz]',       'failed at #280')
  call g:assert.equals(getpos('.'),  [0, 1, 2, 0], 'failed at #280')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #280')
  call g:assert.equals(getpos("']"), [0, 3, 5, 0], 'failed at #280')
endfunction
"}}}
function! s:suite.linewise_n_nothing_inside() abort "{{{
  " #281
  call setline('.', '()')
  normal srVa([
  call g:assert.equals(getline('.'), '[]',         'failed at #281')
  call g:assert.equals(getpos('.'),  [0, 1, 2, 0], 'failed at #281')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #281')
  call g:assert.equals(getpos("']"), [0, 1, 3, 0], 'failed at #281')

  %delete

  " #282
  call append(0, ['(', ')'])
  normal ggsrVa([
  call g:assert.equals(getline(1),   '[',          'failed at #282')
  call g:assert.equals(getline(2),   ']',          'failed at #282')
  call g:assert.equals(getpos('.'),  [0, 1, 1, 0], 'failed at #282')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #282')
  call g:assert.equals(getpos("']"), [0, 2, 2, 0], 'failed at #282')
endfunction
"}}}
function! s:suite.linewise_n_count() abort "{{{
  " #283
  call setline('.', '([foo])')
  normal 2srVl[(
  call g:assert.equals(getline('.'), '[(foo)]',    'failed at #283')
  call g:assert.equals(getpos('.'),  [0, 1, 3, 0], 'failed at #283')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #283')
  call g:assert.equals(getpos("']"), [0, 1, 8, 0], 'failed at #283')

  " #284
  call setline('.', '[({foo})]')
  normal 3srVl{[(
  call g:assert.equals(getline('.'), '{[(foo)]}',   'failed at #284')
  call g:assert.equals(getpos('.'),  [0, 1,  4, 0], 'failed at #284')
  call g:assert.equals(getpos("'["), [0, 1,  1, 0], 'failed at #284')
  call g:assert.equals(getpos("']"), [0, 1, 10, 0], 'failed at #284')

  %delete

  " #285
  call append(0, ['foo', '{', '[', '(', 'bar', ')', ']', '}', 'baz'])
  normal ggj3sr6j({[
  call g:assert.equals(getline(1),   'foo',        'failed at #285')
  call g:assert.equals(getline(2),   '(',          'failed at #285')
  call g:assert.equals(getline(3),   '{',          'failed at #285')
  call g:assert.equals(getline(4),   '[',          'failed at #285')
  call g:assert.equals(getline(5),   'bar',        'failed at #285')
  call g:assert.equals(getline(6),   ']',          'failed at #285')
  call g:assert.equals(getline(7),   '}',          'failed at #285')
  call g:assert.equals(getline(8),   ')',          'failed at #285')
  call g:assert.equals(getline(9),   'baz',        'failed at #285')
  call g:assert.equals(getpos('.'),  [0, 5, 1, 0], 'failed at #285')
  call g:assert.equals(getpos("'["), [0, 2, 1, 0], 'failed at #285')
  call g:assert.equals(getpos("']"), [0, 8, 2, 0], 'failed at #285')
endfunction
"}}}
function! s:suite.linewise_n_breaking() abort "{{{
  let g:operator#sandwich#recipes = [
        \   {'buns': ["aa\naaa", "aaa\naa"], 'input':['a']},
        \   {'buns': ["bb\nbbb\nbb", "bb\nbbb\nbb"], 'input':['b']},
        \ ]

  " #286
  call append(0, ['aa', 'aaafooaaa', 'aa'])
  normal ggsr2j(
  call g:assert.equals(getline(1),   '(foo)',      'failed at #286')
  call g:assert.equals(getpos('.'),  [0, 1, 2, 0], 'failed at #286')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #286')
  call g:assert.equals(getpos("']"), [0, 1, 6, 0], 'failed at #286')

  %delete

  " #287
  call append(0, ['bb', 'bbb', 'bbfoobb', 'bbb', 'bb'])
  normal ggsr4j(
  call g:assert.equals(getline(1),   '(foo)',      'failed at #287')
  call g:assert.equals(getpos('.'),  [0, 1, 2, 0], 'failed at #287')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #287')
  call g:assert.equals(getpos("']"), [0, 1, 6, 0], 'failed at #287')

  %delete

  " #288
  call setline('.', '(foo)')
  normal srVla
  call g:assert.equals(getline(1),   'aa',         'failed at #288')
  call g:assert.equals(getline(2),   'aaafooaaa',  'failed at #288')
  call g:assert.equals(getline(3),   'aa',         'failed at #288')
  call g:assert.equals(getpos('.'),  [0, 2, 4, 0], 'failed at #288')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #288')
  call g:assert.equals(getpos("']"), [0, 3, 3, 0], 'failed at #288')

  %delete

  " #289
  call setline('.', '(foo)')
  normal srVlb
  call g:assert.equals(getline(1),   'bb',         'failed at #289')
  call g:assert.equals(getline(2),   'bbb',        'failed at #289')
  call g:assert.equals(getline(3),   'bbfoobb',    'failed at #289')
  call g:assert.equals(getline(4),   'bbb',        'failed at #289')
  call g:assert.equals(getline(5),   'bb',         'failed at #289')
  call g:assert.equals(getpos('.'),  [0, 3, 3, 0], 'failed at #289')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #289')
  call g:assert.equals(getpos("']"), [0, 5, 3, 0], 'failed at #289')

  %delete

  " #290
  call append(0, ['aa', 'aaa', 'aa', 'aaa', 'foo', 'aaa', 'aa', 'aaa', 'aa'])
  normal gg2sr8j((
  call g:assert.equals(getline(1),   '(',          'failed at #290')
  call g:assert.equals(getline(2),   '(',          'failed at #290')
  call g:assert.equals(getline(3),   'foo',        'failed at #290')
  call g:assert.equals(getline(4),   ')',          'failed at #290')
  call g:assert.equals(getline(5),   ')',          'failed at #290')
  call g:assert.equals(getpos('.'),  [0, 3, 1, 0], 'failed at #290')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #290')
  call g:assert.equals(getpos("']"), [0, 5, 2, 0], 'failed at #290')

  %delete

  " #291
  call append(0, ['bb', 'bbb', 'bb', 'bb', 'bbb', 'bb', 'foo', 'bb', 'bbb', 'bb', 'bb', 'bbb', 'bb'])
  normal gg2sr12j((
  call g:assert.equals(getline(1),   '(',          'failed at #291')
  call g:assert.equals(getline(2),   '(',          'failed at #291')
  call g:assert.equals(getline(3),   'foo',        'failed at #291')
  call g:assert.equals(getline(4),   ')',          'failed at #291')
  call g:assert.equals(getline(5),   ')',          'failed at #291')
  call g:assert.equals(getpos('.'),  [0, 3, 1, 0], 'failed at #291')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #291')
  call g:assert.equals(getpos("']"), [0, 5, 2, 0], 'failed at #291')

  unlet! g:operator#sandwich#recipes
endfunction
"}}}
function! s:suite.linewise_n_external_textobj() abort"{{{
  let g:sandwich#recipes = []
  let g:operator#sandwich#recipes = [
        \   {'external': ['i{', 'a{']},
        \   {'external': ['i[', 'a[']},
        \   {'external': ['i(', 'a(']},
        \   {'external': ['it', 'at']},
        \ ]

  " #292
  call setline('.', '(foo)')
  normal srVl"
  call g:assert.equals(getline('.'), '"foo"', 'failed at #292')

  " #293
  call setline('.', '[foo]')
  normal srVl"
  call g:assert.equals(getline('.'), '"foo"', 'failed at #293')

  " #294
  call setline('.', '{foo}')
  normal srVl"
  call g:assert.equals(getline('.'), '"foo"', 'failed at #294')

  " #295
  call setline('.', '<title>foo</title>')
  normal srVl"
  call g:assert.equals(getline('.'), '"foo"', 'failed at #295')

  unlet g:sandwich#recipes
  unlet g:operator#sandwich#recipes
endfunction
"}}}
function! s:suite.linewise_n_option_cursor() abort  "{{{
  """"" cursor
  """ inner_head
  " #296
  call setline('.', '(((foo)))')
  normal 02srVl[[
  call g:assert.equals(getline('.'), '[[(foo)]]',  'failed at #296')
  call g:assert.equals(getpos('.'),  [0, 1, 3, 0], 'failed at #296')

  " #297
  normal srVl(
  call g:assert.equals(getline('.'), '([(foo)])',  'failed at #297')
  call g:assert.equals(getpos('.'),  [0, 1, 2, 0], 'failed at #297')

  """ keep
  " #298
  call operator#sandwich#set('replace', 'line', 'cursor', 'keep')
  call setline('.', '(((foo)))')
  normal 04l2srVl[[
  call g:assert.equals(getline('.'), '[[(foo)]]',  'failed at #298')
  call g:assert.equals(getpos('.'),  [0, 1, 5, 0], 'failed at #298')

  " #299
  normal lsrVl(
  call g:assert.equals(getline('.'), '([(foo)])',  'failed at #299')
  call g:assert.equals(getpos('.'),  [0, 1, 6, 0], 'failed at #299')

  """ inner_tail
  " #300
  call operator#sandwich#set('replace', 'line', 'cursor', 'inner_tail')
  call setline('.', '(((foo)))')
  normal 04l2srVl[[
  call g:assert.equals(getline('.'), '[[(foo)]]',  'failed at #300')
  call g:assert.equals(getpos('.'),  [0, 1, 7, 0], 'failed at #300')

  " #301
  normal hsrVl(
  call g:assert.equals(getline('.'), '([(foo)])',  'failed at #301')
  call g:assert.equals(getpos('.'),  [0, 1, 8, 0], 'failed at #301')

  """ front
  " #302
  call operator#sandwich#set('replace', 'line', 'cursor', 'front')
  call setline('.', '(((foo)))')
  normal 04l2srVl[[
  call g:assert.equals(getline('.'), '[[(foo)]]',  'failed at #302')
  call g:assert.equals(getpos('.'),  [0, 1, 1, 0], 'failed at #302')

  " #303
  normal 3lsrVl(
  call g:assert.equals(getline('.'), '([(foo)])',  'failed at #303')
  call g:assert.equals(getpos('.'),  [0, 1, 1, 0], 'failed at #303')

  """ end
  " #304
  call operator#sandwich#set('replace', 'line', 'cursor', 'end')
  call setline('.', '(((foo)))')
  normal 04l2srVl[[
  call g:assert.equals(getline('.'), '[[(foo)]]',  'failed at #304')
  call g:assert.equals(getpos('.'),  [0, 1, 9, 0], 'failed at #304')

  " #305
  normal 3hsrVl(
  call g:assert.equals(getline('.'), '([(foo)])',  'failed at #305')
  call g:assert.equals(getpos('.'),  [0, 1, 9, 0], 'failed at #305')

  call operator#sandwich#set('replace', 'line', 'cursor', 'inner_head')
endfunction
"}}}
function! s:suite.linewise_n_option_noremap() abort  "{{{
  """"" noremap
  let g:sandwich#recipes = []
  let g:operator#sandwich#recipes = [{'external': ['i{', 'a{']}]
  xnoremap i{ i(
  xnoremap a{ a(

  """ on
  " #306
  call setline('.', '{foo}')
  normal 0srVl"
  call g:assert.equals(getline('.'), '"foo"', 'failed at #306')

  " #307
  call setline('.', '(foo)')
  normal 0srVl"
  call g:assert.equals(getline('.'), '(foo)', 'failed at #307')

  """ off
  " #308
  call operator#sandwich#set('replace', 'line', 'noremap', 0)
  call setline('.', '{foo}')
  normal 0srVl"
  call g:assert.equals(getline('.'), '{foo}', 'failed at #308')

  " #309
  call setline('.', '(foo)')
  normal 0srVl"
  call g:assert.equals(getline('.'), '"foo"', 'failed at #309')

  unlet! g:sandwich#recipes
  unlet! g:operator#sandwich#recipes
  xunmap i{
  xunmap a{
  call operator#sandwich#set('replace', 'line', 'noremap', 1)
endfunction
"}}}
function! s:suite.linewise_n_option_regex() abort  "{{{
  let g:sandwich#recipes = []
  let g:operator#sandwich#recipes = [{'buns': ['\d\+', '\d\+']}]

  """ off
  " #310
  call setline('.', '\d\+foo\d\+')
  normal 0srVl"
  call g:assert.equals(getline('.'), '"foo"', 'failed at #310')

  " #311
  call setline('.', '888foo888')
  normal 0srVl"
  call g:assert.equals(getline('.'), '"88foo88"', 'failed at #311')

  """ on
  call operator#sandwich#set('replace', 'line', 'regex', 1)
  " #312
  call setline('.', '\d\+foo\d\+')
  normal 0srVl"
  call g:assert.equals(getline('.'), '\d\+foo\d\+', 'failed at #312')

  " #313
  call setline('.', '888foo888')
  normal 0srVl"
  call g:assert.equals(getline('.'), '"foo"', 'failed at #313')

  call operator#sandwich#set('replace', 'line', 'regex', 0)
  unlet! g:sandwich#recipes
  unlet! g:operator#sandwich#recipes
endfunction
"}}}
function! s:suite.linewise_n_option_skip_space() abort  "{{{
  """ on
  " #314
  call setline('.', '"foo"')
  normal 0srVl(
  call g:assert.equals(getline('.'), '(foo)', 'failed at #314')

  " #315
  call setline('.', ' "foo"')
  normal 0srVl(
  call g:assert.equals(getline('.'), ' (foo)', 'failed at #315')

  " #316
  call setline('.', '"foo" ')
  normal 0srVl(
  call g:assert.equals(getline('.'), '(foo) ', 'failed at #316')

  " #317
  " do not skip!
  call setline('.', ' "foo" ')
  normal 0srVl(
  call g:assert.equals(getline('.'), '("foo")', 'failed at #317')

  """ off
  call operator#sandwich#set('replace', 'line', 'skip_space', 0)
  " #318
  call setline('.', '"foo"')
  normal 0srVl(
  call g:assert.equals(getline('.'), '(foo)', 'failed at #318')

  " #319
  call setline('.', ' "foo"')
  normal 0srVl(
  call g:assert.equals(getline('.'), ' "foo"', 'failed at #319')

  " #320
  call setline('.', '"foo" ')
  normal 0srVl(
  call g:assert.equals(getline('.'), '"foo" ', 'failed at #320')

  " #321
  " do not skip!
  call setline('.', ' "foo" ')
  normal 0srVl(
  call g:assert.equals(getline('.'), '("foo")', 'failed at #321')

  call operator#sandwich#set('replace', 'line', 'skip_space', 1)
endfunction
"}}}
function! s:suite.linewise_n_option_skip_char() abort "{{{
  """ off
  " #322
  call setline('.', 'aa(foo)bb')
  normal 0srVl"
  call g:assert.equals(getline('.'), 'aa(foo)bb', 'failed at #322')

  """ on
  call operator#sandwich#set('replace', 'line', 'skip_char', 1)
  " #323
  call setline('.', 'aa(foo)bb')
  normal 0srVl"
  call g:assert.equals(getline('.'), 'aa"foo"bb', 'failed at #323')

  call operator#sandwich#set('replace', 'line', 'skip_char', 0)
endfunction
"}}}
function! s:suite.linewise_n_option_command() abort  "{{{
  call operator#sandwich#set('replace', 'line', 'command', ['normal! `[dv`]'])

  " #324
  call setline('.', '(foo)')
  normal 0srVl"
  call g:assert.equals(getline('.'), '""', 'failed at #324')

  call operator#sandwich#set('replace', 'line', 'command', [])
endfunction
"}}}
function! s:suite.linewise_n_option_linewise() abort  "{{{
  call operator#sandwich#set('replace', 'line', 'linewise', 0)

  """ 0
  " #325
  call append(0, ['(', 'foo', ')'])
  normal ggsr2j[
  call g:assert.equals(getline(1),   '[',          'failed at #325')
  call g:assert.equals(getline(2),   'foo',        'failed at #325')
  call g:assert.equals(getline(3),   ']',          'failed at #325')
  call g:assert.equals(getpos('.'),  [0, 2, 1, 0], 'failed at #325')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #325')
  call g:assert.equals(getpos("']"), [0, 3, 2, 0], 'failed at #325')

  %delete

  " #326
  call append(0, ['(  ', 'foo', '  )'])
  normal ggsr2j[
  call g:assert.equals(getline(1),   '[  ',        'failed at #326')
  call g:assert.equals(getline(2),   'foo',        'failed at #326')
  call g:assert.equals(getline(3),   '  ]',        'failed at #326')
  call g:assert.equals(getpos('.'),  [0, 1, 2, 0], 'failed at #326')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #326')
  call g:assert.equals(getpos("']"), [0, 3, 4, 0], 'failed at #326')

  %delete

  " #327
  call append(0, ['(aa', 'foo', 'aa)'])
  normal ggsr2j[
  call g:assert.equals(getline(1),   '[aa',        'failed at #327')
  call g:assert.equals(getline(2),   'foo',        'failed at #327')
  call g:assert.equals(getline(3),   'aa]',        'failed at #327')
  call g:assert.equals(getpos('.'),  [0, 1, 2, 0], 'failed at #327')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #327')
  call g:assert.equals(getpos("']"), [0, 3, 4, 0], 'failed at #327')

  %delete

  " #328
  call append(0, ['(aa', 'foo', ')'])
  normal ggsr2j[
  call g:assert.equals(getline(1),   '[aa',        'failed at #328')
  call g:assert.equals(getline(2),   'foo',        'failed at #328')
  call g:assert.equals(getline(3),   ']',          'failed at #328')
  call g:assert.equals(getpos('.'),  [0, 1, 2, 0], 'failed at #328')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #328')
  call g:assert.equals(getpos("']"), [0, 3, 2, 0], 'failed at #328')

  %delete

  " #329
  call append(0, ['(', 'foo', 'aa)'])
  normal ggsr2j[
  call g:assert.equals(getline(1),   '[',          'failed at #329')
  call g:assert.equals(getline(2),   'foo',        'failed at #329')
  call g:assert.equals(getline(3),   'aa]',        'failed at #329')
  call g:assert.equals(getpos('.'),  [0, 2, 1, 0], 'failed at #329')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #329')
  call g:assert.equals(getpos("']"), [0, 3, 4, 0], 'failed at #329')

  %delete

  call operator#sandwich#set('replace', 'line', 'linewise', 2)

  """ 2
  " #330
  call append(0, ['(', 'foo', ')'])
  normal ggsr2j[
  call g:assert.equals(getline(1),   '[',          'failed at #330')
  call g:assert.equals(getline(2),   'foo',        'failed at #330')
  call g:assert.equals(getline(3),   ']',          'failed at #330')
  call g:assert.equals(getpos('.'),  [0, 2, 1, 0], 'failed at #330')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #330')
  call g:assert.equals(getpos("']"), [0, 3, 2, 0], 'failed at #330')

  %delete

  " #331
  call append(0, ['(  ', 'foo', '  )'])
  normal ggsr2j[
  call g:assert.equals(getline(1),   '[',          'failed at #331')
  call g:assert.equals(getline(2),   'foo',        'failed at #331')
  call g:assert.equals(getline(3),   ']',          'failed at #331')
  call g:assert.equals(getpos('.'),  [0, 2, 1, 0], 'failed at #331')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #331')
  call g:assert.equals(getpos("']"), [0, 3, 2, 0], 'failed at #331')

  %delete

  " #332
  call append(0, ['(aa', 'foo', 'aa)'])
  normal ggsr2j[
  call g:assert.equals(getline(1),   '[',          'failed at #332')
  call g:assert.equals(getline(2),   'foo',        'failed at #332')
  call g:assert.equals(getline(3),   ']',          'failed at #332')
  call g:assert.equals(getpos('.'),  [0, 2, 1, 0], 'failed at #332')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #332')
  call g:assert.equals(getpos("']"), [0, 3, 2, 0], 'failed at #332')

  %delete

  " #333
  " FIXME: I have no idea what is the expexted behavior.
  call append(0, ['aa', '(foo)', 'bb'])
  normal ggjsrVl[
  call g:assert.equals(getline(1),   'aa',         'failed at #333')
  call g:assert.equals(getline(2),   '[',          'failed at #333')
  call g:assert.equals(getline(3),   'bb',         'failed at #333')
  call g:assert.equals(getline(4),   '',           'failed at #333')
  call g:assert.equals(getpos('.'),  [0, 3, 1, 0], 'failed at #333')
  call g:assert.equals(getpos("'["), [0, 2, 1, 0], 'failed at #333')
  call g:assert.equals(getpos("']"), [0, 3, 1, 0], 'failed at #333')
endfunction
"}}}
function! s:suite.linewise_n_option_query_once() abort  "{{{
  """"" query_once
  """ off
  " #334
  call setline('.', '"""foo"""')
  normal 03srVl([{
  call g:assert.equals(getline('.'), '([{foo}])',  'failed at #334')

  %delete

  """ on
  " #335
  call operator#sandwich#set('replace', 'line', 'query_once', 1)
  call setline('.', '"""foo"""')
  normal 03srVl(
  call g:assert.equals(getline('.'), '(((foo)))',  'failed at #335')

  call operator#sandwich#set('replace', 'line', 'query_once', 0)
endfunction
"}}}
function! s:suite.linewise_n_option_eval() abort "{{{
  """"" eval
  let g:operator#sandwich#recipes = [{'buns': ['1+1', '1+2'], 'input':['a']}]

  """ 0
  " #336
  call setline('.', '"foo"')
  normal 0srVla
  call g:assert.equals(getline('.'), '1+1foo1+2',  'failed at #336')

  """ 1
  " #337
  call operator#sandwich#set('replace', 'line', 'eval', 1)
  call setline('.', '"foo"')
  normal 0srVla
  call g:assert.equals(getline('.'), '2foo3',  'failed at #337')

  """ 2
  " This case cannot be tested since this option makes difference only in
  " dot-repeat.

  unlet! g:operator#sandwich#recipes
  call operator#sandwich#set('replace', 'line', 'eval', 0)
endfunction
"}}}

function! s:suite.linewise_x_default_recipes() abort "{{{
  " #338
  call setline('.', '(foo)')
  normal Vsr[
  call g:assert.equals(getline('.'), '[foo]',      'failed at #338')
  call g:assert.equals(getpos('.'),  [0, 1, 2, 0], 'failed at #338')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #338')
  call g:assert.equals(getpos("']"), [0, 1, 6, 0], 'failed at #338')

  " #339
  call setline('.', '[foo]')
  normal Vsr{
  call g:assert.equals(getline('.'), '{foo}',      'failed at #339')
  call g:assert.equals(getpos('.'),  [0, 1, 2, 0], 'failed at #339')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #339')
  call g:assert.equals(getpos("']"), [0, 1, 6, 0], 'failed at #339')

  " #340
  call setline('.', '{foo}')
  normal Vsr<
  call g:assert.equals(getline('.'), '<foo>',      'failed at #340')
  call g:assert.equals(getpos('.'),  [0, 1, 2, 0], 'failed at #340')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #340')
  call g:assert.equals(getpos("']"), [0, 1, 6, 0], 'failed at #340')

  " #341
  call setline('.', '<foo>')
  normal Vsr(
  call g:assert.equals(getline('.'), '(foo)',      'failed at #341')
  call g:assert.equals(getpos('.'),  [0, 1, 2, 0], 'failed at #341')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #341')
  call g:assert.equals(getpos("']"), [0, 1, 6, 0], 'failed at #341')

  %delete

  " #342
  call append(0, ['(', 'foo', ')'])
  normal ggV2jsr]
  call g:assert.equals(getline(1),   '[',          'failed at #342')
  call g:assert.equals(getline(2),   'foo',        'failed at #342')
  call g:assert.equals(getline(3),   ']',          'failed at #342')
  call g:assert.equals(getpos('.'),  [0, 2, 1, 0], 'failed at #342')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #342')
  call g:assert.equals(getpos("']"), [0, 3, 2, 0], 'failed at #342')

  " #343
  call append(0, ['[', 'foo', ']'])
  normal ggV2jsr}
  call g:assert.equals(getline(1),   '{',          'failed at #343')
  call g:assert.equals(getline(2),   'foo',        'failed at #343')
  call g:assert.equals(getline(3),   '}',          'failed at #343')
  call g:assert.equals(getpos('.'),  [0, 2, 1, 0], 'failed at #343')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #343')
  call g:assert.equals(getpos("']"), [0, 3, 2, 0], 'failed at #343')

  " #344
  call append(0, ['{', 'foo', '}'])
  normal ggV2jsr>
  call g:assert.equals(getline(1),   '<',          'failed at #344')
  call g:assert.equals(getline(2),   'foo',        'failed at #344')
  call g:assert.equals(getline(3),   '>',          'failed at #344')
  call g:assert.equals(getpos('.'),  [0, 2, 1, 0], 'failed at #344')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #344')
  call g:assert.equals(getpos("']"), [0, 3, 2, 0], 'failed at #344')

  " #345
  call append(0, ['<', 'foo', '>'])
  normal ggV2jsr)
  call g:assert.equals(getline(1),   '(',          'failed at #345')
  call g:assert.equals(getline(2),   'foo',        'failed at #345')
  call g:assert.equals(getline(3),   ')',          'failed at #345')
  call g:assert.equals(getpos('.'),  [0, 2, 1, 0], 'failed at #345')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #345')
  call g:assert.equals(getpos("']"), [0, 3, 2, 0], 'failed at #345')
endfunction
"}}}
function! s:suite.linewise_x_not_registered() abort "{{{
  " #346
  call setline('.', 'afooa')
  normal Vsrb
  call g:assert.equals(getline('.'), 'bfoob',      'failed at #346')
  call g:assert.equals(getpos('.'),  [0, 1, 2, 0], 'failed at #346')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #346')
  call g:assert.equals(getpos("']"), [0, 1, 6, 0], 'failed at #346')

  " #347
  call setline('.', '+foo+')
  normal Vsr*
  call g:assert.equals(getline('.'), '*foo*',      'failed at #347')
  call g:assert.equals(getpos('.'),  [0, 1, 2, 0], 'failed at #347')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #347')
  call g:assert.equals(getpos("']"), [0, 1, 6, 0], 'failed at #347')

  %delete

  " #346
  call append(0, ['a', 'foo', 'a'])
  normal ggV2jsrb
  call g:assert.equals(getline(1),   'b',          'failed at #346')
  call g:assert.equals(getline(2),   'foo',        'failed at #346')
  call g:assert.equals(getline(3),   'b',          'failed at #346')
  call g:assert.equals(getpos('.'),  [0, 2, 1, 0], 'failed at #346')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #346')
  call g:assert.equals(getpos("']"), [0, 3, 2, 0], 'failed at #346')

  %delete

  " #347
  call append(0, ['+', 'foo', '+'])
  normal ggV2jsr*
  call g:assert.equals(getline(1),   '*',          'failed at #347')
  call g:assert.equals(getline(2),   'foo',        'failed at #347')
  call g:assert.equals(getline(3),   '*',          'failed at #347')
  call g:assert.equals(getpos('.'),  [0, 2, 1, 0], 'failed at #347')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #347')
  call g:assert.equals(getpos("']"), [0, 3, 2, 0], 'failed at #347')
endfunction
"}}}
function! s:suite.linewise_x_positioning() abort "{{{
  " #348
  call append(0, ['(', 'foo', 'bar', 'baz', ')'])
  normal ggV4jsr[
  call g:assert.equals(getline(1),   '[',          'failed at #348')
  call g:assert.equals(getline(2),   'foo',        'failed at #348')
  call g:assert.equals(getline(3),   'bar',        'failed at #348')
  call g:assert.equals(getline(4),   'baz',        'failed at #348')
  call g:assert.equals(getline(5),   ']',          'failed at #348')
  call g:assert.equals(getpos('.'),  [0, 2, 1, 0], 'failed at #348')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #348')
  call g:assert.equals(getpos("']"), [0, 5, 2, 0], 'failed at #348')

  %delete

  " #349
  call append(0, ['foo', '(', 'bar', ')', 'baz'])
  normal ggjV2jsr[
  call g:assert.equals(getline(1),   'foo',        'failed at #349')
  call g:assert.equals(getline(2),   '[',          'failed at #349')
  call g:assert.equals(getline(3),   'bar',        'failed at #349')
  call g:assert.equals(getline(4),   ']',          'failed at #349')
  call g:assert.equals(getline(5),   'baz',        'failed at #349')
  call g:assert.equals(getpos('.'),  [0, 3, 1, 0], 'failed at #349')
  call g:assert.equals(getpos("'["), [0, 2, 1, 0], 'failed at #349')
  call g:assert.equals(getpos("']"), [0, 4, 2, 0], 'failed at #349')

  %delete

  " #350
  call append(0, ['(foo', 'bar', 'baz)'])
  normal ggV2jsr[
  call g:assert.equals(getline(1),   '[foo',       'failed at #350')
  call g:assert.equals(getline(2),   'bar',        'failed at #350')
  call g:assert.equals(getline(3),   'baz]',       'failed at #350')
  call g:assert.equals(getpos('.'),  [0, 1, 2, 0], 'failed at #350')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #350')
  call g:assert.equals(getpos("']"), [0, 3, 5, 0], 'failed at #350')
endfunction
"}}}
function! s:suite.linewise_x_nothing_inside() abort "{{{
  " #351
  call setline('.', '()')
  normal Vsr[
  call g:assert.equals(getline('.'), '[]',         'failed at #351')
  call g:assert.equals(getpos('.'),  [0, 1, 2, 0], 'failed at #351')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #351')
  call g:assert.equals(getpos("']"), [0, 1, 3, 0], 'failed at #351')

  %delete

  " #352
  call append(0, ['(', ')'])
  normal ggVjsr[
  call g:assert.equals(getline(1),   '[',          'failed at #352')
  call g:assert.equals(getline(2),   ']',          'failed at #352')
  call g:assert.equals(getpos('.'),  [0, 1, 1, 0], 'failed at #352')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #352')
  call g:assert.equals(getpos("']"), [0, 2, 2, 0], 'failed at #352')
endfunction
"}}}
function! s:suite.linewise_x_count() abort "{{{
  " #353
  call setline('.', '([foo])')
  normal V2sr[(
  call g:assert.equals(getline('.'), '[(foo)]',    'failed at #353')
  call g:assert.equals(getpos('.'),  [0, 1, 3, 0], 'failed at #353')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #353')
  call g:assert.equals(getpos("']"), [0, 1, 8, 0], 'failed at #353')

  " #354
  call setline('.', '[({foo})]')
  normal V3sr{[(
  call g:assert.equals(getline('.'), '{[(foo)]}',   'failed at #354')
  call g:assert.equals(getpos('.'),  [0, 1,  4, 0], 'failed at #354')
  call g:assert.equals(getpos("'["), [0, 1,  1, 0], 'failed at #354')
  call g:assert.equals(getpos("']"), [0, 1, 10, 0], 'failed at #354')

  %delete

  " #355
  call append(0, ['foo', '{', '[', '(', 'bar', ')', ']', '}', 'baz'])
  normal ggjV6j3sr({[
  call g:assert.equals(getline(1),   'foo',        'failed at #355')
  call g:assert.equals(getline(2),   '(',          'failed at #355')
  call g:assert.equals(getline(3),   '{',          'failed at #355')
  call g:assert.equals(getline(4),   '[',          'failed at #355')
  call g:assert.equals(getline(5),   'bar',        'failed at #355')
  call g:assert.equals(getline(6),   ']',          'failed at #355')
  call g:assert.equals(getline(7),   '}',          'failed at #355')
  call g:assert.equals(getline(8),   ')',          'failed at #355')
  call g:assert.equals(getline(9),   'baz',        'failed at #355')
  call g:assert.equals(getpos('.'),  [0, 5, 1, 0], 'failed at #355')
  call g:assert.equals(getpos("'["), [0, 2, 1, 0], 'failed at #355')
  call g:assert.equals(getpos("']"), [0, 8, 2, 0], 'failed at #355')
endfunction
"}}}
function! s:suite.linewise_x_breaking() abort "{{{
  let g:operator#sandwich#recipes = [
        \   {'buns': ["aa\naaa", "aaa\naa"], 'input':['a']},
        \   {'buns': ["bb\nbbb\nbb", "bb\nbbb\nbb"], 'input':['b']},
        \ ]

  " #356
  call append(0, ['aa', 'aaafooaaa', 'aa'])
  normal ggV2jsr(
  call g:assert.equals(getline(1),   '(foo)',      'failed at #356')
  call g:assert.equals(getpos('.'),  [0, 1, 2, 0], 'failed at #356')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #356')
  call g:assert.equals(getpos("']"), [0, 1, 6, 0], 'failed at #356')

  %delete

  " #357
  call append(0, ['bb', 'bbb', 'bbfoobb', 'bbb', 'bb'])
  normal ggV4jsr(
  call g:assert.equals(getline(1),   '(foo)',      'failed at #357')
  call g:assert.equals(getpos('.'),  [0, 1, 2, 0], 'failed at #357')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #357')
  call g:assert.equals(getpos("']"), [0, 1, 6, 0], 'failed at #357')

  %delete

  " #358
  call setline('.', '(foo)')
  normal Vsra
  call g:assert.equals(getline(1),   'aa',         'failed at #358')
  call g:assert.equals(getline(2),   'aaafooaaa',  'failed at #358')
  call g:assert.equals(getline(3),   'aa',         'failed at #358')
  call g:assert.equals(getpos('.'),  [0, 2, 4, 0], 'failed at #358')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #358')
  call g:assert.equals(getpos("']"), [0, 3, 3, 0], 'failed at #358')

  %delete

  " #359
  call setline('.', '(foo)')
  normal Vsrb
  call g:assert.equals(getline(1),   'bb',         'failed at #359')
  call g:assert.equals(getline(2),   'bbb',        'failed at #359')
  call g:assert.equals(getline(3),   'bbfoobb',    'failed at #359')
  call g:assert.equals(getline(4),   'bbb',        'failed at #359')
  call g:assert.equals(getline(5),   'bb',         'failed at #359')
  call g:assert.equals(getpos('.'),  [0, 3, 3, 0], 'failed at #359')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #359')
  call g:assert.equals(getpos("']"), [0, 5, 3, 0], 'failed at #359')

  %delete

  " #360
  call append(0, ['aa', 'aaa', 'aa', 'aaa', 'foo', 'aaa', 'aa', 'aaa', 'aa'])
  normal ggV8j2sr((
  call g:assert.equals(getline(1),   '(',          'failed at #360')
  call g:assert.equals(getline(2),   '(',          'failed at #360')
  call g:assert.equals(getline(3),   'foo',        'failed at #360')
  call g:assert.equals(getline(4),   ')',          'failed at #360')
  call g:assert.equals(getline(5),   ')',          'failed at #360')
  call g:assert.equals(getpos('.'),  [0, 3, 1, 0], 'failed at #360')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #360')
  call g:assert.equals(getpos("']"), [0, 5, 2, 0], 'failed at #360')

  %delete

  " #361
  call append(0, ['bb', 'bbb', 'bb', 'bb', 'bbb', 'bb', 'foo', 'bb', 'bbb', 'bb', 'bb', 'bbb', 'bb'])
  normal ggV12j2sr((
  call g:assert.equals(getline(1),   '(',          'failed at #361')
  call g:assert.equals(getline(2),   '(',          'failed at #361')
  call g:assert.equals(getline(3),   'foo',        'failed at #361')
  call g:assert.equals(getline(4),   ')',          'failed at #361')
  call g:assert.equals(getline(5),   ')',          'failed at #361')
  call g:assert.equals(getpos('.'),  [0, 3, 1, 0], 'failed at #361')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #361')
  call g:assert.equals(getpos("']"), [0, 5, 2, 0], 'failed at #361')

  unlet! g:operator#sandwich#recipes
endfunction
"}}}
function! s:suite.linewise_x_external_textobj() abort"{{{
  let g:sandwich#recipes = []
  let g:operator#sandwich#recipes = [
        \   {'external': ['i{', 'a{']},
        \   {'external': ['i[', 'a[']},
        \   {'external': ['i(', 'a(']},
        \   {'external': ['it', 'at']},
        \ ]

  " #362
  call setline('.', '(foo)')
  normal Vsr"
  call g:assert.equals(getline('.'), '"foo"', 'failed at #362')

  " #363
  call setline('.', '[foo]')
  normal Vsr"
  call g:assert.equals(getline('.'), '"foo"', 'failed at #363')

  " #364
  call setline('.', '{foo}')
  normal Vsr"
  call g:assert.equals(getline('.'), '"foo"', 'failed at #364')

  " #365
  call setline('.', '<title>foo</title>')
  normal Vsr"
  call g:assert.equals(getline('.'), '"foo"', 'failed at #365')

  unlet g:sandwich#recipes
  unlet g:operator#sandwich#recipes
endfunction
"}}}
function! s:suite.linewise_x_option_cursor() abort  "{{{
  """"" cursor
  """ inner_head
  " #366
  call setline('.', '(((foo)))')
  normal 0V2sr[[
  call g:assert.equals(getline('.'), '[[(foo)]]',  'failed at #366')
  call g:assert.equals(getpos('.'),  [0, 1, 3, 0], 'failed at #366')

  " #367
  normal Vsr(
  call g:assert.equals(getline('.'), '([(foo)])',  'failed at #367')
  call g:assert.equals(getpos('.'),  [0, 1, 2, 0], 'failed at #367')

  """ keep
  " #368
  call operator#sandwich#set('replace', 'line', 'cursor', 'keep')
  call setline('.', '(((foo)))')
  normal 04lV2sr[[
  call g:assert.equals(getline('.'), '[[(foo)]]',  'failed at #368')
  call g:assert.equals(getpos('.'),  [0, 1, 5, 0], 'failed at #368')

  " #369
  normal lVsr(
  call g:assert.equals(getline('.'), '([(foo)])',  'failed at #369')
  call g:assert.equals(getpos('.'),  [0, 1, 6, 0], 'failed at #369')

  """ inner_tail
  " #370
  call operator#sandwich#set('replace', 'line', 'cursor', 'inner_tail')
  call setline('.', '(((foo)))')
  normal 04lV2sr[[
  call g:assert.equals(getline('.'), '[[(foo)]]',  'failed at #370')
  call g:assert.equals(getpos('.'),  [0, 1, 7, 0], 'failed at #370')

  " #371
  normal hVsr(
  call g:assert.equals(getline('.'), '([(foo)])',  'failed at #371')
  call g:assert.equals(getpos('.'),  [0, 1, 8, 0], 'failed at #371')

  """ front
  " #372
  call operator#sandwich#set('replace', 'line', 'cursor', 'front')
  call setline('.', '(((foo)))')
  normal 04lV2sr[[
  call g:assert.equals(getline('.'), '[[(foo)]]',  'failed at #372')
  call g:assert.equals(getpos('.'),  [0, 1, 1, 0], 'failed at #372')

  " #373
  normal 3lVsr(
  call g:assert.equals(getline('.'), '([(foo)])',  'failed at #373')
  call g:assert.equals(getpos('.'),  [0, 1, 1, 0], 'failed at #373')

  """ end
  " #374
  call operator#sandwich#set('replace', 'line', 'cursor', 'end')
  call setline('.', '(((foo)))')
  normal 04lV2sr[[
  call g:assert.equals(getline('.'), '[[(foo)]]',  'failed at #374')
  call g:assert.equals(getpos('.'),  [0, 1, 9, 0], 'failed at #374')

  " #375
  normal 3hVsr(
  call g:assert.equals(getline('.'), '([(foo)])',  'failed at #375')
  call g:assert.equals(getpos('.'),  [0, 1, 9, 0], 'failed at #375')

  call operator#sandwich#set('replace', 'line', 'cursor', 'inner_head')
endfunction
"}}}
function! s:suite.linewise_x_option_noremap() abort  "{{{
  """"" noremap
  let g:sandwich#recipes = []
  let g:operator#sandwich#recipes = [{'external': ['i{', 'a{']}]
  xnoremap i{ i(
  xnoremap a{ a(

  """ on
  " #376
  call setline('.', '{foo}')
  normal Vsr"
  call g:assert.equals(getline('.'), '"foo"', 'failed at #376')

  " #377
  call setline('.', '(foo)')
  normal Vsr"
  call g:assert.equals(getline('.'), '(foo)', 'failed at #377')

  """ off
  " #378
  call operator#sandwich#set('replace', 'line', 'noremap', 0)
  call setline('.', '{foo}')
  normal Vsr"
  call g:assert.equals(getline('.'), '{foo}', 'failed at #378')

  " #379
  call setline('.', '(foo)')
  normal Vsr"
  call g:assert.equals(getline('.'), '"foo"', 'failed at #379')

  unlet! g:sandwich#recipes
  unlet! g:operator#sandwich#recipes
  xunmap i{
  xunmap a{
  call operator#sandwich#set('replace', 'line', 'noremap', 1)
endfunction
"}}}
function! s:suite.linewise_x_option_regex() abort  "{{{
  let g:sandwich#recipes = []
  let g:operator#sandwich#recipes = [{'buns': ['\d\+', '\d\+']}]

  """ off
  " #380
  call setline('.', '\d\+foo\d\+')
  normal Vsr"
  call g:assert.equals(getline('.'), '"foo"', 'failed at #380')

  " #381
  call setline('.', '888foo888')
  normal Vsr"
  call g:assert.equals(getline('.'), '"88foo88"', 'failed at #381')

  """ on
  call operator#sandwich#set('replace', 'line', 'regex', 1)
  " #382
  call setline('.', '\d\+foo\d\+')
  normal Vsr"
  call g:assert.equals(getline('.'), '\d\+foo\d\+', 'failed at #382')

  " #383
  call setline('.', '888foo888')
  normal Vsr"
  call g:assert.equals(getline('.'), '"foo"', 'failed at #383')

  call operator#sandwich#set('replace', 'line', 'regex', 0)
  unlet! g:sandwich#recipes
  unlet! g:operator#sandwich#recipes
endfunction
"}}}
function! s:suite.linewise_x_option_skip_space() abort  "{{{
  """ on
  " #384
  call setline('.', '"foo"')
  normal Vsr(
  call g:assert.equals(getline('.'), '(foo)', 'failed at #384')

  " #385
  call setline('.', ' "foo"')
  normal Vsr(
  call g:assert.equals(getline('.'), ' (foo)', 'failed at #385')

  " #386
  call setline('.', '"foo" ')
  normal Vsr(
  call g:assert.equals(getline('.'), '(foo) ', 'failed at #386')

  " #387
  " do not skip!
  call setline('.', ' "foo" ')
  normal Vsr(
  call g:assert.equals(getline('.'), '("foo")', 'failed at #387')

  """ off
  call operator#sandwich#set('replace', 'line', 'skip_space', 0)
  " #388
  call setline('.', '"foo"')
  normal Vsr(
  call g:assert.equals(getline('.'), '(foo)', 'failed at #388')

  " #389
  call setline('.', ' "foo"')
  normal Vsr(
  call g:assert.equals(getline('.'), ' "foo"', 'failed at #389')

  " #390
  call setline('.', '"foo" ')
  normal Vsr(
  call g:assert.equals(getline('.'), '"foo" ', 'failed at #390')

  " #391
  " do not skip!
  call setline('.', ' "foo" ')
  normal Vsr(
  call g:assert.equals(getline('.'), '("foo")', 'failed at #391')

  call operator#sandwich#set('replace', 'line', 'skip_space', 1)
endfunction
"}}}
function! s:suite.linewise_x_option_skip_char() abort "{{{
  """ off
  " #392
  call setline('.', 'aa(foo)bb')
  normal Vsr"
  call g:assert.equals(getline('.'), 'aa(foo)bb', 'failed at #392')

  """ on
  call operator#sandwich#set('replace', 'line', 'skip_char', 1)
  " #393
  call setline('.', 'aa(foo)bb')
  normal Vsr"
  call g:assert.equals(getline('.'), 'aa"foo"bb', 'failed at #393')

  call operator#sandwich#set('replace', 'line', 'skip_char', 0)
endfunction
"}}}
function! s:suite.linewise_x_option_command() abort  "{{{
  call operator#sandwich#set('replace', 'line', 'command', ['normal! `[dv`]'])

  " #394
  call setline('.', '(foo)')
  normal Vsr"
  call g:assert.equals(getline('.'), '""', 'failed at #394')

  call operator#sandwich#set('replace', 'line', 'command', [])
endfunction
"}}}
function! s:suite.linewise_x_option_linewise() abort  "{{{
  call operator#sandwich#set('replace', 'line', 'linewise', 0)

  """ 0
  " #395
  call append(0, ['(', 'foo', ')'])
  normal ggV2jsr[
  call g:assert.equals(getline(1),   '[',          'failed at #395')
  call g:assert.equals(getline(2),   'foo',        'failed at #395')
  call g:assert.equals(getline(3),   ']',          'failed at #395')
  call g:assert.equals(getpos('.'),  [0, 2, 1, 0], 'failed at #395')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #395')
  call g:assert.equals(getpos("']"), [0, 3, 2, 0], 'failed at #395')

  %delete

  " #396
  call append(0, ['(  ', 'foo', '  )'])
  normal ggV2jsr[
  call g:assert.equals(getline(1),   '[  ',        'failed at #396')
  call g:assert.equals(getline(2),   'foo',        'failed at #396')
  call g:assert.equals(getline(3),   '  ]',        'failed at #396')
  call g:assert.equals(getpos('.'),  [0, 1, 2, 0], 'failed at #396')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #396')
  call g:assert.equals(getpos("']"), [0, 3, 4, 0], 'failed at #396')

  %delete

  " #397
  call append(0, ['(aa', 'foo', 'aa)'])
  normal ggV2jsr[
  call g:assert.equals(getline(1),   '[aa',        'failed at #397')
  call g:assert.equals(getline(2),   'foo',        'failed at #397')
  call g:assert.equals(getline(3),   'aa]',        'failed at #397')
  call g:assert.equals(getpos('.'),  [0, 1, 2, 0], 'failed at #397')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #397')
  call g:assert.equals(getpos("']"), [0, 3, 4, 0], 'failed at #397')

  %delete

  " #398
  call append(0, ['(aa', 'foo', ')'])
  normal ggV2jsr[
  call g:assert.equals(getline(1),   '[aa',        'failed at #398')
  call g:assert.equals(getline(2),   'foo',        'failed at #398')
  call g:assert.equals(getline(3),   ']',          'failed at #398')
  call g:assert.equals(getpos('.'),  [0, 1, 2, 0], 'failed at #398')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #398')
  call g:assert.equals(getpos("']"), [0, 3, 2, 0], 'failed at #398')

  %delete

  " #399
  call append(0, ['(', 'foo', 'aa)'])
  normal ggV2jsr[
  call g:assert.equals(getline(1),   '[',          'failed at #399')
  call g:assert.equals(getline(2),   'foo',        'failed at #399')
  call g:assert.equals(getline(3),   'aa]',        'failed at #399')
  call g:assert.equals(getpos('.'),  [0, 2, 1, 0], 'failed at #399')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #399')
  call g:assert.equals(getpos("']"), [0, 3, 4, 0], 'failed at #399')

  %delete

  call operator#sandwich#set('replace', 'line', 'linewise', 2)

  """ 2
  " #400
  call append(0, ['(', 'foo', ')'])
  normal ggV2jsr[
  call g:assert.equals(getline(1),   '[',          'failed at #400')
  call g:assert.equals(getline(2),   'foo',        'failed at #400')
  call g:assert.equals(getline(3),   ']',          'failed at #400')
  call g:assert.equals(getpos('.'),  [0, 2, 1, 0], 'failed at #400')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #400')
  call g:assert.equals(getpos("']"), [0, 3, 2, 0], 'failed at #400')

  %delete

  " #401
  call append(0, ['(  ', 'foo', '  )'])
  normal ggV2jsr[
  call g:assert.equals(getline(1),   '[',          'failed at #401')
  call g:assert.equals(getline(2),   'foo',        'failed at #401')
  call g:assert.equals(getline(3),   ']',          'failed at #401')
  call g:assert.equals(getpos('.'),  [0, 2, 1, 0], 'failed at #401')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #401')
  call g:assert.equals(getpos("']"), [0, 3, 2, 0], 'failed at #401')

  %delete

  " #402
  call append(0, ['(aa', 'foo', 'aa)'])
  normal ggV2jsr[
  call g:assert.equals(getline(1),   '[',          'failed at #402')
  call g:assert.equals(getline(2),   'foo',        'failed at #402')
  call g:assert.equals(getline(3),   ']',          'failed at #402')
  call g:assert.equals(getpos('.'),  [0, 2, 1, 0], 'failed at #402')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #402')
  call g:assert.equals(getpos("']"), [0, 3, 2, 0], 'failed at #402')

  %delete

  " #403
  " FIXME: I have no idea what is the expexted behavior.
  call append(0, ['aa', '(foo)', 'bb'])
  normal ggjVsr[
  call g:assert.equals(getline(1),   'aa',         'failed at #403')
  call g:assert.equals(getline(2),   '[',          'failed at #403')
  call g:assert.equals(getline(3),   'bb',         'failed at #403')
  call g:assert.equals(getline(4),   '',           'failed at #403')
  call g:assert.equals(getpos('.'),  [0, 3, 1, 0], 'failed at #403')
  call g:assert.equals(getpos("'["), [0, 2, 1, 0], 'failed at #403')
  call g:assert.equals(getpos("']"), [0, 3, 1, 0], 'failed at #403')
endfunction
"}}}
function! s:suite.linewise_x_option_query_once() abort  "{{{
  """"" query_once
  """ off
  " #404
  call setline('.', '"""foo"""')
  normal V3sr([{
  call g:assert.equals(getline('.'), '([{foo}])',  'failed at #404')

  %delete

  """ on
  " #405
  call operator#sandwich#set('replace', 'line', 'query_once', 1)
  call setline('.', '"""foo"""')
  normal V3sr(
  call g:assert.equals(getline('.'), '(((foo)))',  'failed at #405')

  call operator#sandwich#set('replace', 'line', 'query_once', 0)
endfunction
"}}}
function! s:suite.linewise_x_option_eval() abort "{{{
  """"" eval
  let g:operator#sandwich#recipes = [{'buns': ['1+1', '1+2'], 'input':['a']}]

  """ 0
  " #406
  call setline('.', '"foo"')
  normal Vsra
  call g:assert.equals(getline('.'), '1+1foo1+2',  'failed at #406')

  """ 1
  " #407
  call operator#sandwich#set('replace', 'line', 'eval', 1)
  call setline('.', '"foo"')
  normal Vsra
  call g:assert.equals(getline('.'), '2foo3',  'failed at #407')

  """ 2
  " This case cannot be tested since this option makes difference only in
  " dot-repeat.

  unlet! g:operator#sandwich#recipes
  call operator#sandwich#set('replace', 'line', 'eval', 0)
endfunction
"}}}

" block-wise
function! s:suite.blockwise_n_default_recipes() abort "{{{
  set whichwrap=h,l

  " #279
  call append(0, ['(foo)', '(bar)', '(baz)'])
  execute "normal ggsr\<C-v>17l["
  call g:assert.equals(getline(1),   '[foo]',      'failed at #279')
  call g:assert.equals(getline(2),   '[bar]',      'failed at #279')
  call g:assert.equals(getline(3),   '[baz]',      'failed at #279')
  call g:assert.equals(getpos('.'),  [0, 1, 2, 0], 'failed at #279')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #279')
  call g:assert.equals(getpos("']"), [0, 3, 6, 0], 'failed at #279')

  %delete

  " #280
  call append(0, ['[foo]', '[bar]', '[baz]'])
  execute "normal ggsr\<C-v>17l{"
  call g:assert.equals(getline(1),   '{foo}',      'failed at #280')
  call g:assert.equals(getline(2),   '{bar}',      'failed at #280')
  call g:assert.equals(getline(3),   '{baz}',      'failed at #280')
  call g:assert.equals(getpos('.'),  [0, 1, 2, 0], 'failed at #280')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #280')
  call g:assert.equals(getpos("']"), [0, 3, 6, 0], 'failed at #280')

  %delete

  " #281
  call append(0, ['{foo}', '{bar}', '{baz}'])
  execute "normal ggsr\<C-v>17l<"
  call g:assert.equals(getline(1),   '<foo>',      'failed at #281')
  call g:assert.equals(getline(2),   '<bar>',      'failed at #281')
  call g:assert.equals(getline(3),   '<baz>',      'failed at #281')
  call g:assert.equals(getpos('.'),  [0, 1, 2, 0], 'failed at #281')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #281')
  call g:assert.equals(getpos("']"), [0, 3, 6, 0], 'failed at #281')

  %delete

  " #282
  call append(0, ['<foo>', '<bar>', '<baz>'])
  execute "normal ggsr\<C-v>17l("
  call g:assert.equals(getline(1),   '(foo)',      'failed at #282')
  call g:assert.equals(getline(2),   '(bar)',      'failed at #282')
  call g:assert.equals(getline(3),   '(baz)',      'failed at #282')
  call g:assert.equals(getpos('.'),  [0, 1, 2, 0], 'failed at #282')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #282')
  call g:assert.equals(getpos("']"), [0, 3, 6, 0], 'failed at #282')

  set whichwrap&
endfunction
"}}}
function! s:suite.blockwise_n_not_registered() abort "{{{
  set whichwrap=h,l

  " #283
  call append(0, ['afooa', 'abara', 'abaza'])
  execute "normal ggsr\<C-v>17lb"
  call g:assert.equals(getline(1),   'bfoob',      'failed at #283')
  call g:assert.equals(getline(2),   'bbarb',      'failed at #283')
  call g:assert.equals(getline(3),   'bbazb',      'failed at #283')
  call g:assert.equals(getpos('.'),  [0, 1, 2, 0], 'failed at #283')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #283')
  call g:assert.equals(getpos("']"), [0, 3, 6, 0], 'failed at #283')

  " #284
  call append(0, ['+foo+', '+bar+', '+baz+'])
  execute "normal ggsr\<C-v>17l*"
  call g:assert.equals(getline(1),   '*foo*',      'failed at #284')
  call g:assert.equals(getline(2),   '*bar*',      'failed at #284')
  call g:assert.equals(getline(3),   '*baz*',      'failed at #284')
  call g:assert.equals(getpos('.'),  [0, 1, 2, 0], 'failed at #284')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #284')
  call g:assert.equals(getpos("']"), [0, 3, 6, 0], 'failed at #284')

  set whichwrap&
endfunction
"}}}
function! s:suite.blockwise_n_positioning() abort "{{{
  set whichwrap=h,l

  " #285
  call append(0, ['(foo)bar', '(foo)bar', '(foo)bar'])
  execute "normal ggsr\<C-v>23l["
  call g:assert.equals(getline(1),   '[foo]bar',   'failed at #285')
  call g:assert.equals(getline(2),   '[foo]bar',   'failed at #285')
  call g:assert.equals(getline(3),   '[foo]bar',   'failed at #285')
  call g:assert.equals(getpos('.'),  [0, 1, 2, 0], 'failed at #285')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #285')
  call g:assert.equals(getpos("']"), [0, 3, 6, 0], 'failed at #285')

  %delete

  " #286
  call append(0, ['foo(bar)', 'foo(bar)', 'foo(bar)'])
  execute "normal gg3lsr\<C-v>23l["
  call g:assert.equals(getline(1),   'foo[bar]',   'failed at #286')
  call g:assert.equals(getline(2),   'foo[bar]',   'failed at #286')
  call g:assert.equals(getline(3),   'foo[bar]',   'failed at #286')
  call g:assert.equals(getpos('.'),  [0, 1, 5, 0], 'failed at #286')
  call g:assert.equals(getpos("'["), [0, 1, 4, 0], 'failed at #286')
  call g:assert.equals(getpos("']"), [0, 3, 9, 0], 'failed at #286')

  %delete

  " #287
  call append(0, ['foo(bar)baz', 'foo(bar)baz', 'foo(bar)baz'])
  execute "normal gg3lsr\<C-v>29l["
  call g:assert.equals(getline(1),   'foo[bar]baz', 'failed at #287')
  call g:assert.equals(getline(2),   'foo[bar]baz', 'failed at #287')
  call g:assert.equals(getline(3),   'foo[bar]baz', 'failed at #287')
  call g:assert.equals(getpos('.'),  [0, 1, 5, 0],  'failed at #287')
  call g:assert.equals(getpos("'["), [0, 1, 4, 0],  'failed at #287')
  call g:assert.equals(getpos("']"), [0, 3, 9, 0],  'failed at #287')

  %delete

  " #288
  call append(0, ['(foo)', '(bar)', 'bazbaz'])
  execute "normal ggsr\<C-v>17l["
  call g:assert.equals(getline(1),   '[foo]',      'failed at #288')
  call g:assert.equals(getline(2),   '[bar]',      'failed at #288')
  call g:assert.equals(getline(3),   'bazbaz',     'failed at #288')
  call g:assert.equals(getpos('.'),  [0, 1, 2, 0], 'failed at #288')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #288')
  call g:assert.equals(getpos("']"), [0, 2, 6, 0], 'failed at #288')

  %delete

  " #289
  call append(0, ['(foo)', 'barbar', '(baz)'])
  execute "normal ggsr\<C-v>18l["
  call g:assert.equals(getline(1),   '[foo]',      'failed at #289')
  call g:assert.equals(getline(2),   'barbar',     'failed at #289')
  call g:assert.equals(getline(3),   '[baz]',      'failed at #289')
  call g:assert.equals(getpos('.'),  [0, 1, 2, 0], 'failed at #289')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #289')
  call g:assert.equals(getpos("']"), [0, 3, 6, 0], 'failed at #289')

  %delete

  " #290
  call append(0, ['foofoo', '(bar)', '(baz)'])
  execute "normal ggsr\<C-v>18l["
  call g:assert.equals(getline(1),   'foofoo',     'failed at #290')
  call g:assert.equals(getline(2),   '[bar]',      'failed at #290')
  call g:assert.equals(getline(3),   '[baz]',      'failed at #290')
  call g:assert.equals(getpos('.'),  [0, 2, 2, 0], 'failed at #290')
  call g:assert.equals(getpos("'["), [0, 2, 1, 0], 'failed at #290')
  call g:assert.equals(getpos("']"), [0, 3, 6, 0], 'failed at #290')

  set whichwrap&
endfunction
"}}}
function! s:suite.blockwise_n_a_character() abort "{{{
  set whichwrap=h,l

  " #291
  call append(0, ['(a)', '(b)', '(c)'])
  execute "normal ggsr\<C-v>11l["
  call g:assert.equals(getline(1),   '[a]',        'failed at #291')
  call g:assert.equals(getline(2),   '[b]',        'failed at #291')
  call g:assert.equals(getline(3),   '[c]',        'failed at #291')
  call g:assert.equals(getpos('.'),  [0, 1, 2, 0], 'failed at #291')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #291')
  call g:assert.equals(getpos("']"), [0, 3, 4, 0], 'failed at #291')

  set whichwrap&
endfunction
"}}}
function! s:suite.blockwise_n_nothing_inside() abort "{{{
  set whichwrap=h,l

  " #292
  call append(0, ['()', '()', '()'])
  execute "normal ggsr\<C-v>8l["
  call g:assert.equals(getline(1),   '[]',         'failed at #292')
  call g:assert.equals(getline(2),   '[]',         'failed at #292')
  call g:assert.equals(getline(3),   '[]',         'failed at #292')
  call g:assert.equals(getpos('.'),  [0, 1, 2, 0], 'failed at #292')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #292')
  call g:assert.equals(getpos("']"), [0, 3, 3, 0], 'failed at #292')

  %delete

  " #293
  call append(0, ['foo()bar', 'foo()bar', 'foo()bar'])
  execute "normal gg3lsr\<C-v>20l["
  call g:assert.equals(getline(1),   'foo[]bar',   'failed at #293')
  call g:assert.equals(getline(2),   'foo[]bar',   'failed at #293')
  call g:assert.equals(getline(3),   'foo[]bar',   'failed at #293')
  call g:assert.equals(getpos('.'),  [0, 1, 5, 0], 'failed at #293')
  call g:assert.equals(getpos("'["), [0, 1, 4, 0], 'failed at #293')
  call g:assert.equals(getpos("']"), [0, 3, 6, 0], 'failed at #293')

  set whichwrap&
endfunction
"}}}
function! s:suite.blockwise_n_count() abort "{{{
  set whichwrap=h,l

  " #294
  call append(0, ['[(foo)]', '[(bar)]', '[(baz)]'])
  execute "normal gg3sr\<C-v>23l({"
  call g:assert.equals(getline(1),   '({foo})',    'failed at #294')
  call g:assert.equals(getline(2),   '({bar})',    'failed at #294')
  call g:assert.equals(getline(3),   '({baz})',    'failed at #294')
  call g:assert.equals(getpos('.'),  [0, 1, 3, 0], 'failed at #294')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #294')
  call g:assert.equals(getpos("']"), [0, 3, 8, 0], 'failed at #294')

  %delete

  " #295
  call append(0, ['{[(foo)]}', '{[(bar)]}', '{[(baz)]}'])
  execute "normal gg3sr\<C-v>29l({["
  call g:assert.equals(getline(1),   '({[foo]})',   'failed at #295')
  call g:assert.equals(getline(2),   '({[bar]})',   'failed at #295')
  call g:assert.equals(getline(3),   '({[baz]})',   'failed at #295')
  call g:assert.equals(getpos('.'),  [0, 1,  4, 0], 'failed at #295')
  call g:assert.equals(getpos("'["), [0, 1,  1, 0], 'failed at #295')
  call g:assert.equals(getpos("']"), [0, 3, 10, 0], 'failed at #295')

  %delete

  " #296
  call append(0, ['{[afoob]}', '{[(bar)]}', '{[(baz)]}'])
  execute "normal gg3sr\<C-v>29l({["
  call g:assert.equals(getline(1),   '({afoob})',   'failed at #296')
  call g:assert.equals(getline(2),   '({[bar]})',   'failed at #296')
  call g:assert.equals(getline(3),   '({[baz]})',   'failed at #296')
  call g:assert.equals(getpos('.'),  [0, 1,  3, 0], 'failed at #296')
  call g:assert.equals(getpos("'["), [0, 1,  1, 0], 'failed at #296')
  call g:assert.equals(getpos("']"), [0, 3, 10, 0], 'failed at #296')

  %delete

  " #297
  call append(0, ['{[(foo)]}', '{[abarb]}', '{[(baz)]}'])
  execute "normal gg3sr\<C-v>29l({["
  call g:assert.equals(getline(1),   '({[foo]})',   'failed at #297')
  call g:assert.equals(getline(2),   '({abarb})',   'failed at #297')
  call g:assert.equals(getline(3),   '({[baz]})',   'failed at #297')
  call g:assert.equals(getpos('.'),  [0, 1,  4, 0], 'failed at #297')
  call g:assert.equals(getpos("'["), [0, 1,  1, 0], 'failed at #297')
  call g:assert.equals(getpos("']"), [0, 3, 10, 0], 'failed at #297')

  %delete

  " #298
  call append(0, ['{[(foo)]}', '{[(bar)]}', '{[abazb]}'])
  execute "normal gg3sr\<C-v>29l({["
  call g:assert.equals(getline(1),   '({[foo]})',   'failed at #298')
  call g:assert.equals(getline(2),   '({[bar]})',   'failed at #298')
  call g:assert.equals(getline(3),   '({abazb})',   'failed at #298')
  call g:assert.equals(getpos('.'),  [0, 1,  4, 0], 'failed at #298')
  call g:assert.equals(getpos("'["), [0, 1,  1, 0], 'failed at #298')
  call g:assert.equals(getpos("']"), [0, 3, 10, 0], 'failed at #298')

  set whichwrap&
endfunction
"}}}
function! s:suite.blockwise_n_external_textobj() abort "{{{
  set whichwrap=h,l

  let g:sandwich#recipes = []
  let g:operator#sandwich#recipes = [
        \   {'external': ['i{', 'a{']},
        \   {'external': ['i[', 'a[']},
        \   {'external': ['i(', 'a(']},
        \   {'external': ['it', 'at']},
        \ ]

  " #299
  call append(0, ['(foo)', '(bar)', '(baz)'])
  execute "normal ggsr\<C-v>17l\""
  call g:assert.equals(getline(1), '"foo"', 'failed at #299')
  call g:assert.equals(getline(2), '"bar"', 'failed at #299')
  call g:assert.equals(getline(3), '"baz"', 'failed at #299')

  %delete

  " #300
  call append(0, ['[foo]', '[bar]', '[baz]'])
  execute "normal ggsr\<C-v>17l\""
  call g:assert.equals(getline(1), '"foo"', 'failed at #300')
  call g:assert.equals(getline(2), '"bar"', 'failed at #300')
  call g:assert.equals(getline(3), '"baz"', 'failed at #300')

  %delete

  " #301
  call append(0, ['{foo}', '{bar}', '{baz}'])
  execute "normal ggsr\<C-v>17l\""
  call g:assert.equals(getline(1), '"foo"', 'failed at #301')
  call g:assert.equals(getline(2), '"bar"', 'failed at #301')
  call g:assert.equals(getline(3), '"baz"', 'failed at #301')

  %delete

  " #302
  call append(0, ['<title>foo</title>', '<title>bar</title>', '<title>baz</title>'])
  execute "normal ggsr\<C-v>56l\""
  call g:assert.equals(getline(1), '"foo"', 'failed at #302')
  call g:assert.equals(getline(2), '"bar"', 'failed at #302')
  call g:assert.equals(getline(3), '"baz"', 'failed at #302')

  set whichwrap&
  unlet g:sandwich#recipes
  unlet g:operator#sandwich#recipes
endfunction
"}}}
function! s:suite.blockwise_n_option_cursor() abort  "{{{
  set whichwrap=h,l

  """"" cursor
  """ inner_head
  " #303
  call append(0, ['(((foo)))', '(((bar)))', '(((baz)))'])
  execute "normal gg2sr\<C-v>29l[]"
  call g:assert.equals(getline(1),  '[[(foo)]]',  'failed at #303')
  call g:assert.equals(getline(2),  '[[(bar)]]',  'failed at #303')
  call g:assert.equals(getline(3),  '[[(baz)]]',  'failed at #303')
  call g:assert.equals(getpos('.'), [0, 1, 3, 0], 'failed at #303')

  " #304
  execute "normal sr\<C-v>25l["
  call g:assert.equals(getline(1),  '[[[foo]]]',  'failed at #304')
  call g:assert.equals(getline(2),  '[[[bar]]]',  'failed at #304')
  call g:assert.equals(getline(3),  '[[[baz]]]',  'failed at #304')
  call g:assert.equals(getpos('.'), [0, 1, 4, 0], 'failed at #304')

  %delete

  """ keep
  " #305
  call operator#sandwich#set('replace', 'block', 'cursor', 'keep')
  call append(0, ['(((foo)))', '(((bar)))', '(((baz)))'])
  execute "normal gg2sr\<C-v>29l[]"
  call g:assert.equals(getline(1),  '[[(foo)]]',  'failed at #305')
  call g:assert.equals(getline(2),  '[[(bar)]]',  'failed at #305')
  call g:assert.equals(getline(3),  '[[(baz)]]',  'failed at #305')
  call g:assert.equals(getpos('.'), [0, 1, 1, 0], 'failed at #305')

  " #306
  execute "normal 2lsr\<C-v>25l["
  call g:assert.equals(getline(1),  '[[[foo]]]',  'failed at #306')
  call g:assert.equals(getline(2),  '[[[bar]]]',  'failed at #306')
  call g:assert.equals(getline(3),  '[[[baz]]]',  'failed at #306')
  call g:assert.equals(getpos('.'), [0, 1, 3, 0], 'failed at #306')

  %delete

  """ inner_tail
  " #307
  call operator#sandwich#set('replace', 'block', 'cursor', 'inner_tail')
  call append(0, ['(((foo)))', '(((bar)))', '(((baz)))'])
  execute "normal gg2sr\<C-v>29l[]"
  call g:assert.equals(getline(1),  '[[(foo)]]',  'failed at #307')
  call g:assert.equals(getline(2),  '[[(bar)]]',  'failed at #307')
  call g:assert.equals(getline(3),  '[[(baz)]]',  'failed at #307')
  call g:assert.equals(getpos('.'), [0, 3, 7, 0], 'failed at #307')

  " #308
  execute "normal gg2lsr\<C-v>25l["
  call g:assert.equals(getline(1),  '[[[foo]]]',  'failed at #308')
  call g:assert.equals(getline(2),  '[[[bar]]]',  'failed at #308')
  call g:assert.equals(getline(3),  '[[[baz]]]',  'failed at #308')
  call g:assert.equals(getpos('.'), [0, 3, 6, 0], 'failed at #308')

  %delete

  """ front
  " #309
  call operator#sandwich#set('replace', 'block', 'cursor', 'front')
  call append(0, ['(((foo)))', '(((bar)))', '(((baz)))'])
  execute "normal gg2sr\<C-v>29l[]"
  call g:assert.equals(getline(1),  '[[(foo)]]',  'failed at #309')
  call g:assert.equals(getline(2),  '[[(bar)]]',  'failed at #309')
  call g:assert.equals(getline(3),  '[[(baz)]]',  'failed at #309')
  call g:assert.equals(getpos('.'), [0, 1, 1, 0], 'failed at #309')

  " #310
  execute "normal 2lsr\<C-v>25l["
  call g:assert.equals(getline(1),  '[[[foo]]]',  'failed at #310')
  call g:assert.equals(getline(2),  '[[[bar]]]',  'failed at #310')
  call g:assert.equals(getline(3),  '[[[baz]]]',  'failed at #310')
  call g:assert.equals(getpos('.'), [0, 1, 3, 0], 'failed at #310')

  %delete

  """ end
  " #311
  call operator#sandwich#set('replace', 'block', 'cursor', 'end')
  call append(0, ['(((foo)))', '(((bar)))', '(((baz)))'])
  execute "normal gg2sr\<C-v>29l[]"
  call g:assert.equals(getline(1),  '[[(foo)]]',  'failed at #311')
  call g:assert.equals(getline(2),  '[[(bar)]]',  'failed at #311')
  call g:assert.equals(getline(3),  '[[(baz)]]',  'failed at #311')
  call g:assert.equals(getpos('.'), [0, 3, 9, 0], 'failed at #311')

  " #312
  execute "normal 6h2ksr\<C-v>25l["
  call g:assert.equals(getline(1),  '[[[foo]]]',  'failed at #312')
  call g:assert.equals(getline(2),  '[[[bar]]]',  'failed at #312')
  call g:assert.equals(getline(3),  '[[[baz]]]',  'failed at #312')
  call g:assert.equals(getpos('.'), [0, 3, 7, 0], 'failed at #312')

  set whichwrap&
  call operator#sandwich#set('replace', 'block', 'cursor', 'inner_head')
endfunction
"}}}
function! s:suite.blockwise_n_option_noremap() abort  "{{{
  set whichwrap=h,l

  """"" noremap
  let g:sandwich#recipes = []
  let g:operator#sandwich#recipes = [{'external': ['i{', 'a{']}]
  xnoremap i{ i(
  xnoremap a{ a(

  """ on
  " #313
  call append(0, ['{foo}', '{bar}', '{baz}'])
  execute "normal ggsr\<C-v>17l\""
  call g:assert.equals(getline(1), '"foo"', 'failed at #313')
  call g:assert.equals(getline(2), '"bar"', 'failed at #313')
  call g:assert.equals(getline(3), '"baz"', 'failed at #313')

  %delete

  " #314
  call append(0, ['(foo)', '(bar)', '(baz)'])
  execute "normal ggsr\<C-v>17l\""
  call g:assert.equals(getline(1), '(foo)', 'failed at #314')
  call g:assert.equals(getline(2), '(bar)', 'failed at #314')
  call g:assert.equals(getline(3), '(baz)', 'failed at #314')

  %delete

  """ off
  " #315
  call operator#sandwich#set('replace', 'block', 'noremap', 0)
  call append(0, ['{foo}', '{bar}', '{baz}'])
  execute "normal ggsr\<C-v>17l\""
  call g:assert.equals(getline(1), '{foo}', 'failed at #315')
  call g:assert.equals(getline(2), '{bar}', 'failed at #315')
  call g:assert.equals(getline(3), '{baz}', 'failed at #315')

  %delete

  " #316
  call append(0, ['(foo)', '(bar)', '(baz)'])
  execute "normal ggsr\<C-v>17l\""
  call g:assert.equals(getline(1), '"foo"', 'failed at #316')
  call g:assert.equals(getline(2), '"bar"', 'failed at #316')
  call g:assert.equals(getline(3), '"baz"', 'failed at #316')

  set whichwrap&
  unlet! g:sandwich#recipes
  unlet! g:operator#sandwich#recipes
  xunmap i{
  xunmap a{
  call operator#sandwich#set('replace', 'block', 'noremap', 1)
endfunction
"}}}
function! s:suite.blockwise_n_option_regex() abort  "{{{
  set whichwrap=h,l
  let g:sandwich#recipes = []
  let g:operator#sandwich#recipes = [{'buns': ['\d\+', '\d\+']}]

  """ off
  " #317
  call append(0, ['\d\+foo\d\+', '\d\+bar\d\+', '\d\+baz\d\+'])
  execute "normal ggsr\<C-v>35l\""
  call g:assert.equals(getline(1), '"foo"', 'failed at #317')
  call g:assert.equals(getline(2), '"bar"', 'failed at #317')
  call g:assert.equals(getline(3), '"baz"', 'failed at #317')

  %delete

  " #318
  call append(0, ['888foo888', '888bar888', '888baz888'])
  execute "normal ggsr\<C-v>29l\""
  call g:assert.equals(getline(1), '"88foo88"', 'failed at #318')
  call g:assert.equals(getline(2), '"88bar88"', 'failed at #318')
  call g:assert.equals(getline(3), '"88baz88"', 'failed at #318')

  %delete

  """ on
  call operator#sandwich#set('replace', 'block', 'regex', 1)
  " #319
  call append(0, ['\d\+foo\d\+', '\d\+bar\d\+', '\d\+baz\d\+'])
  execute "normal ggsr\<C-v>35l\""
  call g:assert.equals(getline(1), '\d\+foo\d\+', 'failed at #319')
  call g:assert.equals(getline(2), '\d\+bar\d\+', 'failed at #319')
  call g:assert.equals(getline(3), '\d\+baz\d\+', 'failed at #319')

  %delete

  " #320
  call append(0, ['888foo888', '888bar888', '888baz888'])
  execute "normal ggsr\<C-v>29l\""
  call g:assert.equals(getline(1), '"foo"', 'failed at #320')
  call g:assert.equals(getline(2), '"bar"', 'failed at #320')
  call g:assert.equals(getline(3), '"baz"', 'failed at #320')

  set whichwrap&
  call operator#sandwich#set('replace', 'block', 'regex', 0)
  unlet! g:sandwich#recipes
  unlet! g:operator#sandwich#recipes
endfunction
"}}}
function! s:suite.blockwise_n_option_skip_space() abort  "{{{
  set whichwrap=h,l

  """ on
  " #321
  call append(0, ['"foo"', '"bar"', '"baz"'])
  execute "normal ggsr\<C-v>17l("
  call g:assert.equals(getline(1), '(foo)', 'failed at #321')
  call g:assert.equals(getline(2), '(bar)', 'failed at #321')
  call g:assert.equals(getline(3), '(baz)', 'failed at #321')

  %delete

  " #322
  call append(0, [' "foo"', ' "bar"', ' "baz"'])
  execute "normal ggsr\<C-v>20l("
  call g:assert.equals(getline(1), ' (foo)', 'failed at #322')
  call g:assert.equals(getline(2), ' (bar)', 'failed at #322')
  call g:assert.equals(getline(3), ' (baz)', 'failed at #322')

  %delete

  " #323
  call append(0, ['"foo" ', '"bar" ', '"baz" '])
  execute "normal ggsr\<C-v>20l("
  call g:assert.equals(getline(1), '(foo) ', 'failed at #323')
  call g:assert.equals(getline(2), '(bar) ', 'failed at #323')
  call g:assert.equals(getline(3), '(baz) ', 'failed at #323')

  %delete

  " #324
  " do not skip!
  call append(0, [' "foo" ', ' "bar" ', ' "baz" '])
  execute "normal ggsr\<C-v>23l("
  call g:assert.equals(getline(1), '("foo")', 'failed at #324')
  call g:assert.equals(getline(2), '("bar")', 'failed at #324')
  call g:assert.equals(getline(3), '("baz")', 'failed at #324')

  %delete

  """ off
  call operator#sandwich#set('replace', 'block', 'skip_space', 0)
  " #325
  call append(0, ['"foo"', '"bar"', '"baz"'])
  execute "normal ggsr\<C-v>17l("
  call g:assert.equals(getline(1), '(foo)', 'failed at #325')
  call g:assert.equals(getline(2), '(bar)', 'failed at #325')
  call g:assert.equals(getline(3), '(baz)', 'failed at #325')

  %delete

  " #326
  call append(0, [' "foo"', ' "bar"', ' "baz"'])
  execute "normal ggsr\<C-v>20l("
  call g:assert.equals(getline(1), ' "foo"', 'failed at #326')
  call g:assert.equals(getline(2), ' "bar"', 'failed at #326')
  call g:assert.equals(getline(3), ' "baz"', 'failed at #326')

  %delete

  " #327
  call append(0, ['"foo" ', '"bar" ', '"baz" '])
  execute "normal ggsr\<C-v>20l("
  call g:assert.equals(getline(1), '"foo" ', 'failed at #327')
  call g:assert.equals(getline(2), '"bar" ', 'failed at #327')
  call g:assert.equals(getline(3), '"baz" ', 'failed at #327')

  %delete

  " #328
  " do not skip!
  call append(0, [' "foo" ', ' "bar" ', ' "baz" '])
  execute "normal ggsr\<C-v>23l("
  call g:assert.equals(getline(1), '("foo")', 'failed at #328')
  call g:assert.equals(getline(2), '("bar")', 'failed at #328')
  call g:assert.equals(getline(3), '("baz")', 'failed at #328')

  set whichwrap&
  call operator#sandwich#set('replace', 'block', 'skip_space', 1)
endfunction
"}}}
function! s:suite.blockwise_n_option_skip_char() abort "{{{
  set whichwrap=h,l

  """ off
  " #329
  call append(0, ['aa(foo)bb', 'aa(bar)bb', 'aa(baz)bb'])
  execute "normal ggsr\<C-v>29l\""
  call g:assert.equals(getline(1), 'aa(foo)bb', 'failed at #329')
  call g:assert.equals(getline(2), 'aa(bar)bb', 'failed at #329')
  call g:assert.equals(getline(3), 'aa(baz)bb', 'failed at #329')

  %delete

  """ on
  call operator#sandwich#set('replace', 'block', 'skip_char', 1)
  " #330
  call append(0, ['aa(foo)bb', 'aa(bar)bb', 'aa(baz)bb'])
  execute "normal ggsr\<C-v>29l\""
  call g:assert.equals(getline(1), 'aa"foo"bb', 'failed at #330')
  call g:assert.equals(getline(2), 'aa"bar"bb', 'failed at #330')
  call g:assert.equals(getline(3), 'aa"baz"bb', 'failed at #330')

  set whichwrap&
  call operator#sandwich#set('replace', 'block', 'skip_char', 0)
endfunction
"}}}
function! s:suite.blockwise_n_option_command() abort  "{{{
  set whichwrap=h,l
  call operator#sandwich#set('replace', 'block', 'command', ["normal! `[d\<C-v>`]"])

  " #331
  call append(0, ['(foo)', '(bar)', '(baz)'])
  execute "normal ggsr\<C-v>17l\""
  call g:assert.equals(getline(1), '""', 'failed at #331')
  call g:assert.equals(getline(2), '""', 'failed at #331')
  call g:assert.equals(getline(3), '""', 'failed at #331')

  set whichwrap&
  call operator#sandwich#set('replace', 'block', 'command', [])
endfunction
"}}}
function! s:suite.blockwise_n_option_query_once() abort  "{{{
  set whichwrap=h,l

  """"" query_once
  """ off
  " #331
  call append(0, ['"""foo"""', '"""bar"""', '"""baz"""'])
  execute "normal gg3sr\<C-v>29l([{"
  call g:assert.equals(getline(1), '([{foo}])',  'failed at #331')
  call g:assert.equals(getline(2), '([{bar}])',  'failed at #331')
  call g:assert.equals(getline(3), '([{baz}])',  'failed at #331')

  %delete

  """ on
  " #332
  call operator#sandwich#set('replace', 'block', 'query_once', 1)
  call append(0, ['"""foo"""', '"""bar"""', '"""baz"""'])
  execute "normal gg3sr\<C-v>29l("
  call g:assert.equals(getline(1), '(((foo)))',  'failed at #332')
  call g:assert.equals(getline(2), '(((bar)))',  'failed at #332')
  call g:assert.equals(getline(3), '(((baz)))',  'failed at #332')

  set whichwrap&
  call operator#sandwich#set('replace', 'block', 'query_once', 0)
endfunction
"}}}
function! s:suite.blockwise_n_option_eval() abort "{{{
  """"" eval
  set whichwrap=h,l
  let g:operator#sandwich#recipes = [{'buns': ['1+1', '1+2'], 'input':['a']}]

  """ 0
  " #333
  call append(0, ['"foo"', '"bar"', '"baz"'])
  execute "normal ggsr\<C-v>17la"
  call g:assert.equals(getline('.'), '1+1foo1+2',  'failed at #333')

  %delete

  """ 1
  " #334
  call operator#sandwich#set('replace', 'block', 'eval', 1)
  call append(0, ['"foo"', '"bar"', '"baz"'])
  execute "normal ggsr\<C-v>17la"
  call g:assert.equals(getline('.'), '2foo3',  'failed at #334')

  """ 2
  " This case cannot be tested since this option makes difference only in
  " dot-repeat.

  set whichwrap&
  unlet! g:operator#sandwich#recipes
  call operator#sandwich#set('replace', 'block', 'eval', 0)
endfunction
"}}}

function! s:suite.blockwise_x_default_recipes() abort "{{{
  " #335
  call append(0, ['(foo)', '(bar)', '(baz)'])
  execute "normal gg\<C-v>2j4lsr["
  call g:assert.equals(getline(1),   '[foo]',      'failed at #335')
  call g:assert.equals(getline(2),   '[bar]',      'failed at #335')
  call g:assert.equals(getline(3),   '[baz]',      'failed at #335')
  call g:assert.equals(getpos('.'),  [0, 1, 2, 0], 'failed at #335')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #335')
  call g:assert.equals(getpos("']"), [0, 3, 6, 0], 'failed at #335')

  %delete

  " #336
  call append(0, ['[foo]', '[bar]', '[baz]'])
  execute "normal gg\<C-v>2j4lsr{"
  call g:assert.equals(getline(1),   '{foo}',      'failed at #336')
  call g:assert.equals(getline(2),   '{bar}',      'failed at #336')
  call g:assert.equals(getline(3),   '{baz}',      'failed at #336')
  call g:assert.equals(getpos('.'),  [0, 1, 2, 0], 'failed at #336')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #336')
  call g:assert.equals(getpos("']"), [0, 3, 6, 0], 'failed at #336')

  %delete

  " #337
  call append(0, ['{foo}', '{bar}', '{baz}'])
  execute "normal gg\<C-v>2j4lsr<"
  call g:assert.equals(getline(1),   '<foo>',      'failed at #337')
  call g:assert.equals(getline(2),   '<bar>',      'failed at #337')
  call g:assert.equals(getline(3),   '<baz>',      'failed at #337')
  call g:assert.equals(getpos('.'),  [0, 1, 2, 0], 'failed at #337')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #337')
  call g:assert.equals(getpos("']"), [0, 3, 6, 0], 'failed at #337')

  %delete

  " #338
  call append(0, ['<foo>', '<bar>', '<baz>'])
  execute "normal gg\<C-v>2j4lsr("
  call g:assert.equals(getline(1),   '(foo)',      'failed at #338')
  call g:assert.equals(getline(2),   '(bar)',      'failed at #338')
  call g:assert.equals(getline(3),   '(baz)',      'failed at #338')
  call g:assert.equals(getpos('.'),  [0, 1, 2, 0], 'failed at #338')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #338')
  call g:assert.equals(getpos("']"), [0, 3, 6, 0], 'failed at #338')
endfunction
"}}}
function! s:suite.blockwise_x_not_registered() abort "{{{
  " #339
  call append(0, ['afooa', 'abara', 'abaza'])
  execute "normal gg\<C-v>2j4lsrb"
  call g:assert.equals(getline(1),   'bfoob',      'failed at #339')
  call g:assert.equals(getline(2),   'bbarb',      'failed at #339')
  call g:assert.equals(getline(3),   'bbazb',      'failed at #339')
  call g:assert.equals(getpos('.'),  [0, 1, 2, 0], 'failed at #339')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #339')
  call g:assert.equals(getpos("']"), [0, 3, 6, 0], 'failed at #339')

  " #340
  call append(0, ['+foo+', '+bar+', '+baz+'])
  execute "normal gg\<C-v>2j4lsr*"
  call g:assert.equals(getline(1),   '*foo*',      'failed at #340')
  call g:assert.equals(getline(2),   '*bar*',      'failed at #340')
  call g:assert.equals(getline(3),   '*baz*',      'failed at #340')
  call g:assert.equals(getpos('.'),  [0, 1, 2, 0], 'failed at #340')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #340')
  call g:assert.equals(getpos("']"), [0, 3, 6, 0], 'failed at #340')
endfunction
"}}}
function! s:suite.blockwise_x_positioning() abort "{{{
  " #341
  call append(0, ['(foo)bar', '(foo)bar', '(foo)bar'])
  execute "normal gg\<C-v>2j4lsr["
  call g:assert.equals(getline(1),   '[foo]bar',   'failed at #341')
  call g:assert.equals(getline(2),   '[foo]bar',   'failed at #341')
  call g:assert.equals(getline(3),   '[foo]bar',   'failed at #341')
  call g:assert.equals(getpos('.'),  [0, 1, 2, 0], 'failed at #341')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #341')
  call g:assert.equals(getpos("']"), [0, 3, 6, 0], 'failed at #341')

  %delete

  " #342
  call append(0, ['foo(bar)', 'foo(bar)', 'foo(bar)'])
  execute "normal gg3l\<C-v>2j4lsr["
  call g:assert.equals(getline(1),   'foo[bar]',   'failed at #342')
  call g:assert.equals(getline(2),   'foo[bar]',   'failed at #342')
  call g:assert.equals(getline(3),   'foo[bar]',   'failed at #342')
  call g:assert.equals(getpos('.'),  [0, 1, 5, 0], 'failed at #342')
  call g:assert.equals(getpos("'["), [0, 1, 4, 0], 'failed at #342')
  call g:assert.equals(getpos("']"), [0, 3, 9, 0], 'failed at #342')

  %delete

  " #343
  call append(0, ['foo(bar)baz', 'foo(bar)baz', 'foo(bar)baz'])
  execute "normal gg3l\<C-v>2j4lsr["
  call g:assert.equals(getline(1),   'foo[bar]baz', 'failed at #343')
  call g:assert.equals(getline(2),   'foo[bar]baz', 'failed at #343')
  call g:assert.equals(getline(3),   'foo[bar]baz', 'failed at #343')
  call g:assert.equals(getpos('.'),  [0, 1, 5, 0],  'failed at #343')
  call g:assert.equals(getpos("'["), [0, 1, 4, 0],  'failed at #343')
  call g:assert.equals(getpos("']"), [0, 3, 9, 0],  'failed at #343')

  %delete

  " #344
  call append(0, ['(foo)', '(bar)', 'bazbaz'])
  execute "normal gg\<C-v>2j4lsr["
  call g:assert.equals(getline(1),   '[foo]',      'failed at #344')
  call g:assert.equals(getline(2),   '[bar]',      'failed at #344')
  call g:assert.equals(getline(3),   'bazbaz',     'failed at #344')
  call g:assert.equals(getpos('.'),  [0, 1, 2, 0], 'failed at #344')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #344')
  call g:assert.equals(getpos("']"), [0, 2, 6, 0], 'failed at #344')

  %delete

  " #345
  call append(0, ['(foo)', 'barbar', '(baz)'])
  execute "normal gg\<C-v>2j4lsr["
  call g:assert.equals(getline(1),   '[foo]',      'failed at #345')
  call g:assert.equals(getline(2),   'barbar',     'failed at #345')
  call g:assert.equals(getline(3),   '[baz]',      'failed at #345')
  call g:assert.equals(getpos('.'),  [0, 1, 2, 0], 'failed at #345')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #345')
  call g:assert.equals(getpos("']"), [0, 3, 6, 0], 'failed at #345')

  %delete

  " #346
  call append(0, ['foofoo', '(bar)', '(baz)'])
  execute "normal gg\<C-v>2j4lsr["
  call g:assert.equals(getline(1),   'foofoo',     'failed at #346')
  call g:assert.equals(getline(2),   '[bar]',      'failed at #346')
  call g:assert.equals(getline(3),   '[baz]',      'failed at #346')
  call g:assert.equals(getpos('.'),  [0, 2, 2, 0], 'failed at #346')
  call g:assert.equals(getpos("'["), [0, 2, 1, 0], 'failed at #346')
  call g:assert.equals(getpos("']"), [0, 3, 6, 0], 'failed at #346')

  %delete

  """ terminal-extended block-wise visual mode
  " #347
  call append(0, ['"fooo"', '"baaar"', '"baz"'])
  execute "normal gg\<C-v>2j$sr("
  call g:assert.equals(getline(1),   '(fooo)',     'failed at #347')
  call g:assert.equals(getline(2),   '(baaar)',    'failed at #347')
  call g:assert.equals(getline(3),   '(baz)',      'failed at #347')
  call g:assert.equals(getpos('.'),  [0, 1, 2, 0], 'failed at #347')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #347')
  call g:assert.equals(getpos("']"), [0, 3, 6, 0], 'failed at #347')

  %delete

  " #348
  call append(0, ['"foooo"', '"bar"', '"baaz"'])
  execute "normal gg\<C-v>2j$sr("
  call g:assert.equals(getline(1),   '(foooo)',    'failed at #348')
  call g:assert.equals(getline(2),   '(bar)',      'failed at #348')
  call g:assert.equals(getline(3),   '(baaz)',     'failed at #348')
  call g:assert.equals(getpos('.'),  [0, 1, 2, 0], 'failed at #348')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #348')
  call g:assert.equals(getpos("']"), [0, 3, 7, 0], 'failed at #348')

  %delete

  " #349
  call append(0, ['"fooo"', '', '"baz"'])
  execute "normal gg\<C-v>2j$sr("
  call g:assert.equals(getline(1),   '(fooo)',     'failed at #349')
  call g:assert.equals(getline(2),   '',           'failed at #349')
  call g:assert.equals(getline(3),   '(baz)',      'failed at #349')
  call g:assert.equals(getpos('.'),  [0, 1, 2, 0], 'failed at #349')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #349')
  call g:assert.equals(getpos("']"), [0, 3, 6, 0], 'failed at #349')
endfunction
"}}}
function! s:suite.blockwise_x_a_character() abort "{{{
  " #350
  call append(0, ['(a)', '(b)', '(c)'])
  execute "normal gg\<C-v>2j2lsr["
  call g:assert.equals(getline(1),   '[a]',        'failed at #350')
  call g:assert.equals(getline(2),   '[b]',        'failed at #350')
  call g:assert.equals(getline(3),   '[c]',        'failed at #350')
  call g:assert.equals(getpos('.'),  [0, 1, 2, 0], 'failed at #350')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #350')
  call g:assert.equals(getpos("']"), [0, 3, 4, 0], 'failed at #350')
endfunction
"}}}
function! s:suite.blockwise_x_nothing_inside() abort "{{{
  " #351
  call append(0, ['()', '()', '()'])
  execute "normal gg\<C-v>2jlsr["
  call g:assert.equals(getline(1),   '[]',         'failed at #351')
  call g:assert.equals(getline(2),   '[]',         'failed at #351')
  call g:assert.equals(getline(3),   '[]',         'failed at #351')
  call g:assert.equals(getpos('.'),  [0, 1, 2, 0], 'failed at #351')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #351')
  call g:assert.equals(getpos("']"), [0, 3, 3, 0], 'failed at #351')

  %delete

  " #352
  call append(0, ['foo()bar', 'foo()bar', 'foo()bar'])
  execute "normal gg3l\<C-v>2jlsr["
  call g:assert.equals(getline(1),   'foo[]bar',   'failed at #352')
  call g:assert.equals(getline(2),   'foo[]bar',   'failed at #352')
  call g:assert.equals(getline(3),   'foo[]bar',   'failed at #352')
  call g:assert.equals(getpos('.'),  [0, 1, 5, 0], 'failed at #352')
  call g:assert.equals(getpos("'["), [0, 1, 4, 0], 'failed at #352')
  call g:assert.equals(getpos("']"), [0, 3, 6, 0], 'failed at #352')
endfunction
"}}}
function! s:suite.blockwise_x_count() abort "{{{
  " #353
  call append(0, ['[(foo)]', '[(bar)]', '[(baz)]'])
  execute "normal gg\<C-v>2j6l3sr({"
  call g:assert.equals(getline(1),   '({foo})',    'failed at #353')
  call g:assert.equals(getline(2),   '({bar})',    'failed at #353')
  call g:assert.equals(getline(3),   '({baz})',    'failed at #353')
  call g:assert.equals(getpos('.'),  [0, 1, 3, 0], 'failed at #353')
  call g:assert.equals(getpos("'["), [0, 1, 1, 0], 'failed at #353')
  call g:assert.equals(getpos("']"), [0, 3, 8, 0], 'failed at #353')

  %delete

  " #354
  call append(0, ['{[(foo)]}', '{[(bar)]}', '{[(baz)]}'])
  execute "normal gg\<C-v>2j8l3sr({["
  call g:assert.equals(getline(1),   '({[foo]})',   'failed at #354')
  call g:assert.equals(getline(2),   '({[bar]})',   'failed at #354')
  call g:assert.equals(getline(3),   '({[baz]})',   'failed at #354')
  call g:assert.equals(getpos('.'),  [0, 1,  4, 0], 'failed at #354')
  call g:assert.equals(getpos("'["), [0, 1,  1, 0], 'failed at #354')
  call g:assert.equals(getpos("']"), [0, 3, 10, 0], 'failed at #354')

  %delete

  " #355
  call append(0, ['{[afoob]}', '{[(bar)]}', '{[(baz)]}'])
  execute "normal gg\<C-v>2j8l3sr({["
  call g:assert.equals(getline(1),   '({afoob})',   'failed at #355')
  call g:assert.equals(getline(2),   '({[bar]})',   'failed at #355')
  call g:assert.equals(getline(3),   '({[baz]})',   'failed at #355')
  call g:assert.equals(getpos('.'),  [0, 1,  3, 0], 'failed at #355')
  call g:assert.equals(getpos("'["), [0, 1,  1, 0], 'failed at #355')
  call g:assert.equals(getpos("']"), [0, 3, 10, 0], 'failed at #355')

  %delete

  " #356
  call append(0, ['{[(foo)]}', '{[abarb]}', '{[(baz)]}'])
  execute "normal gg\<C-v>2j8l3sr({["
  call g:assert.equals(getline(1),   '({[foo]})',   'failed at #356')
  call g:assert.equals(getline(2),   '({abarb})',   'failed at #356')
  call g:assert.equals(getline(3),   '({[baz]})',   'failed at #356')
  call g:assert.equals(getpos('.'),  [0, 1,  4, 0], 'failed at #356')
  call g:assert.equals(getpos("'["), [0, 1,  1, 0], 'failed at #356')
  call g:assert.equals(getpos("']"), [0, 3, 10, 0], 'failed at #356')

  %delete

  " #357
  call append(0, ['{[(foo)]}', '{[(bar)]}', '{[abazb]}'])
  execute "normal gg\<C-v>2j8l3sr({["
  call g:assert.equals(getline(1),   '({[foo]})',   'failed at #357')
  call g:assert.equals(getline(2),   '({[bar]})',   'failed at #357')
  call g:assert.equals(getline(3),   '({abazb})',   'failed at #357')
  call g:assert.equals(getpos('.'),  [0, 1,  4, 0], 'failed at #357')
  call g:assert.equals(getpos("'["), [0, 1,  1, 0], 'failed at #357')
  call g:assert.equals(getpos("']"), [0, 3, 10, 0], 'failed at #357')
endfunction
"}}}
function! s:suite.blockwise_x_external_textobj() abort "{{{
  let g:sandwich#recipes = []
  let g:operator#sandwich#recipes = [
        \   {'external': ['i{', 'a{']},
        \   {'external': ['i[', 'a[']},
        \   {'external': ['i(', 'a(']},
        \   {'external': ['it', 'at']},
        \ ]

  " #358
  call append(0, ['(foo)', '(bar)', '(baz)'])
  execute "normal gg\<C-v>2j4lsr\""
  call g:assert.equals(getline(1), '"foo"', 'failed at #358')
  call g:assert.equals(getline(2), '"bar"', 'failed at #358')
  call g:assert.equals(getline(3), '"baz"', 'failed at #358')

  %delete

  " #359
  call append(0, ['[foo]', '[bar]', '[baz]'])
  execute "normal gg\<C-v>2j4lsr\""
  call g:assert.equals(getline(1), '"foo"', 'failed at #359')
  call g:assert.equals(getline(2), '"bar"', 'failed at #359')
  call g:assert.equals(getline(3), '"baz"', 'failed at #359')

  %delete

  " #360
  call append(0, ['{foo}', '{bar}', '{baz}'])
  execute "normal gg\<C-v>2j4lsr\""
  call g:assert.equals(getline(1), '"foo"', 'failed at #360')
  call g:assert.equals(getline(2), '"bar"', 'failed at #360')
  call g:assert.equals(getline(3), '"baz"', 'failed at #360')

  %delete

  " #361
  call append(0, ['<title>foo</title>', '<title>bar</title>', '<title>baz</title>'])
  execute "normal gg\<C-v>2j17lsr\""
  call g:assert.equals(getline(1), '"foo"', 'failed at #361')
  call g:assert.equals(getline(2), '"bar"', 'failed at #361')
  call g:assert.equals(getline(3), '"baz"', 'failed at #361')

  unlet g:sandwich#recipes
  unlet g:operator#sandwich#recipes
endfunction
"}}}
function! s:suite.blockwise_x_option_cursor() abort  "{{{
  """"" cursor
  """ inner_head
  " #362
  call append(0, ['(((foo)))', '(((bar)))', '(((baz)))'])
  execute "normal gg\<C-v>2j8l2sr[]"
  call g:assert.equals(getline(1),  '[[(foo)]]',  'failed at #362')
  call g:assert.equals(getline(2),  '[[(bar)]]',  'failed at #362')
  call g:assert.equals(getline(3),  '[[(baz)]]',  'failed at #362')
  call g:assert.equals(getpos('.'), [0, 1, 3, 0], 'failed at #362')

  " #363
  execute "normal \<C-v>2j4lsr["
  call g:assert.equals(getline(1),  '[[[foo]]]',  'failed at #363')
  call g:assert.equals(getline(2),  '[[[bar]]]',  'failed at #363')
  call g:assert.equals(getline(3),  '[[[baz]]]',  'failed at #363')
  call g:assert.equals(getpos('.'), [0, 1, 4, 0], 'failed at #363')

  %delete

  """ keep
  " #364
  call operator#sandwich#set('replace', 'block', 'cursor', 'keep')
  call append(0, ['(((foo)))', '(((bar)))', '(((baz)))'])
  execute "normal gg\<C-v>2j8l2sr[]"
  call g:assert.equals(getline(1),  '[[(foo)]]',  'failed at #364')
  call g:assert.equals(getline(2),  '[[(bar)]]',  'failed at #364')
  call g:assert.equals(getline(3),  '[[(baz)]]',  'failed at #364')
  call g:assert.equals(getpos('.'), [0, 3, 9, 0], 'failed at #364')

  " #365
  execute "normal 2h\<C-v>2k4hsr["
  call g:assert.equals(getline(1),  '[[[foo]]]',  'failed at #365')
  call g:assert.equals(getline(2),  '[[[bar]]]',  'failed at #365')
  call g:assert.equals(getline(3),  '[[[baz]]]',  'failed at #365')
  call g:assert.equals(getpos('.'), [0, 1, 3, 0], 'failed at #365')

  %delete

  """ inner_tail
  " #366
  call operator#sandwich#set('replace', 'block', 'cursor', 'inner_tail')
  call append(0, ['(((foo)))', '(((bar)))', '(((baz)))'])
  execute "normal gg\<C-v>2j8l2sr[]"
  call g:assert.equals(getline(1),  '[[(foo)]]',  'failed at #366')
  call g:assert.equals(getline(2),  '[[(bar)]]',  'failed at #366')
  call g:assert.equals(getline(3),  '[[(baz)]]',  'failed at #366')
  call g:assert.equals(getpos('.'), [0, 3, 7, 0], 'failed at #366')

  " #367
  execute "normal gg2l\<C-v>2j4lsr["
  call g:assert.equals(getline(1),  '[[[foo]]]',  'failed at #367')
  call g:assert.equals(getline(2),  '[[[bar]]]',  'failed at #367')
  call g:assert.equals(getline(3),  '[[[baz]]]',  'failed at #367')
  call g:assert.equals(getpos('.'), [0, 3, 6, 0], 'failed at #367')

  %delete

  """ front
  " #368
  call operator#sandwich#set('replace', 'block', 'cursor', 'front')
  call append(0, ['(((foo)))', '(((bar)))', '(((baz)))'])
  execute "normal gg\<C-v>2j8l2sr[]"
  call g:assert.equals(getline(1),  '[[(foo)]]',  'failed at #368')
  call g:assert.equals(getline(2),  '[[(bar)]]',  'failed at #368')
  call g:assert.equals(getline(3),  '[[(baz)]]',  'failed at #368')
  call g:assert.equals(getpos('.'), [0, 1, 1, 0], 'failed at #368')

  " #369
  execute "normal 2l\<C-v>2j4lsr["
  call g:assert.equals(getline(1),  '[[[foo]]]',  'failed at #369')
  call g:assert.equals(getline(2),  '[[[bar]]]',  'failed at #369')
  call g:assert.equals(getline(3),  '[[[baz]]]',  'failed at #369')
  call g:assert.equals(getpos('.'), [0, 1, 3, 0], 'failed at #369')

  %delete

  """ end
  " #370
  call operator#sandwich#set('replace', 'block', 'cursor', 'end')
  call append(0, ['(((foo)))', '(((bar)))', '(((baz)))'])
  execute "normal gg\<C-v>2j8l2sr[]"
  call g:assert.equals(getline(1),  '[[(foo)]]',  'failed at #370')
  call g:assert.equals(getline(2),  '[[(bar)]]',  'failed at #370')
  call g:assert.equals(getline(3),  '[[(baz)]]',  'failed at #370')
  call g:assert.equals(getpos('.'), [0, 3, 9, 0], 'failed at #370')

  " #371
  execute "normal 6h2k\<C-v>2j4lsr["
  call g:assert.equals(getline(1),  '[[[foo]]]',  'failed at #371')
  call g:assert.equals(getline(2),  '[[[bar]]]',  'failed at #371')
  call g:assert.equals(getline(3),  '[[[baz]]]',  'failed at #371')
  call g:assert.equals(getpos('.'), [0, 3, 7, 0], 'failed at #371')

  call operator#sandwich#set('replace', 'block', 'cursor', 'inner_head')
endfunction
"}}}
function! s:suite.blockwise_x_option_noremap() abort  "{{{
  """"" noremap
  let g:sandwich#recipes = []
  let g:operator#sandwich#recipes = [{'external': ['i{', 'a{']}]
  xnoremap i{ i(
  xnoremap a{ a(

  """ on
  " #372
  call append(0, ['{foo}', '{bar}', '{baz}'])
  execute "normal gg\<C-v>2j4lsr\""
  call g:assert.equals(getline(1), '"foo"', 'failed at #372')
  call g:assert.equals(getline(2), '"bar"', 'failed at #372')
  call g:assert.equals(getline(3), '"baz"', 'failed at #372')

  %delete

  " #373
  call append(0, ['(foo)', '(bar)', '(baz)'])
  execute "normal gg\<C-v>2j4lsr\""
  call g:assert.equals(getline(1), '(foo)', 'failed at #373')
  call g:assert.equals(getline(2), '(bar)', 'failed at #373')
  call g:assert.equals(getline(3), '(baz)', 'failed at #373')

  %delete

  """ off
  " #374
  call operator#sandwich#set('replace', 'block', 'noremap', 0)
  call append(0, ['{foo}', '{bar}', '{baz}'])
  execute "normal gg\<C-v>2j4lsr\""
  call g:assert.equals(getline(1), '{foo}', 'failed at #374')
  call g:assert.equals(getline(2), '{bar}', 'failed at #374')
  call g:assert.equals(getline(3), '{baz}', 'failed at #374')

  %delete

  " #375
  call append(0, ['(foo)', '(bar)', '(baz)'])
  execute "normal gg\<C-v>2j4lsr\""
  call g:assert.equals(getline(1), '"foo"', 'failed at #375')
  call g:assert.equals(getline(2), '"bar"', 'failed at #375')
  call g:assert.equals(getline(3), '"baz"', 'failed at #375')

  unlet! g:sandwich#recipes
  unlet! g:operator#sandwich#recipes
  xunmap i{
  xunmap a{
  call operator#sandwich#set('replace', 'block', 'noremap', 1)
endfunction
"}}}
function! s:suite.blockwise_x_option_regex() abort  "{{{
  let g:sandwich#recipes = []
  let g:operator#sandwich#recipes = [{'buns': ['\d\+', '\d\+']}]

  """ off
  " #376
  call append(0, ['\d\+foo\d\+', '\d\+bar\d\+', '\d\+baz\d\+'])
  execute "normal gg\<C-v>2j10lsr\""
  call g:assert.equals(getline(1), '"foo"', 'failed at #376')
  call g:assert.equals(getline(2), '"bar"', 'failed at #376')
  call g:assert.equals(getline(3), '"baz"', 'failed at #376')

  %delete

  " #377
  call append(0, ['888foo888', '888bar888', '888baz888'])
  execute "normal gg\<C-v>2j8lsr\""
  call g:assert.equals(getline(1), '"88foo88"', 'failed at #377')
  call g:assert.equals(getline(2), '"88bar88"', 'failed at #377')
  call g:assert.equals(getline(3), '"88baz88"', 'failed at #377')

  %delete

  """ on
  call operator#sandwich#set('replace', 'block', 'regex', 1)
  " #378
  call append(0, ['\d\+foo\d\+', '\d\+bar\d\+', '\d\+baz\d\+'])
  execute "normal gg\<C-v>2j10lsr\""
  call g:assert.equals(getline(1), '\d\+foo\d\+', 'failed at #378')
  call g:assert.equals(getline(2), '\d\+bar\d\+', 'failed at #378')
  call g:assert.equals(getline(3), '\d\+baz\d\+', 'failed at #378')

  %delete

  " #379
  call append(0, ['888foo888', '888bar888', '888baz888'])
  execute "normal gg\<C-v>2j8lsr\""
  call g:assert.equals(getline(1), '"foo"', 'failed at #379')
  call g:assert.equals(getline(2), '"bar"', 'failed at #379')
  call g:assert.equals(getline(3), '"baz"', 'failed at #379')

  call operator#sandwich#set('replace', 'block', 'regex', 0)
  unlet! g:sandwich#recipes
  unlet! g:operator#sandwich#recipes
endfunction
"}}}
function! s:suite.blockwise_x_option_skip_space() abort  "{{{
  """ on
  " #380
  call append(0, ['"foo"', '"bar"', '"baz"'])
  execute "normal gg\<C-v>2j4lsr("
  call g:assert.equals(getline(1), '(foo)', 'failed at #380')
  call g:assert.equals(getline(2), '(bar)', 'failed at #380')
  call g:assert.equals(getline(3), '(baz)', 'failed at #380')

  %delete

  " #381
  call append(0, [' "foo"', ' "bar"', ' "baz"'])
  execute "normal gg0\<C-v>2j5lsr("
  call g:assert.equals(getline(1), ' (foo)', 'failed at #381')
  call g:assert.equals(getline(2), ' (bar)', 'failed at #381')
  call g:assert.equals(getline(3), ' (baz)', 'failed at #381')

  %delete

  " #382
  call append(0, ['"foo" ', '"bar" ', '"baz" '])
  execute "normal gg\<C-v>2j5lsr("
  call g:assert.equals(getline(1), '(foo) ', 'failed at #382')
  call g:assert.equals(getline(2), '(bar) ', 'failed at #382')
  call g:assert.equals(getline(3), '(baz) ', 'failed at #382')

  %delete

  " #383
  " do not skip!
  call append(0, [' "foo" ', ' "bar" ', ' "baz" '])
  execute "normal gg0\<C-v>2j6lsr("
  call g:assert.equals(getline(1), '("foo")', 'failed at #383')
  call g:assert.equals(getline(2), '("bar")', 'failed at #383')
  call g:assert.equals(getline(3), '("baz")', 'failed at #383')

  %delete

  """ off
  call operator#sandwich#set('replace', 'block', 'skip_space', 0)
  " #384
  call append(0, ['"foo"', '"bar"', '"baz"'])
  execute "normal gg\<C-v>2j4lsr("
  call g:assert.equals(getline(1), '(foo)', 'failed at #384')
  call g:assert.equals(getline(2), '(bar)', 'failed at #384')
  call g:assert.equals(getline(3), '(baz)', 'failed at #384')

  %delete

  " #385
  call append(0, [' "foo"', ' "bar"', ' "baz"'])
  execute "normal gg0\<C-v>2j5lsr("
  call g:assert.equals(getline(1), ' "foo"', 'failed at #385')
  call g:assert.equals(getline(2), ' "bar"', 'failed at #385')
  call g:assert.equals(getline(3), ' "baz"', 'failed at #385')

  %delete

  " #386
  call append(0, ['"foo" ', '"bar" ', '"baz" '])
  execute "normal gg\<C-v>2j5lsr("
  call g:assert.equals(getline(1), '"foo" ', 'failed at #386')
  call g:assert.equals(getline(2), '"bar" ', 'failed at #386')
  call g:assert.equals(getline(3), '"baz" ', 'failed at #386')

  %delete

  " #387
  " do not skip!
  call append(0, [' "foo" ', ' "bar" ', ' "baz" '])
  execute "normal gg0\<C-v>2j6lsr("
  call g:assert.equals(getline(1), '("foo")', 'failed at #387')
  call g:assert.equals(getline(2), '("bar")', 'failed at #387')
  call g:assert.equals(getline(3), '("baz")', 'failed at #387')

  call operator#sandwich#set('replace', 'block', 'skip_space', 1)
endfunction
"}}}
function! s:suite.blockwise_x_option_skip_char() abort "{{{
  """ off
  " #388
  call append(0, ['aa(foo)bb', 'aa(bar)bb', 'aa(baz)bb'])
  execute "normal gg\<C-v>2j8lsr\""
  call g:assert.equals(getline(1), 'aa(foo)bb', 'failed at #388')
  call g:assert.equals(getline(2), 'aa(bar)bb', 'failed at #388')
  call g:assert.equals(getline(3), 'aa(baz)bb', 'failed at #388')

  %delete

  """ on
  call operator#sandwich#set('replace', 'block', 'skip_char', 1)
  " #389
  call append(0, ['aa(foo)bb', 'aa(bar)bb', 'aa(baz)bb'])
  execute "normal gg\<C-v>2j8lsr\""
  call g:assert.equals(getline(1), 'aa"foo"bb', 'failed at #389')
  call g:assert.equals(getline(2), 'aa"bar"bb', 'failed at #389')
  call g:assert.equals(getline(3), 'aa"baz"bb', 'failed at #389')

  call operator#sandwich#set('replace', 'block', 'skip_char', 0)
endfunction
"}}}
function! s:suite.blockwise_x_option_command() abort  "{{{
  call operator#sandwich#set('replace', 'block', 'command', ["normal! `[d\<C-v>`]"])

  " #390
  call append(0, ['(foo)', '(bar)', '(baz)'])
  execute "normal gg\<C-v>2j4lsr\""
  call g:assert.equals(getline(1), '""', 'failed at #390')
  call g:assert.equals(getline(2), '""', 'failed at #390')
  call g:assert.equals(getline(3), '""', 'failed at #390')

  call operator#sandwich#set('replace', 'block', 'command', [])
endfunction
"}}}
function! s:suite.blockwise_x_option_query_once() abort  "{{{
  """"" query_once
  """ off
  " #390
  call append(0, ['"""foo"""', '"""bar"""', '"""baz"""'])
  execute "normal gg\<C-v>2j8l3sr([{"
  call g:assert.equals(getline(1), '([{foo}])',  'failed at #390')
  call g:assert.equals(getline(2), '([{bar}])',  'failed at #390')
  call g:assert.equals(getline(3), '([{baz}])',  'failed at #390')

  %delete

  """ on
  " #391
  call operator#sandwich#set('replace', 'block', 'query_once', 1)
  call append(0, ['"""foo"""', '"""bar"""', '"""baz"""'])
  execute "normal gg\<C-v>2j8l3sr("
  call g:assert.equals(getline(1), '(((foo)))',  'failed at #391')
  call g:assert.equals(getline(2), '(((bar)))',  'failed at #391')
  call g:assert.equals(getline(3), '(((baz)))',  'failed at #391')

  call operator#sandwich#set('replace', 'block', 'query_once', 0)
endfunction
"}}}
function! s:suite.blockwise_x_option_eval() abort "{{{
  """"" eval
  let g:operator#sandwich#recipes = [{'buns': ['1+1', '1+2'], 'input':['a']}]

  """ 0
  " #392
  call append(0, ['"foo"', '"bar"', '"baz"'])
  execute "normal gg\<C-v>2j4lsra"
  call g:assert.equals(getline('.'), '1+1foo1+2',  'failed at #392')

  %delete

  """ 1
  " #393
  call operator#sandwich#set('replace', 'block', 'eval', 1)
  call append(0, ['"foo"', '"bar"', '"baz"'])
  execute "normal gg\<C-v>2j4lsra"
  call g:assert.equals(getline('.'), '2foo3',  'failed at #393')

  """ 2
  " This case cannot be tested since this option makes difference only in
  " dot-repeat.

  unlet! g:operator#sandwich#recipes
  call operator#sandwich#set('replace', 'block', 'eval', 0)
endfunction
"}}}

" vim:set foldmethod=marker:
" vim:set commentstring="%s: