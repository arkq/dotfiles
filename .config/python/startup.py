# Startup script for python which enables history and tab name completion
# for the interpreter interactive mode.

import atexit
import os
import readline
import rlcompleter
import sys

if sys.version_info < (3, 13):
    history = (os.getenv("PYTHON_HISTORY") or
               os.path.expanduser("~/.python_history"))
    # Handler for saving history.
    def save_history(history=history):
        import readline
        readline.write_history_file(history)
    # Read history, if it exists.
    if os.path.exists(history):
        readline.set_history_length(10000)
        readline.read_history_file(history)
    # Register saving handler.
    atexit.register(save_history)
    # Enable completion.
    readline.parse_and_bind('tab: complete')
    # Cleanup.
    del save_history, history

# Cleanup.
del atexit, os, readline, rlcompleter, sys
