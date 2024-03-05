#!/bin/sh
export ORACLE_HOME=/opt/oracle/product/dbhome19c
export PATH=$ORACLE_HOME/bin:$PATH:/usr/local/bin
export ORACLE_SID=TOMCO
sqlplus / as sysdba <<EOF
set pages 10000
set echo off
set head off
spool /opt/oracle/refresh/scripts/drop_objts_CEN_S_GWR_S.sql
select 'drop '||object_type||' '||owner||'.'||object_name|| DECODE(OBJECT_TYPE,'TABLE',' CASCADE CONSTRAINTS','') || ';' from dba_objects where owner in('CEN510_S','GWR602_S');
spool off
@/opt/oracle/refresh/scripts/drop_objts_CEN_S_GWR_S.sql
spool /opt/oracle/refresh/scripts/drop_objts_CEN_S_GWR_S.sql
select 'drop '||object_type||' '||owner||'.'||object_name|| DECODE(OBJECT_TYPE,'TABLE',' CASCADE CONSTRAINTS','') || ';' from dba_objects where owner in('CEN510_S','GWR602_S');
spool off
@/opt/oracle/refresh/scripts/drop_objts_CEN_S_GWR_S.sql
spool /opt/oracle/refresh/scripts/drop_objts_CEN_S_GWR_S.sql
select 'drop '||object_type||' '||owner||'.'||object_name|| DECODE(OBJECT_TYPE,'TABLE',' CASCADE CONSTRAINTS','') || ';' from dba_objects where owner in('CEN510_S','GWR602_S');
spool off
@/opt/oracle/refresh/scripts/drop_objts_CEN_S_GWR_S.sql
spool /opt/oracle/refresh/scripts/drop_objts_CEN_S_GWR_S.sql
select 'drop '||object_type||' '||owner||'.'||object_name||';' from dba_objects where owner in('CEN510_S','GWR602_S');
spool off
@/opt/oracle/refresh/scripts/drop_objts_CEN_S_GWR_S.sql
spool /opt/oracle/refresh/logs/del_gwr_s_cen_s_b.log
@/opt/oracle/refresh/scripts/drop_objts_CEN_S_GWR_S.sql
spool /opt/oracle/refresh/logs/del_gwr_s_cen_s_b.log
@/opt/oracle/refresh/scripts/drop_objts_CEN_S_GWR_S.sql
spool /opt/oracle/refresh/logs/del_gwr_s_cen_s_b.log
@/opt/oracle/refresh/scripts/drop_objts_CEN_S_GWR_S.sql
spool off
exit
EOF

