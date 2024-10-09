#!/bin/bash

while getopts aoip flag
do
    case "${flag}" in
        a) backupAll=true;;
        o) backupOpenhab=true;;
        i) backupInflux=true;;
	p) backupPivccu=true;;
    esac
done

declare -A listOfDirs

rcloneConfig=/home/openhabian/.config/rclone/rclone.conf
rcloneOptions="-v --ignore-checksum --ignore-size --local-no-check-updated"

echo  $(date +"%Y-%m-%d %H:%M:%S") starting backup

if [[ $backupAll = true || $backupOpenhab = true ]]; then
  echo  $(date +"%Y-%m-%d %H:%M:%S") creating openhab backup in ${listOfDirs[openhab]}
  listOfDirs[openhab]=/bkup/openhab
  # Create openhab backup
  mkdir -p ${listOfDirs[openhab]}
  openhab-cli backup ${listOfDirs[openhab]}/openhab-backup-$(date +"%d_%m_%y-%H_%M_%S").zip
fi

if [[ $backupAll = true || $backupInflux = true ]]; then
  echo  $(date +"%Y-%m-%d %H:%M:%S") creating influxdb backup in ${listOfDirs[influxdb]}
  listOfDirs[influxdb]=/bkup/influxdb
  # Create influxdb backup
  mkdir -p ${listOfDirs[influxdb]}
  influxd backup -portable ${listOfDirs[influxdb]}
fi

if [[ $backupAll = true || $backupPivccu = true ]]; then
  echo  $(date +"%Y-%m-%d %H:%M:%S") creating pivccu backup in ${listOfDirs[pivccu]}
  listOfDirs[pivccu]=/bkup/pivccu

  # Create pivccu backup
  mkdir -p ${listOfDirs[pivccu]}
  pivccu-backup ${listOfDirs[pivccu]}
fi

for dir in "${!listOfDirs[@]}"
do
   :
   echo  $(date +"%Y-%m-%d %H:%M:%S") backing up $dir - ${listOfDirs[$dir]}
   rclone $rcloneOptions --config=$rcloneConfig sync ${listOfDirs[$dir]} gdrive:/backups/$dir
done


echo  $(date +"%Y-%m-%d %H:%M:%S") cleaning up space
rm -R /bkup/*

echo  $(date +"%Y-%m-%d %H:%M:%S") backup completed
