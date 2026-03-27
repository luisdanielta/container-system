# Secure SSH (Windows-Ubuntu)

This guide outlines the protocol for establishing a **Identity Tunnel** between a Windows workstation and an Ubuntu node. We are deprecating password-based authentication in favor of **Ed25519 Elliptic Curve** cryptography and automated connection multiplexing.

---

## 1. Identity Generation (Ed25519)

We avoid RSA due to its larger footprint and slower computational overhead. **Ed25519** provides better security with shorter keys and faster signature verification.

### Audit & Create
Check for existing keys in PowerShell: `ls $env:USERPROFILE\.ssh\`. If no `id_ed25519` exists, generate a new pair with high KDF (Key Derivation Function) rounds:

```powershell
ssh-keygen -t ed25519 -a 100 -C "workstation-id" -f $env:USERPROFILE\.ssh\id_ed25519
```

> **Why `-a 100`?** This increases the cost of brute-forcing the passphrase on the private key file, significantly slowing down offline attacks.

---

## 2. Remote Provisioning (The "One-Liner")

Since Windows lacks `ssh-copy-id`, we use a piped command to inject the public key and enforce strict POSIX permissions on the target.

**Target Node:** `192.168.1.250` | **Port:** `2022`

```powershell
Get-Content $env:USERPROFILE\.ssh\id_ed25519.pub | ssh <user>@192.168.1.250 -p 2022 "umask 077; test -d ~/.ssh || mkdir ~/.ssh; cat >> ~/.ssh/authorized_keys"
```

### Technical Validation:
* **`umask 077`**: Ensures any files created during this session are unreadable by other users from the start.
* **`cat >>`**: Appends the key to prevent overwriting existing infrastructure keys.
* **Idempotency**: The `test -d` check prevents errors if the directory already exists.

---

## 3. Server-Side Hardening

To finalize the security posture, password authentication must be disabled. This eliminates 99% of automated brute-force attempts.

1.  **Access the Node:** `ssh <user>@192.168.1.250 -p 2022`
2.  **Edit SSH Daemon Config:** `sudo nano /etc/ssh/sshd_config`
3.  **Apply Production Standards:**
    ```text
    PasswordAuthentication no
    PubkeyAuthentication yes
    PermitRootLogin no
    MaxAuthTries 3
    ```
4.  **Restart Service:** `sudo systemctl restart ssh`

---

## 4. Workstation Abstraction (`~/.ssh/config`)

To minimize cognitive load and eliminate the need to remember IPs or ports, implement a local configuration file. 

**File Path:** `$env:USERPROFILE\.ssh\config`

```text
Host remote-node
    HostName 192.168.1.250
    User <your-user>
    Port 2022
    IdentityFile ~/.ssh/id_ed25519
    # Persistence & Performance
    ServerAliveInterval 30
    ServerAliveCountMax 5
    ControlMaster auto
    ControlPath  ~/.ssh/sockets/%r@%h-%p
    ControlPersist 10m
    Compression yes
```

### Key Optimizations:
* **ControlPersist**: Keeps the master connection socket open for 10 minutes. Subsequent commands (SSH, SCP, RSYNC) will connect **instantly** without re-authenticating.
* **ServerAlive**: Prevents NAT/Firewall timeouts by sending a heartbeat every 30 seconds.
* **Compression**: Reduces latency on bandwidth-constrained networks.

---

## Usage

Once configured, the connection overhead is reduced to a single, memorable command:

```bash
ssh remote-node
```

**Security Note:** Always protect your private key (`id_ed25519`) and never commit it to version control. Only the `.pub` file is shareable.