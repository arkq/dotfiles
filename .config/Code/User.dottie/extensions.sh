#!/bin/sh
exec echo "
	chrislajoie.vscode-modelines
	eamodio.gitlens
	ms-python.python
	ms-vscode.cpptools
	ms-vscode.go
	streetsidesoftware.code-spell-checker
	vscjava.vscode-java-pack
	vscodevim.vim
" |xargs -n 1 vscode --install-extension
