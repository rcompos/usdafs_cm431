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
-- ccm_ora_admin.sql
--

-- PRECONDITION: The default 'ccm' database is created with the statement
--		'create database ccm'.
-- Execute this SQL file as Oracle RDBMS user "sys":
-- sqlplus "sys/<password>@<database> as sysdba" @ccm_ora_schema.sql
--

-- spool ccm_ora_admin.log
spool fs_ccm_ora_admin.log

-- initialize a tablespace for ccm
create tablespace ccm_ts
  datafile 'ccm_ts.dbf' size 128M
  default storage (
  initial 100K
  next 50K
  minextents 2)
  online;
commit;

-- add user tivoli for ccm
create user tivoli
  identified by tivoli
  default tablespace ccm_ts
  quota unlimited on ccm_ts;
commit;

GRANT CONNECT,RESOURCE,UNLIMITED TABLESPACE TO
  tivoli identified by tivoli;
commit;

spool off;

exit;

