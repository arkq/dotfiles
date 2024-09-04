set history save on
set history size 1000
set history remove-duplicates 10
set history filename ~/.gdb_history
set pagination off
# do not stop during thread cancellation
handle SIG32 noprint nostop pass
# no-fork mode for check test framework
set environment CK_FORK no
