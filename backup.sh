#!/bin/bash

<< help
=========================================================
Backup & Git Workflow Script
- Creates a timestamped backup of the repo
- Commits backup and script to dev branch
- Merges dev into main and pushes both branches

NOTE: This script can be added to cron for automatic backups
Example cron entry (runs at 2 AM daily):
0 2 * * * /home/ubuntu/linux_for_devOps/backup.sh >> /home/ubuntu/linux_for_devOps/backup.log 2>&1
=========================================================
help

# ----------------------------
# Paths
# ----------------------------
source_dir="/home/ubuntu/linux_for_devOps"
destination_dir="/home/ubuntu/linux_for_devOps/backups"
mkdir -p "$destination_dir"

# ----------------------------
# Create backup (exclude backups folder itself)
# ----------------------------
timestamp=$(date '+%Y-%m-%d-%H-%M-%S')
backup_file="${destination_dir}/backup_${timestamp}.zip"

zip -r "$backup_file" "$source_dir" -x "$destination_dir/*"
echo "✅ Backup created: $backup_file"

# ----------------------------
# Git workflow
# ----------------------------
git switch dev
git pull --rebase origin dev

git add "$backup_file"
git add backup.sh
git commit -m "Backup and updates: $timestamp" || echo "Nothing to commit"
git push origin dev

git switch main
git pull --rebase origin main
git merge dev -m "Merge dev into main after backup $timestamp"
git push origin main

git status
git branch

echo "✅ DevOps backup + Git workflow complete!"
