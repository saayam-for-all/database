/*************************************************************
***
***  Name       :  cntry.sql 
***  purpose    :  countries dml 
***  Depemdency :  region , states 
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


insert into cntry(cntry_ph_cd , cntry_nm, regn_id , cre_dt , cre_by ) values ( 1 ,'United States' , 1, current_date , 'SYSTEM');
