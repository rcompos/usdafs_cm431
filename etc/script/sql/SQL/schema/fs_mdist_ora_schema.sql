---------------------------------------------------------------------
--
-- Licensed Materials - Property of IBM
--
-- 5698-FRA
--
-- (C) Copyright IBM Corp. 1997, 2003 All Rights Reserved
--
-- US Government Users Restricted Rights - Use, duplication or
-- disclosure restricted by GSA ADP Schedule Contract with
-- IBM Corp
--
---------------------------------------------------------------------

spool fs_mdist_ora_schema.log;

------------
-- TABLES --
------------

DROP TABLE DIST_STATE CASCADE CONSTRAINTS;
CREATE TABLE DIST_STATE (
        ID                              VARCHAR2(32) NOT NULL,
        OWNER                           VARCHAR2(251) NOT NULL,
        LABEL                           VARCHAR2(251) NOT NULL,
        DIST_SIZE                       NUMBER NULL,
        SOURCE_APPLICATION              VARCHAR2(251) NULL,
        SOURCE_NODE                     VARCHAR2(251) NULL,
        START_TIME                      DATE NULL,
        FINISH_TIME                     DATE NULL,
        FINISH_SEC                      NUMBER NULL,
        EXPIRE_TIME                     DATE NULL,
        EXPIRE_SEC                      NUMBER NULL,
        LAST_MODIFY_TIME                DATE NULL,
        LAST_MODIFY_SEC                 NUMBER NULL,
        LAST_OPERATION                  NUMBER NULL,
        TARGET_COUNT                    NUMBER NULL,
        COMPLETED_COUNT                 NUMBER NULL,
        WAITING_COUNT                   NUMBER NULL,
        PAUSED_COUNT                    NUMBER NULL,
        UNAVAILABLE_COUNT               NUMBER NULL,
        RECEIVING_COUNT                 NUMBER NULL,
        INTERRUPTED_COUNT               NUMBER NULL,
        SENDING_COUNT                   NUMBER NULL,
        SUCCESSFUL_COUNT                NUMBER NULL,
        FAILED_COUNT                    NUMBER NULL,
        CANCELED_COUNT                  NUMBER NULL,
        REJECTED_COUNT                  NUMBER NULL,
        EXPIRED_COUNT                   NUMBER NULL,
        WAITING_REPORT                  NUMBER NULL,
        PAUSED_REPORT                   NUMBER NULL,
        UNAVAILABLE_REPORT              NUMBER NULL,
        RECEIVING_REPORT                NUMBER NULL,
        INTERRUPTED_REPORT              NUMBER NULL,
        SENDING_REPORT                  NUMBER NULL,
        SUCCESSFUL_REPORT               NUMBER NULL,
        FAILED_REPORT                   NUMBER NULL,
        CANCELED_REPORT                 NUMBER NULL,
        REJECTED_REPORT                 NUMBER NULL,
        EXPIRED_REPORT                  NUMBER NULL,
        MIN_WAITING_TIME                NUMBER NULL,
        MIN_PAUSED_TIME                 NUMBER NULL,
        MIN_UNAVAIL_TIME                NUMBER NULL,
        MIN_RECEIVING_TIME              NUMBER NULL,
        MIN_INTERRUPT_TIME              NUMBER NULL,
        MIN_SENDING_TIME                NUMBER NULL,
        MAX_WAITING_TIME                NUMBER NULL,
        MAX_PAUSED_TIME                 NUMBER NULL,
        MAX_UNAVAIL_TIME                NUMBER NULL,
        MAX_RECEIVING_TIME              NUMBER NULL,
        MAX_INTERRUPT_TIME              NUMBER NULL,
        MAX_SENDING_TIME                NUMBER NULL,
        TOT_WAITING_TIME                NUMBER NULL,
        TOT_PAUSED_TIME                 NUMBER NULL,
        TOT_UNAVAIL_TIME                NUMBER NULL,
        TOT_RECEIVING_TIME              NUMBER NULL,
        TOT_INTERRUPT_TIME              NUMBER NULL,
        TOT_SENDING_TIME                NUMBER NULL
);

ALTER TABLE DIST_STATE
	ADD ( PRIMARY KEY (ID) ) ;

DROP TABLE DIST_NODE_STATE CASCADE CONSTRAINTS;

CREATE TABLE DIST_NODE_STATE (
        DISTRIBUTION_ID                 VARCHAR2(32) NOT NULL,
        NODE                            VARCHAR2(50) NOT NULL,
        NODE_NAME                       VARCHAR2(251) NULL,
        PARENT_NODE                     VARCHAR2(50) NULL,
        NODE_TYPE                       NUMBER NOT NULL,
        CURRENT_STATE                   NUMBER NULL,
        PREVIOUS_STATE                  NUMBER NULL,
        ERROR_MSG                       VARCHAR2(251) NULL,
        ERROR_ARGS                      VARCHAR2(251) NULL,
        START_TIME                      DATE NULL,
        FINISH_TIME                     DATE NULL,
        LAST_MODIFY_TIME                DATE NULL,
        LAST_MODIFY_SEC                 NUMBER NULL,
        INTERRUPTION_COUNT              NUMBER NULL,
        UNAVAILABLE_TIME                NUMBER NULL,
        RECEIVING_TIME                  NUMBER NULL,
        INTERRUPTED_TIME                NUMBER NULL,
        SENDING_TIME                    NUMBER NULL
);

ALTER TABLE DIST_NODE_STATE
	ADD ( PRIMARY KEY (DISTRIBUTION_ID, NODE, NODE_TYPE) );

commit;

spool off;

exit

