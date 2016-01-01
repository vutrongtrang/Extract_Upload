insert into  tptux.workstation_upload
select b.workstation_Id,  a.LOCATION_NAME, b.WORKSTATION_NAME, b.WORKSTATION_DESCRIPTION, b.WORKSTATION_TYPE, null workstation_id 
from tptux.location_codes a, tptux.workstation b
where a.location_code_id = b.location_code_id



insert into ESLTPTADM.WORKSTATION_DEVICE_UPLOAD
select a.workstation_id upload_id, a.workstation_name, b.device_id, null status  from tptux.workstation a, tptux.workstation_device b --, tptux.workstation_device_attribute c
where a.workstation_id = b.workstation_id 
/

insert into ESLTPTADM.WORKSTATION_DEVICE_DETAIL
select a.workstation_name, b.device_id, b.attribute_id from tptux.workstation a, tptux.workstation_device_attribute  b
where a.workstation_id = b.workstation_id 
/
--Workstation 

insert into ESLTPTADM.CASH_DRAWER_UPLOAD
select a.cash_drawer_id cash_drawer_upload_id, a.cash_drawer_name, c.location_name, 
b.type_name, a.currency_code, a.zero_balance, null cash_drawer_id
from tptux.cash_drawer a, tptux.location_codes c,  tptux.drawer_type  b
where b.drawer_type_id = a.drawer_type_id
and a.location_code_id = c.location_code_id
/

insert into ESLTPTADM.CASH_DRAWER_DATA_UPLOAD
with t as (
      select *  from ESLTPTADM.cash_drawer_data x
      where x.cash_drawer_date = 
      (
        select max(cash_drawer_date) from ESLTPTADM.cash_drawer_data c where c.cash_drawer_id = x.cash_drawer_id
      )
)
select  t.cash_drawer_id, a.cash_field_name, 0 value, t.value_ccode 
from tptux.cash_box_fields a , t where a.cash_field_id = t.cash_field_id
/


--Extract User --Change the extraction to outer join to include all users 
insert into  ESLTPTADM.USER_UPLOAD
select a.user_id USER_UPLOAD_ID, a.USER_NAME USER_NAME, a.DELIVERY_CHANNEL, 
a.PASSWORD, a.USER_DISABLED, a.USER_DESCRIPTION,a.AGENTID, b.FIRST_NAME, b.LAST_NAME,  
 (select location_name from tptux.location_codes where location_code_id = a.primary_location_id) as PRIMARY_location_name,
a.EMAIL_ADDRESS, a.SUPERVISORY_LEVEL, a.PWD_EXPIRES, a.IS_TEMPORARY, d.STREET, d.CITY, d.STATE_PROVINCE, d.COUNTRY, d.POSTAL_CODE,
a.IS_FLOATER, b.IS_SUPERVISOR, b.IS_MANAGER, 
(select title from tptux.employee_ml where employee_id = b.employee_id and  language_id = 'vi') as TITLE_VN,
(select title from tptux.employee_ml where employee_id = b.employee_id and language_id = 'en') as TITLE_en,
b.ssn, 
(select department  from tptux.employee_ml where employee_id = b.employee_id and language_id = 'vi') as DEPARTMENT_VN,
(select department from tptux.employee_ml where employee_id = b.employee_id and language_id = 'en') as DEPARTMENT_EN,
e.area_code, e.PHONE_NUMBER, b.EMPLOYEE_NUMBER, null user_id, null ERR_MSG
 from tptux.users a, tptux.employee b, tptux.user_as_employee c, tptux.address d, tptux.phone e
where a.user_id = c.user_id
and c.employee_id = b.employee_id 
and b.home_address = d.address_id
and b.home_phone = e.phone_id
/

--Correct query 
insert into  ESLTPTADM.USER_UPLOAD
with x as (
         select c.user_id, b.*
         from tptux.employee b, tptux.user_as_employee c
         where c.employee_id = b.employee_id 
   ), y as (
         select * from x
         left outer join tptux.address d on x.home_address = d.address_id 
         left outer join tptux.phone e  on x.home_phone = e.phone_id
    )
select u.user_id USER_UPLOAD_ID, u.USER_NAME USER_NAME, u.DELIVERY_CHANNEL, 
u.PASSWORD, u.USER_DISABLED, u.USER_DESCRIPTION,u.AGENTID, y.FIRST_NAME, y.LAST_NAME, 
(select location_name from tptux.location_codes where location_code_id = u.primary_location_id) as PRIMARY_location_name,
u.EMAIL_ADDRESS, u.SUPERVISORY_LEVEL, u.PWD_EXPIRES, u.IS_TEMPORARY, y.STREET, y.CITY, y.STATE_PROVINCE, y.COUNTRY, y.POSTAL_CODE,
u.IS_FLOATER, y.IS_SUPERVISOR, y.IS_MANAGER, 
(select title from tptux.employee_ml where employee_id = y.employee_id and  language_id = 'vi') as TITLE_VN,
(select title from tptux.employee_ml where employee_id = y.employee_id and language_id = 'en') as TITLE_en,
y.ssn, 
(select department  from tptux.employee_ml where employee_id = y.employee_id and language_id = 'vi') as DEPARTMENT_VN,
(select department from tptux.employee_ml where employee_id = y.employee_id and language_id = 'en') as DEPARTMENT_EN,
y.area_code, y.PHONE_NUMBER, y.EMPLOYEE_NUMBER, null user_id, null ERR_MSG
from tptux.users u 
left outer join y on u.user_id = y.user_id 
/


---> second command as location name is required 
insert into ESLTPTADM.USER_LOCATION_UPLOAD
select x.user_id USER_UPLOAD_ID,
(select location_name from tptux.location_codes where location_code_id = x.location_code_id) as LOCATION_NAME,
x.START_DATE, x.END_DATE, x.IS_PRIMARY, x.bank_id, x.region_id 
from tptux.user_location x
/
--Condition for Primary Location if location_code_id is null meaning the record is not required
insert into ESLTPTADM.USER_LOCATION_UPLOAD
select * from (
  select x.user_id USER_UPLOAD_ID,
  (select location_name from tptux.location_codes where location_code_id = x.location_code_id) as LOCATION_NAME,
  x.START_DATE, x.END_DATE, x.IS_PRIMARY, x.bank_id, x.region_id 
  from tptux.user_location x 
) where LOCATION_NAME is not null 
/

insert into ESLTPTADM.USER_ROLE_UPLOAD
select t.user_id as user_upload_id, (select role_name from tptux.roles where role_id = t.role_id) as ROLE_NAME,
t.ISDEFAULT, t.lob_id, t.SYNC_FLG
from tptux.user_roles t
/

--drawer assignment upload 
insert into ESLTPTADM.DRAWER_ASSIGNMENTS_UPLOAD
select a.user_id||c.cash_drawer_id upload_id, a.user_name, c.CASH_DRAWER_NAME, 
( select location_name from tptux.location_codes where location_code_id = c.location_code_id) as location_name
,b.is_default, null status  from 
ESLTPTADM.DRAWER_ASSIGNMENTS b, tptux.cash_drawer c, tptux.users a
where b.cash_drawer_id = c.cash_drawer_id 
and a.user_id =b.user_id

insert into ESLTPTADM.DRAWER_ASSIGNMENTS
select (select user_id from tptux.users where user_name = a.user_name) as user_id,
(select cash_drawer_id from tptux.cash_drawer where cash_drawer_name = a.cash_drawer_name
and location_code_id = (select location_code_id from tptux.location_codes where location_name = a.location_name)
) as cash_drawer_id, a.is_default
from ESLTPTADM.DRAWER_ASSIGNMENTS_UPLOAD a
/


delete from tptux.phone a where exists (select * from tptux.employee b where b.home_phone = a.phone_id);