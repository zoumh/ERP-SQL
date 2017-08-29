

-------PO for Project (CC in prj range , invoice_date)

SELECT  b.segment5 PROJECT,b.segment2 Cost_Center,b.segment3 Account_No,
to_date(d.CREATION_DATE) PO_Date,to_date(c.closed_date) Invoice_date,
c.ITEM_DESCRIPTION,'' Comm_Unique,
nvl(d.rate,1)*a.QUANTITY_ORDERED*C.UNIT_PRICE as PO_CNY_Amt,
d.segment1 PO_number,to_char(c.LINE_NUM) PO_Line_Num,to_char(e.SHIPMENT_NUM) PO_Ship_Num,to_char(a.DISTRIBUTION_NUM) PO_Dist_Num,
a.QUANTITY_ORDERED,a.QUANTITY_DELIVERED,a.QUANTITY_BILLED,
d.CURRENCY_CODE,C.UNIT_PRICE,a.QUANTITY_ORDERED*C.UNIT_PRICE PO_AMOUNT,
f.VENDOR_NAME
FROM apps.PO_DISTRIBUTIONS_ALL A,
     apps.GL_CODE_COMBINATIONS B,
	 apps.PO_LINES_ALL         C,
	 apps.PO_HEADERS_ALL       D,
	 apps.po_Line_locations_all e,
	 apps.PO_VENDORS f
WHERE A.CODE_COMBINATION_ID=B.CODE_COMBINATION_ID
AND  C.PO_LINE_ID=A.PO_lINE_ID
AND  D.PO_HEADER_ID=A.PO_HEADER_ID
and  e.LINE_LOCATION_ID=a.LINE_LOCATION_ID
and c.LINE_TYPE_ID=1020 --No-BOM PO line
and (d.AUTHORIZATION_STATUS ='APPROVED')
and (d.USER_HOLD_FLAG is null or d.USER_HOLD_FLAG='N' )
and (d.CANCEL_FLAG ='N' or d.CANCEL_FLAG  is null)
and (e.CANCEL_FLAG<>'Y' or e.CANCEL_FLAG is null)
and (c.CANCEL_FLAG<>'Y' or c.CANCEL_FLAG is null)
and f.VENDOR_ID=d.VENDOR_ID
and (b.segment5 in ('9918','9919')
or b.segment2 in ('4191','5195','5197','4171'))
order by d.segment1,c.LINE_NUM,e.SHIPMENT_NUM,a.DISTRIBUTION_NUM,d.CREATION_DATE


---------- Period non-BOM PO amt by Cost Center
SELECT  b.segment2 Cost_Center,b.segment3 Account_No,
d.CREATION_DATE PO_Date, 
nvl(d.rate,1)*a.QUANTITY_ORDERED*C.UNIT_PRICE as PO_CNY_Amt,
d.segment1 PO_number,to_char(c.LINE_NUM) PO_Line_Num,to_char(e.SHIPMENT_NUM) PO_Ship_Num,to_char(a.DISTRIBUTION_NUM) PO_Dist_Num,
a.QUANTITY_ORDERED,a.QUANTITY_DELIVERED,a.QUANTITY_BILLED,
d.CURRENCY_CODE,C.UNIT_PRICE,a.QUANTITY_ORDERED*C.UNIT_PRICE PO_AMOUNT,d.rate,
f.FULL_NAME Buyer,c.ITEM_DESCRIPTION
FROM apps.PO_DISTRIBUTIONS_ALL A,
     apps.GL_CODE_COMBINATIONS B,
     apps.PO_LINES_ALL         C,
     apps.PO_HEADERS_ALL       D,
     apps.po_Line_locations_all e,
     apps.po_agents_name_v f
WHERE A.CODE_COMBINATION_ID=B.CODE_COMBINATION_ID
AND  C.PO_LINE_ID=A.PO_lINE_ID
AND  D.PO_HEADER_ID=A.PO_HEADER_ID
and  e.LINE_LOCATION_ID=a.LINE_LOCATION_ID
and c.LINE_TYPE_ID=1020 --No-BOM PO line
and (d.AUTHORIZATION_STATUS ='APPROVED')
and (d.USER_HOLD_FLAG is null or d.USER_HOLD_FLAG='N' )
and (d.CANCEL_FLAG ='N' or d.CANCEL_FLAG  is null)
and (e.CANCEL_FLAG<>'Y' or e.CANCEL_FLAG is null)
and (c.CANCEL_FLAG<>'Y' or c.CANCEL_FLAG is null)
and d.agent_id=f.BUYER_ID
and b.segment2 in ('5060','5992','6040')
and d.CREATION_DATE>=to_date('2007-1-1','yyyy-mm-dd')
--and d.CREATION_DATE<to_date('2007-1-1','yyyy-mm-dd')
--and d.CURRENCY_CODE='USD'
order by d.segment1,c.LINE_NUM,e.SHIPMENT_NUM,a.DISTRIBUTION_NUM,d.CREATION_DATE



------PO (Distribution) amount by PRD & PRJ

SELECT  d.CREATION_DATE,d.segment1 PO_number,to_char(c.LINE_NUM) PO_Line_Num
,to_char(e.SHIPMENT_NUM) PO_Ship_Num,to_char(a.DISTRIBUTION_NUM) PO_Dist_Num
,c.ITEM_DESCRIPTION
,a.QUANTITY_ORDERED,a.QUANTITY_DELIVERED,a.QUANTITY_BILLED
,d.CURRENCY_CODE,C.UNIT_PRICE,a.QUANTITY_ORDERED*C.UNIT_PRICE AMOUNT,b.segment4 PRODUCT,b.segment5 PROJECT
,nvl(d.rate,1)*a.QUANTITY_ORDERED*C.UNIT_PRICE as CNY_Amt
,a.DESTINATION_ORGANIZATION_ID Destin_Org,f.VENDOR_NAME
FROM apps.PO_DISTRIBUTIONS_ALL A,
     apps.GL_CODE_COMBINATIONS B,
	 apps.PO_LINES_ALL         C,
	 apps.PO_HEADERS_ALL       D,
	 apps.po_Line_locations_all e,
	 apps.PO_VENDORS f
WHERE A.CODE_COMBINATION_ID=B.CODE_COMBINATION_ID
AND  C.PO_LINE_ID=A.PO_lINE_ID
AND  D.PO_HEADER_ID=A.PO_HEADER_ID
and  e.LINE_LOCATION_ID=a.LINE_LOCATION_ID
and c.LINE_TYPE_ID=1020 --No-BOM PO line
and (d.AUTHORIZATION_STATUS ='APPROVED')
and (d.USER_HOLD_FLAG is null or d.USER_HOLD_FLAG='N' )
and (d.CANCEL_FLAG ='N' or d.CANCEL_FLAG  is null)
and (e.CANCEL_FLAG<>'Y' or e.CANCEL_FLAG is null)
and (c.CANCEL_FLAG<>'Y' or c.CANCEL_FLAG is null)
and f.VENDOR_ID=d.VENDOR_ID
order by d.segment1,c.LINE_NUM,e.SHIPMENT_NUM,a.DISTRIBUTION_NUM,d.CREATION_DATE



------ PO ship line info by Item
SELECT DISTINCT d.segment1 PO_number,C.LINE_NUM,e.SHIPMENT_NUM,c.ITEM_DESCRIPTION,e.QUANTITY,e.QUANTITY_RECEIVED,e.QUANTITY_BILLED,
d.CURRENCY_CODE--, C.QUANTITY,C.UNIT_PRICE,C.QUANTITY*C.UNIT_PRICE AMOUNT
,e.CANCEL_FLAG
FROM --apps.PO_DISTRIBUTIONS_ALL A,
	 apps.PO_LINES_ALL         C,
	 apps.PO_HEADERS_ALL       D,
	 apps.po_Line_locations_all e
WHERE  D.PO_HEADER_ID=c.PO_HEADER_ID
and  e.PO_HEADER_ID=d.PO_HEADER_ID
and e.PO_LINE_ID=c.PO_LINE_ID
and c.ITEM_DESCRIPTION like '%FNTM%62%'
order by d.segment1,C.LINE_NUM,e.SHIPMENT_NUM




---------Use line lever but get first distribution's account! wrong when has multi distribution & different account!
---This SQL Script is used to provide PO no, price,amount, received QTY, billed QTY for sPecail PRoject No---
---Lijing----


SELECT DISTINCT d.segment1 PO_number,a.DESTINATION_ORGANIZATION_ID,
c.ITEM_DESCRIPTION,e.QUANTITY_RECEIVED,e.QUANTITY_BILLED,
d.CURRENCY_CODE,C.PO_lINE_ID, C.QUANTITY,C.UNIT_PRICE,C.QUANTITY*C.UNIT_PRICE AMOUNT,b.segment5 PROJECT
FROM apps.PO_DISTRIBUTIONS_ALL A,
     apps.GL_CODE_COMBINATIONS B,
	 apps.PO_LINES_ALL         C,
	 apps.PO_HEADERS_ALL       D,
	 apps.po_Line_locations_all e
WHERE A.CODE_COMBINATION_ID=B.CODE_COMBINATION_ID
AND  b.SEGMENT5 like '99%'
AND  C.PO_LINE_ID=A.PO_lINE_ID
AND  D.PO_HEADER_ID=A.PO_HEADER_ID
and  e.LINE_LOCATION_ID=a.LINE_LOCATION_ID

select * from apps.po_Line_locations_all       








----To add CNY_PO_amount column on the report
---(Harris Update)

SELECT  d.segment1 PO_number,a.DESTINATION_ORGANIZATION_ID,
c.ITEM_DESCRIPTION,e.QUANTITY_RECEIVED,e.QUANTITY_BILLED,
d.CURRENCY_CODE,C.PO_lINE_ID, C.QUANTITY as PO_Qty,C.UNIT_PRICE,C.QUANTITY*C.UNIT_PRICE AMOUNT,b.segment5 PROJECT
,nvl(d.rate,1)*C.QUANTITY*C.UNIT_PRICE as PO_Amt_CNY
FROM apps.PO_DISTRIBUTIONS_ALL A,
     apps.GL_CODE_COMBINATIONS B,
	 apps.PO_LINES_ALL         C,
	 apps.PO_HEADERS_ALL       D,
	 apps.po_Line_locations_all e
WHERE A.CODE_COMBINATION_ID=B.CODE_COMBINATION_ID
AND  b.SEGMENT5 like '99%'
AND  C.PO_LINE_ID=A.PO_lINE_ID
AND  D.PO_HEADER_ID=A.PO_HEADER_ID
and  e.LINE_LOCATION_ID=a.LINE_LOCATION_ID