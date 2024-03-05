#!/bin/sh
export ORACLE_HOME=/opt/oracle/product/dbhome19c
export PATH=$ORACLE_HOME/bin:$PATH:/usr/local/bin
export ORACLE_SID=TOMCO
sqlplus / as sysdba <<EOF
set pages 10000
set echo off
set head off
spool /opt/oracle/refresh/scripts/drop_objts_CEN_S_GWR_S.sql
select 'drop '||object_type||' '||owner||'.'||object_name|| DECODE(OBJECT_TYPE,'TABLE',' CASCADE CONSTRAINTS','') || ';' from dba_objects where owner in('CEN510_S','GWR602_S') and object_name not in ('ADM_USERS','ADM_PROFILES','SECUSERPRO','PARTABLES','TRA_PARTABLES','PARPOSTES','TRA_PARPOSTES','PARSCOPES','ADM_USERS_I1','TRA_PARPOSTES_PK','TRA_PARPOSTES_I1','TRA_PARTABLES_PK',
'SECUSERPRO_PK','PARPOSTES_PK','PARSCOPES_I1','PARSCOPES_PK','PARTABLES_PK','ADM_PROFILES_PK','ADM_USERS_PK');
spool off
@/opt/oracle/refresh/scripts/drop_objts_CEN_S_GWR_S.sql
spool /opt/oracle/refresh/scripts/drop_objts_CEN_S_GWR_S.sql
select 'drop '||object_type||' '||owner||'.'||object_name|| DECODE(OBJECT_TYPE,'TABLE',' CASCADE CONSTRAINTS','') || ';' from dba_objects where owner in('CEN510_S','GWR602_S') and object_name not in ('ADM_USERS','ADM_PROFILES','SECUSERPRO','PARTABLES','TRA_PARTABLES','PARPOSTES','TRA_PARPOSTES','PARSCOPES','ADM_USERS_I1','TRA_PARPOSTES_PK','TRA_PARPOSTES_I1','TRA_PARTABLES_PK',
'SECUSERPRO_PK','PARPOSTES_PK','PARSCOPES_I1','PARSCOPES_PK','PARTABLES_PK','ADM_PROFILES_PK','ADM_USERS_PK');
spool off
@/opt/oracle/refresh/scripts/drop_objts_CEN_S_GWR_S.sql
spool /opt/oracle/refresh/scripts/drop_objts_CEN_S_GWR_S.sql
select 'drop '||object_type||' '||owner||'.'||object_name|| DECODE(OBJECT_TYPE,'TABLE',' CASCADE CONSTRAINTS','') || ';' from dba_objects where owner in('CEN510_S','GWR602_S') and object_name not in ('ADM_USERS','ADM_PROFILES','SECUSERPRO','PARTABLES','TRA_PARTABLES','PARPOSTES','TRA_PARPOSTES','PARSCOPES','ADM_USERS_I1','TRA_PARPOSTES_PK','TRA_PARPOSTES_I1','TRA_PARTABLES_PK',
'SECUSERPRO_PK','PARPOSTES_PK','PARSCOPES_I1','PARSCOPES_PK','PARTABLES_PK','ADM_PROFILES_PK','ADM_USERS_PK');
spool off
@/opt/oracle/refresh/scripts/drop_objts_CEN_S_GWR_S.sql
spool /opt/oracle/refresh/scripts/drop_objts_CEN_S_GWR_S.sql
select 'drop '||object_type||' '||owner||'.'||object_name||';' from dba_objects where owner in('CEN510_S','GWR602_S') and object_name not in ('ADM_USERS','ADM_PROFILES','SECUSERPRO','PARTABLES','TRA_PARTABLES','PARPOSTES','TRA_PARPOSTES','PARSCOPES','ADM_USERS_I1','TRA_PARPOSTES_PK','TRA_PARPOSTES_I1','TRA_PARTABLES_PK',
'SECUSERPRO_PK','PARPOSTES_PK','PARSCOPES_I1','PARSCOPES_PK','PARTABLES_PK','ADM_PROFILES_PK','ADM_USERS_PK');
spool off
@/opt/oracle/refresh/scripts/drop_objts_CEN_S_GWR_S.sql
spool /opt/oracle/refresh/logs/del_gwr_s_cen_s_b.log
@/opt/oracle/refresh/scripts/drop_objts_CEN_S_GWR_S.sql
spool off
exit
EOF

