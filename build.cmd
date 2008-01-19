@echo off
ruby extconf.rb
nmake
del *.obj
del *.lib
del *.def
del *.exp
del *.pdb
rem del Makefile
