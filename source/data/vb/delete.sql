-- turn message off
SET NOCOUNT ON;

-- this script should not be run directly but should be run with sqlcmd.sql in SQLCMD mode
-- input variables are defined in sqlcmd.sql file

-- input variables
DECLARE @Schema				VARCHAR(50)		= '$(Schema)'				-- required
DECLARE @TableName			VARCHAR(50)		= '$(TableName)'			-- required
DECLARE @StoredProcedure	VARCHAR(50)		= @TableName + '_Delete'	-- required
DECLARE @EnterpriseLibrary	VARCHAR(10)		= '$(EnterpriseLibrary)'	-- optional

-- other variables
DECLARE @PrimaryKey			VARCHAR(50)	= ''

-- get primary key
SELECT		TOP 1
			@PrimaryKey = c.name
FROM		sys.columns c
JOIN		sys.tables t ON c.object_id = t.object_id
JOIN		sys.schemas s ON t.schema_id = s.schema_id
JOIN		sys.types x ON c.user_type_id = x.user_type_id
JOIN		INFORMATION_SCHEMA.COLUMNS i ON i.TABLE_SCHEMA = s.name AND i.TABLE_NAME = t.name AND i.COLUMN_NAME = c.name
WHERE		s.name = @Schema
AND			t.name = @TableName
AND			c.is_identity = 1
ORDER BY	i.ORDINAL_POSITION

PRINT '		Public Function Delete(ByVal ' + @PrimaryKey + ' As Integer) As Integer'
PRINT '			''variables'

IF @EnterpriseLibrary = '6'
BEGIN
	PRINT '			Dim DB As Database = New DatabaseProviderFactory().CreateDefault()'
END
ELSE
BEGIN
	PRINT '			Dim DB As Database = DatabaseFactory.CreateDatabase()'
END

PRINT '			Dim ReturnValue As Integer = -1'
PRINT ''
PRINT '			''command'
PRINT '			Using cmd As DbCommand = DB.GetStoredProcCommand("' + @Schema + '.' + @StoredProcedure + '")'
PRINT '				''parameters'
PRINT '				DB.AddInParameter(cmd, "@' + @PrimaryKey + '", DbType.Int32, ' + @PrimaryKey + ')'
PRINT ''
PRINT '				''return value parameter'
PRINT '				DB.AddParameter(cmd, "@ReturnValue", DbType.Int32, 4, ParameterDirection.ReturnValue, False, 0, 0, "@ReturnValue", DataRowVersion.Default, Nothing)'
PRINT ''
PRINT '				''execute query'
PRINT '				DB.ExecuteNonQuery(cmd)'
PRINT ''
PRINT '				''get return value'
PRINT '				ReturnValue = DB.GetParameterValue(cmd, "@ReturnValue")'
PRINT '			End Using'
PRINT ''
PRINT '			''return value'
PRINT '			Return ReturnValue'
PRINT '		End Function'
-- PRINT ''

-- submit batch
GO