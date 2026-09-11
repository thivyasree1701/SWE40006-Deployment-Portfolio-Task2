# SWE40006 Software Deployment and Evolution

## Deployment Portfolio – Task 2

**Student:** Thivyasree A/P Sunder  
**Unit:** SWE40006 – Software Deployment and Evolution  
**Assessment:** Deployment Portfolio – Task 2  
**Target Level:** High Distinction – Task 2.4  
**AWS Region:** Asia Pacific (Singapore) – `ap-southeast-1`

---

## Project Overview

This repository contains the implementation and evidence for **SWE40006 Deployment Portfolio – Task 2**.

The project demonstrates the deployment of a WordPress application on AWS and progressively extends the deployment using an Application Load Balancer, Amazon RDS, Amazon S3, a Launch Template, an Auto Scaling Group, and SSH command-line administration.

I completed the requirements from **Task 2.1 to Task 2.4**.

---

## Deployment Architecture

The final deployment uses the following AWS services:

- **Amazon EC2** – hosts the WordPress application
- **Application Load Balancer (ALB)** – distributes HTTP traffic
- **Amazon RDS for MariaDB** – external WordPress database
- **Amazon S3** – stores WordPress backup files
- **Launch Template** – defines configuration for automatically launched EC2 instances
- **Auto Scaling Group (ASG)** – manages the number of EC2 instances
- **Security Groups** – control HTTP, SSH and database network access
- **IAM Role** – allows the EC2 instance to access the S3 backup bucket

---

# Task 2.1 – WordPress Deployment on EC2

Task 2.1 involved creating the initial AWS environment and deploying WordPress on an EC2 instance.

### Completed

- Created an AWS EC2 instance
- Created and configured an SSH key pair
- Configured the EC2 security group
- Allowed HTTP traffic on port `80`
- Restricted SSH access on port `22`
- Connected to EC2 using SSH from Windows
- Installed and started Apache
- Installed PHP and MariaDB
- Installed WordPress
- Verified that the WordPress website was accessible through a web browser

### Evidence

Evidence is available in:

`/screenshots/Task-2.1/`

Detailed documentation:

`/docs/Task-2.1-WordPress-EC2.md`

---

# Task 2.2 – Load Balancer, RDS and S3 Backup/Restore

Task 2.2 extended the deployment by introducing load balancing, an external database and backup/recovery.

## Application Load Balancer

An internet-facing **Application Load Balancer** was created for the WordPress application.

A target group was configured using HTTP port `80`, and the WordPress EC2 instance was registered as a target.

The target health was verified before testing WordPress through the load balancer.

## Amazon RDS

A MariaDB database was created using **Amazon RDS**.

The existing WordPress database was exported from the EC2 instance and imported into RDS. The WordPress `wp-config.php` configuration was then updated so that WordPress used the external RDS database instead of the local MariaDB database.

The local database service was stopped during testing and WordPress continued to operate, confirming that the application was using RDS.

## Amazon S3 Backup

WordPress was backed up to an Amazon S3 bucket.

The backup included:

- WordPress database backup
- WordPress application files

The S3 bucket contained:

```text
wordpress-backup.sql
wordpress-files-backup.tar.gz
```

## Restore Test

A separate EC2 instance was created to test recovery from the S3 backup.

The WordPress files were downloaded from S3 and extracted onto the new instance. Database connectivity to RDS was configured and the restored WordPress application was tested successfully.

### Evidence

Evidence is available in:

`/screenshots/Task-2.2/`

Detailed documentation:

`/docs/Task-2.2-ELB-RDS-S3.md`

---

# Task 2.3 – Launch Template and Auto Scaling

Task 2.3 extended the deployment to support automatic instance management.

### Completed

- Created a Launch Template
- Created an Auto Scaling Group
- Connected the Auto Scaling deployment to the WordPress target group
- Configured minimum, desired and maximum capacity
- Verified that an instance could be launched by the Auto Scaling Group
- Tested scaling by increasing desired capacity
- Verified that an additional EC2 instance was launched
- Reduced desired capacity again
- Verified that the additional instance was terminated

The scaling activity history provides evidence of both the **scale-out** and **scale-in** operations.

### Evidence

Evidence is available in:

`/screenshots/Task-2.3/`

Detailed documentation:

`/docs/Task-2.3-Auto-Scaling.md`

---

# Task 2.4 – SSH and Command-Line Administration

Task 2.4 demonstrates administration of the AWS deployment through SSH from Windows.

SSH was used to connect to the Amazon Linux EC2 instances and perform deployment, backup, restoration and troubleshooting operations.

Examples of command-line activities include:

```bash
ssh -i "SWE40006-WordPress-Key.pem" ec2-user@<EC2-PUBLIC-DNS>
```

Checking the web server:

```bash
sudo systemctl status httpd
```

Testing WordPress locally:

```bash
curl -I http://localhost
```

Checking the S3 backup:

```bash
aws s3 ls s3://swe40006-thivyasree-ec2-backup/
```

Downloading the WordPress backup:

```bash
aws s3 cp s3://swe40006-thivyasree-ec2-backup/wordpress-files-backup.tar.gz .
```

Restoring WordPress files:

```bash
sudo tar -xzf wordpress-files-backup.tar.gz -C /
```

### Evidence

Evidence is available in:

`/screenshots/Task-2.4/`

Detailed documentation:

`/docs/Task-2.4-SSH.md`

---

# Troubleshooting and Investigation

Several deployment problems were encountered and investigated during the project.

## 1. SSH Connection Timeout

The SSH connection initially timed out because the public IP address of the Windows computer had changed.

**Solution:** The EC2 security group SSH rule was updated to allow the current IP address on port `22`.

---

## 2. SSH Private Key Permission Error

Windows SSH reported that the private key permissions were too open.

The permissions were corrected using:

```powershell
icacls "SWE40006-WordPress-Key.pem" /inheritance:r
icacls "SWE40006-WordPress-Key.pem" /grant:r "$($env:USERNAME):(R)"
```

After correcting the permissions, SSH connected successfully.

---

## 3. Load Balancer Target Not Being Used

The target initially appeared as unused because the Availability Zone containing the WordPress EC2 instance was not enabled on the Application Load Balancer.

**Solution:** The required subnet/Availability Zone was added to the load balancer configuration. The target subsequently became healthy.

---

## 4. RDS Secure Transport Error

The MariaDB client initially failed to connect because the RDS database required secure transport.

**Solution:** SSL was used for the database connection.

```bash
mariadb --ssl -h <RDS-ENDPOINT> -u admin -p
```

---

## 5. SELinux Database Connectivity

Apache initially could not communicate with the external RDS database because the SELinux database network connection setting was disabled.

**Solution:**

```bash
sudo setsebool -P httpd_can_network_connect_db 1
```

---

## 6. WordPress HTTP 500 Error

WordPress returned an HTTP 500 error after the RDS migration.

Command-line PHP testing identified an incorrect constant in `wp-config.php`.

Incorrect:

```php
MYSQL_CLIENT_SSL
```

Correct:

```php
MYSQLI_CLIENT_SSL
```

After correcting the configuration, WordPress returned:

```text
HTTP/1.1 200 OK
```

---

## 7. Restored EC2 Could Not Access RDS

The restored EC2 instance initially returned a `504 Gateway Timeout`.

Testing showed that the RDS database port was blocked for the restored instance.

**Solution:** The RDS security group was updated to allow MariaDB traffic on port `3306` from the restored EC2 security group.

After the security group change, the RDS port became accessible and WordPress returned:

```text
HTTP/1.1 200 OK
```

More troubleshooting evidence is documented in:

`/docs/Troubleshooting.md`

---

# Repository Structure

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

---

# Scripts

The `scripts` directory contains documented backup and restore commands used as part of the deployment workflow.

### Backup

`scripts/backup-wordpress.sh`

### Restore

`scripts/restore-wordpress.sh`

These scripts demonstrate the command-line process used to back up and restore the WordPress deployment.

---

# Security

The repository does **not** intentionally contain private SSH keys or passwords.

Sensitive files are excluded using `.gitignore`, including:

```text
*.pem
*.key
.env
*credentials*
*password*
```

SSH access was restricted through security group rules, and RDS was configured as a private database rather than being publicly accessible.

---

# Conclusion

This project demonstrates the progressive deployment and evolution of a WordPress application on AWS.

The initial EC2-hosted WordPress deployment was extended with an Application Load Balancer, an external RDS MariaDB database, S3 backup and recovery, a Launch Template, an Auto Scaling Group, scaling tests, and Windows SSH command-line administration.

The deployment also involved investigating and resolving practical problems involving SSH permissions, security groups, Availability Zones, RDS SSL requirements, SELinux database connectivity, WordPress configuration and backup restoration.

The evidence and documentation in this repository demonstrate completion of **Task 2.1, Task 2.2, Task 2.3 and Task 2.4**.
