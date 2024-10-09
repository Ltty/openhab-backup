# openhab-backup
Backs up openhab, influx databases, and pivccu configurations and syncs them to a cloud storage provider every 24 hours.

- openhab backup uses `openhab-cli backup` to create a backup including persistence
- influx backup uses `influxd backup -portable` to create a backup
- pivccu backup uses `pivccu-backup` to create a backup

1. Clone the repository to `/opt/`
2. [Install rclone](https://rclone.org/install/), a command line tool to manage files on cloud storage
3. [Conigure rclone](https://rclone.org/docs/) to sync backup files with your cloud storage provider of choice
4. Run `sudo nano /etc/fstab` and add the following command to mount `/bkup` as a virtual directory in memory to extend the lifetime of your SD card.
   ```
   tmpfs /bkup tmpfs nosuid,nodev,noatime 0 0
   ```

6. Reboot the system with `sudo reboot`. If you do not want to reboot your system, you can alternatively call `sudo mount -a` to apply the changes to `fstab`.
7. Run `sudo crontab -e` and add one of the following options to create a cronjob that runs the backup once a day and pipes log output to a log file

   Backup all services
   ```
   0 0 * * /opt/openhab-backup/sync.sh -a >> /var/log/openhab-backup.log  2>&1
   ```
   
   Backup openhab only
   ```
   0 0 * * /opt/openhab-backup/sync.sh -o >> /var/log/openhab-backup.log  2>&1
   ```

   Backup influx only
   ```
   0 0 * * /opt/openhab-backup/sync.sh -i >> /var/log/openhab-backup.log  2>&1
   ```

   Backup pivccu only
   ```
   0 0 * * /opt/openhab-backup/sync.sh -p >> /var/log/openhab-backup.log  2>&1
   ```

9. Run the following command to give all users execution rights to the script.
    ```
    sudo chmod +x /opt/openhab-backup/sync.sh
    ```
