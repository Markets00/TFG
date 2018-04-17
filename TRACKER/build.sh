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


# mkdir -p build && \
# pushd build && \
# clang++ \
# 	-o main \
# 	../src/imgui.cpp \
# 	../src/imgui_draw.cpp \
# 	../src/imgui_demo.cpp \
# 	../src/imgui-SFML.cpp \
# 	../src/main.cpp \
# 	-Wall \
# 	-g 						`# Generate complete debug info` \
# 	-std=c++11 \
# 	-I ../include \
# 	-I ../imgui \
# 	-I/home/markets/git/SFML/include
# 	-l GLU \
# 	-l X11 \
# 	-l Xxf86vm \
# 	-l Xrandr \
# 	-l pthread \
# 	-l Xi \
# 	-l Xinerama \
#   	-l Xcursor && \
# popd || exit 1