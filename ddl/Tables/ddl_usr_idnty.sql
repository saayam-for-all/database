/*************************************************************
***
***  Name       :  idnty_typ.sql 
***  purpose    :  
***                
***  Depemdency : upstream --->  country, region 
***               down stream----> usr_idnty 
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
*****************************************************************/

drop table if exists idnty_typ ;

create table if not exists idnty_typ   
( 
    idnty_id       integer generated always as identity 
   ,idnty_typ_cd        varchar(30)
   ,idnty_typ_desc      varchar(100) 
   ,idnty_value         varchar(30)
   ,owning_cntry        integer
   , CONSTRAINT uk_user_idnty_id unique( idnty_id ) 
   , CONSTRAINT  fk_cntry_cntry_id FOREIGN KEY (owning_cntry) REFERENCES cntry(cntry_id)
 )
   
 
   
  