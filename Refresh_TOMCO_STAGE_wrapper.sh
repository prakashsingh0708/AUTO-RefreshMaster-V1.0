#! /bin/bash

chmod +x /opt/oracle/refresh/scripts/env/cred_oracle
source /opt/oracle/refresh/scripts/env/cred_oracle

chmod +x /opt/oracle/refresh/scripts/*.sh

################## OLD RSYNC method which replace the files after checking it############################
#sshpass -p "$ORACLE_PASSWORD" rsync /opt/oracle/refresh/scripts/env/cred_oracle oracle@10.245.93.68:/opt/oracle/refresh/scripts/env/

#sshpass -p "$ORACLE_PASSWORD" rsync /opt/oracle/refresh/scripts/TOMCO_PROD_CEN_GWR_exp* oracle@10.245.93.68:/opt/oracle/refresh/scripts/

################## RSYNC Method which will replace the files without checking #############

rsync -av --delete-before -c --checksum  -e "sshpass -p '$ORACLE_PASSWORD' ssh" /opt/oracle/refresh/scripts/env/cred_oracle oracle@10.245.93.68:/opt/oracle/refresh/scripts/env/

rsync -av --delete-before -c --checksum  -e "sshpass -p '$ORACLE_PASSWORD' ssh" /opt/oracle/refresh/scripts/TOMCO_PROD_CEN_GWR_exp* oracle@10.245.93.68:/opt/oracle/refresh/scripts/

sshpass -p "$ORACLE_PASSWORD"  ssh oracle@10.245.93.68 "chmod +x /opt/oracle/refresh/scripts/env/cred_oracle"

sshpass -p "$ORACLE_PASSWORD"  ssh oracle@10.245.93.68 "chmod +x /opt/oracle/refresh/scripts/TOMCO_PROD_CEN_GWR_exp*" 

sshpass -p "$ORACLE_PASSWORD" ssh oracle@10.245.93.68 "sh /opt/oracle/refresh/scripts/TOMCO_PROD_CEN_GWR_exp_estimate_only.sh" &

sh /opt/oracle/refresh/scripts/TOMCO_STAGE_CEN_GWR_exp_estimate_only.sh

sshpass -p "$ORACLE_PASSWORD" ssh oracle@10.245.93.68 "sh /opt/oracle/refresh/scripts/TOMCO_PROD_CEN_GWR_exp_job.sh" &
prod_exp_pid=$!

#####################commented below as it stage export and import job will be bound on main wrapper file################
###sh /opt/oracle/refresh/scripts/script_stage.sh &

sh /opt/oracle/refresh/scripts/TOMCO_STAGE_CEN_GWR_exp_job.sh
stage_exp_pid=$!
wait $prod_exp_pid
wait $stage_exp_pid
sh /opt/oracle/refresh/scripts/TOMCO_STAGE_CEN_GWR_imp_job.sh

EOF

