#!/bin/bash

## Add system-specific environment definitions.
## Assumes MHOME is pointing to this directory.
## Add the following to your .bashrc (or .zshrc):

## export MHOME=/path/to/mosesmake
## if [ -f $MHOME/setup.sh ]; then
## 	. $MHOME/setup.sh
## fi


export PATH=$MHOME/bin:$PATH

if [ `uname` = Darwin ]; then
	. $MHOME/env/Darwin.env
elif [ `uname` = Linux ]; then
	. $MHOME/env/Linux.env
fi
