if repl.VERSION >= 0.8 then
  repl:loadplugin 'linenoise'
  repl:loadplugin 'history'
  repl:loadplugin 'completion'
  repl:loadplugin 'autoreturn'
  repl:loadplugin 'filename_completion'
  repl:loadplugin 'pretty_print'
  repl:loadplugin 'semicolon_suppress_output'
end
