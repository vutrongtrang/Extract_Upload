set wrap off
set head off
set lines 1000
SPOOL C:\enable_triggers.SQL
select ' alter table ' ||table_owner||'.'||table_name || ' enable ALL TRIGGERS  ;' from dba_triggers where table_owner in
(
'ESLTPTADM','SECFRPADM','CORXPRADM','TPTUX'
);
spool off
spool C:\enable_triggers.log
@C:\enable_triggers.SQL
spool off