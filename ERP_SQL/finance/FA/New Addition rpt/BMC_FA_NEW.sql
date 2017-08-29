SET heading off;
SET pagesize 1000;
SET LINESIZE 500;
select 'CREATION_DATE;TRANSACTION_DATE_ENTERED;DATE_EFFECTIVE;ASSET_ID;tag_number;serial_number;ASSET_NUMBER;LOCATION;PROJECT;PRODUCT;CATEGORY1;CATEGORY2;CATEGORY3;INVOICE_NUMBER;PO_NUMBER;COST;ORIGINAL_COST;Account;Cost Center;gl_date;DEPRECIATE_FLAG;Remark;DESCRIPTION' 
from dual
union all
select to_char(fab.CREATION_DATE,'YYYY-MM-DD hh24:mi:ss')||';'||fth.TRANSACTION_DATE_ENTERED||';'||
fth.DATE_EFFECTIVE||';'||fab.ASSET_ID||';'||fab.tag_number||';'||fab.serial_number||';'||
fab.ASSET_NUMBER||';'||fl.segment1||'.'||fl.segment2||'.'||fl.segment3||';'||fak.segment1||';'||fak.segment2||';'||replace(fab.ATTRIBUTE_CATEGORY_CODE,'.',';')||';'||
fai.INVOICE_NUMBER||';'||fai.PO_NUMBER||';'||fb.COST||';'||fb.ORIGINAL_COST||';'||
gcc.SEGMENT3||';'||gcc.segment2||';'||glp.gl_date||';'||fb.DEPRECIATE_FLAG||';'||fab.ATTRIBUTE1||';'||fat.DESCRIPTION
/*select fab.CREATION_DATE,fth.TRANSACTION_DATE_ENTERED,fth.DATE_EFFECTIVE,fab.ASSET_ID,fab.tag_number,fab.serial_number,
fab.ASSET_NUMBER,fak.segment1 project,fak.segment2 product,fab.ATTRIBUTE_CATEGORY_CODE,
fai.INVOICE_NUMBER,fai.PO_NUMBER,fb.COST,fb.ORIGINAL_COST,fat.DESCRIPTION,
gcc.SEGMENT3 Account,gcc.segment2 "Cost Center",glp.gl_date,fb.DEPRECIATE_FLAG,fab.ATTRIBUTE1 Remark*/
from fa_additions_b fab,fa_asset_keywords fak,fa_asset_invoices fai,gl_code_combinations gcc,
fa_books fb,fa_transaction_headers fth,fa_additions_tl fat,fa_distribution_history fdh,fa_locations fl,
(select asset_id,
to_char(add_months(MIN(to_date(fdp.PERIOD_NAME,'MON-YY')),1),'MON-YY')||' to '||
      to_char(max(to_date(fdp.PERIOD_NAME,'MON-YY')),'MON-YY') GL_DATE
      from fa_deprn_detail fdd,fa_deprn_periods fdp
      where fdd.BOOK_TYPE_CODE='BMC_FA_BOOK'
      and fdd.PERIOD_COUNTER=fdp.PERIOD_COUNTER
      and fdp.BOOK_TYPE_CODE='BMC_FA_BOOK'
      group by asset_id
      )glp
      where fab.asset_key_ccid=fak.code_combination_id(+)
	  and fab.ASSET_ID=fai.ASSET_ID(+)
      and fab.asset_id=fb.asset_id
      and fab.ASSET_ID=fat.ASSET_ID
      and fab.ASSET_ID=glp.asset_id
      and fab.ASSET_ID=fdh.ASSET_ID
      and fat.LANGUAGE='US'
      --and fab.ASSET_ID=fth.ASSET_ID
      and fb.BOOK_TYPE_CODE='BMC_FA_BOOK'
      and fb.TRANSACTION_HEADER_ID_IN=fth.TRANSACTION_HEADER_ID
      and fb.transaction_header_id_out is null
      and fdh.CODE_COMBINATION_ID=gcc.CODE_COMBINATION_ID(+)
	  and fdh.location_id=fl.location_id
      and fdh.TRANSACTION_HEADER_ID_OUT is null
      and (fab.creation_date >= to_date('&&1','yyyy/mm/dd'))
      and (fab.creation_date <= to_date('&&2','yyyy/mm/dd'));
