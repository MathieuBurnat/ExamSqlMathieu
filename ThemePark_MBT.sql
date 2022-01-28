-- exam_sql.sql:	This script creates a database for the management of theme park
--				The database is initialized with fake data and data coming from the web site of DineyLand, Le Puy du Fou and Europa Park
--				
-- Version:		1.0, january 2022
-- Author:		F. Andolfatto
--
-- History:
--			1.0 Database creation
--
--

USE master
GO

SET NOCOUNT OFF

-------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
-- Suppression de la base de donn�es
-------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
IF (EXISTS (SELECT name FROM master.dbo.sysdatabases WHERE name = 'exam_sql'))
BEGIN
	/**Deconnexion de tous les utilsateurs sauf l'administrateur**/
	/**Annulation immediate de toutes les transactions**/
	ALTER DATABASE exam_sql SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

	/**Suppression de la base de donn�es**/
	DROP DATABASE exam_sql;
END
GO

-------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
-- CreationDatabase
-------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
--create automatically the directories for the SQL Server data and log files

-- ensure we have the proper directory structure
CREATE TABLE #ResultSet (Directory varchar(200)) -- Temporary table (name starts with #) -> will be automatically destroyed at the end of the session

INSERT INTO #ResultSet EXEC master.sys.xp_subdirs 'c:\' -- Stored procedure that lists subdirectories

IF NOT EXISTS (Select * FROM #ResultSet where Directory = 'DATA')
	EXEC master.sys.xp_create_subdir 'C:\DATA\' -- create DATA

DELETE FROM #ResultSet -- start over for MSSQL subdir
INSERT INTO #ResultSet EXEC master.sys.xp_subdirs 'c:\DATA'

IF NOT EXISTS (Select * FROM #ResultSet where Directory = 'MSSQL')
	EXEC master.sys.xp_create_subdir 'C:\DATA\MSSQL'

DROP TABLE #ResultSet -- Explicitely delete it because the script may be executed multiple times during the same session
GO



CREATE DATABASE exam_sql
 ON  PRIMARY 
( NAME = N'exam_sql', FILENAME = N'C:\Data\MSSQL\exam_sql.mdf' , SIZE = 5120KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'exam_sql_LOG', FILENAME = N'C:\Data\MSSQL\exam_sql_log.ldf' , SIZE = 1024KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO

-------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
-- Cr�ation des tables
-------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------

USE exam_sql
GO

-- -----------------------------------------------------
-- Table theme_park.parks
-- -----------------------------------------------------
CREATE TABLE parks (
  id INT NOT NULL PRIMARY KEY IDENTITY(1,1),
  name VARCHAR(45) NOT NULL,
  description VARCHAR(2000) NOT NULL,
  openingdate DATE NOT NULL,
  closingdate DATE NOT NULL,
  openingtime TIME NOT NULL,
  closingtime TIME NOT NULL
  )


-- -----------------------------------------------------
-- Table theme_park.locations
-- -----------------------------------------------------
CREATE TABLE locations (
  id INT NOT NULL PRIMARY KEY IDENTITY(1,1),
  name VARCHAR(45) NOT NULL
  )


-- -----------------------------------------------------
-- Table theme_park.shows
-- -----------------------------------------------------
CREATE TABLE shows (
  id INT NOT NULL PRIMARY KEY IDENTITY(1,1),
  name VARCHAR(45) NOT NULL,
  description VARCHAR(2000) NOT NULL,
  duration INT NOT NULL,
  nblimitspectators INT NULL,
  permanent TINYINT NOT NULL,
  parks_id INT NOT NULL,
  location_id INT NULL)

-- -----------------------------------------------------
-- Table theme_park.specialities
-- -----------------------------------------------------
CREATE TABLE specialities (
  id INT NOT NULL PRIMARY KEY IDENTITY(1,1),
  name VARCHAR(45) NOT NULL)

-- -----------------------------------------------------
-- Table theme_park.employees
-- -----------------------------------------------------
CREATE TABLE employees (
  id INT NOT NULL PRIMARY KEY IDENTITY(1,1),
  lastname VARCHAR(45) NOT NULL,
  firstname VARCHAR(45) NOT NULL,
  birthdate DATE NOT NULL,
  salary DECIMAL(7,2) NOT NULL,
  specialities_id INT NOT NULL)

-- -----------------------------------------------------
-- Table theme_park.restaurants
-- -----------------------------------------------------
CREATE TABLE restaurants (
  id INT NOT NULL PRIMARY KEY IDENTITY(1,1),
  name VARCHAR(45) NOT NULL,
  type VARCHAR(45) NOT NULL,
  openingtime TIME NOT NULL,
  closingtime TIME NOT NULL,
  openingdate DATE NOT NULL,
  closingdate DATE NOT NULL,
  locations_id INT NOT NULL,
  parks_id INT NOT NULL)

-- -----------------------------------------------------
-- Table theme_park.types
-- -----------------------------------------------------
CREATE TABLE types (
  id INT NOT NULL PRIMARY KEY IDENTITY(1,1),
  name VARCHAR(45) NOT NULL
  )

-- -----------------------------------------------------
-- Table theme_park.shops
-- -----------------------------------------------------
CREATE TABLE shops (
  id INT NOT NULL PRIMARY KEY IDENTITY(1,1),
  name VARCHAR(45) NOT NULL,
  openingtime TIME NOT NULL,
  closingtime TIME NOT NULL,
  parks_id INT NOT NULL,
  types_id INT NOT NULL,
  locations_id INT NOT NULL)

-- -----------------------------------------------------
-- Table theme_park.roles
-- -----------------------------------------------------
CREATE TABLE roles (
  id INT NOT NULL PRIMARY KEY IDENTITY(1,1),
  name VARCHAR(45) NOT NULL,
  specialities_id INT NOT NULL
  )

-- -----------------------------------------------------
-- Table theme_park.shows_has_employees
-- -----------------------------------------------------
CREATE TABLE shows_has_employees (
  id INT NOT NULL PRIMARY KEY IDENTITY(1,1),
  shows_id INT NOT NULL,
  employees_id INT NOT NULL,
  roles_id INT NOT NULL)


ALTER TABLE shows_has_employees WITH CHECK ADD CONSTRAINT fk_shows_has_employees_shows FOREIGN KEY(shows_id)
REFERENCES shows (id);

ALTER TABLE shows_has_employees WITH CHECK ADD CONSTRAINT fk_shows_has_employees_employees FOREIGN KEY(employees_id)
REFERENCES employees (id);

ALTER TABLE shows_has_employees WITH CHECK ADD CONSTRAINT fk_shows_has_employees_roles FOREIGN KEY(roles_id)
REFERENCES roles (id)

ALTER TABLE shows WITH CHECK ADD CONSTRAINT fk_shows_parks FOREIGN KEY(parks_id)
REFERENCES parks(id);

ALTER TABLE shows WITH CHECK ADD CONSTRAINT fk_shows_locations FOREIGN KEY(location_id)
REFERENCES locations(id);

ALTER TABLE employees WITH CHECK ADD CONSTRAINT fk_employees_specialities FOREIGN KEY(specialities_id)
REFERENCES specialities (id);

ALTER TABLE restaurants WITH CHECK ADD CONSTRAINT fk_restaurants_locations FOREIGN KEY(locations_id)
REFERENCES locations (id);

ALTER TABLE restaurants WITH CHECK ADD CONSTRAINT fk_restaurants_parks FOREIGN KEY(parks_id)
REFERENCES parks (id);

ALTER TABLE shops WITH CHECK ADD CONSTRAINT fk_shops_parks FOREIGN KEY(parks_id)
REFERENCES parks (id);

ALTER TABLE shops WITH CHECK ADD CONSTRAINT fk_shops_types FOREIGN KEY(types_id)
REFERENCES [types](id);

ALTER TABLE shops WITH CHECK ADD CONSTRAINT fk_shops_locations FOREIGN KEY(locations_id)
REFERENCES locations (id);

ALTER TABLE roles WITH CHECK ADD CONSTRAINT fk_roles_specialities FOREIGN KEY(specialities_id)
REFERENCES specialities (id);


-- for later
CREATE TABLE employeeGroup (
	idEmployeGroup int  IDENTITY(1,1) PRIMARY KEY,
	name varchar(35) NOT NULL);



insert into parks (name, description, openingtime, closingtime, openingdate, closingdate) values ('Le Puy du Fou', 'Complexe de loisirs fran�ais � th�matique historique situ� en Vend�e', '09:00', '22:00', '2021-06-01', '2021-09-30');
insert into parks (name, description, openingtime, closingtime, openingdate, closingdate) values ('Europa-park', 'Grand parc de loisirs en Allemagne', '09:00', '20:00', '2021-05-01', '2021-10-30');

insert  into locations (name) VALUES ('Lac'), ('Village XVIII�me si�cle'), ('Le bourg 1900'), ('Village m�di�val'), ('Europa-Park Arena'), ('Europa-Park Dome'), ('Portugal'), ('Italie'), ('Angleterre'), ('Espagne'), ('Univers de l''aventure'), ('Gr�ce'), ('For�t Enchant�e Grimm'), ('Autriche'), ('Scandinavie');

insert into shows (name, description, duration, nblimitspectators, permanent, parks_id, location_id) values 
	('Le monde imaginaire de La Fontaine', 
	'Enrichi de nouvelles fables en 2021, le � Monde Imaginaire de La Fontaine � est un incroyable jardin arbor�, plein de surprises et de po�sie. Entre les plantes sauvages et les fleurs �l�gantes, les ruisseaux et les arbres tortueux, plus de 40 animaux se sont donn�s rendez-vous pour donner vie � une douzaine de fables �ternelles ou oubli�es, servies par les effets sp�ciaux spectaculaires du Puy du Fou. Laissez-vous emporter par ce monde anim�, plein de surprises !', 
	60, null, 1, 1, null);

insert into shows (name, description, duration, nblimitspectators, permanent, parks_id, location_id) values 
	('Les noces de feu', 
	'Chaque soir, quand le soleil dispara�t, de douces m�lodies r�sonnent sur le lac et r�veillent peu � peu le souvenir du plus romantique des mariages. Apr�s s��tre rencontr�s dans le spectacle � Les Orgues de Feu �, la Muse violoniste et le Pianiste virtuose se retrouvent pour c�l�brer leur amour �ternel dans une f��rie d�eau et de feu. Assistez � ces noces fantastiques o� danseurs et d�cors g�ants surgissent des profondeurs du lac, tels des mirages, et reprennent vie pour offrir aux jeunes mari�s le r�ve d�une f�te inoubliable.', 
	30, 1000, 0, 1, 1);;
	
insert into shows (name, description, duration, nblimitspectators, permanent, parks_id, location_id) values 
	('Le premier royaume', 
	'Au V�me si�cle, en pleine chute de l�Empire Romain tout juste ravag� par les hordes d�Attila, accompagnez Clovis, le c�l�bre roi franc ! Au fil de ses conqu�tes, d�couvrez les doutes de ce grand strat�ge partag� entre les traditions ancestrales de son peuple et la voie nouvelle qu�il pourrait choisir pour fonder le Premier Royaume ! Vous vivrez son �pop�e depuis l�int�rieur, entre les sc�nes de guerre, les incroyables rencontres avec des figures de la mythologie nordique et le voyage extraordinaire dans les entrailles de la terre, au c�ur du bouillonnant Valhalla.', 
	18, null, 1, 1, null);

insert into shows (name, description, duration, nblimitspectators, permanent, parks_id, location_id) values 
	('Le bal des oiseaux fant�mes', 
	'Au temps des ch�teaux forts, les souvenirs de la princesse Ali�nor et de son amie d�enfance Elo�se reprennent vie et plus de 330 somptueux oiseaux reviennent habiter les vieilles ruines abandonn�es depuis des si�cles ! Les aigles, les faucons, les vautours, les milans, les chouettes et des dizaines d�autres rapaces dansent dans le ciel et plongent sur les bras des ma�tres fauconniers qui orchestrent un ballet envo�tant. Tous ces oiseaux volent � quelques centim�tres du public et les plumes de leurs ailes viendront certainement caresser le sommet de votre t�te ! Pr�parez-vous � vivre un moment de gr�ce inoubliable !', 
	33, 800, 0, 1, null);
	
insert into shows (name, description, duration, nblimitspectators, permanent, parks_id, location_id) values 
	('Le signe du triomphe', 
	'Au III�me si�cle apr�s J-C, le peuple Gaulois se rebelle contre l�occupant Romain. Pour sauver leur vie, des prisonniers gaulois sont condamn�s � remporter les Jeux du Cirque sous les yeux du gouverneur romain et de son peuple. Dans ce spectacle, ils participeront � plusieurs �preuves, devront affronter les terribles gladiateurs et remporter la mythique course de char ! Installez-vous dans les tribunes du Stadium Gallo-Romain et laissez-vous emporter par une ambiance survolt�e ! Suivez avec intensit� les aventures de Damien et Soline, les 2 h�ros dont le destin bascule dans cette ar�ne.', 
	37, 2500, 0, 1, null);
	
insert into shows (name, description, duration, nblimitspectators, permanent, parks_id, location_id) values 
	('Le grand carillon', 
	'Au centre du Village XVIII�me se dresse un immense carillon de 16 m�tres de hauteur. Plusieurs fois par jour, � chaque repr�sentation, cette architecture originale et spectaculaire d�ploie ses 70 cloches. Durant une dizaine de minutes, vous assisterez � un spectacle musical des plus surprenants ! En plus de la musique grandiose des cloches, 2  com�diens voltigeurs �voluent dans les airs autour de l�imposante structure, au rythme des c�l�bres m�lodies populaires du XVIII�me si�cle r�orchestr�es par le Puy du Fou. Profitez d�un moment original de musique en famille !', 
	10, 200, 0, 1, 2);	
	
insert into shows (name, description, duration, nblimitspectators, permanent, parks_id, location_id) values 
	('Les amoureux de Verdun', 
	'Aventurez-vous dans la for�t centenaire du Puy du Fou et traversez les si�cles pour arriver au c�ur de la Premi�re Guerre mondiale. Au fil de la correspondance amoureuse d�un soldat et de sa fianc�e, vous plongez au c�ur de l�hiver 1916, dans une v�ritable tranch�e, � la rencontre de soldats h�ro�ques. A la veille de No�l, les fum�es envahissent les galeries, le sol tremble � chaque nouvelle explosion, les alarmes retentissent� Tout semble perdu, mais en ce 24 d�cembre, les soldats ne savent pas encore qu�ils vont vivre un No�l qu�ils n�oublieront jamais !', 
	15, NULL, 1, 1, NULL);		

insert into shows (name, description, duration, nblimitspectators, permanent, parks_id, location_id) values 
	('Le secret de la lance', 
	'Vivez une aventure m�di�vale � grand spectacle ! En pleine Guerre de Cent Ans, Jeanne la Lorraine vient � la rencontre du chevalier Fulgent pour r�unir ses meilleurs guerriers avant d�aller combattre les Anglais. Apr�s le d�part des chevaliers pour Orl�ans, Marguerite, une jeune berg�re, se retrouve seule au ch�teau. Elle va devoir d�couvrir le secret d�une lance aux pouvoirs fantastiques pour prot�ger les remparts enchant�s du ch�teau en pleine bataille. Suivez le destin de cette h�ro�ne courageuse et intr�pide !',
	29, 600, 0, 1, NULL);

insert into shows (name, description, duration, nblimitspectators, permanent, parks_id, location_id) values 
	('Le dernier panache', 
	'Fran�ois-Athanase Charette de la Contrie, dit � Charette �, h�ros de la Guerre d�Ind�pendance Am�ricaine, voit sa vie basculer en 1793 dans un ultime combat pour la libert� ! Emport�s dans une �pop�e entre d�cors r�els et virtuels � 360�, vous d�couvrirez le destin hors du commun d�un h�ros fran�ais. En 2021, vous suivrez les grands moments qui ont forg� le destin de Charette au cours d�un grand spectacle �pique et �mouvant servi par une mise en sc�ne unique au monde !',
	34, 1500, 0, 1, NULL);	

insert into shows (name, description, duration, nblimitspectators, permanent, parks_id, location_id) values 
	('La renaissance du ch�teau', 
	'Oubli� depuis des si�cles, le ch�teau du Puy du Fou vous ouvre ses portes ! Les tableaux vous parlent, les miroirs vous observent, les fant�mes dansent encore, les gisants se r�veillent� Chaque salle du ch�teau vous d�voile ses merveilles encore hant�es par son pass� glorieux. Partez � la d�couverte des splendeurs vivantes de la Renaissance ! Dans ce spectacle immersif, vous rencontrerez les membres illustres de la famille au fur et � mesure de votre visite dans les entrailles du ch�teau !',
	30, NULL, 1, 1, NULL);		
	
insert into shows (name, description, duration, nblimitspectators, permanent, parks_id, location_id) values 
	('La vall�e fleurie', 
	'En plein c�ur de la for�t centenaire du Puy du Fou, la � Vall�e Fleurie � est un v�ritable havre de paix parmi les ch�nes, les foug�res, les plantes aquatiques et les cascades. Arr�tez-vous un instant et profitez de la tranquillit� de ce lieu verdoyant pour prendre un v�ritable bol d�air. Plusieurs fois par jour, la vall�e est plong�e dans une brume qui laisse apparaitre petit � petit toute la splendeur de ce jardin baign� par le soleil. Vous y d�couvrirez de nombreuses vari�t�s de plantes, sauvages ou domestiques, exotiques ou plus locales.',
	15, NULL, 1, 1, NULL);			

insert into shows (name, description, duration, nblimitspectators, permanent, parks_id, location_id) values 
	('La cit� m�di�vale', 
	'Entre deux spectacles, traversez une fois de plus les portes de l�Histoire en p�n�trant dans l�enceinte fortifi�e de la Cit� M�di�vale qui s�duit par son r�alisme dans les moindres d�tails. Vous y d�couvrirez toutes les richesses du Moyen-�ge et le savoir-faire ancestral pr�serv� de nos artisans d�art. La Cit� M�di�vale est compos�e d�un ensemble de constructions inspir�es du XI�me au XV�me si�cle. Ses murs de torchis authentiques, ses remparts et sa herse, sa chapelle romane et ses �choppes d��poque vous plongeront au temps des chevaliers !',
	60, NULL, 1, 1, 4);		

insert into shows (name, description, duration, nblimitspectators, permanent, parks_id, location_id) values 
	('Classic Rock Night', 
	'Suzi Quattro, The Sweet et Chris Andrews qui partagent la m�me sc�ne lors d�une soir�e. Tous accompagn�s par leurs propres musiciens. Autant dire que l�Europa-Park Arena s�appr�te � vibrer comme jamais. Des figures du rock allemand accompagn�es du DJ Uwe Carsten de Schwarzwaldradio pour un marathon de sept heures � grand renfort de tubes intemporels.',
	300, 1500, 0, 2, 5);	

insert into shows (name, description, duration, nblimitspectators, permanent, parks_id, location_id) values 
	('Science Days', 
	'Avec plus de 60 institutions issues des mondes de la science, de l��ducation, de l��conomie et d�autres domaines, nous avons compil� une offre int�ressante et vari�e. Nous proposerons �galement un petit programme num�rique. Soyez des n�tres et laissez-vous surprendre. Avec votre visite, vous rendez non seulement possible une activit� �ducative extrascolaire attractive, mais vous contribuerez aussi largement au succ�s des Science Days 2021.',
	480, 200, 0, 2, NULL);	

insert into shows (name, description, duration, nblimitspectators, permanent, parks_id, location_id) values 
	('D�ner-Spectacle - �dition sp�ciale', 
	'L�emplacement change, les festivit�s auront lieu � l�Europa-Park Arena, mais tout le reste se pr�sente dans la qualit� exceptionnelle habituelle : un programme plein de surprises et de num�ros spectaculaires accompagn� d�un succulent menu � quatre plats concoct� en exclusivit� pour le d�ner-spectacle par notre chef 2 �toiles Michelin Peter Hagen-Wiest qui officie aux fourneaux d�� Ammolite � The Lighthouse Restaurant � ! Et pour conclure, le point d�orgue de la soir�e : la remise des Ed-Awards, le prix tant convoit� qui r�compense les meilleurs artistes de chaque cat�gorie !',
	120, 1200, 0, 2, 5);	

insert into shows (name, description, duration, nblimitspectators, permanent, parks_id, location_id) values 
	('Retorno dos Piratas', 
	'Plongeons, saltos et vrilles ex�cut�s � la perfection depuis une hauteur vertigineuse : des pirates t�m�raires partent � l�abordage des plongeoirs et se livrent une bataille des plus p�rilleuses, riche en rebondissements et en adr�naline. Retenez votre souffle et d�couvrez le nouveau spectacle de plongeon de haut-vol d�Europa-Park !',
	15, 1200, 0, 2, 7);		
	
insert into shows (name, description, duration, nblimitspectators, permanent, parks_id, location_id) values 
	('Le Monde Merveilleux d�Oguz avec Ed & Edda', 
	'Plongez avec Ed & Edda dans le monde merveilleux de la magie et laissez-vous envo�ter par les tours �poustouflants d�Oguz Engin. Ed et Edda ont h�te de vous accueillir !',
	25, 800, 0, 2, 9);	

insert into shows (name, description, duration, nblimitspectators, permanent, parks_id, location_id) values 
	('Le carnaval de Venise', 
	'Imagine-toi la chose suivante : � 70 oiseaux �lectroniques c�l�brent tous ensemble le carnaval de Venise. � Tu vois, il y certaines choses qu�il faut vraiment voir de ses propres yeux pour pouvoir les croire. ',
	15, 1000, 0, 2, 8);		
	
insert into shows (name, description, duration, nblimitspectators, permanent, parks_id, location_id) values 
	('El Baron', 
	'Cette fois, il exag�re un peu, le t�m�raire Baron de M�nchhausen : un Sultan le met au d�fi d�aller d�rober la pr�cieuse amulette de la Reine� une �preuve qui pourrait bien lui co�ter la t�te. Un spectacle d�aventures d�coiffant, avec des cascades �poustouflantes, de superbes chevaux et de fantastiques effets sp�ciaux. Grandiose et � couper le souffle : de l�action � l��tat pur !',
	30, 1000, 0, 2, 9);	

insert into shows (name, description, duration, nblimitspectators, permanent, parks_id, location_id) values 
	('Ch�teau hant�', 
	'Frissons garantis ! Vous y trouverez des monstres, des esprits, des fant�mes, des bruits effrayants qui vous donneront la chair de poule... Bouuuuuuh.... Pour ceux qui aiment avoir peur et pas seulement � Halloween. Frissons garantis ! ',
	4, 2, 1, 2, 8);		
	
insert into shows (name, description, duration, nblimitspectators, permanent, parks_id, location_id) values 
	('African Queen', 
	'Faites une croisi�re � bord de nos bateaux � vapeur sur le grand lac d''Europa-Park et d�couvrez un village africain et de nombreux animaux. Les enfants adoreront les pistolets � eau � bord du bateau.',
	5.2, 40, 1, 2, 10);
	
insert into shows (name, description, duration, nblimitspectators, permanent, parks_id, location_id) values 
	('A la d�couverte d''Atlantis', 
	'Des amusements interactifs. Une aventure interactive � la d�couverte d�Atlantis ! A bord de sous-marins, parcourez les fonds de l�oc�an � la recherche de la cit� engloutie. Les aventuriers les plus courageux utiliseront leurs lasers pour r�colter des points.',
	6, 2, 1, 2, 11);;
	
insert into shows (name, description, duration, nblimitspectators, permanent, parks_id, location_id) values 
	('Atlantica SuperSplash', 
	'Un plongeon abrupte dans les eaux fra�ches. Tels les grands navigateurs et explorateurs, les visiteurs montent � bord des navires pour une escapade �claboussante avec � Atlantica SuperSplash �. � proximit� imm�diate du gigantesque voilier � Santa Marian �, les bateaux l�chent les amarres au sein d�une citadelle faiblement �clair�e pour partir � l�aventure par del� les profondeurs de l�Atlantique. � 30 m de hauteur, les bateaux tournent sur une plateforme avant de faire une descente de neuf m�tres en marche arri�re. Apr�s une deuxi�me rotation et une vue grandiose sur la For�t-Noire et les Vosges, les bateaux plongent � 80 km/h dans un oc�an de fra�cheur en passant sous le mat d�une �pave �chou�e. Eclaboussures garanties ! Lors des chaudes journ�es d��t�, nous vous recommandons la Douche Atlantica. Vous serez rafra�chis comme jamais auparavant � c�est une certitude. Si vous n''avez pas le pied marin et que vous pr�f�rez rester sur la terre ferme, nous vous conseillons la terrasse du port ou � l�espace du charpentier de marine � pour rester au sec. ',
	3.5, 16, 1, 2, 7);
	
insert into shows (name, description, duration, nblimitspectators, permanent, parks_id, location_id) values 
	('Dame Hiver', 
	'Les flocons de neige dansent autour de vous. Secouer l''�dredon pour qu''il neige sur le monde.',
	5, NULL, 1, 2, 12);	

insert into shows (name, description, duration, nblimitspectators, permanent, parks_id, location_id) values 
	('Express des Alpes "Enzian"', 
	'Un classique � faire en famille. Le premier grand huit d''Europa-Park. Foncez � toute allure � travers les montagnes autrichiennes. Un grand huit id�al pour les familles.',
	1.8, 38, 1, 2, 13);	
	
insert into shows (name, description, duration, nblimitspectators, permanent, parks_id, location_id) values 
	('Fjord Rafting', 
	'Descente endiabl�e d''un torrent aux eaux sauvages Offrez-vous une descente en rafting dans les Rapides de scandinavie. Affrontez les eaux tumultueuses d''un torrent d�cha�n�, de puissantes et titanesques cascades� Une grande joie pour tous les aventuriers qui ne craignent pas l�eau. Alors pr�t pour l''aventure ? ',
	4.4, 6, 1, 2, 14);		
	
insert into shows (name, description, duration, nblimitspectators, permanent, parks_id, location_id) values 
	('Hansel et Gretel', 
	'Visitez la maison en pain d''�pice Visitez la maison en pain d''�pice et souvenez-vous des aventures de Hansel et Gretel dans le confortable salon. ',
	5, NULL, 1, 2, 12);	

insert into shows (name, description, duration, nblimitspectators, permanent, parks_id, location_id) values 
	('Le vol d''Icare', 
	'Un vol en montgolfi�re. Un v�ritable vol en montgolfi�re : d�collez tout en douceur, planez et atterrissez en toute s�curit�. ',
	2, 4, 1, 2, 11);;		
	
insert into specialities (name) values ('Chanteur/Musicien'), ('Com�dien'), ('Cavalier'), ('Machiniste'), ('Eclairagiste'), ('Costumier'), ('Pilote'), ('Pyrotechnicien'), ('Dresseur'), ('Danseur'), ('Cascadeur'), ('Direction') ;	

insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Quentin','AELLEN','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Jonas','AESCHBACHER','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Marwan','ALHELO','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Ashraf','ALKHEROO','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Roderick','ANGELOZ','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Gwenael','ANSERMOZ','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Kenan','AUGSBURGER','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Alex','BARREIRA-VIDEIRA','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Luca','BASSI','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Yannick','BAUDRAZ','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Philippe','BAUMANN','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Noe','BERDOZ','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Florian','BERGMANN','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Dylan','BERNEY','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Jan','BLATTER','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Francisco','BONITO','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary,  specialities_id) values ('Yoann','BONZON','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary,  specialities_id) values ('Jessy','BORCARD','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary,  specialities_id) values ('Jean-Amedee','BOSCH','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary,  specialities_id) values ('Arthur','BOTTEMANNE','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary,  specialities_id) values ('Arthur','BOURGUE','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary,  specialities_id) values ('Mathias','BOURQUI','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary,  specialities_id) values ('Ba-Khanh-Henry','BURGAT','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary,  specialities_id) values ('Mathieu','BURNAT','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary,  specialities_id) values ('Yvann','BUTTICAZ','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary,  specialities_id) values ('Vicky','BUTTY','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary,  specialities_id) values ('Joao-Alexandre','CARVALHO-SANTOS','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary,  specialities_id) values ('Jimmy','CATARINO-DINIS','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary,  specialities_id) values ('Richard','CHASSOT','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary,  specialities_id) values ('Nathan','CHAUVEAU','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary,  specialities_id) values ('Damien','CHERVET','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary,  specialities_id) values ('Nathanael','COLLAUD','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary,  specialities_id) values ('Theo','COOK','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary,  specialities_id) values ('Lucienne','CORNAZ','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary,  specialities_id) values ('Paola','COSTA','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary,  specialities_id) values ('Mauro-Alexandre','COSTA-DOS-SANTOS','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary,  specialities_id) values ('Leane','COUVREUR','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary,  specialities_id) values ('Simon','CUANY','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary,  specialities_id) values ('Dylan-David','CUNHA-ROCHA','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary,  specialities_id) values ('Diogo','DA-SILVA-FERNANDES','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary,  specialities_id) values ('David','DA-SILVA-SOARES','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary,  specialities_id) values ('Kevin','DE-ALMEIDA-GOMES','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary,  specialities_id) values ('Guilherme','DE-OLIVEIRA-CALHAU','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary,  specialities_id) values ('Elodie','DEPIERRAZ','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary,  specialities_id) values ('Raphael','DESFOURNEAUX','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary,  specialities_id) values ('David','DUBEY','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary,  specialities_id) values ('Antoine','DUBOIS','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary,  specialities_id) values ('Alexandre','DUBRULLE','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary,  specialities_id) values ('Florian','DURUZ','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary,  specialities_id) values ('Guillaume','DUVOISIN','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary,  specialities_id) values ('Kaarththigan','EAASWARALINGAM','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary,  specialities_id) values ('Joel','EMERY','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary,  specialities_id) values ('Gaetan','EPARS','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary,  specialities_id) values ('Bryan','EVANGELISTI','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary,  specialities_id) values ('Nolan','EVARD','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary,  specialities_id) values ('Naima','FAHMY-HANNA','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary,  specialities_id) values ('Jeremy','FAILLOUBAZ','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary,  specialities_id) values ('Loic','FAILLOUBAZ','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary,  specialities_id) values ('Yann','FANHA-DIAS','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary,  specialities_id) values ('Bastien','FARDEL','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary,  specialities_id) values ('Anthony','FAUGERON','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary,  specialities_id) values ('Yael','FAVRE','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary,  specialities_id) values ('Arben','FERATI','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary,  specialities_id) values ('Luis-Pedro','FERNANDES-PINHEIRO','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary,  specialities_id) values ('Ricardo-Joao','FERREIRA-DANTAS','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary,  specialities_id) values ('Tibo','FERREIRA-DE-CARVALHO','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary,  specialities_id) values ('Mounir-Yann','FIAUX','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary,  specialities_id) values ('Benjamin','FONTANA','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary,  specialities_id) values ('Alexandre','FONTES','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary,  specialities_id) values ('Kevin','GACON','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary,  specialities_id) values ('Daniel','GAMPER','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary,  specialities_id) values ('Din','GASHI','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary,  specialities_id) values ('Luca','GATTO','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary,  specialities_id) values ('Theo','GAUTIER','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary,  specialities_id) values ('Loic','GAVIN','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary,  specialities_id) values ('Paul-Loup','GERMAIN','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary,  specialities_id) values ('Esteban','GIORGIS','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary,  specialities_id) values ('Gabriel','GLOOR','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary,  specialities_id) values ('Michael','GOGNIAT','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary,  specialities_id) values ('Cyril','GOLDENSCHUE','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary,  specialities_id) values ('Andreas','GRANADA','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary,  specialities_id) values ('Thomas','GROSSMANN','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary,  specialities_id) values ('Adam','GRUBER','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary,  specialities_id) values ('Quentin','GUEISSAZ','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary,  specialities_id) values ('Mathias','GUIGNARD','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary,  specialities_id) values ('Shanshe','GUNDISHVILI','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary,  specialities_id) values ('Diego','HALDI','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary,  specialities_id) values ('Alexis','HALDY','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary,  specialities_id) values ('William','HAUSMANN','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary,  specialities_id) values ('Jonas','HAUTIER','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary,  specialities_id) values ('Alexandre','HOFSTETTER','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary,  specialities_id) values ('Thomas','HUGUET','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary,  specialities_id) values ('Romain','HUMBERT-DROZ-LAURENT','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Dimitri','IMFELD','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Szymon','JAGLA','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Damien','JAKOB','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Jerome','JAQUEMET','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Cyprien','JAQUIER','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Eliott','JAQUIER','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Gatien','JAYME','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Senistan','JEGARAJASINGAM','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Nithujan','JEGATHEESWARAN','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Mikael','JUILLET','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Jeremy','JUNGO','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Stephane','JUNOD','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Mehdi','KAROUI','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Christnovie','KIALA-BINGA','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Mahe','LAVAUD','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Amos','LE-COQ','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Sylvain','LECHAIRE','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Nathanael','LIARDET','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Marina','MACHADO-CAPISTRANO-SILVA','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Gabriel','MACHADO-PEREIRA','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Nicolas','MAITRE','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Davide','MANCOSU','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Fabien','MASSON','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Dmitri','MEILI','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Pierrot','METILLE','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Samuel-Souka','MEYER','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Loik','MEYLAN','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Garis','MIEHLBRADT','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Dylan','MIGEWANT','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Sam','CHATOUILLE','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Rui-Miguel','MONTEIRO-PEREIRA','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Sebastien','MORAZ','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Benjamin','MUMINOVIC','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Jeffrey','MVUTU-MABILAMA','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Enzo','NONNENMACHER','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Gael','OBERSON','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Benjamin','OCONNER','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Alec-Chima','OJI','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Dylan','OLIVEIRA-RAMOS','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Romain','ONRUBIA','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Loan','PANCHAUD','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Blend','PAPAZI','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Christopher','PARDO','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Kevin','PASTEUR','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Michael','PEDROLETTI','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Jonathan','PENARANDA-GONZALEZ','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Gabriel','PEREIRA','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Jonatan','PERRET','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Alexandre','PHILIBERT','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Celestin','PICCIN','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Oceane','PICHONNAZ','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Benoit','PIERREHUMBERT','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Fabian','PILLONEL','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Pedro','PINTO','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Diego','PINTO-TOMAZ','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Axel','PITTET','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Mathieu','RABOT','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Thirusan','RAJADURAI','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Timothee','RAPIN','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Nathan','RAYBURN','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Almir','RAZIC','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Mathias','RENOULT','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Nuno','RIBEIRO-PEREIRA','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Alexandre','RICART','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Louis','RICHARD','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Lucas','ROCHA-DO-ROSARIO','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Brian','RODRIGUES-FRAGA','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Samuel','ROLAND','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Alessandro','ROSSI','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Gabriel','ROSSIER','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('David','ROULET','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Antoine','ROULIN','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Azad','SAFAI-NAEENI','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Ammar-Nicolas','SALHI','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Souphakone','SAMOUTPHONH','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Tiago','SANTOS','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Andi','SANTOS-OLIVEIRA','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Robin','SCHMUTZ','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Ethann','SCHNEIDER','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Zaid-Francois','SCHOUWEY','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Thomas','SCHWARTZ','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Besjan','SEJRANI','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Bekir','SENGONUL','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Adam','SIFATE','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Samuel','SIMOES','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Miguel','SOARES','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Yann','SOLLIARD','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Edward','STEWART','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Ivan','STOJILOVIC','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Joshua','SURICO','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Arlindo','TAVARES-VARELA','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Kevin','TEIXEIRA','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary,  specialities_id) values ('Quentin','TIYANGOU', '2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Keanu','TROSSET','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Ander','URIEL-GLARIA','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Johnny','VACA-JARAMILLO','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('David-Manuel','VAROSO-GOMES','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Kevin','VAUCHER','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Diogo','VIEIRA-FERREIRA','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Killian','VIQUERAT','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Sven','VOLERY','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Gwenael','WEST','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Valentin','WILHEM','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Theo','YOSHIURA','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Altin','ZILI','2000-11-30', 1000, 1);
insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Valentin','ZINGG','2000-11-30', 1000, 1);

update employees set salary = salary * (id %12);

update employees set specialities_id = (id % 11) + 1;

insert into [employees](firstname, lastname, birthdate, salary, specialities_id) values ('Sam','Chatouille','1985-05-20', 5000, 12);


insert into roles (name, specialities_id) values ('Damien' ,2), ('Soline' ,1),('Gaulois',2), ('Gladiateur', 3), ('Machiniste', 4), ('Eclairagiste', 5), ('Princesse Ali�nor', 1), ('Elo�se', 1), ('Dresseur', 9), ('Carilloneur', 1), ('Com�diens voltigeurs', 11), ('Soldat', 2), ('Marguerite', 2), ('Jeanne la Lorraire', 3), ('Fulgent', 3), ('Chevalier', 3), ('Villageois ch�teau', 2), ('Costumier', 6) ;	
-- Le signe du triomphe (ar�ne)
-- Chanteur
insert into shows_has_employees (shows_id, employees_id, roles_id) values (5,33,2);
-- Com�dien
insert into shows_has_employees (shows_id, employees_id, roles_id) values (5,1,1);
insert into shows_has_employees (shows_id, employees_id, roles_id) values (5,12,3);
insert into shows_has_employees (shows_id, employees_id, roles_id) values (5,23,3);
insert into shows_has_employees (shows_id, employees_id, roles_id) values (5,34,3);
insert into shows_has_employees (shows_id, employees_id, roles_id) values (5,45,3);
insert into shows_has_employees (shows_id, employees_id, roles_id) values (5,56,3);
-- Dresseur
insert into shows_has_employees (shows_id, employees_id, roles_id) values (5,52,9);
insert into shows_has_employees (shows_id, employees_id, roles_id) values (5,41,9);
insert into shows_has_employees (shows_id, employees_id, roles_id) values (5,162,9);
-- Cavalier
insert into shows_has_employees (shows_id, employees_id, roles_id) values (5,90,4);
insert into shows_has_employees (shows_id, employees_id, roles_id) values (5,101,4);
insert into shows_has_employees (shows_id, employees_id, roles_id) values (5,112,4);
insert into shows_has_employees (shows_id, employees_id, roles_id) values (5,123,4);
insert into shows_has_employees (shows_id, employees_id, roles_id) values (5,134,4);

-- La Fontaine
-- Machiniste
insert into shows_has_employees (shows_id, employees_id, roles_id) values (1,14,5);

-- Pour les noces de feu
insert into shows_has_employees (shows_id, employees_id, roles_id) values (2,14,5);
insert into shows_has_employees (shows_id, employees_id, roles_id) values (2,48,6);

-- Le premier royaume (Clovis)
insert into shows_has_employees (shows_id, employees_id, roles_id) values (3,14,5);
insert into shows_has_employees (shows_id, employees_id, roles_id) values (3,48,6);

-- Le bal des oiseaux fant�me
-- Com�dien
insert into shows_has_employees (shows_id, employees_id, roles_id) values (4,56,7);
insert into shows_has_employees (shows_id, employees_id, roles_id) values (4,34,8);

-- Carillon
-- Musicien
insert into shows_has_employees (shows_id, employees_id, roles_id) values (6,45,10);
-- Cascadeur
insert into shows_has_employees (shows_id, employees_id, roles_id) values (6,98,11);
insert into shows_has_employees (shows_id, employees_id, roles_id) values (6,131,11);

-- Les amoureux de Verdun
insert into shows_has_employees (shows_id, employees_id, roles_id) values (7,45,12);
insert into shows_has_employees (shows_id, employees_id, roles_id) values (7,78,12);

-- Le secret de la lance
insert into shows_has_employees (shows_id, employees_id, roles_id) values (8,34,13);
insert into shows_has_employees (shows_id, employees_id, roles_id) values (8,35,14);
insert into shows_has_employees (shows_id, employees_id, roles_id) values (8,90,15);
insert into shows_has_employees (shows_id, employees_id, roles_id) values (8,101,16);
insert into shows_has_employees (shows_id, employees_id, roles_id) values (8,112,16);
insert into shows_has_employees (shows_id, employees_id, roles_id) values (8,123,16);
insert into shows_has_employees (shows_id, employees_id, roles_id) values (8,14,4);
insert into shows_has_employees (shows_id, employees_id, roles_id) values (8,56,17);
insert into shows_has_employees (shows_id, employees_id, roles_id) values (8,5,17);
insert into shows_has_employees (shows_id, employees_id, roles_id) values (8,16,17);
insert into shows_has_employees (shows_id, employees_id, roles_id) values (8,38,17);
insert into shows_has_employees (shows_id, employees_id, roles_id) values (8,38,18);
insert into shows_has_employees (shows_id, employees_id, roles_id) values (8,16,18);

-- Village 18�me
insert into restaurants (name, type, openingdate, openingtime, closingtime, closingdate, locations_id, parks_id) values ('L''auberge', 'Classique', '2021-07-08', '12:00', '22:00', '2021-09-30', 2, 1);
insert into restaurants (name, type, openingdate, openingtime, closingtime, closingdate, locations_id, parks_id) values ('La r�tissoire', 'Grillade', '2021-06-01', '12:00', '22:00', '2021-09-30', 2, 1);
insert into restaurants (name, type, openingdate, openingtime, closingtime, closingdate, locations_id, parks_id) values ('Le bistrot', 'Traditionnel', '2021-06-01', '12:00', '22:00', '2021-09-30', 3, 1);
insert into restaurants (name, type, openingdate, openingtime, closingtime, closingdate, locations_id, parks_id) values ('L''�chansonnerie', 'Renaissance', '2021-07-08', '12:00', '22:00', '2021-09-30', 1, 1);
insert into restaurants (name, type, openingdate, openingtime, closingtime, closingdate, locations_id, parks_id) values ('Le rendez-vous des ventres faims', 'Rapide', '2021-06-01', '12:00', '22:00', '2021-09-30', 4, 1);
insert into restaurants (name, type, openingdate, openingtime, closingtime, closingdate, locations_id, parks_id) values ('Le chaudron', 'A emporter', '2021-06-01', '12:00', '22:00', '2021-09-04', 4, 1);

insert into types (name) values ('Ma�tre verrier'),('Boulanger'), ('Librairie'), ('Poterie'), ('Jouets'), ('Sucreries'), ('Saboterie'), ('Fa�ence'), ('Relieuse doreuse') ;

--alter table shops add COLUMN name varchar(45) NOT NULL;

insert into shops(name, openingtime, closingtime, parks_id, locations_id, types_id) values ('Au verre souffl�', '10:00', '19:00', 1, 4, 1);
insert into shops(name, openingtime, closingtime, parks_id, locations_id, types_id) values ('Aux d�lices du Moyen-Age', '9:30', '19:00', 1, 4, 2);
insert into shops(name, openingtime, closingtime, parks_id, locations_id, types_id) values ('Aux contes du Moyen-Age', '10:00', '19:00', 1, 4, 3);
insert into shops(name, openingtime, closingtime, parks_id, locations_id, types_id) values ('Poteries et c�ramiques', '10:00', '19:00', 1, 4, 4);
insert into shops(name, openingtime, closingtime, parks_id, locations_id, types_id) values ('Le paradis des enfants', '10:00', '19:00', 1, 3, 5);
insert into shops(name, openingtime, closingtime, parks_id, locations_id, types_id) values ('Candies world', '10:00', '19:00', 1, 3, 6);
insert into shops(name, openingtime, closingtime, parks_id, locations_id, types_id) values ('La lecture en 1900', '10:00', '19:00', 1, 3, 3);

insert into shops(name, openingtime, closingtime, parks_id, locations_id, types_id) values ('Au sabotier', '10:00', '19:00', 1, 2, 7);
insert into shops(name, openingtime, closingtime, parks_id, locations_id, types_id) values ('Au temps de la fa�ence', '10:00', '19:00', 1, 3, 8);
insert into shops(name, openingtime, closingtime, parks_id, locations_id, types_id) values ('Au relieur dor�', '10:00', '19:00', 1, 3, 9);

-- TODO : Your triggers and functions