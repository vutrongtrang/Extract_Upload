set wrap off
set head off
set lines 10000
SPOOL C:\enable_constraints.SQL
select ' alter table ' ||owner||'.'||table_name || ' enable constraint '|| constraint_name|| ' ;' from dba_constraints where owner in
(
'ESLTPTADM','SECFRPADM','CORXPRADM','TPTUX'
) and status <> 'ENABLED' order by 
decode(constraint_type, 'C',2, 'O', 3, 'R', 4, 'P',1) asc;
spool off
spool C:\enable_constraints.log
@C:\enable_constraints.SQL
spool off