#!/bin/bash -r
##
## DAM: Deadlock Access-Decision Manager
## Scribe Inc. <systems@scribenet.com>
##

#
# bash color codes
#
color_blue="\033[1;34m"
color_purple="\033[0;35m"
color_red="\033[1;31m"
color_green="\033[1;32m"
color_white="\033[1;37m"

#
# user remote IP (if available)
#
user_remote_ip="$(echo $SSH_CLIENT | awk '{ print $1}')"

#
# allowed accounts filepath
#
allowed_account_filepath="/opt/dam/allowed_accounts"

#
# allowed accounts
#
allowed_accounts="$(cat ${allowed_account_filepath})"

#
# lock filepath
#
lock_filepath="/home/dam/file.lock"

#
# length of secret to generate
#
secret_char_length=128

#
# e-mail address to send secret to
#
secret_email_verify="dam@scribenet.com"

#
# simple echo function
#
function out()
{
    #
    # output first parameter with backslash character support
    #
    echo -en "${1}\n"

    #
    # reset any previously set bash color codes
    #
    tput sgr0
}

#
# simple prompt function with color reset
#
function prompt()
{
    #
    # output first parameter with backslash character support
    #
    echo -en "${1}"

    #
    # reset any previously set bash color codes
    #
    tput sgr0

    #
    # read user input
    #
    read prompt_input
}

#
# account locking function
#
function lock_set()
{
    #
    # inform the user the account has been locked
    #
    out
    out "${color_red}Account locked...Bye."
    out

    #
    # set lock file
    #
    touch "${lock_filepath}"

    #
    # email about lock
    #
    echo -e "<html><body>" \
        "<h1>DAM: Decision Access-control Manager</h1>" \
        "<h2>Rejection/Lockout</h2>" \
        "<p>An attempt through DAM has been <b>rejected</b> with the following details:</p>" \
        "<ul><li>Remote IP: ${user_remote_ip}</li>" \
        "<li>Username: ${user}</li>" \
        "<li>Datetime: $(date)</li></ul>" \
        "<p>If this was a malicious attempt to gain account access, take appropriate action.</p>" \
        "</body></html>" | mail.mailutils \
        --append="Content-type: text/html" \
        -s "[Rejection] DAM: Deadswitch Access-decision Manager" \
        "${secret_email_verify}"

    #
    # exit script
    #
    exit
}

#
# account lock check
#
function lock_check()
{
    #
    # check if lock file exists
    #
    if [[ -f "${lock_filepath}" ]]; then
        #
        # log attempt and exit
        #
        lock_set
    fi
}

#
# output informative title text
#
out
out "${color_blue}DAM: Deadswitch Access-decision Manager"
out "${color_blue}By Scribe Inc. <systems@scribenet.com>"
out

#
# check log file
#
lock_check

#
# prompt for a valid (and enabled) account
#
prompt "Enter a valid (and enabled) system username: "
user="${prompt_input}"

#
# default validity of false for user check
#
check_valid_user=0

#
# for each user under /home...
#
for path in /home/*; do
    #
    # skip if not a directory
    #
    [ -d "${path}" ] || continue

    #
    # get the path basename
    #
    basename="$(basename ${path})"

    #
    # check if basename matches supplied username
    #
    if [[ "${basename}" == "${user}" ]]; then
        #
        # for each user specified as valid
        #
        for valid_user in $allowed_accounts; do
            #
            # check if an allowed account matches passed username
            #
            if [[ "${valid_user}" == "${user}" ]]; then
                #
                # passed first round of checks, mark passed
                #
                check_valid_user=1
            fi
        done
    fi
done

#
# did the first test pass?
#
if [[ $check_valid_user -eq 0 ]]; then
    #
    # bail out if check was not passed
    #
    lock_set
fi

#
# generate a secret for next check
#
secret="$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${secret_char_length})"

#
# send e-mail with secret
#
echo -e "<html><body>" \
    "<h1>DAM: Decision Access-control Manager</h1>" \
    "<h2>E-Mail Verification</h2>" \
    "<p>An accept attempt through DAM has been <b>initiated</b> with the following details:</p>" \
    "<ul><li>Remote IP: ${user_remote_ip}</li>" \
    "<li>Username: ${user}</li>" \
    "<li>Datetime: $(date)</li>" \
    "<li>Secret: ${secret}</li></ul>" \
    "<p>To complete the process, enter the secret key provided above." \
    "If this was a malicious attempt to gain account access, take appropriate action.</p>" \
    "</body></html>" | mail.mailutils \
    --append="Content-type: text/html" \
    -s "[Verification] DAM: Deadswitch Access-decision Manager" \
    "${secret_email_verify}"

#
# confirm the user has physical access to an authenticated e-mail account
#
prompt "Enter the generated secret key: "
secret_from_user="${prompt_input}"

#
# check if the secret matches the string provided by the user
#
if [[ ! "${secret}" == "${secret_from_user}" ]]; then
    #
    # it doesn't match, exit
    #
    lock_set
fi

#
# granting access to password-level account login
#
echo -e "<html><body>" \
    "<h1>DAM: Decision Access-control Manager</h1>" \
    "<h2>Access Granted</h2>" \
    "<p>An attempt through DAM has been <b>granted</b> with the following details:</p>" \
    "<ul><li>Remote IP: ${user_remote_ip}</li>" \
    "<li>Username: ${user}</li>" \
    "<li>Datetime: $(date)</li></ul>" \
    "<p>If this was a malicious attempt to gain account access, take appropriate action.</p>" \
    "</body></html>" | mail.mailutils \
    --append="Content-type: text/html" \
    -s "[Granted] DAM: Deadswitch Access-decision Manager" \
    "${secret_email_verify}"

#
# the user can now access the requested account with a valid account password
#
echo "Enter the valid account password: "
su "${user}"

#
# grab su's return code
#
su_exit="$?"

#
# check if su completed successfully (non-zero exit means bad password)
#
if [[ "${su_exit}" == "1" ]]; then
    #
    # lock the account
    #
    lock_set
fi

#
# all done
#
out
out "${color_green}Bye!"
out

#
# exit script
#
exit

#
# EOF
#
