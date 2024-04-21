/*************************************************************
***
***  Name       :  skill_lst_10.sql 
***  purpose    :  
***                
***  Depemdency :  user <---  skill_lst 
***               
***                  
***
*** Data Model: https://drawsql.app/teams/sayam-team/diagrams/saayam-arch
*** Code Repo : https://github.com/saayam-for-all/database/tree/main/ddl
***
*** Created on   : 06/10/2023 
*** Created By   : 
*** Last Update : 04/21/2024 
*** Last update by : 
*** change comments: Intuitive column changes
***
***
*****************************************************************/

drop table if exists skill_lst ;

create table if not exists skill_lst   
( 
    skill_lst_id     integer generated always as identity 
   ,skill_level      integer not null
   ,level_desc       varchar(100) not null 
   ,skill_last_used  date    
   ,is_actv          varchar(1)
   ,created_by       varchar(30) default 'SYSTEM'
   ,created_dt       date  
   ,last_update_by   varchar(30) 
   ,last_update      date 
    
   ,CONSTRAINT uk_skill_lst_id unique(skill_lst_id) 
   ,CONSTRAINT ck_skl_lvl CHECK( skill_level between 0 and 10 )
 )