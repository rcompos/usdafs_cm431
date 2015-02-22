--  %Z%%M%    %I%  %W%  %G%  %U%
--
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
-- mdist_ora_admin.sql
--

-- Execute this SQL file as Oracle RDBMS user "sys":
-- sqlplus "sys/<password>@<database> as sysdba" @mdist_ora_schema.sql
--

-- spool mdist_ora_admin.log
spool fs_mdist_ora_admin.log


-- initialize a tablespace for mdist2
create tablespace mdist2_ts
  datafile 'mdist2_ts.dbf' size 128M
  default storage (
  initial 100K
  next 50K
  minextents 2)
  online;
commit;

create temporary tablespace mdist2_temp_ts
  tempfile 'mdist2_temp_ts.dbf' size 10M
  autoextend on
  next 512K
  maxsize 128M;
commit;

-- add user mdstatus for mdist2
create user mdstatus
  identified by mdstatus
  default tablespace mdist2_ts
  temporary tablespace mdist2_temp_ts
  quota unlimited on mdist2_ts;
commit;

GRANT CONNECT,RESOURCE,UNLIMITED TABLESPACE TO
  mdstatus identified by mdstatus;
commit;

spool off;

exit;

