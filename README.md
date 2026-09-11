<a id="readme-top"></a>

# SWE40006 Deployment Portfolio – Task 2

AWS WordPress deployment project for **SWE40006 – Software Deployment and Evolution**.

This repository documents the deployment and evolution of a WordPress application using Amazon EC2, Application Load Balancer, Amazon RDS, Amazon S3, Launch Templates, Auto Scaling and SSH administration.

**Target Level: High Distinction – Task 2.4**

---

## Table of Contents

1. [About](#about)
   - [Built With](#built-with)
   - [AWS Services](#aws-services)
2. [Features](#features)
3. [Deployment Tasks](#deployment-tasks)
4. [Architecture](#architecture)
5. [Documentation](#documentation)
6. [Evidence](#evidence)
7. [Usage](#usage)
8. [Backup and Restore](#backup-and-restore)
9. [Troubleshooting](#troubleshooting)
10. [Repository Structure](#repository-structure)
11. [Security](#security)
12. [Acknowledgments](#acknowledgments)

---

## About

This repository contains my implementation and evidence for **SWE40006 Deployment Portfolio – Task 2**.

The project started with a basic WordPress deployment on Amazon EC2 and was progressively extended to include:

- Application Load Balancing
- External Amazon RDS database
- Amazon S3 backup and recovery
- EC2 Launch Template
- Auto Scaling Group
- Scaling tests
- Windows SSH administration
- Command-line deployment and troubleshooting

The completed implementation covers **Task 2.1, Task 2.2, Task 2.3 and Task 2.4**.

([back to top](#readme-top))

---

### Built With

The deployment uses:

- WordPress
- Amazon Linux 2023
- Apache HTTP Server
- PHP
- MariaDB
- AWS CLI
- Git
- GitHub
- Windows OpenSSH

([back to top](#readme-top))

---

### AWS Services

The following AWS services were used in the deployment.

#### Amazon EC2

Amazon EC2 hosts the WordPress application and provides the Linux environment used for deployment and administration.

#### Application Load Balancer

The Application Load Balancer provides an internet-facing endpoint and forwards HTTP traffic to healthy WordPress targets.

#### Amazon RDS

Amazon RDS for MariaDB provides the external database used by WordPress instead of relying on the database hosted locally on the EC2 instance.

#### Amazon S3

Amazon S3 stores the WordPress backup files:

```text
wordpress-backup.sql
wordpress-files-backup.tar.gz
```

#### EC2 Launch Template

The Launch Template defines the configuration required when the Auto Scaling Group launches new EC2 instances.

#### Auto Scaling Group

The Auto Scaling Group manages WordPress EC2 instances and was tested by scaling the desired capacity from one instance to two instances and back to one.

#### IAM

An IAM role was attached to the EC2 instance to provide access to the S3 backup bucket without storing AWS access keys directly on the server.

#### Security Groups

Security groups control access to:

```text
HTTP      TCP 80
SSH       TCP 22
MariaDB   TCP 3306
```

([back to top](#readme-top))

---

## Features

The completed deployment demonstrates:

- WordPress hosted on Amazon EC2
- Secure SSH access from Windows
- Apache and PHP configuration
- Application Load Balancing
- Target health monitoring
- External MariaDB database using Amazon RDS
- WordPress database migration from EC2 to RDS
- SSL database connectivity
- S3 application and database backup
- Recovery onto a separate EC2 instance
- EC2 Launch Template
- Auto Scaling Group
- Scale-out testing
- Scale-in testing
- AWS CLI administration
- Linux command-line administration
- Deployment troubleshooting and verification

([back to top](#readme-top))

---

## Deployment Tasks

### Task 2.1 – EC2 and WordPress

The initial deployment involved:

- Creating an EC2 instance
- Creating an SSH key pair
- Configuring security groups
- Connecting through SSH
- Installing Apache
- Installing PHP and MariaDB
- Installing WordPress
- Verifying WordPress through a browser

**Documentation:**  
[Task 2.1 – EC2 and WordPress](docs/Task-2.1-WordPress-EC2.md)

---

### Task 2.2 – ALB, RDS and S3

The deployment was extended by:

- Creating an Application Load Balancer
- Creating a target group
- Verifying healthy targets
- Creating an Amazon RDS MariaDB database
- Migrating the WordPress database to RDS
- Configuring WordPress to use RDS
- Creating WordPress backups
- Uploading backups to Amazon S3
- Creating a separate restore EC2 instance
- Restoring WordPress from S3
- Verifying the restored application

**Documentation:**  
[Task 2.2 – ALB, RDS and S3](docs/Task-2.2-ELB-RDS-S3.md)

---

### Task 2.3 – Auto Scaling

The scalable deployment involved:

- Creating an EC2 Launch Template
- Creating an Auto Scaling Group
- Connecting the deployment to the WordPress target group
- Launching an instance through the ASG
- Increasing desired capacity from 1 to 2
- Verifying automatic instance launch
- Reducing desired capacity from 2 to 1
- Verifying automatic instance termination

**Documentation:**  
[Task 2.3 – Auto Scaling](docs/Task-2.3-Auto-Scaling.md)

---

### Task 2.4 – SSH Administration

SSH from Windows was used to demonstrate command-line administration.

Activities included:

- Connecting to Amazon Linux from Windows
- Correcting private-key permissions
- Managing Apache
- Testing WordPress
- Accessing S3 using AWS CLI
- Restoring WordPress files
- Testing RDS connectivity
- Troubleshooting the deployment

**Documentation:**  
[Task 2.4 – SSH](docs/Task-2.4-SSH.md)

([back to top](#readme-top))

---

## Architecture

The main deployment architecture is:

```text
                    Internet
                       |
                       v
            Application Load Balancer
                       |
                       v
             WordPress Target Group
                       |
                       v
                EC2 Instances
                /          \
               /            \
              v              v
        Amazon RDS       Amazon S3
         MariaDB          Backups
```

For scaling:

```text
Launch Template
      |
      v
Auto Scaling Group
      |
      v
EC2 WordPress Instances
      |
      v
Target Group
      |
      v
Application Load Balancer
```

The architecture separates the application, database and backup storage while allowing EC2 application instances to be managed through Auto Scaling.

([back to top](#readme-top))

---

## Documentation

Detailed documentation is available in the `docs` directory:

| Document | Description |
|---|---|
| [Task 2.1](docs/Task-2.1-WordPress-EC2.md) | EC2 and WordPress deployment |
| [Task 2.2](docs/Task-2.2-ELB-RDS-S3.md) | ALB, RDS migration and S3 backup/restore |
| [Task 2.3](docs/Task-2.3-Auto-Scaling.md) | Launch Template and Auto Scaling |
| [Task 2.4](docs/Task-2.4-SSH.md) | Windows SSH and CLI administration |
| [Troubleshooting](docs/Troubleshooting.md) | Problems, investigation and solutions |

([back to top](#readme-top))

---

## Evidence

Deployment screenshots are organised according to the assessment tasks.

```text
screenshots/
├── Task-2.1/
├── Task-2.2/
├── Task-2.3/
└── Task-2.4/
```

### Task 2.1 Evidence

Includes evidence of:

- EC2 creation
- SSH key pair
- Security group
- SSH connection
- Apache
- WordPress files
- Working WordPress website

### Task 2.2 Evidence

Includes evidence of:

- Application Load Balancer
- Healthy target group
- WordPress through ALB
- Amazon RDS
- RDS connectivity
- S3 backup
- S3 restore
- Restore troubleshooting
- Restored EC2
- Restored WordPress website

### Task 2.3 Evidence

Includes evidence of:

- Launch Template
- Auto Scaling Group
- Target group integration
- Two-instance scale-out
- Scaling activity history
- Target health

### Task 2.4 Evidence

Includes evidence of:

- Windows SSH
- SSH key-permission troubleshooting
- WordPress CLI testing
- S3 CLI commands
- Restore commands
- RDS CLI testing
- Final restore verification

([back to top](#readme-top))

---

## Usage

### SSH to EC2

A typical SSH connection from Windows is:

```bash
ssh -i "SWE40006-WordPress-Key.pem" ec2-user@<EC2-PUBLIC-DNS>
```

### Check Apache

```bash
sudo systemctl status httpd
```

or:

```bash
sudo systemctl is-active httpd
```

### Test WordPress

```bash
curl -I http://localhost
```

A successful deployment returns:

```text
HTTP/1.1 200 OK
```

### Check WordPress Files

```bash
ls -la /var/www/html
```

([back to top](#readme-top))

---

## Backup and Restore

### Check S3 Backup

```bash
aws s3 ls s3://swe40006-thivyasree-ec2-backup/
```

### Download WordPress Backup

```bash
aws s3 cp s3://swe40006-thivyasree-ec2-backup/wordpress-files-backup.tar.gz .
```

### Restore WordPress Files

```bash
sudo tar -xzf wordpress-files-backup.tar.gz -C /
```

### Verify Restored Files

```bash
ls -la /var/www/html
```

Backup and restore scripts are also available in:

```text
scripts/
├── backup-wordpress.sh
└── restore-wordpress.sh
```

([back to top](#readme-top))

---

## Troubleshooting

Several technical problems were encountered and resolved during the deployment.

| Problem | Cause | Solution |
|---|---|---|
| SSH timeout | Public IP address changed | Updated SSH security group source |
| SSH key rejected | Windows `.pem` permissions too open | Corrected permissions using `icacls` |
| ALB target unused | Required subnet/AZ not enabled | Added the required subnet to ALB |
| RDS connection rejected | Secure transport required | Used MariaDB SSL connection |
| RDS authentication failed | Credential mismatch | Reset and verified RDS credentials |
| Apache could not access RDS | SELinux restriction | Enabled `httpd_can_network_connect_db` |
| WordPress HTTP 500 | Incorrect MySQL SSL constant | Corrected to `MYSQLI_CLIENT_SSL` |
| Restored site returned 504 | RDS blocked restored EC2 | Allowed restore EC2 security group on port 3306 |

Full investigation:

[**View Troubleshooting Documentation »**](docs/Troubleshooting.md)

([back to top](#readme-top))

---

## Repository Structure

```text
SWE40006-Deployment-Portfolio-Task2/
│
├── README.md
├── .gitignore
│
├── docs/
│   ├── Task-2.1-WordPress-EC2.md
│   ├── Task-2.2-ELB-RDS-S3.md
│   ├── Task-2.3-Auto-Scaling.md
│   ├── Task-2.4-SSH.md
│   └── Troubleshooting.md
│
├── screenshots/
│   ├── Task-2.1/
│   ├── Task-2.2/
│   ├── Task-2.3/
│   └── Task-2.4/
│
├── scripts/
│   ├── backup-wordpress.sh
│   └── restore-wordpress.sh
│
└── report/
```

([back to top](#readme-top))

---

## Security

Sensitive information is intentionally excluded from this repository.

The repository does **not** intentionally contain:

- SSH private keys
- Database passwords
- AWS access keys
- Secret access keys
- Environment files containing credentials

The `.gitignore` contains rules such as:

```text
*.pem
*.key
.env
*credentials*
*password*
```

The AWS deployment also uses:

- SSH restricted to the administrator's public IP
- Security groups between EC2 and RDS
- Private RDS access
- IAM role access to Amazon S3
- SSL for RDS database communication

> **Important:** Screenshots and documentation should also be manually checked for visible passwords or credentials before submission.

([back to top](#readme-top))

---

## Acknowledgments

This project was completed as part of:

**SWE40006 – Software Deployment and Evolution**

The deployment uses services provided by Amazon Web Services and the WordPress open-source platform.

Documentation and evidence in this repository were prepared for the SWE40006 Deployment Portfolio assessment.

([back to top](#readme-top))

---

## Final Result

The project successfully demonstrates the progressive deployment and evolution of a WordPress application on AWS from a single EC2 instance to a deployment incorporating:

**EC2 → ALB → RDS → S3 Backup/Restore → Launch Template → Auto Scaling → SSH Administration**

All requirements for **Task 2.1 through Task 2.4** are documented with implementation details, command-line evidence, screenshots and troubleshooting.
