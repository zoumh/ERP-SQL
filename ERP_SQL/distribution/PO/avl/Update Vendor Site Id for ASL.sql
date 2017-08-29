/*Update Supplier Site*/
declare
begin
--dbms_output.put_line('00_ASM: ' || ' 00_COMP: ' || ' 00_SUPPLY: ' ||' AX_ASM: ' || ' AX_COMP: ' || ' 00_SUPPLY: ' );
for R in ( Select --pasl.using_organization_id,pasl.item_id,pasl.vendor_id,pasl.vendor_site_id 
                  pasl.creation_date,pasl.asl_id, pasl.using_organization_id, pasl.owning_organization_id,pasl.item_id,pasl.vendor_id,pasl.vendor_site_id,msib.segment1
               From   PO_APPROVED_SUPPLIER_LIST pasl
                      , mtl_system_items_b      msib
                      , mtl_parameters          mp
               Where  msib.inventory_item_id = pasl.item_id
               And    msib.organization_id = mp.organization_id
               And    mp.organization_code = 'BMC'
               And    pasl.using_organization_id = -1
               And    pasl.owning_organization_id > 126
--               And    msib.segment1 = 'SXA 109 4889.R1A'
          ) LOOP
         
         for W  in ( select  paa.asl_id,paa.using_organization_id,paa.item_id,paa.vendor_id,paa.vendor_site_id,paa.processing_lead_time,paa.min_order_qty,paa.fixed_lot_multiple
                     from    po_asl_attributes paa
                     where   paa.asl_id = r.asl_id
                     And     paa.item_id = r.item_id
--                     And     paa.using_organization_id = r.using_organization_id
                     And     paa.vendor_id = r.vendor_id
                     And     paa.vendor_site_id <> r.vendor_site_id
                   ) LOOP
                   
                   Begin
--                     dbms_output.put_line(to_char(c.asl_id),to_char(c.using_organization_id),to_char(c.item_id,c.vendor_id),to_char(c.vendor_site_id),to_char(c.processing_lead_time),to_char(c.min_order_qty),to_char(c.fixed_lot_multiple));
                     Update po_asl_attributes  p
                     Set    p.vendor_site_id = r.vendor_site_id
                     Where  p.asl_id = w.asl_id
                     And    p.using_organization_id = w.using_organization_id
                     And    p.item_id = w.item_id
                     And    p.vendor_id = w.vendor_id
                     And    p.vendor_site_id = w.vendor_site_id;
                     
                   end;
         End LOOP;
End LOOP;

--commit;

END;
                                          



-------------to check the result
Select paa.vendor_site_id , pasl.vendor_site_id,
                  pasl.creation_date,pasl.using_organization_id, pasl.owning_organization_id,pasl.item_id,pasl.vendor_id,pasl.vendor_site_id,msib.segment1
               From   apps.PO_APPROVED_SUPPLIER_LIST pasl
                      , apps.mtl_system_items_b      msib
                      , apps.mtl_parameters          mp
					  ,apps.po_asl_attributes paa
               Where  msib.inventory_item_id = pasl.item_id
               And    msib.organization_id = mp.organization_id
               And    mp.organization_code = 'BMC'
               And    pasl.using_organization_id = -1
               And    pasl.owning_organization_id > 126
			   and paa.asl_id = pasl.asl_id
			   And     paa.item_id = pasl.item_id
			   And     paa.vendor_id = pasl.vendor_id
			   And     paa.vendor_site_id <> pasl.vendor_site_id

