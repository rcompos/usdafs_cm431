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
-- inv_ora_schema_423_FP04.sql
--
-- This script is to upgrade a CM 4.2.3 installation.
-- Use inv_ora_schema.sql script for a fresh install.
--

---------------------------------------------------------------------

-- spool inv_ora_schema_423_FP04.log;
spool fs_inv_ora_schema_423_FP04.log;

DROP TABLE INST_SERVICE_INFO;
DROP TABLE SERVICE_INFO;
CREATE TABLE INST_SERVICE_INFO (
       COMPUTER_SYS_ID      VARCHAR(64)   NOT NULL,
       SNAME                VARCHAR(128)  NOT NULL,
       DNAME             VARCHAR(64),
       SDESC             VARCHAR(256),
       SPATH_NAME        VARCHAR(128),
       STYPE             VARCHAR(64),
       SSTARTED          VARCHAR(16),
       SSTART_MODE       VARCHAR(16),
       SDISPLAY_NAME     VARCHAR(64),
       SSTATE            VARCHAR(16),
       SSTATUS           VARCHAR(16),
       RECORD_TIME          DATE          DEFAULT SYSDATE,
         CONSTRAINT INSTSERVICE_PK PRIMARY KEY(COMPUTER_SYS_ID,SNAME),
         CONSTRAINT INSTSERVICE_FK FOREIGN KEY(COMPUTER_SYS_ID)
           REFERENCES COMPUTER(COMPUTER_SYS_ID))
;

CREATE OR REPLACE TRIGGER INST_SINFO_TR
       BEFORE UPDATE ON INST_SERVICE_INFO
       FOR EACH ROW
       BEGIN
         :NEW.RECORD_TIME := SYSDATE;
       END;
/



create or replace view SERVICE_INFO_VIEW
as
select
    COMPUTER.TME_OBJECT_LABEL,
    COMPUTER.TME_OBJECT_ID,
    COMPUTER.COMPUTER_SYS_ID,
    INST_SERVICE_INFO.SNAME,                      
    INST_SERVICE_INFO.DNAME,                       
    INST_SERVICE_INFO.SDESC,                       
    INST_SERVICE_INFO.STYPE,                      
    INST_SERVICE_INFO.SSTART_MODE,                
    INST_SERVICE_INFO.SDISPLAY_NAME,              
    INST_SERVICE_INFO.SSTATE,                     
    INST_SERVICE_INFO.SSTATUS,                    
    to_char(INST_SERVICE_INFO.RECORD_TIME,'YYYY.MM.DD HH24:MI:SS') as RECORD_TIME
from
    INST_SERVICE_INFO,COMPUTER
where
    INST_SERVICE_INFO.COMPUTER_SYS_ID = COMPUTER.COMPUTER_SYS_ID
;


create or replace view MATCH_SWARE_VIEW
as
select
    COMPUTER.TME_OBJECT_LABEL,
    COMPUTER.TME_OBJECT_ID,
    COMPUTER.COMPUTER_SYS_ID,
    SIGNATURE.DESCRIPTION as SWARE_DESC,
    SIGNATURE.VERSION as SWARE_VERS,
    SIGNATURE.NAME as SWARE_NAME,
    SIGNATURE.FILE_SIZE as SWARE_SIZE,
    to_char(UNMATCHED_FILES.RECORD_TIME,'YYYY.MM.DD HH24:MI:SS') as RECORD_TIME
from
    SIGNATURE, UNMATCHED_FILES, COMPUTER, SWARE_SIG_MAP
where
    UNMATCHED_FILES.COMPUTER_SYS_ID = COMPUTER.COMPUTER_SYS_ID
and
    SIGNATURE.ID = SWARE_SIG_MAP.ID
and
    SWARE_SIG_MAP.FILE_DESC_ID = UNMATCHED_FILES.FILE_DESC_ID
and
    SIGNATURE.ENABLED = 1
;


drop table MATCHED_SWARE; 
CREATE TABLE MATCHED_SWARE (
       COMPUTER_SYS_ID      VARCHAR2(64)    NOT NULL,
       SWARE_SIG_ID         integer         NOT NULL,
       MD5_ID               VARCHAR2(128)   NOT NULL,
       RECORD_TIME          DATE            DEFAULT SYSDATE,
         CONSTRAINT MATCHEDSWARE_PK PRIMARY KEY(COMPUTER_SYS_ID,SWARE_SIG_ID,MD5_ID),
         CONSTRAINT MATCHEDSWARE_FK FOREIGN KEY(COMPUTER_SYS_ID)
           REFERENCES COMPUTER(COMPUTER_SYS_ID))
;

CREATE OR REPLACE TRIGGER MATCHEDSWARE_TR
       BEFORE UPDATE ON MATCHED_SWARE
       FOR EACH ROW
       BEGIN
         :NEW.RECORD_TIME := SYSDATE;
       END;
/

insert into MATCHED_SWARE
(
         COMPUTER_SYS_ID,
         SWARE_SIG_ID,
         MD5_ID
)
select   COMPUTER_SYS_ID,
         SWARE_SIG_ID,
         MD5_ID
from    MSWARE_DESC
;

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

create or replace view MIGR_SWARE_VIEW
as
select
    COMPUTER.TME_OBJECT_LABEL,
    COMPUTER.TME_OBJECT_ID,
    COMPUTER.COMPUTER_SYS_ID,
    SIGNATURE.DESCRIPTION as SWARE_DESC,
    SIGNATURE.VERSION as SWARE_VERS,
    SIGNATURE.NAME as SWARE_NAME,
    SIGNATURE.FILE_SIZE as SWARE_SIZE,
    to_char(MATCHED_SWARE.RECORD_TIME,'YYYY.MM.DD HH24:MI:SS') as RECORD_TIME
from
    MATCHED_SWARE,SWARE_SIG_MAP, SIGNATURE,COMPUTER
where
    MATCHED_SWARE.COMPUTER_SYS_ID = COMPUTER.COMPUTER_SYS_ID
and    
    MATCHED_SWARE.SWARE_SIG_ID = SWARE_SIG_MAP.ID
and
    SWARE_SIG_MAP.ID = SIGNATURE.ID
and
    (SIGNATURE.ENABLED = 0 or SIGNATURE.ENABLED = 2)
;

create or replace view MATCHED_SIG_COUNT
as
select distinct
    MATCHED_SWARE.COMPUTER_SYS_ID,
    SIG_PACKAGE.SIG_PACKAGE_ID,
    SIG_PACKAGE.SWARE_DESC,
    SIG_PACKAGE.SWARE_VERS,
    count(*) as NUM
from
    SIG_PACKAGE,MATCHED_SWARE
where
    SIG_PACKAGE.SWARE_SIG_ID = MATCHED_SWARE.SWARE_SIG_ID
group by
    MATCHED_SWARE.COMPUTER_SYS_ID, 
    SIG_PACKAGE.SIG_PACKAGE_ID, 
    SIG_PACKAGE.SWARE_DESC, 
    SIG_PACKAGE.SWARE_VERS
;


insert into SCHEMA_VERS values ('CM 4.2.3', SYSDATE, 'PATCH',
'inv_ora_schema_423_FP04.sql', 'FP04 applied to existing installation')
;

spool off;

exit;

