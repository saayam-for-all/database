/*************************************************************
***
***  Name       :  state_lkp.sql 
***  purpose    :  To identigy snf categorize the group of users. 
***                Possible user types are Volunteers , donors, members, 
***  Depemdency :  Down stream dependency with Usr Table. 
***  
***
*** Data Model: https://drawsql.app/teams/sayam-team/diagrams/saayam-arch
*** Code Repo :  https://github.com/saayam-for-all/database/tree/main/ddl
*** 
*** Created on   : 06/10/2023 
*** Created By   : 
*** Last Updatee :
*** Last update by : 
*** change comments: 
***
***
*****************************************************************/


drop table if exists state_lkp ;

create table if not exists state_lkp  
( 
    country_id    integer
   ,state_id      integer generated always as identity
   ,state_cd      varchar(5) not null 
   ,state_nm      varchar(30) not null 
   ,created_by    varchar(30) not null default 'SYSTEM' 
   ,created_dt    date not null default current_date
   ,lst_update_by varchar(30) 
   ,lst_update_dt date 
   ,CONSTRAINT  fk_stlkp_country_id FOREIGN KEY (country_id) REFERENCES country(country_id)
);
 