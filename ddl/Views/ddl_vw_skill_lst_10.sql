/*************************************************************
***
***  Name       :  vw_skill_lst_10.sql 
***  purpose    :  
***                
***  Depemdency :  user <---  skill_lst 
***               
***                  
***
*** Data Model: https://drawsql.app/teams/sayam-team/diagrams/saayam-arch
*** Code Repo : https://github.com/saayam-for-all/database/tree/main/ddl
***
*** Created on   : 06/10/2023 
*** Created By   : 
*** Last Update : 04/21/2024 
*** Last update by : 
*** change comments: Intuitive column changes
***
***
*****************************************************************/



create or replace view vw_skill_lst
( 
    skill_lst_id      
   ,skill_level      
   ,level_desc       
   ,skill_last_used  
   ,is_actv          
   ,created_by       
   ,created_dt       
   ,last_update_by   
   ,last_update      
)
as 
select 
    skill_lst_id      
   ,skill_level      
   ,level_desc       
   ,skill_last_used  
   ,is_actv          
   ,created_by       
   ,created_dt       
   ,last_update_by   
   ,last_update      
from skill_lst
;
