/*************************************************************
***
***  Name       :  usr_typ.sql 
***  purpose    :  To identigy and categorize the group of users. 
***                Possible user types are Volunteers , donors, members, 
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
*****************************************************************/


drop table if exists usr_typ ;

create table if not exists state_lkp  
( 
    cntry_id  integer
   ,state_id  integer generated always as identity
   ,state_cd  varchar(5) not null 
   ,state_nm  varchar(30) not null 
   ,cre_by    varchar(30) not null default 'SYSTEM' 
   ,cre_dt    date not null default current_date
   ,lst_upd_by varchar(30) 
   ,lst_upd_dt date 
   ,constraint uk_sta_id  unique(state_id) 
  ,constraint fk_cntry_id foreign key(cntry_id) REFERENCES cntry(cntry_id)   
);
-----------------------------dml-------------------------------------------------
insert into state_lkp(cntry_id,state_cd,state_nm) values ( 1,'TX','Texas');
insert into state_lkp(cntry_id,state_cd,state_nm) values ( 1,'WA','Washington');
insert into state_lkp(cntry_id,state_cd,state_nm) values ( 1,'DE','Delaware');
insert into state_lkp(cntry_id,state_cd,state_nm) values ( 2,'TN','TamilNadu');
insert into state_lkp(cntry_id,state_cd,state_nm) values ( 2,'KL','Kerala'); 