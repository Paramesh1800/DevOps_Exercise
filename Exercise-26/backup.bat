@echo off

set BUCKET_NAME=backup-solution-paramesh-2026

aws s3 cp backup-project\app s3://%BUCKET_NAME%/backups/app --recursive

aws s3 cp backup-project\config s3://%BUCKET_NAME%/backups/config --recursive

echo Backup Completed Successfully
pause