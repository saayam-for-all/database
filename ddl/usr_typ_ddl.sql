/*************************************************************
***
***  Name       :  usr_typ.sql 
***  purpose    :  To identigy snf categorize the group of users. 
***                Possible user types are Volunteers , donors, members, 
***  Depemdency :  Down stream dependency with Usr Table. 
***  
***
*** Data Model: https://drawsql.app/teams/sayam-team/diagrams/saayam-arch
*** Code Repo : https://github.com/saayam-for-all/database/tree/main
***
*** Created on   : 06/10/2023 
*** Created By   : 
*** Last Update : 04/14/2024
*** Last update by : 
*** change comments:  Initutive Column changes
***
***
******************************************************************/

drop table if exists user_type ;

create table if not exists user_type 
( 
    user_type_id      integer generated always as identity
   ,user_type         varchar(15) not null 
   ,user_type_desc     varchar(30) not null
   ,created_by       varchar(30) default 'SYSTEM'    
   ,created_dt       date default current_date 
   ,last_update_by   varchar(30) 
   ,last_update      date 
   
   ,CONSTRAINT  uk_ut_utypid  unique(user_type_id) 
 );