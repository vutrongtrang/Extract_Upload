set wrap off
set head off
set lines 1000
SPOOL C:\disable_constraints.SQL
select ' alter table ' ||owner||'.'||table_name || ' disable constraint '|| constraint_name|| ';' from dba_constraints where owner in
(
'ESLTPTADM','SECFRPADM','CORXPRADM','TPTUX'
)and status = 'ENABLED' and constraint_type in ('C','R','P') order by 
decode(constraint_type, 'C',1, 'O', 2, 'R', 3, 'P',4) asc;
spool off
spool C:\disable_constraints.log
@C:\disable_constraints.SQL
spool off