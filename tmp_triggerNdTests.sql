Declare @parkTypesAmmount int
Declare @parks_id int
Declare @types_id int

set @parks_id = 1
set @types_id = 2

-- Get the amount of same shop types inside a park
set @parkTypesAmmount = (select count(*) from shops where parks_id = @parks_id and types_id = @types_id);

-- If the amount after the insertion is less or equal than two
-- -> Make that insertion
-- Otherwise, continue to the next insertion

if (@parkTypesAmmount + 1) <= 2
	print 'Fine bro'
else 
	print 'aww man thas short'


select [name], parks_id, types_id from shops