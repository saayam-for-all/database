# The Saayam 
     <p> Saayam means that help in Telugu one south indian language. The app purpose is to provide help for the needy person.The type of help can including but not limited food,shelter,education,non emergency help.Please note this application NOT purposed to override the existing emergeny application the are provided by governments. Any emergency help to called out to local regulatrory bodies like 911. </p>
# Database 
 <p> RDBMS Dataabse preferred a as backend database over the NoSQL Database engine.
 RDBMS stores data into a logical way and accessed thrpugh SQL programming. 
 Decision to use Fully managed RDS Engine Amazon Aurora with Postgres compatiblity.
 This database aims to hold the request details from the help and voulunteers/donors who are fulfiling the equests. Voluteers acts as bridge between requestor and helpers </p>
 
 # List of tables 
 ## user or volunteer tables
    | Table Name | Table Desc   | 
    | ---------- | ------------ |
    | user       | holds data related tp users,volunteers or donors |
    |
 2. user
 3. usr_idnty 
 4. usr_skills
 5. usr_skills
 ## Request tables 
 1. req_type
 2. reqst
 # Look up tables
 1. request_sts_type
 2. usr_sts
 3. idnty_typ
 4. lkp_skills
 5. cntry 
  
 

  
 
 
