# tarsnap-backup-script
Simple tarsnap backup shell script with purging functionality meant to be run via cron or interactively. Tarsnap key requires reading, writing and deleting permissions and must be unencrypted to be run non-interactively. Date and time is appended to the archive name specified. Mostly using this to learn how to git.

```
backup.sh [-h] [-n name] [-p] [-c count] [-i include] [-x exclude] [files | directories]

-h      Show this text
-n      Specify the name of the archives (default: backup)
-p      Enable pruning
-c      Number of archives to keep (default: 1)
-i      Include file
-x      Exclude file
```
