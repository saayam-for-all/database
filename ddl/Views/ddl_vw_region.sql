/*************************************************************
***
***  Name       :  region.sql 
***  purpose    :  to retain the list of regions currently serving.
***                
***  Dependency :  country 
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

create or replace view vw_region
AS  
 select 
    regn_id    
   ,regn_nm   
   ,cre_dt     
   ,cre_by    
   ,lst_upd     
   ,lst_upd_by  
 from region