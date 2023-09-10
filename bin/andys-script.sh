#!/bin/bash

my_file="${HOME}/.config/term_counter"

if [[ ! -e $my_file ]]; then
	echo "0" > "$my_file"
fi

number_of_profiles=4
term_counter=$(cat "${my_file}")
gnome-terminal --window-with-profile=RedPanda"${term_counter}"
term_counter="(term_counter + 1) % ${number_of_profiles}"
echo "$term_counter" > "$my_file"
