/*************************************************************
***
***  Name       :  region.sql 
***  purpose    :  to retain the list of regions currently serving.
***                
***  Dependency :  country 
***  
***
*** Data Model: https://drawsql.app/teams/sayam-team/diagrams/saayam-arch
***
*** Created on   : 06/29/2023 
*** Created By   : 
*** Last Updatee :
*** Last update by : 
*** change comments: 
***
***
******************************************************************/

create or replace view vw_region
(
  region_id     
 ,region_name     
 ,created_date    
 ,created_by    
 ,last_update_by
 ,last_update
) 
AS  
 select 
  region_id     
 ,region_nm     
 ,created_dt    
 ,created_by    
 ,last_update_by
 ,last_update 
 from region
;