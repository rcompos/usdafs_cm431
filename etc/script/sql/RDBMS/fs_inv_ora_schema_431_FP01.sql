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
-- This script is to upgrade a 4.3.1
-- Use inv_ora_schema.sql script for a fresh install.
--

-- spool inv_ora_schema_431_FP01.log;
spool fs_inv_ora_schema_431_FP01.log;

-- DROP TABLE T_MOUSE;
CREATE GLOBAL TEMPORARY TABLE T_MOUSE (
       MOUSE_ID             VARCHAR2(32)  NOT NULL,
       MOUSE_MODEL          VARCHAR2(64),
       MOUSE_TYPE           VARCHAR2(32),
       BUTTONS              INTEGER)
       ON COMMIT DELETE ROWS
;

-- DROP TABLE T_PRINTER;
CREATE GLOBAL TEMPORARY TABLE T_PRINTER (
       PRINTER_ID           VARCHAR2(32)  NOT NULL,
       PRINTER_MODEL        VARCHAR2(128))
       ON COMMIT DELETE ROWS
;


alter table COMPUTER modify (OS_SUB_VERS varchar2(64));

alter table MSWARE_DESC ADD ACCESSED_TIME DATE;


create or replace view INST_SWARE_VIEW
as
select
    COMPUTER.TME_OBJECT_LABEL,
    COMPUTER.TME_OBJECT_ID,
    COMPUTER.COMPUTER_SYS_ID,
    SIGNATURE.DESCRIPTION as SWARE_DESC,
    SIGNATURE.VERSION as SWARE_VERS,
    SIGNATURE.NAME as SWARE_NAME,
    SIGNATURE.FILE_SIZE as SWARE_SIZE,
    MSWARE_DESC.SWARE_SIG_PATH,
    to_char(MSWARE_DESC.ACCESSED_TIME,'YYYY.MM.DD HH24:MI:SS') as ACCESSED_TIME,
    to_char(MATCHED_SWARE.RECORD_TIME,'YYYY.MM.DD HH24:MI:SS') as RECORD_TIME
from
    MATCHED_SWARE
        JOIN COMPUTER ON
          MATCHED_SWARE.COMPUTER_SYS_ID = COMPUTER.COMPUTER_SYS_ID
        JOIN SIGNATURE ON
          MATCHED_SWARE.SWARE_SIG_ID = SIGNATURE.ID
        LEFT JOIN MSWARE_DESC ON
          MATCHED_SWARE.COMPUTER_SYS_ID = MSWARE_DESC.COMPUTER_SYS_ID and
          MATCHED_SWARE.SWARE_SIG_ID = MSWARE_DESC.SWARE_SIG_ID and
          MATCHED_SWARE.MD5_ID = MSWARE_DESC.MD5_ID
where
    SIGNATURE.ENABLED = 1
;

create or replace view INVENTORYDATA
as
select distinct
    COMPUTER.TME_OBJECT_LABEL,
    COMPUTER.TME_OBJECT_ID,
    COMPUTER.COMPUTER_SYS_ID,
    COMPUTER.COMPUTER_MODEL,
    COMPUTER.COMPUTER_ALIAS,
    COMPUTER.SYS_SER_NUM,
    COMPUTER_SYS_MEM.PHYSICAL_TOTAL_KB,
    COMPUTER_SYS_MEM.PHYSICAL_FREE_KB,
    COMPUTER_SYS_MEM.TOTAL_PAGES,
    COMPUTER_SYS_MEM.FREE_PAGES,
    COMPUTER_SYS_MEM.PAGE_SIZE,
    COMPUTER_SYS_MEM.VIRT_TOTAL_KB,
    COMPUTER_SYS_MEM.VIRT_FREE_KB,
    PHYSICAL_PROCESSOR.FAMILY as PROCESSOR_MODEL,
    PHYSICAL_PROCESSOR.CPU_FREQ AS PROCESSOR_SPEED,
    COMPUTER.OS_NAME,
    COMPUTER.OS_TYPE,
    to_char(COMPUTER.COMPUTER_SCANTIME,'YYYY.MM.DD HH24:MI:SS') as COMPUTER_SCANTIME
from
    COMPUTER,COMPUTER_SYS_MEM,PHYSICAL_PROCESSOR
where
    COMPUTER_SYS_MEM.COMPUTER_SYS_ID = COMPUTER.COMPUTER_SYS_ID
and
     PHYSICAL_PROCESSOR.COMPUTER_SYS_ID = COMPUTER.COMPUTER_SYS_ID
;

insert into SCHEMA_VERS values ('Inventory 4.3.1', SYSDATE, 'PATCH', 'inv_ora_schema_431_FP01.sql', 'FP01 applied to existing installation');
commit;

spool off;

exit;
