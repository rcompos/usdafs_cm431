-- Licensed Materials - Property of IBM
--
-- 5698-INV
--
-- (C) Copyright IBM Corp. 2002, 2002 All Rights Reserved
--
-- US Government Users Restricted Rights - Use, duplication or
-- disclosure restricted by GSA ADP Schedule Contract with
-- IBM Corp
--
--
-- pristine_ora_admin.sql
--

-- PRECONDITION: The default 'pristine' database is created with the statement
--		'create database pristine'.
-- Execute this SQL file as Oracle RDBMS user "sys":
-- sqlplus "sys/<password>@<database> as sysdba" @pristine_ora_schema.sql
--

-- spool pristine_ora_admin.log
spool fs_pristine_ora_admin.log

-- initialize a tablespace for pristine
create tablespace pristine_ts
  datafile 'pristine_ts.dbf' size 128M
  default storage (
  initial 100K
  next 50K
  minextents 2)
  online;
commit;

-- add user pristine for pristine
create user pristine
  identified by pristine
  default tablespace pristine_ts
  quota unlimited on pristine_ts;
commit;

GRANT CONNECT,RESOURCE,UNLIMITED TABLESPACE TO
  pristine identified by pristine;
commit;

spool off;

exit;

