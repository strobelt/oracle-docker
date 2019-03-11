FROM store/oracle/database-enterprise:12.2.0.1
COPY shellScripts/setupDB.sh /home/oracle/setup/
COPY shellScripts/runInitialScripts.sh /home/oracle/setup/
