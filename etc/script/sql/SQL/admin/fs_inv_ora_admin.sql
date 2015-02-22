--
-- Licensed Materials - Property of IBM
--
-- 5698-INV
--
-- (C) Copyright IBM Corp. 2002, 2003 All Rights Reserved
--
-- US Government Users Restricted Rights - Use, duplication or
-- disclosure restricted by GSA ADP Schedule Contract with
-- IBM Corp
--
--
-- inv_ora_admin.sql
--

-- PRECONDITION: The default 'inv_db' database is created with the statement
--		'create database inv_db'.
-- Execute this SQL file as Oracle RDBMS user "sys":
-- sqlplus "sys/<password>@<database> as sysdba" @inv_ora_schema.sql
--

-- spool inv_ora_admin.log
spool fs_inv_ora_admin.log

-- initialize a tablespace for inventory
create tablespace inv_ts
  datafile 'inv_ts.dbf' size 1024M
  default storage (
  initial 100K
  next 50K
  minextents 2)
  online;
commit;

create temporary tablespace inv_temp_ts
  tempfile 'inv_temp_ts.dbf' size 128M
  autoextend on
  next 512K
  maxsize 256M;
commit;

-- add user invtiv for inventory
create user invtiv
  identified by tivoli
  default tablespace inv_ts
  temporary tablespace inv_temp_ts
  quota unlimited on inv_ts;
commit;

GRANT CONNECT,RESOURCE,UNLIMITED TABLESPACE TO
  invtiv identified by tivoli;
commit;

GRANT CREATE SYNONYM TO 
  invtiv identified by tivoli;
commit;

GRANT CREATE VIEW TO invtiv identified by tivoli;
commit;

spool off;

exit;

