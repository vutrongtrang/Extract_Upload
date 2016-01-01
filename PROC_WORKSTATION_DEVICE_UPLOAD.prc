CREATE OR REPLACE PROCEDURE  ESLTPTADM.PROC_WORKSTATION_DEVICE_UPLOAD
AS

TYPE l_workstation_device_t is table of workstation_device%ROWTYPE;
l_workstation_device l_workstation_device_t;

TYPE l_workstation_device_attr_t is table of workstation_device_attribute%ROWTYPE;
l_workstation_device_attribute l_workstation_device_attr_t;

l_cnt pls_integer :=0;
l_cnt_1 pls_integer :=0;

BEGIN
      l_workstation_device := new l_workstation_device_t();
      l_workstation_device_attribute := new l_workstation_device_attr_t();
      l_cnt := 1;
      l_cnt_1 := 1;
      for i in (select * from ESLTPTADM.WORKSTATION_DEVICE_UPLOAD)
      loop
               l_workstation_device.extend;
               
               select workstation_id into  
               l_workstation_device(l_cnt).WORKSTATION_ID 
               from workstation where workstation_name = i.WORKSTATION_NAME;
               
               l_workstation_device(l_cnt).DEVICE_ID := i.DEVICE_ID;
               
               
               
               
               for j in (select * from WORKSTATION_DEVICE_DETAIL a where WORKSTATION_NAME = i.WORKSTATION_NAME
                   and a.device_id = i.device_id
               )
               loop
                   l_workstation_device_attribute.extend;
                   l_workstation_device_attribute(l_cnt_1).WORKSTATION_ID := l_workstation_device(l_cnt).WORKSTATION_ID;
                   l_workstation_device_attribute(l_cnt_1).DEVICE_ID := j.device_id; 
                   l_workstation_device_attribute(l_cnt_1).ATTRIBUTE_ID := j.ATTRIBUTE_ID;
                   l_cnt_1 := l_cnt_1 + 1;
               end loop;
               
               l_cnt := l_cnt +1;
      end loop;
      
      forall indx in 1..l_workstation_device.COUNT
                  insert into workstation_device values l_workstation_device(indx);
                  
      forall indx in 1..l_workstation_device_attribute.COUNT
                  insert into workstation_device_attribute values l_workstation_device_attribute(indx); 
      
      commit;
END;
/
