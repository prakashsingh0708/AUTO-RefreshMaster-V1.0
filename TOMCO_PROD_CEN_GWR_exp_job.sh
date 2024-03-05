#!/bin/sh

datetime() { echo `date '+%a%d%b%Y %H:%M:%S'` ;}
# Get the estimation size from expdp logfile
expdp_estimate="/oradump/TOMCO_PROD_cen_gwr_ESTIMATE_ONLY_exp.log"
if [ ! -f "$expdp_estimate" ]; then
    echo "$(datetime) Error: Expdp estimate logfile not found " > /opt/oracle/refresh/logs/status.log
    SUBJECT="[Gold][CRITICAL][NOT-STARTED][DB]Cloud_S_GOLD-oracle PROD CEN_GWR_exp JOB Not-STARTED"
    echo "Error: Expdp estimate logfile not found. Exiting."
    exit 1
fi

# Set initial values for space check loop
retry_interval=300  # 5 minutes
max_retries=10
retries=0

while true; do
    # Get the size from df command
    df_output=$(df -h /oradump)
    size=$(echo "$df_output" | awk 'NR==2{gsub(/[a-zA-Z]/, "", $3); print $3}')

    # Get the estimation size from expdp logfile
    estimation=$(awk -F ': ' '/Total estimation using BLOCKS method:/ {gsub(/[a-zA-Z]/, "", $2); print $2}' "$expdp_estimate" | awk '{print $1}')

    # Compare the sizes
    if (( $(echo "$size > $estimation" | bc -l) )); then
        echo "$(datetime) Size from df ($size G) is greater than Estimation from expdp ($estimation G). Initiating Export job..." >> /opt/oracle/refresh/logs/status.log
        SUBJECT="[Gold][success][STARTED][DB]Cloud_S_GOLD-oracle PROD CEN_GWR_exp JOB STARTED"

    
source /opt/oracle/refresh/scripts/env/cred_oracle

echo "1" > /opt/oracle/refresh/scripts/STATUS.txt
export ORACLE_SID=TOMCO
export ORACLE_HOME=`egrep -i ":Y|:N" /etc/oratab |grep $ORACLE_SID | cut -d":" -f2 | grep -v "\#" | grep -v "\*"`
export PATH=$ORACLE_HOME/bin:$PATH
echo $(datetime)" TOMCO_S CEN-GWR refresh is initiated " > /opt/oracle/refresh/logs/status.log
#datetime() { echo `date '+%a%d%b%Y %H:%M:%S'` ;}
echo $(datetime)" export from TOMCO PRD, schemas CEN510P,GWR602TOMCO is going on " >> /opt/oracle/refresh/logs/status.log
expdp \'/as sysdba\' parfile=/opt/oracle/refresh/scripts/TOMCO_PROD_CEN_GWR_exp.par
expdp \'/as sysdba\' parfile=/opt/oracle/refresh/scripts/TOMCO_PROD_CEN_GWR_exp_seq.par
ERRORLIST=$(egrep "^ORA-[0-9]*:" /oradump/TOMCO_PROD_cen_gwr_exp.log)
ERRORLIST=`echo $ERRORLIST|grep -v ORA-01555`
if [ -n "$ERRORLIST" ]; then
echo $(datetime) " export is failed, check export logfile /oradump/TOMCO_PROD_cen_gwr_exp.log" >> /opt/oracle/refresh/logs/status.log
echo "1" > /opt/oracle/refresh/scripts/STATUS.txt
else
echo $(datetime)" export success"  >> /opt/oracle/refresh/logs/status.log
echo "0" > /opt/oracle/refresh/scripts/STATUS.txt
fi
################## OLD RSYNC method which replace the files after checking it############################
#sshpass -p "$ORACLE_PASSWORD" rsync /opt/oracle/refresh/logs/status.log 10.245.93.100:/opt/oracle/refresh/logs/
#sshpass -p "$ORACLE_PASSWORD" rsync /opt/oracle/refresh/scripts/STATUS.txt 10.245.93.100:/opt/oracle/refresh/scripts/
#########rsync /opt/oracle/refresh/scripts/*.dmp 10.245.93.100:/opt/oracle/refresh/scripts/
#sshpass -p "$ORACLE_PASSWORD" rsync /oradump/TOMCO_PROD_cen_gwr_exp*.dmp 10.245.93.100:/oradump/refresh/

################## RSYNC Method which will replace the files without checking #############
rsync -av --delete-before -c --checksum  -e "sshpass -p '$ORACLE_PASSWORD' ssh" /opt/oracle/refresh/logs/status.log 10.245.93.100:/opt/oracle/refresh/logs/
rsync -av --delete-before -c --checksum  -e "sshpass -p '$ORACLE_PASSWORD' ssh" /opt/oracle/refresh/scripts/STATUS.txt 10.245.93.100:/opt/oracle/refresh/scripts/
rsync -av --delete-before -c --checksum  -e "sshpass -p '$ORACLE_PASSWORD' ssh" /oradump/TOMCO_PROD_cen_gwr_exp*.dmp 10.245.93.100:/oradump/refresh/

        # Break out of the loop if export job initiated successfully
        break
    else
        echo "$(datetime) ALERT!! Dear, There is Space Crunch in the export DIR, Please do the housekeeping! Size from df: $size G, Estimation from expdp: $estimation G" >> /opt/oracle/refresh/logs/status.log
        SUBJECT="[Gold][CRITICAL][NOT-STARTED][DB]Cloud_S_GOLD-oracle PROD CEN_GWR_exp JOB NOT-STARTED"
    fi

    # Increment retry count
    retries=$((retries + 1))

    if [ "$retries" -ge "$max_retries" ]; then
        echo "$(datetime) Maximum number of retries reached. Exiting."
        break
    fi

    # Wait before the next retry
    sleep "$retry_interval"
done

