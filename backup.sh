#!/bin/bash

# Configuration
#
# Backup and migrate module requires
# Change BaM settings pattern to be like "$tarnamebase-YYYY-MM-DD"
   mysqldir=/home/private/backup_migrate/manual
# Website Files
   # (e.g.: webrootdir=/home/user/public_html)
   webrootdir=/home/user/public_html
#
# Variables
#
# Default TAR Output File Base Name
   tarnamebase=drupal-
   datestamp=`date +'%Y-%m-%d'`
   tarname=$tarnamebase$datestamp.tgz
   mysqlfile=$tarnamebase$datestamp.mysql.gz
# Execution directory (script start point)
   startdir=`pwd`
# Temporary Directory
   tempdir=$datestamp
  
#
# Begin logging
#
echo " [START]"

# Check DB backup exist
if [ ! -f "$mysqldir/$mysqlfile" ]
then
  echo " Can not find file DB backup in $mysqlfile"
  echo " Make manual backup with BaM module"
  echo " Exiting ..."
  exit
fi

#
# Create temporary working directory
#
  echo "   Creating temp working dir ..."
  mkdir $tempdir
  cd $tempdir
  cp $mysqldir/$mysqlfile dbcontent.mysql.gz
  gunzip dbcontent.mysql.gz
#
# TAR website files
#
  echo "   TARing website files from $webrootdir ..."
  tar --exclude='./flash' --exclude='./uploads' --exclude='./sites/default/files' \
      -czf $startdir/$tarname \
        -C $webrootdir . \
        -C $startdir/$tempdir ./dbcontent.mysql

# TAR sites/default/files
  read -p "   Make backup of sites/default/files? " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]
  then
    tar czf $startdir/files-$tarname -C $webrootdir/sites/default ./files
  fi

# Remove temporary working directory
  echo "   Removing temp working dir ..."
  rm -r $startdir/$tempdir

#
# Exit banner
#
  endtime=`date`
  echo " Backup completed $endtime, TAR file at $tarname. "
