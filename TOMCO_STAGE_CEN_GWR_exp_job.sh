#!/bin/sh

datetime() { echo `date '+%a%d%b%Y %H:%M:%S'` ;}

# Get the estimation size from expdp logfile
expdp_estimate="/oradump/refresh/TOMCO_STAGE_CEN_GWR_ESTIMATE_ONLY_exp.log"
if [ ! -f "$expdp_estimate" ]; then
    echo "$(datetime) Error: Expdp estimate logfile not found " > /opt/oracle/refresh/logs/status.log
    SUBJECT="[Gold][CRITICAL][NOT-STARTED][DB]Cloud_S_GOLD-oracle STAGE CEN_GWR_exp JOB Not-STARTED"
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
        SUBJECT="[Gold][success][STARTED][DB]Cloud_S_GOLD-oracle STAGE CEN_GWR_exp JOB STARTED"

export ORACLE_SID=TOMCO
export ORACLE_HOME=`egrep -i ":Y|:N" /etc/oratab |grep $ORACLE_SID | cut -d":" -f2 | grep -v "\#" | grep -v "\*"`
export PATH=$ORACLE_HOME/bin:$PATH
#datetime() { echo `date '+%a%d%b%Y %H:%M:%S'` ;}
echo $(datetime)" export from tomco STG, Backup Before refresh is initiated " > /opt/oracle/refresh/logs/status.log
expdp \'/as sysdba\' parfile=/opt/oracle/refresh/scripts/TOMCO_STAGE_CEN_GWR_exp.par
ERRORLIST=$(egrep "^ORA-[0-9]*:" /opt/oracle/backup/DUMP/TOMCO_STAGE_CEN_GWR_exp.log)
ERRORLIST=`echo $ERRORLIST|grep -v ORA-01555`
if [ -n "$ERRORLIST" ]; then
echo $(datetime) " export from tomco STG Before refresh -- failed, check export logfile /opt/oracle/backup/DUMP/TOMCO_STAGE_CEN_GWR_exp.log" >> /opt/oracle/refresh/logs/status.log
SUBJECT="[Gold][Critical][DB][PROD]:Cloud_S_GOLD-oracle TOMCOPRD to TOMCO_S refresh export failed"
echo "1" > /opt/oracle/refresh/scripts/STAT.txt
else
echo $(datetime)" export from tomco STG Before refresh success"  >> /opt/oracle/refresh/logs/status.log
SUBJECT="[Gold][success][DB]Cloud_S_GOLD-oracle TOMCO CEN and GWR export success"
echo "0" > /opt/oracle/refresh/scripts/STAT.txt
fi

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


