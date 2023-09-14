#!/bin/sh
if [ ! -f "$1/c_api.o" ]; then
	echo "building c_api to $1"
	g++ -c "$1/plt/c_api.cpp" -fPIC -lstdc++ -o "$1/c_api.o"
fi
