--  %Z%%M%    %I%  %W%  %G%  %U%
--
-- Licensed Materials - Property of IBM
--
-- 5698-INV
--
-- (C) Copyright IBM Corp. 2002, 2008 All Rights Reserved
--
-- US Government Users Restricted Rights - Use, duplication or
-- disclosure restricted by GSA ADP Schedule Contract with
-- IBM Corp
--
--
-- apm_ora_admin.sql
--

-- PRECONDITION: The default 'planner' database is created with the statement
--		'create database planner'.
-- Execute this SQL file as Oracle RDBMS user "sys":
-- sqlplus "sys/<password>@<database> as sysdba" @apm_ora_schema.sql
--

-- spool apm_ora_admin.log
spool fs_apm_ora_admin.log

-- initialize a tablespace for planner
-- size is 128MB
create tablespace planner_ts
  datafile 'planner_ts.dbf' size 128M
  default storage (
  initial 100K
  next 50K
  minextents 2)
  online;
commit;

-- add user planner for planner
create user planner
  identified by planner
  default tablespace planner_ts
  quota unlimited on planner_ts;
commit;

GRANT CONNECT,RESOURCE,UNLIMITED TABLESPACE TO
  planner identified by planner;
commit;

GRANT CREATE VIEW TO
  planner identified by planner;
commit;

spool off;

exit;

