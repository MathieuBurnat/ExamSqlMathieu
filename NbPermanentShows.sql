drop function IF EXISTS NbPermanentShows
go

CREATE FUNCTION NbPermanentShows(@parkName varchar(45)) RETURNS int
AS
BEGIN
	Declare @spectaplesPermanents int;
	Declare @hasParkName int;

	-- If the park @hasParkName is zero, the the park name doesn't exist
	set @hasParkName = (select count(*) from dbo.parks as p where p.name = @parkName)

	if @hasParkName = 0
		return -1
	
	set @spectaplesPermanents = (select count(*) from dbo.parks as p
	Inner join shows as s on p.id=s.parks_id 
	where p.name = @parkName and s.permanent = 1);


return @spectaplesPermanents;
END