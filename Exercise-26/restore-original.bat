@echo off

set BUCKET_NAME=backup-solution-paramesh-2026

aws s3 cp s3://%BUCKET_NAME%/backups/app backup-project\app --recursive

aws s3 cp s3://%BUCKET_NAME%/backups/config backup-project\config --recursive

echo Original Files Restored Successfully
pause