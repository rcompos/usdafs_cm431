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
--
-- This script is to upgrade a CM 4.2.3 installation.
-- Use inv_ora_schema.sql script for a fresh install.
--

---------------------------------------------------------------------

-- spool inv_ora_schema_423_FP02.log;
spool fs_inv_ora_schema_423_FP02.log;

alter table COMPUTER modify (OS_NAME varchar2(128));
alter table COMPUTER add OS_LANG_VERS varchar2(64);
alter table COMPUTER add OS_LCID varchar2(64);
alter table COMPUTER add CURRENT_LCID varchar2(64);
alter table COMPUTER add OS_ARCH      varchar2(24);


drop view COMPUTER_VIEW;
create view COMPUTER_VIEW
as
select
    COMPUTER.COMPUTER_SYS_ID,
    to_char(COMPUTER.COMPUTER_SCANTIME,'YYYY.MM.DD HH24:MI:SS') as COMPUTER_SCANTIME,
    COMPUTER.TME_OBJECT_ID,
    COMPUTER.TME_OBJECT_LABEL,
    COMPUTER.COMPUTER_MODEL,
    COMPUTER.COMPUTER_BOOT_TIME,
    COMPUTER.COMPUTER_ALIAS,
    COMPUTER.SYS_SER_NUM,
    COMPUTER.OS_NAME,
    COMPUTER.OS_TYPE,
    COMPUTER.OS_MAJOR_VERS,
    COMPUTER.OS_MINOR_VERS,
    COMPUTER.OS_SUB_VERS,
    COMPUTER.OS_INST_DATE,
    COMPUTER.REGISTERED_OWNER,
    COMPUTER.REGISTERED_ORG,
    COMPUTER.KEYBOARD_TYPE,
    COMPUTER.FUNCTION_KEYS,
    COMPUTER.TZ_LOCALE,
    COMPUTER.TZ_NAME,
    COMPUTER.TZ_DAYLIGHT_NAME,
    COMPUTER.ON_SAVINGS_TIME,
    COMPUTER.TZ_SECONDS,
    COMPUTER.TIME_DIRECTION,
    COMPUTER.OS_LANG_VERS,
    COMPUTER.OS_LCID,
    COMPUTER.OS_ARCH,
    COMPUTER.CURRENT_LCID,
    to_char(COMPUTER.RECORD_TIME,'YYYY.MM.DD HH24:MI:SS') as RECORD_TIME
from
    COMPUTER
;

create or replace view OS_VIEW
as
select
    COMPUTER.TME_OBJECT_LABEL,
    COMPUTER.TME_OBJECT_ID,
    COMPUTER.COMPUTER_SYS_ID,
    COMPUTER.OS_NAME,
    COMPUTER.OS_TYPE,
    COMPUTER.OS_MAJOR_VERS,
    COMPUTER.OS_MINOR_VERS,
    COMPUTER.OS_SUB_VERS,
    COMPUTER.OS_INST_DATE,
    COMPUTER.OS_LANG_VERS,
    COMPUTER.OS_LCID,
    COMPUTER.OS_ARCH
from
    COMPUTER
;

-- DROP TABLE SERVICE_INFO;
CREATE TABLE SERVICE_INFO (
       SNAME             VARCHAR(128)  NOT NULL,
       DNAME             VARCHAR(64),
       SDESC             VARCHAR(256),
       SPATH_NAME        VARCHAR(128),
       STYPE             VARCHAR(64),
       SSTARTED          VARCHAR(16),
       SSTART_MODE       VARCHAR(16),
       SDISPLAY_NAME     VARCHAR(64),
       SSTATE            VARCHAR(16),
       SSTATUS           VARCHAR(16),
         CONSTRAINT SINFO_PK PRIMARY KEY(SNAME))
;

-- DROP TABLE T_SERVICE_INFO;
CREATE GLOBAL TEMPORARY TABLE T_SERVICE_INFO (
       SNAME             VARCHAR(128)  NOT NULL,
       DNAME             VARCHAR(64),
       SDESC             VARCHAR(256),
       SPATH_NAME        VARCHAR(128),
       STYPE             VARCHAR(64),
       SSTARTED          VARCHAR(16),
       SSTART_MODE       VARCHAR(16),
       SDISPLAY_NAME     VARCHAR(64),
       SSTATE            VARCHAR(16),
       SSTATUS           VARCHAR(16))
       ON COMMIT DELETE ROWS
;

-- DROP TABLE INST_SERVICE_INFO;
CREATE TABLE INST_SERVICE_INFO (
       COMPUTER_SYS_ID      VARCHAR(64)   NOT NULL,
       SNAME                VARCHAR(128)  NOT NULL,
       RECORD_TIME          DATE          DEFAULT SYSDATE,
         CONSTRAINT INSTSERVICE_PK PRIMARY KEY(COMPUTER_SYS_ID,SNAME),
         CONSTRAINT INSTSERVICE_FK FOREIGN KEY(COMPUTER_SYS_ID)
           REFERENCES COMPUTER(COMPUTER_SYS_ID),
         CONSTRAINT SERVICE_FK FOREIGN KEY(SNAME)
           REFERENCES SERVICE_INFO(SNAME))
;

CREATE OR REPLACE TRIGGER INST_SINFO_TR
       BEFORE UPDATE ON INST_SERVICE_INFO
       FOR EACH ROW
       BEGIN
         :NEW.RECORD_TIME := SYSDATE;
       END;
/

-- DROP TABLE LPAR;
CREATE TABLE LPAR (
       COMPUTER_SYS_ID        VARCHAR(64)  NOT NULL,
       LPARID                 VARCHAR(32),
       SHARED_POOL_ID         VARCHAR(16),
       NODE_CAPACITY          VARCHAR(64),
       LPAR_CAPACITY          VARCHAR(64),
       SHARED_POOL_CAPACITY   VARCHAR(64),
       SERIAL_NUMBER          VARCHAR(64),
       RECORD_TIME            DATE          DEFAULT SYSDATE,
         CONSTRAINT LPAR_PK PRIMARY KEY(COMPUTER_SYS_ID),
         CONSTRAINT LPAR_FK FOREIGN KEY(COMPUTER_SYS_ID)
           REFERENCES COMPUTER(COMPUTER_SYS_ID))
;


CREATE OR REPLACE TRIGGER LPAR_TR
       BEFORE UPDATE ON LPAR
       FOR EACH ROW
       BEGIN
         :NEW.RECORD_TIME := SYSDATE;
       END;
/


-- drop table OID;
create table OID
(
    LAST_ID             integer             not null,
    TABLE_NAME          varchar2(40)        not null,
    BLOCK_SIZE          integer             not null,
         CONSTRAINT OID_PK PRIMARY KEY(TABLE_NAME)
);

-- drop table SIGNATURE;
-- drop table PLATFORM;

create table PLATFORM 
(
    ID                  integer             not null,
    NAME                varchar2(50)        not null,
    LAST_MODIFIED       date                default SYSDATE not null,
         CONSTRAINT PLATFORM_PK PRIMARY KEY(ID),
         CONSTRAINT PLATFORM_UK UNIQUE (NAME)
)
;

CREATE OR REPLACE TRIGGER PLATFORM_TR1
       BEFORE UPDATE ON PLATFORM
       FOR EACH ROW
       BEGIN
         :NEW.LAST_MODIFIED := SYS_EXTRACT_UTC(CURRENT_TIMESTAMP);
       END;
/

CREATE OR REPLACE TRIGGER PLATFORM_TR2
    BEFORE INSERT ON PLATFORM
    FOR EACH ROW
        BEGIN
         :NEW.LAST_MODIFIED := SYS_EXTRACT_UTC(CURRENT_TIMESTAMP);
        END;
/

    
create table SIGNATURE 
(
    ID                  integer             not null,
    NAME                varchar2(254)       not null,
    FILE_SIZE           integer             not null,
    PLATFORM            varchar2(50)        not null,
    SIG_VALUE           varchar2(254),   
    SIG_TYPE            integer             default 0 not null,
    SIG_SCOPE           integer             default 0 not null,
    ENABLED             integer             default 1 not null,
    DESCRIPTION         varchar2(254),
    VERSION             varchar2(64),
    IBM_SOURCE          integer             default 1  not null,
    LAST_MODIFIED       date                default sysdate not null,  
         CONSTRAINT SIG_PK PRIMARY KEY(ID),
         CONSTRAINT SIG_FK FOREIGN KEY(PLATFORM) REFERENCES PLATFORM(NAME)
);

create unique index SIG_UK on SIGNATURE
(
    NAME,
    FILE_SIZE,
    PLATFORM,
    SIG_VALUE
);

CREATE OR REPLACE TRIGGER SIGNATURE_TR1
       BEFORE UPDATE ON SIGNATURE
       FOR EACH ROW
       BEGIN
         :NEW.LAST_MODIFIED := SYS_EXTRACT_UTC(CURRENT_TIMESTAMP);
       END;
/

CREATE OR REPLACE TRIGGER SIGNATURE_TR2
    BEFORE INSERT ON SIGNATURE
    FOR EACH ROW
        BEGIN
         :NEW.LAST_MODIFIED := SYS_EXTRACT_UTC(CURRENT_TIMESTAMP);
        END;
/
     
-- drop table INVENTORY_SIG;
create table INVENTORY_SIG 
(
    ID                  integer             not null,
    BODY                clob                not null,
         CONSTRAINT INV_SIG_PK PRIMARY KEY(ID)
)
;

CREATE OR REPLACE TRIGGER INVENTORY_SIG_T1
       AFTER INSERT ON INVENTORY_SIG
       FOR EACH ROW
       BEGIN
         UPDATE SIGNATURE
         SET ID = ID 
         WHERE ID = :NEW.ID;
       END;
/

CREATE OR REPLACE TRIGGER INVENTORY_SIG_T2
       AFTER UPDATE ON INVENTORY_SIG
       FOR EACH ROW
       BEGIN
         UPDATE SIGNATURE
         SET ID = ID 
         WHERE ID = :NEW.ID;
       END;
/

CREATE OR REPLACE TRIGGER INVENTORY_SIG_T3
       AFTER DELETE ON INVENTORY_SIG
       FOR EACH ROW
       BEGIN
         UPDATE SIGNATURE
         SET ID = ID 
         WHERE ID = :OLD.ID;
       END;
/

-- drop table CONTROL;
create table CONTROL
(
    NAME                varchar(40)        not null,
    CTRL_VALUE          varchar(60)        not null,
        CONSTRAINT CONTROL_PK PRIMARY KEY(NAME)
)
;

insert into PLATFORM (ID, NAME) values (1, 'Windows');
insert into PLATFORM (ID, NAME) values (2, 'Linux');
insert into PLATFORM (ID, NAME) values (3, 'AIX');
insert into PLATFORM (ID, NAME) values (4, 'HPUX');
insert into PLATFORM (ID, NAME) values (5, 'Solaris');
insert into PLATFORM (ID, NAME) values (6, 'i5/OS');
insert into PLATFORM (ID, NAME) values (7, 'Unix');
insert into PLATFORM (ID, NAME) values (9, 'JVM');

INSERT INTO oid SELECT NVL (max(id),0), 'swcat.signature', 1 FROM signature;
INSERT INTO oid SELECT NVL (max(id),0), 'swcat.platform',  1 FROM platform;

INSERT INTO CONTROL (NAME, CTRL_VALUE) VALUES 
    ('CATALOG_INSTALL', 
        TO_CHAR(SYS_EXTRACT_UTC(CURRENT_TIMESTAMP), 'YYYY-MM-DD HH24-MI-SS') || '.0');

INSERT INTO CONTROL (NAME, CTRL_VALUE) VALUES 
    ('DATABASE_VERSION', '2.2');
INSERT INTO CONTROL (NAME, CTRL_VALUE) VALUES 
    ('CATALOG_UPDATE', '2002-05-01 12:00:00.000000');
INSERT INTO CONTROL (NAME, CTRL_VALUE) VALUES 
    ('CATALOG_ID', SUBSTR(TO_CHAR(SYSTIMESTAMP, 'SSMIFF'), 1, 6));
    
INSERT INTO CONTROL (NAME, CTRL_VALUE) VALUES 
    ('CATALOG_LAST_MODIFIED', 
           TO_CHAR(SYS_EXTRACT_UTC(CURRENT_TIMESTAMP), 'YYYY-MM-DD HH24-MI-SS') || '.0');

INSERT INTO CONTROL (NAME, CTRL_VALUE) VALUES 
    ('CAT_MGR_ERROR_CONTROL_FIELD', '0');

INSERT INTO CONTROL (NAME, CTRL_VALUE) VALUES 
    ('ITLM_INSTALLED', '0');
INSERT INTO CONTROL (NAME, CTRL_VALUE) VALUES 
    ('ITCM_INSTALLED', '1');

-----------------------------------------------------------------------------------

-- drop table SWARE_SIG_MAP;
create table SWARE_SIG_MAP
(
    ID                  integer             not null,
    FILE_DESC_ID        varchar2(32)        not null,
    OS_NAME             varchar2(64)        not null,
         CONSTRAINT SWARESIGMAP_PK PRIMARY KEY(FILE_DESC_ID, OS_NAME)
);

DROP TRIGGER MATCHEDSWARE_TR;
DROP TRIGGER SIGPACKAGE_TR;
ALTER TABLE MATCHED_SWARE DROP CONSTRAINT MATCHEDSWARE_FK;
ALTER TABLE MATCHED_SWARE DROP CONSTRAINT MATCHEDSWARE_PK;
ALTER TABLE SIG_PACKAGE DROP CONSTRAINT SIGPACKAGE_PK;
ALTER TABLE SIG_SP_MAP DROP CONSTRAINT SIGSPMAP_PK;

-- WARNING : drop this table causes old signatures info are lost
-- drop table oldMATCHEDSWARE;
rename MATCHED_SWARE to oldMATCHEDSWARE;
-- drop table MATCHED_SWARE; 
CREATE TABLE MATCHED_SWARE (
       COMPUTER_SYS_ID      VARCHAR2(64)    NOT NULL,
       SWARE_SIG_ID         integer         NOT NULL,
       RECORD_TIME          DATE            DEFAULT SYSDATE,
         CONSTRAINT MATCHEDSWARE_PK PRIMARY KEY(COMPUTER_SYS_ID,SWARE_SIG_ID),
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

-- drop table MSWARE_DESC;
CREATE TABLE MSWARE_DESC (
       COMPUTER_SYS_ID      VARCHAR(64)   NOT NULL,
       SWARE_SIG_ID         INTEGER       NOT NULL,
       MD5_ID               VARCHAR(128)  NOT NULL,    
       SWARE_SIG_PATH       VARCHAR(1024) NOT NULL,    
         CONSTRAINT MSWDESC_PK PRIMARY KEY(COMPUTER_SYS_ID, SWARE_SIG_ID, MD5_ID),
         CONSTRAINT MSWDESC_FK FOREIGN KEY(COMPUTER_SYS_ID)
           REFERENCES COMPUTER(COMPUTER_SYS_ID))
;

-- WARNING : drop this table causes old signatures info are lost
-- drop table oldSIGPACKAGE;
rename SIG_PACKAGE to oldSIGPACKAGE;
-- drop table SIG_PACKAGE;
CREATE TABLE SIG_PACKAGE (
       SIG_PACKAGE_ID       VARCHAR2(32)    NOT NULL,
       SWARE_SIG_ID         integer         NOT NULL,
       SWARE_DESC           VARCHAR2(128),
       SWARE_VERS           VARCHAR2(64),
       RECORD_TIME          DATE            DEFAULT SYSDATE,
         CONSTRAINT SIGPACKAGE_PK PRIMARY KEY(SIG_PACKAGE_ID,SWARE_SIG_ID))
;

CREATE OR REPLACE TRIGGER SIGPACKAGE_TR
       BEFORE UPDATE ON SIG_PACKAGE
       FOR EACH ROW
       BEGIN
         :NEW.RECORD_TIME := SYSDATE;
       END;
/

-- WARNING : drop this table causes old signatures info are lost
-- drop table oldSIGSPMAP;
rename SIG_SP_MAP to oldSIGSPMAP;
-- drop table SIG_SP_MAP;
CREATE TABLE SIG_SP_MAP(
       SWARE_SIG_ID         integer         NOT NULL,
       SWARE_NAME           VARCHAR2(128)   NOT NULL,
       SWARE_VERS           VARCHAR2(64)    NOT NULL,
       MAP_STATUS           CHAR(1),
         CONSTRAINT SIGSPMAP_PK PRIMARY KEY(SWARE_SIG_ID,SWARE_NAME,SWARE_VERS))
;

commit;

-----------------------------------------------------------------------------------

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
    COMPUTER.OS_NAME = SWARE_SIG_MAP.OS_NAME
and
    SWARE_SIG_MAP.FILE_DESC_ID = UNMATCHED_FILES.FILE_DESC_ID
and
    SIGNATURE.ENABLED = 1
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
          MATCHED_SWARE.SWARE_SIG_ID = MSWARE_DESC.SWARE_SIG_ID
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

create or replace view PACKAGE_FILE_VIEW
as
select
    SIG_PACKAGE.SIG_PACKAGE_ID,
    SIG_PACKAGE.SWARE_SIG_ID,
    SIG_PACKAGE.SWARE_DESC,
    SIG_PACKAGE.SWARE_VERS,
    SIGNATURE.NAME as SWARE_NAME,
    SIGNATURE.FILE_SIZE as SWARE_SIZE,
    SIGNATURE.PLATFORM,    
    to_char(SIG_PACKAGE.RECORD_TIME,'YYYY.MM.DD HH24:MI:SS') as RECORD_TIME
from
    SIG_PACKAGE,SIGNATURE
where
    SIG_PACKAGE.SWARE_SIG_ID = SIGNATURE.ID
and
    SIGNATURE.ENABLED = 1
;

create or replace view SIG_PACKAGE_COUNT
as
select
    SIG_PACKAGE.SIG_PACKAGE_ID,
    count(*) as NUM
from
    SIG_PACKAGE,SIGNATURE
where
    SIG_PACKAGE.SWARE_SIG_ID = SIGNATURE.ID
and
    SIGNATURE.ENABLED = 1
group by
    SIG_PACKAGE.SIG_PACKAGE_ID
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

create or replace view SIG_PACKAGE_VIEW
as
select
    COMPUTER.TME_OBJECT_LABEL,
    COMPUTER.TME_OBJECT_ID,
    COMPUTER.COMPUTER_SYS_ID,
    MATCHED_SIG_COUNT.SWARE_DESC,
    MATCHED_SIG_COUNT.SWARE_VERS
from
    COMPUTER,SIG_PACKAGE_COUNT,MATCHED_SIG_COUNT
where
    COMPUTER.COMPUTER_SYS_ID = MATCHED_SIG_COUNT.COMPUTER_SYS_ID
and
    SIG_PACKAGE_COUNT.SIG_PACKAGE_ID=MATCHED_SIG_COUNT.SIG_PACKAGE_ID
and
    SIG_PACKAGE_COUNT.NUM = MATCHED_SIG_COUNT.NUM
;

create or replace view CHECK_PACKAGES
as
select
    SIG_PACKAGE.SIG_PACKAGE_ID,
    SIG_PACKAGE.SWARE_SIG_ID,
    SIG_PACKAGE.SWARE_DESC,
    SIG_PACKAGE.SWARE_VERS,
    SIGNATURE.PLATFORM
from
    SIG_PACKAGE, SIGNATURE
where
    SIG_PACKAGE.SWARE_SIG_ID = SIGNATURE.ID and
    not exists
    (select 'X'
    from SIGNATURE
    where SIG_PACKAGE.SWARE_SIG_ID = SIGNATURE.ID
    and SIGNATURE.ENABLED = 1)
;

create or replace view CHECK_SIG
as
select
    SIGNATURE.ID,   
    SWARE_SIG_MAP.FILE_DESC_ID,
    SWARE_SIG_MAP.OS_NAME,
    PLATFORM,  
    SIG_VALUE, 
    SIG_TYPE, 
    SIG_SCOPE, 
    ENABLED,   
    DESCRIPTION,
    VERSION,  
    IBM_SOURCE,
    NAME
from
    SWARE_SIG_MAP, SIGNATURE
where
    SWARE_SIG_MAP.ID = SIGNATURE.ID
;

create or replace view NOSIG_FILES_VIEW
as
select
    COMPUTER.TME_OBJECT_LABEL,
    COMPUTER.TME_OBJECT_ID,
    COMPUTER.COMPUTER_SYS_ID,
    FILE_DESC.FILE_NAME,
    FILE_DESC.FILE_SIZE
from
    UNMATCHED_FILES,FILE_DESC,COMPUTER
where
    UNMATCHED_FILES.COMPUTER_SYS_ID = COMPUTER.COMPUTER_SYS_ID
and
    UNMATCHED_FILES.FILE_DESC_ID = FILE_DESC.FILE_DESC_ID
and
    not exists
    (select 'X'
    from SIGNATURE, SWARE_SIG_MAP, COMPUTER
    where 
        UNMATCHED_FILES.FILE_DESC_ID = SWARE_SIG_MAP.FILE_DESC_ID
    and
        SIGNATURE.ID = SWARE_SIG_MAP.ID
    and
        COMPUTER.OS_NAME = SWARE_SIG_MAP.OS_NAME
    and
        UNMATCHED_FILES.COMPUTER_SYS_ID = COMPUTER.COMPUTER_SYS_ID
    and 
        SIGNATURE.ENABLED = 1)
;    

create or replace view SWARE_MATCH_QUICK
as
select
    COMPUTER.TME_OBJECT_LABEL,
    COMPUTER.TME_OBJECT_ID,
    COMPUTER.COMPUTER_SYS_ID,
    SIGNATURE.DESCRIPTION as SWARE_DESC,
    SIGNATURE.VERSION as SWARE_VERS,
    SIGNATURE.NAME as SWARE_NAME,
    SIGNATURE.FILE_SIZE as SWARE_SIZE,
    UNMATCHED_FILES.CHECKSUM_QUICK,
    UNMATCHED_FILES.RECORD_TIME
from
    COMPUTER, SIGNATURE,UNMATCHED_FILES, SWARE_SIG_MAP
where
    SIGNATURE.ENABLED = 1
and
    SIGNATURE.ID = SWARE_SIG_MAP.ID
and
    COMPUTER.OS_NAME = SWARE_SIG_MAP.OS_NAME
and
    UNMATCHED_FILES.FILE_DESC_ID = SWARE_SIG_MAP.FILE_DESC_ID
and
    UNMATCHED_FILES.CHECKSUM_QUICK <> ''
and
    UNMATCHED_FILES.COMPUTER_SYS_ID = COMPUTER.COMPUTER_SYS_ID
;

create or replace view SWARE_MATCH_CRC32
as
select
    COMPUTER.TME_OBJECT_LABEL,
    COMPUTER.TME_OBJECT_ID,
    COMPUTER.COMPUTER_SYS_ID,
    SIGNATURE.DESCRIPTION as SWARE_DESC,
    SIGNATURE.VERSION as SWARE_VERS,
    SIGNATURE.NAME as SWARE_NAME,
    SIGNATURE.FILE_SIZE as SWARE_SIZE,
    UNMATCHED_FILES.CHECKSUM_CRC32,
    UNMATCHED_FILES.RECORD_TIME
from
    COMPUTER, SIGNATURE,UNMATCHED_FILES, SWARE_SIG_MAP
where
    SIGNATURE.ENABLED = 1
and
    SIGNATURE.ID = SWARE_SIG_MAP.ID
and
    COMPUTER.OS_NAME = SWARE_SIG_MAP.OS_NAME
and
    UNMATCHED_FILES.FILE_DESC_ID = SWARE_SIG_MAP.FILE_DESC_ID
and
    UNMATCHED_FILES.CHECKSUM_CRC32 <> ''
and
    UNMATCHED_FILES.COMPUTER_SYS_ID = COMPUTER.COMPUTER_SYS_ID
;

create or replace view SWARE_MATCH_MD5
as
select
    COMPUTER.TME_OBJECT_LABEL,
    COMPUTER.TME_OBJECT_ID,
    COMPUTER.COMPUTER_SYS_ID,
    SIGNATURE.DESCRIPTION as SWARE_DESC,
    SIGNATURE.VERSION as SWARE_VERS,
    SIGNATURE.NAME as SWARE_NAME,
    SIGNATURE.FILE_SIZE as SWARE_SIZE,
    UNMATCHED_FILES.CHECKSUM_MD5,
    UNMATCHED_FILES.RECORD_TIME
from
    COMPUTER, SIGNATURE,UNMATCHED_FILES, SWARE_SIG_MAP
where
    SIGNATURE.ENABLED = 1
and
    SIGNATURE.ID = SWARE_SIG_MAP.ID
and
    COMPUTER.OS_NAME = SWARE_SIG_MAP.OS_NAME
and
    UNMATCHED_FILES.FILE_DESC_ID = SWARE_SIG_MAP.FILE_DESC_ID
and
    UNMATCHED_FILES.CHECKSUM_MD5 <> ''
and
    UNMATCHED_FILES.COMPUTER_SYS_ID = COMPUTER.COMPUTER_SYS_ID
;

create or replace view SP_SIG_VIEW
as
select
    SIG_SP_MAP.SWARE_NAME,
    SIG_SP_MAP.SWARE_VERS,
    SIG_SP_MAP.SWARE_SIG_ID,
    SIGNATURE.NAME as SWARE_FILENAME,
    SIGNATURE.FILE_SIZE as SWARE_FILESIZE,
    SIG_SP_MAP.MAP_STATUS,
    SIGNATURE.ENABLED as SIG_STATUS
from
    SIG_SP_MAP, SIGNATURE
where
    SIG_SP_MAP.SWARE_SIG_ID = SIGNATURE.ID
;

create or replace view CAT_SIG_V
as
select SIGNATURE.ID as ID,
    SIGNATURE.NAME as NAME,
    SIGNATURE.FILE_SIZE as FILE_SIZE,
    SIGNATURE.SIG_TYPE as SIG_TYPE,
    SIGNATURE.SIG_VALUE as SIG_VALUE,
    nvl(DBMS_LOB.SUBSTR(INVENTORY_SIG.BODY,32767,1),'') as BODY,
    SIGNATURE.SIG_SCOPE as SIG_SCOPE,
    0 as COMPONENT_ID,
    SIGNATURE.PLATFORM as PLATFORM
from SIGNATURE
    LEFT OUTER JOIN INVENTORY_SIG ON
        SIGNATURE.ID=INVENTORY_SIG.ID WHERE
        SIGNATURE.ENABLED = 1
;

CREATE or REPLACE VIEW INV_PKG_VIEW
AS
SELECT SIG_PACKAGE.SIG_PACKAGE_ID AS SIG_PACKAGE_ID,
    SIG_PACKAGE.SWARE_SIG_ID AS SWARE_SIG_ID,
    SIG_PACKAGE.SWARE_DESC AS SWARE_DESC,
    SIG_PACKAGE.SWARE_VERS AS SWARE_VERS,
        SIGNATURE.ID as ID
FROM SIG_PACKAGE 
    JOIN SIGNATURE ON 
    SIG_PACKAGE.SWARE_SIG_ID = SIGNATURE.ID 
    AND SIGNATURE.ENABLED=2
;

commit
;

---------------------------------------------------------------------

create sequence swsigid start with 1 increment by 1;

insert into SWARE_SIG_MAP 
     (
        ID,
        FILE_DESC_ID,
        OS_NAME
     )
select 
        (select LAST_ID from OID where TABLE_NAME = 'swcat.signature') + swsigid.nextval,
        SWARE_SIG_ID,
        'JVM'
from SWARE_SIG
;

update OID set LAST_ID = (select NVL (max(ID),0) from SWARE_SIG_MAP) where TABLE_NAME = 'swcat.signature';

drop sequence swsigid;

commit
;

insert into SIGNATURE 
     (
        ID,
        NAME,
        FILE_SIZE,
        PLATFORM,
        SIG_SCOPE,
        SIG_TYPE,
        ENABLED,
        DESCRIPTION,
        VERSION,
        IBM_SOURCE,
        LAST_MODIFIED
     )
select 
        ID,   
        SWARE_NAME, 
        SWARE_SIZE,
        'JVM',
        1,
        0,
        to_number(NVL(SIG_STATUS, '0')),
        SWARE_DESC,
        SWARE_VERS,
        0,
        RECORD_TIME
from SWARE_SIG, SWARE_SIG_MAP
where SIG_SOURCE = 'CUSTOM' and
      SWARE_SIG_MAP.FILE_DESC_ID = SWARE_SIG.SWARE_SIG_ID and
      ID not in (select id from signature)
;

commit
;

insert into SIGNATURE 
     (
        ID,
        NAME,
        FILE_SIZE,
        PLATFORM,
        SIG_SCOPE,
        SIG_TYPE,
        ENABLED,
        DESCRIPTION,
        VERSION,
        IBM_SOURCE,
        LAST_MODIFIED
     )
select 
        ID,   
        SWARE_NAME, 
        SWARE_SIZE,
        'JVM',
        1,
        0,
        to_number(NVL(SIG_STATUS, '0')),
        SWARE_DESC,
        SWARE_VERS,
        2,
        RECORD_TIME
from SWARE_SIG, SWARE_SIG_MAP
where SIG_SOURCE = 'SWD' and
      SWARE_SIG_MAP.FILE_DESC_ID = SWARE_SIG.SWARE_SIG_ID and
      ID not in (select id from signature)
;

commit
;


insert into SIGNATURE 
     (
        ID,
        NAME,
        FILE_SIZE,
        PLATFORM,
        SIG_SCOPE,
        SIG_TYPE,
        ENABLED,
        DESCRIPTION,
        VERSION,
        LAST_MODIFIED
     )
select 
        ID,   
        SWARE_NAME, 
        SWARE_SIZE,
        'JVM',
        1,
        0,
        0,
        SWARE_DESC,
        SWARE_VERS,
        RECORD_TIME
from SWARE_SIG, SWARE_SIG_MAP
where SIG_SOURCE <> 'CUSTOM' and SIG_SOURCE <> 'SWD' and
    SIG_STATUS = '0' and
    SWARE_SIG_MAP.FILE_DESC_ID = SWARE_SIG.SWARE_SIG_ID and
    ID not in (select id from signature)
;

commit
;

insert into SIGNATURE 
     (
        ID,
        NAME,
        FILE_SIZE,
        PLATFORM,
        SIG_SCOPE,
        SIG_TYPE,
        ENABLED,
        DESCRIPTION,
        VERSION,
        LAST_MODIFIED
     )
select 
        SWARE_SIG_MAP.ID,   
        SWARE_NAME, 
        SWARE_SIZE,
        'JVM',
        1,
        0,
        2,
        SWARE_DESC,
        SWARE_VERS,
        RECORD_TIME
from SWARE_SIG, SWARE_SIG_MAP
where SIG_SOURCE <> 'CUSTOM' and SIG_SOURCE <> 'SWD' and
    SIG_STATUS = '1' and
    SWARE_SIG_MAP.FILE_DESC_ID = SWARE_SIG.SWARE_SIG_ID and
    ID not in (select id from signature)
;

commit
;

insert into MATCHED_SWARE 
     (
        COMPUTER_SYS_ID,
        SWARE_SIG_ID,
        RECORD_TIME
     )
select 
        COMPUTER_SYS_ID,
        ID,
        RECORD_TIME
from oldMATCHEDSWARE, SWARE_SIG_MAP
where SWARE_SIG_MAP.FILE_DESC_ID = oldMATCHEDSWARE.SWARE_SIG_ID and
    ID not in (select SWARE_SIG_ID from MATCHED_SWARE)
;

commit
;

insert into SIG_PACKAGE 
     (
        SIG_PACKAGE_ID,
        SWARE_SIG_ID,
        SWARE_DESC,
        SWARE_VERS,
        RECORD_TIME
     )
select 
        SIG_PACKAGE_ID,
        ID,
        SWARE_DESC,
        SWARE_VERS,
        RECORD_TIME
from oldSIGPACKAGE, SWARE_SIG_MAP
where SWARE_SIG_MAP.FILE_DESC_ID = oldSIGPACKAGE.SWARE_SIG_ID and
    ID not in (select SWARE_SIG_ID from SIG_PACKAGE)
;

commit
;

insert into SIG_SP_MAP 
     (
        SWARE_SIG_ID,
        SWARE_NAME,
        SWARE_VERS,
        MAP_STATUS
     )
select 
        ID,
        SWARE_NAME,
        SWARE_VERS,
        MAP_STATUS
from oldSIGSPMAP, SWARE_SIG_MAP
where SWARE_SIG_MAP.FILE_DESC_ID = oldSIGSPMAP.SWARE_SIG_ID and
    ID not in (select SWARE_SIG_ID from SIG_SP_MAP)
;

commit
;

drop table SWARE_SIG
;

update LAST_SIG_UPDATE set LAST_UPDATE = LAST_UPDATE + 60 where UPDATE_TABLE = '0'
;

commit
;

---------------------------------------------------------------------

create or replace view SERVICE_INFO_VIEW
as
select
    COMPUTER.TME_OBJECT_LABEL,
    COMPUTER.TME_OBJECT_ID,
    COMPUTER.COMPUTER_SYS_ID,
    SERVICE_INFO.SNAME,                      
    SERVICE_INFO.DNAME,                       
    SERVICE_INFO.SDESC,                       
    SERVICE_INFO.STYPE,                      
    SERVICE_INFO.SSTART_MODE,                
    SERVICE_INFO.SDISPLAY_NAME,              
    SERVICE_INFO.SSTATE,                     
    SERVICE_INFO.SSTATUS,                    
    to_char(INST_SERVICE_INFO.RECORD_TIME,'YYYY.MM.DD HH24:MI:SS') as RECORD_TIME
from
    SERVICE_INFO,INST_SERVICE_INFO,COMPUTER
where
    INST_SERVICE_INFO.COMPUTER_SYS_ID = COMPUTER.COMPUTER_SYS_ID
and
    INST_SERVICE_INFO.SNAME = SERVICE_INFO.SNAME
;

insert into SCHEMA_VERS values ('CM 4.2.3', SYSDATE, 'PATCH',
            'inv_ora_schema_423_FP02.sql', 'FP02 applied to existing installation')
;

---------------------------------------------------------------------

insert into INVENTORY_TABLES(TABLE_NAME) values ('INST_SERVICE_INFO')
;
---------------------------------------------------------------------
insert into QUERY_VIEWS(VIEW_NAME) values ('SERVICE_INFO_VIEW')
;
---------------------------------------------------------------------
create or replace view LPAR_VIEW
as
select
    COMPUTER.TME_OBJECT_LABEL,
    COMPUTER.TME_OBJECT_ID,
    COMPUTER.COMPUTER_SYS_ID,
    COMPUTER.COMPUTER_ALIAS AS COMPUTER_NAME,
    LPAR.LPARID,
    LPAR.SHARED_POOL_ID,
    LPAR.NODE_CAPACITY,
    LPAR.LPAR_CAPACITY,
    LPAR.SHARED_POOL_CAPACITY,
    LPAR.SERIAL_NUMBER,
    to_char(LPAR.RECORD_TIME,'YYYY.MM.DD HH24:MI:SS') as RECORD_TIME
from
    LPAR, COMPUTER
where
    LPAR.COMPUTER_SYS_ID = COMPUTER.COMPUTER_SYS_ID
;

create or replace view LPAR_SYSTEMS_VIEW
as
select
    SERIAL_NUMBER,
    NODE_CAPACITY
from
    LPAR_VIEW
where
    LPAR_CAPACITY NOT LIKE '-1%'
GROUP BY 
    SERIAL_NUMBER,
    NODE_CAPACITY
;

create or replace view LOGICAL_PARTITIONS_VIEW
as
select
    COMPUTER_NAME,
    SERIAL_NUMBER,
    COMPUTER_SYS_ID,
    LPARID,
    LPAR_CAPACITY,
    NODE_CAPACITY,
    SHARED_POOL_ID,
    SHARED_POOL_CAPACITY,
    RECORD_TIME
from
    LPAR_VIEW
where
    LPAR_CAPACITY NOT LIKE '-1%'
;

---------------------------------------------------------------------
insert into QUERY_VIEWS (VIEW_NAME) values ('LPAR_VIEW')
;
insert into QUERY_VIEWS (VIEW_NAME) values ('LPAR_SYSTEMS_VIEW')
;
insert into QUERY_VIEWS (VIEW_NAME) values ('LOGICAL_PARTITIONS_VIEW')
;
---------------------------------------------------------------------
insert into INVENTORY_TABLES(TABLE_NAME) values ('LPAR')
;
insert into INVENTORY_TABLES(TABLE_NAME) values ('MSWARE_DESC')
;
---------------------------------------------------------------------
commit;

spool off;

exit;

