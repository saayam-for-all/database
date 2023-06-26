
# The Saayam
<p>
Saayam means that help in Telugu one south indian language. The app purpose is to provide help for the needy person.The type of help can including but not limited food,shelter,education,non emergency help.Please note this application NOT purposed to override the existing emergeny application the are provided by governments. Any emergency help to called out to local regulatrory bodies like 911. </p>

# Database 
 <p> RDBMS Dataabse preferred a as backend database over the NoSQL Database engine.
 RDBMS stores data into a logical way and accessed thrpugh SQL programming. 
 Decision to use Fully managed RDS Engine Amazon Aurora with Postgres compatiblity.
 This database aims to hold the request details from the help and voulunteers/donors who are fulfiling the equests. Voluteers acts as bridge between requestor and helpers </p>
 
 # List of tables 
 ## user or volunteer tables
   | Table Name | Description | 
   | ---------- | ----------- |
   | user | Contains basic information related to users like contact# , addresss.. | 
   | usr_idnty | contains information related tp users personal information , The attribute which contains PII to be *encrypted* |
   | usr_typ | Contains user type information look up table for user. |
   | usr_skils | contains sill information related to user or volunteer. The skills may tech or non-technical skills |
   | usr_status | contains the status of the user/volunterr like *active* , *inactive* , *suspended* , *verification in progress* or *deleted*. |

 ## Request tables
 | Table Name | Description | 
   | ---------- | ----------- |
   | req_type |    List of request type like Food , Shelter , Eductaion. |
   | request  | Here is a place the user/ volunteers raise saayam request for them self or for the another person | 
      
 # Look up tables
  | Table Name | Description |
  | ---------- | ----------- |
  | priority | contains priority typs


  
  

 

  
 
 
