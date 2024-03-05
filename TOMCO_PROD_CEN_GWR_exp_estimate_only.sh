#!/bin/sh

datetime() { echo `date '+%a%d%b%Y %H:%M:%S'` ;}

source /opt/oracle/refresh/scripts/env/cred_oracle

#echo "1" > /opt/oracle/refresh/scripts/STATUS.txt
export ORACLE_SID=TOMCO
export ORACLE_HOME=`egrep -i ":Y|:N" /etc/oratab |grep $ORACLE_SID | cut -d":" -f2 | grep -v "\#" | grep -v "\*"`
export PATH=$ORACLE_HOME/bin:$PATH
#datetime() { echo `date '+%a%d%b%Y %H:%M:%S'` ;}
expdp \'/as sysdba\' parfile=/opt/oracle/refresh/scripts/TOMCO_PROD_CEN_GWR_exp_estimate_only.par
EOF
