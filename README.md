# tarsnap-backup-script
Simple tarsnap backup shell script with purging functionality meant to be run via cron or interactively. Tarsnap key requires reading, writing and deleting permissions and must be unencrypted to be run non-interactively. Archives are named by the folder the script is located in and the date and the time the script is run. Files and directories are to be listed one per line in the `include.txt` and `exclude.txt` files respectively.

```backup.sh [archives]```

*archives* The number of archives you wish to keep. 
