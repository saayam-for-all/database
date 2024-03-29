/*************************************************************
***
***  Name       :  users.sql 
***  purpose    :  This table stores the details of all type 
***                of users like Donors ,Volunteers.
***                
***  Depemdency :  
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


drop table if exists users ;

create table if not exists users   
( 
    user_id       integer generated always as identity
   ,idnty_typ_id   integer 
   ,frst_nm      varchar(30) not null 
   ,mdl_nm       varchar(30) 
   ,lst_nm       varchar(30) not null 
   ,eml_id       varchar(100) not null 
   ,phn_nbr      varchar(30) 
   ,cntc_nbr     varchar(30)    not null
   ,addr_ln1   varchar(50)  not null 
   ,addr_ln2   varchar(50)
   ,addr_ln3   varchar(50)
   ,cntry_id   integer     not null 
   ,state_id   integer   not null 
   ,cty        varchar(50)
   ,zip_cd     varchar(30) not null 
   ,geo_cd     varchar(15) 
   ,regn_dt    date  not null default current_date
   ,usr_sts_id integer  not null 
   ,usr_sts_dt date 
   ,emrgncy_avblty_ind varchar(1)
   ,cre_by    varchar(30) not null default 'SYSTEM' 
   ,cre_dt    date not null default current_date
   ,upd_by    varchar(30) 
   ,upd_dt    date    
   
   ,CONSTRAINT uk_user_user_id unique( user_id ) 
   ,CONSTRAINT pk_user primary key ( idnty_typ_id , eml_id ,cntc_nbr)
   ,CONSTRAINT fk_usr_idty_id FOREIGN KEY(idnty_typ_id) 
                               REFERENCES idnty_typ(idnty_typ_id)
   ,CONSTRAINT fk_usr_cntry_id FOREIGN KEY(cntry_id) 
                               REFERENCES cntry(cntry_id)
   ,CONSTRAINT fk_usr_state_id FOREIGN KEY(state_id) 
                               REFERENCES state_lkp(state_id)
);
--------------------------------dmls----------------------------
--select * from idnty_typ
insert into users(idnty_typ_id,frst_nm,lst_nm,eml_id,phn_nbr,cntc_nbr,addr_ln1,addr_ln3,cntry_id,
                  state_id,cty,zip_cd,usr_sts_id,usr_sts_dt,emrgncy_avblty_ind)
            values(1,'MOHANAKRISHNAN','RAJA','mohankrishnan83@gmail.com','9789999720','9789999720','BLOCKB12','PREUNGALATHUR',
                     '2',4,'PRGL','600063',1,CURRENT_DATE,'N');
insert into users(idnty_typ_id,frst_nm,lst_nm,eml_id,phn_nbr,cntc_nbr,addr_ln1,addr_ln3,cntry_id,
                  state_id,cty,zip_cd,usr_sts_id,usr_sts_dt,emrgncy_avblty_ind)
            values(2,'MOHANA','KRISHNAN','mohankrishnan83@gmail.com','9789999729','9789999729','BLOCKB12','PREUNGALATHUR',
                     '2',4,'PRGL','600063',1,CURRENT_DATE,'N');