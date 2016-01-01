create or replace procedure ESLTPTADM.PROC_WORKSTATION_UPLOAD
as

l_workstation workstation%ROWTYPE;

/*TYPE l_workstation_device_t is table of workstation_device%ROWTYPE;
l_workstation_device l_workstation_device_t;

TYPE l_workstation_device_attr_t is table of workstation_device_attribute%ROWTYPE;
l_workstation_device_attribute l_workstation_device_attr_t;

l_cnt pls_integer :=0;*/

begin
       --Init
       /*l_workstation_device := new l_workstation_device_t();
       l_workstation_device_attribute := new l_workstation_device_attr_t();*/
       --End Init
       for i in (select * from WORKSTATION_UPLOAD where WORKSTATION_ID is null) 
       loop
           BEGIN
           SAVEPOINT begin_process; 
           
           l_workstation.WORKSTATION_ID := WORKSTATIONID.nextval;
           
           select LOCATION_CODE_ID
           into l_workstation.LOCATION_CODE_ID 
           from  CORXPRADM.location_codes  x where x.location_name = i.location_name;  
           
           l_workstation.WORKSTATION_NAME:= i.WORKSTATION_NAME;
           l_workstation.WORKSTATION_DESCRIPTION := i.WORKSTATION_DESCRIPTION;
           l_workstation.WORKSTATION_TYPE := i.WORKSTATION_TYPE;
           l_workstation.WORKSTATION_HOST_STATUS := 'Y';
           
           
           /*l_cnt:= 1;      
           for j in (select * from WORKSTATION_DEVICE_UPLOAD where WORKSTATION_UPLOAD_ID = i.WORKSTATION_UPLOAD_ID)
           loop
               l_workstation_device.extend;
               l_workstation_device(l_cnt).WORKSTATION_ID := l_workstation.WORKSTATION_ID;
               l_workstation_device(l_cnt).DEVICE_ID := j.DEVICE_ID;
               l_cnt := l_cnt +1;
           end loop;
           
           l_cnt:= 1;
           for j in (select * from WORKSTA_DEVICE_ATTR_UPLOAD where WORKSTATION_UPLOAD_ID = i.WORKSTATION_UPLOAD_ID)
           loop
               l_workstation_device_attribute.extend;
               l_workstation_device_attribute(l_cnt).WORKSTATION_ID := l_workstation.WORKSTATION_ID;
               l_workstation_device_attribute(l_cnt).DEVICE_ID := j.DEVICE_ID;
               l_workstation_device_attribute(l_cnt).ATTRIBUTE_ID := j.ATTRIBUTE_ID;
               
           end loop;*/
           
           insert into workstation values l_workstation;
           
           /*forall indx in 1..l_workstation_device.COUNT
                  insert into workstation_device values l_workstation_device(indx);
                  
           forall indx in 1..l_workstation_device_attribute.COUNT
                  insert into workstation_device_attribute values l_workstation_device_attribute(indx);  */     
           
           update WORKSTATION_UPLOAD set WORKSTATION_ID = l_workstation.WORKSTATION_ID
           where WORKSTATION_UPLOAD_ID = i.WORKSTATION_UPLOAD_ID;
           --COMMIT;
           EXCEPTION WHEN OTHERS THEN
                     dbms_output.put_line('Error '||SQLERRM);
                     ROLLBACK TO begin_process;
           END;
       end loop;
       
end;
/
