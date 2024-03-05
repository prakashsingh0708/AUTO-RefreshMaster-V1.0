#! /bin/bash

source /opt/oracle/refresh/scripts/env/cred_oracle


sshpass -p "$ORACLE_PASSWORD" scp -o StrictHostKeyChecking=yes /opt/oracle/refresh/scripts/TOMCO_PROD_CEN_GWR_exp* oracle@10.245.93.68:/opt/oracle/refresh/scripts/TEMP/

sshpass -p "$ORACLE_PASSWORD"  ssh oracle@10.245.93.68 "chmod +x /opt/oracle/refresh/scripts/TEMP/TOMCO_PROD_CEN_GWR_exp*"

#ssh oracle@10.245.93.68 "sh /opt/oracle/refresh/scripts/TOMCO_PROD_CEN_GWR_exp_job.sh" &

#####ssh 10.245.93.68 "sh /opt/oracle/refresh/scripts/script_stage.sh" &

#sh /opt/oracle/refresh/scripts/script_stage.sh &

#EOF

