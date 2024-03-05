#!/bin/sh
#STATUS=`cat /opt/oracle/refresh/scripts/STATUS.txt`
#echo "waiting for export to complete" > /opt/oracle/refresh/logs/wait.log
#while [[ $STATUS -eq 1 ]]
#do
#    echo "Time Now: `date +%H:%M:%S`" >> /opt/oracle/refresh/logs/wait.log
#    echo "Sleeping for 15min" >> /opt/oracle/refresh/logs/wait.log
#    sleep 900
#    STATUS=`cat /opt/oracle/refresh/scripts/STATUS.txt`
#done
#echo "1" > /opt/oracle/refresh/scripts/STATUS.txt
#STAT=`cat /opt/oracle/refresh/scripts/STAT.txt`
#echo "waiting for export to complete" > /opt/oracle/refresh/logs/wait.log
#while [[ $STAT -eq 1 ]]
#do
#    echo "Time Now: `date +%H:%M:%S`" >> /opt/oracle/refresh/logs/wait.log
#    echo "Sleeping for 15min" >> /opt/oracle/refresh/logs/wait.log
#    sleep 900
#    STAT=`cat /opt/oracle/refresh/scripts/STAT.txt`
#done
#echo "1" > /opt/oracle/refresh/scripts/STAT.txt
export ORACLE_SID=TOMCO
export ORACLE_HOME=`egrep -i ":Y|:N" /etc/oratab |grep $ORACLE_SID | cut -d":" -f2 | grep -v "\#" | grep -v "\*"`
export PATH=$ORACLE_HOME/bin:$PATH:/usr/local/bin
datetime() { echo `date '+%a%d%b%Y %H:%M:%S'` ;}
echo =======
echo Export command
echo =======
echo $(datetime)" ORACLE_HOME="$ORACLE_HOME > /opt/oracle/refresh/logs/TOMCO_Stage_CEN_GWR_progress.log
echo $(datetime)" ORACLE_SID="$ORACLE_SID >> /opt/oracle/refresh/logs/TOMCO_Stage_CEN_GWR_progress.log
##import schemas from TOMCO-PR ##
echo $(datetime)" Droping objects in stage schemas CEN and GWR is going on " >> /opt/oracle/refresh/logs/TOMCO_Stage_CEN_GWR_progress.log
sh /opt/oracle/refresh/scripts/before_drop_objts_GWR_S_CEN_S.sh
sh /opt/oracle/refresh/scripts/drop_objts_GWR_S_CEN_S.sh
echo $(datetime)" import from TOMCO PR to stage schemas CEN and GWR is going on " >> /opt/oracle/refresh/logs/TOMCO_Stage_CEN_GWR_progress.log
impdp \'/as sysdba\' parfile=/opt/oracle/refresh/scripts/TOMCO_STAGE_CEN_GWR_imp.par
impdp \'/as sysdba\' parfile=/opt/oracle/refresh/scripts/TOMCO_STAGE_CEN_GWR_imp_seq.par
egrep -q "ORA-31693|ORA-01555|Linux-x86_64 Error|stopped|Failed|FATAL" /opt/oracle/backup/DUMP/TOMCO_Stage_ERROR_imp_CEN_GWR.log
if [ $? -ne 0 ]; then
 echo $(datetime)" import success"  >> /opt/oracle/refresh/logs/TOMCO_Stage_CEN_GWR_progress.log
else
  echo $(datetime) " import is failed, check import logfile /opt/oracle/backup/DUMP/TOMCO_Stage_ERROR_imp_CEN_GWR.log" >> /opt/oracle/refresh/logs/TOMCO_Stage_CEN_GWR_progress.log
## exit 1
fi
egrep -q "ORA-31693|ORA-01555|Linux-x86_64 Error|stopped|Failed|FATAL" /opt/oracle/backup/DUMP/TOMCO_Stage_ERROR_imp_seq_CEN_GWR.log
if [ $? -ne 0 ]; then
 echo $(datetime)" seqimport success"  >> /opt/oracle/refresh/logs/TOMCO_Stage_CEN_GWR_progress.log
else
  echo $(datetime) " seqimport is failed, check import logfile /opt/oracle/backup/DUMP/TOMCO_Stage_ERROR_imp_seq_CEN_GWR" >> /opt/oracle/refresh/logs/TOMCO_Stage_CEN_GWR_progress.log
## exit 1
fi

sqlplus / as sysdba <<EOF
spool /opt/oracle/refresh/logs/TOMCO_STAGE_CEN_GWR_sql.log
col OWNER for a15
select owner,count(*) from dba_objects where status='INVALID' group by owner;
@?/rdbms/admin/utlrp.sql
@?/rdbms/admin/utlrp.sql
@?/rdbms/admin/utlrp.sql
select owner,count(*) from dba_objects where status='INVALID' group by owner;
execute dbms_mview.refresh('"GWR602_S"."EEG_VM"','C');
execute dbms_mview.refresh('"GWR602_S"."SITE_RES_ASS"','C');
execute dbms_mview.refresh('"GWR602_S"."SITE_RES_ETI"','C');
execute dbms_mview.refresh('"GWR602_S"."EEG_VM_ART"','C');
execute dbms_mview.refresh('"CEN510_S"."EEG_VM_ART"','C');
execute dbms_mview.refresh('"CEN510_S"."SITE_RES_ETI"','C');
execute dbms_mview.refresh('"CEN510_S"."VM_ARTCOCA"','C');
execute dbms_mview.refresh('"CEN510_S"."VUE_GSOSEARCHARTICLEVLUV"','C');
execute dbms_mview.refresh('"CEN510_S"."VUE_GSOSEARCHSUPPLIERCCOM"','C');
execute dbms_mview.refresh('"CEN510_S"."SITE_RES_ASS"','C');
execute dbms_mview.refresh('"CEN510_S"."VUE_GSMSEARCHARTICLE"','C');
execute dbms_mview.refresh('"CEN510_S"."VM_QUICKSEARCHARTICLEMDMV6"','C');
execute dbms_mview.refresh('"CEN510_S"."V_TMC_CODEART_3"','C');
execute dbms_mview.refresh('"CEN510_S"."EEG_VM"','C');
@/opt/oracle/refresh/scripts/privileges_before_dropping_objects.sql
spool off
exit
EOF
echo $(datetime)" Refresh completed successfully >> stats gather is inprogress"  >> /opt/oracle/refresh/logs/TOMCO_Stage_CEN_GWR_progress.log
sqlplus / as sysdba <<EOF
spool /opt/oracle/refresh/logs/TOMCO_STAGE_CEN_GWR_stats_gather.log
EXEC DBMS_STATS.gather_schema_stats('CEN510_S', estimate_percent => DBMS_STATS.AUTO_SAMPLE_SIZE, cascade => TRUE, method_opt => 'FOR ALL COLUMNS SIZE 1');
EXEC DBMS_STATS.gather_schema_stats('GWR602_S', estimate_percent => DBMS_STATS.AUTO_SAMPLE_SIZE, cascade => TRUE, method_opt => 'FOR ALL COLUMNS SIZE 1');
spool off
exit
EOF
echo $(datetime)" Stats gather is completed"  >> /opt/oracle/refresh/logs/TOMCO_Stage_CEN_GWR_progress.log
