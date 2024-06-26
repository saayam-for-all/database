/*************************************************************
***
***  Name       :  vw_action.sql 
***  purpose    :  View for the action table. 
***  Dependency :  
***  
***
*** Data Model: https://drawsql.app/teams/sayam-team/diagrams/saayam-arch
*** Code Repo : https://github.com/saayam-for-all/database
***
*** Created on   : 06/29/2023 
*** Created By   : 
*** Last Updatee :
*** Last update by : 
*** change comments: 
***
***
******************************************************************/

create or replace view vw_action 
 (
  action_id    
 ,action_desc  
 ,created_dt   
 ,created_by   
 ,last_upd_by  
 ,last_upd_dt 
)
AS
 select action_id    
   ,action_desc   
   ,created_dt   
   ,created_by    
   ,last_upd_by  
   ,last_upd_dt  
 from 
  action
 ;
  
 