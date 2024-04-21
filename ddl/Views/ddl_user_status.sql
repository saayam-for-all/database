/*************************************************************
***
***  Name       :  vw_user_status.sql 
***  purpose    :  
***                 
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
*** change comments:  
***
***
*****************************************************************/

create or replace view vw_user_status   
( 
    user_status_id     
   ,user_status_desc   
   ,created_by          
   ,created_dt         
   ,last_update_by     
   ,last_update        
)
as select  
    user_status_id     
   ,user_status_desc   
   ,created_by          
   ,created_dt         
   ,last_update_by     
   ,last_update
from user_status
 ;
