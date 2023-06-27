/*************************************************************
***
***  Name       :  ddl_vw_sla.sql 
***  purpose    :  view for table sla 
***  Dependency :  Down stream dependency with User or request Table. 
***  
***
*** Data Model: https://drawsql.app/teams/sayam-team/diagrams/saayam-arch
***
*** Created on   : 06/27/2023 
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