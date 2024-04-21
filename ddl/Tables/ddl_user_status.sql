/*************************************************************
***
***  Name       :  user_status.sql 
***  purpose    :  This table stores the statuses of each users. 
***                 Available users statuses are Active , Inactive
***                
***  Dependency :  
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
*****************************************************************/


drop table if exists user_status ;

create table if not exists user_status   
( 
    user_status_id     integer not null , 
	user_status_desc   varchar(30) not null 
   ,created_by         varchar(30) not null default 'SYSTEM' 
   ,created_dt         date not null default current_date
   ,last_update_by     varchar(30) 
   ,last_update        date    
   
   ,CONSTRAINT uk_user_status_id unique( user_status_id )
);

