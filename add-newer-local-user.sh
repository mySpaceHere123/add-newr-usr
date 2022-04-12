#!/bin/bash


# Make sure the script is being executed with superuser privileges.
if [[ "${UID}" -ne 0 ]]
then
    echo 'Please run with sudo or as root' >&2
    exit 1
fi


# If the user doesn't supply at least one argument, then give them help.
if [[ "${#}" -lt 2 ]]
then 
    echo 'Please provide sufficient parameters.' >&2
    exit 1
fi

# The first parameter is the user name.
USER_NAME=${1}
# echo "${USER_NAME}"

# The rest of the parameters are for the account comments.
shift
COMMENT="${@}"

# Generate a password.
PASSWORD=$(date +%s%N | sha256sum | head -c32)

# Create the user with the password.
useradd -c "${COMMENT}" -m ${USER_NAME} &> /dev/null

# Check to see if the useradd command succeeded.
if [[ "${?}" -ne 0 ]]
then
    echo 'The account could not be created.' >&2
    exit 1
fi

# Set the password.
echo ${PASSWORD} | passwd --stdin ${USER_NAME} &> /dev/null

# Check to see if the passwd command succeeded.
if [[ "${?}" -ne 0 ]]
then
    echo 'The password could not be set.' >&2
    exit 1
fi

# Force password change on first login.
passwd -e ${USER_NAME} &> /dev/null

if [[ "${?}" -ne 0 ]]
then
    echo 'The password could not be set.' >&2
    exit 1
fi

# Display the username, password, and the host where the user was created
echo
echo "username:"
echo "${USER_NAME}"
echo
echo "password:"
echo "${PASSWORD}"
echo
echo "host:"
echo "${HOSTNAME}"
exit 0