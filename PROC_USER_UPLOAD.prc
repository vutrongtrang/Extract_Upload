create or replace procedure ESLTPTADM.PROC_USER_UPLOAD
as

l_user  CORXPRADM.users%ROWTYPE;

type USER_LOCATION_t is table of USER_LOCATION%rowtype;
l_user_location USER_LOCATION_t;

type user_roles_t is table of CORXPRADM.User_Roles%ROWTYPE;
l_user_roles user_roles_t;

l_employee ESLTPTADM.Employee%ROWTYPE;
l_usr_employee ESLTPTADM.User_As_Employee%ROWTYPE;

type employee_ml_t is table of EMPLOYEE_ML%ROWTYPE index by pls_integer;
l_employee_ml employee_ml_t;

l_address CORXPRADM.address%ROWTYPE;
l_phone phone%ROWTYPE;

l_index pls_integer := 0;

begin
        for i in (select * from user_upload where user_id is null )
        loop
            begin
                    l_user := null;
                    l_user.user_id := CORXPRADM.Usersid.NEXTVAL;
                    l_user.supervisory_level :=i.SUPERVISORY_LEVEL;
                    --l_user.supervisor_disabled :=i.SUPERVISOR_DISABLED;
                    l_user.email_address :=i.EMAIL_ADDRESS;
                    --l_user.primary_location_id :=i.PRIMARY_LOCATION_ID;
                    BEGIN
                    select LOCATION_CODE_ID
                    into l_user.primary_location_id
                    from  CORXPRADM.location_codes  x where x.location_name = i.PRIMARY_location_name;
                    EXCEPTION WHEN NO_DATA_FOUND THEN
                         l_user.primary_location_id := null;
                    END;
                    l_user.is_floater :=i.IS_FLOATER;
                    l_user.agentid :=i.AGENTID;
                    l_user.user_description :=i.USER_DESCRIPTION;
                    l_user.user_disabled :=i.USER_DISABLED;
                    l_user.password :=i.PASSWORD;
                    l_user.delivery_channel :=i.DELIVERY_CHANNEL;
                    l_user.user_name :=i.USER_NAME;
                    
                    l_user.pwd_expires := i.pwd_expires;
                    l_user.is_temporary := i.is_temporary;
                    
                    --Constant 
                    l_user.single_logon_allowed := 'N';
                    l_user.creation := sysdate;
                    l_user.last_access := sysdate;
                    l_user.last_pwd_change := sysdate;
                    
                    l_user.access_flags := 400;
                    
                    l_user.expire_count := 0;
                    l_user.security_count := 0;
                    l_user.first_name := i.first_name;
                    l_user.last_name := i.last_name;
                    l_user.date_changed := sysdate;
                    l_user.search_name := upper(i.last_name)||', '||upper(i.first_name);
                    l_user.last_logon := sysdate;
                    l_user.is_active := 'Y';
                    l_user.sync_flg := 'Y';
                    
                    l_employee.employee_id := EMPLOYEEID.nextval;
                    l_employee.ssn :=i.SSN;
                    l_employee.is_manager :=i.IS_MANAGER;
                    l_employee.is_supervisor :=i.IS_SUPERVISOR;
                    l_employee.last_name :=i.LAST_NAME;
                    l_employee.first_name :=i.FIRST_NAME;
                    l_employee.department := i.DEPARTMENT_EN;
                    l_employee.title := i.TITLE_EN;
                    l_employee.employee_number := i.employee_number;
                    --Constant
                    l_employee.emp_creator :=1;
                    l_employee.hire_date := sysdate;
                    l_employee.emp_creation_date := sysdate;
                    l_employee.emp_modification_date := sysdate;
                    l_employee.is_relation_mgr:= 'N';
                    l_employee.emp_modified_by := 1;
                    
                    l_employee_ml(1).employee_id := l_employee.employee_id;
                    l_employee_ml(1).DEPARTMENT :=i.DEPARTMENT_EN;
                    l_employee_ml(1).LANGUAGE_ID := 'en';
                    l_employee_ml(1).TITLE  :=i.TITLE_EN;
                    
                    l_employee_ml(2).employee_id := l_employee.employee_id;
                    l_employee_ml(2).DEPARTMENT :=i.DEPARTMENT_VN;
                    l_employee_ml(2).LANGUAGE_ID := 'vi';
                    l_employee_ml(2).TITLE  :=i.TITLE_VN;
                     
                     
                    l_phone.PHONE_NUMBER :=i.PHONE_NUMBER;
                    l_phone.AREA_CODE :=i.AREA_CODE;
                    l_phone.PHONE_ID := PHONEID.nextval;
                                   
                    l_address.postal_code :=i.POSTAL_CODE;
                    l_address.country :=i.COUNTRY;
                    l_address.state_province :=i.STATE_PROVINCE;
                    l_address.city :=i.CITY;
                    l_address.street :=i.STREET;
                    l_address.address_id := CORXPRADM.Addressid.NEXTVAL;
                    
                    l_employee.home_phone :=  l_phone.PHONE_ID;
                    l_employee.home_address := l_address.address_id;
                    
                    
                    
                    
              l_index := 1; 
              l_user_location := new USER_LOCATION_t();   
              for j in (select * from ESLTPTADM.USER_LOCATION_UPLOAD where USER_UPLOAD_ID = i.USER_UPLOAD_ID)
              loop
                  l_user_location.extend;
                  l_user_location(l_index).user_id := l_user.user_id;
                  select LOCATION_CODE_ID
                  into l_user_location(l_index).LOCATION_CODE_ID 
                   from  CORXPRADM.location_codes  x where x.location_name = j.location_name;
                  --l_user_location(l_index).LOCATION_CODE_ID := j.LOCATION_CODE_ID;
                  l_user_location(l_index).START_DATE := j.START_DATE;
                  l_user_location(l_index).END_DATE := j.END_DATE;
                  l_user_location(l_index).IS_PRIMARY := j.IS_PRIMARY;
                  l_user_location(l_index).BANK_ID := j.BANK_ID;
                  l_user_location(l_index).REGION_ID := j.REGION_ID; 
                  l_index := l_index + 1; 
              end loop;
              
              l_index := 1; 
              l_user_roles := new user_roles_t();
              for z in (select * from ESLTPTADM.USER_ROLE_UPLOAD where USER_UPLOAD_ID = i.USER_UPLOAD_ID
                  and role_name <> 'Supervisor'
              )
              loop
                  l_user_roles.extend;
                  l_user_roles(l_index).user_id := l_user.user_id;
                  --l_user_roles(l_index).ROLE_ID := z.ROLE_ID;
                  select role_id
                  into 
                  l_user_roles(l_index).ROLE_ID
                  from CORXPRADM.roles
                  where role_name = z.ROLE_NAME;
                  
                  l_user_roles(l_index).ISDEFAULT := z.ISDEFAULT;
                  l_user_roles(l_index).LOB_ID := z.LOB_ID;
                  l_user_roles(l_index).sync_flg := 'Y';
                  l_index := l_index + 1;
              end loop;
              
              --dbms_output.put_line('User ID '||l_user.user_id);
                            
              insert into users values l_user;
              
              insert into phone values l_phone;
              
              insert into CORXPRADM.address values l_address; 
              
              insert into employee values l_employee;
              
              insert into user_as_employee values(l_user.user_id, l_employee.employee_id);
              
              forall indx in 1..l_employee_ml.count
                     insert into employee_ml  values l_employee_ml(indx);
                     
              forall indx in 1.. l_user_location.COUNT
                     insert into user_location values l_user_location(indx);
                     
              forall indx in 1.. l_user_roles.COUNT       
                     insert into CORXPRADM.User_Roles values l_user_roles(indx);
            
            exception when others then
                      dbms_output.put_line(SQLERRM);
                      dbms_output.put_line( dbms_utility.format_error_backtrace );
                      null;
            end;
        end loop;
        
end;
/
