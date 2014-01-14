# Deadswitch Access-decision Manager

Dam is a bash login shell used to securly allow password login to an otherwise key-based-authentication only linux server. It is intended to be used for the sole purpose of allowing rightful systems administrators access in an emergency situation where they do not have access to a machine whos public key was setup with their account, and thereforce must revert back to password-based login.

## Overview

When used as a login shell for a pre-defined recovery system user (called, for example, `dam`) the script uses the following mechanisms to allow password login to a server that otherwise allows only key-based authentication:

- Runs in a *restricted* bash enviornment
- *Requires* the entry of a valid user account on the system
- *Requires* that the above user is also granted to use DAM per the script config
- Sends a *randomly generated* secret-key (default of 128 bytes) to the email specified per the script config
- *Requires* that the user retreive the secret and provide it back to confirm access to the e-mail
- *Requires* the correct local-password is entered for the requested user account

**If any of the above *require* statements fail, the user is automatically kicked and DAM locked.** Hence, Deadswitch Access-decision Manager. To unlock DAM, an administrator must logon using key-based authentication and remove the lock file.

## Restricted Bash Enviornment

Running this script within a restricted bash enviornment provides the power of bash, with the exception that some actions or disalloed or not performed. 

Some of the more significant restrictions are outlined below. It is important to also note that the below restrictions are applied *after* any startup scripts run.

- Cannot change directories using `cd`
- Cannot set or unset the values of `SHELL`, `PATH`, `ENV`, or `BASH_ENV`
- Cannot specify command named containing `/`
- Cannot specify a file name containing a `/` as an argument to the builtin `.` - or "source" - command
- Cannot redirect output using the `>`, `>|`, `<>`, `>&`, `&>`, and `>>` redirection operators
- Cannot use the `exec` builtin command to replace the shell
- Cannot use `+r` to turn off restricted mode
- Cannot use `+o` to change exit behavious
