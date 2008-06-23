#!/bin/bash

## Add system-specific environment definitions.
## Assumes MHOME is pointing to this directory.

export PATH=$MHOME/bin:$PATH

if [ `uname` = Darwin ]; then
	. $MHOME/env/Darwin.env
elif [ `uname` = Linux ]; then
	. $MHOME/env/Linux.env
fi
