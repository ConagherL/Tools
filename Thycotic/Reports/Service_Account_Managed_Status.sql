SELECT
    cd.AccountDomain AS 'Domain',
    cd.AccountName AS 'Account',
    c.ComputerName AS 'Host Name',
    cd.DependencyName AS 'Dependency Name',
    sdt.SecretDependencyTypeName AS 'Dependency Type',
    SDTM.SecretDependencyTemplateName AS 'Dependency Template Name',
    CONVERT(VARCHAR(20),c.LastPolledDate,107) AS 'Last Scanned',
CASE
            WHEN SecretID is NULL THEN 'No'
            WHEN SecretID Is NOT NULL THEN 'Yes'
            END    AS [Managed Status],
CASE
            WHEN SecretID is NULL THEN 'lightpink'
            WHEN SecretID is NOT NULL THEN 'lightgreen'
        END    AS [Color]
FROM
        tbComputer c
    JOIN     tbComputerDependency cd

    ON
        cd.ComputerID = c.ComputerId

    JOIN     tbSecretDependencyType sdt

    ON
        sdt.SecretDependencyTypeId = cd.SecretDependencyTypeID
        
    JOIN tbSecretDependencyTemplate sdtm
    
    ON    
        cd.ScanItemTemplateId = sdtm.ScanItemTemplateId
    AND
        cd.SecretDependencyTypeID = sdtm.SecretDependencyTypeId
        
    ORDER BY cd.AccountName asc
