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
--
-- This script is to upgrade a 4.2.3
-- Use inv_ora_schema.sql script for a fresh install.
--

-- spool inv_ora_schema_423_FP08.log;
spool fs_inv_ora_schema_423_FP08.log;


alter table COMPUTER modify (OS_SUB_VERS varchar2(64));

insert into SCHEMA_VERS values ('Inventory 4.2.3', SYSDATE, 'PATCH', 'inv_ora_schema_423_FP08.sql', 'FP08 applied to existing installation');

commit;

spool off;

exit;
