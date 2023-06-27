 /*************************************************************
***
***  Name       :  vw_sla.sql 
***  purpose    :  view form the table SLA
***  Depemdency :  user table
***  
***
*** Data Model: https://drawsql.app/teams/sayam-team/diagrams/saayam-arch
***
*** Created on   : 06/10/2023 
*** Created By   : 
*** Last Updatee :
*** Last update by : 
*** change comments: 
***
***
******************************************************************/
 
 create or replace view vw_sla
 AS Select 
     sla_id    
   ,hrs_limit  
   ,sla_typ_dsc 
   ,cre_dt      
   ,cre_by       
   ,lst_upd     
   ,lst_upd_by  
   from 
      sla
	  ;