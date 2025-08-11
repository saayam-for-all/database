drop table if exists organization_map

create table if not exists organization_map (
    parent_org_id VARCHAR(50),
    child_org_id VARCHAR(50) PRIMARY KEY, --one parent multiple child
    FOREIGN KEY (parent_org_id) REFERENCES organizations(org_id),
    FOREIGN KEY (child_org_id) REFERENCES organizations(org_id)
);

/* insertion is done by organization_map.csv file 
sample csv file:
parent_org_id      child_org_id
                   ORG-1
ORG-1.1            ORG-1
ORG-1.2            ORG-1
ORG-1.3            ORG-1
                   ORG-2
ORG-2.1            ORG-2
ORG-2.2            ORG-2
ORG-2.2.1          ORG-2.2

the .csv file has to be determined like this and manually populated into the db
where, the parent would be the head branch, and the child would be the other branches
for example, ORG-2 is of Red Cross, Washington, D.C
ORG-2.1 is Red Cross, Newark
ORG-2.2 is Red Cross, OH one of the chapter
ORG-2.2.1 is Red Cross, Columbus, OH would be local chapter

the collection should be done by data engineering team
*/