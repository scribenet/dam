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

## Installation/Use

Choose a location to store the Dam repository - `/opt` is a good choice. Enter the directory, clone this repo, and enter it (you may need to set correct permissions to do this):

```
cd /opt
git clone git@github.com:scribenet/dam.git
cd dam
```

Copy the `allowed_accounts.dist` file as `allowed_accounts` and edit it to include a space-separated list of users you want to allow to perform functions using the Dam service:

```
cp allowed_accounts.dist allowed_accounts
nano allowed_accounts
```

Add the new login shell to the list of system-allowed login shells by editing `/etc/shells` and appending the full filepath to the `login` file within Dam. Assuming the dir/file placement above, the path would be `/opt/dam/login`.

Next, create the local user for people to access Dam with:

```
sudo adduser --shell /opt/dam/login dam
```

Assuming your have `PasswordAuthentication` set to `no` in your `/etc/ssh/sshd_config` file (as you should...otherwise this script is meaningless) you must add an exclusion entry for the `dam` user. Open `/etc/ssh/sshd_config` and append the following lines to the end of the file:

```
Match User dam
PasswordAuthentication yes
```

Lastly, be sure to open up and edit the configuration values within the `/opt/dam/login` file to suite your needs.

## Contact

Please contact systems@scribenet.com with any questions.

## Copying

This software is licensed under the MIT License included within this repository.
