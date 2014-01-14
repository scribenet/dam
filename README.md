# DAM: Deadswitch Access-decision Manager

Dam is a bash login shell used to securly allow password login to an otherwise key-based-authentication only linux server.

## Overview

When used as a login shell for a pre-defined user (called, for example, `dam`) the script uses the following mechanisms to allow for secure password-based user logon - in the event of an administer not having access to a machine whose public key has been properly initialized for their account:

- Requires the entry of a valid user account on the system
- Send a random 128-length key to the general systems e-mail address
- Requires entry of the above generated key
- Requires the correct local-password for the requested account

In the event that any of the above steps fails, the account is automatically locked until a valid administrator can login using their regular key-based mechanisms and disable the lock - hence deadswitch.
