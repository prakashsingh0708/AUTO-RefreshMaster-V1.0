#!/bin/sh
export ORACLE_HOME=/opt/oracle/product/dbhome19c
export PATH=$ORACLE_HOME/bin:$PATH:/usr/local/bin
export ORACLE_SID=TOMCO
sqlplus / as sysdba <<EOF
set pages 10000
set echo off
set head off
spool /opt/oracle/refresh/scripts/privileges_before_dropping_objects.sql  
select 'grant ' || PRIVILEGE || ' on ' || OWNER || '.' || TABLE_NAME ||' to ' || grantee || ' ;' from  dba_tab_privs where owner in ('CEN510_S','GWR602_S');
spool off; 
exit
EOF

