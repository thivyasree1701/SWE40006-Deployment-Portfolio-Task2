#!/bin/bash

# SWE40006 Deployment Portfolio Task 2
# WordPress Restore Script
#
# Purpose:
# 1. Download the WordPress backup from Amazon S3
# 2. Restore WordPress files
# 3. Verify the restored files
# 4. Check Apache
# 5. Test the website
#
# Note:
# Database passwords are NOT stored in this script.

set -e

# Variables
S3_BUCKET="s3://swe40006-thivyasree-ec2-backup"
BACKUP_FILE="wordpress-files-backup.tar.gz"
WORDPRESS_DIR="/var/www/html"

echo "========================================"
echo "SWE40006 WordPress Restore"
echo "========================================"

# -------------------------------------------------
# Step 1 - Check S3 backup
# -------------------------------------------------

echo "Checking S3 backup files..."

aws s3 ls "$S3_BUCKET/"

# -------------------------------------------------
# Step 2 - Download WordPress backup
# -------------------------------------------------

echo "Downloading WordPress files backup..."

aws s3 cp "$S3_BUCKET/$BACKUP_FILE" .

echo "Backup downloaded:"
ls -lh "$BACKUP_FILE"

# -------------------------------------------------
# Step 3 - Restore WordPress files
# -------------------------------------------------

echo "Restoring WordPress files..."

sudo tar -xzf "$BACKUP_FILE" -C /

# -------------------------------------------------
# Step 4 - Verify restored files
# -------------------------------------------------

echo "Checking restored WordPress directory..."

ls -la "$WORDPRESS_DIR"

# -------------------------------------------------
# Step 5 - Start Apache
# -------------------------------------------------

echo "Starting Apache..."

sudo systemctl enable --now httpd

# -------------------------------------------------
# Step 6 - Check Apache status
# -------------------------------------------------

echo "Checking Apache status..."

sudo systemctl status httpd --no-pager

# -------------------------------------------------
# Step 7 - Verify WordPress database configuration
# -------------------------------------------------

echo "Checking WordPress database configuration..."

grep -E "DB_NAME|DB_USER|DB_HOST" "$WORDPRESS_DIR/wp-config.php"

# -------------------------------------------------
# Step 8 - Test WordPress locally
# -------------------------------------------------

echo "Testing WordPress..."

curl -I http://localhost | head -n 1

echo "========================================"
echo "Restore procedure completed"
echo "========================================"