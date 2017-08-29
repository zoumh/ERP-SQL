1. Find out the PHYSICAL_INVENTORY_ID

select PHYSICAL_INVENTORY_NAME,PHYSICAL_INVENTORY_ID,ORGANIZATION_ID,DESCRIPTION,FREEZE_DATE,TOTAL_ADJUSTMENT_VALUE,NEXT_TAG_NUMBER  from apps.MTL_PHYSICAL_INVENTORIES 
where trunc(FREEZE_DATE)>= to_date('2006-08-01','YYYY-MM-DD')
  and trunc(FREEZE_DATE)<= to_date('2006-09-30','YYYY-MM-DD')
order by PHYSICAL_INVENTORY_ID

---------------------------------------------------------------------------
2.-4207
Non-SB ;SG;SD;SI, With Cost & Level,sort by c.segment3,c.segment5  

select (select f.tag_number from apps.mtl_physical_inventory_tags f where a.adjustment_id=f.adjustment_id and rownum=1) Tag,
system_quantity Sys_Qty,'' Count_Qty, b.segment1 Item, a.revision Rev, a.subinventory_name Stock, 
c.segment2||'.'||c.segment3||'.'||c.segment4||'.'||c.segment5 Locator,
e.cost_group COST_GROUP,
(select g.license_plate_number from apps.wms_license_plate_numbers g where a.parent_lpn_id=g.lpn_id and rownum=1) LPN, 
''Audit_Qty,
(case when a.actual_cost>50 then 'A' else case when (a.actual_cost<=50 and a.actual_cost>20) then 'B' else case when (a.actual_cost<=20 and a.actual_cost>10) then'C' else 'D' end end end) Remark
--,actual_cost
--,c.segment2 Locat1,c.segment3 Locat2,(c.segment4) Locat3,c.segment5 Locat4
from   apps.mtl_physical_adjustments a, apps.mtl_system_items b, apps.mtl_item_locations c, apps.cst_cost_groups e 
where  a.physical_inventory_id =:d --and actual_cost > 50 
       and a.inventory_item_id=b.inventory_item_id and a.organization_id=130 and b.organization_id=130 
       and a.locator_id=c.inventory_location_id and c.organization_id=130 
       and a.cost_group_id=e.cost_group_id 
       and (a.subinventory_name not in ('SB','SD','SG','SI') )
order by a.subinventory_name

-----------------------------------------------------

3.-4716
SB-SD-SG-SI , With Cost & Level,sort by c.segment3,c.segment5
 
select (select f.tag_number from apps.mtl_physical_inventory_tags f where a.adjustment_id=f.adjustment_id and rownum=1) Tag,
system_quantity Sys_Qty,'' Count_Qty, b.segment1 Item, a.revision Rev, a.subinventory_name Stock, 
c.segment2||'.'||c.segment3||'.'||c.segment4||'.'||c.segment5 Locator,
e.cost_group COST_GROUP,
(select g.license_plate_number from apps.wms_license_plate_numbers g where a.parent_lpn_id=g.lpn_id and rownum=1) LPN, 
''Audit_Qty,
(case when a.actual_cost>50 then 'A' else case when (a.actual_cost<=50 and a.actual_cost>20) then 'B' else case when (a.actual_cost<=20 and a.actual_cost>10) then'C' else 'D' end end end) Remark
--, actual_cost
--,c.segment2 Locat1,c.segment3 Locat2,(c.segment4) Locat3,c.segment5 Locat4
from   apps.mtl_physical_adjustments a, apps.mtl_system_items b, apps.mtl_item_locations c, apps.cst_cost_groups e 
where  a.physical_inventory_id =806 --and actual_cost > 50 
       and a.inventory_item_id=b.inventory_item_id and a.organization_id=130 and b.organization_id=130 
       and a.locator_id=c.inventory_location_id and c.organization_id=130 
       and a.cost_group_id=e.cost_group_id 
       and a.subinventory_name in ('SB','SD','SG','SI') 
       --and c.segment2 IN('L','M','S','Lend') 
--and (c.segment5 not in ('11','22','33','44') or c.segment5 is null)
--and a.ADJUSTMENT_ID=74970
--and (substr(c.segment4,1,1)<='9' or c.segment4 is null)
order by a.subinventory_name,c.segment3,c.segment5,c.segment4
 

---------------------------------------------------------------------------
-------------------------
verify all_Org tag QTY.

select count(*)
from   apps.mtl_physical_adjustments a 
where  a.physical_inventory_id =:d  and a.organization_id=130
--and SUBINVENTORY_NAME='SB'

-------------------------
4 AC -19, With Cost & Level,sort by c.segment3,c.segment5*/
 
select (select f.tag_number from apps.mtl_physical_inventory_tags f where a.adjustment_id=f.adjustment_id and rownum=1) Tag,
system_quantity Sys_Qty,'' Count_Qty, b.segment1 Item, a.revision Rev, a.subinventory_name Stock, 
c.segment2||'.'||c.segment3||'.'||c.segment4||'.'||c.segment5 Locator,
e.cost_group COST_GROUP,
(select g.license_plate_number from apps.wms_license_plate_numbers g where a.parent_lpn_id=g.lpn_id and rownum=1) LPN, 
''Audit_Qty,
(case when a.actual_cost>50 then 'A' else case when (a.actual_cost<=50 and a.actual_cost>20) then 'B' else case when (a.actual_cost<=20 and a.actual_cost>10) then'C' else 'D' end end end) Remark
--, actual_cost
--,c.segment2 Locat1,c.segment3 Locat2,(c.segment4) Locat3,c.segment5 Locat4
from   apps.mtl_physical_adjustments a, apps.mtl_system_items b, apps.mtl_item_locations c, apps.cst_cost_groups e 
where  a.physical_inventory_id =800 --and actual_cost > 50 
       and a.inventory_item_id=b.inventory_item_id and a.organization_id=128 and b.organization_id=128 
       and a.locator_id=c.inventory_location_id and c.organization_id=128 
       and a.cost_group_id=e.cost_group_id 
       --and (a.subinventory_name = 'SG')
order by a.subinventory_name,TO_NUMBER(c.segment3),c.segment5,c.segment4 Asc


5.IP Tag -608, SBT with locator, other WH no locator


select (select f.tag_number from apps.mtl_physical_inventory_tags f where a.adjustment_id=f.adjustment_id and rownum=1) Tag,
system_quantity Sys_Qty,'' Count_Qty, b.segment1 Item, a.revision Rev, a.subinventory_name Stock, 
c.segment2||'.'||c.segment3||'.'||c.segment4||'.'||c.segment5 Locator,
''Audit_Qty,
(case when a.actual_cost>50 then 'A' else case when (a.actual_cost<=50 and a.actual_cost>20) then 'B' else case when (a.actual_cost<=20 and a.actual_cost>10) then'C' else 'D' end end end) Remark
--,	actual_cost
--,c.segment2 Locat1,c.segment3 Locat2,(c.segment4) Locat3,c.segment5 Locat4
from apps.mtl_physical_adjustments a, apps.mtl_system_items b, apps.mtl_item_locations c 
where  a.physical_inventory_id =:d
       and a.inventory_item_id=b.inventory_item_id and a.organization_id=132 and b.organization_id=132 
       and a.locator_id=c.inventory_location_id and c.organization_id=132 
	   and a.subinventory_name IN ('SBT')
union
select (select f.tag_number from apps.mtl_physical_inventory_tags f where a.adjustment_id=f.adjustment_id and rownum=1) Tag,
system_quantity Sys_Qty,'' Count_Qty, b.segment1 Item, a.revision Rev, a.subinventory_name Stock, 
'' Locator,
''Audit_Qty,
(case when a.actual_cost>50 then 'A' else case when (a.actual_cost<=50 and a.actual_cost>20) then 'B' else case when (a.actual_cost<=20 and a.actual_cost>10) then'C' else 'D' end end end) Remark
--,	actual_cost
from apps.mtl_physical_adjustments a, apps.mtl_system_items b--, apps.mtl_item_locations c 
where  a.physical_inventory_id =:d 
       and a.inventory_item_id=b.inventory_item_id and a.organization_id=132 and b.organization_id=132
	   and a.subinventory_name<>'SBT'

-----Verify total Prj Tag numbers 

select count(*)
from   apps.mtl_physical_adjustments a 
where  a.physical_inventory_id =:d  and a.organization_id=132 


-----Verify total Prj amount 

select 
sum(nvl(system_quantity*actual_cost,0)) total_system_value,
sum(round(nvl(count_quantity*actual_cost,0) ,2)) total_count_value,
sum(round(nvl(adjustment_quantity*actual_cost,0),2)) total_adjustment_value
from apps.mtl_physical_adjustments
where physical_inventory_id = :d

---------------------------------------------------------------------------
6. SE Tags

	   select (select f.tag_number from apps.mtl_physical_inventory_tags f where a.adjustment_id=f.adjustment_id and rownum=1) Tag,
system_quantity Sys_Qty,'' Count_Qty, b.segment1 Item, a.revision Rev, a.subinventory_name Stock, 
c.segment2||'.'||c.segment3||'.'||c.segment4||'.'||c.segment5 Locator,
''Audit_Qty,
(case when a.actual_cost>50 then 'A' else case when (a.actual_cost<=50 and a.actual_cost>20) then 'B' else case when (a.actual_cost<=20 and a.actual_cost>10) then'C' else 'D' end end end) Remark
,	actual_cost
--,c.segment2 Locat1,c.segment3 Locat2,(c.segment4) Locat3,c.segment5 Locat4
from   apps.mtl_physical_adjustments a, apps.mtl_system_items b, apps.mtl_item_locations c 
where  a.physical_inventory_id =:d 
       and a.inventory_item_id=b.inventory_item_id and a.organization_id=133 and b.organization_id=133 
       and a.locator_id=c.inventory_location_id and c.organization_id=133 
order by tag

-----Verify total SEM Tag numbers 

select count(*)
from   apps.mtl_physical_adjustments a 
where  a.physical_inventory_id =:d  and a.organization_id=133 


Select  
         a.Organization_Id,a.subinventory_code Stock,
               c.Segment2 || '.' || c.Segment3 || '.' || c.Segment4 || '.' || c.Segment5 Locator,Sum(a.Primary_Transaction_Quantity) Onhand
From Apps.MTL_ONHAND_QUANTITIES_DETAIl a ,Apps.Mtl_Item_Locations c
Where a.Organization_Id = 83  And 
 a.subinventory_code ='SB' And 
 a.Locator_Id = c.Inventory_Location_Id(+)
And a.Organization_Id = c.Organization_Id
Group By     a.Organization_Id,a.subinventory_code,c.Segment2 || '.' || c.Segment3 || '.' || c.Segment4 || '.' || c.Segment5
Having Sum(a.Primary_Transaction_Quantity)>0
 Order By a.Organization_Id,a.subinventory_code
 
---------------------------------------- 
 counting_SQL_end

 

