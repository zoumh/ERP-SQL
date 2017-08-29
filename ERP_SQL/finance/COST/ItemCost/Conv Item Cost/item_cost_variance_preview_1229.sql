
----------Item cost with onhand, base on item mapping table

select --decode(nvl(cic_old.item_cost,0),0,99999,(nvl(cic_new.item_cost,0)-nvl(cic_old.item_cost,0))/cic_old.item_cost) var_old,
       --decode(nvl(cic_new.item_cost,0),0,99999,(nvl(cic_old.item_cost,0)-nvl(cic_new.item_cost,0))/cic_new.item_cost) var_new,
       cic_old.organization_id,
       cic_old.inventory_item_id,
       xpm.old_item_number o_item,--msi_old.segment1 o_item,
       xpm.old_revision, 
       xpm.old_item_number||xpm.old_revision o_item_Rev,
       msi_old.description o_desc,
       msi_old.inventory_item_status_code o_status,
       cic_old.based_on_rollup_flag o_rollup,
       msi_old.planning_make_buy_code o_make_buy,
       cic_old.item_cost o_cost,
       msi_new.organization_id,
       xpm.new_item_number,--msi_new.segment1 n_item,
       xpm.new_revision,
       msi_new.inventory_item_status_code n_status,
       cic_new.based_on_rollup_flag n_rollup,
       msi_new.planning_make_buy_code n_make_buy,
       cic_new.item_cost n_cost,
       (nvl(cic_new.item_cost,0)-nvl(cic_old.item_cost,0)) cost_var,
       (select sum(moq.transaction_quantity)
				from apps.mtl_onhand_quantities_detail moq
						,mtl_secondary_inventories sei
			 where moq.organization_id = sei.organization_id
				 and moq.subinventory_code = sei.secondary_inventory_name
				 and sei.asset_inventory = 1 -- 排除费用子库
				 and moq.organization_id=xpm.old_organization_id
				 and moq.inventory_item_id=xpm.old_inventory_id
         and nvl(moq.revision,'0')=xpm.old_revision
       ) old_oh_total,
/*       (select sum(moq.transaction_quantity)
				from apps.mtl_onhand_quantities_detail moq
						,mtl_secondary_inventories sei
			 where moq.organization_id = sei.organization_id
				 and moq.subinventory_code = sei.secondary_inventory_name
				 and sei.asset_inventory = 1 -- 排除费用子库
				 and moq.organization_id=xpm.new_organization_id
				 and moq.inventory_item_id=nvl(xpm.new_inventory_item_id,xpm.old_inventory_id)
         and nvl(moq.revision,'0')=xpm.new_revision
       ) new_oh_total,*/
       '' amt_variance
from apps.conv_item_mapping xpm,
     cst_item_costs cic_new,
     cst_item_costs cic_old,
     mtl_system_items_b msi_new,
     mtl_system_items_b msi_old
where  cic_old.organization_id = 83 
and cic_new.organization_id=130
and msi_old.organization_id=83
and msi_new.organization_id=130
and cic_old.cost_type_id=1
and cic_new.cost_type_id=1
and cic_old.inventory_item_id=xpm.old_inventory_id
and cic_old.organization_id=xpm.old_organization_id
and nvl(xpm.new_inventory_item_id,xpm.old_inventory_id)=cic_new.inventory_item_id
and xpm.new_organization_id=cic_new.organization_id
and cic_old.inventory_item_id=msi_old.inventory_item_id
and cic_new.inventory_item_id=msi_new.inventory_item_id


---------update new
select --decode(nvl(cic_old.item_cost,0),0,99999,(nvl(cic_new.item_cost,0)-nvl(cic_old.item_cost,0))/cic_old.item_cost) var_old,
       --decode(nvl(cic_new.item_cost,0),0,99999,(nvl(cic_old.item_cost,0)-nvl(cic_new.item_cost,0))/cic_new.item_cost) var_new,
       cic_old.organization_id,
       cic_old.inventory_item_id,
       xpm.old_item_number o_item,--msi_old.segment1 o_item,
       xpm.old_revision, 
       xpm.old_item_number||xpm.old_revision o_item_Rev,
       msi_old.description o_desc,
       msi_old.inventory_item_status_code o_status,
       cic_old.based_on_rollup_flag o_rollup,
       msi_old.planning_make_buy_code o_make_buy,
       cic_old.item_cost o_cost,
       msi_new.organization_id,
       xpm.new_item_number,--msi_new.segment1 n_item,
       xpm.new_revision,
       msi_new.inventory_item_status_code n_status,
       cic_new.based_on_rollup_flag n_rollup,
       msi_new.planning_make_buy_code n_make_buy,
       cic_new.item_cost n_cost,
       (nvl(cic_new.item_cost,0)-nvl(cic_old.item_cost,0)) cost_var,
       (select sum(moq.transaction_quantity)
				from apps.mtl_onhand_quantities_detail moq
						,apps.mtl_secondary_inventories sei
			 where moq.organization_id = sei.organization_id
				 and moq.subinventory_code = sei.secondary_inventory_name
				 and sei.asset_inventory = 1 -- 排除费用子库
				 and moq.organization_id=xpm.old_organization_id
				 and moq.inventory_item_id=xpm.old_inventory_id
         and nvl(moq.revision,'0')=xpm.old_revision
       ) old_oh_total,
/*       (select sum(moq.transaction_quantity)
				from apps.mtl_onhand_quantities_detail moq
						,mtl_secondary_inventories sei
			 where moq.organization_id = sei.organization_id
				 and moq.subinventory_code = sei.secondary_inventory_name
				 and sei.asset_inventory = 1 -- 排除费用子库
				 and moq.organization_id=xpm.new_organization_id
				 and moq.inventory_item_id=nvl(xpm.new_inventory_item_id,xpm.old_inventory_id)
         and nvl(moq.revision,'0')=xpm.new_revision
       ) new_oh_total,*/
       '' amt_variance
from apps.conv_item_mapping xpm,
     apps.cst_item_costs cic_new,
     apps.cst_item_costs cic_old,
     apps.mtl_system_items_b msi_new,
     apps.mtl_system_items_b msi_old
where  cic_old.organization_id = 83 
and cic_new.organization_id=130
and msi_old.organization_id=83
and msi_new.organization_id=130
and cic_old.cost_type_id=1
and cic_new.cost_type_id=3
and cic_old.inventory_item_id=xpm.old_inventory_id
and cic_old.organization_id=xpm.old_organization_id
and nvl(xpm.new_inventory_item_id,xpm.old_inventory_id)=cic_new.inventory_item_id
and xpm.new_organization_id=cic_new.organization_id
and cic_old.inventory_item_id=msi_old.inventory_item_id
and cic_new.inventory_item_id=msi_new.inventory_item_id--16724
and xpm.old_item_number='ROA 128 1376'
and xpm.old_item_number='KRH 101 333/4R4A'

select  distinct a.old_item_number||a.old_revision o_item_Rev,count(*)
from conv_item_mapping a where a.old_organization_id=83
group by a.old_item_number,a.old_revision
having count(*)>1--16725     --5419

select * from conv_item_mapping xpm where  xpm.old_item_number like 'ROA 128 1482%'----'ROA 128 1376'
--aa.old_item_number='KRH 101 333/4R4A'

select  distinct a.new_organization_id,a.new_item_number,a.new_revision o_item_Rev,count(*)
from conv_item_mapping a where a.old_organization_id=83
group by a.new_organization_id,a.new_item_number,a.new_revision
having count(*)>1


select * from mtl_onhand_quantities_detail moq
where moq.inventory_item_id=29542 and moq.revision='2A'

