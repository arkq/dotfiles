# This file is read each time a login shell is started.
# All other interactive shells will read .bashrc only.

# run private tools
export PATH=$HOME/.local/bin:$PATH
# run superuser tools
export PATH=$PATH:/usr/sbin:/sbin/

# python interpreter customization
export PYTHONSTARTUP=$HOME/.pythonrc

# setup Android native development
export NDK=$HOME/bin/opt/android-ndk-r21d
export PATH=$PATH:$NDK/toolchains/llvm/prebuilt/linux-x86_64/bin

# use native CPU capabilities during compilation
export CFLAGS="-march=native -mtune=native -O2 -g -pipe"
export CFLAGS="${CFLAGS} -Wall -Wextra -Wshadow"
export CXXFLAGS="${CFLAGS}"

# enable C/C++ compilation cache
export PATH=/usr/lib/ccache/bin:$PATH
export GCC_COLORS=auto

# always generate compile commands
export CMAKE_EXPORT_COMPILE_COMMANDS=ON

# use full host capacity for make actions
export MAKEFLAGS=-j$(nproc)
export NINJAFLAGS=-j$(nproc)

# setup Go environment
export GOBIN=$HOME/.local/bin
export GOPATH=$HOME/Documents/GO

# access PlatformIO tools
export PATH=$PATH:$HOME/.platformio/penv/bin

# directory change speedups
export CDPATH=.:$HOME/Documents:$HOME

# prevent esoteric editors being spawned
export EDITOR=nvim
export VISUAL=nvim

# show ANSI colors in less
export LESS="-R"

# use custom uncrustify configuration
export UNCRUSTIFY_CONFIG=$HOME/.config/uncrustify/default.cfg

# get rid of accessibility support
export NO_AT_BRIDGE=1

# define our X session type
export XSESSION=fluxbox

# load private configuration
if [ -s ~/.shadow ]; then
	# load if the file is unlocked
	head -c 10 ~/.shadow | grep -q "GITCRYPT" || . ~/.shadow
fi

# load bash settings for login shell as well
[ -n "$BASH" ] && . ~/.bashrc
