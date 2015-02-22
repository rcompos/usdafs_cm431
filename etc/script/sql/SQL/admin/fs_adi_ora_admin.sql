--
-- Licensed Materials - Property of IBM
-- 5698-SWD
-- (C)IBM Corp. 2006 All Rights Reserved
-- US Government Users Restricted Rights - Use, duplication or
-- disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
--
-- adi_ora_admin.sql
--

-- PRECONDITION: The default 'ad_db' database is created with the statement
--		'create database ad_db'.
-- Execute this SQL file as Oracle RDBMS user "sys":
-- sqlplus "sys/<password>@<database> as sysdba" @adi_ora_admin.sql
--

-- spool ad_ora_admin.log
spool fs_ad_ora_admin.log

-- initialize tablespaces for ad_db
create tablespace ad_ts
  datafile 'ad_ts.dbf' size 1408M
  default storage (
  initial 100K
  next 50K
  minextents 2)
  online;
commit;

-- add user ad_user for ADIEngine
create user ad_user
  identified by tivoli
  default tablespace ad_ts
  quota unlimited on ad_ts;
commit;

GRANT CONNECT,RESOURCE,UNLIMITED TABLESPACE TO
  ad_user identified by tivoli;
commit;

spool off;

exit;

