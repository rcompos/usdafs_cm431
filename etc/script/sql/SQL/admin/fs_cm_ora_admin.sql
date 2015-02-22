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
-- cm_ora_admin.sql
--

-- PRECONDITION: The default 'cm_db' database is created with the statement
--		'create database cm_db'.
-- Execute this SQL file as Oracle RDBMS user "sys":
-- sqlplus "sys/<password>@<database> as sysdba" @cm_ora_schema.sql
--

-- spool cm_ora_admin.log
spool fs_cm_ora_admin.log

-- initialize tablespaces for cm_db
create tablespace cm_ts
  datafile 'cm_ts.dbf' size 1408M
  default storage (
  initial 100K
  next 50K
  minextents 2)
  online;
commit;

create temporary tablespace cm_temp_ts
  tempfile 'cm_temp_ts.dbf' size 128M
  autoextend on
  next 512K
  maxsize 256M;
commit;

-- add user invtiv for inventory
create user invtiv
  identified by tivoli
  default tablespace cm_ts
  temporary tablespace cm_temp_ts
  quota unlimited on cm_ts;
commit;

GRANT CONNECT,RESOURCE,UNLIMITED TABLESPACE TO
  invtiv identified by tivoli;

-- add user planner for planner
create user planner
  identified by planner
  default tablespace cm_ts
  temporary tablespace cm_temp_ts
  quota unlimited on cm_ts;
commit;

GRANT CONNECT,RESOURCE,UNLIMITED TABLESPACE TO
  planner identified by planner;

-- add user tivoli for ccm
create user tivoli
  identified by tivoli
  default tablespace cm_ts
  temporary tablespace cm_temp_ts
  quota unlimited on cm_ts;
commit;

GRANT CONNECT,RESOURCE,UNLIMITED TABLESPACE TO
  tivoli identified by tivoli;

-- add user mdstatus for mdist2
create user mdstatus
  identified by mdstatus
  default tablespace cm_ts
  temporary tablespace cm_temp_ts
  quota unlimited on cm_ts;
commit;

GRANT CONNECT,RESOURCE,UNLIMITED TABLESPACE TO
  mdstatus identified by mdstatus;

GRANT CREATE SYNONYM TO
  invtiv identified by tivoli;
commit;

GRANT CREATE VIEW TO invtiv identified by tivoli;
commit;

spool off;

exit;
