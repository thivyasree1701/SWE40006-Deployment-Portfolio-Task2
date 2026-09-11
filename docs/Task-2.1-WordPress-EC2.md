\# Task 2.1 – EC2 and WordPress Deployment



\## Objective



The objective of Task 2.1 was to create an AWS EC2 instance and deploy a working WordPress website on it.



The main components used were:



\- AWS EC2

\- Amazon Linux 2023

\- SSH key pair

\- Security Group

\- Apache HTTP Server

\- PHP

\- MariaDB

\- WordPress



\---



\# Step 1 – Access AWS



I logged in to the AWS environment and selected:



```text

Region: Asia Pacific (Singapore)

Region code: ap-southeast-1

```



I used the Singapore region for all resources in this deployment.



\---



\# Step 2 – Create SSH Key Pair



I opened:



```text

EC2

→ Network \& Security

→ Key Pairs

→ Create key pair

```



I created the key pair:



```text

Name: SWE40006-WordPress-Key

Private key format: .pem

```



The private key was downloaded to my Windows computer.



The `.pem` file is NOT included in this GitHub repository because it is a private authentication credential.



\---



\# Step 3 – Create EC2 Instance



I opened:



```text

EC2

→ Instances

→ Launch instances

```



The main EC2 instance was created with:



```text

Name: SWE40006-WordPress

AMI: Amazon Linux 2023

Instance type: t3.micro

Key pair: SWE40006-WordPress-Key

Region: ap-southeast-1

Availability Zone: ap-southeast-1c

```



The instance was successfully launched and entered the `Running` state.



\---



\# Step 4 – Configure Security Group



The EC2 security group was configured to allow web and administrative access.



The important inbound rules were:



| Type | Protocol | Port | Source | Purpose |

|---|---|---:|---|---|

| HTTP | TCP | 80 | 0.0.0.0/0 | Allow public access to WordPress |

| SSH | TCP | 22 | My IP /32 | Allow SSH access from my computer |



SSH was restricted to my current public IP instead of being opened to the whole Internet.



\---



\# Step 5 – Connect to EC2 Using SSH



From Windows Command Prompt, I connected to the EC2 instance using SSH.



The command format used was:



```cmd

ssh -i "SWE40006-WordPress-Key.pem" ec2-user@<EC2-PUBLIC-DNS-OR-IP>

```



When connecting for the first time, SSH displayed the host authenticity message.



I accepted the host by entering:



```text

yes

```



The SSH connection then opened an Amazon Linux terminal.



\---



\# Step 6 – Verify SSH User



After connecting to the EC2 instance, I verified the current Linux user.



```bash

whoami

```



Expected result:



```text

ec2-user

```



This confirmed that SSH access to the EC2 instance was successful.



\---



\# Step 7 – Update the EC2 System



The Amazon Linux packages were updated before installing the web server components.



```bash

sudo dnf update -y

```



`sudo` was used because software installation requires administrator privileges.



\---



\# Step 8 – Install Apache



Apache was installed as the web server.



```bash

sudo dnf install -y httpd

```



Apache was then enabled and started.



```bash

sudo systemctl enable --now httpd

```



Apache status could be checked using:



```bash

sudo systemctl status httpd

```



The Apache service was expected to show:



```text

active (running)

```



\---



\# Step 9 – Install PHP



PHP and the required database extension were installed.



```bash

sudo dnf install -y php php-mysqli

```



PHP installation could be verified using:



```bash

php -v

```



The deployment used PHP on Amazon Linux to execute the WordPress application.



\---



\# Step 10 – Install MariaDB



MariaDB was used as the initial local WordPress database.



The MariaDB packages were installed on the EC2 instance.



The database service was then started and enabled.



Example service commands used during the deployment were:



```bash

sudo systemctl enable --now mariadb

```



and:



```bash

sudo systemctl status mariadb

```



\---



\# Step 11 – Create WordPress Database



A database was created for WordPress.



The database used was:



```text

wordpress

```



A dedicated local database user was also configured for the initial WordPress installation.



The database password is intentionally not included in this repository.



\---



\# Step 12 – Download and Prepare WordPress



WordPress was downloaded to the EC2 instance and extracted.



The WordPress application files were placed in the Apache document root:



```text

/var/www/html

```



The directory could be checked using:



```bash

ls -la /var/www/html

```



\---



\# Step 13 – Configure WordPress



The WordPress configuration file was prepared as:



```text

/var/www/html/wp-config.php

```



The configuration included:



```text

Database name

Database user

Database password

Database host

```



For Task 2.1, WordPress initially used the database running on the EC2 instance.



Database passwords are not included in this GitHub repository.



\---



\# Step 14 – Configure File Permissions



Apache required access to the WordPress files.



The WordPress directory ownership and permissions were configured so that the web server could access the application files.



The deployment directory was:



```text

/var/www/html

```



The files were then checked using:



```bash

ls -la /var/www/html

```



\---



\# Step 15 – Restart Apache



After configuring WordPress, Apache was restarted.



```bash

sudo systemctl restart httpd

```



The service was checked again using:



```bash

sudo systemctl status httpd

```



\---



\# Step 16 – Test the Website from EC2



Before testing from the browser, I tested the local web server from the EC2 command line.



```bash

curl -I http://localhost

```



A successful web server response returned:



```text

HTTP/1.1 200 OK

```



This confirmed that Apache and WordPress were responding on the EC2 instance.



\---



\# Step 17 – Test WordPress from Browser



I copied the EC2 public IPv4 address and opened it in a web browser.



The URL format was:



```text

http://<EC2-PUBLIC-IP>

```



The WordPress page loaded successfully.



The WordPress site created for the deployment was:



```text

SWE40006 WordPress

```



This confirmed that:



```text

Internet

&#x20;  |

&#x20;  | HTTP : 80

&#x20;  v

EC2 Security Group

&#x20;  |

&#x20;  v

Amazon EC2

&#x20;  |

&#x20;  v

Apache + PHP

&#x20;  |

&#x20;  v

WordPress

&#x20;  |

&#x20;  v

Local MariaDB

```



was working correctly.



\---



\# Step 18 – Verify WordPress Files



The WordPress installation could also be verified from SSH using:



```bash

ls -la /var/www/html

```



The directory contained WordPress files and directories such as:



```text

index.php

wp-admin

wp-content

wp-includes

wp-config.php

```



\---



\# Task 2.1 Result



Task 2.1 was successfully completed.



I demonstrated:



\- AWS environment access

\- SSH key pair creation

\- EC2 instance creation

\- security group configuration

\- SSH access

\- Apache installation

\- PHP installation

\- local database configuration

\- WordPress deployment

\- command-line testing

\- browser testing



The initial architecture was:



```text

&#x20;                   Internet

&#x20;                      |

&#x20;                      | HTTP 80

&#x20;                      v

&#x20;             +------------------+

&#x20;             | Security Group   |

&#x20;             +------------------+

&#x20;                      |

&#x20;                      v

&#x20;             +------------------+

&#x20;             | Amazon EC2       |

&#x20;             | Amazon Linux     |

&#x20;             +------------------+

&#x20;                      |

&#x20;              +-------+-------+

&#x20;              |               |

&#x20;              v               v

&#x20;         Apache/PHP        MariaDB

&#x20;              |

&#x20;              v

&#x20;           WordPress

```



This EC2 WordPress deployment was later extended in Task 2.2 using an Application Load Balancer, Amazon RDS and Amazon S3.



\---



\# Evidence to Include



Screenshots for this task should be stored in:



```text

screenshots/Task-2.1/

```



Useful Task 2.1 evidence includes:



1\. EC2 instance details showing `SWE40006-WordPress`

2\. SSH key pair

3\. Security Group HTTP and SSH inbound rules

4\. Successful Windows SSH connection

5\. Apache service status

6\. WordPress files under `/var/www/html`

7\. `curl -I http://localhost` result

8\. Working WordPress website in the browser



\---



\# Security Note



The following information is intentionally excluded from this repository:



```text

SSH private key (.pem)

Database passwords

WordPress administrator password

AWS credentials

Secret keys

```



These credentials must never be committed to GitHub.

