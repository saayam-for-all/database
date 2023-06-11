/*************************************************************
***
***  Name       :  usr_typ.sql 
***  purpose    :  To identigy snf categorize the group of users. 
***  Depemdency :  Down stream dependency with Usr Table. 
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

drop table if exists usr_typ ;

create table if not exists usr_typ 
( 
    usr_typ_id   integer generated always as identity
   ,usr_typ      varchar(15) not null 
   ,usr_typ_dsc varchar(30) not null 
   ,cre_dt       date default current_date 
   ,cre_by       varchar(30) default 'SYSTEM' 
   ,lst_upd      date 
   ,lst_upd_by   varchar(30) 
   ,CONSTRAINT  uk_ut_utypid  unique(usr_typ_id) 
 );
