#!/bin/sh
export ORACLE_SID=TOMCO
export ORACLE_HOME=`egrep -i ":Y|:N" /etc/oratab |grep $ORACLE_SID | cut -d":" -f2 | grep -v "\#" | grep -v "\*"`
export PATH=$ORACLE_HOME/bin:$PATH
datetime() { echo `date '+%a%d%b%Y %H:%M:%S'` ;}
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

