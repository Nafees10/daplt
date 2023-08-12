#!/bin/sh
if [ ! -f c_api.o ]; then
	echo "building c_api"
	g++ -c plt/c_api.cpp -fPIC -lstdc++ -o c_api.o
fi
