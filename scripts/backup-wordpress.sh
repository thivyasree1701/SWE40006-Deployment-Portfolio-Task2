#!/bin/bash

# SWE40006 Deployment Portfolio Task 2
# WordPress Backup Script
#
# Purpose:
# 1. Create a backup of the WordPress database
# 2. Create a compressed backup of WordPress files
# 3. Upload both backups to Amazon S3
# 4. Verify the uploaded files

# Stop script if a command fails
set -e

# Variables
S3_BUCKET="s3://swe40006-thivyasree-ec2-backup"
WORDPRESS_DIR="/var/www/html"
BACKUP_DIR="/home/ec2-user"

DB_BACKUP="$BACKUP_DIR/wordpress-backup.sql"
FILES_BACKUP="$BACKUP_DIR/wordpress-files-backup.tar.gz"

echo "========================================"
echo "SWE40006 WordPress Backup"
echo "========================================"

# -------------------------------------------------
# Step 1 - Create WordPress database backup
# -------------------------------------------------

echo "Creating WordPress database backup..."

# This command backs up the local WordPress database.
# The database password should be entered securely when required.
sudo mariadb-dump wordpress > "$DB_BACKUP"

echo "Database backup created:"
ls -lh "$DB_BACKUP"

# -------------------------------------------------
# Step 2 - Create WordPress files backup
# -------------------------------------------------

echo "Creating WordPress files backup..."

sudo tar -czf "$FILES_BACKUP" "$WORDPRESS_DIR"

echo "WordPress files backup created:"
ls -lh "$FILES_BACKUP"

# -------------------------------------------------
# Step 3 - Check S3 bucket
# -------------------------------------------------

echo "Checking S3 bucket..."

aws s3 ls "$S3_BUCKET/"

# -------------------------------------------------
# Step 4 - Upload database backup to S3
# -------------------------------------------------

echo "Uploading database backup to S3..."

aws s3 cp "$DB_BACKUP" "$S3_BUCKET/wordpress-backup.sql"

# -------------------------------------------------
# Step 5 - Upload WordPress files backup to S3
# -------------------------------------------------

echo "Uploading WordPress files backup to S3..."

aws s3 cp "$FILES_BACKUP" "$S3_BUCKET/wordpress-files-backup.tar.gz"

# -------------------------------------------------
# Step 6 - Verify S3 backup
# -------------------------------------------------

echo "Verifying uploaded files..."

aws s3 ls "$S3_BUCKET/"

echo "========================================"
echo "Backup completed successfully"
echo "========================================"