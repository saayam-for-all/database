/*************************************************************
***
***  Name       :  ddl_cntry.sql 
***  purpose    :  categorize the list of countries currently serving
***  Depemdency :  region 
***  
***
*** Data Model: https://drawsql.app/teams/sayam-team/diagrams/saayam-arch
*** Code Repo: https://github.com/saayam-for-all/database
***
*** Created on   : 06/29/2023 
*** Created By   : 
*** Last Update : 04/14/2024
*** Last update by : 
*** change comments: Initutive Column name changes
***
***
******************************************************************/
drop table if exists country ;

create table if not exists country
( 
    country_id      integer generated by default AS identity
   ,country_ph_cd   varchar(5) not null 
   ,country_nm      varchar(30)	 not null 
   ,region_id       integer  not null 
   ,created_dt      date default current_date 
   ,created_by      varchar(30) default 'SYSTEM'
   ,last_update_by  varchar(30)   
   ,last_update     date      
   ,CONSTRAINT  uk_cntry_cntry_id  unique(country_id)
   ,CONSTRAINT  pk_cntry_ph_cd   unique(country_ph_cd)
   ,CONSTRAINT  fk_regn_regn_id FOREIGN KEY (region_id) REFERENCES region(region_id)    
 );
 
 
 