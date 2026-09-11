# Troubleshooting and Problem Resolution

## Overview

During the AWS WordPress deployment, several technical problems occurred involving SSH, networking, the Application Load Balancer, Amazon RDS, WordPress configuration and restoration from Amazon S3.

This document records the main problems, how they were investigated, their causes, and the solutions applied.

---

## 1. SSH Connection Timeout

### Problem

When attempting to connect to the EC2 instance from Windows using SSH, the connection timed out.

Example:

```bash
ssh -i "SWE40006-WordPress-Key.pem" ec2-user@<EC2-PUBLIC-DNS>
```

The connection could not reach the EC2 instance.

### Investigation

I checked:

- EC2 instance state
- Public IP/DNS
- Security group inbound rules
- SSH port `22`
- My current public IP address

The EC2 security group allowed SSH only from a specific `/32` public IP address.

My public IP address had changed, so the existing security group rule no longer matched my computer.

### Cause

The SSH security group rule contained my previous public IP address.

### Solution

I edited the EC2 security group and changed the SSH source to my current public IP address.

The rule remained restricted to:

```text
SSH
TCP
Port 22
My IP /32
```

After updating the rule, SSH could reach the EC2 instance again.

### Lesson Learned

Restricting SSH to a specific IP address improves security, but the rule must be updated when the client public IP changes.

---

## 2. Windows SSH Private Key Permission Error

### Problem

After resolving the network timeout, Windows SSH rejected the `.pem` private key because its permissions were too open.

The SSH client displayed a warning indicating that the private key file was accessible by other users.

### Investigation

The EC2 instance and network configuration were working, so the problem was related to the local Windows key file rather than AWS.

### Cause

The `.pem` file inherited Windows permissions that allowed more access than OpenSSH accepts for a private key.

### Solution

I removed inherited permissions:

```powershell
icacls "SWE40006-WordPress-Key.pem" /inheritance:r
```

I then granted read access to my Windows user:

```powershell
icacls "SWE40006-WordPress-Key.pem" /grant:r "$($env:USERNAME):(R)"
```

After changing the permissions, SSH authentication succeeded.

### Lesson Learned

SSH private keys must be protected both in AWS and on the local computer.

The private `.pem` file is not included in this GitHub repository.

---

## 3. Application Load Balancer Target Was Unused

### Problem

After creating the Application Load Balancer and target group, the WordPress EC2 target initially appeared as unused instead of healthy.

### Investigation

I checked:

- Target group registration
- HTTP port `80`
- EC2 instance state
- Security groups
- Load Balancer Availability Zones and subnets

The WordPress EC2 instance was located in an Availability Zone that was not initially enabled on the Application Load Balancer.

### Cause

The ALB did not include the subnet for the Availability Zone containing the WordPress EC2 instance.

Therefore, the load balancer could not correctly use that target.

### Solution

I edited the Application Load Balancer network configuration and added the required subnet/Availability Zone.

After the change, the target became healthy.

### Verification

The WordPress website successfully loaded using the Application Load Balancer DNS name.

### Lesson Learned

The load balancer must be configured for the Availability Zones containing the EC2 targets that it needs to serve.

---

## 4. Amazon RDS Secure Transport Error

### Problem

When connecting from EC2 to the Amazon RDS MariaDB database, the initial MariaDB connection failed.

RDS required secure transport.

### Investigation

A standard connection was attempted first.

The database server rejected the connection because secure transport was required.

### Cause

The RDS MariaDB configuration required SSL for database connections.

### Solution

I connected using the MariaDB client's SSL option:

```bash
mariadb --ssl -h <RDS-ENDPOINT> -u admin -p
```

The password was entered interactively and is not stored in this repository.

### Verification

The secure connection successfully opened the MariaDB client connected to Amazon RDS.

### Lesson Learned

Managed database services can enforce additional security requirements such as encrypted database connections.

---

## 5. RDS Authentication Error

### Problem

During the RDS migration process, a database connection produced an authentication error.

Example:

```text
ERROR 1045
Access denied
```

### Investigation

I checked:

- RDS endpoint
- Database username
- Password
- Port `3306`
- Security group configuration

Network access was available, which indicated that the problem was authentication rather than connectivity.

### Cause

The password being used did not match the current RDS master-user password.

### Solution

The RDS master password was reset.

The new credentials were tested directly using the MariaDB client before updating WordPress.

The corresponding WordPress database configuration was then updated.

### Security Note

The database password is intentionally excluded from the GitHub repository and documentation.

### Lesson Learned

Testing database credentials directly from the command line helps separate authentication problems from network problems.

---

## 6. Apache/PHP Could Not Communicate with RDS

### Problem

Even after command-line RDS connectivity was available, the WordPress application still experienced database connectivity problems.

### Investigation

I checked the SELinux configuration using the HTTP database networking setting.

The relevant setting was initially disabled.

### Cause

SELinux prevented the Apache/PHP process from making the required external database network connection.

### Solution

I enabled the setting persistently:

```bash
sudo setsebool -P httpd_can_network_connect_db 1
```

The setting was then checked to confirm that it was enabled.

### Verification

The configuration showed that HTTP database network connectivity was enabled.

### Lesson Learned

Successful command-line connectivity does not always mean that the web-server process has permission to make the same network connection.

Operating-system security controls such as SELinux must also be considered.

---

## 7. WordPress HTTP 500 Error After RDS Migration

### Problem

After configuring WordPress to use Amazon RDS, the website returned an HTTP 500 error.

### Investigation

Several areas were checked:

- Apache service
- PHP
- `wp-config.php`
- RDS connectivity
- WordPress logging

The normal WordPress debug log did not immediately identify the problem.

I then executed PHP directly from the command line to isolate the configuration error.

The command-line output reported an undefined constant in:

```text
/var/www/html/wp-config.php
```

### Cause

The SSL client constant in `wp-config.php` was written incorrectly.

Incorrect:

```php
MYSQL_CLIENT_SSL
```

Correct:

```php
MYSQLI_CLIENT_SSL
```

### Solution

I corrected the constant in `wp-config.php`.

I then checked the PHP configuration and tested WordPress again.

### Verification

The final HTTP test returned:

```text
HTTP/1.1 200 OK
```

WordPress also loaded successfully in the browser.

### Lesson Learned

Running PHP directly from the command line can reveal configuration errors that may not be obvious from the browser or application logs.

---

## 8. Restored EC2 Instance Returned 504 Gateway Timeout

### Problem

After restoring the WordPress files from Amazon S3 onto the new EC2 instance, the application initially returned:

```text
HTTP/1.1 504 Gateway Timeout
```

### Investigation

The WordPress files were present, so I tested connectivity from the restored EC2 instance to the external RDS database.

The result showed:

```text
RDS PORT BLOCKED
```

I then checked the RDS security group.

### Cause

The restored EC2 instance used a different security group from the original WordPress EC2 instance.

The RDS security group allowed the original application environment but did not yet allow database traffic from the restored EC2 security group.

### Solution

I updated the RDS security group to allow:

```text
MariaDB
TCP
Port 3306
Source: Restored EC2 Security Group
```

Using a security group as the source allowed database access specifically from the required EC2 environment rather than opening the database publicly.

### Verification

After updating the security group, connectivity testing showed:

```text
RDS PORT OPEN
```

The WordPress HTTP test then returned:

```text
HTTP/1.1 200 OK
```

The restored WordPress website also loaded successfully in the browser.

### Evidence

![Restore RDS Troubleshooting](../screenshots/Task-2.2/08-Restore-RDS-Troubleshooting.png)

**Figure 1:** Restored EC2 troubleshooting showing the transition from RDS port blocked and HTTP 504 to RDS port open and HTTP 200.

### Lesson Learned

When creating or restoring a new EC2 instance, database security-group rules must also permit the new instance or its security group to communicate with RDS.

---

## 9. S3 Backup and Restore Verification

### Problem

Creating backup files alone does not prove that the deployment can actually be recovered.

### Approach

I tested the backup by creating a separate EC2 instance and retrieving the WordPress application archive from S3.

The S3 bucket contents were checked using:

```bash
aws s3 ls s3://swe40006-thivyasree-ec2-backup/
```

The WordPress archive was downloaded using:

```bash
aws s3 cp s3://swe40006-thivyasree-ec2-backup/wordpress-files-backup.tar.gz .
```

The application files were restored using:

```bash
sudo tar -xzf wordpress-files-backup.tar.gz -C /
```

### Verification

The WordPress files were present under:

```text
/var/www/html
```

After resolving the RDS security-group issue, the restored deployment returned:

```text
HTTP/1.1 200 OK
```

and WordPress loaded successfully.

### Lesson Learned

A backup should be tested by performing a restoration. A successful restore provides stronger evidence than simply showing that backup files exist.

---

## Troubleshooting Summary

| Problem | Cause | Resolution |
|---|---|---|
| SSH timeout | Public IP changed | Updated SSH security group source |
| SSH key rejected | Windows key permissions too open | Corrected permissions using `icacls` |
| ALB target unused | Required Availability Zone/subnet missing | Added subnet/AZ to ALB |
| RDS secure transport error | SSL required | Connected using `mariadb --ssl` |
| RDS authentication error | Password mismatch | Reset and verified RDS credentials |
| Apache could not reach RDS | SELinux database networking disabled | Enabled `httpd_can_network_connect_db` |
| WordPress HTTP 500 | Incorrect MySQL SSL constant | Changed to `MYSQLI_CLIENT_SSL` |
| Restored WordPress HTTP 504 | RDS port blocked for restore instance | Allowed restore EC2 security group on port `3306` |

---

## Final Result

All major deployment problems were investigated and resolved successfully.

The troubleshooting process involved checking multiple layers of the deployment:

```text
Windows Client
      |
      v
SSH / Security Groups
      |
      v
EC2 / Apache / PHP
      |
      v
Application Load Balancer
      |
      v
WordPress
      |
      v
Amazon RDS
      |
      v
Amazon S3 Backup and Restore
```

The final environment demonstrated successful WordPress deployment, external RDS database connectivity, load balancing, S3 backup and recovery, Auto Scaling, and SSH command-line administration.

The troubleshooting work also demonstrates practical investigation rather than only successful final-state screenshots.
