#!/usr/bin/env sh

PREFIX=$HOME/.local

./configure --with-features=huge \
            --enable-multibyte \
	    --enable-rubyinterp=yes \
	    --enable-pythoninterp=yes \
	    --with-python-config-dir=/usr/lib/python2.7/config-x86_64-linux-gnu/ \
	    --enable-python3interp=yes \
	    --with-python3-config-dir=$PREFIX/lib/python3.6/config-3.6m-x86_64-linux-gnu \
	    --enable-perlinterp=yes \
	    --enable-luainterp=yes \
            --enable-cscope \
            LDFLAGS=-Wl,-rpath,$PREFIX/lib \
            --prefix=$PREFIX

make VIMRUNTIMEDIR=$PREFIX/share/vim/vim81 -j8
