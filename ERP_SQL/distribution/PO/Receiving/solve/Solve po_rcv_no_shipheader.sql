-- check the data in rcv_txn have the rcv_ship number mapping
Select 	Shipment_Header_Id
From   Apps.Rcv_Transactions rcv
Where ORGANIZATION_ID=	130
Minus
Select SHIPMENT_HEADER_ID
From   Apps.Rcv_Shipment_Headers Rch

254863

--------List PO Info by Shipment_Header_Id
select a.creation_date ,a.quantity,a.DESTINATION_TYPE_CODE,
a.transaction_type,c.SEGMENT1 PO,d.LINE_NUM,b.segment1 Item,
a.PO_UNIT_PRICE,a.CURRENCY_CONVERSION_RATE,a.quantity Qty_DB,a.CURRENCY_CODE 
from apps.rcv_transactions a,
apps.PO_HEADERS_ALL c,
apps.PO_LINES_ALL d,apps.mtl_system_items b
where 
a.source_document_code='PO'
and a.PO_HEADER_ID =c.PO_HEADER_ID
and d.PO_HEADER_ID =c.PO_HEADER_ID
and a.PO_LINE_ID =d.PO_LINE_ID 
and Shipment_Header_Id in (286308,303232,305272)
and b.ORGANIZATION_ID =a.ORGANIZATION_ID
and b.INVENTORY_ITEM_ID =d.item_id
order by c.segment1,d.LINE_NUM,a.creation_date


-------List Rcv_Trans for this PO line , compare with Form Qty & PO summary Rev_Qty,to decide how to treate with  these Qty

PO line Receive Qty (from PO summary)
PO line Receive Qty (from PO Transaction summary form)
PO line Receive Qty (from rcv_transactions)

---list rev_transction summary the Qty by PO.line,type 
select  sum(a.quantity) Qty,a.DESTINATION_TYPE_CODE,Shipment_Header_Id,
a.transaction_type,c.SEGMENT1 PO,d.LINE_NUM,b.segment1 Item
from apps.rcv_transactions a,
apps.PO_HEADERS_ALL c,
apps.PO_LINES_ALL d,apps.mtl_system_items b
where 
a.source_document_code='PO'
and a.PO_HEADER_ID =c.PO_HEADER_ID
and d.PO_HEADER_ID =c.PO_HEADER_ID
and a.PO_LINE_ID =d.PO_LINE_ID 
and b.ORGANIZATION_ID =a.ORGANIZATION_ID
and b.INVENTORY_ITEM_ID =d.item_id
and c.segment1='1061190'
and d.LINE_NUM='1'
group by a.DESTINATION_TYPE_CODE,
a.transaction_type,c.SEGMENT1,d.LINE_NUM,b.segment1 ,Shipment_Header_Id


-----need to confirm with Buyer about the actual PO receive Qty !

		
-- check the receipt number
Select Po_Header_Id, Po_Line_Id, vendor_id,vendor_site_id,Transaction_Type, Transfer_Lpn_Id, Shipment_Header_Id,rcv.*
From   Apps.Rcv_Transactions rcv
Where  Shipment_Header_Id In (254863,254858)


PO_HEADER_ID	PO_LINE_ID
116267	166387
116267	166387

-- check the near receipt number --same PO
Select  last_update_date,Shipment_Header_Id,rch.RECEIPT_NUM,rch.*
From Apps.Rcv_Shipment_Headers Rch
Where TO_CHAR(last_update_date,'YYYYMMDD')>='200600109'
  And Shipment_Header_Id In (Select Shipment_Header_Id From apps.Rcv_Transactions
	Where Po_Header_Id = 116267 
  -- And PO_LINE_ID =166387
	 )

2006-1-9 
-- check the receipt number not using 
Select * From Apps.Rcv_Shipment_Headers Rch
Where RECEIPT_NUM = 402600

Insert Into apps.Rcv_Shipment_Headers
     (Receipt_Source_Code, Vendor_Id, Receipt_Num, Shipment_Header_Id, Last_Update_Date, Creation_Date, Organization_Id,
      Ship_To_Org_Id, Last_Updated_By, Created_By, Last_Update_Login, Vendor_Site_Id, Employee_Id)
     Select 'VENDOR', Vendor_Id, '402600', '254863', Last_Update_Date, Creation_Date, Organization_Id, Ship_To_Org_Id,
                    Last_Updated_By, Created_By, Last_Update_Login, Vendor_Site_Id, Employee_Id
     From Apps.Rcv_Shipment_Headers
     Where  Shipment_Header_Id In (254858)





----------------My :

-- Find the PO_Header from Shipment_Header_Id
Select Po_Header_Id, Po_Line_Id, vendor_id,vendor_site_id,Transaction_Type, Transfer_Lpn_Id, Shipment_Header_Id,rcv.*
From   Apps.Rcv_Transactions rcv
Where  Shipment_Header_Id In (408231)


--------List PO Info by Shipment_Header_Id
select a.creation_date ,a.quantity,a.DESTINATION_TYPE_CODE,TRANSACTION_ID,
a.transaction_type,c.SEGMENT1 PO,d.LINE_NUM,b.segment1 Item,
a.PO_UNIT_PRICE,a.CURRENCY_CONVERSION_RATE,a.quantity Qty_DB,a.CURRENCY_CODE 
from apps.rcv_transactions a,
apps.PO_HEADERS_ALL c,
apps.PO_LINES_ALL d,apps.mtl_system_items b
where 
a.source_document_code='PO'
and a.PO_HEADER_ID =c.PO_HEADER_ID
and d.PO_HEADER_ID =c.PO_HEADER_ID
and a.PO_LINE_ID =d.PO_LINE_ID 
and Shipment_Header_Id =1170476
and b.ORGANIZATION_ID =a.ORGANIZATION_ID
and b.INVENTORY_ITEM_ID =d.item_id
order by c.segment1,d.LINE_NUM,a.creation_date


------------Make sure this record has booking accounting (rcv accrual)
select 
g.CREATION_DATE,g.GL_SL_LINK_ID,g.RCV_TRANSACTION_ID,
--g.JE_BATCH_NAME,g.JE_CATEGORY_NAME,--g.JE_SOURCE_NAME,
a.TRANSACTION_ID,b.segment1 PO,c.LINE_NUM Line,d.segment1 Item,a.transaction_date,
c.UNIT_PRICE,b.CURRENCY_CODE Curr,a.transaction_type,a.quantity,
g.ACCOUNTED_DR,g.ACCOUNTED_CR,h.segment3 Account
from apps.rcv_transactions a,apps.PO_LINES_ALL c,apps.PO_HEADERS_ALL b,apps.PO_VENDORS VDR,
apps.mtl_system_items d, apps.PO_VENDOR_SITES_ALL e,APPS.mtl_parameters f,
APPS.RCV_RECEIVING_SUB_LEDGER g,apps.GL_CODE_combinations h
where c.po_header_id=b.po_header_id --and a.transaction_type='RECEIVE'
and a.source_document_code='PO'
and a.organization_id>127
and VDR.VENDOR_ID=b.VENDOR_ID
--and a.transaction_type in ('RETURN TO VENDOR','RECEIVE','CORRECT')
and c.org_id=b.org_id
and c.org_id>=127
--and DESTINATION_TYPE_CODE='RECEIVING'
--and c.line_type_id not in (1020,1021) ---No-BOM POs
and a.po_line_id=c.po_line_id
and d.organization_id=a.organization_id
and d.inventory_item_id=c.item_id
and b.VENDOR_SITE_ID=e.VENDOR_SITE_ID
and b.org_id=e.org_id 
and a.organization_id=f.organization_id
and g.RCV_TRANSACTION_ID=a.TRANSACTION_ID
and g.CODE_COMBINATION_ID=h.CODE_COMBINATION_ID  
and c.LINE_NUM =2
and b.segment1='1094597'
and a.quantity=3480
--and TRANSACTION_ID=5732063


---Verify this RECEIPT_NUM no exist
select * from Apps.Rcv_Shipment_Headers where SHIPMENT_HEADER_ID=303232
 
select * from Apps.Rcv_Shipment_lines where SHIPMENT_HEADER_ID=303232


----check to select a unique RECEIPT_NUM (by Shipment_Header_Id & creation_date)

select CREATION_DATE,LAST_UPDATE_DATE from Apps.Rcv_Shipment_lines where SHIPMENT_HEADER_ID=408231

Select creation_date,RECEIPT_NUM,SHIPMENT_HEADER_ID  From Apps.Rcv_Shipment_Headers 
where creation_date>=to_date('20060426 15:43:10','YYYYMMDD HH24:MI:SS')
and creation_date<=to_date('20060426 16:39:10','YYYYMMDD HH24:MI:SS')
--and SHIPMENT_HEADER_ID>286301
order by creation_date--SHIPMENT_HEADER_ID--RECEIPT_NUM 

RECEIPT_NUM= 474972

---Verify this RECEIPT_NUM no exist
select * from Apps.Rcv_Shipment_Headers where RECEIPT_NUM= '474972' or SHIPMENT_HEADER_ID=303232
 
select * from Apps.Rcv_Shipment_lines where SHIPMENT_HEADER_ID=303232


---Find out same PO's correct Rcv_Shipment_Headers
Select  last_update_date,Shipment_Header_Id,rch.RECEIPT_NUM,rch.*
From Apps.Rcv_Shipment_Headers Rch
Where TO_CHAR(last_update_date,'YYYYMMDD')>='20060426'
  And Shipment_Header_Id In (Select Shipment_Header_Id From apps.Rcv_Transactions
	Where Po_Header_Id = 116227  
   And PO_LINE_ID =166238
	 )


----------my new , correct insert the Date while get other info from  the same PO's successed header_ID
----------The Shipment_Header_Id is the one needed be inserted
Insert Into  
    apps.Rcv_Shipment_Headers
     (Receipt_Source_Code, Vendor_Id, Receipt_Num, Shipment_Header_Id, Last_Update_Date, Creation_Date, Organization_Id,
      Ship_To_Org_Id, Last_Updated_By, Created_By, Last_Update_Login, Vendor_Site_Id, Employee_Id)
     Select 'VENDOR', Vendor_Id, '998693', '651777', --Last_Update_Date, Creation_Date, 
     to_date('2007-8-15 17:41:06','yyyy-mm-dd HH24:MI:SS'),to_date('2007-8-15 17:41:06','yyyy-mm-dd HH24:MI:SS'),
     Organization_Id, Ship_To_Org_Id,Last_Updated_By, Created_By, Last_Update_Login, Vendor_Site_Id, Employee_Id
     From Apps.Rcv_Shipment_Headers
     Where  Shipment_Header_Id =652576 --this is the same PO's successed header_ID


---- This one use copy source transaction's Date !
Insert Into apps.Rcv_Shipment_Headers
     (Receipt_Source_Code, Vendor_Id, Receipt_Num, Shipment_Header_Id, Last_Update_Date, Creation_Date, Organization_Id,
      Ship_To_Org_Id, Last_Updated_By, Created_By, Last_Update_Login, Vendor_Site_Id, Employee_Id)
     Select 'VENDOR', Vendor_Id, '464080', '295729', Last_Update_Date, Creation_Date, Organization_Id, Ship_To_Org_Id,
                    Last_Updated_By, Created_By, Last_Update_Login, Vendor_Site_Id, Employee_Id
     From Apps.Rcv_Shipment_Headers
     Where  Shipment_Header_Id In (295804)


----------------------------Oracle Tar 5335779.992  (not tested,looks not correct)
a) Query a PO in Enter Receipts form with the same supplier and site 
combination as that of the probelematic records.
b) Enter required data in the RECEIPT HEADER WINDOW ONLY. 
c) Save the receipt without going to Receipt Lines Window. 
d) Note down the receipt_num... 
e) Run the foll. query in SQL*Plus and get the shipment_header_id (NEW_SHID) 

Select shipment_header_id NEW_SHID from rcv_shipment_headers where 
receipt_num = '&Receipt_Num' ; 

f) Note down the shipment_header_id OLD_SHID (714763 from line_data.xls) 
in rcv_shipment_lines for which the customer finds no record in 
rcv_shipment_headers. 
. 
g) Run the following statement. 
. 
Update rcv_shipment_headers set shipment_header_id = &OLD_SHID where 
shipment_header_id = &NEW_SHID ; 
. 
h) commit the transaction. 
i) Do the same for other records.

Ask the client to perform all the steps in TEST instance and confirm all 
the results before moving to the prodcution instance after taking necessary 
back-up. 


----HZ:We don't have data to test your SQL now, your sql is too too later ! 5 month later !!!


