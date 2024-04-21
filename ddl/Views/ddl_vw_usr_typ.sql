/*************************************************************
***
***  Name       :  vw_usr_typ.sql 
***  purpose    :  
***                
***  Dependency :  
***  
***
*** Data Model: https://drawsql.app/teams/sayam-team/diagrams/saayam-arch
*** Code Repo : https://github.com/saayam-for-all/database/tree/main
***
*** Created on   : 04/21/2024 
*** Created By   : 
*** Last Update : 
*** Last update by : 
*** change comments:  
***
***
******************************************************************/

create or replace view vw_user_type 
( 
    user_type_id     
   ,user_type        
   ,user_type_desc   
   ,created_by       
   ,created_dt       
   ,last_update_by   
   ,last_update      
 )
 as 
 select 
    user_type_id     
   ,user_type        
   ,user_type_desc   
   ,created_by       
   ,created_dt       
   ,last_update_by   
   ,last_update
 from user_type
 ;