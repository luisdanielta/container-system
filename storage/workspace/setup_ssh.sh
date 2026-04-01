#!/bin/sh
# -----------------------------------------------------------------------------
# @file         setup_ssh.sh
# @description  Automated SSH Infrastructure Initializer.
#               Ensures persistence, modular configuration, and strict 
#               security permissions for multi-provider SSH identities.
# @version      1.0.0
# -----------------------------------------------------------------------------

# -e: Exit immediately if a command exits with a non-zero status.
# -u: Treat unset variables as an error.
set -eu

# Configuration Constants
readonly sshDir="/data/.ssh"
readonly configFile="$sshDir/config"

##
# @function    bootstrapFileSystem
# @description Creates the required directory hierarchy and applies 
#              baseline security folders permissions (700).
##
bootstrapFileSystem() {
    # POSIX-compliant iteration over required subdirectories
    # Note: 'local' is supported by BusyBox Ash.
    local targetDirs="$sshDir $sshDir/github $sshDir/gitea"

    for dir in $targetDirs; do
        if [ ! -d "$dir" ]; then
            mkdir -p "$dir"
        fi
        chmod 700 "$dir"
    done

    # Ensure the master config file exists with restricted permissions (600)
    if [ ! -f "$configFile" ]; then
        touch "$configFile"
        chmod 600 "$configFile"
    fi
}

##
# @function    registerSshInclude
# @description Idempotently registers modular configuration files into 
#              the main SSH config using the 'Include' directive.
# @param       $1  The absolute path of the config file to include.
##
registerSshInclude() {
    local includePath="$1"
    local includeLine="Include $includePath"

    # Search for the exact line to avoid duplicate entries on restart
    if ! grep -qxF "$includeLine" "$configFile" 2>/dev/null; then
        echo "$includeLine" >> "$configFile"
        printf "SSH_SYSTEM: Registered include for %s\n" "$includePath"
    fi
}

##
# @function    hardenKeyPermissions
# @description Recursively finds and restricts permissions for any file 
#              prefixed with 'id_' to 600 (Owner Read/Write only).
##
hardenKeyPermissions() {
    # Using 'find' handles empty directories gracefully in Ash
    find "$sshDir" -type f -name "id_*" -exec chmod 600 {} +
}

##
# @function    main
# @description Main orchestrator. Initializes the system and hands over 
#              control to the container's primary process (CMD).
##
main() {
    bootstrapFileSystem
    
    # Register modular identity configs
    registerSshInclude "$sshDir/github/config"
    registerSshInclude "$sshDir/gitea/config"
    
    hardenKeyPermissions

    # Transition to the command passed via Docker CMD (e.g., /bin/sh)
    if [ "$#" -gt 0 ]; then
        exec "$@"
    fi
}

# Execute main with all passed arguments
main "$@"