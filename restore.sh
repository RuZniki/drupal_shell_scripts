#!/bin/bash
#
#
# Parameters:
# tarfile
# tarfile of sites/defaul/files
#
#
# Database connection information
dbname="drupal"
dbhost="127.0.0.1"
dbuser="user"
dbpw="PASS"
mysqlfile="dbcontent.mysql"

# Website location
webrootdir=/home/sites/drupal/
#
# Variables

# Execution directory (script start point)
startdir=`pwd`	 # return of pwd() populates statdir var
logfile=$startdir"/fullsite.log"	# file path and name of log file to use

# Temporary Directory
datestamp=`date +'%Y-%m-%d'`	# uses US format
tempdir=$datestamp

#
# Begin logging
#
echo "Beginning drupal site restore using \'fullsiterestore.sh\' ..." > $logfile

#
# Input Parameter Check
#

# If no input parameter is given, echo usage and exit
if [ $# -eq 0 ]
then
echo " Usage: sh fullsiterestore.sh {backupfile.tgz} {files-backupfile.tgz}"
echo ""
exit
fi

tarfile=$1
defaultfiles=$2
# Check that the file exists
if [ ! -f "$tarfile" ]
then
  echo " Can not find file: $tarfile" >> $logfile
  echo " Exiting ..." >> $logfile
  exit
fi


# Check that the webroot directory exists
if [ ! -d "$webrootdir" ]
then
  echo " Invalid internal parameter: webrootdir" >> $logfile
  echo " Directory: $webrootdir does not exist" >> $logfile
  echo " Exiting ..." >> $logfile
  exit
fi

#
# Remove old website files
#
echo " Removing old files from $webrootdir ..." >> $logfile
rm -rf $webrootdir/*

#
# unTAR website files
#
echo " unTARing website files into $webrootdir ..." >> $logfile
cd $webrootdir
tar --exclude="$mysqlfile" -xzf $startdir/$tarfile

# unTAR sites/default/files
if [ -f "$startdir/$defaultfiles" ]
then
  echo " Restoring sites/default/files ..." >> $logfile
  cd $webrootdir/sites/default
  tar xzf $startdir/$defaultfiles
fi

# Restore database

#
# Create temporary working directory and expand tar file
#
echo " Creating temp working dir ..." >> $logfile
mkdir $startdir/$tempdir
cd $startdir/$tempdir

# Untar only mysql.file
echo " unTARing db ..." >> $logfile
tar -xzf $startdir/$tarfile "$mysqlfile"
 echo " Restoring database ..." >> $logfile
 echo " user: $dbuser; database: $dbname; host: $dbhost" >> $logfile
 echo "use $dbname; source $mysqlfile;" | mysql --password=$dbpw --user=$dbuser --host=$dbhost

#
# Cleanup
#
echo " Cleaning up ..." >> $logfile
cd $startdir
rm -r $tempdir

#
# Exit banner
#
endtime=`date`
echo "Restoration completed $endtime for $tarfile. " >> $logfile
