--
-- Licensed Materials - Property of IBM 
--
-- (C) Copyright IBM Corp. 2002, 2008 All Rights Reserved
-- US Government Users Restricted Rights - Use, duplication 
-- or disclosure restricted by GSA ADP Schedule Contract with 
-- IBM Corp.
--
-- IBM Tivoli Configuration Manager 4.3.1 
-- Change Manager
-- Database schema creation script 
-- Platform: Oracle
--

spool fs_ccm_ora_schema.log;

------------
-- TABLES --
------------

-- Dropping existing tables --

--DROP TABLE DEPENDENCY;

--DROP TABLE ELEMENT;

--DROP TABLE SUBSCRIBER;

--DROP TABLE REFERENCE_MODEL;

--DROP TABLE COMP_ATTRIBUTES;

--DROP TABLE CCM_REPORT;

--DROP TABLE CCM_SYNCH;

--DROP TABLE CCM_COMP;

--DROP TABLE CCM_PLUGIN;

--DROP TABLE CCM_PLUGIN_FILES;

--DROP TABLE CCM_WEBUI_PACKAGES;

-- Creating tables and constraints --

 
 CREATE TABLE REFERENCE_MODEL (
        REF_MODEL_ID   VARCHAR2(32) NOT NULL,
        NAME           VARCHAR2(64) NOT NULL,
        VER            VARCHAR2(16) NULL,
        DESCRIP        VARCHAR2(255)NULL,
        PARENT         VARCHAR2(32) NULL,
        LAST_UPDATE    DATE NULL,
        IS_LEAF        INTEGER NOT NULL,
        ROOT_ID        VARCHAR(32) NULL
 );

 
 
 ALTER TABLE REFERENCE_MODEL
        ADD (PRIMARY KEY (REF_MODEL_ID));
 

 
 CREATE TABLE ELEMENT (
        ELEMENT_ID     VARCHAR2(32)  NOT NULL,
        NAME           VARCHAR2(255) NOT NULL,
        TYPE           VARCHAR2(64)  NOT NULL,
        DESIRED_STATE  VARCHAR2(64)  NULL,
        REF_MODEL_ID   VARCHAR2(32)  NOT NULL
 );
 
 
 ALTER TABLE ELEMENT
        ADD (PRIMARY KEY (ELEMENT_ID));

 ALTER TABLE ELEMENT ADD CONSTRAINT FK_ELEMENT
    FOREIGN KEY (REF_MODEL_ID)
    REFERENCES REFERENCE_MODEL(REF_MODEL_ID);
        


 CREATE TABLE DEPENDENCY (
        DEPENDENCY_ID     VARCHAR2(32) NOT NULL,
        NAME              VARCHAR2(64) NOT NULL,
        TYPE              VARCHAR2(64) NOT NULL,
        STATE             VARCHAR2(64) NULL,
        ELEMENT_ID        VARCHAR2(32) NOT NULL
 );
 
 
 ALTER TABLE DEPENDENCY
        ADD (PRIMARY KEY (DEPENDENCY_ID));

 ALTER TABLE DEPENDENCY ADD CONSTRAINT FK_DEPENDENCY
    FOREIGN KEY (ELEMENT_ID)
    REFERENCES ELEMENT(ELEMENT_ID);
 

 CREATE TABLE SUBSCRIBER (
        SUBSCRIBER_ID     VARCHAR2(32) NOT NULL,
        NAME              VARCHAR2(255) NOT NULL,
        TYPE              VARCHAR2(64) NOT NULL,
        EXCLUDED          INTEGER NULL,
        PARENT_ID         VARCHAR2(32) NOT NULL,
        REF_MODEL_ID      VARCHAR2(32) NOT NULL
 );
 
 
 ALTER TABLE SUBSCRIBER
        ADD (PRIMARY KEY (SUBSCRIBER_ID));

 ALTER TABLE SUBSCRIBER ADD CONSTRAINT FK_SUBSCRIBER
    FOREIGN KEY (REF_MODEL_ID)
    REFERENCES REFERENCE_MODEL(REF_MODEL_ID);


 CREATE TABLE COMP_ATTRIBUTES (
        COMP_ID             VARCHAR(32) NOT NULL,
        ATTR_NAME           VARCHAR(64) NOT NULL,
        ATTR_VALUE          VARCHAR(64) NOT NULL
 );
 
 
 ALTER TABLE COMP_ATTRIBUTES
        ADD (PRIMARY KEY (COMP_ID, ATTR_NAME));



 
 CREATE TABLE CCM_REPORT (
        PLAN_ID             VARCHAR2(32) NOT NULL,
        REFERENCE_MODEL     VARCHAR2(64) NOT NULL,
        TARGET_NAME         VARCHAR2(64) NOT NULL,
        TARGET_TYPE         VARCHAR2(64) NULL,
        SUBMIT_TIME         DATE NULL,
        RECEIVE_TIME        DATE NULL,
        PLAN_STATUS         VARCHAR2(64) NOT NULL,
        SYNCH_ID            VARCHAR(32)
 );

 
 ALTER TABLE CCM_REPORT
        ADD (PRIMARY KEY (REFERENCE_MODEL, TARGET_NAME));


 CREATE TABLE CCM_SYNCH (
        SYNCH_ID            VARCHAR(32) NOT NULL,
        REFERENCE_MODEL     VARCHAR(64) NOT NULL,
        TARGET_NAME         VARCHAR(64) NOT NULL,
        TARGET_TYPE         VARCHAR(64),
        SYNCH_TIME          DATE NOT NULL
 );
 
 
 ALTER TABLE CCM_SYNCH
        ADD PRIMARY KEY (SYNCH_ID, REFERENCE_MODEL, TARGET_NAME);

    

 CREATE TABLE CCM_PLUGIN (
        APP_NAME        VARCHAR(64) NOT NULL,
        CLASSPATH       VARCHAR(255) NULL,
        DESCRIP         VARCHAR(255) NULL,
        PACKAGE         VARCHAR(64) NOT NULL        
 );

 
 
 ALTER TABLE CCM_PLUGIN
        ADD (PRIMARY KEY (APP_NAME));


 CREATE TABLE CCM_COMP (
        COMP_KEY           VARCHAR(110) NOT NULL,
        COMP_TYPE          VARCHAR(32) NOT NULL,
        COMP_CLASS         VARCHAR(128) NOT NULL,
        PARENT_REF         VARCHAR(110) NOT NULL,
        DESCRIP            VARCHAR(255) NULL,
        APP_NAME           VARCHAR(64) NOT NULL
 );

 
 
 ALTER TABLE CCM_COMP
        ADD (PRIMARY KEY (COMP_KEY, COMP_TYPE, PARENT_REF));



 CREATE TABLE CCM_PLUGIN_FILES (
        APP_NAME        VARCHAR(64) NOT NULL,
        FILE_NAME       VARCHAR(255) NOT NULL,
        CRC32           VARCHAR(32) NOT NULL        
 );
 

 ALTER TABLE CCM_PLUGIN_FILES
        ADD PRIMARY KEY (APP_NAME, FILE_NAME);




--
-- THE FOLLOWING TABLE IS COMPLETELY MANAGED BY WEB UI 
--

 CREATE TABLE CCM_WEBUI_PACKAGES (
        REF_MOD_NAME       VARCHAR(64) NOT NULL,       
        REF_MOD_VERS       VARCHAR(16) NOT NULL,
        TME_ADMIN_ID       VARCHAR(64) NULL,
        EXEC_TIME          VARCHAR(32) NULL,
        WEB_PACKAGE_NAME   VARCHAR(254) NULL,
        WEB_PACKAGE_VERS   VARCHAR(32) NULL,
        COMPUTER_SYS_ID    VARCHAR(64) NOT NULL
 );
 
 
 ALTER TABLE CCM_WEBUI_PACKAGES
        ADD PRIMARY KEY (REF_MOD_NAME, REF_MOD_VERS, COMPUTER_SYS_ID);



--
-- INSERT CONFIGURATION DATA IN TABLE 
--

INSERT INTO CCM_COMP (COMP_KEY, 
                      COMP_TYPE, 
                      COMP_CLASS, 
                      PARENT_REF, 
                      APP_NAME)
VALUES ('com.tivoli.ccm.data.ApmSyncProtocol', 
        'sync_protocol', 
        'com.tivoli.ccm.data.ApmSyncProtocol', 
        'CCM', 
        'CCM');


INSERT INTO CCM_COMP (COMP_KEY, 
                      COMP_TYPE, 
                      COMP_CLASS, 
                      PARENT_REF, 
                      APP_NAME)
VALUES ('com.tivoli.ccm.policy.apmSync.ApmSubmitPanel', 
        'panel', 
        'com.tivoli.ccm.policy.apmSync.ApmSubmitPanel', 
        'com.tivoli.ccm.data.ApmSyncProtocol', 
        'CCM');


INSERT INTO CCM_COMP (COMP_KEY, 
                      COMP_TYPE, 
                      COMP_CLASS, 
                      PARENT_REF, 
                      APP_NAME)
VALUES ('com.tivoli.ccm.policy.TMESecurityPolicy', 
        'security_policy', 
        'com.tivoli.ccm.policy.TMESecurityPolicy', 
        'CCM', 
        'CCM');

INSERT INTO CCM_COMP (COMP_KEY, 
                      COMP_TYPE, 
                      COMP_CLASS, 
                      PARENT_REF, 
                      APP_NAME)
VALUES ('com.tivoli.ccm.data.JRIMReportManager', 
        'report_info', 
        'com.tivoli.ccm.data.JRIMReportManager', 
        'CCM', 
        'CCM');
        

INSERT INTO CCM_COMP (COMP_KEY, 
                      COMP_TYPE, 
                      COMP_CLASS, 
                      PARENT_REF, 
                      APP_NAME)
VALUES ('com.tivoli.ccm.data.FilterManager', 
        'filter_info', 
        'com.tivoli.ccm.data.FilterManager', 
        'CCM', 
        'CCM');


INSERT INTO CCM_COMP (COMP_KEY, 
                      COMP_TYPE, 
                      COMP_CLASS, 
                      PARENT_REF, 
                      DESCRIP,
                      APP_NAME)
VALUES ('com.tivoli.ccm.data.DefaultFilterPolicy', 
        'strategy', 
        'com.tivoli.ccm.data.DefaultFilterPolicy', 
        'CCM', 
        'SubscribersFiltering',
        'CCM');


INSERT INTO CCM_COMP (COMP_KEY, 
                      COMP_TYPE, 
                      COMP_CLASS, 
                      PARENT_REF, 
                      APP_NAME)
VALUES ('com.tivoli.ccm.data.ValidationManager', 
        'validation_info', 
        'com.tivoli.ccm.data.ValidationManager', 
        'CCM', 
        'CCM');



--
-- INSERT SUBSCRIBER SPECIFIC INFORMATION
--
--
-- CSV subscriber --
--

INSERT INTO CCM_COMP (COMP_KEY, 
                      COMP_TYPE, 
                      COMP_CLASS, 
                      PARENT_REF, 
                      APP_NAME)
VALUES ('com.tivoli.ccm.data.CSVSubscriber', 
        'subscriber', 
        'com.tivoli.ccm.data.CSVSubscriber', 
        'CCM', 
        'CCM');


INSERT INTO CCM_COMP (COMP_KEY, 
                      COMP_TYPE, 
                      COMP_CLASS, 
                      PARENT_REF, 
                      APP_NAME)
VALUES ('/com/tivoli/ccm/configuration/editor/images/subscribers_s.gif', 
        'icon', 
        '/com/tivoli/ccm/configuration/editor/images/subscribers_s.gif', 
        'com.tivoli.ccm.data.CSVSubscriber', 
        'CCM');

INSERT INTO CCM_COMP (COMP_KEY, 
                      COMP_TYPE, 
                      COMP_CLASS, 
                      PARENT_REF, 
                      APP_NAME)
VALUES ('com.tivoli.ccm.navigator.gui.subscriber.SubscriberFromFile', 
        'panel', 
        'com.tivoli.ccm.navigator.gui.subscriber.SubscriberFromFile', 
        'com.tivoli.ccm.data.CSVSubscriber', 
        'CCM');

--
-- Profile Manager subscriber --
--

INSERT INTO CCM_COMP (COMP_KEY, 
                      COMP_TYPE, 
                      COMP_CLASS, 
                      PARENT_REF, 
                      APP_NAME)
VALUES ('com.tivoli.ccm.data.ProfileManagerSubscriber', 
        'subscriber', 
        'com.tivoli.ccm.data.ProfileManagerSubscriber', 
        'CCM', 
        'CCM');


INSERT INTO CCM_COMP (COMP_KEY, 
                      COMP_TYPE, 
                      COMP_CLASS, 
                      PARENT_REF, 
                      APP_NAME)
VALUES ('/com/tivoli/ccm/configuration/editor/images/subscribers_s.gif', 
        'icon', 
        '/com/tivoli/ccm/configuration/editor/images/subscribers_s.gif', 
        'com.tivoli.ccm.data.ProfileManagerSubscriber', 
        'CCM');

INSERT INTO CCM_COMP (COMP_KEY, 
                      COMP_TYPE, 
                      COMP_CLASS, 
                      PARENT_REF, 
                      APP_NAME)
VALUES ('com.tivoli.ccm.navigator.gui.subscriber.SubscriberFromTME', 
        'panel', 
        'com.tivoli.ccm.navigator.gui.subscriber.SubscriberFromTME', 
        'com.tivoli.ccm.data.ProfileManagerSubscriber', 
        'CCM');


--
-- Static subscriber --
--

INSERT INTO CCM_COMP (COMP_KEY, 
                      COMP_TYPE, 
                      COMP_CLASS, 
                      PARENT_REF, 
                      APP_NAME)
VALUES ('com.tivoli.ccm.data.StaticSubscriber', 
        'subscriber', 
        'com.tivoli.ccm.data.StaticSubscriber', 
        'CCM', 
        'CCM');


INSERT INTO CCM_COMP (COMP_KEY, 
                      COMP_TYPE, 
                      COMP_CLASS, 
                      PARENT_REF, 
                      APP_NAME)
VALUES ('/com/tivoli/ccm/configuration/editor/images/subscribers_s.gif', 
        'icon', 
        '/com/tivoli/ccm/configuration/editor/images/subscribers_s.gif', 
        'com.tivoli.ccm.data.StaticSubscriber', 
        'CCM');

INSERT INTO CCM_COMP (COMP_KEY, 
                      COMP_TYPE, 
                      COMP_CLASS, 
                      PARENT_REF, 
                      APP_NAME)
VALUES ('com.tivoli.ccm.navigator.gui.subscriber.SubscriberEndpointFromTME', 
        'panel', 
        'com.tivoli.ccm.navigator.gui.subscriber.SubscriberEndpointFromTME', 
        'com.tivoli.ccm.data.StaticSubscriber', 
        'CCM');


--
-- Query Library subscriber --
--

INSERT INTO CCM_COMP (COMP_KEY, 
                      COMP_TYPE, 
                      COMP_CLASS, 
                      PARENT_REF, 
                      APP_NAME)
VALUES ('com.tivoli.ccm.data.QueryLibrarySubscriber', 
        'subscriber', 
        'com.tivoli.ccm.data.QueryLibrarySubscriber', 
        'CCM', 
        'CCM');


INSERT INTO CCM_COMP (COMP_KEY, 
                      COMP_TYPE, 
                      COMP_CLASS, 
                      PARENT_REF, 
                      APP_NAME)
VALUES ('/com/tivoli/ccm/configuration/editor/images/subscribers_s.gif', 
        'icon', 
        '/com/tivoli/ccm/configuration/editor/images/subscribers_s.gif', 
        'com.tivoli.ccm.data.QueryLibrarySubscriber', 
        'CCM');

INSERT INTO CCM_COMP (COMP_KEY, 
                      COMP_TYPE, 
                      COMP_CLASS, 
                      PARENT_REF, 
                      APP_NAME)
VALUES ('com.tivoli.ccm.navigator.gui.subscriber.SubscriberFromQueryLibrary', 
        'panel', 
        'com.tivoli.ccm.navigator.gui.subscriber.SubscriberFromQueryLibrary', 
        'com.tivoli.ccm.data.QueryLibrarySubscriber', 
        'CCM');


--
-- Query Directory Library subscriber --
--

INSERT INTO CCM_COMP (COMP_KEY, 
                      COMP_TYPE, 
                      COMP_CLASS, 
                      PARENT_REF, 
                      APP_NAME)
VALUES ('com.tivoli.ccm.data.QueryDirectoryLibrarySubscriber', 
        'subscriber', 
        'com.tivoli.ccm.data.QueryDirectoryLibrarySubscriber', 
        'CCM', 
        'CCM');


INSERT INTO CCM_COMP (COMP_KEY, 
                      COMP_TYPE, 
                      COMP_CLASS, 
                      PARENT_REF, 
                      APP_NAME)
VALUES ('/com/tivoli/ccm/configuration/editor/images/subscribers_s.gif', 
        'icon', 
        '/com/tivoli/ccm/configuration/editor/images/subscribers_s.gif', 
        'com.tivoli.ccm.data.QueryDirectoryLibrarySubscriber', 
        'CCM');
        

INSERT INTO CCM_COMP (COMP_KEY, 
                      COMP_TYPE, 
                      COMP_CLASS, 
                      PARENT_REF, 
                      APP_NAME)
VALUES ('com.tivoli.ccm.navigator.gui.subscriber.SubscriberFromQueryDirectoryLibrary', 
        'panel', 
        'com.tivoli.ccm.navigator.gui.subscriber.SubscriberFromQueryDirectoryLibrary', 
        'com.tivoli.ccm.data.QueryDirectoryLibrarySubscriber', 
        'CCM');


--
-- INSERT DEFAULT SUPPORTED SUBSCRIBER TYPES
--
--
-- EndpointType --
--

INSERT INTO CCM_COMP (COMP_KEY, 
                      COMP_TYPE, 
                      COMP_CLASS, 
                      PARENT_REF, 
                      DESCRIP,
                      APP_NAME)
VALUES ('com.tivoli.ccm.data.EndpointType', 
        'subscriber_type', 
        'com.tivoli.ccm.data.EndpointType', 
        'CCM', 
        'Endpoint',
        'CCM');


INSERT INTO CCM_COMP (COMP_KEY, 
                      COMP_TYPE, 
                      COMP_CLASS, 
                      PARENT_REF, 
                      APP_NAME)
VALUES ('com.tivoli.ccm.configuration.NLSResources', 
		'bundle', 
		'com.tivoli.ccm.configuration.NLSResources', 
		'com.tivoli.ccm.data.EndpointType',
		'CCM');


--
--
-- DeviceType --
--

INSERT INTO CCM_COMP (COMP_KEY, 
                      COMP_TYPE, 
                      COMP_CLASS, 
                      PARENT_REF, 
                      DESCRIP,
                      APP_NAME)
VALUES ('com.tivoli.ccm.data.DeviceType', 
        'subscriber_type', 
        'com.tivoli.ccm.data.DeviceType', 
        'CCM', 
        'Device',
        'CCM');


INSERT INTO CCM_COMP (COMP_KEY, 
                      COMP_TYPE, 
                      COMP_CLASS, 
                      PARENT_REF, 
                      APP_NAME)
VALUES ('com.tivoli.ccm.configuration.NLSResources', 
		'bundle', 
		'com.tivoli.ccm.configuration.NLSResources', 
		'com.tivoli.ccm.data.DeviceType',
		'CCM');

--
--
-- UserType --
--

INSERT INTO CCM_COMP (COMP_KEY, 
                      COMP_TYPE, 
                      COMP_CLASS, 
                      PARENT_REF, 
                      DESCRIP,
                      APP_NAME)
VALUES ('com.tivoli.ccm.data.UserType', 
        'subscriber_type', 
        'com.tivoli.ccm.data.UserType', 
        'CCM', 
        'User',
        'CCM');


INSERT INTO CCM_COMP (COMP_KEY, 
                      COMP_TYPE, 
                      COMP_CLASS, 
                      PARENT_REF, 
                      APP_NAME)
VALUES ('com.tivoli.ccm.configuration.NLSResources', 
		'bundle', 
		'com.tivoli.ccm.configuration.NLSResources', 
		'com.tivoli.ccm.data.UserType',
		'CCM');


--
-- THE FOLLOWING IS FOR BACK-WARD COMPATIBILITY
--

INSERT INTO CCM_COMP (COMP_KEY, 
                      COMP_TYPE, 
                      COMP_CLASS, 
                      PARENT_REF, 
                      APP_NAME)
VALUES ('com.tivoli.ccm.data.SWDElement', 
        'element', 
        'com.tivoli.ccm.plugin.sd.data.SWDElement', 
        'CCM', 
        'CCM');
 
INSERT INTO CCM_COMP (COMP_KEY, 
                      COMP_TYPE, 
                      COMP_CLASS, 
                      PARENT_REF, 
                      APP_NAME)
VALUES 
('/com/tivoli/ccm/configuration/editor/images/software_package_t.gif', 
 'icon', 
 '/com/tivoli/ccm/plugin/sd/gui/element/icons/software_package_t.gif', 
 'com.tivoli.ccm.data.SWDElement', 
 'CCM');


INSERT INTO CCM_COMP (COMP_KEY, 
                      COMP_TYPE, 
                      COMP_CLASS, 
                      PARENT_REF, 
                      APP_NAME)
VALUES ('com.tivoli.ccm.navigator.gui.element.SWDElementPanel', 
        'panel', 
        'com.tivoli.ccm.plugin.sd.gui.element.SWDElementPanel', 
        'com.tivoli.ccm.data.SWDElement', 
        'CCM');

INSERT INTO CCM_COMP (COMP_KEY, 
                      COMP_TYPE, 
                      COMP_CLASS, 
                      PARENT_REF, 
                      APP_NAME)
VALUES ('com.tivoli.ccm.data.SWDExReq', 
        'dependence', 
        'com.tivoli.ccm.plugin.sd.data.SWDExReq', 
        'com.tivoli.ccm.data.SWDElement', 
        'CCM');

INSERT INTO CCM_COMP (COMP_KEY, 
                      COMP_TYPE, 
                      COMP_CLASS, 
                      PARENT_REF, 
                      APP_NAME)
VALUES (
'com.tivoli.ccm.navigator.gui.element.SWDElementDependencyPanel', 
'panel', 
'com.tivoli.ccm.plugin.sd.gui.element.SWDElementDependencyPanel', 
'com.tivoli.ccm.data.SWDExReq', 
'CCM');

INSERT INTO CCM_COMP (COMP_KEY, 
                      COMP_TYPE, 
                      COMP_CLASS, 
                      PARENT_REF, 
                      APP_NAME)
VALUES ('com.tivoli.ccm.data.SWDPreReq', 
        'dependence', 
        'com.tivoli.ccm.plugin.sd.data.SWDPreReq', 
        'com.tivoli.ccm.data.SWDElement', 
        'CCM');

INSERT INTO CCM_COMP (COMP_KEY, 
                      COMP_TYPE, 
                      COMP_CLASS, 
                      PARENT_REF, 
                      APP_NAME)
VALUES (
'com.tivoli.ccm.navigator.gui.element.SWDElementDependencyPanel', 
'panel', 
'com.tivoli.ccm.plugin.sd.gui.element.SWDElementDependencyPanel', 
'com.tivoli.ccm.data.SWDPreReq', 
'CCM');

INSERT INTO CCM_COMP (COMP_KEY, 
                      COMP_TYPE, 
                      COMP_CLASS, 
                      PARENT_REF, 
                      APP_NAME)
VALUES ('com.tivoli.ccm.data.SWDCoReq', 
        'dependence', 
        'com.tivoli.ccm.plugin.sd.data.SWDCoReq', 
        'com.tivoli.ccm.data.SWDElement', 
        'CCM');

INSERT INTO CCM_COMP (COMP_KEY, 
                      COMP_TYPE, 
                      COMP_CLASS, 
                      PARENT_REF, 
                      APP_NAME)
VALUES (
'com.tivoli.ccm.navigator.gui.element.SWDElementDependencyPanel', 
'panel', 
'com.tivoli.ccm.plugin.sd.gui.element.SWDElementDependencyPanel', 
'com.tivoli.ccm.data.SWDCoReq', 
'CCM');

INSERT INTO CCM_COMP (COMP_KEY, 
                      COMP_TYPE, 
                      COMP_CLASS, 
                      PARENT_REF, 
                      APP_NAME)
VALUES ('com.tivoli.ccm.data.INVElement', 
        'element', 
        'com.tivoli.ccm.plugin.inv.data.INVElement', 
        'CCM', 
        'CCM');
 
INSERT INTO CCM_COMP (COMP_KEY, 
                      COMP_TYPE, 
                      COMP_CLASS, 
                      PARENT_REF, 
                      APP_NAME)
VALUES ('/com/tivoli/ccm/configuration/editor/images/wiz.gif', 
        'icon', 
        '/com/tivoli/ccm/plugin/inv/gui/element/icons/wiz.gif', 
        'com.tivoli.ccm.data.INVElement', 
        'CCM');

INSERT INTO CCM_COMP (COMP_KEY, 
                      COMP_TYPE, 
                      COMP_CLASS, 
                      PARENT_REF, 
                      APP_NAME)
VALUES ('com.tivoli.ccm.navigator.gui.element.InventoryElementPanel', 
        'panel', 
        'com.tivoli.ccm.plugin.inv.gui.element.InventoryElementPanel', 
        'com.tivoli.ccm.data.INVElement', 
        'CCM');


INSERT INTO CCM_COMP (COMP_KEY, 
                      COMP_TYPE, 
                      COMP_CLASS, 
                      PARENT_REF, 
                      APP_NAME)
VALUES ('com.tivoli.ccm.data.INVSubscriber', 
        'subscriber', 
        'com.tivoli.ccm.plugin.inv.data.INVSubscriber', 
        'CCM', 
        'CCM');


INSERT INTO CCM_COMP (COMP_KEY, 
                      COMP_TYPE, 
                      COMP_CLASS, 
                      PARENT_REF, 
                      APP_NAME)
VALUES ('/com/tivoli/ccm/configuration/editor/images/subscribers_s.gif', 
        'icon', 
        '/com/tivoli/ccm/configuration/editor/images/subscribers_s.gif', 
        'com.tivoli.ccm.data.INVSubscriber', 
        'CCM');

INSERT INTO CCM_COMP (COMP_KEY, 
                      COMP_TYPE, 
                      COMP_CLASS, 
                      PARENT_REF, 
                      APP_NAME)
VALUES ('com.tivoli.ccm.navigator.gui.subscriber.SubscriberFromInventory', 
        'panel', 
        'com.tivoli.ccm.plugin.inv.gui.subscriber.SubscriberFromInventory', 
        'com.tivoli.ccm.data.INVSubscriber', 
        'CCM');

INSERT INTO CCM_COMP (COMP_KEY, 
                      COMP_TYPE, 
                      COMP_CLASS, 
                      PARENT_REF, 
                      APP_NAME)
VALUES ('com.tivoli.ccm.plugin.inv.data.InvPluginNLSResources', 
        'bundle', 
        'com.tivoli.ccm.plugin.inv.data.InvPluginNLSResources', 
        'com.tivoli.ccm.data.INVSubscriber', 
        'CCM');


COMMIT;

spool off;

exit

