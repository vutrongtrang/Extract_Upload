create or replace procedure ESLTPTADM.PROC_CASH_DRAWER_UPLOAD
as

l_cash_drawer cash_drawer%ROWTYPE;

TYPE l_cash_drawer_ml_t is table of cash_drawer_ml%ROWTYPE index by pls_integer;
l_cash_drawer_ml l_cash_drawer_ml_t;

l_cash_drawer_instance CASH_DRAWER_INSTANCE%ROWTYPE;

TYPE l_cash_drawer_data_t is table of cash_drawer_data%ROWTYPE;
l_cash_drawer_data l_cash_drawer_data_t;

l_cnt pls_integer :=0;

l_drawer_date DATE;
begin
       --Init
       
       --l_workstation_device_attribute := new l_workstation_device_attr_t();
       --End Init
       for i in (select * from CASH_DRAWER_UPLOAD where CASH_DRAWER_ID is null) 
       loop
           BEGIN
           SAVEPOINT begin_process; 
           
           l_cash_drawer.CASH_DRAWER_ID := CASH_DRAWERID.nextval;
           l_cash_drawer.CASH_DRAWER_NAME := i.CASH_DRAWER_NAME;
           
           select LOCATION_CODE_ID
           into l_cash_drawer.LOCATION_CODE_ID 
           from  CORXPRADM.location_codes  x where x.location_name = i.location_name;
           
           --l_cash_drawer.LOCATION_CODE_ID:= i.LOCATION_CODE_ID;
           select DRAWER_TYPE_ID into
           l_cash_drawer.DRAWER_TYPE_ID
           from drawer_type where TYPE_NAME = i.DRAWER_TYPE_NAME;
           --l_cash_drawer.DRAWER_TYPE_ID := i.DRAWER_TYPE_ID;
           l_cash_drawer.CURRENCY_CODE := i.CURRENCY_CODE;
           l_cash_drawer.ZERO_BALANCE := i.ZERO_BALANCE;
           l_cash_drawer.Status := 'V';
           
           l_cash_drawer_ml(1).CASH_DRAWER_ID := l_cash_drawer.CASH_DRAWER_ID;
           l_cash_drawer_ml(1).language_id :=  'en';
           l_cash_drawer_ml(1).CASH_DRAWER_NAME := l_cash_drawer.CASH_DRAWER_NAME; 
           
           l_cash_drawer_ml(2).CASH_DRAWER_ID := l_cash_drawer.CASH_DRAWER_ID;
           l_cash_drawer_ml(2).language_id :=  'vi';
           l_cash_drawer_ml(2).CASH_DRAWER_NAME := l_cash_drawer.CASH_DRAWER_NAME;
           
           --find the drawer date 
           select max(today) into l_drawer_date
           from ESLTPTADM.location_log
           where location_code_id = l_cash_drawer.LOCATION_CODE_ID;

           l_cash_drawer_instance.CASH_DRAWER_ID := l_cash_drawer.CASH_DRAWER_ID;
           l_cash_drawer_instance.cash_drawer_date := l_drawer_date;
           
           l_cash_drawer_data := new l_cash_drawer_data_t();
           l_cnt:= 1;      
           for j in (select * from CASH_DRAWER_DATA_UPLOAD where CASH_DRAWER_UPLOAD_ID = i.CASH_DRAWER_UPLOAD_ID)
           loop
               l_cash_drawer_data.extend;
               l_cash_drawer_data(l_cnt).CASH_DRAWER_ID := l_cash_drawer.CASH_DRAWER_ID;
               select cash_field_id 
               into l_cash_drawer_data(l_cnt).CASH_FIELD_ID 
               from cash_box_fields where CASH_FIELD_NAME = j.CASH_FIELD_NAME;
               --l_cash_drawer_data(l_cnt).CASH_FIELD_ID := j.CASH_FIELD_ID;
               l_cash_drawer_data(l_cnt).VALUE := j.value;
               l_cash_drawer_data(l_cnt).access_count := 0;
               l_cash_drawer_data(l_cnt).VALUE_CCODE := j.VALUE_CCODE;
               l_cash_drawer_data(l_cnt).cash_drawer_date := l_drawer_date;
               l_cnt := l_cnt +1;
           end loop;
           
           l_cnt:= 1;
           
           
           insert into cash_drawer values l_cash_drawer;
           
           forall indx in 1..l_cash_drawer_ml.COUNT
                  insert into cash_drawer_ml values l_cash_drawer_ml(indx);
                        
           insert into cash_drawer_instance values l_cash_drawer_instance;
           
           forall indx in 1..l_cash_drawer_data.COUNT
                  insert into cash_drawer_data values l_cash_drawer_data(indx);
             
           update CASH_DRAWER_UPLOAD set CASH_DRAWER_ID = l_cash_drawer.CASH_DRAWER_ID
           where CASH_DRAWER_UPLOAD_ID = i.CASH_DRAWER_UPLOAD_ID;
           --COMMIT;
           EXCEPTION WHEN OTHERS THEN
                     dbms_output.put_line('Error '||SQLERRM);
                     ROLLBACK TO begin_process;
           END;
       end loop;
       
end;
/
