/*************************************************************
***
***  Name       :  ddl_vw_sla.sql 
***  purpose    :  view for table sla 
***  Dependency :  Down stream dependency with User or request Table. 
***  
***
*** Data Model: https://drawsql.app/teams/sayam-team/diagrams/saayam-arch
***
*** Created on   : 06/27/2023 
*** Created By   : 
*** Last Updatee :
*** Last update by : 
*** change comments: 
***
***
******************************************************************/

 create or replace view vw_sla
 (
    sla_id          
   ,sla_typ_dsc     
   ,no_of_cust_impct
   ,eta_in_hrs      
   ,created_by      
   ,created_dt      
   ,last_update_by  
   ,last_update     
 )
 AS
  select 
     sla_id          
    ,sla_typ_dsc     
    ,no_of_cust_impct
    ,eta_in_hrs      
    ,created_by      
    ,created_dt      
    ,last_update_by  
    ,last_update
from sla 
;