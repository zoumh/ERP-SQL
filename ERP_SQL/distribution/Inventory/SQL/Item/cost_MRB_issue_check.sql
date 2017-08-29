--///////Pending cost issue check/////----
select msib.organization_id, '采购件没有选择了Based_on_rollup有BOM' 描述类型,mc.segment1 Product_line,msib.segment1,msib.planning_make_buy_code
,msib.description,msib.inventory_item_status_code,msib.creation_date
,(select sum(a1.item_cost) from bom.cst_item_cost_details a1 where  a1.rollup_source_type = 1 and a1.cost_type_id = 3 
and a1.organization_id = msib.organization_id and a1.inventory_item_id (+) = msib.inventory_item_id 
) DEFINED_COST 
,(select sum(a2.item_cost) from bom.cst_item_cost_details a2 where  a2.rollup_source_type = 3 and a2.cost_type_id = 3 
and a2.organization_id = msib.organization_id and a2.inventory_item_id (+)= msib.inventory_item_id 
) ROLLUP_COST
,(select sum(o.transaction_quantity) from inv.mtl_onhand_quantities_detail o 
where o.inventory_item_id (+) = msib.inventory_item_id and o.organization_id  = msib.organization_id  )ONHAND 
from mtl_system_items_b msib,mtl_item_categories mic,mtl_categories mc
where msib.organization_id in (83,130)
     -- and msib.inventory_item_status_code = 'Active'
      and msib.planning_make_buy_code = 2
      and exists ( select 1 from cst_item_costs cic
                   where cic.organization_id = msib.organization_id
                         and cic.inventory_item_id = msib.inventory_item_id 
                         and cic.cost_type_id = 3
                         and cic.based_on_rollup_flag = 2 ) 
      and exists ( select 1 from bom_bill_of_materials bbom 
                   where bbom.organization_id = msib.organization_id
                         and bbom.assembly_item_id = msib.inventory_item_id )
         -- added item category
     and mic.inventory_item_id=msib.inventory_item_id
     and mic.organization_id=msib.organization_id
     and mc.structure_id=101 
     and mic.category_id=mc.category_id         

union
select msib.organization_id, '采购件选择了Based_on_rollup没有BOM' 描述类型,mc.segment1 Product_line,msib.segment1,msib.planning_make_buy_code
,msib.description,msib.inventory_item_status_code,msib.creation_date
,(select sum(a1.item_cost) from bom.cst_item_cost_details a1 where  a1.rollup_source_type = 1 and a1.cost_type_id = 3 
and a1.organization_id = msib.organization_id and a1.inventory_item_id (+) = msib.inventory_item_id 
) DEFINED_COST 
,(select sum(a2.item_cost) from bom.cst_item_cost_details a2 where  a2.rollup_source_type = 3 and a2.cost_type_id = 3 
and a2.organization_id = msib.organization_id and a2.inventory_item_id (+)= msib.inventory_item_id 
) ROLLUP_COST
,(select sum(o.transaction_quantity) from inv.mtl_onhand_quantities_detail o 
where o.inventory_item_id (+) = msib.inventory_item_id and o.organization_id  = msib.organization_id  )ONHAND 
from mtl_system_items_b msib,mtl_item_categories mic,mtl_categories mc
where msib.organization_id in ( 83,130 )
      --and msib.inventory_item_status_code = 'Active'
      and msib.planning_make_buy_code = 2
      and exists ( select 1 from cst_item_costs cic
                   where cic.organization_id = msib.organization_id
                         and cic.inventory_item_id = msib.inventory_item_id 
                         and cic.cost_type_id = 3
                         and cic.based_on_rollup_flag = 1 ) 
      and not exists ( select 1 from bom_bill_of_materials bbom 
                   where bbom.organization_id = msib.organization_id
                         and bbom.assembly_item_id = msib.inventory_item_id )
        -- added item category
     and mic.inventory_item_id=msib.inventory_item_id
     and mic.organization_id=msib.organization_id
     and mc.structure_id=101 
     and mic.category_id=mc.category_id   
union
select msib.organization_id, '采购件选择了Based_on_rollup有BOM' 描述类型,mc.segment1 Product_line,msib.segment1,msib.planning_make_buy_code
,msib.description,msib.inventory_item_status_code,msib.creation_date
,(select sum(a1.item_cost) from bom.cst_item_cost_details a1 where  a1.rollup_source_type = 1 and a1.cost_type_id = 3 
and a1.organization_id = msib.organization_id and a1.inventory_item_id (+) = msib.inventory_item_id 
) DEFINED_COST 
,(select sum(a2.item_cost) from bom.cst_item_cost_details a2 where  a2.rollup_source_type = 3 and a2.cost_type_id = 3 
and a2.organization_id = msib.organization_id and a2.inventory_item_id (+)= msib.inventory_item_id 
) ROLLUP_COST
,(select sum(o.transaction_quantity) from inv.mtl_onhand_quantities_detail o 
where o.inventory_item_id (+) = msib.inventory_item_id and o.organization_id  = msib.organization_id  )ONHAND 
from mtl_system_items_b msib,mtl_item_categories mic,mtl_categories mc
where msib.organization_id in ( 83,130 )
      --and msib.inventory_item_status_code = 'Active'
      and msib.planning_make_buy_code = 2
      and exists ( select 1 from cst_item_costs cic
                   where cic.organization_id = msib.organization_id
                         and cic.inventory_item_id = msib.inventory_item_id 
                         and cic.cost_type_id = 3
                         and cic.based_on_rollup_flag = 1 ) 
      and exists ( select 1 from bom_bill_of_materials bbom 
                   where bbom.organization_id = msib.organization_id
                         and bbom.assembly_item_id = msib.inventory_item_id )
         -- added item category
     and mic.inventory_item_id=msib.inventory_item_id
     and mic.organization_id=msib.organization_id
     and mc.structure_id=101 
     and mic.category_id=mc.category_id   
union
select msib.organization_id, '制造件没有选择Based_on_rollup且没有BOM' 描述类型,mc.segment1 Product_line
,msib.segment1,msib.planning_make_buy_code,msib.description,msib.inventory_item_status_code,msib.creation_date
,(select sum(a1.item_cost) from bom.cst_item_cost_details a1 where  a1.rollup_source_type = 1 and a1.cost_type_id = 3 
and a1.organization_id = msib.organization_id and a1.inventory_item_id (+) = msib.inventory_item_id 
) DEFINED_COST 
,(select sum(a2.item_cost) from bom.cst_item_cost_details a2 where  a2.rollup_source_type = 3 and a2.cost_type_id = 3 
and a2.organization_id = msib.organization_id and a2.inventory_item_id (+)= msib.inventory_item_id 
) ROLLUP_COST
,(select sum(o.transaction_quantity) from inv.mtl_onhand_quantities_detail o 
where o.inventory_item_id (+) = msib.inventory_item_id and o.organization_id  = msib.organization_id  )ONHAND 
from mtl_system_items_b msib,mtl_item_categories mic,mtl_categories mc
where msib.organization_id in ( 83,130 )
      and msib.planning_make_buy_code = 1
--      and msib.inventory_item_status_code = 'Active'
      and exists ( select 1 from cst_item_costs cic
                   where cic.organization_id = msib.organization_id
                         and cic.inventory_item_id = msib.inventory_item_id 
                         and cic.cost_type_id = 3
                         and cic.based_on_rollup_flag = 2 )
      and not exists ( select 1 from bom_bill_of_materials bbom 
                       where bbom.organization_id = msib.organization_id
                             and bbom.assembly_item_id = msib.inventory_item_id )
      -- added item category
     and mic.inventory_item_id=msib.inventory_item_id
     and mic.organization_id=msib.organization_id
     and mc.structure_id=101 
     and mic.category_id=mc.category_id 
union
select msib.organization_id, '制造件没有选择Based_on_rollup且有BOM' 描述类型
,mc.segment1 Product_line,msib.segment1,msib.planning_make_buy_code
,msib.description,msib.inventory_item_status_code,msib.creation_date
,(select sum(a1.item_cost) from bom.cst_item_cost_details a1 where  a1.rollup_source_type = 1 and a1.cost_type_id = 3 
and a1.organization_id = msib.organization_id and a1.inventory_item_id (+) = msib.inventory_item_id 
) DEFINED_COST 
,(select sum(a2.item_cost) from bom.cst_item_cost_details a2 where  a2.rollup_source_type = 3 and a2.cost_type_id = 3 
and a2.organization_id = msib.organization_id and a2.inventory_item_id (+)= msib.inventory_item_id 
) ROLLUP_COST
,(select sum(o.transaction_quantity) from inv.mtl_onhand_quantities_detail o 
where o.inventory_item_id (+) = msib.inventory_item_id and o.organization_id  = msib.organization_id  )ONHAND 
from mtl_system_items_b msib ,mtl_item_categories mic,mtl_categories mc
where msib.organization_id in ( 83,130 )
--      and msib.inventory_item_status_code = 'Active'
      and msib.planning_make_buy_code = 1
      and exists ( select 1 from cst_item_costs cic
                   where cic.organization_id = msib.organization_id
                         and cic.inventory_item_id = msib.inventory_item_id 
                         and cic.cost_type_id = 3
                         and cic.based_on_rollup_flag = 2 )
      and exists ( select 1 from bom_bill_of_materials bbom 
                   where bbom.organization_id = msib.organization_id
                         and bbom.assembly_item_id = msib.inventory_item_id )
           -- added item category
     and mic.inventory_item_id=msib.inventory_item_id
     and mic.organization_id=msib.organization_id
     and mc.structure_id=101 
     and mic.category_id=mc.category_id   
union
select msib.organization_id, '制造件选择了Based_on_rollup且没有BOM' 描述类型,mc.segment1 Product_line,msib.segment1,msib.planning_make_buy_code
,msib.description,msib.inventory_item_status_code,msib.creation_date
,(select sum(a1.item_cost) from bom.cst_item_cost_details a1 where  a1.rollup_source_type = 1 and a1.cost_type_id = 3 
and a1.organization_id = msib.organization_id and a1.inventory_item_id (+) = msib.inventory_item_id 
) DEFINED_COST 
,(select sum(a2.item_cost) from bom.cst_item_cost_details a2 where  a2.rollup_source_type = 3 and a2.cost_type_id = 3 
and a2.organization_id = msib.organization_id and a2.inventory_item_id (+)= msib.inventory_item_id 
) ROLLUP_COST
,(select sum(o.transaction_quantity) from inv.mtl_onhand_quantities_detail o 
where o.inventory_item_id (+) = msib.inventory_item_id and o.organization_id  = msib.organization_id  )ONHAND 
from mtl_system_items_b msib,mtl_item_categories mic,mtl_categories mc
where msib.organization_id in ( 83,130 )
 --     and msib.inventory_item_status_code = 'Active'
      and msib.planning_make_buy_code = 1
      and exists ( select 1 from cst_item_costs cic
                   where cic.organization_id = msib.organization_id
                         and cic.inventory_item_id = msib.inventory_item_id 
                         and cic.cost_type_id = 3
                         and cic.based_on_rollup_flag = 1 )
      and not exists ( select 1 from bom_bill_of_materials bbom 
                   where bbom.organization_id = msib.organization_id
                         and bbom.assembly_item_id = msib.inventory_item_id )
         -- added item category
     and mic.inventory_item_id=msib.inventory_item_id
     and mic.organization_id=msib.organization_id
     and mc.structure_id=101 
     and mic.category_id=mc.category_id        
order by 2,1,3