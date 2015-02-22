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
-- inv_ora_schema_423_FP03.sql
--
-- This script is to upgrade a CM 4.2.3 installation.
-- Use inv_ora_schema.sql script for a fresh install.
--

---------------------------------------------------------------------

-- spool inv_ora_schema_423_FP03.log;
spool fs_inv_ora_schema_423_FP03.log;

alter table IP_ADDR add PERM_MAC_ADDRESS varchar2(64);

create or replace view IP_ADDR_VIEW
as
select
    COMPUTER.TME_OBJECT_LABEL,
    COMPUTER.TME_OBJECT_ID,
    IP_ADDR.COMPUTER_SYS_ID,
    IP_ADDR.IP_ADDR,
    IP_ADDR.IP_HOSTNAME,
    IP_ADDR.IP_DOMAIN,
    IP_ADDR.IP_SUBNET,
    IP_ADDR.IP_GATEWAY,
    IP_ADDR.IP_PRIMARY_DNS,
    IP_ADDR.IP_SECONDARY_DNS,
    IP_ADDR.IS_DHCP,
    IP_ADDR.PERM_MAC_ADDRESS,
    to_char(IP_ADDR.RECORD_TIME,'YYYY.MM.DD HH24:MI:SS') as RECORD_TIME
from
    IP_ADDR,COMPUTER
where
    IP_ADDR.COMPUTER_SYS_ID = COMPUTER.COMPUTER_SYS_ID
;

-- DROP TABLE DEVICE;
CREATE TABLE DEVICE (
	COMPUTER_SYS_ID               VARCHAR2(64) NOT NULL,
	DEVICE_NAME                   VARCHAR2(255),
	FRIENDLY_NAME                 VARCHAR2(255),
	DEVICE_CLASS_ID               VARCHAR2(18),
	LABEL                         VARCHAR2(255),
	SERIAL_NUMBER                 VARCHAR2(128),
	MAKE                          VARCHAR2(128),	
	MODEL                         VARCHAR2(128),
	DEV_DESCRIPTION               VARCHAR2(255),
	DEVICE_STATUS                 CHAR(1),
	BOOTSTRAPPED                  CHAR(1),
	NEW_DEVICE                    CHAR(1),
	LAST_EVALUATED_TIMESTAMP      DATE,
    JOB_PROFILE_IGNORED           CHAR(1),
  	NOTIFICATION_TYPE             VARCHAR2(32),
	DEVICE_NAME_INUSE             CHAR(1),
    ENROLLED_TIMESTAMP            DATE,
    CREATION_TIMESTAMP            DATE,
	LAST_MODIFIED                 DATE,
	CONSTRAINT DEVICE_PK PRIMARY KEY(COMPUTER_SYS_ID))
;


insert into QUERY_VIEWS (VIEW_NAME) values ('DEVICE');
insert into INVENTORY_TABLES (TABLE_NAME) values ('DEVICE');

-- DROP TABLE MO_TARM_LOCK;
CREATE TABLE MO_TARM_LOCK (
    COMPUTER_SYS_ID               VARCHAR2(64) NOT NULL,
    LOCK_LEVEL                    VARCHAR2(16),
    MAX_AUTO_LOCK                 VARCHAR2(16),
    AUTO_LOCK                     VARCHAR2(16),
    RECORD_TIME                   DATE,
    CONSTRAINT MO_TL_PK PRIMARY KEY(COMPUTER_SYS_ID))
    ;
	
insert into QUERY_VIEWS (VIEW_NAME) values ('MO_TARM_LOCK');
insert into INVENTORY_TABLES (TABLE_NAME) values ('MO_TARM_LOCK');

-- drop view MO_TARM_LOCK_VIEW;
create view MO_TARM_LOCK_VIEW
as
select
    TRM_RESOURCES.LABEL,
    MO_TARM_LOCK.COMPUTER_SYS_ID,
    MO_TARM_LOCK.LOCK_LEVEL,
    MO_TARM_LOCK.MAX_AUTO_LOCK,
    MO_TARM_LOCK.AUTO_LOCK,
    MO_TARM_LOCK.RECORD_TIME
from
    MO_TARM_LOCK, TRM_RESOURCES
where
    MO_TARM_LOCK.COMPUTER_SYS_ID = TRM_RESOURCES.ADDR
;

insert into QUERY_VIEWS (VIEW_NAME) values ('MO_TARM_LOCK_VIEW');


insert into SCHEMA_VERS values ('CM 4.2.3', SYSDATE, 'PATCH',
            'inv_ora_schema_423_FP03.sql', 'FP03 applied to existing installation')
;

commit;


-------------------------------------
-- Multicore section               --
-------------------------------------

alter table LPAR add NODECAP_IN_CORES varchar(64);
alter table LPAR add LPARCAP_IN_CORES varchar(64);
alter table LPAR add SHAREDPC_IN_CORES varchar(64);

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
    LPAR.NODECAP_IN_CORES,
    LPAR.LPAR_CAPACITY,
    LPAR.LPARCAP_IN_CORES,
    LPAR.SHARED_POOL_CAPACITY,
    LPAR.SHAREDPC_IN_CORES,
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
    NODE_CAPACITY,
    NODECAP_IN_CORES
from
    LPAR_VIEW
where
    LPAR_CAPACITY NOT LIKE '-1%'
GROUP BY 
    SERIAL_NUMBER,
    NODE_CAPACITY,
    NODECAP_IN_CORES
;

create or replace view LOGICAL_PARTITIONS_VIEW
as
select
    COMPUTER_NAME,
    SERIAL_NUMBER,
    COMPUTER_SYS_ID,
    LPARID,
    LPAR_CAPACITY,
    LPARCAP_IN_CORES,
    NODE_CAPACITY,
    NODECAP_IN_CORES,
    SHARED_POOL_ID,
    SHARED_POOL_CAPACITY,
    SHAREDPC_IN_CORES,
    RECORD_TIME
from
    LPAR_VIEW
where
    LPAR_CAPACITY NOT LIKE '-1%'
;


-- DROP TABLE PHYSICAL_PROCESSOR;
CREATE TABLE PHYSICAL_PROCESSOR (
       COMPUTER_SYS_ID         VARCHAR(64)  NOT NULL,
       PROCESSOR_ID            VARCHAR(64)  NOT NULL,
       CORE_PER_PK_COUNT       INTEGER,
       LOG_PROC_PER_CORE       INTEGER,
       MANUFACTURER            VARCHAR(64),
       FAMILY                  VARCHAR(64),
       TYPE                    VARCHAR(64),
       CPU_FREQ                INTEGER,
       L2_CACHE_SIZE           INTEGER,
       L3_CACHE_SIZE           INTEGER,
       BRANDNAME               VARCHAR(128),
       SIGNATURE               VARCHAR(128), 
       RECORD_TIME             DATE    DEFAULT SYSDATE,
         CONSTRAINT PHYSPROCESSOR_PK PRIMARY KEY(COMPUTER_SYS_ID,PROCESSOR_ID),
         CONSTRAINT PHYSPROCESSOR_FK FOREIGN KEY(COMPUTER_SYS_ID)
           REFERENCES COMPUTER(COMPUTER_SYS_ID))
;

CREATE OR REPLACE TRIGGER PHYSPROCESSOR_TR
       BEFORE UPDATE ON PHYSICAL_PROCESSOR
       FOR EACH ROW
       BEGIN
         :NEW.RECORD_TIME := SYSDATE;
       END;
/

insert into INVENTORY_TABLES(TABLE_NAME) values ('PHYSICAL_PROCESSOR')
;
      
-- drop view PHYSICAL_PROCESSOR_VIEW;
create or replace view PHYSICAL_PROCESSOR_VIEW
as
select
    COMPUTER.TME_OBJECT_LABEL,
    COMPUTER.TME_OBJECT_ID,
    COMPUTER.COMPUTER_SYS_ID,
    PHYSICAL_PROCESSOR.BRANDNAME,
    PHYSICAL_PROCESSOR.CORE_PER_PK_COUNT,
    PHYSICAL_PROCESSOR.LOG_PROC_PER_CORE,
    PHYSICAL_PROCESSOR.RECORD_TIME
from
    PHYSICAL_PROCESSOR,COMPUTER
where
    PHYSICAL_PROCESSOR.COMPUTER_SYS_ID = COMPUTER.COMPUTER_SYS_ID
;

-- drop view TOT_LOGIC_PROC_VIEW;
create or replace view TOT_LOGIC_PROC_VIEW
as
select
    COMPUTER.TME_OBJECT_LABEL,
    COMPUTER.TME_OBJECT_ID,
    COMPUTER.COMPUTER_SYS_ID,
    PHYSICAL_PROCESSOR.BRANDNAME,
    PHYSICAL_PROCESSOR.CORE_PER_PK_COUNT,
    PHYSICAL_PROCESSOR.LOG_PROC_PER_CORE * PHYSICAL_PROCESSOR.CORE_PER_PK_COUNT AS LOGICAL_PROC,
    PHYSICAL_PROCESSOR.RECORD_TIME
from
    PHYSICAL_PROCESSOR,COMPUTER
where
    PHYSICAL_PROCESSOR.COMPUTER_SYS_ID = COMPUTER.COMPUTER_SYS_ID
;


create or replace view PROCESSOR_NUM_VIEW
as
select distinct
    COMPUTER.TME_OBJECT_LABEL,
    COMPUTER.TME_OBJECT_ID,
    COMPUTER.COMPUTER_SYS_ID,
    count(*) as NUM_PROCESSOR,
    SUM(CORE_PER_PK_COUNT) as NUM_CORE,
    SUM(TOT_LOGIC_PROC_VIEW.LOGICAL_PROC) as NUM_THREAD
from
    COMPUTER,TOT_LOGIC_PROC_VIEW
where
    COMPUTER.COMPUTER_SYS_ID = TOT_LOGIC_PROC_VIEW.COMPUTER_SYS_ID
group by
    COMPUTER.TME_OBJECT_LABEL,COMPUTER.TME_OBJECT_ID,COMPUTER.COMPUTER_SYS_ID
;


insert into QUERY_VIEWS (VIEW_NAME) values ('PHYSICAL_PROCESSOR_VIEW')
;


commit;

-------------------------------------
-- PATCH MANAGEMENT section        --
-------------------------------------


-- drop table INV_GROUP_EP CASCADE CONSTRAINTS;
-- delete from INVENTORY_TABLES
-- where TABLE_NAME = 'INV_GROUP_EP';

-- drop table INV_GROUP CASCADE CONSTRAINTS;
-- delete from INVENTORY_TABLES
-- where TABLE_NAME = 'INV_GROUP';


create table INV_GROUP (
  	GROUP_LABEL		varchar2(64)  not null,
  	GROUP_LABEL_ID		varchar2(128) not null,
        GROUP_DESCR	        varchar2(255) not null,
constraint GROUP_PK primary key(GROUP_LABEL_ID)
);





create table INV_GROUP_EP (
  	GROUP_LABEL_ID          	varchar2(128) not null,
  	COMPUTER_SYS_ID          	varchar2(64) not null,
constraint GROUP_EP_PK primary key(GROUP_LABEL_ID,COMPUTER_SYS_ID),
constraint GROUP_EP_CP_FK foreign key(COMPUTER_SYS_ID)
references COMPUTER(COMPUTER_SYS_ID),
constraint GROUP_EP_FK foreign key(GROUP_LABEL_ID)
references INV_GROUP(GROUP_LABEL_ID)
);

insert into INVENTORY_TABLES(TABLE_NAME) values('INV_GROUP_EP');
-- insert into INVENTORY_TABLES(TABLE_NAME) values('INV_GROUP');
commit
;


-- Views

-------------------------------------
-- View To query for EPs by GROUPS --
-------------------------------------
-- delete from QUERY_VIEWS where VIEW_NAME = 'INV_GRP_EP_VIEW';
create or replace view INV_GRP_EP_VIEW
as
select
  INV_GROUP.GROUP_LABEL,
  INV_GROUP.GROUP_LABEL_ID,
  INV_GROUP_EP.COMPUTER_SYS_ID
from
  INV_GROUP
JOIN
  INV_GROUP_EP
ON
  INV_GROUP.GROUP_LABEL_ID=
  INV_GROUP_EP.GROUP_LABEL_ID
;





insert into QUERY_VIEWS (VIEW_NAME) values ('INV_GRP_EP_VIEW');
commit
;


spool off;

exit;

