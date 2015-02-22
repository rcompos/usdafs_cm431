--
--
-- Licensed Materials - Property of IBM
--
-- 5698-INV
--
-- (C) Copyright IBM Corp. 2002, 2005 All Rights Reserved
--
-- US Government Users Restricted Rights - Use, duplication or
-- disclosure restricted by GSA ADP Schedule Contract with
-- IBM Corp
--
--
-- inv_ora_schema_423_FP06.sql
--
-- This script is to upgrade a CM 4.2.3 installation.
-- Use inv_ora_schema.sql script for a fresh install.
--

---------------------------------------------------------------------

-- spool inv_ora_schema_423_FP06.log;
spool fs_inv_ora_schema_423_FP06.log;

CREATE TABLE INST_PARTITION_MB (
       COMPUTER_SYS_ID      VARCHAR2(64)  NOT NULL,
       FS_ACCESS_POINT      VARCHAR2(191) NOT NULL,
       DEV_NAME             VARCHAR2(64),
       PARTITION_TYPE       VARCHAR2(32),
       MEDIA_TYPE           VARCHAR2(32),
       PHYSICAL_SIZE_MB     INTEGER,
       FS_TYPE              VARCHAR2(32),
       FS_MOUNT_POINT       VARCHAR2(254),
       FS_TOTAL_SIZE_MB     INTEGER,
       FS_FREE_SIZE_MB      INTEGER,
       RECORD_TIME          DATE          DEFAULT SYSDATE,
         CONSTRAINT INSTPARTITIONMB_PK PRIMARY KEY(COMPUTER_SYS_ID,FS_ACCESS_POINT),
         CONSTRAINT INSTPARTITIONMB_FK FOREIGN KEY(COMPUTER_SYS_ID)
           REFERENCES COMPUTER(COMPUTER_SYS_ID))
;
CREATE OR REPLACE TRIGGER INSTPARTITIONMB_TR
       BEFORE UPDATE ON INST_PARTITION_MB
       FOR EACH ROW
       BEGIN
         :NEW.RECORD_TIME := SYSDATE;
       END;
/

create or replace view PARTITION_MB_VIEW
as
select
    COMPUTER.TME_OBJECT_LABEL,
    COMPUTER.TME_OBJECT_ID,
    INST_PARTITION_MB.COMPUTER_SYS_ID,
    INST_PARTITION_MB.FS_ACCESS_POINT,
    INST_PARTITION_MB.DEV_NAME,
    INST_PARTITION_MB.PARTITION_TYPE,
    INST_PARTITION_MB.MEDIA_TYPE,
    INST_PARTITION_MB.PHYSICAL_SIZE_MB,
    INST_PARTITION_MB.FS_TYPE,
    INST_PARTITION_MB.FS_MOUNT_POINT,
    INST_PARTITION_MB.FS_TOTAL_SIZE_MB,
    INST_PARTITION_MB.FS_FREE_SIZE_MB,
    to_char(INST_PARTITION_MB.RECORD_TIME,'YYYY.MM.DD HH24:MI:SS') as RECORD_TIME
from
    INST_PARTITION_MB,COMPUTER
where
    INST_PARTITION_MB.COMPUTER_SYS_ID = COMPUTER.COMPUTER_SYS_ID
;

insert into QUERY_VIEWS (VIEW_NAME) values ('PARTITION_MB_VIEW')
;

insert into INVENTORY_TABLES(TABLE_NAME) values ('INST_PARTITION_MB')
;

insert into SCHEMA_VERS values ('CM 4.2.3', SYSDATE, 'PATCH',
            'inv_ora_schema_423_FP06.sql', 'FP06 applied to existing installation')
;

commit;


spool off;

exit;

