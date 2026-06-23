@echo off

set BUCKET_NAME=backup-solution-paramesh-2026

aws s3 cp s3://%BUCKET_NAME%/backups/app backup-project\restore\app --recursive

aws s3 cp s3://%BUCKET_NAME%/backups/config backup-project\restore\config --recursive

echo Restore Completed Successfully
pause