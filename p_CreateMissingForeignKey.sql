create procedure p_CreateMissingForeignKey
(
	@TableName sysname,
	@ColumnName sysname,
	@DataType nvarchar(256),
	@CharacterMaxLength int = null,
	@NumericPrecision int = null,
	@TargetColumnName sysname
)
as
begin
	
	select 
		'ALTER TABLE ['+TABLE_NAME+'] ADD CONSTRAINT [FK_'+TABLE_NAME+'_'+COLUMN_NAME+'_'+@TableName+'_'+@TargetColumnName+'] FOREIGN KEY (['+COLUMN_NAME+']) REFERENCES (['+@TableName+'](['+@TargetColumnName+']))' +
		+char(13)+char(10)+'GO'
	from information_schema.columns
	where
		Table_name <> @TableName
		and COLUMN_NAME = @ColumnName
		and DATA_TYPE = @DataType
		and (@CharacterMaxLength is null or CHARACTER_MAXIMUM_LENGTH = @CharacterMaxLength)
		and (@NumericPrecision is null or NUMERIC_PRECISION = @NumericPrecision)
		and not exists(select 1 from sys.foreign_keys fk
							inner join sys.tables fk_table on fk_table.object_id = fk.parent_object_id
							inner join sys.foreign_key_columns fk_column on fk_column.parent_object_id = fk.parent_object_id
							inner join sys.columns col on col.object_id = fk_column.parent_object_id
						where fk_table.name = TABLE_NAME and col.name = COLUMN_NAME)
end
go