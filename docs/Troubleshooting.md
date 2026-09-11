\# Troubleshooting and Problem Investigation



\## Overview



During Deployment Portfolio Task 2, several technical problems occurred while configuring EC2, SSH, the Application Load Balancer, Amazon RDS, WordPress, Amazon S3 and the restored EC2 instance.



Instead of only rebuilding the environment, I investigated each problem using AWS configuration checks and Linux command-line tools.



This document records the main problems, causes, investigations and solutions.



\---



\# 1. SSH Connection Timed Out



\## Problem



I attempted to connect to the WordPress EC2 instance from Windows using SSH:



```cmd

ssh -i "SWE40006-WordPress-Key.pem" ec2-user@<EC2-PUBLIC-DNS-OR-IP>

```



The SSH connection timed out.



\## Investigation



I checked:



\- EC2 instance state

\- public IPv4 address

\- SSH key pair

\- Security Group inbound rules

\- source IP configured for TCP port 22



The SSH Security Group rule was restricted to a `/32` public IP address.



My Internet connection had received a different public IP address.



Therefore, the IP permitted by the Security Group was no longer my current IP.



\## Solution



I opened:



```text

EC2

→ Security Groups

→ Inbound rules

→ Edit inbound rules

```



For:



```text

SSH

TCP

Port 22

```



I changed the source to:



```text

My IP

```



and saved the rule.



\## Result



I retried SSH and successfully connected to Amazon Linux.



\## Lesson Learned



Restricting SSH to a specific IP is more secure than allowing `0.0.0.0/0`, but the rule must be updated when the client's public IP changes.



\---



\# 2. Application Load Balancer Target Appeared Unused



\## Problem



After creating the Application Load Balancer and registering the WordPress EC2 instance, the target did not initially operate as expected and appeared as unused.



\## Investigation



I checked:



```text

EC2 instance Availability Zone

ALB network mappings

Target Group

Health check

Security Groups

```



The original WordPress EC2 instance was in:



```text

ap-southeast-1c

```



The ALB initially did not have the required subnet enabled for that Availability Zone.



\## Cause



The load balancer was not enabled in the Availability Zone containing the WordPress target instance.



\## Solution



I edited the Application Load Balancer network mappings and added the subnet for:



```text

ap-southeast-1c

```



\## Result



The target became usable/healthy and WordPress successfully loaded through the ALB DNS address.



\## Lesson Learned



The ALB network mapping must include the Availability Zones containing the EC2 targets.



\---



\# 3. RDS Secure Transport Error 3159



\## Problem



After creating the Amazon RDS MariaDB instance, I attempted to connect from EC2.



The database returned an error similar to:



```text

ERROR 3159

Connections using insecure transport are prohibited

```



\## Investigation



This indicated that the RDS MariaDB configuration required secure transport.



\## Solution



I changed the MariaDB command to use SSL:



```bash

mariadb --ssl -h <RDS-ENDPOINT> -u admin -p

```



The password was entered interactively and is not recorded in this repository.



\## Result



The RDS connection succeeded.



I could then import the WordPress database using:



```bash

mariadb --ssl -h <RDS-ENDPOINT> -u admin -p wordpress < \~/wordpress-backup.sql

```



\## Lesson Learned



A network connection being permitted by the Security Group does not guarantee database login will succeed. Database-level security such as mandatory TLS/SSL must also be satisfied.



\---



\# 4. RDS Authentication Error



\## Problem



During later RDS testing, MariaDB returned an authentication error:



```text

ERROR 1045

Access denied

```



\## Investigation



I verified:



\- RDS endpoint

\- database username

\- port 3306

\- Security Group connectivity

\- password being used by the application



The problem was related to the RDS master password.



\## Solution



I reset the RDS master password through the AWS RDS console.



I then tested the new credentials directly from EC2 using the MariaDB client before updating WordPress.



After successful testing, the WordPress configuration was updated.



\## Result



RDS authentication succeeded.



\## Security Note



The actual database password is intentionally excluded from this repository.



\---



\# 5. WordPress Could Not Properly Access RDS Because of SELinux



\## Problem



WordPress still had problems communicating with the external database even though direct database connectivity was being tested.



\## Investigation



I checked the SELinux Boolean:



```bash

getsebool httpd\_can\_network\_connect\_db

```



The setting was disabled.



\## Cause



Apache/PHP needed permission under SELinux to establish a network connection to the external RDS database.



\## Solution



I enabled the required SELinux setting permanently:



```bash

sudo setsebool -P httpd\_can\_network\_connect\_db 1

```



I verified it:



```bash

getsebool httpd\_can\_network\_connect\_db

```



\## Result



The output showed:



```text

httpd\_can\_network\_connect\_db --> on

```



\## Lesson Learned



Linux security controls can block an application even when AWS Security Groups and database credentials are configured correctly.



\---



\# 6. WordPress Returned HTTP 500



\## Problem



After migrating WordPress from the local MariaDB database to Amazon RDS, the website returned:



```text

HTTP 500

```



\## Investigation



I first checked the WordPress PHP configuration:



```bash

php -l /var/www/html/wp-config.php

```



I also verified the MySQL PHP extension:



```bash

php -m | grep -i mysqli

```



The configuration did not show a normal PHP syntax error and `mysqli` was installed.



Apache logs and the expected WordPress debug output did not immediately reveal the actual problem.



I therefore tested the WordPress PHP execution directly from the command line.



This exposed a fatal PHP error involving an undefined SSL constant.



\## Root Cause



The WordPress configuration contained:



```text

MYSQL\_CLIENT\_SSL

```



The correct PHP `mysqli` constant was:



```text

MYSQLI\_CLIENT\_SSL

```



The missing letter `I` caused the fatal PHP error.



\## Solution



I corrected the configuration to:



```php

define( 'MYSQL\_CLIENT\_FLAGS', MYSQLI\_CLIENT\_SSL );

```



\## Verification



I tested WordPress again:



```bash

curl -I http://localhost

```



\## Result



The server returned:



```text

HTTP/1.1 200 OK

```



WordPress also loaded successfully in the browser.



\## Lesson Learned



When normal web-server logs do not clearly reveal a PHP application failure, direct command-line execution can help expose the actual fatal error.



\---



\# 7. Verifying WordPress Was Really Using RDS



\## Objective



After fixing WordPress, I wanted to confirm that the application was actually using Amazon RDS instead of silently continuing to use the local MariaDB database.



\## Test



The local MariaDB service on the original EC2 instance was stopped.



I then tested WordPress again.



\## Result



WordPress continued to return a successful response and remained accessible.



This provided evidence that WordPress was using:



```text

EC2 WordPress

&#x20;    |

&#x20;    v

Amazon RDS MariaDB

```



rather than the original local database.



\---



\# 8. Restored EC2 Returned HTTP 504



\## Problem



After downloading the WordPress backup from Amazon S3 and restoring it to the new EC2 instance, the website initially returned:



```text

HTTP/1.1 504 Gateway Timeout

```



\## Investigation



The WordPress files were present:



```bash

ls -la /var/www/html

```



Therefore, I investigated the backend database connection.



I tested access to the RDS database port.



The test showed:



```text

RDS PORT BLOCKED

```



\## Cause



The original EC2 instance and the new restore EC2 instance used different Security Groups.



The RDS Security Group permitted the original WordPress EC2 Security Group but did not yet permit the Security Group used by:



```text

SWE40006-WordPress-S3-Restore

```



\## Solution



I opened the RDS Security Group inbound rules and added:



```text

Type: MySQL/Aurora

Protocol: TCP

Port: 3306

Source: Restore EC2 Security Group

```



I did not make the RDS database publicly accessible.



\## Result



After updating the Security Group, the network test showed:



```text

RDS PORT OPEN

```



\---



\# 9. Final Restore Verification



After fixing RDS access, I verified the restored WordPress configuration without displaying the password:



```bash

grep -E "DB\_NAME|DB\_USER|DB\_HOST" /var/www/html/wp-config.php

```



I also used:



```bash

echo "=== RESTORED WORDPRESS INSTANCE ==="

hostname

grep -E "DB\_NAME|DB\_USER|DB\_HOST" /var/www/html/wp-config.php

echo "=== WEBSITE TEST ==="

curl -I http://localhost | head -n 1

```



The final result included:



```text

HTTP/1.1 200 OK

```



I then opened the restored EC2 public address in a browser.



The WordPress website loaded successfully.



\---



\# Troubleshooting Summary



| Problem | Investigation | Cause | Solution | Result |

|---|---|---|---|---|

| SSH timeout | Checked port 22 and source IP | Public IP changed | Updated SSH rule to current My IP | SSH connected |

| ALB target unused | Checked AZ and ALB mappings | EC2 AZ subnet missing from ALB | Added ap-southeast-1c subnet | Target healthy |

| RDS Error 3159 | Tested MariaDB connection | Secure transport required | Used `--ssl` | RDS connected |

| RDS Error 1045 | Tested credentials | RDS password mismatch | Reset and verified password | Authentication succeeded |

| WordPress/RDS connection | Checked SELinux | DB network Boolean disabled | Enabled `httpd\_can\_network\_connect\_db` | Network DB access allowed |

| HTTP 500 | PHP and CLI testing | Incorrect SSL constant | Changed to `MYSQLI\_CLIENT\_SSL` | HTTP 200 |

| Restore HTTP 504 | Tested RDS port | Restore SG not permitted | Added restore SG to RDS inbound rules | RDS port open |

| Restore verification | `curl`, `grep`, browser | Configuration corrected | Retested application | HTTP 200 |



\---



\# Overall Learning



The main lesson from the deployment was that cloud application problems can occur at several different layers:



```text

Application configuration

&#x20;       |

&#x20;       v

PHP / Apache

&#x20;       |

&#x20;       v

Linux / SELinux

&#x20;       |

&#x20;       v

EC2 Security Groups

&#x20;       |

&#x20;       v

Load Balancer / Target Group

&#x20;       |

&#x20;       v

RDS security and authentication

&#x20;       |

&#x20;       v

AWS networking

```



Testing each layer separately made it easier to identify the actual cause instead of changing multiple settings at the same time.



Command-line tools such as:



```bash

curl

php

mariadb

systemctl

getsebool

grep

aws s3

```



were useful for isolating problems and confirming that each fix worked.



\---



\# Security



No passwords, SSH private keys, AWS access keys or AWS secret keys are included in this troubleshooting documentation.



Screenshots containing visible credentials should not be uploaded to GitHub.

