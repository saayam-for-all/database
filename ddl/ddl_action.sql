/*************************************************************
***
***  Name       :  action.sql 
***  purpose    :  categorize the list of action served by the user
***                volunteer or donars
***  Depemdency :  
***  
***
*** Data Model: https://drawsql.app/teams/sayam-team/diagrams/saayam-arch
***
*** Created on   : 06/29/2023 
*** Created By   : 
*** Last Updatee :
*** Last update by : 
*** change comments: 
***
***
******************************************************************/

drop table if exists action ;

create table if not exists action
( 
    actn_id    integer generated by default AS identity
   ,actn_dsc   varchar(30)	 not null 
   ,cre_dt      date default current_date 
   ,cre_by      varchar(30) default 'SYSTEM' 
   ,upd_by      varchar(30)
   ,upd_dt      date
   ,CONSTRAINT  uk_action_actn_id  unique(actn_id) 
 );