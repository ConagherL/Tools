SELECT 
		a.DateRecorded AS [Date Recorded],
		upn.displayname AS [User],
		ISNULL(f.FolderPath, N'No folder assigned') as [Folder Path],
		s.secretname AS [Secret Name],
		a.Action,
		a.Notes,
		a.ipaddress As [IP Address]
	FROM tbAuditSecret a WITH (NOLOCK)
	INNER JOIN tbUser u WITH (NOLOCK)
		ON u.UserId = a.UserId AND u.OrganizationId = #Organization
	INNER JOIN vUserDisplayName upn WITH (NOLOCK)
		ON u.UserId = upn.UserId
	INNER JOIN tbsecret s WITH (NOLOCK)
		ON s.SecretId = a.SecretId 
	LEFT JOIN tbFolder f WITH (NOLOCK)
		ON s.FolderId = f.FolderId
	LEFT JOIN tbUserGroup ug WITH (NOLOCK)
		ON u.UserId = ug.UserID
	LEFT JOIN tbGroup g WITH (NOLOCK)
		ON g.GroupID = ug.GroupID
	WHERE 
		a.DateRecorded >= #StartDate
		AND 
		a.DateRecorded <= #EndDate
		AND
		g.GroupID = #Group
	ORDER BY 
		1 DESC, 2,3,4,5,6,7
