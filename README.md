\# SWE40006 Software Deployment and Evolution

\## Deployment Portfolio – Task 2



\*\*Student:\*\* Thivyasree A/P Sunder  

\*\*Unit:\*\* SWE40006 – Software Deployment and Evolution  

\*\*Assessment:\*\* Deployment Portfolio – Task 2  

\*\*Target Level:\*\* High Distinction – Task 2.4  

\*\*AWS Region:\*\* Asia Pacific (Singapore) – ap-southeast-1



\---



\## Project Overview



This repository contains the implementation and evidence for Deployment Portfolio Task 2.



The deployment was completed progressively from Task 2.1 to Task 2.4 using Amazon Web Services (AWS).



The completed deployment includes:



\- Amazon EC2

\- SSH key pair

\- Apache and PHP

\- WordPress

\- Application Load Balancer (ALB)

\- Target Group

\- Amazon RDS MariaDB

\- Amazon S3 backup

\- WordPress restoration to a new EC2 instance

\- Launch Template

\- Auto Scaling Group

\- Scaling testing

\- Windows SSH access

\- Linux/AWS command-line interaction

\- Troubleshooting and testing



\---



\# Task 2.1 – EC2 and WordPress Deployment



Task 2.1 involved creating the initial AWS infrastructure and deploying WordPress.



Main activities:



1\. Accessed the AWS environment.

2\. Selected the Asia Pacific (Singapore) region.

3\. Created an SSH key pair.

4\. Created an Amazon Linux EC2 instance.

5\. Configured the EC2 security group.

6\. Allowed HTTP port 80.

7\. Allowed SSH port 22 from my IP address.

8\. Connected to the EC2 instance using SSH.

9\. Installed Apache.

10\. Installed PHP.

11\. Installed MariaDB.

12\. Deployed WordPress.

13\. Configured the WordPress database.

14\. Tested WordPress from a web browser.



Initial EC2 instance:



`SWE40006-WordPress`



WordPress document root:



```bash

/var/www/html

```



Example website test:



```bash

curl -I http://localhost

```



A successful deployment returned:



```text

HTTP/1.1 200 OK

```



Detailed documentation and screenshots are stored under:



```text

docs/Task-2.1-WordPress-EC2.md

screenshots/Task-2.1/

```



\---



\# Task 2.2 – Load Balancer, RDS and S3 Backup



Task 2.2 extended the WordPress deployment by adding load balancing, an external database and backup/recovery.



\## Application Load Balancer



An internet-facing Application Load Balancer was created:



`SWE40006-WordPress-ALB`



A target group was created:



`SWE40006-WordPress-TG`



The WordPress EC2 instance was registered with the target group and the health check was verified.



\## Amazon RDS



An external Amazon RDS MariaDB database was created:



`SWE40006-WordPress-RDS`



The existing WordPress database was backed up and migrated from the EC2 instance to Amazon RDS.



WordPress `wp-config.php` was then configured to use the external RDS database.



The local MariaDB service was stopped during testing to verify that WordPress was actually using RDS.



\## Amazon S3 Backup



An S3 bucket was created for WordPress backup:



`SWE40006-WordPress-EC2-Backup`



The backup contained:



```text

wordpress-backup.sql

wordpress-files-backup.tar.gz

```



AWS CLI was used to verify the backup:



```bash

aws s3 ls s3://swe40006-thivyasree-ec2-backup/

```



\## S3 Restore



A new EC2 instance was created:



`SWE40006-WordPress-S3-Restore`



The WordPress files were downloaded from S3 and restored.



Example commands used:



```bash

aws s3 cp s3://swe40006-thivyasree-ec2-backup/wordpress-files-backup.tar.gz .



sudo tar -xzf wordpress-files-backup.tar.gz -C /



ls -la /var/www/html

```



The restored website was tested using:



```bash

curl -I http://localhost

```



Final result:



```text

HTTP/1.1 200 OK

```



Detailed documentation and evidence are stored under:



```text

docs/Task-2.2-ELB-RDS-S3.md

screenshots/Task-2.2/

```



\---



\# Task 2.3 – Launch Template and Auto Scaling



Task 2.3 implemented automatic EC2 instance management.



A Launch Template was created:



`SWE40006-WordPress-LT`



An Auto Scaling Group was created:



`SWE40006-WordPress-ASG`



The Auto Scaling Group was connected to the WordPress target group.



Capacity was configured with:



```text

Minimum capacity: 1

Desired capacity: 1

Maximum capacity: 3

```



\## Scaling Test



Manual scaling was performed to demonstrate that the Auto Scaling Group could create and terminate EC2 instances.



The desired capacity was changed:



```text

1 -> 2

```



A second EC2 instance was automatically launched.



The desired capacity was then changed:



```text

2 -> 1

```



The additional instance was automatically terminated.



The Auto Scaling Activity history was used as evidence of successful scaling.



Detailed documentation and screenshots are stored under:



```text

docs/Task-2.3-Auto-Scaling.md

screenshots/Task-2.3/

```



\---



\# Task 2.4 – SSH and Command-Line Interaction



Task 2.4 demonstrates remote administration of AWS EC2 from Windows using SSH.



Example SSH connection:



```cmd

ssh -i "SWE40006-WordPress-Key.pem" ec2-user@<EC2-PUBLIC-IP>

```



After connecting to Amazon Linux, command-line operations were performed to:



\- inspect WordPress files

\- check Apache

\- test WordPress

\- access Amazon S3

\- download backup files

\- extract backup files

\- test RDS connectivity

\- troubleshoot deployment problems



Examples:



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

curl -I http://localhost

```



```bash

aws s3 ls s3://swe40006-thivyasree-ec2-backup/

```



Detailed SSH evidence is stored under:



```text

docs/Task-2.4-SSH.md

screenshots/Task-2.4/

```



\---



\# Troubleshooting



Several deployment problems were investigated during this task.



These included:



\### SSH Connection Timeout



The SSH connection timed out because my public IP address had changed.



The EC2 security group SSH inbound rule was updated to allow my current IP address.



\### Load Balancer Target Not Used



The target initially appeared as unused because the Availability Zone containing the WordPress EC2 instance was not enabled on the Application Load Balancer.



The required subnet was added to the ALB.



\### RDS Secure Transport Error



MariaDB rejected a connection because secure transport was required.



SSL was enabled when connecting to RDS.



\### WordPress HTTP 500 Error



A PHP fatal error was discovered in `wp-config.php`.



The SSL constant was corrected to:



```php

MYSQLI\_CLIENT\_SSL

```



After correcting the configuration, WordPress returned:



```text

HTTP/1.1 200 OK

```



\### SELinux Database Connectivity



Apache initially could not communicate correctly with the external database.



The required SELinux setting was enabled:



```bash

sudo setsebool -P httpd\_can\_network\_connect\_db 1

```



It was verified using:



```bash

getsebool httpd\_can\_network\_connect\_db

```



\### Restored Instance – RDS Connection Problem



The restored WordPress instance initially could not connect to RDS.



Testing showed that RDS port 3306 was blocked for the new EC2 instance.



The RDS security group was updated to allow the security group of the restored EC2 instance.



After the change, RDS connectivity succeeded and WordPress returned:



```text

HTTP/1.1 200 OK

```



Full troubleshooting documentation is available in:



```text

docs/Troubleshooting.md

```



\---



\# Repository Structure



```text

SWE40006-Deployment-Portfolio-Task2/

|

|-- README.md

|

|-- docs/

|   |-- Task-2.1-WordPress-EC2.md

|   |-- Task-2.2-ELB-RDS-S3.md

|   |-- Task-2.3-Auto-Scaling.md

|   |-- Task-2.4-SSH.md

|   `-- Troubleshooting.md

|

|-- screenshots/

|   |-- Task-2.1/

|   |-- Task-2.2/

|   |-- Task-2.3/

|   `-- Task-2.4/

|

|-- scripts/

|   |-- backup-wordpress.sh

|   `-- restore-wordpress.sh

|

`-- report/

&#x20;   `-- Deployment-Portfolio-Task2.pdf

```



\---



\# Security



Sensitive AWS credentials are not stored in this repository.



The following must never be committed:



\- `.pem` SSH private keys

\- AWS access keys

\- AWS secret access keys

\- database passwords

\- `.env` files containing credentials

\- WordPress passwords



Passwords and private credentials shown during testing should be removed or redacted from screenshots before submission.



\---



\# Final Deployment Result



The deployment successfully demonstrated the progression from a single WordPress EC2 deployment to an AWS architecture using:



\*\*EC2 + WordPress + ALB + RDS + S3 + Launch Template + Auto Scaling + SSH\*\*



The final deployment also included backup and restoration testing, scaling testing, command-line administration and troubleshooting.

