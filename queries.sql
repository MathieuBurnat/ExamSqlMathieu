Declare @parkName varchar(30);
set @parkName = 'Le Puy du Fou'

select * from dbo.parks as p
Inner join shows as s on p.id=s.parks_id where p.name = @parkName and s.permanent = 1

