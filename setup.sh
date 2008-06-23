#!/bin/bash

export PATH=$MHOME/bin:$PATH

if [ `uname` = Darwin ]; then
	. $MHOME/env/Darwin.env
elif [ `uname` = Linux ]; then
	. $MHOME/env/Linux.env
fi
