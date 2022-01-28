drop function IF EXISTS NbPermanentShows
go

CREATE FUNCTION NbPermanentShows(@parkName varchar) RETURNS int
AS
BEGIN
	Declare @spectaplesPermanents int;

    DECLARE @id AS int
    DECLARE @name AS varchar(30)
    DECLARE @desc AS varchar(30)
    DECLARE @resultCount as int
    set @resultCount = 0;

    PRINT '-------- EMPLOYEE DETAILS --------';

    DECLARE cPony CURSOR FOR
        SELECT id, [name], [description] FROM pony Where [description] = @searchedName

        OPEN cPony

        FETCH NEXT FROM cPony
            INTO @id, @name, @desc

            print 'Employee_ID  Employee_Name   Employee_Description'

            WHILE @@FETCH_STATUS = 0
                BEGIN
                    print '   ' + CAST(@id as varchar(10)) + '           ' + cast(@name as varchar(20)) + '           ' + cast(@desc as varchar(20))

                    set @resultCount += 1;

                    FETCH NEXT FROM cPony
                INTO @id, @name, @desc

                END
        CLOSE cPony;
    DEALLOCATE cPony;

    If @resultCount = 0
        Begin
            print 'Aucun résultat trouvé :<';
        End

return @spectaplesPermanents;
END