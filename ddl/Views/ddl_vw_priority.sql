/*************************************************************
***
***  Name       :  vw_priority.sql 
***  purpose    :  To identigy and categorize priority of the requests. 
***  Depemdency :  
***  
***
*** Data Model: https://drawsql.app/teams/sayam-team/diagrams/saayam-arch
*** Code Repo  : https://github.com/saayam-for-all/database/tree/main/ddl
***
*** Created on   : 06/29/2023 
*** Created By   : 
*** Last Update : 04/14/2024
*** Last update by : 
*** change comments: Initutive Column Changes
***
***
******************************************************************/

create or replace view vw_priority
( 
    priority_id     
   ,priority_typ    
   ,priority_desc   
   ,created_by      
   ,created_dt      
   ,last_update_by  
   ,last_update_dt 
)
as 
 select  
    priority_id     
   ,priority_typ    
   ,priority_desc   
   ,created_by      
   ,created_dt      
   ,last_update_by  
   ,lapst_update_dt
  from priority
;