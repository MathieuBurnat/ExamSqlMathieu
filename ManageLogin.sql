drop trigger ManageLogin
go
-- F. Andolfatto january 2018
--trigger that checks if the room for the training goes with the machines inside the room
create trigger ManageLogin 
on employees
after insert
as
begin
	DECLARE @id AS int
	
	DECLARE @lastname AS varchar(45)
	DECLARE @firstname AS varchar(45)
	Declare @specialities_id as int
	Declare @login as varchar(90)

	DECLARE cEmployee CURSOR FOR
		SELECT [lastname], firstname, speci	alities_id FROM INSERTED
		OPEN cEmployee
		FETCH NEXT FROM cEmployee
			INTO @lastname, @firstname, @specialities_id

			WHILE @@FETCH_STATUS = 0
				BEGIN
					-- Easy patch 'cause I haven't a lot of time :v *quak*
					-- If the speciatilies id equals to 12 (aka direction), create a login
					if specialities_id=12
						begin
							set @login = @lastname+@firstname
							CREATE LOGIN CONVERT(VARCHAR(10), @login) WITH PASSWORD = 'ch@Nge2-mech@Nge2-me' MUST_CHANGE, DEFAULT_DATABASE = Exam, CHECK_POLICY = ON, CHECK_EXPIRATION = ON ;
						end
					FETCH NEXT FROM cEmployee
				INTO @lastname, @firstname, @specialities_id
				END
				-- To Do (if i had more time)
				  -- Reup this method with dynamic rules
				  -- Add the innner join to check directly with the 'direction' s name
		CLOSE cEmployee;
	DEALLOCATE cEmployee;
end