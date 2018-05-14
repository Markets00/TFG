#!/usr/bin/env bash

mkdir -p build && \
pushd build && \
clang++ \
	 -o main \
	 ../src/ayumi.c \
	 ../src/imgui.cpp \
	 ../src/imgui_demo.cpp \
	 ../src/imgui_draw.cpp \
	 ../src/imgui-SFML.cpp \
	 ../src/main.cpp \
	 -Wall \
	 -g \
	 -std=c++11 \
	 -Iinclude \
	 -lsfml-graphics \
	 -lsfml-window \
	 -lsfml-system \
	 -lglut \
	 -lGLU \
	 -lGLEW \
	 -lGL && \
popd || exit 1