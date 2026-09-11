\# Task 2.2 – Application Load Balancer, RDS and S3 Backup/Restore



\## Objective



Task 2.2 extended the Task 2.1 WordPress deployment by implementing:



\- Application Load Balancer (ALB)

\- Target Group

\- External Amazon RDS MariaDB database

\- Migration of the existing WordPress database to RDS

\- Amazon S3 backup

\- Restoration of WordPress to a new EC2 instance



\---



\# Part A – Application Load Balancer



\## Step 1 – Create Target Group



I opened:



```text

EC2

→ Load Balancing

→ Target Groups

→ Create target group

```



The target group was configured as:



```text

Name: SWE40006-WordPress-TG

Target type: Instances

Protocol: HTTP

Port: 80

```



The WordPress EC2 instance was registered as a target.



\---



\## Step 2 – Create ALB Security Group



A security group was created for the Application Load Balancer.



```text

Name: SWE40006-ALB-SG

```



HTTP traffic was allowed:



```text

Type: HTTP

Protocol: TCP

Port: 80

Source: 0.0.0.0/0

```



This allows Internet users to access WordPress through the load balancer.



\---



\## Step 3 – Create Application Load Balancer



I opened:



```text

EC2

→ Load Balancing

→ Load Balancers

→ Create load balancer

→ Application Load Balancer

```



The load balancer was configured as:



```text

Name: SWE40006-WordPress-ALB

Scheme: Internet-facing

IP address type: IPv4

```



The ALB was configured across multiple Availability Zones in the Singapore region.



The listener was configured as:



```text

HTTP : 80

→ SWE40006-WordPress-TG

```



\---



\## Step 4 – Troubleshoot Target Group



Initially, the WordPress EC2 target appeared as unused.



\### Problem



The EC2 instance was located in:



```text

ap-southeast-1c

```



but the ALB did not initially include the subnet for that Availability Zone.



\### Solution



I edited the ALB network mapping and added the subnet for:



```text

ap-southeast-1c

```



After adding the correct Availability Zone/subnet, the target became healthy.



The target group later showed healthy targets.



This demonstrated the importance of matching ALB Availability Zones with the Availability Zones containing target EC2 instances.



\---



\## Step 5 – Test WordPress Through ALB



The ALB DNS name was opened in the browser.



WordPress loaded successfully through the Application Load Balancer.



The architecture at this stage was:



```text

Internet

&#x20;  |

&#x20;  v

Application Load Balancer

&#x20;  |

&#x20;  v

Target Group

&#x20;  |

&#x20;  v

WordPress EC2

```



\---



\# Part B – Amazon RDS External Database



\## Step 6 – Create RDS MariaDB



I opened:



```text

Amazon RDS

→ Databases

→ Create database

```



The database was created with:



```text

DB identifier: swe40006-wordpress-rds

Engine: MariaDB

Instance class: db.t4g.micro

Region: ap-southeast-1

Availability Zone: ap-southeast-1c

Public access: No

Port: 3306

```



The database was kept private rather than being directly exposed to the Internet.



\---



\## Step 7 – Configure RDS Security



The RDS security group was configured to permit MySQL/MariaDB traffic from the EC2 application security group.



```text

Protocol: TCP

Port: 3306

Source: EC2 Security Group

```



This allows the WordPress EC2 instance to communicate with RDS without exposing the database publicly.



\---



\# Part C – Migrate Existing WordPress Database



\## Step 8 – Create Local WordPress Database Backup



Before migrating the database, I created a SQL backup of the existing WordPress database.



The backup file was:



```text

/home/ec2-user/wordpress-backup.sql

```



The database dump was created from the existing `wordpress` database.



The backup was checked to make sure the SQL file existed before migration.



\---



\## Step 9 – Connect to RDS



I attempted to connect from the EC2 instance to the RDS MariaDB server.



The RDS endpoint format was:



```text

swe40006-wordpress-rds.<RDS-ENDPOINT>.ap-southeast-1.rds.amazonaws.com

```



An initial connection attempt produced:



```text

ERROR 3159

Connections using insecure transport are prohibited

```



\### Cause



The RDS database had secure transport enabled.



\### Solution



I connected using SSL:



```bash

mariadb --ssl -h <RDS-ENDPOINT> -u admin -p

```



The password was entered interactively and is not stored in this repository.



The connection then succeeded.



\---



\## Step 10 – Create WordPress Database on RDS



The WordPress database was prepared on RDS:



```text

wordpress

```



The existing WordPress SQL backup was then imported into the external database.



Example command:



```bash

mariadb --ssl -h <RDS-ENDPOINT> -u admin -p wordpress < \~/wordpress-backup.sql

```



After importing, the WordPress tables were verified in RDS.



\---



\# Part D – Configure WordPress to Use RDS



\## Step 11 – Backup wp-config.php



Before modifying WordPress configuration, I kept a backup of the configuration file.



```text

/var/www/html/wp-config.php.backup

```



This provided a recovery copy if the new database configuration failed.



\---



\## Step 12 – Change Database Configuration



The WordPress configuration file was changed:



```text

/var/www/html/wp-config.php

```



The database settings were updated so WordPress used:



```text

DB\_NAME = wordpress

DB\_USER = admin

DB\_HOST = RDS endpoint

```



The database password is intentionally not shown.



\---



\## Step 13 – Configure SSL for WordPress Database Connection



Because RDS required secure transport, SSL support was configured for the WordPress database connection.



The required PHP/MySQL constant was:



```php

define( 'MYSQL\_CLIENT\_FLAGS', MYSQLI\_CLIENT\_SSL );

```



This allows the WordPress MySQL connection to use SSL.



\---



\# Part E – Troubleshooting WordPress/RDS



\## Step 14 – HTTP 500 Error



After changing WordPress to RDS, the website initially produced:



```text

HTTP 500

```



I checked the WordPress PHP configuration.



Syntax was tested using:



```bash

php -l /var/www/html/wp-config.php

```



\---



\## Step 15 – Check PHP MySQL Extension



I verified that PHP had MySQL support.



```bash

php -m | grep -i mysqli

```



The `mysqli` module was available.



\---



\## Step 16 – SELinux Database Connectivity



I checked whether Apache was permitted to make network database connections.



```bash

getsebool httpd\_can\_network\_connect\_db

```



It was initially disabled.



I enabled it permanently:



```bash

sudo setsebool -P httpd\_can\_network\_connect\_db 1

```



I verified the setting again:



```bash

getsebool httpd\_can\_network\_connect\_db

```



The result showed:



```text

httpd\_can\_network\_connect\_db --> on

```



\---



\## Step 17 – Identify PHP Fatal Error



Apache logs did not clearly identify the root cause of the HTTP 500 error.



I therefore executed the WordPress PHP entry point directly from the command line.



This exposed a PHP fatal error caused by the SSL constant.



The incorrect constant was:



```text

MYSQL\_CLIENT\_SSL

```



The correct PHP mysqli constant was:



```text

MYSQLI\_CLIENT\_SSL

```



I corrected the configuration to:



```php

define( 'MYSQL\_CLIENT\_FLAGS', MYSQLI\_CLIENT\_SSL );

```



After correcting the configuration, WordPress executed successfully.



\---



\## Step 18 – Test WordPress



I tested the web server again:



```bash

curl -I http://localhost

```



The result was:



```text

HTTP/1.1 200 OK

```



WordPress also loaded successfully in the browser.



\---



\## Step 19 – Verify WordPress Uses RDS



To verify that WordPress was no longer dependent on the MariaDB database installed on the EC2 instance, I stopped the local MariaDB service.



WordPress continued to work.



This demonstrated that WordPress was using the external Amazon RDS database.



Architecture:



```text

Internet

&#x20;  |

&#x20;  v

Application Load Balancer

&#x20;  |

&#x20;  v

Target Group

&#x20;  |

&#x20;  v

WordPress EC2

&#x20;  |

&#x20;  | TCP 3306 / SSL

&#x20;  v

Amazon RDS MariaDB

```



\---



\# Part F – Amazon S3 Backup



\## Step 20 – Create S3 Bucket



An Amazon S3 bucket was created for the WordPress backup:



```text

swe40006-thivyasree-ec2-backup

```



The bucket was created in the Singapore region.



\---



\## Step 21 – Configure EC2 Access to S3



An IAM role was attached to the WordPress EC2 instance so the instance could access the S3 backup bucket.



The role used was:



```text

SWE40006-EC2-S3-Backup-Role

```



This allowed the EC2 instance to use AWS CLI commands with S3 without storing AWS access keys directly on the server.



\---



\## Step 22 – Create WordPress Files Backup



The WordPress application files were archived.



The backup file was:



```text

wordpress-files-backup.tar.gz

```



The WordPress database backup was:



```text

wordpress-backup.sql

```



Therefore, the backup contained both:



```text

WordPress application files

\+

WordPress database

```



\---



\## Step 23 – Upload Backups to S3



AWS CLI was used to work with the S3 bucket.



The bucket was checked using:



```bash

aws s3 ls s3://swe40006-thivyasree-ec2-backup/

```



The backup files stored in S3 were:



```text

wordpress-backup.sql

wordpress-files-backup.tar.gz

```



This confirmed that the WordPress backup was stored outside the EC2 instance.



\---



\# Part G – Restore from S3 to a New EC2 Instance



\## Step 24 – Create New Restore EC2 Instance



A separate EC2 instance was created to demonstrate recovery from the S3 backup.



The instance was named:



```text

SWE40006-WordPress-S3-Restore

```



This was a fresh EC2 instance used to prove that the WordPress deployment could be restored.



\---



\## Step 25 – SSH into Restore Instance



I connected to the restore instance from Windows using SSH.



Command format:



```cmd

ssh -i "SWE40006-WordPress-Key.pem" ec2-user@<RESTORE-EC2-PUBLIC-IP>

```



The SSH connection successfully opened the Amazon Linux terminal.



\---



\## Step 26 – Check S3 Backup



From the restore EC2 instance, I checked the backup:



```bash

aws s3 ls s3://swe40006-thivyasree-ec2-backup/

```



The S3 bucket showed the WordPress backup files.



\---



\## Step 27 – Download WordPress Files Backup



The WordPress archive was downloaded from S3:



```bash

aws s3 cp s3://swe40006-thivyasree-ec2-backup/wordpress-files-backup.tar.gz .

```



This copied the archive from S3 to the new EC2 instance.



\---



\## Step 28 – Restore WordPress Files



The WordPress files were extracted:



```bash

sudo tar -xzf wordpress-files-backup.tar.gz -C /

```



The restored files were checked:



```bash

ls -la /var/www/html

```



The WordPress installation was present in:



```text

/var/www/html

```



\---



\# Part H – Restore Instance Troubleshooting



\## Step 29 – Test Website



The restored WordPress website was initially tested.



The instance returned:



```text

HTTP/1.1 504 Gateway Timeout

```



This showed that the web server was reachable but WordPress could not successfully complete the backend database request.



\---



\## Step 30 – Test RDS Port



RDS connectivity was investigated from the restore instance.



The test showed:



```text

RDS PORT BLOCKED

```



\### Cause



The RDS security group allowed the original EC2 instance/security group, but the newly created restore EC2 instance used a different security group.



Therefore, the new EC2 instance was not permitted to access RDS on port 3306.



\---



\## Step 31 – Update RDS Security Group



The RDS inbound security rules were updated.



A rule was added allowing:



```text

Type: MySQL/Aurora

Protocol: TCP

Port: 3306

Source: Restore EC2 Security Group

```



The database was still not made publicly accessible.



\---



\## Step 32 – Retest RDS Connectivity



After updating the RDS security group, the connectivity test showed:



```text

RDS PORT OPEN

```



This confirmed that the new restore EC2 instance could communicate with RDS.



\---



\## Step 33 – Verify Restored WordPress Configuration



I verified the important WordPress database settings without displaying the database password.



```bash

grep -E "DB\_NAME|DB\_USER|DB\_HOST" /var/www/html/wp-config.php

```



The configuration confirmed:



```text

DB\_NAME = wordpress

DB\_USER = admin

DB\_HOST = Amazon RDS endpoint

```



\---



\## Step 34 – Final Website Test



The restored WordPress instance was tested again:



```bash

curl -I http://localhost

```



The final result was:



```text

HTTP/1.1 200 OK

```



The restored WordPress website also loaded successfully in a web browser.



\---



\# Final Task 2.2 Architecture



```text

&#x20;                        Internet

&#x20;                           |

&#x20;                           v

&#x20;                 +---------------------+

&#x20;                 | Application Load    |

&#x20;                 | Balancer            |

&#x20;                 +---------------------+

&#x20;                           |

&#x20;                           v

&#x20;                 +---------------------+

&#x20;                 | Target Group        |

&#x20;                 +---------------------+

&#x20;                           |

&#x20;                           v

&#x20;                 +---------------------+

&#x20;                 | WordPress EC2       |

&#x20;                 | Apache + PHP        |

&#x20;                 +---------------------+

&#x20;                           |

&#x20;                           | SSL / TCP 3306

&#x20;                           v

&#x20;                 +---------------------+

&#x20;                 | Amazon RDS MariaDB  |

&#x20;                 +---------------------+



Backup:

WordPress EC2

&#x20;     |

&#x20;     | AWS CLI

&#x20;     v

+-------------------------+

| Amazon S3               |

| wordpress-backup.sql    |

| wordpress-files-        |

| backup.tar.gz           |

+-------------------------+

&#x20;     |

&#x20;     | Restore

&#x20;     v

+-------------------------+

| New Restore EC2         |

| WordPress restored      |

+-------------------------+

&#x20;     |

&#x20;     v

Amazon RDS

```



\---



\# Task 2.2 Result



Task 2.2 was successfully completed.



I demonstrated:



\- Application Load Balancer creation

\- Target Group creation

\- ALB health checking

\- ALB Availability Zone troubleshooting

\- Amazon RDS MariaDB creation

\- migration of the existing WordPress database to RDS

\- SSL database connectivity

\- WordPress external database configuration

\- SELinux troubleshooting

\- HTTP 500 troubleshooting

\- Amazon S3 backup

\- IAM role use for S3 access

\- WordPress files and database backup

\- creation of a new restore EC2 instance

\- S3 backup download

\- WordPress restoration

\- RDS security group troubleshooting

\- final HTTP 200 verification



\---



\# Evidence to Include



Screenshots should be stored in:



```text

screenshots/Task-2.2/

```



Important evidence includes:



1\. Application Load Balancer details

2\. ALB network mappings

3\. Target Group showing healthy targets

4\. RDS database details

5\. RDS endpoint and port

6\. RDS security group

7\. successful RDS command-line connection

8\. WordPress tables on RDS

9\. `httpd\_can\_network\_connect\_db --> on`

10\. HTTP 500 troubleshooting

11\. corrected `MYSQLI\_CLIENT\_SSL`

12\. `curl` returning HTTP 200

13\. S3 bucket showing both backup files

14\. IAM role attached to EC2

15\. restore EC2 instance

16\. AWS CLI S3 listing

17\. S3 backup download

18\. restored `/var/www/html`

19\. RDS port blocked troubleshooting

20\. updated RDS security group

21\. RDS port open

22\. restored WordPress returning HTTP 200

23\. restored WordPress working in browser



\---



\# Security



No database password, WordPress administrator password, AWS secret key or SSH private key is included in this documentation.



Screenshots containing passwords should be redacted or excluded before submission.

