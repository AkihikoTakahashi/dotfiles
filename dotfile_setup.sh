#!/bin/bash

cur_dir=$(cd $(dirname $0); pwd)

echo setup .condarc
ln -sf ${cur_dir}/.condarc ~/

echo setup .latexmkrc
ln -sf ${cur_dir}/.latexmkrc ~/

echo setup .yatex-template
ln -sf ${cur_dir}/.yatex-template ~/

echo setup .yatexrc
ln -sf ${cur_dir}/.yatexrc ~/

echo setup .emacs.d
ln -sf ${cur_dir}/.emacs.d ~/
