/* Program: notify_shipline1.sql 
   This script will update the workflow status of a line
   which is at SHIP_LINE error status and the delivery is confirmed,
   to ship line NOTIFIED status.  Subsequent OM Interface should
   go thorugh without errors.
*/
set serveroutput on
Declare
  l_line_id     NUMBER := &line_id;
  l_org_id      NUMBER;
l_file_val   VARCHAR2(60);

  l_count       NUMBER;
  l_activity_id NUMBER;
  l_result      VARCHAR2(30);

Begin
dbms_output.enable(1000000);
  oe_debug_pub.debug_on;
  oe_debug_pub.initialize;
  l_file_val    := OE_DEBUG_PUB.Set_Debug_Mode('FILE');
  oe_Debug_pub.setdebuglevel(5);
  dbms_output.put_line('File : '||l_file_val);

     OE_Standard_WF.OEOL_SELECTOR
	   (p_itemtype => 'OEOL'
	   ,p_itemkey => to_char(l_line_id)
	   ,p_actid => 12345
	   ,p_funcmode => 'SET_CTX'
	   ,p_result => l_result
	   );

  dbms_output.put_line('Result: '||l_result);

	   select activity_id
	   into l_activity_id
	   from wf_item_activity_statuses_v
	   where item_type = 'OEOL'
	   and activity_name = 'SHIP_LINE'
	   and item_key = to_char(l_line_id)
--	   and activity_status_code = 'COMPLETE'
           and activity_status_code = 'ERROR'
           and rownum =1;

           wf_item_activity_status.create_status('OEOL',to_char(l_line_id),l_activity_id,wf_engine.eng_notified,wf_engine.eng_null,SYSDATE,null);

  dbms_output.put_line('File name '||OE_DEBUG_PUB.G_DIR||'/'||OE_DEBUG_PUB.G_FILE);
End;
/
--rollback;
commit;
exit;

