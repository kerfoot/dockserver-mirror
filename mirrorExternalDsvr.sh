#! /bin/bash --
#
# Mirrors remove dockserver directories to a local destination using
# passwordless ssh, which must be set up by the user.
#
# ============================================================================
# $RCSfile$
# $Source$
# $Revision$
# $Date$
# $Author$
# $Name$
# ============================================================================
#

PATH=${PATH}:/bin;

app=$(basename $0);

# Usage message
USAGE="
NAME
    $app - mirror remote dockserver directories via passwordless ssh 

SYNOPSIS
    $app [hx]

DESCRIPTION
    -h
        show help message

    -x
        Dry run.  Shows which files are to be mirrored, but does NOT actually
        mirror them
";

# Default values for options

# Process options
while getopts "hx" option
do
    case "$option" in
        "h")
            echo -e "$USAGE";
            exit 0;
            ;;
        "x")
            DRY_RUN=1;
            ;;
        "*")
            echo -e "Invalid option specified: $option\n$USAGE";
            exit 1;
            ;;
    esac
done

# Remove option from $@
shift $((OPTIND-1));

# CONFIGURATION ==============================================================
REMOTE_URL='remote.server.com'; # CHANGE THIS
REMOTE_ROOT='/var/opt/gmc/gliders'; # MAY NEED TO CHANGE THIS
USER='YOUR_USER_NAME'; # CHANGE THIS
SSH_KEY='LOCATION_OF_LOCAL_SSH_KEY'; # CHANGE THIS
RULES='LOCATION_OF_RULES_FILE'; # CHANGE THIS
LOCAL_DEST_ROOT='LOCAL_DESTINATION'; # CHANGE THIS
GLIDERS='GLIDER_NAME'; # CHANGE THIS. SEPARATE MULTIPLE GLIDERS WITH WHITESPACE
REMOTE_DIRS='from-glider logs to-glider';
# ============================================================================

# Validate configuration variables
if [ -z "$LOCAL_DEST_ROOT" -o ! -f "$LOCAL_DEST_ROOT" ]
then
    echo "LOCAL_DEST_ROOT is not valid!" >&2;
    exit 1;
elif [ -z "$REMOTE_URL" ]
then
    echo "REMOTE_URL is not set!" >&2;
    exit 1;
elif [ -z "$REMOTE_ROOT" ]
then
    echo "REMOTE_ROOT is not set!" >&2;
    exit 1;
elif [ -z "$SSH_KEY" -o ! -f "$SSH_KEY" ]
then
    echo "SSH_KEY is not a valid ssh key!" >&2;
    exit 1;
elif [ -z "$USER" ]
then
    echo "USER is not set!" >&2;
    exit 1;
elif [ -z "$GLIDERS" ]
then
    echo "GLIDERS is not set!" >&2;
    exit 1;
elif [ -z "$REMOTE_DIRS" ]
then
    echo "REMOTE_DIRS is not set!" >&2;
    exit 1;
fi

for GLIDER in $GLIDERS
do

    echo "Mirroring Glider: $GLIDER";

	for d in $REMOTE_DIRS
	do
	    if [ -n "$DRY_RUN" ]
	    then
			rsync -avz \
			    --rsh="ssh -i $SSH_KEY" \
			    --exclude-from=$RULES \
	            --dry-run \
			    ${USER}@${REMOTE_URL}:${REMOTE_ROOT}/${GLIDER}/${d} \
			    ${LOCAL_DEST_ROOT}/${GLIDER}
	    else
			rsync -avz \
			    --rsh="ssh -i $SSH_KEY" \
			    --exclude-from=$RULES \
			    ${USER}@${REMOTE_URL}:${REMOTE_ROOT}/${GLIDER}/${d} \
			    ${LOCAL_DEST_ROOT}/${GLIDER}
	    fi
	done
done

