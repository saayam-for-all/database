/*************************************************************
***
***  Name       :  state_lkp.sql 
***  purpose    :  View for the state lookup table. 
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
create or replace view vw_state_lkp 
(
 country_id    
 ,state_id      
 ,state_cd      
 ,state_nm      
 ,created_by    
 ,created_dt    
 ,last_update_by
 ,last_update   
)
as
 select 
   country_id    
   ,state_id      
   ,state_cd      
   ,state_nm      
   ,created_by    
   ,created_dt    
   ,last_update_by
   ,last_update   
 from 
   state_lkp
;