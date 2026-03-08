#!/usr/bin/env bash
set -e

# Default USER_UID and USER_GID
USER_UID=${USER_UID:-1000}
USER_GID=${USER_GID:-1000}

if ! id "${USERNAME}" >/dev/null 2>&1; then
  if ! getent group "${USERNAME}" >/dev/null; then
    groupadd --gid "${USER_GID}" "${USERNAME}"
  fi

  useradd \
    --uid "${USER_UID}" \
    --gid "${USER_GID}" \
    --create-home \
    --shell /bin/bash \
    "${USERNAME}"

  echo "${USERNAME}:${PASSWORD}" | chpasswd
  echo "Password for user ${USERNAME} set to ${PASSWORD}"

  echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/${USERNAME}"
  chmod 0440 "/etc/sudoers.d/${USERNAME}"

  chown -R "${USER_UID}:${USER_GID}" "/home/${USERNAME}"
fi

BASHRC="/home/${USERNAME}"
if [ ! -f "$BASHRC/.bashrc" ]; then
    cp /etc/skel/.bashrc "$BASHRC/.bashrc"
fi

if ! grep -Fq "# >>> bash >>>" "$BASHRC/.bash_profile"; then
    cat << 'EOF' >> "$BASHRC/.bash_profile"
# >>> bash >>>
if [ -f ~/.bashrc ]; then
    source ~/.bashrc
fi
# <<< bash <<<
EOF
fi

. "$BASHRC/.bash_profile"

exit 0