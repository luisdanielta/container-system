#!/bin/sh
# -----------------------------------------------------------------------------
# @file         setup_ssh.sh
# @description  Automated SSH Infrastructure Initializer (Multi-user Access Ver.)
#               Balances SSH security requirements with data accessibility.
# @version      1.1.0
# -----------------------------------------------------------------------------

set -eu

# Configuration Constants
readonly sshDir="/data/.ssh"
readonly configFile="$sshDir/config"
readonly UID_USER=1000
readonly GID_USER=1000

##
# @function     bootstrapFileSystem
# @description  Creates directories and applies 755 (Read/Execute for others)
#               allowing users to enter and list files.
##
bootstrapFileSystem() {
    local targetDirs="$sshDir $sshDir/github $sshDir/gitea"

    for dir in $targetDirs; do
        if [ ! -d "$dir" ]; then
            mkdir -p "$dir"
        fi
        # 755: Dueño (rwx), Grupo/Otros (r-x). Crucial para que puedan "entrar".
        chmod 755 "$dir"
    done

    # Aseguramos propiedad del proceso principal
    chown -R $UID_USER:$GID_USER "$sshDir"

    if [ ! -f "$configFile" ]; then
        touch "$configFile"
        # 644: Permite que otros usuarios lean la config de SSH
        chmod 644 "$configFile"
        chown $UID_USER:$GID_USER "$configFile"
    fi
}

##
# @function     registerSshInclude
# @description  Idempotently registers modular configuration files.
##
registerSshInclude() {
    local includePath="$1"
    local includeLine="Include $includePath"

    if ! grep -qxF "$includeLine" "$configFile" 2>/dev/null; then
        echo "$includeLine" >> "$configFile"
        printf "SSH_SYSTEM: Registered include for %s\n" "$includePath"
    fi
}

##
# @function     hardenKeyPermissions
# @description  The core logic: Protects private keys while keeping public
#               data accessible.
##
hardenKeyPermissions() {
    # 1. LLAVES PRIVADAS: Deben ser 600. Si son más abiertas, SSH fallará.
    # Buscamos archivos que empiecen con id_ y NO terminen en .pub
    find "$sshDir" -type f -name "id_*" ! -name "*.pub" -exec chmod 600 {} +

    # 2. LLAVES PÚBLICAS Y CONFIGS MODULARES: 644 (Lectura para todos)
    # Esto permite que tus usuarios copien la data sin problemas.
    find "$sshDir" -type f -name "*.pub" -exec chmod 644 {} +
    find "$sshDir" -type f -name "config" -exec chmod 644 {} +

    # Asegurar que el dueño sigue siendo el usuario 1000
    find "$sshDir" -exec chown $UID_USER:$GID_USER {} +
}

##
# @function     main
##
main() {
    printf "SSH_SYSTEM: Initializing infrastructure...\n"

    bootstrapFileSystem

    hardenKeyPermissions

    printf "SSH_SYSTEM: Infrastructure ready. Permissions balanced.\n"

    # Hand over to CMD
    if [ "$#" -gt 0 ]; then
        exec "$@"
    fi
}

main "$@"
