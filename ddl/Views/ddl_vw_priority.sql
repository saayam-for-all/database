/*************************************************************
***
***  Name       :  vw_priority.sql 
***  purpose    :  A View for priority table. 
***  Depemdency :  
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


create or replace view vw_priority AS 
SELECT 
    prty_id   AS priority_ID  
   ,prty_typ  AS priority_TYPE 
   ,prty_desc  
   ,cre_dt       
   ,cre_by       
   ,lst_upd       
   ,lst_upd_by   
  from 
     priority   
 ;