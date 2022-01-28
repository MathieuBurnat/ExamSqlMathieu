-- Disconnect all users
alter database exam_sql set single_user with rollback immediate

USE master
GO
SET NOCOUNT ON

-- Delete the database if it exists
DROP DATABASE IF EXISTS exam_sql;



--CREATE DATABASE .....
CREATE DATABASE exam_sql;

Use exam_sql
go

CREATE TABLE Dish (
	idDish int IDENTITY(1,1) PRIMARY KEY,
	dishDescription varchar(100) , 
	fkDishType int , 
	fkMenu int, 
	amountWithTaxes decimal(5,2) );

Insert into Dish (dishDescription, amountWithTaxes) values ('test', 3.0)
