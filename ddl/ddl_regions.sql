-----
---- List the Name and occupation with first name 
----- count all occupations 
---------------

CREATE Table occupations 
( name varchar(50) , 
  occupation varchar(30) 
)
/

insert into occupations values ( 'samantha' , 'Doctor' ) ;
insert into occupations values ( 'Julia' , 'Actor' ) ;
insert into occupations values ( 'Maria' , 'Actor' ) ;
insert into occupations values ( 'Meera' , 'Singer' ) ;
insert into occupations values ( 'Ashlye' , 'Professor' ) ;
insert into occupations values ( 'Ketty' , 'Professor' ) ;
insert into occupations values ( 'Jane' , 'Actor' ) ;
insert into occupations values ( 'Jenny' , 'Doctor' ) ;
insert into occupations values ( 'Priya' , 'Singer' ) ;
insert into occupations values ( 'Mohan' , 'Writer ) ;

select name  || concat('(', substr(occupation,1,1) ,')') from occupations 
union all 
select 'There are a total of ' || count(*) || occupation ||'.'
from occupations
group by occupation 
order by name 
