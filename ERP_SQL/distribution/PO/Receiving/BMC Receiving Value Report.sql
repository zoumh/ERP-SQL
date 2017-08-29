SELECT rs.ITEM_ID, 
       rs.item_revision, 
       rsl.item_description, 
       rs.unit_of_measure, 
       rs.location_id, 
       rs.to_organization_id, 
       rs.to_org_primary_quantity, 
       rs.receipt_date, 
       rsh.receipt_num, 
       rsh.shipment_num, 
       rsh.shipped_date, 
       rsh.freight_carrier_code, 
       rsl.quantity_shipped, 
       rs.destination_type_code, 
       nvl(rsl.packing_slip,rsh.packing_slip), 
       rsl.source_document_code, 
       decode(rsl.source_document_code, 'INV', rsl.deliver_to_location_id, 'PO', pd.deliver_to_location_id, 'REQ', prl.deliver_to_location_id) deliver_to_location_id, 
       decode(rsl.source_document_code, 'INV', rsh.shipment_num, 'PO', ph.segment1, 'REQ', prh.segment1) source_document, 
       decode(rsl.source_document_code, 'INV', rsl.line_num, 'PO', pl.line_num, 'REQ', prl.line_num) document_line_num, 
       decode(rsl.source_document_code, 'INV', (rsl.shipment_unit_price * nvl(ph.rate,1)) * (rct.source_doc_quantity/rct.primary_quantity), 'PO', (pll.price_override * nvl(ph.rate,1)) * (rct.source_doc_quantity/rct.primary_quantity), 'REQ', prl.unit_price * (rct.source_doc_quantity / rct.primary_quantity)) actual_price, 
       rsh.vendor_id, 
       rs.rcv_transaction_id, 
       pd.bom_resource_id, 
       pd.wip_entity_id, 
       pd.wip_resource_seq_num, 
       pd.wip_operation_seq_num, 
       pd.wip_repetitive_schedule_id,
       rct.transfer_lpn_id,
       rct.CREATION_DATE,
       ROUND(pl.UNIT_PRICE*nvl(ph.rate,1),2) UNIT_PRICE
FROM   MTL_SUPPLY RS,
       RCV_SHIPMENT_HEADERS RSH,
       RCV_SHIPMENT_LINES RSL,
       PO_HEADERS_ALL PH,
       PO_LINES_ALL PL,
       PO_LINE_LOCATIONS PLL,
       PO_DISTRIBUTIONS PD,
       PO_REQUISITION_HEADERS PRH,
       PO_REQUISITION_LINES PRL,
       RCV_TRANSACTIONS RCT
where  rsh.shipment_header_id = rs.shipment_header_id 
       and rsl.shipment_line_id = rs.shipment_line_id 
       and ph.po_header_id (+) = rs.po_header_id 
       and pl.po_line_id (+) = rs.po_line_id 
       and pll.line_location_id (+) = rs.po_line_location_id 
       and pd.po_distribution_id (+) = rs.po_distribution_id 
       and prh.requisition_header_id (+) = rs.req_header_id 
       and prl.requisition_line_id (+) = rs.req_line_id 
       and rs.rcv_transaction_id = rct.transaction_id 
       and rs.supply_type_code = 'RECEIVING'
       and rs.ITEM_ID is not null
       and rs.to_organization_id=83;