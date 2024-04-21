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
*** Code Repo : https://github.com/saayam-for-all/database/tree/main/ddl
***
*** Created on   : 06/10/2023 
*** Created By   : 
*** Last Updatee :  04/14/2024
*** Last update by : 
*** change comments: Initutive Column Changes
***
***
*****************************************************************/

drop table if exists identity_type ;

create table if not exists identity_type   
( 
    identity_type_id       integer generated always as identity 
   ,identity_type_cd       varchar(30)
   ,identity_type_dsc      varchar(100) 
   ,identity_value         varchar(30)
   ,owning_country         integer
   , CONSTRAINT uk_user_idnty_id unique( identity_type_id ) 
   , CONSTRAINT  pk_ity_itycd PRIMARY KEY (identity_type_cd )
   , CONSTRAINT  fk_cntry_cntry_id FOREIGN KEY (owning_country) REFERENCES country(country_id)
 );