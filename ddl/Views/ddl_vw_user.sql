/*************************************************************
***
***  Name       :  vw_users.sql 
***  purpose    :  
***                
***  Dependency :  
***  
***
*** Data Model: https://drawsql.app/teams/sayam-team/diagrams/saayam-arch
*** Code Repo : https://github.com/saayam-for-all/database/tree/main
***
*** Created on   : 06/10/2023 
*** Created By   : 
*** Last Update : 04/14/2024
*** Last update by : 
*** change comments:  Initutive Column changes 
***
***
*****************************************************************/


create or replace view vw_users   
( 
    user_id            
   ,identity_type_id   
   ,first_name           
   ,middle_name        
   ,last_name          
   ,email_id           
   ,phone_nbr          
   ,contact_nbr        
   ,addr_line1           
   ,addr_line2           
   ,addr_line3           
   ,country_id         
   ,state_id           
   ,city               
   ,zip_code             
   ,geo_code             
   ,region_date          
   ,user_status_id     
   ,user_status_dt     
   ,emergency_availablity_ind 
   ,created_by        
   ,created_dt         
   ,last_update_by     
   ,last_update        
) as select 
    user_id            
   ,identity_type_id   
   ,first_nm           
   ,middle_name        
   ,last_name          
   ,email_id           
   ,phone_nbr          
   ,contact_nbr        
   ,addr_ln1           
   ,addr_ln2           
   ,addr_ln3           
   ,country_id         
   ,state_id           
   ,city               
   ,zip_cd             
   ,geo_cd             
   ,region_dt          
   ,user_status_id     
   ,user_status_dt     
   ,emrgncy_avblty_ind 
   ,created_by        
   ,created_dt         
   ,last_update_by     
   ,last_update
from users
;