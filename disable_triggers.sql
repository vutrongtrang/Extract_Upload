set wrap off
set head off
set lines 1000
SPOOL C:\disale_triggers.SQL
select ' alter table ' ||table_owner||'.'||table_name || ' disable ALL TRIGGERS  ;' from dba_triggers where table_owner in
(
'ESLTPTADM','SECFRPADM','CORXPRADM','TPTUX'
);
spool off
spool C:\disale_triggers.log
@C:\disale_triggers.SQL
spool off