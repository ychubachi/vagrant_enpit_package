#!/bin/bash

# github-connect.sh
# -----------------
# Copyright 2012 Andrew Coulton - released under the BSD licence
#
# A simple command line script to set up and register an SSH key against a
# user's github account - for example when provisioning a new virtual
# machine for a developer.
#
# Parameters:
#   --user=<user>        Github username (prompts if not provided)
#   --passwd=<passwd>    Github password (prompts if not provided)
#   --keyfile=<file>     Path to SSH public key file (defaults to ~/.ssh/id_rsa.pub)
#   --keyname=<name>     Name to use for the key on GH (defaults to $(hostname)
#   --git-email=<email>  Committer email address (for git global config)
#   --git-author=<name>  Committer name (for git global config)

USER=""
PASSWD=""
KEYFILE=~/.ssh/id_rsa
KEYNAME="$(hostname)-$(whoami)-$(date --rfc-3339=seconds)"
GIT_EMAIL=""
GIT_AUTHOR=""

# ----------------------------
# Parse command line arguments
# ----------------------------

for i in $*
do
	case $i in
	--user=*)
		USER=${i#*=}
		;;
	--passwd=*)
		PASSWD=${i#*=}
		;;
	--keyfile=*)
		KEYFILE=${i#*=}
		;;
	--keyname=*)
		KEYNAME=${i#*=}
		;;
	--git-email=*)
		GIT_EMAIL=${i#*=}
		;;
	--git-author=*)
		GIT_AUTHOR=${i#*=}
		;;
	esac
done

# --------------------------------------------
# Prompt for user and password if not provided
# --------------------------------------------
if [ -z "$USER" ]
	then
		read -p "Enter your github username: " USER
fi
if [ -z "$PASSWD" ]
	then
		read -s -p "Enter your github password: " PASSWD
fi

# ----------------------------------------------
# Try to get git committer email from git config
# ----------------------------------------------
GIT_EMAIL_SET=""
GIT_AUTHOR_SET=""

if [ -z "$GIT_EMAIL" ]
	then
		GIT_EMAIL=$(git config --get --global user.email)
		if [ ! -z "$GIT_EMAIL" ]
			then
				GIT_EMAIL_SET=1
		fi
fi
if [ -z "$GIT_AUTHOR" ]
	then
		GIT_AUTHOR=$(git config --get --global user.name)
		if [ ! -z "$GIT_AUTHOR" ]
			then
				GIT_AUTHOR_SET=1
		fi
fi

# ----------------------------------------------------------------
# If not in git config, try to get email and real name from github
# ----------------------------------------------------------------
if [ -z "$GIT_AUTHOR" ]
	then
		GIT_AUTHOR=$(curl --user $USER:$PASSWD --silent --show-error https://api.github.com/user | python -c 'import json,sys;obj=json.loads(sys.stdin.read());print obj["'"name"'"]')
fi

if [ -z "$GIT_EMAIL" ]
	then
		GIT_EMAIL=$(curl --user $USER:$PASSWD --silent --show-error https://api.github.com/user/emails | python -c 'import json,sys;obj=json.loads(sys.stdin.read());print obj[0]')
fi


# -------------------------------------------------------------
# Prompt to confirm git details if required, and set git config
# -------------------------------------------------------------
if [ -z "$GIT_EMAIL_SET" ]
	then
		read -p "Set git committer email {$GIT_EMAIL}: " GIT_EMAIL_ANS
		if [ ! -z "$GIT_EMAIL_ANS" ]
			then
				GIT_EMAIL = GIT_EMAIL_ANS
		fi
		git config --global user.email "$GIT_EMAIL"
	else
		echo "git committer email is set to $GIT_EMAIL"
fi

if [ -z "$GIT_AUTHOR_SET" ]
	then
		read -p "Set git committer name {$GIT_AUTHOR}: " GIT_AUTHOR_ANS
		if [ ! -z "$GIT_AUTHOR_ANS" ]
			then
				GIT_AUTHOR = GIT_AUTHOR_ANS
		fi
		git config --global user.name "$GIT_AUTHOR"
	else
		echo "git committer name is set to $GIT_AUTHOR"
fi

# ----------------------------------
# Generate an SSH key if none exists
# ----------------------------------

if [ ! -e "$KEYFILE" ]
	then
		ssh-keygen -t rsa -C "$GIT_EMAIL" -f "$KEYFILE"
	else
		echo "You already have an SSH key in $KEYFILE - we will set this as your github key"
fi

# ---------------------------------
# Load the SSH public key to memory
# ---------------------------------

ssh_key=$(<$KEYFILE".pub")


# -------------------------------------------------
# Check if this key is already authorised on github
# -------------------------------------------------

gh_response=$(curl --user $USER:$PASSWD --silent --show-error https://api.github.com/user/keys)

# the email doesn't appear in the keys returned from github
search_key=${ssh_key% *}
case $gh_response in
	*$search_key*)
		echo -e $(tput setaf 3)
		echo "Your SSH key is already authorised for your github account"
		echo -e $(tput setaf 7)
		exit 0;
esac

# ----------------------------
# Authorise this key on github
# ----------------------------

post_data='{"title":"'$KEYNAME'","key":"'$ssh_key'"}'
gh_response=$(curl --user $USER:$PASSWD --write-out "\nGithub response code %{http_code} \n" --data "$post_data" --header "Content-Type: application/json" --silent --show-error https://api.github.com/user/keys)

# --------------------------
# Verify the response status
# --------------------------
case $gh_response in
	*"response code 201"*)
		echo -e $(tput setaf 2)
		echo "Your SSH key was authorised for your github account"
		echo -e $(tput setaf 7)
		exit 0
esac

echo -e $(tput setaf 1)
echo "********************************************"
echo "There was an error authorising your SSH key:"
echo "********************************************"
echo $gh_response
echo -e $(tput setaf 7)
exit 1
