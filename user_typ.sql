/********************************************************************
**
**  Application : Saayam 
**  
**  Table Name  : user_typ 
**
**  Purpose  : A Table to store types of users.  
**
**  created dt : 04/04/2023
**
**  Last Modified : 
**
**  Change Comments : 
**
**
**
**********************************************************************/

drop table if exists user_typ;

create table user_typ (
usr_typ_id integer generated always as identity primary key,
usr_typ varchar(30) not null,
usr_typ_desc varchar(50) not null
);