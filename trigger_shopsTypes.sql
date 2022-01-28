drop trigger if exists checkShopTypesAmount
go

create trigger checkShopTypesAmount
on Shops
instead of insert, update  
as
begin
	-- [name], openingtime, closingtime, parks_id, types_id, locations_id

	Declare @parkTypesAmmount int
	Declare @name as varchar(45)
	Declare @openingtime time
	Declare @closingtime time
	Declare @parks_id int
	Declare @types_id int
	Declare @locations_id int

	DECLARE cShop CURSOR FOR
		select [name], openingtime, closingtime, parks_id, types_id, locations_id from INSERTED
		OPEN cShop
		FETCH NEXT FROM cShop
			INTO @name, @openingtime, @closingtime, @parks_id, @types_id, @locations_id
			WHILE @@FETCH_STATUS = 0
				BEGIN
				
					-- Get the amount of same shop types inside a park
					set @parkTypesAmmount = (select count(*) from shops where parks_id = @parks_id and types_id = @types_id);

					-- If the amount after the insertion is less or equal than two
					if (@parkTypesAmmount + 1) <= 2
						Begin
							insert into shops ([name], openingtime, closingtime, parks_id, types_id, locations_id) 
							values (@name, @openingtime, @closingtime, @parks_id, @types_id, @locations_id);
						END
					else -- Otherwise, print an indication and continue the insertion
						print 'Error : Sorry, there are already two shops with the same types that exist into the park.'
					
					FETCH NEXT FROM cShop
				INTO @name, @openingtime, @closingtime, @parks_id, @types_id, @locations_id
				END

		CLOSE cShop;
	DEALLOCATE cShop;
end