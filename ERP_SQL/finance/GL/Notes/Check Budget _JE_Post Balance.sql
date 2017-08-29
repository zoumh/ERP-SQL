col ccid format 999999 
col period format a9 
col currency format a8 
col balances_cr format 999,999,999,999.99 
col balances_dr format 999,999,999,999.99 
col lines_cr format 999,999,999,999.99 
col lines_dr format 999,999,999,999.99 
set pagesize 132 
-- part for functional currency 


select b.code_combination_id ccid, 
       b.period_name period, 
       b.currency_code currency, 
       nvl(b.period_net_cr, 0) balances_cr, 
       nvl(b.period_net_dr, 0) balances_dr, 
       sum(nvl(l.accounted_cr, 0)) lines_cr, 
       sum(nvl(l.accounted_dr, 0)) lines_dr 
from   gl.gl_je_headers h 
       , gl.gl_je_lines l 
       , gl.gl_balances b 
where b.set_of_books_id = 1 
and    b.period_name LIKE '%05' 
and    b.actual_flag = 'B' -- A Actual, B Budget, E Encumbrance 
and    b.currency_code != 'STAT' 
and    b.currency_code = 'CNY' 
and    l.set_of_books_id = b.set_of_books_id 
and    l.period_name = b.period_name 
and    l.code_combination_id = b.code_combination_id 
and    (b.translated_flag <> 'Y' or b.translated_flag is null) 
and    h.je_header_id = l.je_header_id 
and    h.actual_flag = b.actual_flag 
and    h.currency_code != 'STAT' 
and    h.status = 'P' 
group by b.code_combination_id, 
         b.period_name, 
         b.currency_code, 
         nvl(b.period_net_cr, 0), 
         nvl(b.period_net_dr, 0) 
having   nvl(b.period_net_cr,0) <> sum(nvl(accounted_cr,0)) 
or nvl(b.period_net_dr,0) <> sum(nvl(accounted_dr,0)) 


union 
--part for foreign currencies 


select b.code_combination_id ccid, 
       b.period_name period, 
       b.currency_code currency, 
       nvl(b.period_net_cr, 0) balances_cr, 
       nvl(b.period_net_dr, 0) balances_dr, 
       sum(nvl(l.entered_cr, 0)) lines_cr, 
       sum(nvl(l.entered_dr, 0)) lines_dr 
from   gl.gl_je_headers h 
       , gl.gl_je_lines l 
       , gl.gl_balances b 
where b.set_of_books_id = 1 
and    b.period_name LIKE '%05' 
and    b.actual_flag = 'B' -- A Actual, B Budget, E Encumbrance 
and    b.currency_code != 'STAT' 
and    b.currency_code != 'CNY' 
and    l.set_of_books_id = b.set_of_books_id 
and    l.period_name = b.period_name 
and    l.code_combination_id = b.code_combination_id 
and    (b.translated_flag <> 'Y' or b.translated_flag is null) 
and    h.je_header_id = l.je_header_id 
and    h.actual_flag = b.actual_flag 
and    h.currency_code = b.currency_code 
and    h.currency_code != 'STAT' 
and    h.status = 'P' 
group by b.code_combination_id, 
         b.period_name, 
         b.currency_code, 
         nvl(b.period_net_cr, 0), 
         nvl(b.period_net_dr, 0) 
having   nvl(b.period_net_cr,0) <> sum(nvl(entered_cr,0)) 
or nvl(b.period_net_dr,0) <> sum(nvl(entered_dr,0)); 
 

