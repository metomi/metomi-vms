augroup filetype
  au! BufRead,BufnewFile *suite.rc set filetype=cylc
augroup END
if has("folding") | set foldlevelstart=99 | endif

augroup filetype
  au! BufRead,BufnewFile rose-*.conf,rose-*.info set filetype=rose-conf
augroup END
