\# Task 2.4 – SSH Access and Command-Line Interaction



\## Objective



The objective of Task 2.4 was to demonstrate remote access to the deployed AWS EC2 instances from Windows using SSH and to perform command-line administration and testing.



The demonstration included:



\- Windows Command Prompt

\- SSH authentication using an EC2 key pair

\- Amazon Linux command-line access

\- Apache testing

\- WordPress testing

\- WordPress file inspection

\- Amazon S3 commands

\- backup restoration commands

\- RDS connectivity testing

\- troubleshooting using command-line tools



\---



\# Step 1 – Open Windows Command Prompt



I opened Windows Command Prompt on my local computer.



The SSH private key created for the deployment was stored securely on my local computer.



The key pair used was:



```text

SWE40006-WordPress-Key

```



The private `.pem` file is not included in this GitHub repository.



\---



\# Step 2 – Connect to the Original WordPress EC2 Instance



I connected from Windows to the original WordPress EC2 instance using SSH.



The command format was:



```cmd

ssh -i "SWE40006-WordPress-Key.pem" ec2-user@<EC2-PUBLIC-DNS-OR-IP>

```



The SSH username for Amazon Linux was:



```text

ec2-user

```



When connecting to an instance for the first time, SSH asked whether I trusted the remote host.



I entered:



```text

yes

```



The connection then opened an Amazon Linux terminal.



\---



\# Step 3 – Verify the Logged-In User



After connecting, I used:



```bash

whoami

```



The result was:



```text

ec2-user

```



This confirmed that I had successfully connected to the EC2 instance using SSH.



\---



\# Step 4 – Inspect WordPress Files



I inspected the WordPress installation directory:



```bash

ls -la /var/www/html

```



The directory contained the WordPress application files.



Examples included:



```text

index.php

wp-admin

wp-content

wp-includes

wp-config.php

```



This confirmed that WordPress was installed under the Apache document root.



\---



\# Step 5 – Check Apache



I checked the Apache web server using:



```bash

sudo systemctl status httpd

```



The service showed that Apache was running.



Apache could also be restarted when configuration changes were made:



```bash

sudo systemctl restart httpd

```



\---



\# Step 6 – Test WordPress from the Command Line



I tested the local web server using:



```bash

curl -I http://localhost

```



A successful result returned:



```text

HTTP/1.1 200 OK

```



This allowed me to verify the web application directly from the EC2 terminal without relying only on the browser.



\---



\# Step 7 – Check WordPress PHP Configuration



During troubleshooting, I checked the WordPress PHP configuration for syntax errors.



```bash

php -l /var/www/html/wp-config.php

```



A valid configuration returned:



```text

No syntax errors detected

```



\---



\# Step 8 – Check PHP MySQL Support



I verified that PHP had the required MySQL/MariaDB extension.



```bash

php -m | grep -i mysqli

```



The `mysqli` module was available.



This was necessary for WordPress to communicate with MariaDB/RDS.



\---



\# Step 9 – Check SELinux Database Permission



During RDS troubleshooting, I checked the SELinux setting:



```bash

getsebool httpd\_can\_network\_connect\_db

```



The setting initially prevented the required database network connection.



I enabled it permanently:



```bash

sudo setsebool -P httpd\_can\_network\_connect\_db 1

```



I checked it again:



```bash

getsebool httpd\_can\_network\_connect\_db

```



The final result was:



```text

httpd\_can\_network\_connect\_db --> on

```



\---



\# Step 10 – Connect to Amazon RDS from SSH



I tested the external RDS MariaDB database directly from the EC2 command line.



Because RDS required secure transport, I used SSL:



```bash

mariadb --ssl -h <RDS-ENDPOINT> -u admin -p

```



The database password was entered interactively.



It is not included in this repository.



The successful connection confirmed communication between:



```text

EC2

&#x20;|

&#x20;| SSL / TCP 3306

&#x20;v

Amazon RDS MariaDB

```



\---



\# Step 11 – Import the WordPress Database



The WordPress SQL backup was imported into the RDS database using a command in this format:



```bash

mariadb --ssl -h <RDS-ENDPOINT> -u admin -p wordpress < \~/wordpress-backup.sql

```



This migrated the existing WordPress database from the original EC2 deployment to Amazon RDS.



\---



\# Step 12 – Troubleshoot the HTTP 500 Error



After migrating WordPress to RDS, WordPress returned an HTTP 500 error.



Several command-line checks were performed.



Configuration syntax:



```bash

php -l /var/www/html/wp-config.php

```



PHP MySQL extension:



```bash

php -m | grep -i mysqli

```



SELinux:



```bash

getsebool httpd\_can\_network\_connect\_db

```



Direct PHP execution was then used to expose the actual fatal error.



The problem was an incorrect SSL constant.



Incorrect:



```text

MYSQL\_CLIENT\_SSL

```



Correct:



```text

MYSQLI\_CLIENT\_SSL

```



The WordPress configuration was corrected to:



```php

define( 'MYSQL\_CLIENT\_FLAGS', MYSQLI\_CLIENT\_SSL );

```



After correcting the configuration:



```bash

curl -I http://localhost

```



returned:



```text

HTTP/1.1 200 OK

```



\---



\# Step 13 – SSH into the S3 Restore EC2 Instance



Task 2.2 also required a new EC2 instance to demonstrate restoration from the S3 backup.



The restore instance was:



```text

SWE40006-WordPress-S3-Restore

```



From Windows Command Prompt, I connected using SSH:



```cmd

ssh -i "SWE40006-WordPress-Key.pem" ec2-user@<RESTORE-EC2-PUBLIC-IP>

```



The SSH connection successfully opened the Amazon Linux command line.



\---



\# Step 14 – List the S3 Backup



From the restore EC2 instance, I used AWS CLI to inspect the backup bucket:



```bash

aws s3 ls s3://swe40006-thivyasree-ec2-backup/

```



The output showed the WordPress backup files:



```text

wordpress-backup.sql

wordpress-files-backup.tar.gz

```



This demonstrated command-line access from EC2 to Amazon S3.



\---



\# Step 15 – Download the Backup from S3



I downloaded the WordPress application backup:



```bash

aws s3 cp s3://swe40006-thivyasree-ec2-backup/wordpress-files-backup.tar.gz .

```



AWS CLI copied the backup from S3 to the new EC2 instance.



\---



\# Step 16 – Restore the WordPress Files



I extracted the downloaded archive:



```bash

sudo tar -xzf wordpress-files-backup.tar.gz -C /

```



I then checked the restored files:



```bash

ls -la /var/www/html

```



The WordPress files were successfully restored.



\---



\# Step 17 – Test the Restored Website



I tested the restored web server:



```bash

curl -I http://localhost

```



During the first test, the website produced:



```text

HTTP/1.1 504 Gateway Timeout

```



This required further investigation.



\---



\# Step 18 – Test RDS Network Connectivity



I tested whether the restored EC2 instance could reach RDS on TCP port 3306.



The initial test indicated:



```text

RDS PORT BLOCKED

```



The problem was traced to the RDS security group.



The new restore EC2 instance used a different security group from the original WordPress EC2 instance.



\---



\# Step 19 – Fix RDS Security Group



I updated the RDS security group to permit the restore EC2 security group to connect on:



```text

TCP 3306

```



After changing the rule, the connectivity test returned:



```text

RDS PORT OPEN

```



This demonstrated command-line network troubleshooting.



\---



\# Step 20 – Verify Database Configuration Without Password



I checked the important WordPress database configuration without displaying the database password:



```bash

grep -E "DB\_NAME|DB\_USER|DB\_HOST" /var/www/html/wp-config.php

```



The result confirmed that the restored WordPress instance used:



```text

DB\_NAME = wordpress

DB\_USER = admin

DB\_HOST = Amazon RDS endpoint

```



\---



\# Step 21 – Combined Restore Verification



I also used command-line verification to show the restored server configuration and website status.



Commands included:



```bash

echo "=== RESTORED WORDPRESS INSTANCE ==="

hostname

grep -E "DB\_NAME|DB\_USER|DB\_HOST" /var/www/html/wp-config.php

echo "=== WEBSITE TEST ==="

curl -I http://localhost | head -n 1

```



The final website test returned:



```text

HTTP/1.1 200 OK

```



This demonstrated that the restored EC2 instance could:



```text

Load restored WordPress files

&#x20;       |

&#x20;       v

Connect to Amazon RDS

&#x20;       |

&#x20;       v

Run WordPress through Apache/PHP

&#x20;       |

&#x20;       v

Return HTTP 200

```



\---



\# Step 22 – Browser Verification



After the command-line test returned HTTP 200, I opened the public address of the restored EC2 instance in a browser.



The WordPress website loaded successfully.



This provided both:



```text

Command-line evidence

\+

Browser evidence

```



of the successful restoration.



\---



\# SSH Troubleshooting – Connection Timeout



During the deployment, an SSH connection attempt timed out.



\## Problem



The EC2 security group allowed SSH only from my previous public IP address.



My Internet connection later received a different public IP.



Therefore, the existing `/32` security group rule no longer matched my computer.



\## Solution



I opened:



```text

EC2

→ Security Groups

→ Inbound rules

→ Edit inbound rules

```



For SSH port 22, I changed the source to my current:



```text

My IP

```



I saved the security group rule and retried SSH.



The connection then succeeded.



This showed that SSH access depended on both:



```text

Correct SSH private key

\+

Correct Security Group source IP

```



\---



\# Command-Line Summary



Important commands demonstrated during the deployment included:



```bash

whoami

```



```bash

ls -la /var/www/html

```



```bash

sudo systemctl status httpd

```



```bash

sudo systemctl restart httpd

```



```bash

curl -I http://localhost

```



```bash

php -l /var/www/html/wp-config.php

```



```bash

php -m | grep -i mysqli

```



```bash

getsebool httpd\_can\_network\_connect\_db

```



```bash

sudo setsebool -P httpd\_can\_network\_connect\_db 1

```



```bash

mariadb --ssl -h <RDS-ENDPOINT> -u admin -p

```



```bash

aws s3 ls s3://swe40006-thivyasree-ec2-backup/

```



```bash

aws s3 cp s3://swe40006-thivyasree-ec2-backup/wordpress-files-backup.tar.gz .

```



```bash

sudo tar -xzf wordpress-files-backup.tar.gz -C /

```



```bash

grep -E "DB\_NAME|DB\_USER|DB\_HOST" /var/www/html/wp-config.php

```



\---



\# Task 2.4 Result



Task 2.4 was successfully completed.



I demonstrated:



\- SSH access from Windows

\- authentication using an EC2 `.pem` key

\- Amazon Linux command-line access

\- Linux user verification

\- Apache administration

\- WordPress file inspection

\- HTTP testing using `curl`

\- PHP configuration testing

\- SELinux configuration

\- RDS command-line access

\- SSL database connectivity

\- AWS CLI interaction with S3

\- S3 backup download

\- command-line restoration

\- network/database troubleshooting

\- SSH security group troubleshooting

\- successful restored WordPress verification



\---



\# Evidence to Include



Screenshots for this task should be stored in:



```text

screenshots/Task-2.4/

```



Important evidence includes:



1\. Windows Command Prompt showing the SSH command

2\. successful Amazon Linux SSH login

3\. `whoami` result

4\. Apache/WordPress command-line testing

5\. `curl -I http://localhost`

6\. AWS CLI `aws s3 ls`

7\. AWS CLI S3 download

8\. `tar` extraction

9\. `/var/www/html` listing

10\. RDS connectivity testing

11\. final HTTP 200 response

12\. restored WordPress browser result



\---



\# Security Note



The SSH private key is not included in this repository.



The following must never be committed:



```text

\*.pem

Database passwords

AWS access keys

AWS secret keys

WordPress administrator passwords

```



Screenshots containing passwords should be redacted or excluded.

