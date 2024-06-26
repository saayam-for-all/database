/*************************************************************
***
***  Name       :  users.sql 
***  purpose    :  This table stores the details of all type 
***                of users like Donors ,Volunteers.
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


drop table if exists users ;

create table if not exists users   
( 
    user_id            integer generated always as identity
   ,identity_type_id       integer 
   ,first_nm           varchar(30) not null 
   ,middle_name        varchar(30) 
   ,last_name          varchar(30) not null 
   ,email_id           varchar(100) not null 
   ,phone_nbr          varchar(30) 
   ,contact_nbr        varchar(30)    not null
   ,addr_ln1           varchar(50)  not null 
   ,addr_ln2           varchar(50)
   ,addr_ln3           varchar(50)
   ,country_id         integer     not null 
   ,state_id           integer   not null 
   ,city               varchar(50)
   ,zip_cd             varchar(30) not null 
   ,geo_cd             varchar(15) 
   ,region_dt          date  not null default current_date
   ,user_status_id     integer  not null 
   ,user_status_dt     date 
   ,emrgncy_avblty_ind varchar(1)
   ,created_by         varchar(30) not null default 'SYSTEM' 
   ,created_dt         date not null default current_date
   ,last_update_by     varchar(30) 
   ,last_update        date    
   
   ,CONSTRAINT uk_user_user_id unique( user_id )
   ,CONSTRAINT ck_emrgcy_avblty_ind Check (emrgncy_avblty_ind IN ('Y','N'))   
   ,CONSTRAINT pk_user primary key ( identity_type_id , email_id ,contact_nbr)
   ,CONSTRAINT fk_usr_idty_id FOREIGN KEY(identity_type_id) 
                               REFERENCES identity_type(identity_type_id)
   ,CONSTRAINT fk_usr_cntry_id FOREIGN KEY(country_id) 
                               REFERENCES country(country_id)
   ,CONSTRAINT fk_usr_state_id FOREIGN KEY(country_id,state_id) 
                               REFERENCES state_lkp(country_id,state_id)
   ,CONSTRAINT fk_usr_status_id FOREIGN KEY(user_status_id) 
                                REFERENCES user_status(user_status_id)
);
--------------------------------dmls----------------------------
--select * from idnty_typ
/**insert into users(idnty_typ_id,frst_nm,lst_nm,eml_id,phn_nbr,cntc_nbr,addr_ln1,addr_ln3,cntry_id,
                  state_id,cty,zip_cd,usr_sts_id,usr_sts_dt,emrgncy_avblty_ind)
            values(1,'MOHANAKRISHNAN','RAJA','mohankrishnan83@gmail.com','9789999720','9789999720','BLOCKB12','PREUNGALATHUR',
                     '2',4,'PRGL','600063',1,CURRENT_DATE,'N');
insert into users(idnty_typ_id,frst_nm,lst_nm,eml_id,phn_nbr,cntc_nbr,addr_ln1,addr_ln3,cntry_id,
                  state_id,cty,zip_cd,usr_sts_id,usr_sts_dt,emrgncy_avblty_ind)
            values(2,'MOHANA','KRISHNAN','mohankrishnan83@gmail.com','9789999729','9789999729','BLOCKB12','PREUNGALATHUR',
                     '2',4,'PRGL','600063',1,CURRENT_DATE,'N'); */