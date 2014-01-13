#!/bin/bash

cdgray="\033[1;30m"
clgray="\033[0;37m"
cdblue="\033[0;34m"
clblue="\033[1;34m"
cdpurple="\033[1;35m"
clpurple="\033[0;35m"
clred="\033[1;31m"
cdred="\033[0;31m"
clgreen="\033[1;32m"
cdgreen="\033[0;32m"
cwhite="\033[1;37m"

function out() {
    echo -en "${1}\n"
    tput sgr0
}

function prompt() {
    echo -en "${1} "
    read input
}

function bye() {
    out "${clred}Bye..."
    echo "locked" > /home/dams/locked
    exit
}

out "${clgreen}Dams: ${cdgreen} Deadswitch Manager for Scribe Servers"
out "${cdgray}By Scribe Inc. <systems@scribenet.com>"

if [[ -f /home/dams/locked ]]; then
    bye
fi

prompt "Who are you?"
user="${input}"

is_user="0"
for path in /home/*; do
    [ -d "${path}" ] || continue # if not a directory, skip
    dirname="$(basename "${path}")"
    if [[ "${dirname}" == "${user}" ]]; then
      is_user="1"
    fi
done

if [[ "${is_user}" == "0" ]]; then
    bye
fi

if [[ "${user}" == "root" ]]; then
    bye
fi

secret="$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c128)"

echo -e "Dams \n Request from user ${user} \n Time $(date) \n Secret: ${secret}" | mail -s “Dams” systems@scribenet.com

prompt "What is the secret?"
secret_from_user="${input}"

if [[ ! "${secret}" == "${secret_from_user}" ]]; then
    bye
fi

su "${user}"

exit
