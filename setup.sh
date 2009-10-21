#!/bin/bash

## Add system-specific environment definitions.
## Assumes MHOME is pointing to this directory.
## Add the following to your .bashrc (or .zshrc):

## export MHOME=/path/to/mosesmake
## if [ -f $MHOME/setup.sh ]; then
## 	. $MHOME/setup.sh
## fi


MHOME=`dirname $0`
PATH=$MHOME/bin:$PATH
export MHOME PATH

if [ `uname` = Darwin ]; then
	. $MHOME/env/Darwin.env
elif [ `uname` = Linux ]; then
	. $MHOME/env/Linux.env
fi
