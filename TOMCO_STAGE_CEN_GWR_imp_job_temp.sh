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
echo $(datetime)" ORACLE_HOME="$ORACLE_HOME > /opt/oracle/refresh/logs/CEN510_S_GWR602_S_progress.log
echo $(datetime)" ORACLE_SID="$ORACLE_SID >> /opt/oracle/refresh/logs/CEN510_S_GWR602_S_progress.log
##import schemas from TOMCO-PR ##
echo $(datetime)" Droping objects in schemas CEN510_S and GWR602_S is going on " >> /opt/oracle/refresh/logs/CEN510_S_GWR602_S_progress.log
sh /opt/oracle/refresh/scripts/drop_objts_GWR_S_CEN_S.sh
echo $(datetime)" import from TOMCO PR to schemas CEN510_S and GWR602_S is going on " >> /opt/oracle/refresh/logs/CEN510_S_GWR602_S_progress.log
impdp \'/as sysdba\' parfile=/opt/oracle/refresh/scripts/CEN510_S_GWR602_S_imp.par
impdp \'/as sysdba\' parfile=/opt/oracle/refresh/scripts/seq_refresh.par
egrep -q "ORA-31693|ORA-01555|Linux-x86_64 Error|stopped|Failed|FATAL" /opt/oracle/backup/DUMP/imp_CEN510_S_GWR602_S.log
if [ $? -ne 0 ]; then
 echo $(datetime)" import success"  >> /opt/oracle/refresh/logs/CEN510_S_GWR602_S_progress.log
else
  echo $(datetime) " import is failed, check import logfile /opt/oracle/backup/DUMP/imp_CEN510_S_GWR602_S.log" >> /opt/oracle/refresh/logs/CEN510_S_GWR602_S_progress.log
## exit 1
fi
egrep -q "ORA-31693|ORA-01555|Linux-x86_64 Error|stopped|Failed|FATAL" /opt/oracle/backup/DUMP/imp_seq_CEN_S_GWR_S.log
if [ $? -ne 0 ]; then
 echo $(datetime)" seqimport success"  >> /opt/oracle/refresh/logs/CEN510_S_GWR602_S_progress.log
else
  echo $(datetime) " seqimport is failed, check import logfile /opt/oracle/backup/DUMP/imp_seq_CEN_S_GWR_S.log" >> /opt/oracle/refresh/logs/CEN510_S_GWR602_S_progress.log
## exit 1
fi
sqlplus / as sysdba <<EOF
spool /opt/oracle/refresh/logs/CEN510_S_GWR602_S_sql.log
BEGIN dbms_refresh.make('"CEN510_S"."BICEPS_PO_HEADER"',list=>'',next_date=>SYSDATE,interval=>'(SYSDATE+1/144)',implicit_destroy=>TRUE,lax=>FALSE,rollback_seg=>NULL,push_deferred_rpc=>TRUE,refresh_after_errors=>FALSE,purge_option=>1,parallelism=>0,heap_size=>0);
dbms_refresh.add(name=>'"CEN510_S"."BICEPS_PO_HEADER"',list=>'"CEN510_S"."BICEPS_PO_HEADER"',siteid=>0,export_db=>'TOMCO');
END;
/
BEGIN
dbms_refresh.make('"CEN510_S"."BICEPS_PO_DETAIL"',list=>null,next_date=>SYSDATE,interval=>'(SYSDATE+1/144)',implicit_destroy=>TRUE,lax=>FALSE,rollback_seg=>NULL,push_deferred_rpc=>TRUE,refresh_after_errors=>FALSE,purge_option=>1,parallelism=>0,heap_size=>0);
dbms_refresh.add(name=>'"CEN510_S"."BICEPS_PO_DETAIL"',list=>'"CEN510_S"."BICEPS_PO_DETAIL"',siteid=>0,export_db=>'TOMCO');
END;
/
BEGIN dbms_refresh.make('"GWR602_S"."ALX_TURN_PROMO_FORWARDBUY_PO_MV"',list=>null,next_date=>SYSDATE,interval=>'(SYSDATE+1/144)',implicit_destroy=>TRUE,lax=>FALSE,job=>0,rollback_seg=>NULL,push_deferred_rpc=>TRUE,refresh_after_errors=>FALSE,purge_option=>1,parallelism=>0,heap_size=>0);
dbms_refresh.add(name=>'"GWR602_S"."ALX_TURN_PROMO_FORWARDBUY_PO_MV"',list=>'"GWR602_S"."ALX_TURN_PROMO_FORWARDBUY_PO_MV"',siteid=>0,export_db=>'TOMCO');
END;
/
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
EXEC DBMS_STATS.gather_schema_stats('CEN510_S', estimate_percent => DBMS_STATS.AUTO_SAMPLE_SIZE, cascade => TRUE, method_opt => 'FOR ALL COLUMNS SIZE 1');
EXEC DBMS_STATS.gather_schema_stats('GWR602_S', estimate_percent => DBMS_STATS.AUTO_SAMPLE_SIZE, cascade => TRUE, method_opt => 'FOR ALL COLUMNS SIZE 1');
spool off
exit
EOF

