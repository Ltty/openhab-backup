# openhab-backup
Backs up openhab and influx databases and syncs them to a cloud storage provider every 24 hours.

1. Clone the repository to `/opt/`
2. [Install rclone](https://rclone.org/install/), a command line tool to manage files on cloud storage
3. [Conigure rclone](https://rclone.org/docs/) to sync backup files with your cloud storage provider of choice
4. Run `sudo nano etc/fstab` and add `tmpfs /bkup tmpfs nosuid,nodev,noatime 0 0`
   - This command mounts `/bkup` as virtual directory in memory, which will extend the lifetime of your SD card by not writing larger amounts of data every day. Tmpfs is a file system which keeps all of its files in virtual memory. Everything in `tmpfs` is temporary in the sense that no files will be created on your hard drive.
     - The `nosuid` mount option specifies that the filesystem cannot contain set userid files. Preventing `setuid` binaries on a world-writable filesystem makes sense because there's a risk of root escalation.
     - The `nodev` mount option specifies that the filesystem cannot contain special devices: This is a security precaution. You don't want a user world-accessible filesystem like this to have the potential for the creation of character devices or access to random device hardware.
     - The `noatime`mount option disables the updating of access time for both files and directories so that reading a file does not update their access time (atime) which is useful for backups as it results in measurable performance gains
5. Reboot the system with `sudo reboot`. Alternatively, run `sudo mount -a`to apply the changes to `fstab` if you want to apply the changes without rebooting the system.
6. Run `sudo crontab -e` and add `0 0 * * /opt/openhab-backup/sync.sh >> /var/log/openhab-backup.log  2>&1`

   This will create a cronjob that runs once a day and writes log output to a log file.

