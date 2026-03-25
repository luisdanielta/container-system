## windows
winget install smallstep.step

step ca bootstrap --ca-url https://10.10.3.198:9000 --fingerprint <fingerprint>

step.exe ssh certificate <user>@<host> id_ecdsa

Get-Service ssh-agent | Set-Service -StartupType Automatic

Start-Service ssh-agent

ssh-add .\id_ecdsa

ForwardAgent yes