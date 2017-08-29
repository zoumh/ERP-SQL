UNDEFINE v_headerinfo
DEFINE v_headerinfo = '$Header: WMSCheckLPN.sql 1.1 21-Mar-2003 support'
UNDEFINE v_testlongname
DEFINE   v_testlongname = 'WMS Check License Plate Number'

REM   =========================================================================
REM   PURPOSE:           Assist in troubleshooting transactions where
REM                      LPN is in use, e.g. inspect, putaway, pickload.
REM   PRODUCT:           Oracle Warehouse Management System ( WMS )
REM   PRODUCT VERSIONS:  11.5.x
REM   PLATFORM:          Generic
REM   PARAMETERS:        LICENSE_PLATE_NUMBER
REM   =========================================================================
REM
REM   =========================================================================
REM   CHANGE HISTORY:
REM      30-NOV-2002    G.Angelo    Created initial sqlplus version
REM      21-MAR-2003    G.Schmidt   Complete re-write to plsql so script is
REM                                     completly dynamic and for all levels
REM                                     of WMS.
REM                                 Changed name from INV_SUPS_LPN.sql
REM                                     to WMSCheckLPN.sql
REM
REM   =========================================================================

SET SERVEROUTPUT ON SIZE 1000000
SET VERIFY OFF
SET TERMOUT ON
SET FEEDBACK ON
SET SCAN ON
SET PAGES 0
 
PROMPT
PROMPT &v_headerinfo
PROMPT
 
ACCEPT v_lpn PROMPT 'Please enter Licence Plate Number : '
PROMPT
 
SET HEADING OFF
SET FEEDBACK OFF
SELECT 'Date run: ' || TO_CHAR(SYSDATE, 'DD-MON-YY HH24:MI') FROM DUAL;
SELECT 'Database: ' || name FROM V$DATABASE;
SELECT 'Applications: ' || release_name FROM fnd_product_groups;

PROMPT
SELECT * FROM v$version;
PROMPT
 
PROMPT
PROMPT WMS Related Product Installation Status
SET HEADING ON
SELECT substr( favl.application_short_name,1,6) module,
       fpi.status || '=' || substr( fl.meaning,1,14) status,
       substr( fpi.patch_level,1,15 ) patch_level
  FROM fnd_application_vl favl, fnd_product_installations fpi,
       fnd_lookup_values_vl fl
 WHERE favl.application_short_name in ('INV', 'ONT', 'PO', 'WMS' )
   AND fl.lookup_type = 'FND_PRODUCT_STATUS'
   AND nvl(fpi.status,'N') = fl.lookup_code
   AND fpi.application_id = favl.application_id(+);
 
PROMPT ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PROMPT Analysing LPN related tables and columns Phase - 1 ....
PROMPT Depending on the amount of underlying data to be analysed,
PROMPT the script can run from a couple of seconds to several minutes.
PROMPT ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 
SET HEADING OFF
SET FEEDBACK OFF
SET ECHO OFF
SET LINESIZE 79
SET ARRAY 1
SET TERMOUT ON
 
SET TERMOUT OFF
 
-- I intentionally do NOT include LPN in the spoolfile name
-- because it might happen, special characters are in LPN
SPOOL WMSCheckLPN_Run.sql

PROMPT -- WMSCheckLPN_Run.sql is a generated sql-script from sql-script
PROMPT -- &v_headerinfo
PROMPT -- to gather LPN_ID related data
PROMPT PROMPT &v_headerinfo
PROMPT PROMPT
 
PROMPT SET TERMOUT ON
PROMPT SET HEADING OFF
PROMPT SET FEEDBACK ON
PROMPT SET RECSEPCHAR .
PROMPT SET LONG 80
SET DEFINE ON
 
DECLARE
    l_lpn_id NUMBER;
    l_text VARCHAR2(100);

    -- Get all tables, that have a LPN_ID-Related column
    CURSOR c_lpn_tables IS
        SELECT distinct atc.table_name
          FROM all_tab_columns atc, all_objects ao
         WHERE atc.table_name = ao.object_name
           AND ao.object_type = 'TABLE'
           AND atc.owner = ao.owner
           AND ao.owner = atc.owner
           AND atc.column_name like '%LPN_ID%'
         ORDER BY atc.table_name;
 
PROCEDURE p_ANALYSE_TABLE ( p_table VARCHAR2 ) IS
    l_proc VARCHAR2(30) := 'p_ANALYSE_TABLE';
 
    CURSOR c_lpn_tabs ( p_tabelle VARCHAR2 ) IS
        SELECT '''' hc1, column_name cn1, ' : ' dp, '''' hc2, '||' pipe,
               column_name cn2, ',' komma
          FROM all_tab_columns
         WHERE table_name = p_tabelle
         ORDER BY column_id;
 
    -- Get all columns for given table, that are LPN_ID related
    CURSOR c_lpn_cols ( p_tabelle  VARCHAR2 )IS
        SELECT column_name
          FROM all_tab_columns
         WHERE table_name = p_tabelle
           AND column_name like '%LPN_ID%'
         ORDER BY column_name;
 
BEGIN -- p_ANALYSE_TABLE
    DBMS_OUTPUT.PUT_LINE( '' );
    DBMS_OUTPUT.PUT_LINE( 'PROMPT' );
    DBMS_OUTPUT.PUT_LINE( 'PROMPT Analysing ' || p_table );
    DBMS_OUTPUT.PUT_LINE( 'SELECT ' );
    FOR tabelle IN c_lpn_tabs ( p_table )
    LOOP
        -- We have a special case in table WMS_LABEL_REQUESTS_HIST
        -- column LABEL_CONTENT, which is of type "LONG"
        -- to prevent the ORA-932: inconsistent datatypes
        -- we dont include it in the select
        IF p_table = 'WMS_LABEL_REQUESTS_HIST' AND tabelle.cn1 = 'LABEL_CONTENT'
        THEN
        DBMS_OUTPUT.PUT_LINE( tabelle.hc1 || rpad( tabelle.cn1, 30, ' ') ||
                              tabelle.dp || tabelle.hc2 || tabelle.pipe ||  
                              '''Cannot display LABEL_CONTENT''' || tabelle.komma);

        ELSE
        DBMS_OUTPUT.PUT_LINE( tabelle.hc1 || rpad( tabelle.cn1, 30, ' ') ||
                              tabelle.dp || tabelle.hc2 || tabelle.pipe ||
                              tabelle.cn2 || tabelle.komma);
        END IF;        
    END LOOP;
    l_text := 'New Record ****************************************************';
    DBMS_OUTPUT.PUT_LINE( '''' || l_text || '''' );
    DBMS_OUTPUT.PUT_LINE( 'FROM  ' || p_table );
    -- The WHERE 2=1 is necessary, so we can always append " OR col1=blabla"
    DBMS_OUTPUT.PUT_LINE( 'WHERE   2 = 1 ' );
    FOR spalte IN c_lpn_cols ( p_table )
    LOOP
        dbms_output.put_line( ' OR ' || spalte.column_name || '=' || l_lpn_id );
    END LOOP;
    dbms_output.put_line( '/' );
 
END p_ANALYSE_TABLE;
 
BEGIN  -- MAIN
    SELECT TO_CHAR(SYSDATE, 'DD-MON-YY HH24:MI')
      INTO l_text FROM DUAL;
    DBMS_OUTPUT.PUT_LINE( 'PROMPT Date run: ' || l_text );
 
    SELECT name INTO l_text FROM V$DATABASE;
    DBMS_OUTPUT.PUT_LINE( 'PROMPT Database: ' || l_text );
 
    SELECT release_name INTO l_text FROM fnd_product_groups;
    DBMS_OUTPUT.PUT_LINE( 'PROMPT Applications: ' || l_text );
 
    DBMS_OUTPUT.PUT_LINE( 'SET FEEDBACK OFF' );
    DBMS_OUTPUT.PUT_LINE( 'PROMPT' );
    DBMS_OUTPUT.PUT_LINE( 'SELECT * FROM v$version;' );
    DBMS_OUTPUT.PUT_LINE( 'PROMPT' );
    DBMS_OUTPUT.PUT_LINE( 'SET FEEDBACK ON' );
 
    -- Get lpn_id from user-entered license_plate_number
    SELECT lpn_id
      INTO l_lpn_id
      FROM wms_license_plate_numbers
     WHERE license_plate_number = '&v_lpn' ;
 
    DBMS_OUTPUT.PUT_LINE( 'PROMPT User entered v_lpn : &v_lpn ' );
    DBMS_OUTPUT.PUT_LINE( 'PROMPT l_lpn_id = ' || l_lpn_id );
 
    --BEGIN 
      FOR tabelle IN c_lpn_tables
      LOOP
          if tabelle.table_name = 'WMS_LPN_CONTENTS_BU' 
          then
            p_ANALYSE_TABLE('XNBXZXCVBMCMNCMDHGDJ');
          else
            p_ANALYSE_TABLE( tabelle.table_name );
          end if;
          --p_ANALYSE_TABLE( tabelle.table_name );
      END LOOP;
    -- EXCEPTION
    --  WHEN OTHERS THEN
    --    DBMS_OUTPUT.PUT_LINE( 'Problem with table - Skipping');
    -- END;
    
    DBMS_OUTPUT.PUT_LINE( 'PROMPT End of &v_headerinfo' );
 
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        dbms_output.put_line( 'PROMPT Invalid LICENSE_PLATE_NUMBER. &v_lpn ');
        dbms_output.put_line( 'PROMPT Please rerun script with correct LPN');
    WHEN OTHERS THEN
        dbms_output.put_line( 'Unexpected Error : ' || sqlerrm(sqlcode));
end; -- MAIN

/
 
SET TERMOUT ON
SPOOL OFF
 
PROMPT
PROMPT ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PROMPT Analysing LPN related tables and columns Phase - 2 ....
PROMPT Dependent on what kind of transaction - this is the script can
PROMPT                    run from a couple sec to several minutes.
PROMPT ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 
SPOOL WMSCheckLPN.txt
SET RECSEPCHAR .
SET FEEDBACK ON
@@WMSCheckLPN_Run.sql
SPOOL OFF
 
PROMPT
PROMPT  =======================================================================
PROMPT  Please find output in file WMSCheckLPN.txt
PROMPT  =======================================================================
PROMPT
EXIT
