/*************************************************************
***
***  Name       :  vw_country.sql 
***  purpose    :  View for the country table. 
***  Dependency :  
***  
***
*** Data Model: https://drawsql.app/teams/sayam-team/diagrams/saayam-arch
*** Code Repo : https://github.com/saayam-for-all/database
***
*** Created on   : 04/21/2024 
*** Created By   : 
*** Last Updatee :
*** Last update by : 
*** change comments: 
***
***
******************************************************************/

create or replace view vw_country
( 
    country_id
   ,country_phone_code   
   ,country_name      
   ,region_id        
   ,created_date       
   ,created_by      
   ,last_update_by    
   ,last_update 
)
AS
select  
    country_id      
   ,country_ph_cd   
   ,country_nm      
   ,region_id       
   ,created_dt      
   ,created_by      
   ,last_update_by  
   ,last_update     
from
   country 
;
   
  
 