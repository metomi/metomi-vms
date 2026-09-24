set foldlevelstart=99
augroup filetype
  au! BufRead,BufnewFile rose-*.conf,rose-*.info set filetype=rose-conf
augroup END
