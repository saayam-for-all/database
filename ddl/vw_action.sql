/*************************************************************
***
***  Name       :  vw_action.sql 
***  purpose    :  View for the action table. 
***  Dependency :  
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

create or replace view vw_actn as
select  
    actn_id   
   ,actn_dsc  
   ,cre_dt     
   ,cre_by      
   ,lst_upd      
   ,lst_upd_by 
from
   action     
  
 