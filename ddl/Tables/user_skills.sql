/*************************************************************
***
***  Name       :  user_skills.sql 
***  purpose    : To Map users with their skills list  
***                 
***  dependency :  Down stream dependency with User and skills table. 
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

drop table if exists user_skills ;

create table if not exists user_skills
( 
    user_id          integer 
   ,skill_id         integer  
   ,created_by       varchar(30) default 'SYSTEM'    
   ,created_dt       date default current_date 
   ,last_update_by   varchar(30) 
   ,last_update      date 
   
   ,CONSTRAINT fk_user_skills_user_id FOREIGN KEY(user_id) 
                               REFERENCES users(user_id)
   ,CONSTRAINT fk_user_skills_skill_id FOREIGN KEY(skill_id) 
                                REFERENCES skill_lst(skill_lst_id) 
 );