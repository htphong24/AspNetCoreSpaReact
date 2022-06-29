USE master;
GO

CREATE DATABASE ContactsMgmt
ON ( NAME = ContactsMgmt_dat, FILENAME = 'D:\Databases\Data\ContactsMgmt.mdf' )  
LOG ON
( NAME = ContactsMgmt_log, FILENAME = 'D:\Databases\Data\ContactsMgmt_log.ldf' );
GO

USE ContactsMgmt;
GO

/***************************************************
 **********       IDENTITY TABLES        ***********
 ***************************************************/

/*****************
 * AspNetUsers
 *****************/
CREATE TABLE [AspNetUsers] (
    [Id]                   NVARCHAR (127)     NOT NULL,
    [AccessFailedCount]    INT                NOT NULL,
    [ConcurrencyStamp]     NVARCHAR (4000),
    [Email]                NVARCHAR (255),
    [EmailConfirmed]       BIT                NOT NULL,
    [LockoutEnabled]       BIT                NOT NULL,
    [LockoutEnd]           DATETIME NULL,
    [NormalizedEmail]      NVARCHAR (255),
    [NormalizedUserName]   NVARCHAR (255),
    [PasswordHash]         NVARCHAR (4000),
    [PhoneNumber]          NVARCHAR (4000), 
    [PhoneNumberConfirmed] BIT                NOT NULL,
    [SecurityStamp]        NVARCHAR (4000),
    [TwoFactorEnabled]     BIT                NOT NULL,
    [UserName]             NVARCHAR (255) ,
    [FirstName]            NVARCHAR (255)     NOT NULL,
    [LastName]             NVARCHAR (255)     NOT NULL,
    [CreatedTime]          DATETIME DEFAULT(GETDATE()) NOT NULL,
    [UpdatedTime]          DATETIME DEFAULT(GETDATE()) NOT NULL
);
GO

ALTER TABLE [AspNetUsers] ADD CONSTRAINT [PK_AspNetUsers] PRIMARY KEY ([Id]);
GO

CREATE NONCLUSTERED INDEX [EmailIndex] ON [AspNetUsers]([NormalizedEmail] ASC);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UserNameIndex] ON [AspNetUsers]([NormalizedUserName] ASC);
GO

/********************
 * AspNetUserTokens
 ********************/
CREATE TABLE [AspNetUserTokens] (
    [UserId]        NVARCHAR (127)  NOT NULL,
    [LoginProvider] NVARCHAR (127)  NOT NULL,
    [Name]          NVARCHAR (450)  NOT NULL,
    [Value]         NVARCHAR (4000)
);
GO

ALTER TABLE [AspNetUserTokens] ADD CONSTRAINT [PK_AspNetUserTokens] PRIMARY KEY ([UserId], [LoginProvider], [Name]);
GO

/********************
 * RefreshTokens
 ********************/
CREATE TABLE [RefreshTokens] (
    [Id]               INT IDENTITY (1, 1)         NOT NULL,
    [Token]            NVARCHAR(4000)              NOT NULL,
    [ExpiresTime]      DATETIME                    NOT NULL,
    [CreatedTime]      DATETIME DEFAULT(GETDATE()) NOT NULL,
    [CreatedByIp]      NVARCHAR(255),
    [RevokedTime]      DATETIME,
    [RevokedByIp]      NVARCHAR(255),
    [ReplacedByToken]  NVARCHAR(4000),
    [UserId]           NVARCHAR(127)               NOT NULL
);
GO

ALTER TABLE [RefreshTokens] ADD CONSTRAINT [PK_RefreshTokens] PRIMARY KEY ([Id]);
GO
ALTER TABLE [RefreshTokens] ADD CONSTRAINT [FK_RefreshTokens_AspNetUsers_UserId] FOREIGN KEY ([UserId]) REFERENCES [AspNetUsers] ([Id]) ON DELETE CASCADE;
GO

CREATE NONCLUSTERED INDEX [IX_RefreshTokens_UserId] ON [RefreshTokens]([UserId]);
GO

/********************
 * AspNetRoles
 ********************/
CREATE TABLE [AspNetRoles] (
    [Id]               NVARCHAR (127)  NOT NULL,
    [ConcurrencyStamp] NVARCHAR (4000),
    [Name]             NVARCHAR (255),
    [NormalizedName]   NVARCHAR (255) 
);
GO

ALTER TABLE [AspNetRoles] ADD CONSTRAINT [PK_AspNetRoles] PRIMARY KEY ([Id]);
GO

CREATE NONCLUSTERED INDEX [RoleNameIndex] ON [AspNetRoles]([NormalizedName] ASC);
GO

INSERT INTO AspNetRoles (Id, ConcurrencyStamp, Name, NormalizedName) 
SELECT '-1', NEWID(), 'Admin',    LOWER('Admin')    UNION ALL
SELECT '-2', NEWID(), 'Standard', LOWER('Standard') UNION ALL
SELECT '-3', NEWID(), 'Manager',  LOWER('Manager')  UNION ALL
SELECT '-4', NEWID(), 'HR',       LOWER('HR');
GO

/********************
 * AspNetUserRoles
 ********************/
CREATE TABLE [AspNetUserRoles] (
    [UserId] NVARCHAR (127) NOT NULL,
    [RoleId] NVARCHAR (127) NOT NULL
);
GO

ALTER TABLE [AspNetUserRoles] ADD CONSTRAINT [PK_AspNetUserRoles] PRIMARY KEY ([UserId], [RoleId]);
GO
ALTER TABLE [AspNetUserRoles] ADD CONSTRAINT [FK_AspNetUserRoles_AspNetRoles_RoleId] FOREIGN KEY ([RoleId]) REFERENCES [AspNetRoles] ([Id]) ON DELETE CASCADE;
GO 
ALTER TABLE [AspNetUserRoles] ADD CONSTRAINT [FK_AspNetUserRoles_AspNetUsers_UserId] FOREIGN KEY ([UserId]) REFERENCES [AspNetUsers] ([Id]) ON DELETE CASCADE;
GO

CREATE NONCLUSTERED INDEX [IX_AspNetUserRoles_RoleId] ON [AspNetUserRoles]([RoleId ASC]);
GO
CREATE NONCLUSTERED INDEX [IX_AspNetUserRoles_UserId] ON [AspNetUserRoles]([UserId] ASC);
GO

/********************
 * AspNetUserLogins
 ********************/
CREATE TABLE [AspNetUserLogins] (
    [LoginProvider]       NVARCHAR (127)  NOT NULL,
    [ProviderKey]         NVARCHAR (127)  NOT NULL,
    [ProviderDisplayName] NVARCHAR (4000),
    [UserId]              NVARCHAR (127)  NOT NULL
);
GO

ALTER TABLE [AspNetUserLogins] ADD CONSTRAINT [PK_AspNetUserLogins] PRIMARY KEY ([LoginProvider], [ProviderKey]);
GO
ALTER TABLE [AspNetUserLogins] ADD CONSTRAINT [FK_AspNetUserLogins_AspNetUsers_UserId] FOREIGN KEY ([UserId]) REFERENCES [AspNetUsers] ([Id]) ON DELETE CASCADE;
GO

CREATE NONCLUSTERED INDEX [IX_AspNetUserLogins_UserId] ON [AspNetUserLogins]([UserId]);
GO

/********************
 * AspNetUserClaims
 ********************/
CREATE TABLE [AspNetUserClaims] (
    [Id]         INT IDENTITY (1, 1)  NOT NULL,
    [ClaimType]  NVARCHAR (4000),
    [ClaimValue] NVARCHAR (4000),
    [UserId]     NVARCHAR (127)       NOT NULL
);
GO

ALTER TABLE [AspNetUserClaims] ADD CONSTRAINT [PK_AspNetUserClaims] PRIMARY KEY ([Id]);
GO
ALTER TABLE [AspNetUserClaims] ADD CONSTRAINT [FK_AspNetUserClaims_AspNetUsers_UserId] FOREIGN KEY ([UserId]) REFERENCES [AspNetUsers] ([Id]) ON DELETE CASCADE;
GO

CREATE NONCLUSTERED INDEX [IX_AspNetUserClaims_UserId] ON [AspNetUserClaims]([UserId]);
GO

/********************
 * AspNetRoleClaims
 ********************/
CREATE TABLE [AspNetRoleClaims] (
    [Id]         INT IDENTITY (1, 1)  NOT NULL,
    [ClaimType]  NVARCHAR (4000),
    [ClaimValue] NVARCHAR (4000),
    [RoleId]     NVARCHAR (127)		  NOT NULL
);
GO

ALTER TABLE [AspNetRoleClaims] ADD CONSTRAINT [PK_AspNetRoleClaims] PRIMARY KEY ([Id]);
GO
ALTER TABLE [AspNetRoleClaims] ADD CONSTRAINT [FK_AspNetRoleClaims_AspNetRoles_RoleId] FOREIGN KEY ([RoleId]) REFERENCES [AspNetRoles] ([Id]) ON DELETE CASCADE;
GO

CREATE NONCLUSTERED INDEX [IX_AspNetRoleClaims_RoleId] ON [AspNetRoleClaims]([RoleId]);
GO

/******************************
 * Contacts
 ******************************/
CREATE TABLE [Contacts] (
  ContactId   INT IDENTITY(1, 1) NOT NULL,
  FirstName   NVARCHAR(255)      NOT NULL,
  LastName    NVARCHAR(255)      NOT NULL,
  Company     NVARCHAR(255),
  Address     NVARCHAR(255),
  City        NVARCHAR(255),
  State       NVARCHAR(255),
  Post        NVARCHAR(255),
  Email       NVARCHAR(255)      NOT NULL,
  Web         NVARCHAR(255),
  Phone1      NVARCHAR(127)      NOT NULL,
  Phone2      NVARCHAR(127)
);
GO

ALTER TABLE [Contacts] ADD CONSTRAINT Contacts_PK PRIMARY KEY (ContactId);
GO

--INSERT INTO Contacts (FirstName, LastName, Email, Phone1, Company, Address, City, State, Post, Web, Phone2) SELECT '', '', '', '', '', '', '', '', '', '', '';
INSERT INTO Contacts (FirstName, LastName, Email, Phone1, Company, Address, City, State, Post, Web, Phone2) 
SELECT 'Rebbecca', 'Didio', 'rebbecca.didio@didio.com.au', '03-8174-9123', 'Brandt, Jonathan F Esq', '171 E 24th St', 'Leith', 'TA', '7315', 'http://www.brandtjonathanfesq.com.au', '0458-665-290' UNION ALL
SELECT 'Stevie', 'Hallo', 'stevie.hallo@hotmail.com', '07-9997-3366', 'Landrum Temporary Services', '22222 Acoma St', 'Proston', 'QL', '4613', 'http://www.landrumtemporaryservices.com.au', '0497-622-620' UNION ALL
SELECT 'Mariko', 'Stayer', 'mariko_stayer@hotmail.com', '08-5558-9019', 'Inabinet, Macre Esq', '534 Schoenborn St #51', 'Hamel', 'WA', '6215', 'http://www.inabinetmacreesq.com.au', '0427-885-282' UNION ALL
SELECT 'Gerardo', 'Woodka', 'gerardo_woodka@hotmail.com', '02-6044-4682', 'Morris Downing & Sherred', '69206 Jackson Ave', 'Talmalmo', 'NS', '2640', 'http://www.morrisdowningsherred.com.au', '0443-795-912' UNION ALL
SELECT 'Mayra', 'Bena', 'mayra.bena@gmail.com', '02-1455-6085', 'Buelt, David L Esq', '808 Glen Cove Ave', 'Lane Cove', 'NS', '1595', 'http://www.bueltdavidlesq.com.au', '0453-666-885' UNION ALL
SELECT 'Idella', 'Scotland', 'idella@hotmail.com', '08-7868-1355', 'Artesian Ice & Cold Storage Co', '373 Lafayette St', 'Cartmeticup', 'WA', '6316', 'http://www.artesianicecoldstorageco.com.au', '0451-966-921' UNION ALL
SELECT 'Sherill', 'Klar', 'sklar@hotmail.com', '08-6522-8931', 'Midway Hotel', '87 Sylvan Ave', 'Nyamup', 'WA', '6258', 'http://www.midwayhotel.com.au', '0427-991-688' UNION ALL
SELECT 'Ena', 'Desjardiws', 'ena_desjardiws@desjardiws.com.au', '02-5226-9402', 'Selsor, Robert J Esq', '60562 Ky Rt 321', 'Bendick Murrell', 'NS', '2803', 'http://www.selsorrobertjesq.com.au', '0415-961-606' UNION ALL
SELECT 'Vince', 'Siena', 'vince_siena@yahoo.com', '07-3184-9989', 'Vincent J Petti & Co', '70 S 18th Pl', 'Purrawunda', 'QL', '4356', 'http://www.vincentjpettico.com.au', '0411-732-965' UNION ALL
SELECT 'Theron', 'Jarding', 'tjarding@hotmail.com', '08-6890-4661', 'Prentiss, Paul F Esq', '8839 Ventura Blvd', 'Blanchetown', 'SA', '5357', 'http://www.prentisspaulfesq.com.au', '0461-862-457' UNION ALL
SELECT 'Amira', 'Chudej', 'amira.chudej@chudej.net.au', '07-8135-3271', 'Public Works Department', '3684 N Wacker Dr', 'Rockside', 'QL', '4343', 'http://www.publicworksdepartment.com.au', '0478-867-289' UNION ALL
SELECT 'Marica', 'Tarbor', 'marica.tarbor@hotmail.com', '03-1174-6817', 'Prudential Lighting Corp', '68828 S 32nd St #6', 'Rosegarland', 'TA', '7140', 'http://www.prudentiallightingcorp.com.au', '0494-982-617' UNION ALL
SELECT 'Shawna', 'Albrough', 'shawna.albrough@albrough.com.au', '07-7977-6039', 'Wood, J Scott Esq', '43157 Cypress St', 'Ringwood', 'QL', '4343', 'http://www.woodjscottesq.com.au', '0441-255-802' UNION ALL
SELECT 'Paulina', 'Maker', 'paulina_maker@maker.net.au', '08-8344-8929', 'Swanson Peterson Fnrl Home Inc', '6 S Hanover Ave', 'Maylands', 'WA', '6931', 'http://www.swansonpetersonfnrlhomeinc.com.au', '0420-123-282' UNION ALL
SELECT 'Rose', 'Jebb', 'rose@jebb.net.au', '07-4941-9471', 'Old Cider Mill Grove', '27916 Tarrytown Rd', 'Wooloowin', 'QL', '4030', 'http://www.oldcidermillgrove.com.au', '0496-441-929' UNION ALL
SELECT 'Reita', 'Tabar', 'rtabar@hotmail.com', '02-3518-7078', 'Cooper Myers Y Co', '79620 Timber Dr', 'Arthurville', 'NS', '2820', 'http://www.coopermyersyco.com.au', '0431-669-863' UNION ALL
SELECT 'Maybelle', 'Bewley', 'mbewley@yahoo.com', '07-9387-7293', 'Angelo International', '387 Airway Cir #62', 'Mapleton', 'QL', '4560', 'http://www.angelointernational.com.au', '0448-221-640' UNION ALL
SELECT 'Camellia', 'Pylant', 'camellia_pylant@gmail.com', '02-5171-4345', 'Blackley, William J Pa', '570 W Pine St', 'Tuggerawong', 'NS', '2259', 'http://www.blackleywilliamjpa.com.au', '0423-446-913' UNION ALL
SELECT 'Roy', 'Nybo', 'rnybo@nybo.net.au', '02-5311-7778', 'Phoenix Phototype', '823 Fishers Ln', 'Red Hill', 'AC', '2603', 'http://www.phoenixphototype.com.au', '0416-394-795' UNION ALL
SELECT 'Albert', 'Sonier', 'albert.sonier@gmail.com', '07-9354-2612', 'Quartzite Processing Inc', '4 Brookcrest Dr #7786', 'Inverlaw', 'QL', '4610', 'http://www.quartziteprocessinginc.com.au', '0420-575-355' UNION ALL
SELECT 'Hayley', 'Taghon', 'htaghon@taghon.net.au', '02-1638-4380', 'Biltmore Textile Co Inc', '72 Wyoming Ave', 'Eugowra', 'NS', '2806', 'http://www.biltmoretextilecoinc.com.au', '0491-976-291' UNION ALL
SELECT 'Norah', 'Daleo', 'ndaleo@daleo.net.au', '02-5322-6127', 'Gateway Refrigeration', '754 Sammis Ave', 'Kotara Fair', 'NS', '2289', 'http://www.gatewayrefrigeration.com.au', '0462-327-613' UNION ALL
SELECT 'Rosina', 'Sidhu', 'rosina_sidhu@gmail.com', '07-6460-4488', 'Anchorage Yamaha', '660 N Green St', 'Burpengary', 'QL', '4505', 'http://www.anchorageyamaha.com.au', '0458-753-924' UNION ALL
SELECT 'Royal', 'Costeira', 'royal_costeira@costeira.com.au', '07-5338-6357', 'Wynns Precision Inc Az Div', '970 Waterloo Rd', 'Ellis Beach', 'QL', '4879', 'http://www.wynnsprecisionincazdiv.com.au', '0480-443-612' UNION ALL
SELECT 'Barrie', 'Nicley', 'bnicley@nicley.com.au', '03-6443-2786', 'Paragon Cable Tv', '4129 Abbott Dr', 'Fish Creek', 'VI', '3959', 'http://www.paragoncabletv.com.au', '0455-270-505' UNION ALL
SELECT 'Linsey', 'Gedman', 'lgedman@gedman.net.au', '07-4785-3781', 'Eagle Computer Services Inc', '1529 Prince Rodgers Ave', 'Kennedy', 'QL', '4816', 'http://www.eaglecomputerservicesinc.com.au', '0433-965-131' UNION ALL
SELECT 'Laura', 'Bourbonnais', 'laura.bourbonnais@yahoo.com', '03-6543-6688', 'Kansas Association Ins Agtts', '2 N Valley Mills Dr', 'Cape Portland', 'TA', '7264', 'http://www.kansasassociationinsagtts.com.au', '0491-455-112' UNION ALL
SELECT 'Fanny', 'Stoneking', 'fstoneking@hotmail.com', '07-3721-9123', 'Di Giacomo, Richard F Esq', '50968 Kurtz St #45', 'Warra', 'QL', '4411', 'http://www.digiacomorichardfesq.com.au', '0465-778-983' UNION ALL
SELECT 'Kristian', 'Ellerbusch', 'kristian@yahoo.com', '08-2748-1250', 'Butler, Frank B Esq', '71585 S Ayon Ave #9', 'Wanguri', 'NT', '810', 'http://www.butlerfrankbesq.com.au', '0442-982-316' UNION ALL
SELECT 'Gwen', 'Julye', 'gjulye@hotmail.com', '03-7063-6734', 'Alphagraphics Printshops', '8 Old County Rd #3', 'Alvie', 'VI', '3249', 'http://www.alphagraphicsprintshops.com.au', '0465-547-766' UNION ALL
SELECT 'Ben', 'Majorga', 'ben.majorga@hotmail.com', '02-8171-9051', 'Voyager Travel Service', '13904 S 35th St', 'Wherrol Flat', 'NS', '2429', 'http://www.voyagertravelservice.com.au', '0462-648-621' UNION ALL
SELECT 'Trina', 'Oto', 'trina@oto.com.au', '07-1153-8567', 'N Amer Plast & Chemls Co Inc', '6149 Kapiolani Blvd #6', 'Placid Hills', 'QL', '4343', 'http://www.namerplastchemlscoinc.com.au', '0460-377-727' UNION ALL
SELECT 'Emelda', 'Geffers', 'emelda.geffers@gmail.com', '08-7097-3947', 'D L Downing General Contr Inc', '95431 34th Ave #62', 'Nedlands', 'WA', '6909', 'http://www.dldowninggeneralcontrinc.com.au', '0454-643-433' UNION ALL
SELECT 'Zana', 'Ploszaj', 'zana_ploszaj@ploszaj.net.au', '07-7991-8880', 'Community Insurance Agy Inc', '25 Swift Ave', 'Auchenflower', 'QL', '4066', 'http://www.communityinsuranceagyinc.com.au', '0430-656-502' UNION ALL
SELECT 'Shaun', 'Rael', 'shaun.rael@rael.com.au', '03-8998-5485', 'House Of Ing', '14304 Old Alexandria Ferry Rd', 'Buninyong', 'VI', '3357', 'http://www.houseofing.com.au', '0498-627-281' UNION ALL
SELECT 'Oren', 'Lobosco', 'olobosco@hotmail.com', '02-5046-1307', 'Vei Inc', '1585 Salem Church Rd #59', 'Dangar Island', 'NS', '2083', 'http://www.veiinc.com.au', '0495-838-492' UNION ALL
SELECT 'Catherin', 'Aguele', 'caguele@gmail.com', '07-6476-1399', 'Hanna, Robert J Esq', '75962 E Drinker St', 'Sunny Nook', 'QL', '4605', 'http://www.hannarobertjesq.com.au', '0444-150-950' UNION ALL
SELECT 'Pearlene', 'Boudrie', 'pboudrie@boudrie.net.au', '07-4463-7223', 'Design Rite Homes Inc', '8978 W Henrietta Rd', 'Minden', 'QL', '4311', 'http://www.designritehomesinc.com.au', '0462-627-260' UNION ALL
SELECT 'Kathryn', 'Bonalumi', 'kathryn.bonalumi@yahoo.com', '08-3071-2258', 'State Library', '86 Worth St #272', 'Tibradden', 'WA', '6532', 'http://www.statelibrary.com.au', '0455-699-311' UNION ALL
SELECT 'Suzan', 'Landa', 'suzan.landa@gmail.com', '07-1576-1412', 'Vista Grande Baptist Church', '15 Campville Rd #191', 'Clermont', 'QL', '4721', 'http://www.vistagrandebaptistchurch.com.au', '0471-251-939' UNION ALL
SELECT 'Sommer', 'Agar', 'sagar@agar.net.au', '08-9130-3372', 'Poole Publications Inc', '3 N Ridge Ave', 'Kadina', 'SA', '5554', 'http://www.poolepublicationsinc.com.au', '0486-599-199' UNION ALL
SELECT 'Keena', 'Rebich', 'krebich@rebich.net.au', '02-4972-3570', 'Affilated Consulting Group Inc', '3713 Poway Rd', 'Sawtell', 'NS', '2452', 'http://www.affilatedconsultinggroupinc.com.au', '0468-708-802' UNION ALL
SELECT 'Rupert', 'Hinkson', 'rupert_hinkson@hinkson.net.au', '02-7160-2066', 'Northwestern Mutual Life Ins', '1 E 17th St', 'East Gosford', 'NS', '2250', 'http://www.northwesternmutuallifeins.com.au', '0489-430-358' UNION ALL
SELECT 'Aleta', 'Poarch', 'apoarch@gmail.com', '03-2691-1298', 'Barrett Burke Wilson Castl', '5 Liberty Ave', 'Fosterville', 'VI', '3557', 'http://www.barrettburkewilsoncastl.com.au', '0419-138-629' UNION ALL
SELECT 'Jamal', 'Korczynski', 'jamal_korczynski@gmail.com', '02-3877-9654', 'Helricks Inc', '404 Broxton Ave', 'Bateau Bay', 'NS', '2261', 'http://www.helricksinc.com.au', '0427-970-674' UNION ALL
SELECT 'Luz', 'Broccoli', 'luz_broccoli@hotmail.com', '07-2679-1774', 'Wynn, Mary Ellen Esq', '4 S Main St #285', 'Glenmoral', 'QL', '4719', 'http://www.wynnmaryellenesq.com.au', '0416-525-908' UNION ALL
SELECT 'Janessa', 'Ruthers', 'janessa@yahoo.com', '02-2367-6845', 'Mackraft Signs', '1255 W Passaic St #1553', 'Bolivia', 'NS', '2372', 'http://www.mackraftsigns.com.au', '0410-358-989' UNION ALL
SELECT 'Lavonne', 'Esco', 'lavonne.esco@yahoo.com', '03-3474-2120', 'Ansaring Answering Service', '377 Excalibur Dr', 'East Melbourne', 'VI', '3002', 'http://www.ansaringansweringservice.com.au', '0444-359-546' UNION ALL
SELECT 'Honey', 'Lymaster', 'honey_lymaster@lymaster.net.au', '07-8087-2603', 'Joiner & Goudeau Law Offices', '7 Wilshire Blvd', 'Taringa', 'QL', '4068', 'http://www.joinergoudeaulawoffices.com.au', '0411-717-109' UNION ALL
SELECT 'Jean', 'Cecchinato', 'jean.cecchinato@gmail.com', '08-5263-2786', 'Cox, J Thomas Jr', '7 Hugh Wallis Rd', 'Koolan Island', 'WA', '6733', 'http://www.coxjthomasjr.com.au', '0448-530-536' UNION ALL
SELECT 'Katlyn', 'Flitcroft', 'kflitcroft@hotmail.com', '07-1778-9968', 'Bill, Michael M', '7177 E 14th St', 'Maleny', 'QL', '4552', 'http://www.billmichaelm.com.au', '0465-519-356' UNION ALL
SELECT 'Cassie', 'Soros', 'csoros@gmail.com', '08-2666-6390', 'A B C Tank Co', '67765 W 11th St', 'Yelverton', 'WA', '6280', 'http://www.abctankco.com.au', '0423-281-356' UNION ALL
SELECT 'Rolf', 'Gene', 'rolf_gene@gene.com.au', '02-4458-2810', 'Jolley, Mark A Cpa', '99968 Merced St #79', 'Flinders', 'NS', '2529', 'http://www.jolleymarkacpa.com.au', '0482-882-653' UNION ALL
SELECT 'Darnell', 'Moothart', 'darnell_moothart@yahoo.com', '02-3996-9188', 'Melco Embroidery Systems', '40 E 19th Ave', 'Empire Bay', 'NS', '2257', 'http://www.melcoembroiderysystems.com.au', '0419-656-117' UNION ALL
SELECT 'Cherilyn', 'Fraize', 'cherilyn_fraize@fraize.net.au', '02-4873-1914', 'Witchs Brew', '84826 Plaza Dr', 'Rose Bay North', 'NS', '2030', 'http://www.witchsbrew.com.au', '0468-743-337' UNION ALL
SELECT 'Lynda', 'Lazzaro', 'lynda.lazzaro@gmail.com', '03-4933-4205', 'Funding Equity Corp', '20214 W Main St', 'Macks Creek', 'VI', '3971', 'http://www.fundingequitycorp.com.au', '0472-315-303' UNION ALL
SELECT 'Leigha', 'Capelli', 'leigha.capelli@capelli.com.au', '07-4823-9785', 'Saturn Of Delray', '8039 Howard Ave', 'East Toowoomba', 'QL', '4350', 'http://www.saturnofdelray.com.au', '0432-580-634' UNION ALL
SELECT 'Delfina', 'Binnie', 'delfina_binnie@binnie.net.au', '08-3692-5784', 'Motel 6', '8 Austin Bluffs Pky', 'Bimbijy', 'WA', '6472', 'http://www.motel.com.au', '0460-951-322' UNION ALL
SELECT 'Carlota', 'Gephardt', 'carlota.gephardt@gephardt.com.au', '02-5078-4389', 'Ultimate In Womens Apparel The', '96605 Pioneer Rd', 'Kundabung', 'NS', '2441', 'http://www.ultimateinwomensapparelthe.com.au', '0415-230-654' UNION ALL
SELECT 'Alida', 'Helger', 'alida@helger.com.au', '07-1642-3251', 'Ballinger, Maria Chan Esq', '6 Hope Rd #10', 'Pinnacle', 'QL', '4741', 'http://www.ballingermariachanesq.com.au', '0412-699-567' UNION ALL
SELECT 'Donte', 'Resureccion', 'donte.resureccion@yahoo.com', '07-2373-6048', 'N E Industrial Distr Inc', '65898 E St Nw', 'Watsonville', 'QL', '4887', 'http://www.neindustrialdistrinc.com.au', '0478-459-448' UNION ALL
SELECT 'Lou', 'Kriner', 'lou.kriner@hotmail.com', '02-7328-3350', 'Joondeph, Jerome J Esq', '39 Broad St', 'Seaforth', 'NS', '2092', 'http://www.joondephjeromejesq.com.au', '0496-387-592' UNION ALL
SELECT 'Dortha', 'Vrieze', 'dortha@vrieze.net.au', '03-1981-6209', 'Art In Forms', '654 Seguine Ave', 'White Hills', 'TA', '7258', 'http://www.artinforms.com.au', '0430-222-319' UNION ALL
SELECT 'Genevive', 'Sanborn', 'genevive@hotmail.com', '02-6246-5711', 'Central Hudson Ent Corp', '78 31st St', 'Bellangry', 'NS', '2446', 'http://www.centralhudsonentcorp.com.au', '0431-413-930' UNION ALL
SELECT 'Alease', 'Strawbridge', 'alease_strawbridge@strawbridge.com.au', '07-3760-1546', 'Marscher, William F Iii', '35673 Annapolis Rd #190', 'Ascot', 'QL', '4359', 'http://www.marscherwilliamfiii.com.au', '0497-868-525' UNION ALL
SELECT 'Veda', 'Mishkin', 'veda.mishkin@mishkin.com.au', '07-6034-2422', 'Smith, Sean O Esq', '98247 Russell Blvd', 'Stafford Heights', 'QL', '4053', 'http://www.smithseanoesq.com.au', '0474-823-917' UNION ALL
SELECT 'Craig', 'Vandersloot', 'craig_vandersloot@yahoo.com', '02-5487-7528', 'Maverik Country Stores Inc', '3 S Willow St #82', 'Bygalorie', 'NS', '2669', 'http://www.maverikcountrystoresinc.com.au', '0492-408-109' UNION ALL
SELECT 'Lauran', 'Tovmasyan', 'ltovmasyan@tovmasyan.net.au', '02-2546-5344', 'United Christian Cmnty Crdt Un', '199 Maple Ave', 'Boolaroo', 'NS', '2284', 'http://www.unitedchristiancmntycrdtun.com.au', '0459-680-488' UNION ALL
SELECT 'Aaron', 'Kloska', 'aaron_kloska@kloska.net.au', '07-9896-4827', 'Radecker, H Philip Jr', '423 S Navajo St #56', 'Brookhill', 'QL', '4816', 'http://www.radeckerhphilipjr.com.au', '0473-600-733' UNION ALL
SELECT 'Francene', 'Skursky', 'francene.skursky@skursky.net.au', '02-5941-3178', 'Cullen, Jack J Esq', '5 30w W #3083', 'Hillston', 'NS', '2675', 'http://www.cullenjackjesq.com.au', '0485-944-417' UNION ALL
SELECT 'Zena', 'Daria', 'zdaria@gmail.com', '03-2822-8156', 'Kszl Am Radio', '57245 W Union Blvd #25', 'Ivanhoe East', 'VI', '3079', 'http://www.kszlamradio.com.au', '0466-820-981' UNION ALL
SELECT 'Brigette', 'Breckenstein', 'brigette@breckenstein.com.au', '03-5722-3451', 'Blewett, Yvonne S', '971 Northwest Blvd', 'Caniambo', 'VI', '3630', 'http://www.blewettyvonnes.com.au', '0462-308-800' UNION ALL
SELECT 'Jeniffer', 'Jezek', 'jeniffer@gmail.com', '03-3268-5102', 'Sheraton Inn Atlanta Northwest', '1089 Pacific Coast Hwy', 'Myrniong', 'VI', '3341', 'http://www.sheratoninnatlantanorthwest.com.au', '0493-644-827' UNION ALL
SELECT 'Selma', 'Elm', 'selm@elm.net.au', '03-9183-9493', 'Preston, Anne M Esq', '6787 Emerson St', 'Woolamai', 'VI', '3995', 'http://www.prestonannemesq.com.au', '0418-581-770' UNION ALL
SELECT 'Elenora', 'Handler', 'ehandler@yahoo.com', '08-5671-3318', 'A & A Custom Rubber Stamps', '8 Middletown Blvd #708', 'Wardering', 'WA', '6311', 'http://www.aacustomrubberstamps.com.au', '0481-367-908' UNION ALL
SELECT 'Nadine', 'Okojie', 'nadine.okojie@okojie.com.au', '08-9746-2341', 'Hirsch, Walter W Esq', '56 Tank Farm Rd', 'Kukerin', 'WA', '6352', 'http://www.hirschwalterwesq.com.au', '0424-801-736' UNION ALL
SELECT 'Kristin', 'Shiflet', 'kristin@hotmail.com', '03-4529-7210', 'Jones, Peter B Esq', '503 Fulford Ave', 'Somers', 'VI', '3927', 'http://www.jonespeterbesq.com.au', '0488-223-788' UNION ALL
SELECT 'Melinda', 'Fellhauer', 'melinda_fellhauer@fellhauer.com.au', '03-4387-3800', 'Sterling Institute', '8275 Calle De Industrias', 'Wayatinah', 'TA', '7140', 'http://www.sterlinginstitute.com.au', '0493-258-647' UNION ALL
SELECT 'Kirby', 'Litherland', 'kirby.litherland@hotmail.com', '07-5284-3845', 'Cross Western Store', '92 South St', 'Alligator Creek', 'QL', '4740', 'http://www.crosswesternstore.com.au', '0480-676-186' UNION ALL
SELECT 'Kent', 'Ivans', 'kent_ivans@yahoo.com', '07-8661-4016', 'Demer Normann Smith Ltd', '56710 Euclid Ave', 'Camp Mountain', 'QL', '4520', 'http://www.demernormannsmithltd.com.au', '0429-746-524' UNION ALL
SELECT 'Dan', 'Platz', 'dan_platz@hotmail.com', '07-4306-1623', 'Ny Stat Trial Lawyers Assn', '5210 E Airy St #2', 'Brandy Creek', 'QL', '4800', 'http://www.nystattriallawyersassn.com.au', '0441-978-907' UNION ALL
SELECT 'Millie', 'Pirkl', 'millie_pirkl@gmail.com', '03-6023-2680', 'Mann, Charles E Esq', '31 Schuyler Ave', 'Sovereign Hill', 'VI', '3350', 'http://www.manncharleseesq.com.au', '0410-688-713' UNION ALL
SELECT 'Moira', 'Qadir', 'moira.qadir@gmail.com', '08-7687-4883', 'Airnetics Engineering Co', '661 Plummer St #963', 'Arno Bay', 'SA', '5603', 'http://www.airneticsengineeringco.com.au', '0471-106-909' UNION ALL
SELECT 'Reta', 'Qazi', 'reta.qazi@yahoo.com', '03-1974-9948', 'American Pie Co Inc', '1351 Simpson St', 'Maffra', 'VI', '3860', 'http://www.americanpiecoinc.com.au', '0446-105-779' UNION ALL
SELECT 'Brittney', 'Lolley', 'brittney@lolley.net.au', '03-4072-7094', 'Brown Chiropractic', '2391 Pacific Blvd', 'Ulverstone', 'TA', '7315', 'http://www.brownchiropractic.com.au', '0451-120-660' UNION ALL
SELECT 'Leandro', 'Bolka', 'leandro_bolka@hotmail.com', '03-8157-4609', 'Classic Video Duplication Inc', '1886 2nd Ave', 'Wattle Hill', 'TA', '7172', 'http://www.classicvideoduplicationinc.com.au', '0413-530-467' UNION ALL
SELECT 'Edison', 'Sumera', 'edison.sumera@sumera.net.au', '08-9114-1763', 'Mcclier Corp', '52404 S Clinton Ave', 'Bower', 'SA', '5374', 'http://www.mccliercorp.com.au', '0463-377-181' UNION ALL
SELECT 'Breana', 'Cassi', 'breana@yahoo.com', '03-2305-8627', 'Gormley Lore Murphy', '405 W Lee St', 'Stonehaven', 'VI', '3221', 'http://www.gormleyloremurphy.com.au', '0495-644-883' UNION ALL
SELECT 'Jarvis', 'Nicols', 'jarvis@gmail.com', '08-2117-5217', 'Thudium Mail Advg Company', '5656 N Fiesta Blvd', 'East Newdegate', 'WA', '6355', 'http://www.thudiummailadvgcompany.com.au', '0436-246-951' UNION ALL
SELECT 'Felicitas', 'Orlinski', 'felicitas_orlinski@orlinski.com.au', '03-2451-1896', 'Jen E Distributing Co', '9 Beverly Rd #5', 'Emerald', 'VI', '3782', 'http://www.jenedistributingco.com.au', '0444-326-506' UNION ALL
SELECT 'Geraldine', 'Neisius', 'geraldine@gmail.com', '03-8243-2999', 'Re/max Realty Services', '96 Armitage Ave', 'Katunga', 'VI', '3640', 'http://www.remaxrealtyservices.com.au', '0440-707-817' UNION ALL
SELECT 'Alfred', 'Pacleb', 'alfred@pacleb.net.au', '08-9450-7978', 'Roundys Pole Fence Co', '523 N Prince St', 'Willunga', 'SA', '5172', 'http://www.roundyspolefenceco.com.au', '0453-896-533' UNION ALL
SELECT 'Leatha', 'Block', 'leatha_block@gmail.com', '08-7635-8350', 'Chadds Ford Winery', '6926 Orange Ave', 'Two Rocks', 'WA', '6037', 'http://www.chaddsfordwinery.com.au', '0445-211-162' UNION ALL
SELECT 'Jacquelyne', 'Rosso', 'jacquelyne.rosso@yahoo.com', '02-4565-6425', 'Barragar, Anne L Esq', '6940 Prospect Pl', 'Caldwell', 'NS', '2710', 'http://www.barragarannelesq.com.au', '0464-763-350' UNION ALL
SELECT 'Jonelle', 'Epps', 'jepps@hotmail.com', '07-8085-8351', 'Kvoo Radio', '52347 San Fernando Rd', 'Coppabella', 'QL', '4741', 'http://www.kvooradio.com.au', '0461-339-731' UNION ALL
SELECT 'Rosamond', 'Amlin', 'rosamond.amlin@gmail.com', '02-8007-5034', 'Donovan, William P Esq', '5399 Mcwhorter Rd', 'Calala', 'NS', '2340', 'http://www.donovanwilliampesq.com.au', '0438-251-615' UNION ALL
SELECT 'Johnson', 'Mcenery', 'johnson@gmail.com', '02-1718-4983', 'Overseas General Business Co', '7 Hall St', 'Nambucca Heads', 'NS', '2448', 'http://www.overseasgeneralbusinessco.com.au', '0446-721-262' UNION ALL
SELECT 'Elliot', 'Scatton', 'elliot.scatton@hotmail.com', '02-3647-9507', 'Nilad Machining', '5 W Allen St', 'Mccullys Gap', 'NS', '2333', 'http://www.niladmachining.com.au', '0481-878-290' UNION ALL
SELECT 'Gerri', 'Perra', 'gerri@yahoo.com', '07-6019-7861', 'Byrne, Beth Hobbs', '15126 Goldenwest St', 'Toowoomba South', 'QL', '4350', 'http://www.byrnebethhobbs.com.au', '0416-887-937' UNION ALL
SELECT 'Rosendo', 'Jelsma', 'rosendo_jelsma@hotmail.com', '08-7712-4785', 'Dileo, Lucille A Esq', '94 I 55s S', 'Applecross', 'WA', '6953', 'http://www.dileolucilleaesq.com.au', '0477-239-199' UNION ALL
SELECT 'Eveline', 'Brickhouse', 'eveline@yahoo.com', '03-9517-9800', 'First Express', '288 N 168th Ave #266', 'Camberwell West', 'VI', '3124', 'http://www.firstexpress.com.au', '0463-242-525' UNION ALL
SELECT 'Laurene', 'Bennett', 'laurene_bennett@gmail.com', '08-2969-2908', 'Elbin Internatl Baskets', '5 Richmond Ct', 'North Perth', 'WA', '6906', 'http://www.elbininternatlbaskets.com.au', '0468-234-875' UNION ALL
SELECT 'Tegan', 'Ebershoff', 'tegan_ebershoff@hotmail.com', '02-6604-9720', 'Multiform Business Printing', '28 Aaronwood Ave Ne', 'Coombell', 'NS', '2470', 'http://www.multiformbusinessprinting.com.au', '0499-760-910' UNION ALL
SELECT 'Tracie', 'Huro', 'thuro@gmail.com', '07-1951-6787', 'Jin Shin Travel Agency', '39701 6th Ave #1485', 'Pacific Heights', 'QL', '4703', 'http://www.jinshintravelagency.com.au', '0494-620-234' UNION ALL
SELECT 'Mertie', 'Kazeck', 'mertie.kazeck@kazeck.com.au', '08-5475-6162', 'Electra Gear Divsn Regal', '35662 S University Blvd', 'Guildford', 'WA', '6935', 'http://www.electrageardivsnregal.com.au', '0446-422-535' UNION ALL
SELECT 'Clare', 'Bortignon', 'clare_bortignon@hotmail.com', '08-9256-6135', 'Sparta Home Center', '73 Dennison St #70', 'Herron', 'WA', '6210', 'http://www.spartahomecenter.com.au', '0423-874-910' UNION ALL
SELECT 'Rebeca', 'Baley', 'rebeca_baley@hotmail.com', '02-7049-7728', 'R A C E Enterprises Inc', '9591 Bayshore Rd #637', 'Mirrool', 'NS', '2665', 'http://www.raceenterprisesinc.com.au', '0486-736-129' UNION ALL
SELECT 'Nilsa', 'Pawell', 'npawell@pawell.net.au', '07-8997-8513', 'Jersey Wholesale Fence Co Inc', '57 N Weinbach Ave', 'Bundaberg West', 'QL', '4670', 'http://www.jerseywholesalefencecoinc.com.au', '0486-504-582' UNION ALL
SELECT 'Samuel', 'Arellanes', 'samuel.arellanes@arellanes.net.au', '02-7995-6787', 'Ryan, Barry M Esq', '286 Santa Rosa Ave', 'Lane Cove', 'NS', '1595', 'http://www.ryanbarrymesq.com.au', '0446-710-661' UNION ALL
SELECT 'Ivette', 'Servantes', 'ivette_servantes@servantes.com.au', '03-9801-9429', 'Albright, Alexandra W Esq', '446 Woodward Ave #1', 'Reservoir', 'VI', '3073', 'http://www.albrightalexandrawesq.com.au', '0488-109-742' UNION ALL
SELECT 'Merrilee', 'Fajen', 'merrilee@fajen.net.au', '07-9104-1459', 'Gazette Record', '1 Jenks Ave', 'Upper Kedron', 'QL', '4055', 'http://www.gazetterecord.com.au', '0489-493-308' UNION ALL
SELECT 'Gianna', 'Eilers', 'gianna@yahoo.com', '03-4328-5253', 'Cochnower Pest Control', '7 Valley Blvd', 'Buchan', 'VI', '3885', 'http://www.cochnowerpestcontrol.com.au', '0418-994-884' UNION ALL
SELECT 'Hyman', 'Phinazee', 'hphinazee@yahoo.com', '08-5756-9456', 'Als Village Stationers', '42741 Anania Dr', 'Beltana', 'SA', '5730', 'http://www.alsvillagestationers.com.au', '0446-460-955' UNION ALL
SELECT 'Buck', 'Pascucci', 'buck@yahoo.com', '08-9279-1731', 'A B C Pattern & Foundry Co', '5 Shakespeare Ave', 'Kingswood', 'SA', '5062', 'http://www.abcpatternfoundryco.com.au', '0453-818-566' UNION ALL
SELECT 'Kenny', 'Leicht', 'kenny@leicht.com.au', '03-6240-8274', 'Gaddis Court Reporting', '245 5th Ave', 'Nicholls Rivulet', 'TA', '7112', 'http://www.gaddiscourtreporting.com.au', '0486-712-822' UNION ALL
SELECT 'Tabetha', 'Bai', 'tabetha.bai@gmail.com', '07-6813-6477', 'Howard Johnson', '2 Gateway Ctr', 'Upper Mount Gravatt', 'QL', '4122', 'http://www.howardjohnson.com.au', '0438-141-107' UNION ALL
SELECT 'Alonso', 'Popper', 'alonso_popper@hotmail.com', '03-7036-7071', 'Sunrise Cirby Animal Hospital', '3175 Northwestern Hwy', 'Ridgley', 'TA', '7321', 'http://www.sunrisecirbyanimalhospital.com.au', '0448-235-525' UNION ALL
SELECT 'Alonzo', 'Polek', 'alonzo_polek@polek.net.au', '03-2403-7167', 'Braid Electric Co', '8 S Plaza Dr', 'Tubbut', 'VI', '3888', 'http://www.braidelectricco.com.au', '0419-100-429' UNION ALL
SELECT 'Son', 'Magnotta', 'son.magnotta@magnotta.net.au', '02-2376-7653', 'Lisko, Roy K Esq', '8 Collins Ave', 'Collingullie', 'NS', '2650', 'http://www.liskoroykesq.com.au', '0446-520-807' UNION ALL
SELECT 'Jesusita', 'Druck', 'jesusita@druck.net.au', '08-3605-3943', 'House Of Ing', '9526 Lincoln St', 'Munno Para', 'SA', '5115', 'http://www.houseofing.com.au', '0424-741-530' UNION ALL
SELECT 'Annice', 'Kunich', 'annice_kunich@kunich.net.au', '02-6769-6153', 'Hassanein, Nesa E Esq', '406 E 4th St', 'Tyagarah', 'NS', '2481', 'http://www.hassaneinnesaeesq.com.au', '0449-775-616' UNION ALL
SELECT 'Delila', 'Buchman', 'delila.buchman@hotmail.com', '08-1791-7668', 'Frasier Karen L Kolligs', '361 Via Colinas', 'Redgate', 'WA', '6286', 'http://www.frasierkarenlkolligs.com.au', '0454-544-286' UNION ALL
SELECT 'Iraida', 'Sionesini', 'iraida.sionesini@yahoo.com', '03-4812-5654', 'Arc Of Montgomery County Inc', '94 S Jefferson Rd', 'Modewarre', 'VI', '3240', 'http://www.arcofmontgomerycountyinc.com.au', '0490-625-307' UNION ALL
SELECT 'Alona', 'Driesenga', 'alona_driesenga@hotmail.com', '08-6777-4159', 'Redington, Thomas P Esq', '8961 S Central Expy', 'Stirling Range National Park', 'WA', '6338', 'http://www.redingtonthomaspesq.com.au', '0428-176-191' UNION ALL
SELECT 'Lajuana', 'Vonderahe', 'lajuana.vonderahe@yahoo.com', '03-5661-2424', 'Milwaukee Courier Inc', '7 Wiley Post Way', 'Trowutta', 'TA', '7330', 'http://www.milwaukeecourierinc.com.au', '0430-111-686' UNION ALL
SELECT 'Madelyn', 'Maestri', 'madelyn.maestri@yahoo.com', '02-2129-8131', 'Mervis Steel Co', '60 S 4th St', 'Rouse Hill', 'NS', '2155', 'http://www.mervissteelco.com.au', '0413-115-438' UNION ALL
SELECT 'Louann', 'Susmilch', 'louann_susmilch@yahoo.com', '07-5035-4889', 'M Sorkin Sanford Associates', '6 Lafayette St #3034', 'Wyandra', 'QL', '4489', 'http://www.msorkinsanfordassociates.com.au', '0489-594-290' UNION ALL
SELECT 'William', 'Devol', 'wdevol@devol.net.au', '07-4963-5297', 'Low Country Kitchen & Bath', '35 Jefferson Ave', 'Goondi Hill', 'QL', '4860', 'http://www.lowcountrykitchenbath.com.au', '0485-183-917' UNION ALL
SELECT 'Corazon', 'Grafenstein', 'cgrafenstein@gmail.com', '08-1624-7236', 'Spieker Properties', '3492 88th St', 'Hill River', 'WA', '6521', 'http://www.spiekerproperties.com.au', '0481-500-964' UNION ALL
SELECT 'Fairy', 'Burket', 'fairy_burket@burket.com.au', '08-9159-7562', 'Walker & Brehn Pa', '20 Sw 28th Ter', 'Fairview Park', 'SA', '5126', 'http://www.walkerbrehnpa.com.au', '0472-806-350' UNION ALL
SELECT 'Lashawn', 'Urion', 'lurion@yahoo.com', '02-4794-6673', 'U Stor', '6 Argyle Rd', 'Bar Beach', 'NS', '2300', 'http://www.ustor.com.au', '0436-337-750' UNION ALL
SELECT 'Ronald', 'Gayner', 'rgayner@hotmail.com', '03-7734-9557', 'Moorhead, Michael D Esq', '438 E Reynolds Rd #239', 'University Of Tasmania', 'TA', '7005', 'http://www.moorheadmichaeldesq.com.au', '0499-737-220' UNION ALL
SELECT 'Shizue', 'Hayduk', 'shayduk@gmail.com', '03-2297-9891', 'R M Sloan Co Inc', '47 Hall St', 'Regent West', 'VI', '3072', 'http://www.rmsloancoinc.com.au', '0456-480-906' UNION ALL
SELECT 'Nida', 'Fitz', 'nfitz@hotmail.com', '07-7445-2572', 'Star Limousine', '17720 Beach Blvd', 'Oxley', 'QL', '4075', 'http://www.starlimousine.com.au', '0473-495-435' UNION ALL
SELECT 'Amos', 'Limberg', 'alimberg@limberg.com.au', '03-4539-9131', 'Pioneer Telephone Paging', '8 2nd St', 'Don', 'TA', '7310', 'http://www.pioneertelephonepaging.com.au', '0492-444-651' UNION ALL
SELECT 'Dexter', 'Prosienski', 'dexter@prosienski.net.au', '03-2454-6523', 'Communication Buildings Amer', '490 Court St', 'Nyora', 'VI', '3987', 'http://www.communicationbuildingsamer.com.au', '0472-707-132' UNION ALL
SELECT 'Ludivina', 'Calamarino', 'lcalamarino@yahoo.com', '07-5378-4498', 'Components & Equipment Co', '1456 Hill Rd', 'Croydon', 'QL', '4871', 'http://www.componentsequipmentco.com.au', '0482-267-844' UNION ALL
SELECT 'Ariel', 'Stavely', 'ariel_stavely@stavely.com.au', '03-6510-4788', 'Grand Rapids Right To Life', '6 7th St', 'Scottsdale', 'TA', '7260', 'http://www.grandrapidsrighttolife.com.au', '0441-579-823' UNION ALL
SELECT 'Haley', 'Vaughn', 'haley_vaughn@vaughn.net.au', '03-7035-6484', 'Martin Nighswander & Mitchell', '29 Nottingham Way #926', 'Montrose', 'VI', '3765', 'http://www.martinnighswandermitchell.com.au', '0430-736-276' UNION ALL
SELECT 'Raelene', 'Legeyt', 'raelene@gmail.com', '03-4878-1766', 'Barter Systems Inc', '8818 Century Park E #33', 'Oak Park', 'VI', '3046', 'http://www.bartersystemsinc.com.au', '0463-745-755' UNION ALL
SELECT 'Micaela', 'Shiflett', 'micaela_shiflett@shiflett.com.au', '08-8856-8589', 'W R Grace & Co', '4 Commerce Center Dr', 'Nailsworth', 'SA', '5083', 'http://www.wrgraceco.com.au', '0451-514-152' UNION ALL
SELECT 'Alpha', 'Prudhomme', 'aprudhomme@hotmail.com', '07-9053-8045', 'Davis, J Mark Esq', '979 S La Cienega Blvd #627', 'Tarong', 'QL', '4615', 'http://www.davisjmarkesq.com.au', '0464-687-686' UNION ALL
SELECT 'Zack', 'Warman', 'zwarman@gmail.com', '08-9948-2940', 'Roswell Honda Partners', '9181 E 26th St', 'Kensington Park', 'SA', '5068', 'http://www.roswellhondapartners.com.au', '0414-749-850' UNION ALL
SELECT 'Wilford', 'Pata', 'wilford_pata@pata.net.au', '07-7445-2538', 'Era Mclachlan John Morgan Real', '8855 North Ave', 'Ashmore', 'QL', '4214', 'http://www.eramclachlanjohnmorganreal.com.au', '0445-797-121' UNION ALL
SELECT 'Carman', 'Robasciotti', 'carman_robasciotti@hotmail.com', '03-1570-9956', 'Vaughan, James J Esq', '4 Spinning Wheel Ln', 'Granya', 'VI', '3701', 'http://www.vaughanjamesjesq.com.au', '0420-704-683' UNION ALL
SELECT 'Carylon', 'Bayot', 'carylon@gmail.com', '03-8858-7088', 'Wzyx 1440 Am', '5905 S 32nd St', 'Alexandra', 'VI', '3714', 'http://www.wzyxam.com.au', '0475-926-458' UNION ALL
SELECT 'Gladys', 'Schmale', 'gschmale@schmale.net.au', '08-4564-2338', 'Amercn Spdy Printg Ctrs Ocala', '514 Glenn Way', 'Wirrulla', 'SA', '5661', 'http://www.amercnspdyprintgctrsocala.com.au', '0410-812-931' UNION ALL
SELECT 'Matilda', 'Peleg', 'matilda.peleg@hotmail.com', '03-1130-5685', 'A & D Pallet Co', '708 S Wilson Way', 'Weymouth', 'TA', '7252', 'http://www.adpalletco.com.au', '0481-222-272' UNION ALL
SELECT 'Jacklyn', 'Wojnar', 'jacklyn@hotmail.com', '02-6287-8787', 'Nationwide Insurance', '16949 Harristown Rd', 'Summer Hill', 'NS', '2287', 'http://www.nationwideinsurance.com.au', '0434-382-805' UNION ALL
SELECT 'Tashia', 'Charney', 'tashia.charney@charney.net.au', '07-7659-5711', 'Gallagher, Owen Esq', '9 13th Ave S', 'Shailer Park', 'QL', '4128', 'http://www.gallagherowenesq.com.au', '0450-769-383' UNION ALL
SELECT 'Dorian', 'Eischens', 'deischens@gmail.com', '02-7739-6600', 'Thomas Somerville Co', '1 Rock Island Rd #8', 'Bell', 'NS', '2786', 'http://www.thomassomervilleco.com.au', '0428-946-162' UNION ALL
SELECT 'Jesus', 'Merkt', 'jesus_merkt@merkt.net.au', '03-9341-9757', 'Unr Rohn', '1554 Bracken Crk', 'Licola', 'VI', '3858', 'http://www.unrrohn.com.au', '0492-739-675' UNION ALL
SELECT 'Brandee', 'Svoboda', 'brandee_svoboda@svoboda.net.au', '08-3614-5966', 'Cath Lea For Relig & Cvl Rgts', '7 10th St W', 'Walyormouring', 'WA', '6460', 'http://www.cathleaforreligcvlrgts.com.au', '0419-644-936' UNION ALL
SELECT 'Edda', 'Mcquaide', 'emcquaide@yahoo.com', '03-1465-8645', 'Eagles Nest', '9 Cron Hill Dr', 'Boronia', 'VI', '3155', 'http://www.eaglesnest.com.au', '0416-330-811' UNION ALL
SELECT 'Felix', 'Bumby', 'felix.bumby@bumby.com.au', '03-1431-3996', 'Epsilon Products Company', '82 Tremont St #4', 'Baddaginnie', 'VI', '3670', 'http://www.epsilonproductscompany.com.au', '0485-718-212' UNION ALL
SELECT 'Ben', 'Kellman', 'ben_kellman@kellman.net.au', '02-7968-9243', 'Anderson, Julie A Esq', '30024 Whipple Ave Nw', 'Berrilee', 'NS', '2159', 'http://www.andersonjulieaesq.com.au', '0441-733-809' UNION ALL
SELECT 'Mickie', 'Upton', 'mickie.upton@yahoo.com', '07-7647-5420', 'Oakey & Oakey Abstrct Burnett', '900 W Wood St', 'Barmaryee', 'QL', '4703', 'http://www.oakeyoakeyabstrctburnett.com.au', '0499-576-666' UNION ALL
SELECT 'Phung', 'Krome', 'pkrome@yahoo.com', '03-9617-5392', 'Pacific Scientific Co', '847 Norristown Rd', 'Longford', 'TA', '7301', 'http://www.pacificscientificco.com.au', '0417-815-258' UNION ALL
SELECT 'Lashonda', 'Langanke', 'lashonda@langanke.net.au', '03-9838-7533', 'Krausert, Diane D Esq', '667 S Highland Dr #4', 'Simson', 'VI', '3465', 'http://www.krausertdianedesq.com.au', '0491-793-730' UNION ALL
SELECT 'Patria', 'Popa', 'patria.popa@gmail.com', '02-6522-3993', 'Blaney Sheet Metal', '21 W 2nd St', 'Killabakh', 'NS', '2429', 'http://www.blaneysheetmetal.com.au', '0493-319-728' UNION ALL
SELECT 'Nidia', 'Horr', 'nidia@gmail.com', '07-8441-8214', 'Goodknight, David R', '2 W Henrietta Rd #6', 'Paluma', 'QL', '4816', 'http://www.goodknightdavidr.com.au', '0437-170-488' UNION ALL
SELECT 'Skye', 'Culcasi', 'skye_culcasi@hotmail.com', '03-9075-3104', 'Sullivan & Associates Ltd', '82655 Shawnee Mission Pky #5798', 'Barnawartha', 'VI', '3688', 'http://www.sullivanassociatesltd.com.au', '0451-601-420' UNION ALL
SELECT 'Kanisha', 'Reyelts', 'kreyelts@yahoo.com', '03-2921-8418', 'American Board Of Surgery', '9 Taylor Ave', 'Holwell', 'TA', '7275', 'http://www.americanboardofsurgery.com.au', '0423-358-965' UNION ALL
SELECT 'Hector', 'Barras', 'hector.barras@barras.com.au', '03-3017-8394', 'Vernon Manor Hotel', '62 J St #450', 'Combienbar', 'VI', '3889', 'http://www.vernonmanorhotel.com.au', '0438-431-666' UNION ALL
SELECT 'Stefan', 'Mongolo', 'stefan_mongolo@mongolo.net.au', '08-4563-6214', 'Keith Altizer & Company Pa', '2 Pennington St', 'Port Adelaide', 'SA', '5015', 'http://www.keithaltizercompanypa.com.au', '0495-777-435' UNION ALL
SELECT 'Francoise', 'Byon', 'francoise@hotmail.com', '08-3914-9404', 'H P Stran & Co', '5496 Ne Columbia Blvd', 'Klemzig', 'SA', '5087', 'http://www.hpstranco.com.au', '0430-357-187' UNION ALL
SELECT 'Lindy', 'Vandermeer', 'lindy@vandermeer.com.au', '07-9407-9202', 'Southern National Bank S Car', '4244 Lucas Creek Rd', 'Emu Park', 'QL', '4710', 'http://www.southernnationalbankscar.com.au', '0417-325-352' UNION ALL
SELECT 'Arthur', 'Diniz', 'arthur@gmail.com', '03-2517-3453', 'American Western Mortgage', '79819 Palmetto Ave', 'Travancore', 'VI', '3032', 'http://www.americanwesternmortgage.com.au', '0429-206-122' UNION ALL
SELECT 'Nicholle', 'Hulme', 'nicholle_hulme@hulme.com.au', '07-7144-4719', 'Oxner Vallerie', '7 N Glenn Rd', 'Whetstone', 'QL', '4387', 'http://www.oxnervallerie.com.au', '0476-915-729' UNION ALL
SELECT 'Tijuana', 'Mesch', 'tijuana_mesch@gmail.com', '07-1415-9307', 'Rochelle Cold Storage', '61 Center St #8', 'Corella', 'QL', '4570', 'http://www.rochellecoldstorage.com.au', '0444-393-673' UNION ALL
SELECT 'Lorenza', 'Schoenleber', 'lorenza.schoenleber@schoenleber.com.au', '08-8081-7779', 'Mail Boxes Etc', '562 Nw Cornell Rd', 'Humpty Doo', 'NT', '836', 'http://www.mailboxesetc.com.au', '0445-830-408' UNION ALL
SELECT 'Iola', 'Baird', 'ibaird@baird.net.au', '08-2325-5905', 'Xandex Inc', '48 General George Patton Dr #8611', 'Goode Beach', 'WA', '6330', 'http://www.xandexinc.com.au', '0482-635-206' UNION ALL
SELECT 'Sang', 'Weigner', 'sweigner@gmail.com', '03-8912-5755', 'Hander, Deborah G Esq', '9 W Passaic St', 'Heidelberg Rgh', 'VI', '3081', 'http://www.handerdeborahgesq.com.au', '0419-565-485' UNION ALL
SELECT 'Leonor', 'Prez', 'lprez@prez.com.au', '02-7463-8776', 'Vinco Furniture Inc', '968 Delaware Ave', 'Waterloo', 'NS', '2017', 'http://www.vincofurnitureinc.com.au', '0466-155-348' UNION ALL
SELECT 'Silvana', 'Whelpley', 'swhelpley@yahoo.com', '03-5175-6193', 'Stamp House', '548 Charmonie Ln', 'Minyip', 'VI', '3392', 'http://www.stamphouse.com.au', '0489-343-254' UNION ALL
SELECT 'Anthony', 'Stever', 'anthony.stever@hotmail.com', '07-7092-8542', 'Burton & Davis', '91114 Grand Ave', 'Hunchy', 'QL', '4555', 'http://www.burtondavis.com.au', '0495-801-419' UNION ALL
SELECT 'Wenona', 'Carmel', 'wenona@gmail.com', '02-2832-1545', 'Maier, Kristine M', '44 Bush St', 'Grosvenor Place', 'NS', '1220', 'http://www.maierkristinem.com.au', '0439-849-209' UNION ALL
SELECT 'Isadora', 'Yurick', 'iyurick@hotmail.com', '07-9595-6042', 'J M Edmunds Co Inc', '6 Mahler Rd', 'Pacific Paradise', 'QL', '4564', 'http://www.jmedmundscoinc.com.au', '0412-855-847' UNION ALL
SELECT 'Mose', 'Vonseggern', 'mose_vonseggern@hotmail.com', '07-5769-8004', 'Art Concepts', '1 E Main St', 'Hungerford', 'QL', '4493', 'http://www.artconcepts.com.au', '0467-531-601' UNION ALL
SELECT 'Marci', 'Aveline', 'marci.aveline@hotmail.com', '08-3342-3889', 'Richards, Don R Esq', '58 State St #998', 'Boya', 'WA', '6056', 'http://www.richardsdonresq.com.au', '0447-443-927' UNION ALL
SELECT 'Michel', 'Hoyne', 'michel@hoyne.com.au', '08-6183-9260', 'B & B Environmental Inc', '11408 Green St', 'Elizabeth West', 'SA', '5113', 'http://www.bbenvironmentalinc.com.au', '0481-466-206' UNION ALL
SELECT 'Stephania', 'Connon', 'stephania.connon@connon.com.au', '02-5725-5992', 'Printing Delite', '297 8th Ave S #9', 'Gumly Gumly', 'NS', '2652', 'http://www.printingdelite.com.au', '0416-443-185' UNION ALL
SELECT 'Charolette', 'Turk', 'cturk@yahoo.com', '08-4735-5054', 'Weil Mclain Co', '1 Wyckoff Ave', 'Wilmington', 'SA', '5485', 'http://www.weilmclainco.com.au', '0430-400-899' UNION ALL
SELECT 'Katie', 'Magro', 'katie_magro@gmail.com', '02-7265-9702', 'Jones, Andrew D Esq', '8 E North Ave', 'Pagewood', 'NS', '2035', 'http://www.jonesandrewdesq.com.au', '0439-832-641' UNION ALL
SELECT 'Inocencia', 'Angeron', 'inocencia.angeron@angeron.net.au', '03-6268-2647', 'South Adams Savings Bank', '13386 Tamarco Dr #20', 'Tawonga', 'VI', '3697', 'http://www.southadamssavingsbank.com.au', '0482-712-669' UNION ALL
SELECT 'Nikita', 'Novosel', 'nikita_novosel@novosel.net.au', '03-5716-1053', 'Universal Granite & Marble Inc', '70 W Market St #20', 'Hamlyn Heights', 'VI', '3215', 'http://www.universalgranitemarbleinc.com.au', '0470-886-805' UNION ALL
SELECT 'Malcolm', 'Gohlke', 'malcolm@yahoo.com', '07-9826-3950', 'Imagelink', '53247 Montgomery St #36', 'Southtown', 'QL', '4350', 'http://www.imagelink.com.au', '0450-887-422' UNION ALL
SELECT 'Desiree', 'Englund', 'denglund@gmail.com', '08-5289-4594', 'Wrrr Fm', '9495 Central Hwy #66', 'East Bowes', 'WA', '6535', 'http://www.wrrrfm.com.au', '0414-731-630' UNION ALL
SELECT 'Holley', 'Worland', 'holley.worland@hotmail.com', '02-9885-9593', 'Lord Aeck & Sargent Architects', '2 Route 9', 'Blue Haven', 'NS', '2262', 'http://www.lordaecksargentarchitects.com.au', '0469-808-491' UNION ALL
SELECT 'Maryann', 'Tates', 'mtates@yahoo.com', '08-1520-4093', 'Dalbec Agency Inc', '75700 Academy Rd', 'Cramphorne', 'WA', '6420', 'http://www.dalbecagencyinc.com.au', '0479-474-917' UNION ALL
SELECT 'Ling', 'Dibello', 'ling_dibello@yahoo.com', '07-1330-6750', 'Reese Press Inc', '6 Monte Ave', 'Beelbi Creek', 'QL', '4659', 'http://www.reesepressinc.com.au', '0444-175-406' UNION ALL
SELECT 'Hailey', 'Kopet', 'hailey_kopet@kopet.com.au', '07-3799-1667', 'Stokes, Fred J Esq', '5 France Ave S', 'Tanbar', 'QL', '4481', 'http://www.stokesfredjesq.com.au', '0443-979-875' UNION ALL
SELECT 'Farrah', 'Malboeuf', 'farrah@malboeuf.com.au', '03-7139-6376', 'Slachter, David Esq', '803 Tupper Ln', 'Ringwood', 'VI', '3134', 'http://www.slachterdavidesq.com.au', '0472-511-112' UNION ALL
SELECT 'Candra', 'Deritis', 'candra@deritis.net.au', '03-4231-3633', 'Girling Health Care Inc', '43 Nolan St', 'Battery Point', 'TA', '7004', 'http://www.girlinghealthcareinc.com.au', '0439-769-439' UNION ALL
SELECT 'Reuben', 'Hegland', 'reuben@yahoo.com', '02-1402-5215', 'Welders Supply Service Inc', '6 W 39th St', 'Milton', 'NS', '2538', 'http://www.welderssupplyserviceinc.com.au', '0489-476-500' UNION ALL
SELECT 'Anglea', 'Andrion', 'anglea.andrion@andrion.com.au', '07-3239-2830', 'Engelbrecht, William H Esq', '910 21st St', 'Laura', 'QL', '4871', 'http://www.engelbrechtwilliamhesq.com.au', '0442-946-694' UNION ALL
SELECT 'Paris', 'Tuccio', 'paris.tuccio@hotmail.com', '08-8868-2010', 'Nancy Brandon Realtor', '2677 S Jackson St', 'Kidman Park', 'SA', '5025', 'http://www.nancybrandonrealtor.com.au', '0417-281-870' UNION ALL
SELECT 'Latricia', 'Schmoyer', 'latricia_schmoyer@hotmail.com', '08-5444-3296', 'Flanagan Lieberman Hoffman', '6 Central Ave #4', 'Woodville', 'SA', '5011', 'http://www.flanaganliebermanhoffman.com.au', '0459-945-995' UNION ALL
SELECT 'Jeffrey', 'Leuenberger', 'jleuenberger@yahoo.com', '08-1267-4421', 'Walter W Lawrence Ink', '564 Almeria Ave #7474', 'Pedler Creek', 'SA', '5171', 'http://www.walterwlawrenceink.com.au', '0436-612-609' UNION ALL
SELECT 'Dean', 'Vollstedt', 'dvollstedt@vollstedt.com.au', '03-6776-1146', 'Ship It Packaging Inc', '4 Grand St', 'Muckleford South', 'VI', '3462', 'http://www.shipitpackaginginc.com.au', '0492-559-630' UNION ALL
SELECT 'Deane', 'Haag', 'dhaag@hotmail.com', '02-9718-2944', 'Malsbary Mfg Co', '9 Hamilton Blvd #299', 'Sydney South', 'NS', '1235', 'http://www.malsbarymfgco.com.au', '0453-828-758' UNION ALL
SELECT 'Edelmira', 'Pedregon', 'edelmira_pedregon@hotmail.com', '08-8484-3223', 'Independence Marine Corp', '50638 Northwest Blvd', 'Bandy Creek', 'WA', '6450', 'http://www.independencemarinecorp.com.au', '0454-458-365' UNION ALL
SELECT 'Andrew', 'Keks', 'andrew@gmail.com', '03-5251-3153', 'Anthonys', '51 Bridge Ave', 'Carwarp', 'VI', '3494', 'http://www.anthonys.com.au', '0499-155-325' UNION ALL
SELECT 'Miesha', 'Decelles', 'mdecelles@decelles.net.au', '03-5185-6258', 'L M H Inc', '457 St Sebastian Way #189', 'Eltham', 'VI', '3095', 'http://www.lmhinc.com.au', '0440-277-657' UNION ALL
SELECT 'Javier', 'Osmer', 'javier@osmer.com.au', '03-8369-6924', 'Milgo Industrial Inc', '6 Ackerman Rd', 'Doncaster East', 'VI', '3109', 'http://www.milgoindustrialinc.com.au', '0489-202-570' UNION ALL
SELECT 'Kizzy', 'Stangle', 'kizzy.stangle@yahoo.com', '08-1937-3980', 'Rogers, Clay M Esq', '8 W Lake St #1', 'Welbungin', 'WA', '6477', 'http://www.rogersclaymesq.com.au', '0474-218-755' UNION ALL
SELECT 'Sharan', 'Wodicka', 'sharan@wodicka.net.au', '08-4712-2157', 'Usa Asbestos Co', '8454 6  17 M At Bradleys', 'Shenton Park', 'WA', '6008', 'http://www.usaasbestosco.com.au', '0413-129-424' UNION ALL
SELECT 'Novella', 'Fritch', 'nfritch@fritch.com.au', '02-2612-1455', 'Voils, Otis V', '5 Ellestad Dr', 'Girraween', 'NS', '2145', 'http://www.voilsotisv.com.au', '0458-731-791' UNION ALL
SELECT 'German', 'Dones', 'german@gmail.com', '02-2393-3289', 'Oaz Communications', '9 N Nevada Ave', 'Woronora', 'NS', '2232', 'http://www.oazcommunications.com.au', '0495-882-447' UNION ALL
SELECT 'Robt', 'Blanck', 'robt.blanck@yahoo.com', '03-6517-9318', 'Elan Techlgy A Divsn Mansol', '790 E Wisconsin Ave', 'Woodbury', 'TA', '7120', 'http://www.elantechlgyadivsnmansol.com.au', '0415-690-961' UNION ALL
SELECT 'Rossana', 'Biler', 'rossana.biler@biler.net.au', '08-9855-2125', 'Norfolk County Newton Lung', '60481 N Clark St', 'Lee Point', 'NT', '810', 'http://www.norfolkcountynewtonlung.com.au', '0461-569-843' UNION ALL
SELECT 'Henriette', 'Gish', 'henriette.gish@gish.net.au', '03-9935-5135', 'Parker Bush & Lane Pc', '43 E Main St', 'Baranduda', 'VI', '3691', 'http://www.parkerbushlanepc.com.au', '0413-952-396' UNION ALL
SELECT 'Buffy', 'Stitely', 'buffy_stitely@stitely.com.au', '03-1600-5230', 'Stylecraft Corporation', '5 Madison St #4651', 'Police Point', 'TA', '7116', 'http://www.stylecraftcorporation.com.au', '0451-121-905' UNION ALL
SELECT 'Christiane', 'Osmanski', 'christiane@gmail.com', '08-9693-9052', 'Bennett, Matthew T Esq', '85 Nw Frontage Rd', 'Williamstown', 'WA', '6430', 'http://www.bennettmatthewtesq.com.au', '0418-813-310' UNION ALL
SELECT 'Annamae', 'Lothridge', 'alothridge@hotmail.com', '02-1919-3941', 'Highland Meadows Golf Club', '584 Meridian St #997', 'Civic Square', 'AC', '2608', 'http://www.highlandmeadowsgolfclub.com.au', '0495-759-817' UNION ALL
SELECT 'Vanesa', 'Glockner', 'vanesa@glockner.com.au', '07-7052-4547', 'Nelson, Michael J Esq', '28220 Park Avenue W', 'Taragoola', 'QL', '4680', 'http://www.nelsonmichaeljesq.com.au', '0496-610-278' UNION ALL
SELECT 'Gennie', 'Pastorino', 'gennie.pastorino@gmail.com', '08-4753-2870', 'Henry, Robert J Esq', '5 Austin Ave', 'Charleston', 'SA', '5244', 'http://www.henryrobertjesq.com.au', '0425-685-933' UNION ALL
SELECT 'Tamra', 'Kenfield', 'tkenfield@kenfield.com.au', '08-5614-9153', 'Mackraft Signs', '481 925n N #959', 'Kealy', 'WA', '6280', 'http://www.mackraftsigns.com.au', '0438-378-139' UNION ALL
SELECT 'Tien', 'Kinney', 'tien_kinney@kinney.com.au', '03-7767-6169', 'Orco State Empl Fed Crdt Un', '9 9th St #4', 'Lillimur', 'VI', '3420', 'http://www.orcostateemplfedcrdtun.com.au', '0468-244-186' UNION ALL
SELECT 'Malcom', 'Leja', 'malcom@leja.com.au', '03-2477-9133', 'Johnsen, Robert U Esq', '56232 Hohman Ave', 'Officer', 'VI', '3809', 'http://www.johnsenrobertuesq.com.au', '0412-417-394' UNION ALL
SELECT 'Claudia', 'Gawrych', 'claudia@gmail.com', '02-4246-3092', 'Abe Goldstein Ofc Furn', '3 Wall St #26', 'Lilli Pilli', 'NS', '2229', 'http://www.abegoldsteinofcfurn.com.au', '0465-885-293' UNION ALL
SELECT 'Page', 'Entzi', 'page@entzi.net.au', '03-2484-5500', 'Roland Ashcroft', '63154 Artesia Blvd', 'Blue Rocks', 'TA', '7255', 'http://www.rolandashcroft.com.au', '0497-335-342' UNION ALL
SELECT 'Lorita', 'Roches', 'lorita_roches@roches.net.au', '08-2358-3115', 'Village Meadows', '32 E Poythress St', 'Westminster', 'WA', '6061', 'http://www.villagemeadows.com.au', '0436-530-773' UNION ALL
SELECT 'Annita', 'Lek', 'annita.lek@lek.net.au', '08-3384-3181', 'Busada Manufacturing Corp', '86274 Howell Mill Rd Nw', 'Karama', 'NT', '812', 'http://www.busadamanufacturingcorp.com.au', '0426-888-203' UNION ALL
SELECT 'Eliseo', 'Mikovec', 'emikovec@mikovec.com.au', '02-9829-2371', 'Air Flow Co Inc', '25488 Brickell Ave', 'Ocean Shores', 'NS', '2483', 'http://www.airflowcoinc.com.au', '0497-955-472' UNION ALL
SELECT 'Tyisha', 'Layland', 'tyisha@yahoo.com', '08-2158-6758', 'Freitag Pc', '270 5th Ave', 'Eastwood', 'SA', '5063', 'http://www.freitagpc.com.au', '0490-478-206' UNION ALL
SELECT 'Colene', 'Tolbent', 'colene.tolbent@tolbent.net.au', '02-4376-1104', 'Saw Repair & Supply Co', '891 Union Pacific Ave #8463', 'Gloucester', 'NS', '2422', 'http://www.sawrepairsupplyco.com.au', '0466-541-467' UNION ALL
SELECT 'Francis', 'Senters', 'fsenters@gmail.com', '03-5933-7288', 'Middendorf Meat Quality Foods', '4562 Aurora Ave N', 'Heidelberg Rgh', 'VI', '3081', 'http://www.middendorfmeatqualityfoods.com.au', '0463-965-946' UNION ALL
SELECT 'Hester', 'Dollins', 'hester_dollins@gmail.com', '02-1622-6412', 'Eagle Plywood & Door Mfrs Inc', '4864 N 168th Ave', 'The Risk', 'NS', '2474', 'http://www.eagleplywooddoormfrsinc.com.au', '0473-268-319' UNION ALL
SELECT 'Susana', 'Baumgarter', 'susana.baumgarter@yahoo.com', '02-5410-5137', 'Leigh, Lewis R Esq', '7 Elm Ave', 'Yanco', 'NS', '2703', 'http://www.leighlewisresq.com.au', '0491-209-954' UNION ALL
SELECT 'Dahlia', 'Tummons', 'dahlia.tummons@gmail.com', '03-8216-8640', 'Bare Bones', '6508 Adams St #32', 'Port Fairy', 'VI', '3284', 'http://www.barebones.com.au', '0430-768-907' UNION ALL
SELECT 'Osvaldo', 'Falvey', 'osvaldo.falvey@yahoo.com', '07-4854-5045', 'Avila, Edward G Esq', '6434 Westchester Ave #28', 'Queenton', 'QL', '4820', 'http://www.avilaedwardgesq.com.au', '0437-545-265' UNION ALL
SELECT 'Armando', 'Barkley', 'armando.barkley@yahoo.com', '08-8161-8201', 'Oregon Handling Equip Co', '70680 S Rider Trl', 'Watercarrin', 'WA', '6407', 'http://www.oregonhandlingequipco.com.au', '0465-254-471' UNION ALL
SELECT 'Torie', 'Deras', 'torie_deras@yahoo.com', '07-8371-4719', 'Reynolds, Stephen R Esq', '700 Factory Ave #5649', 'Yeppoon', 'QL', '4703', 'http://www.reynoldsstephenresq.com.au', '0426-991-115' UNION ALL
SELECT 'Tamie', 'Hollimon', 'tamie@hollimon.com.au', '08-7046-5484', 'Credit Union Of The Rockies', '3 Cherokee St', 'Bobalong', 'WA', '6320', 'http://www.creditunionoftherockies.com.au', '0423-870-900' UNION ALL
SELECT 'Lettie', 'Hessenthaler', 'lettie_hessenthaler@hessenthaler.net.au', '03-5855-5156', 'Sullivan, John M Esq', '76542 W Bijou St', 'Wurdiboluc', 'VI', '3241', 'http://www.sullivanjohnmesq.com.au', '0454-956-810' UNION ALL
SELECT 'Chaya', 'Muhlbauer', 'chaya_muhlbauer@muhlbauer.net.au', '08-5943-4352', 'Henry D Lederman', '44009 W 63rd #269', 'North Dandalup', 'WA', '6207', 'http://www.henrydlederman.com.au', '0469-609-289' UNION ALL
SELECT 'Terina', 'Wildeboer', 'terina_wildeboer@wildeboer.com.au', '03-9107-7349', 'Burress, S Paige Esq', '462 Morris Ave', 'Seddon', 'VI', '3011', 'http://www.burressspaigeesq.com.au', '0438-810-326' UNION ALL
SELECT 'Lisbeth', 'Agney', 'lisbeth.agney@agney.net.au', '08-1184-4145', 'Dynetics', '1 El Camino Real #603', 'Hindmarsh', 'WA', '6462', 'http://www.dynetics.com.au', '0449-675-754' UNION ALL
SELECT 'Lillian', 'Dominique', 'lillian@hotmail.com', '07-3594-6592', 'West Pac Environmental Inc', '92417 Arbuckle Ct', 'Julia Creek', 'QL', '4823', 'http://www.westpacenvironmentalinc.com.au', '0490-548-561' UNION ALL
SELECT 'Corrina', 'Lindblom', 'clindblom@gmail.com', '08-7915-5110', 'Progressive Machine Co', '1 Westpark Dr', 'Salter Point', 'WA', '6152', 'http://www.progressivemachineco.com.au', '0463-118-373' UNION ALL
SELECT 'Dylan', 'Chaleun', 'dylan_chaleun@hotmail.com', '07-2319-2889', 'Berhanu International Foods', '5 Montana Ave', 'Lilydale', 'QL', '4344', 'http://www.berhanuinternationalfoods.com.au', '0412-631-864' UNION ALL
SELECT 'Jerrod', 'Luening', 'jerrod_luening@luening.com.au', '02-9554-9632', 'Mcmillan, Regina E Esq', '6629 Main St', 'Tea Gardens', 'NS', '2324', 'http://www.mcmillanreginaeesq.com.au', '0451-857-511' UNION ALL
SELECT 'Gracie', 'Vicente', 'gracie.vicente@hotmail.com', '03-2444-8291', 'Central Nebraska Home Care', '4 W 18th St', 'Oxley', 'VI', '3678', 'http://www.centralnebraskahomecare.com.au', '0420-776-847' UNION ALL
SELECT 'Barabara', 'Amedro', 'barabara@amedro.net.au', '02-3449-6894', 'Unicircuit Inc', '95412 16th St #6', 'Yallah', 'NS', '2530', 'http://www.unicircuitinc.com.au', '0467-209-469' UNION ALL
SELECT 'Delsie', 'Ducos', 'dducos@hotmail.com', '03-1361-8465', 'F H Overseas Export Inc', '17 Kamehameha Hwy', 'Cavendish', 'VI', '3314', 'http://www.fhoverseasexportinc.com.au', '0458-548-827' UNION ALL
SELECT 'Cassie', 'Digregorio', 'cdigregorio@digregorio.net.au', '02-7922-5417', 'Musgrave, R Todd Esq', '8650 S Valley View Bld #6941', 'Condobolin', 'NS', '2877', 'http://www.musgravertoddesq.com.au', '0433-677-495' UNION ALL
SELECT 'Tamekia', 'Kajder', 'tamekia_kajder@yahoo.com', '02-7498-8576', 'Santek Inc', '16 Talmadge Rd', 'West Tamworth', 'NS', '2340', 'http://www.santekinc.com.au', '0418-218-423' UNION ALL
SELECT 'Johanna', 'Saffer', 'johanna@yahoo.com', '02-5970-1748', 'Springer Industrial Equip Inc', '750 Lancaster Ave', 'Campsie', 'NS', '2194', 'http://www.springerindustrialequipinc.com.au', '0477-424-229' UNION ALL
SELECT 'Sharita', 'Kruk', 'sharita_kruk@gmail.com', '02-7386-4544', 'Long, Robert B Jr', '8808 Northern Blvd', 'Merrylands', 'NS', '2160', 'http://www.longrobertbjr.com.au', '0442-976-132' UNION ALL
SELECT 'Gerald', 'Chrusciel', 'gerald@chrusciel.net.au', '07-7446-6315', 'Prusax, Maximilian M Esq', '76596 Pleasant Hill Rd', 'Townsville Milpo', 'QL', '4813', 'http://www.prusaxmaximilianmesq.com.au', '0426-833-750' UNION ALL
SELECT 'Ardella', 'Dieterich', 'ardella.dieterich@yahoo.com', '07-3581-9462', 'Custom Jig Grinding', '94 Delta Fair Blvd #2702', 'Runnymede', 'QL', '4615', 'http://www.customjiggrinding.com.au', '0426-488-593' UNION ALL
SELECT 'Jackie', 'Kellebrew', 'jackie.kellebrew@kellebrew.com.au', '07-9840-6419', 'Senior Village Nursing Home', '25 Sw End Blvd #609', 'Coominya', 'QL', '4311', 'http://www.seniorvillagenursinghome.com.au', '0448-206-407' UNION ALL
SELECT 'Mabelle', 'Ramero', 'mabelle.ramero@ramero.net.au', '07-8857-6463', 'Mchale, Joseph G Esq', '15258 W Charleston Blvd', 'Aroona', 'QL', '4551', 'http://www.mchalejosephgesq.com.au', '0427-579-588' UNION ALL
SELECT 'Jonell', 'Biasi', 'jbiasi@biasi.net.au', '02-5095-2983', 'Pestmaster Services Inc', '75 Ryan Dr #70', 'Duramana', 'NS', '2795', 'http://www.pestmasterservicesinc.com.au', '0486-778-453' UNION ALL
SELECT 'Linwood', 'Wessner', 'linwood.wessner@hotmail.com', '03-6053-2447', 'Moorhead Associates Inc', '9634 South St', 'Saltwater River', 'TA', '7186', 'http://www.moorheadassociatesinc.com.au', '0487-913-509' UNION ALL
SELECT 'Samira', 'Heninger', 'sheninger@yahoo.com', '07-9512-2457', 'Alb Inc', '40490 Morrow St', 'Bluff', 'QL', '4702', 'http://www.albinc.com.au', '0443-539-658' UNION ALL
SELECT 'Julieta', 'Cropsey', 'julieta@yahoo.com', '07-4217-6258', 'Atrium Marketing Inc', '9 Commerce Cir', 'Kingaroy', 'QL', '4610', 'http://www.atriummarketinginc.com.au', '0420-286-404' UNION ALL
SELECT 'Serita', 'Barthlow', 'serita_barthlow@gmail.com', '08-2941-7378', 'Machine Design Service Inc', '190 34th St #8', 'Nangetty', 'WA', '6522', 'http://www.machinedesignserviceinc.com.au', '0493-703-129' UNION ALL
SELECT 'Tori', 'Tepley', 'tori@tepley.net.au', '02-2493-1870', 'Mcwhirter Realty Corp', '1036 Malone Rd', 'Uarbry', 'NS', '2329', 'http://www.mcwhirterrealtycorp.com.au', '0449-807-281' UNION ALL
SELECT 'Nancey', 'Whal', 'nancey@whal.net.au', '02-3248-3283', 'National Mortgage Co', '398 Fort Campbell Blvd #923', 'Cudgera Creek', 'NS', '2484', 'http://www.nationalmortgageco.com.au', '0426-612-418' UNION ALL
SELECT 'Wilbert', 'Beckes', 'wilbert@hotmail.com', '07-9178-6430', 'Alvis, John W Esq', '2799 Cajon Blvd', 'East Nanango', 'QL', '4615', 'http://www.alvisjohnwesq.com.au', '0455-947-547' UNION ALL
SELECT 'Werner', 'Hermens', 'whermens@hermens.net.au', '03-9085-5714', 'Community Health Law Project', '302 N 10th St #3896', 'Oakleigh South', 'VI', '3167', 'http://www.communityhealthlawproject.com.au', '0462-625-869' UNION ALL
SELECT 'Sunny', 'Catton', 'scatton@catton.com.au', '07-1217-9907', 'Highway Rentals Inc', '79346 Firestone Blvd', 'Gununa', 'QL', '4871', 'http://www.highwayrentalsinc.com.au', '0450-440-670' UNION ALL
SELECT 'Keva', 'Moehring', 'keva.moehring@moehring.net.au', '02-9187-4769', 'Rapid Reproductions Printing', '37564 Grace Ln', 'Salamander Bay', 'NS', '2317', 'http://www.rapidreproductionsprinting.com.au', '0448-465-944' UNION ALL
SELECT 'Mary', 'Dingler', 'mary.dingler@gmail.com', '07-3963-4469', 'Autocrat Inc', '470 W Irving Park Rd', 'Bundaberg North', 'QL', '4670', 'http://www.autocratinc.com.au', '0452-920-972' UNION ALL
SELECT 'Huey', 'Bukovac', 'huey.bukovac@hotmail.com', '08-5236-2143', 'Venino And Venino', '6 Jefferson St', 'Middleton', 'SA', '5213', 'http://www.veninoandvenino.com.au', '0486-924-555' UNION ALL
SELECT 'Antonio', 'Eighmy', 'antonio.eighmy@yahoo.com', '03-6144-7318', 'Corporex Companies Inc', '1758 Park Pl', 'Eaglemont', 'VI', '3084', 'http://www.corporexcompaniesinc.com.au', '0438-100-197' UNION ALL
SELECT 'Quinn', 'Weissbrodt', 'qweissbrodt@weissbrodt.com.au', '02-7239-9923', 'Economy Stainless Supl Co Inc', '7659 Market St', 'Premer', 'NS', '2381', 'http://www.economystainlesssuplcoinc.com.au', '0432-253-912' UNION ALL
SELECT 'Carin', 'Georgiades', 'cgeorgiades@gmail.com', '08-8343-3550', 'Dgstv Diseases Cnslnts', '95830 Webster Dr', 'Trott Park', 'SA', '5158', 'http://www.dgstvdiseasescnslnts.com.au', '0475-701-279' UNION ALL
SELECT 'Jill', 'Davoren', 'jill_davoren@davoren.net.au', '07-1698-9047', 'Broaches Inc', '26 Old William Penn Hwy', 'Boynewood', 'QL', '4626', 'http://www.broachesinc.com.au', '0468-451-905' UNION ALL
SELECT 'Sanjuana', 'Goodness', 'sgoodness@goodness.net.au', '02-2208-2711', 'Woods Manufactured Housing', '343 E Main St', 'Maraylya', 'NS', '2765', 'http://www.woodsmanufacturedhousing.com.au', '0436-444-424' UNION ALL
SELECT 'Elin', 'Koerner', 'elin_koerner@koerner.com.au', '08-5221-9700', 'Theos Software Corp', '8 Cabot Rd', 'Wayville', 'SA', '5034', 'http://www.theossoftwarecorp.com.au', '0472-281-671' UNION ALL
SELECT 'Charlena', 'Decamp', 'charlena@gmail.com', '08-7615-2416', 'Stanco Metal Products Inc', '8 Allied Dr', 'Burnside', 'WA', '6285', 'http://www.stancometalproductsinc.com.au', '0469-445-592' UNION ALL
SELECT 'Annette', 'Breyer', 'abreyer@hotmail.com', '07-5417-9612', 'Xyvision Inc', '26921 Vassar St', 'Daradgee', 'QL', '4860', 'http://www.xyvisioninc.com.au', '0484-806-405' UNION ALL
SELECT 'Alexis', 'Morguson', 'amorguson@morguson.com.au', '08-1895-1457', 'Carrera Casting Corp', '9 Old York Rd #418', 'Weetulta', 'SA', '5573', 'http://www.carreracastingcorp.com.au', '0475-760-952' UNION ALL
SELECT 'Princess', 'Saffo', 'princess_saffo@hotmail.com', '02-2656-6234', 'Asian Jewelry', '12398 Duluth St', 'Auburn', 'NS', '1835', 'http://www.asianjewelry.com.au', '0467-758-219' UNION ALL
SELECT 'Ashton', 'Sutherburg', 'asutherburg@gmail.com', '03-9215-3224', 'Southwark Corporation', '960 S Arroyo Pkwy', 'South Hobart', 'TA', '7004', 'http://www.southwarkcorporation.com.au', '0427-327-492' UNION ALL
SELECT 'Elmer', 'Redlon', 'elmer@hotmail.com', '02-1075-4690', 'Kdhl Am Radio', '53 Euclid Ave', 'Forbes', 'NS', '2871', 'http://www.kdhlamradio.com.au', '0463-757-229' UNION ALL
SELECT 'Aliza', 'Akiyama', 'aliza@yahoo.com', '02-9324-7803', 'Kelly, Charles G Esq', '700 Wilmson Rd', 'Forest Reefs', 'NS', '2798', 'http://www.kellycharlesgesq.com.au', '0445-609-538' UNION ALL
SELECT 'Ora', 'Handrick', 'ora.handrick@gmail.com', '03-8357-4617', 'Fennessey Buick Inc', '466 Hillsdale Ave', 'Rocklands', 'VI', '3401', 'http://www.fennesseybuickinc.com.au', '0411-111-689' UNION ALL
SELECT 'Brent', 'Ahlborn', 'bahlborn@ahlborn.com.au', '08-4563-9520', 'Apex Bottle Co', '86351 Pine Ave', 'Oaklands Park', 'SA', '5046', 'http://www.apexbottleco.com.au', '0492-994-709' UNION ALL
SELECT 'Tora', 'Telch', 'tora@telch.net.au', '08-8808-8104', 'Shamrock Food Service', '6139 Contractors Dr #450', 'Buckland Park', 'SA', '5120', 'http://www.shamrockfoodservice.com.au', '0429-419-390' UNION ALL
SELECT 'Hildred', 'Eilbeck', 'hildred_eilbeck@eilbeck.net.au', '08-2922-4115', 'Plastic Supply Inc', '83 Longhurst Rd', 'Longwood', 'SA', '5153', 'http://www.plasticsupplyinc.com.au', '0463-881-817' UNION ALL
SELECT 'Dante', 'Freiman', 'dante_freiman@freiman.net.au', '07-1964-4238', 'Gaylord', '76 Daylight Way #7', 'Varsity Lakes', 'QL', '4227', 'http://www.gaylord.com.au', '0432-682-937' UNION ALL
SELECT 'Emmanuel', 'Avera', 'emmanuel@yahoo.com', '02-1987-8525', 'Bank Of New York Na', '3883 N Central Ave', 'Appin', 'NS', '2560', 'http://www.bankofnewyorkna.com.au', '0498-489-459' UNION ALL
SELECT 'Keshia', 'Wasp', 'kwasp@wasp.net.au', '08-1683-9243', 'Cole, Gary D Esq', '75 E Main', 'Adelaide River', 'NT', '846', 'http://www.colegarydesq.com.au', '0439-885-729' UNION ALL
SELECT 'Sherman', 'Mahmud', 'sherman@mahmud.com.au', '02-2621-3361', 'Gencheff, Nelson E Do', '9 Memorial Pky Nw', 'Harris Park', 'NS', '2150', 'http://www.gencheffnelsonedo.com.au', '0468-488-918' UNION ALL
SELECT 'Lore', 'Brothers', 'lore@hotmail.com', '03-8780-3473', 'American General Finance', '70086 Division St #3', 'Kallista', 'VI', '3791', 'http://www.americangeneralfinance.com.au', '0449-337-116' UNION ALL
SELECT 'Shawn', 'Weibe', 'shawn@hotmail.com', '03-9480-9611', 'Feutz, James F Esq', '4 Middletown Blvd #33', 'Camena', 'TA', '7316', 'http://www.feutzjamesfesq.com.au', '0456-595-946' UNION ALL
SELECT 'Karima', 'Cheever', 'karima_cheever@hotmail.com', '02-5977-8561', 'Kwik Kopy Printing & Copying', '20907 65s S', 'Woodberry', 'NS', '2322', 'http://www.kwikkopyprintingcopying.com.au', '0416-963-557' UNION ALL
SELECT 'Francesco', 'Kloos', 'fkloos@kloos.com.au', '08-1687-4873', 'Borough Clerk', '82136 Post Rd', 'Rocky Gully', 'WA', '6397', 'http://www.boroughclerk.com.au', '0420-185-206' UNION ALL
SELECT 'King', 'Picton', 'king@hotmail.com', '08-7605-2080', 'U S Rentals', '3 W Pioneer Dr', 'Preston Beach', 'WA', '6215', 'http://www.usrentals.com.au', '0468-322-703' UNION ALL
SELECT 'Mica', 'Simco', 'msimco@gmail.com', '07-1037-3391', 'Katz Brothers Market Inc', '5610 Holliday Rd', 'Brigalow', 'QL', '4412', 'http://www.katzbrothersmarketinc.com.au', '0471-169-302' UNION ALL
SELECT 'Lamonica', 'Princiotta', 'lamonica@hotmail.com', '08-5227-2620', 'Grossman Tuchman & Shah', '29133 Hammond Dr #1', 'Beermullah', 'WA', '6503', 'http://www.grossmantuchmanshah.com.au', '0425-628-359' UNION ALL
SELECT 'Curtis', 'Ware', 'curtis@ware.net.au', '08-6278-9532', 'American Inst Muscl Studies', '51 Greenwood Ave', 'Ridgewood', 'WA', '6030', 'http://www.americaninstmusclstudies.com.au', '0484-331-585' UNION ALL
SELECT 'Sabrina', 'Rabena', 'sabrina_rabena@hotmail.com', '03-5662-3542', 'Joyces Submarine Sandwiches', '327 Ward Pky', 'Bayles', 'VI', '3981', 'http://www.joycessubmarinesandwiches.com.au', '0486-768-529' UNION ALL
SELECT 'Denae', 'Saeteun', 'denae_saeteun@hotmail.com', '03-2802-7434', 'Domurad, John M Esq', '52680 W Hwy 55 #59', 'Moorabbin Airport', 'VI', '3194', 'http://www.domuradjohnmesq.com.au', '0410-539-386' UNION ALL
SELECT 'Anastacia', 'Carranzo', 'anastacia@yahoo.com', '02-6078-3417', 'Debbies Golden Touch', '654 Se 29th St', 'Waratah West', 'NS', '2298', 'http://www.debbiesgoldentouch.com.au', '0481-193-115' UNION ALL
SELECT 'Irving', 'Plocica', 'irving@hotmail.com', '03-9050-2741', 'Johnston, George M Esq', '65 Clayton Rd', 'Cullulleraine', 'VI', '3496', 'http://www.johnstongeorgemesq.com.au', '0465-434-187' UNION ALL
SELECT 'Elenor', 'Siefken', 'elenor.siefken@yahoo.com', '07-5085-8138', 'Chateau Sonesta Hotel', '136 2nd Ave N', 'Cairns City', 'QL', '4870', 'http://www.chateausonestahotel.com.au', '0419-509-353' UNION ALL
SELECT 'Mary', 'Irene', 'mirene@gmail.com', '08-8012-6469', 'Superior Trading Co', '3 N Michigan Ave', 'Warding East', 'WA', '6405', 'http://www.superiortradingco.com.au', '0411-620-740' UNION ALL
SELECT 'Crista', 'Padua', 'crista_padua@gmail.com', '02-9472-5814', 'Breathitt Fnrl Home & Mnmt Co', '1607 Laurel St', 'North Haven', 'NS', '2443', 'http://www.breathittfnrlhomemnmtco.com.au', '0471-602-916' UNION ALL
SELECT 'Lawana', 'Yuasa', 'lawana_yuasa@yuasa.net.au', '03-2324-3472', 'Viking Lodge', '77818 Prince Drew Rd', 'Cape Paterson', 'VI', '3995', 'http://www.vikinglodge.com.au', '0456-330-756' UNION ALL
SELECT 'Maryrose', 'Cove', 'mcove@hotmail.com', '02-8010-8344', 'Brown Bear Bait Company', '1 Vogel Rd', 'Cabramatta', 'NS', '2166', 'http://www.brownbearbaitcompany.com.au', '0440-811-454' UNION ALL
SELECT 'Lindsey', 'Rathmann', 'lindsey_rathmann@rathmann.com.au', '08-1269-1489', 'Pakzad Advertising', '5 Main St', 'Kongorong', 'SA', '5291', 'http://www.pakzadadvertising.com.au', '0499-741-651' UNION ALL
SELECT 'Lynelle', 'Koury', 'lynelle.koury@koury.net.au', '03-5213-8219', 'Jean Barbara Ltd', '7696 Carey Ave', 'Digby', 'VI', '3309', 'http://www.jeanbarbaraltd.com.au', '0462-987-152' UNION ALL
SELECT 'Brice', 'Bogacz', 'bbogacz@hotmail.com', '08-5203-2193', 'Thurmon, Steven P', '76 San Pablo Ave', 'Sedan', 'SA', '5353', 'http://www.thurmonstevenp.com.au', '0467-821-930' UNION ALL
SELECT 'Laine', 'Killean', 'laine@gmail.com', '03-2813-6426', 'Bussard, Vicki L Esq', '767 9th Ave Sw', 'Braybrook', 'VI', '3019', 'http://www.bussardvickilesq.com.au', '0411-276-383' UNION ALL
SELECT 'Rachael', 'Crawley', 'rachael@gmail.com', '08-2089-8553', 'Stamell Tabacco & Schager', '82 Hopkins Plz', 'Inkpen', 'WA', '6302', 'http://www.stamelltabaccoschager.com.au', '0459-738-842' UNION ALL
SELECT 'Della', 'Selestewa', 'della.selestewa@gmail.com', '02-4885-8382', 'Aztech Controls Inc', '64 Prairie Ave', 'Gillieston Heights', 'NS', '2321', 'http://www.aztechcontrolsinc.com.au', '0456-162-659' UNION ALL
SELECT 'Thomasena', 'Graziosi', 'thomasena@gmail.com', '08-4849-4417', 'Hutchinson Inc', '5 Jackson St', 'Neerabup', 'WA', '6031', 'http://www.hutchinsoninc.com.au', '0434-497-618' UNION ALL
SELECT 'Frederic', 'Schimke', 'fschimke@schimke.com.au', '03-4829-5695', 'Curtis & Curtis Inc', '705 Stanwix St', 'Mount Martha', 'VI', '3934', 'http://www.curtiscurtisinc.com.au', '0435-982-307' UNION ALL
SELECT 'Halina', 'Dellen', 'halina.dellen@dellen.com.au', '08-6742-2308', 'Roane, Matthew H Esq', '3318 Buckelew Ave', 'Appila', 'SA', '5480', 'http://www.roanematthewhesq.com.au', '0478-235-293' UNION ALL
SELECT 'Ryann', 'Riston', 'ryann@hotmail.com', '07-9920-3550', 'Best Western Gloucester Inn', '38494 Port Reading Ave', 'Milton', 'QL', '4064', 'http://www.bestwesterngloucesterinn.com.au', '0423-341-752' UNION ALL
SELECT 'Shawn', 'Vugteveen', 'svugteveen@vugteveen.net.au', '07-3103-8372', 'Shine', '81 Us Highway 9', 'Etty Bay', 'QL', '4858', 'http://www.shine.com.au', '0480-561-819' UNION ALL
SELECT 'Leah', 'Milsap', 'leah@milsap.com.au', '08-4040-9192', 'Schwartz, Seymour I Md', '45 Mountain View Ave', 'Lower Hermitage', 'SA', '5131', 'http://www.schwartzseymourimd.com.au', '0452-193-155' UNION ALL
SELECT 'Ira', 'Zihal', 'ira.zihal@yahoo.com', '07-4724-9987', 'American Express Publshng Corp', '6 W Meadow St', 'Degilbo', 'QL', '4621', 'http://www.americanexpresspublshngcorp.com.au', '0466-603-340' UNION ALL
SELECT 'Paris', 'Kinnison', 'paris.kinnison@gmail.com', '07-4518-4450', 'Saratoga Land Office', '2 Old Corlies Ave', 'Eastern Heights', 'QL', '4305', 'http://www.saratogalandoffice.com.au', '0454-257-906' UNION ALL
SELECT 'Shayne', 'Sundahl', 'shayne.sundahl@gmail.com', '08-8587-1196', 'Jaywork, John Terence Esq', '5614 Public Sq', 'Normanville', 'SA', '5204', 'http://www.jayworkjohnterenceesq.com.au', '0443-386-213' UNION ALL
SELECT 'Ernestine', 'Paavola', 'ernestine.paavola@paavola.com.au', '08-1140-6357', 'Northbros Co Divsn Natl Svc', '6 E Gloria Switch Rd #96', 'Yorkrakine', 'WA', '6409', 'http://www.northbroscodivsnnatlsvc.com.au', '0414-354-955' UNION ALL
SELECT 'Eleonore', 'Everline', 'eeverline@hotmail.com', '03-5355-5505', 'Psychotherapy Associates', '1 Us Highway 206', 'Kialla East', 'VI', '3631', 'http://www.psychotherapyassociates.com.au', '0497-442-813' UNION ALL
SELECT 'Misty', 'Leriche', 'mleriche@yahoo.com', '07-5486-1002', 'K J N Advertising Inc', '5289 Ramblewood Dr', 'Glen Boughton', 'QL', '4871', 'http://www.kjnadvertisinginc.com.au', '0414-661-490' UNION ALL
SELECT 'Na', 'Hodges', 'na_hodges@hotmail.com', '08-8215-1588', 'Automatic Feed Co', '5 Aquarium Pl #1', 'Ongerup', 'WA', '6336', 'http://www.automaticfeedco.com.au', '0444-777-459' UNION ALL
SELECT 'Juan', 'Knudtson', 'juan@gmail.com', '03-9173-6140', 'Newton Clerk', '466 Lincoln Blvd', 'Clunes', 'VI', '3370', 'http://www.newtonclerk.com.au', '0474-730-764' UNION ALL
SELECT 'Gerald', 'Kloepper', 'gerald@yahoo.com', '07-4297-4607', 'Pleasantville Finance Dept', '42 United Dr', 'Pierces Creek', 'QL', '4355', 'http://www.pleasantvillefinancedept.com.au', '0437-819-518' UNION ALL
SELECT 'Desmond', 'Tarkowski', 'desmond_tarkowski@hotmail.com', '07-6793-5954', 'Body Part Connection', '5920 E Arapahoe Rd', 'Andergrove', 'QL', '4740', 'http://www.bodypartconnection.com.au', '0445-121-372' UNION ALL
SELECT 'Tommy', 'Gennusa', 'tommy@hotmail.com', '02-5444-1961', 'Cooper And Raley', '2 New Brooklyn Rd', 'Concord West', 'NS', '2138', 'http://www.cooperandraley.com.au', '0498-290-826' UNION ALL
SELECT 'Adrianna', 'Poncio', 'adrianna@poncio.com.au', '07-6113-9653', 'H T Communications Group Ltd', '9 34th Ave #69', 'Bethania', 'QL', '4205', 'http://www.htcommunicationsgroupltd.com.au', '0432-130-553' UNION ALL
SELECT 'Adaline', 'Galagher', 'adaline.galagher@galagher.com.au', '02-3225-1954', 'Debbie Reynolds Hotel', '32716 N Michigan Ave #82', 'Barooga', 'NS', '3644', 'http://www.debbiereynoldshotel.com.au', '0416-156-336' UNION ALL
SELECT 'Tammi', 'Schiavi', 'tammi.schiavi@hotmail.com', '08-9707-2679', 'Crew, Robert B Esq', '78 Sw Beaverton Hillsdale H', 'Willetton', 'WA', '6155', 'http://www.crewrobertbesq.com.au', '0425-809-254' UNION ALL
SELECT 'Virgilio', 'Phay', 'vphay@phay.com.au', '08-8147-9584', 'Reef Encrustaceans', '8494 E 57th St', 'Stratton', 'WA', '6056', 'http://www.reefencrustaceans.com.au', '0460-368-567' UNION ALL
SELECT 'Emeline', 'Sotelo', 'emeline@gmail.com', '07-7240-6480', 'Reporters Inc', '46 Broadway St', 'Elimbah', 'QL', '4516', 'http://www.reportersinc.com.au', '0451-790-704' UNION ALL
SELECT 'Marcos', 'Seniff', 'marcos_seniff@gmail.com', '03-6340-5010', 'Arizona Equipment Trnsprt Inc', '228 S Tyler St', 'Emerald', 'VI', '3782', 'http://www.arizonaequipmenttrnsprtinc.com.au', '0464-786-310' UNION ALL
SELECT 'Yuonne', 'Carabajal', 'ycarabajal@carabajal.com.au', '08-7432-4632', 'Hub Manufacturing Company Inc', '2714 Beach Blvd', 'Changerup', 'WA', '6394', 'http://www.hubmanufacturingcompanyinc.com.au', '0470-345-731' UNION ALL
SELECT 'Gladis', 'Kazemi', 'gkazemi@kazemi.net.au', '07-6444-3666', 'Dippin Flavors', '3266 Welsh Rd', 'Varsity Lakes', 'QL', '4227', 'http://www.dippinflavors.com.au', '0444-157-156' UNION ALL
SELECT 'Muriel', 'Drozdowski', 'muriel_drozdowski@hotmail.com', '07-5686-8088', 'Harfred Oil Co', '1 S Maryland Pky', 'Durham Downs', 'QL', '4454', 'http://www.harfredoilco.com.au', '0473-213-595' UNION ALL
SELECT 'Juliann', 'Dammeyer', 'juliann@gmail.com', '08-3562-8644', 'Wilheim, Kari A Esq', '6 De Belier Rue', 'Bouvard', 'WA', '6210', 'http://www.wilheimkariaesq.com.au', '0492-961-209' UNION ALL
SELECT 'Reiko', 'Dejarme', 'rdejarme@dejarme.net.au', '08-3733-5261', 'Gilardis Frozen Food', '57869 Alemany Blvd', 'Bentley Dc', 'WA', '6983', 'http://www.gilardisfrozenfood.com.au', '0414-715-583' UNION ALL
SELECT 'Verdell', 'Garness', 'verdell.garness@yahoo.com', '02-6291-7620', 'Ronald Massingill Pc', '39 Plummer St', 'Thornton', 'NS', '2322', 'http://www.ronaldmassingillpc.com.au', '0474-367-875' UNION ALL
SELECT 'Arleen', 'Kane', 'arleen.kane@hotmail.com', '07-3476-2066', 'Colosi, Darryl J Esq', '78717 Graves Ln', 'Eagle Farm', 'QL', '4009', 'http://www.colosidarryljesq.com.au', '0430-271-168' UNION ALL
SELECT 'Launa', 'Vanauken', 'launa@gmail.com', '08-9808-2647', 'Tripuraneni, Prabhakar Md', '30338 S Dunworth St', 'Peake', 'SA', '5301', 'http://www.tripuraneniprabhakarmd.com.au', '0423-125-880' UNION ALL
SELECT 'Casandra', 'Gordis', 'casandra_gordis@gordis.com.au', '02-5808-6388', 'Carlyle Abstract Co', '6 Walnut St', 'Chippendale', 'NS', '2008', 'http://www.carlyleabstractco.com.au', '0418-327-906' UNION ALL
SELECT 'Julio', 'Puccini', 'julio@gmail.com', '02-5632-9914', 'Streator Onized Fed Crdt Un', '2244 Franquette Ave', 'Gorokan', 'NS', '2263', 'http://www.streatoronizedfedcrdtun.com.au', '0452-766-262' UNION ALL
SELECT 'Alica', 'Alerte', 'aalerte@alerte.com.au', '02-6974-7785', 'Valley Hi Bank', '9892 Hernando W', 'Grevillia', 'NS', '2474', 'http://www.valleyhibank.com.au', '0423-831-803' UNION ALL
SELECT 'Karol', 'Sarkissian', 'ksarkissian@yahoo.com', '02-3490-2407', 'Pep Boys Manny Moe & Jack', '9296 Prince Rodgers Ave', 'Chatsworth', 'NS', '2469', 'http://www.pepboysmannymoejack.com.au', '0419-430-467' UNION ALL
SELECT 'Wava', 'Ochs', 'wava.ochs@gmail.com', '02-1222-7812', 'Knights Inn', '9 Chandler Ave #355', 'Bawley Point', 'NS', '2539', 'http://www.knightsinn.com.au', '0445-285-375' UNION ALL
SELECT 'Felicitas', 'Gong', 'fgong@gong.com.au', '07-8516-6453', 'Telcom Communication Center', '173 Howard Ave', 'Weengallon', 'QL', '4497', 'http://www.telcomcommunicationcenter.com.au', '0470-655-661' UNION ALL
SELECT 'Jamie', 'Kushnir', 'jamie@kushnir.net.au', '02-4623-8120', 'Bell Electric Co', '3216 W Wabansia Ave', 'Tuggeranong Dc', 'AC', '2901', 'http://www.bellelectricco.com.au', '0426-830-817' UNION ALL
SELECT 'Fidelia', 'Dampier', 'fidelia_dampier@gmail.com', '02-8035-9997', 'Signs Now', '947 W Harrison St #640', 'Dangar Island', 'NS', '2083', 'http://www.signsnow.com.au', '0478-179-538' UNION ALL
SELECT 'Kris', 'Medich', 'kris.medich@hotmail.com', '03-6589-2556', 'Chieftain Four Inc', '94843 Trabold Rd #59', 'Shannon', 'TA', '7030', 'http://www.chieftainfourinc.com.au', '0469-243-477' UNION ALL
SELECT 'Lashawna', 'Filan', 'lashawna.filan@filan.net.au', '08-6937-4366', 'South Carolina State Housing F', '8 Lincoln Way W #6698', 'Greenhills', 'WA', '6302', 'http://www.southcarolinastatehousingf.com.au', '0488-276-458' UNION ALL
SELECT 'Lachelle', 'Andrzejewski', 'lachelle.andrzejewski@andrzejewski.com.au', '02-3416-9617', 'Lucas Cntrl Systems Prod Deeco', '262 Montauk Blvd', 'Cherrybrook', 'NS', '2126', 'http://www.lucascntrlsystemsproddeeco.com.au', '0453-493-910' UNION ALL
SELECT 'Katy', 'Saltourides', 'katy_saltourides@yahoo.com', '02-3003-1369', 'J C S Iron Works Inc', '5040 Teague Rd #65', 'Junee', 'NS', '2663', 'http://www.jcsironworksinc.com.au', '0481-278-876' UNION ALL
SELECT 'Bettyann', 'Fernades', 'bettyann@fernades.com.au', '08-2901-3421', 'Lsr Pokorny Schwartz Friedman', '54648 Hylan Blvd #883', 'Tibradden', 'WA', '6532', 'http://www.lsrpokornyschwartzfriedman.com.au', '0427-971-504' UNION ALL
SELECT 'Valda', 'Levay', 'vlevay@levay.net.au', '08-2401-5672', 'Branom Instrument Co', '7463 Elmwood Park Blvd', 'Tungkillo', 'SA', '5236', 'http://www.branominstrumentco.com.au', '0434-637-971' UNION ALL
SELECT 'Lynette', 'Beaureguard', 'lynette.beaureguard@hotmail.com', '07-6679-3722', 'Young, Craig C Md', '630 E Plano Pky', 'Tarawera', 'QL', '4494', 'http://www.youngcraigcmd.com.au', '0417-544-301' UNION ALL
SELECT 'Victor', 'Laroia', 'victor@laroia.net.au', '02-8156-6969', 'Midwest Marketing Inc', '166 N Maple Dr', 'Scotts Head', 'NS', '2447', 'http://www.midwestmarketinginc.com.au', '0421-987-667' UNION ALL
SELECT 'Pa', 'Badgero', 'pa_badgero@badgero.com.au', '03-1861-5074', 'Korolishin, Michael Esq', '20 Meadow Ln', 'Pakenham Upper', 'VI', '3810', 'http://www.korolishinmichaelesq.com.au', '0480-433-145' UNION ALL
SELECT 'Dorathy', 'Miskelly', 'dorathy.miskelly@gmail.com', '03-6340-9772', 'Perrysburg Animal Care Inc', '73 Robert S', 'Westerway', 'TA', '7140', 'http://www.perrysburganimalcareinc.com.au', '0432-706-521' UNION ALL
SELECT 'Rodrigo', 'Schuh', 'rodrigo_schuh@gmail.com', '02-3869-4096', 'Hospitality Design Group', '512 E Idaho St', 'Burrier', 'NS', '2540', 'http://www.hospitalitydesigngroup.com.au', '0430-503-397' UNION ALL
SELECT 'Stanford', 'Waganer', 'stanford_waganer@waganer.net.au', '08-3200-1670', 'Ciba Geigy Corp', '98021 Harwin Dr', 'East Nabawa', 'WA', '6532', 'http://www.cibageigycorp.com.au', '0479-127-500' UNION ALL
SELECT 'Michael', 'Orehek', 'michael_orehek@gmail.com', '02-1919-1709', 'Robinson, Michael C Esq', '892 Sw Broadway #8', 'Millers Point', 'NS', '2000', 'http://www.robinsonmichaelcesq.com.au', '0482-613-598' UNION ALL
SELECT 'Ines', 'Tokich', 'ines_tokich@tokich.net.au', '07-5017-7337', 'De Woskin, Alan E Esq', '192 N Sheffield Ave', 'Bunya Mountains', 'QL', '4405', 'http://www.dewoskinalaneesq.com.au', '0481-799-605' UNION ALL
SELECT 'Dorinda', 'Markoff', 'dorinda_markoff@hotmail.com', '02-6529-9317', 'Alumi Span Inc', '5 Columbia Pike', 'Mayfield East', 'NS', '2304', 'http://www.alumispaninc.com.au', '0412-153-776' UNION ALL
SELECT 'Clarence', 'Gabbert', 'clarence.gabbert@gmail.com', '02-4776-1384', 'M C Publishing', '35983 Daubert St', 'Verges Creek', 'NS', '2440', 'http://www.mcpublishing.com.au', '0486-302-652' UNION ALL
SELECT 'Omer', 'Radel', 'omer_radel@radel.net.au', '08-9919-9540', 'Phoenix Marketing Rep Inc', '678 S Main St', 'Hill River', 'WA', '6521', 'http://www.phoenixmarketingrepinc.com.au', '0439-808-753' UNION ALL
SELECT 'Winifred', 'Kingshott', 'winifred.kingshott@yahoo.com', '02-5318-1342', 'Remc South Eastern', '532 Saint Marks Ct', 'Marshdale', 'NS', '2420', 'http://www.remcsoutheastern.com.au', '0471-558-187' UNION ALL
SELECT 'Theresia', 'Salomone', 'theresia_salomone@gmail.com', '07-8250-2277', 'Curran, Carol N Esq', '1337 N 26th St', 'Bundall', 'QL', '4217', 'http://www.currancarolnesq.com.au', '0437-687-429' UNION ALL
SELECT 'Daisy', 'Kearsey', 'dkearsey@yahoo.com', '08-2127-5977', 'Faber Castell Corporation', '556 Bernardo Cent', 'Mount Nasura', 'WA', '6112', 'http://www.fabercastellcorporation.com.au', '0455-503-406' UNION ALL
SELECT 'Aretha', 'Bodle', 'aretha_bodle@hotmail.com', '08-7385-2716', 'Palmetto Food Equipment Co Inc', '9561 Chartres St', 'Parndana', 'SA', '5220', 'http://www.palmettofoodequipmentcoinc.com.au', '0481-452-729' UNION ALL
SELECT 'Bettina', 'Diciano', 'bdiciano@diciano.com.au', '02-3566-7608', 'Greater Ky Corp', '11999 Main St', 'Dripstone', 'NS', '2820', 'http://www.greaterkycorp.com.au', '0472-631-448' UNION ALL
SELECT 'Omega', 'Mangino', 'omega.mangino@hotmail.com', '03-6623-5501', 'Kajo 1270 Am Radio', '495 Distribution Dr #996', 'Gnotuk', 'VI', '3260', 'http://www.kajoamradio.com.au', '0422-968-757' UNION ALL
SELECT 'Dana', 'Vock', 'dana_vock@yahoo.com', '02-6689-1150', 'Fried, Monte Esq', '49 Walnut St', 'Yarralumla', 'AC', '2600', 'http://www.friedmonteesq.com.au', '0411-398-917' UNION ALL
SELECT 'Naomi', 'Tuamoheloa', 'naomi@yahoo.com', '08-6137-1726', 'Dayer Real Estate Group', '85 S Washington Ave', 'Muja', 'WA', '6225', 'http://www.dayerrealestategroup.com.au', '0430-962-223' UNION ALL
SELECT 'Luis', 'Yerry', 'luis@hotmail.com', '03-4492-4927', 'On Your Feet', '72984 W 1st St', 'Summerhill', 'TA', '7250', 'http://www.onyourfeet.com.au', '0490-571-461' UNION ALL
SELECT 'Dominga', 'Barchacky', 'dominga.barchacky@hotmail.com', '08-3087-9658', 'South Side Machine Works Inc', '3 Ridge Rd W #949', 'Port Flinders', 'SA', '5495', 'http://www.southsidemachineworksinc.com.au', '0412-225-824' UNION ALL
SELECT 'Isreal', 'Calizo', 'isreal_calizo@gmail.com', '02-3494-3282', 'Milner Inn', '2 Landmeier Rd', 'Wombeyan Caves', 'NS', '2580', 'http://www.milnerinn.com.au', '0455-472-994' UNION ALL
SELECT 'Myrtie', 'Korba', 'mkorba@hotmail.com', '08-3174-2706', 'United Mortgage', '82 W Market St', 'Dartnall', 'WA', '6320', 'http://www.unitedmortgage.com.au', '0412-679-832' UNION ALL
SELECT 'Jodi', 'Naifeh', 'jodi@hotmail.com', '02-6193-5184', 'Cahill, Steven J Esq', '89 N Himes Ave', 'Dural', 'NS', '2330', 'http://www.cahillstevenjesq.com.au', '0488-646-644' UNION ALL
SELECT 'Pearly', 'Hedstrom', 'pearly@gmail.com', '08-3412-6699', 'G Whitfield Richards Co', '62296 S Elliott Rd #2', 'Wandering', 'WA', '6308', 'http://www.gwhitfieldrichardsco.com.au', '0460-335-582' UNION ALL
SELECT 'Aileen', 'Menez', 'aileen_menez@menez.net.au', '08-1196-2822', 'Cuzzo, Michael J Esq', '8 S Main St', 'Manjimup', 'WA', '6258', 'http://www.cuzzomichaeljesq.com.au', '0495-852-298' UNION ALL
SELECT 'Glory', 'Carlo', 'glory_carlo@gmail.com', '07-9265-7183', 'Swanson Travel', '50808 A Pamalee Dr', 'Grange', 'QL', '4051', 'http://www.swansontravel.com.au', '0490-570-424' UNION ALL
SELECT 'Kathrine', 'Francoise', 'kathrine@yahoo.com', '03-8791-9436', 'Jackson, Brian C', '30691 Poplar Ave #4', 'Indented Head', 'VI', '3223', 'http://www.jacksonbrianc.com.au', '0449-461-650' UNION ALL
SELECT 'Domingo', 'Mckale', 'domingo_mckale@mckale.net.au', '08-9919-7850', 'Fables Gallery', '80968 Armitage Ave', 'Marla', 'SA', '5724', 'http://www.fablesgallery.com.au', '0418-290-707' UNION ALL
SELECT 'Julian', 'Laprade', 'jlaprade@laprade.net.au', '07-2627-9976', 'Forsyth Steel Co', '5 Pittsburg St', 'Mungabunda', 'QL', '4718', 'http://www.forsythsteelco.com.au', '0419-587-898' UNION ALL
SELECT 'Marylou', 'Lofts', 'marylou_lofts@lofts.com.au', '03-1765-4584', 'Lally, Lawrence D Esq', '812 Berry Blvd #96', 'Houston', 'VI', '3128', 'http://www.lallylawrencedesq.com.au', '0473-727-909' UNION ALL
SELECT 'Louis', 'Brueck', 'louis.brueck@brueck.net.au', '08-5228-3628', 'Sassy Lassie Dolls', '73 12th St', 'Larrakeyah', 'NT', '820', 'http://www.sassylassiedolls.com.au', '0471-229-188' UNION ALL
SELECT 'Ellsworth', 'Guenther', 'eguenther@hotmail.com', '03-2749-1381', 'Performance Consulting Grp Inc', '27730 American Ave', 'Docklands', 'VI', '3008', 'http://www.performanceconsultinggrpinc.com.au', '0442-173-327' UNION ALL
SELECT 'Wilburn', 'Lary', 'wlary@lary.net.au', '08-1042-4275', 'Padrick, Comer W Jr', '72 Park Ave', 'Gabbadah', 'WA', '6041', 'http://www.padrickcomerwjr.com.au', '0431-743-155' UNION ALL
SELECT 'Arlie', 'Borra', 'arlie.borra@gmail.com', '02-1211-3823', 'Analytical Laboratories', '59215 W 80th St', 'Morundah', 'NS', '2700', 'http://www.analyticallaboratories.com.au', '0423-740-512' UNION ALL
SELECT 'Alysa', 'Lehoux', 'alysa@hotmail.com', '02-1385-3480', 'Signs Of The Times', '186 Geary Blvd #923', 'Trungley Hall', 'NS', '2666', 'http://www.signsofthetimes.com.au', '0475-366-466' UNION ALL
SELECT 'Marilynn', 'Herrera', 'marilynn.herrera@herrera.net.au', '03-1447-7041', 'Brown, Alan Esq', '717 Midway Pl', 'Tawonga', 'VI', '3697', 'http://www.brownalanesq.com.au', '0474-199-825' UNION ALL
SELECT 'Scot', 'Jarva', 'scot.jarva@jarva.com.au', '02-9676-4462', 'Biancas La Petite French Bkry', '68 Camden Rd', 'Kingswood', 'NS', '2550', 'http://www.biancaslapetitefrenchbkry.com.au', '0445-480-672' UNION ALL
SELECT 'Adelaide', 'Ender', 'aender@gmail.com', '07-7538-5504', 'Williams Design Group', '175 N Central Ave', 'Greenslopes', 'QL', '4120', 'http://www.williamsdesigngroup.com.au', '0473-505-816' UNION ALL
SELECT 'Jackie', 'Borchelt', 'jackie_borchelt@hotmail.com', '03-8055-8668', 'Community Communication Servs', '80896 South Ave', 'Grovedale', 'VI', '3216', 'http://www.communitycommunicationservs.com.au', '0423-545-966' UNION ALL
SELECT 'Carli', 'Bame', 'carli@yahoo.com', '07-5354-7251', 'Hampton Inn Hotel', '6584 S Bascom Ave #371', 'Elanora', 'QL', '4221', 'http://www.hamptoninnhotel.com.au', '0499-207-236' UNION ALL
SELECT 'Coletta', 'Thro', 'coletta.thro@thro.net.au', '08-1991-6947', 'Hoffman, Carl Esq', '64865 Main St', 'North Fremantle', 'WA', '6159', 'http://www.hoffmancarlesq.com.au', '0444-915-799' UNION ALL
SELECT 'Katheryn', 'Lamers', 'katheryn_lamers@gmail.com', '02-4885-1611', 'Sonoco Products Co', '62171 E 6th Ave', 'Fyshwick', 'AC', '2609', 'http://www.sonocoproductsco.com.au', '0497-455-126' UNION ALL
SELECT 'Santos', 'Wisenbaker', 'swisenbaker@wisenbaker.net.au', '02-2957-4812', 'Brattleboro Printing Inc', '67729 180th St', 'Allworth', 'NS', '2425', 'http://www.brattleboroprintinginc.com.au', '0411-294-588' UNION ALL
SELECT 'Kimberely', 'Weyman', 'kweyman@weyman.com.au', '02-7091-8948', 'Scientific Agrcltl Svc Inc', '7721 Harrison St', 'Kingsway West', 'NS', '2208', 'http://www.scientificagrcltlsvcinc.com.au', '0441-151-810' UNION ALL
SELECT 'Earlean', 'Suffern', 'earlean.suffern@suffern.net.au', '02-9653-2199', 'Booster Farms', '5351 E Thousand Oaks Blvd', 'Woodford', 'NS', '2463', 'http://www.boosterfarms.com.au', '0452-941-575' UNION ALL
SELECT 'Dannette', 'Heimbaugh', 'dannette@gmail.com', '07-8738-4205', 'Accent Copy Center Inc', '5 Carpenter Ave', 'Breakaway', 'QL', '4825', 'http://www.accentcopycenterinc.com.au', '0422-884-614' UNION ALL
SELECT 'Odelia', 'Hutchin', 'odelia.hutchin@hutchin.com.au', '08-9895-1954', 'Mccaffreys Supermarket', '374 Sunrise Ave', 'Gorrie', 'WA', '6556', 'http://www.mccaffreyssupermarket.com.au', '0472-399-247' UNION ALL
SELECT 'Lina', 'Schwiebert', 'lina@yahoo.com', '03-3608-5660', 'Chemex Labs Ltd', '68538 N Bentz St #1451', 'Koorlong', 'VI', '3501', 'http://www.chemexlabsltd.com.au', '0487-835-113' UNION ALL
SELECT 'Fredric', 'Johanningmeie', 'fredric@hotmail.com', '02-1827-1736', 'Galaxie Displays Inc', '23 S Orange Ave #55', 'Wardell', 'NS', '2477', 'http://www.galaxiedisplaysinc.com.au', '0425-214-447' UNION ALL
SELECT 'Alfreda', 'Delsoin', 'adelsoin@yahoo.com', '07-7369-8849', 'Harris, Eric C Esq', '4373 Washington St', 'Bongeen', 'QL', '4356', 'http://www.harrisericcesq.com.au', '0419-246-570' UNION ALL
SELECT 'Bernadine', 'Elamin', 'bernadine_elamin@yahoo.com', '02-1815-8700', 'Tarix Printing', '61550 S Figueroa St', 'Waverley', 'NS', '2024', 'http://www.tarixprinting.com.au', '0448-195-542' UNION ALL
SELECT 'Ming', 'Thaxton', 'mthaxton@gmail.com', '03-4010-1900', 'Chem Aqua', '8 N Town East Blvd', 'Forrest', 'VI', '3236', 'http://www.chemaqua.com.au', '0486-557-304' UNION ALL
SELECT 'Gracia', 'Pecot', 'gpecot@hotmail.com', '02-8081-3883', 'Kern Valley Printing', '2452 Bango Rd', 'Gundaroo', 'NS', '2620', 'http://www.kernvalleyprinting.com.au', '0472-903-534' UNION ALL
SELECT 'Yuette', 'Metevelis', 'yuette.metevelis@metevelis.net.au', '08-4700-8894', 'American Speedy Printing Ctrs', '8219 Roswell Rd Ne', 'North Boyanup', 'WA', '6237', 'http://www.americanspeedyprintingctrs.com.au', '0483-854-984' UNION ALL
SELECT 'Yuriko', 'Kazarian', 'yuriko_kazarian@gmail.com', '08-1109-5346', 'Doane Products Company', '3 Davis Blvd', 'Mouroubra', 'WA', '6472', 'http://www.doaneproductscompany.com.au', '0476-877-991' UNION ALL
SELECT 'Hyman', 'Hegeman', 'hyman@hotmail.com', '08-9280-9177', 'Jerico Group', '1 S Marginal Rd', 'Flinders University', 'SA', '5042', 'http://www.jericogroup.com.au', '0413-650-821' UNION ALL
SELECT 'Linette', 'Summerfield', 'linette.summerfield@hotmail.com', '07-7489-7577', 'Mortenson Broadcasting Co', '78 S Robson', 'Crows Nest', 'QL', '4355', 'http://www.mortensonbroadcastingco.com.au', '0453-580-611' UNION ALL
SELECT 'Jospeh', 'Couzens', 'jospeh.couzens@couzens.com.au', '03-8451-7537', 'M & M Quality Printing', '2749 Van Nuys Blvd', 'Panmure', 'VI', '3265', 'http://www.mmqualityprinting.com.au', '0452-605-630' UNION ALL
SELECT 'Anna', 'Ovit', 'anna.ovit@hotmail.com', '02-4649-5341', 'Georgia Business Machines', '722 E Liberty St', 'Bygalorie', 'NS', '2669', 'http://www.georgiabusinessmachines.com.au', '0459-496-184' UNION ALL
SELECT 'Shawnta', 'Woodhams', 'shawnta@woodhams.com.au', '02-5770-8546', 'Leo, Frank M', '9 Gunnison St', 'Oakhurst', 'NS', '2761', 'http://www.leofrankm.com.au', '0410-116-435' UNION ALL
SELECT 'Ettie', 'Luckenbach', 'ettie@yahoo.com', '08-9378-7021', 'S E M A', '2902 Edison Dr #278', 'Mandurah East', 'WA', '6210', 'http://www.sema.com.au', '0424-568-217' UNION ALL
SELECT 'Chara', 'Leveston', 'cleveston@gmail.com', '03-2574-8915', 'Arthur Andersen & Co', '72 N Buckeye Ave', 'Daisy Hill', 'VI', '3465', 'http://www.arthurandersenco.com.au', '0415-341-310' UNION ALL
SELECT 'Lauran', 'Huntsberger', 'lhuntsberger@huntsberger.net.au', '08-2704-3706', 'Triangle Engineering Inc', '41 E Jackson St', 'Willetton', 'WA', '6155', 'http://www.triangleengineeringinc.com.au', '0476-605-889' UNION ALL
SELECT 'Pansy', 'Todesco', 'pansy_todesco@gmail.com', '03-3233-4255', 'Schmidt, Charles E Jr', '684 William St', 'Tarnagulla', 'VI', '3551', 'http://www.schmidtcharlesejr.com.au', '0467-468-894' UNION ALL
SELECT 'Georgeanna', 'Silverstone', 'georgeanna@silverstone.net.au', '03-7416-6750', 'Emess Professional Svces', '185 W Guadalupe Rd', 'Steels Creek', 'VI', '3775', 'http://www.emessprofessionalsvces.com.au', '0436-793-916' UNION ALL
SELECT 'Jesus', 'Liversedge', 'jesus.liversedge@hotmail.com', '02-4418-5927', 'White, Mark A Cpa', '18514 E 4th St #8', 'Broken Head', 'NS', '2481', 'http://www.whitemarkacpa.com.au', '0467-331-796' UNION ALL
SELECT 'Jamey', 'Tetter', 'jamey.tetter@gmail.com', '07-6073-5039', 'Vicon Corporation', '28 Standiford Ave #6', 'Bundaberg West', 'QL', '4670', 'http://www.viconcorporation.com.au', '0481-690-589' UNION ALL
SELECT 'Alberta', 'Motter', 'alberta_motter@hotmail.com', '03-1248-8221', 'Turl Engineering Works', '33108 S Yosemite Ct', 'Port Melbourne', 'VI', '3207', 'http://www.turlengineeringworks.com.au', '0491-832-907' UNION ALL
SELECT 'Ronald', 'Grube', 'ronald.grube@yahoo.com', '08-3305-5436', 'Deep Creek Pharmacy', '73778 Battery St', 'Happy Valley', 'SA', '5159', 'http://www.deepcreekpharmacy.com.au', '0457-126-909' UNION ALL
SELECT 'Tamala', 'Hickie', 'tamala_hickie@yahoo.com', '03-3695-2399', 'Mister Bagel', '351 Crooks Rd', 'Benambra', 'VI', '3900', 'http://www.misterbagel.com.au', '0432-182-830' UNION ALL
SELECT 'Gerry', 'Mohrmann', 'gerry_mohrmann@mohrmann.net.au', '08-1399-2471', 'Howard Winig Realty Assocs Inc', '8 Glenn Way #3', 'Brockman', 'WA', '6701', 'http://www.howardwinigrealtyassocsinc.com.au', '0490-947-955' UNION ALL
SELECT 'Isaiah', 'Kueter', 'ikueter@kueter.com.au', '03-3725-6290', 'Jordan, Mark D Esq', '8 W Virginia St', 'Amphitheatre', 'VI', '3468', 'http://www.jordanmarkdesq.com.au', '0494-282-122' UNION ALL
SELECT 'Magnolia', 'Overbough', 'moverbough@overbough.com.au', '02-7947-2980', 'Marin Sun Printing', '65484 Bainbridge Rd', 'Penrith', 'NS', '2750', 'http://www.marinsunprinting.com.au', '0488-624-111' UNION ALL
SELECT 'Ngoc', 'Guglielmina', 'ngoc_guglielmina@hotmail.com', '08-2264-5559', 'Verde, Louis J Esq', '156 Morris St', 'Darke Peak', 'SA', '5642', 'http://www.verdelouisjesq.com.au', '0490-128-503' UNION ALL
SELECT 'Julene', 'Lauretta', 'julene.lauretta@gmail.com', '03-1036-9594', 'Convum Internatl Corp', '1881 Market St', 'Mole Creek', 'TA', '7304', 'http://www.convuminternatlcorp.com.au', '0451-946-241' UNION ALL
SELECT 'Magda', 'Lindbeck', 'magda_lindbeck@yahoo.com', '02-3713-3646', 'Thomas Torto Constr Corp', '6 Kings St #4790', 'Emerald Beach', 'NS', '2456', 'http://www.thomastortoconstrcorp.com.au', '0451-383-562' UNION ALL
SELECT 'Shantell', 'Lizama', 'shantell.lizama@gmail.com', '07-5346-5917', 'Astromatic', '9787 Dunksferry Rd', 'Logan Village', 'QL', '4207', 'http://www.astromatic.com.au', '0459-937-449' UNION ALL
SELECT 'Audria', 'Piccinich', 'audria.piccinich@gmail.com', '08-9757-2379', 'Kuhio Photo', '13 Blanchard St #996', 'Coober Pedy', 'SA', '5723', 'http://www.kuhiophoto.com.au', '0426-175-813' UNION ALL
SELECT 'Nickole', 'Derenzis', 'nderenzis@hotmail.com', '02-5573-6627', 'Lehigh Furn Divsn Lehigh', '2 Pompton Ave', 'Berowra Heights', 'NS', '2082', 'http://www.lehighfurndivsnlehigh.com.au', '0480-120-597' UNION ALL
SELECT 'Grover', 'Reynolds', 'grover.reynolds@gmail.com', '08-7785-3040', 'Okon Inc', '2867 Industrial Way', 'Innaloo', 'WA', '6018', 'http://www.okoninc.com.au', '0447-228-633' UNION ALL
SELECT 'Rocco', 'Bergstrom', 'rocco@yahoo.com', '08-3987-7521', 'Postlewaite, Jack A Esq', '850 Warwick Blvd #58', 'Leeman', 'WA', '6514', 'http://www.postlewaitejackaesq.com.au', '0457-212-114' UNION ALL
SELECT 'Ethan', 'Quintero', 'ethan_quintero@quintero.com.au', '08-8280-9492', 'Regent Consultants Corp', '2 Ellis Rd', 'East Damboring', 'WA', '6608', 'http://www.regentconsultantscorp.com.au', '0488-425-192' UNION ALL
SELECT 'Glynda', 'Sanzenbacher', 'glynda@sanzenbacher.com.au', '03-1051-7865', 'Hinkson Cooper Weaver Inc', '80 Monroe St', 'Kinglake West', 'VI', '3757', 'http://www.hinksoncooperweaverinc.com.au', '0451-639-283' UNION ALL
SELECT 'Yolande', 'Scrimsher', 'yolande@yahoo.com', '08-2136-2433', 'Spclty Fastening Systems Inc', '71089 Queens Blvd', 'Canning Vale', 'WA', '6155', 'http://www.spcltyfasteningsystemsinc.com.au', '0472-691-355' UNION ALL
SELECT 'Twanna', 'Sieber', 'twanna@yahoo.com', '07-5235-7319', 'Rudolph, William S Cpa', '66094 Pioneer Rd', 'Upper Glastonbury', 'QL', '4570', 'http://www.rudolphwilliamscpa.com.au', '0451-406-157' UNION ALL
SELECT 'Rosenda', 'Petteway', 'rosenda@gmail.com', '03-9599-4122', 'Choo Choo Caboose At Jade Bbq', '66 Congress St', 'Caroline Springs', 'VI', '3023', 'http://www.choochoocabooseatjadebbq.com.au', '0438-478-951' UNION ALL
SELECT 'Lacey', 'Francis', 'lacey.francis@francis.net.au', '07-4119-3981', 'Anthony & Langford', '44 105th Ave', 'Hunchy', 'QL', '4555', 'http://www.anthonylangford.com.au', '0415-135-989' UNION ALL
SELECT 'Cordie', 'Meikle', 'cordie.meikle@hotmail.com', '02-8727-4906', 'Shapiro Bag Company', '40809 Rockburn Hill Rd', 'Hamlyn Terrace', 'NS', '2259', 'http://www.shapirobagcompany.com.au', '0441-386-796' UNION ALL
SELECT 'Annalee', 'Graleski', 'annalee.graleski@hotmail.com', '02-6118-8773', 'Lescure Company Inc', '9 Green Rd #5877', 'Darbys Falls', 'NS', '2793', 'http://www.lescurecompanyinc.com.au', '0447-563-450' UNION ALL
SELECT 'Dana', 'Ladeau', 'dana@ladeau.net.au', '07-3511-9233', 'Higgins, Daniel B Esq', '63 W 41st Ave #93', 'Pinnacle', 'QL', '4741', 'http://www.higginsdanielbesq.com.au', '0480-125-331' UNION ALL
SELECT 'Wai', 'Raddle', 'wai.raddle@raddle.com.au', '03-4811-3832', 'Dot Pitch Electronics', '2 Stirrup Dr #4907', 'Carlsruhe', 'VI', '3442', 'http://www.dotpitchelectronics.com.au', '0494-517-582' UNION ALL
SELECT 'Johana', 'Conquest', 'johana@conquest.net.au', '08-6579-7569', 'Henri D Kahn Insurance', '19 Court St', 'Paulls Valley', 'WA', '6076', 'http://www.henridkahninsurance.com.au', '0442-561-392' UNION ALL
SELECT 'Tomas', 'Fults', 'tomas_fults@fults.net.au', '07-1536-4805', 'Test Tools Inc', '3 Hwy 61 #2491', 'Mirani', 'QL', '4754', 'http://www.testtoolsinc.com.au', '0473-757-584' UNION ALL
SELECT 'Karon', 'Etzler', 'karon@hotmail.com', '03-6698-8416', 'Rachmel & Company Cpa Pa', '97539 Connecticut Ave Nw #3586', 'Buckland', 'TA', '7190', 'http://www.rachmelcompanycpapa.com.au', '0432-184-936' UNION ALL
SELECT 'Delbert', 'Houben', 'delbert.houben@hotmail.com', '03-1560-6800', 'Hermann Assocs Inc Safe Mart', '59 Murray Hill Pky', 'Mitta Mitta', 'VI', '3701', 'http://www.hermannassocsincsafemart.com.au', '0417-833-905' UNION ALL
SELECT 'Ashleigh', 'Rimmer', 'ashleigh.rimmer@hotmail.com', '03-5354-9557', 'Palmer Publications Inc', '15 W 11mile Rd', 'Boat Harbour Beach', 'TA', '7321', 'http://www.palmerpublicationsinc.com.au', '0467-120-854' UNION ALL
SELECT 'Nenita', 'Mckenna', 'nmckenna@yahoo.com', '02-5059-2649', 'Southern Imperial Inc', '709 New Market St', 'Botany', 'NS', '1455', 'http://www.southernimperialinc.com.au', '0419-730-349' UNION ALL
SELECT 'Micah', 'Shear', 'mshear@hotmail.com', '08-6270-6829', 'United Water Resources Inc', '324 Shawnee Mission Pky', 'Scaddan', 'WA', '6447', 'http://www.unitedwaterresourcesinc.com.au', '0432-703-516' UNION ALL
SELECT 'Stefany', 'Figueras', 'stefany@figueras.net.au', '08-2209-8647', 'Burke, Jonathan H Esq', '37 Saint Louis Ave #292', 'Lenswood', 'SA', '5240', 'http://www.burkejonathanhesq.com.au', '0474-975-307' UNION ALL
SELECT 'Rene', 'Burnsworth', 'rene@burnsworth.net.au', '08-8222-3171', 'Nurses Ofr Newborns', '80289 Victory Ave #9', 'Farrell Flat', 'SA', '5416', 'http://www.nursesofrnewborns.com.au', '0422-183-541' UNION ALL
SELECT 'Cary', 'Orazine', 'cary.orazine@hotmail.com', '08-7718-8495', 'Para Laboratories', '16 Governors Dr Sw', 'Melrose', 'SA', '5483', 'http://www.paralaboratories.com.au', '0419-720-227' UNION ALL
SELECT 'Micheal', 'Ocken', 'micheal.ocken@ocken.net.au', '02-9828-4921', 'New Orleans Credit Service Inc', '4 E Aven #284', 'Freemans Waterhole', 'NS', '2323', 'http://www.neworleanscreditserviceinc.com.au', '0449-668-295' UNION ALL
SELECT 'Frederick', 'Tamburello', 'frederick.tamburello@hotmail.com', '03-4800-7102', 'Signs By Berry', '262 8th St', 'Simpsons Bay', 'TA', '7150', 'http://www.signsbyberry.com.au', '0466-921-460' UNION ALL
SELECT 'Burma', 'Noa', 'burma.noa@gmail.com', '03-6438-4586', 'Saum, Scott J Esq', '79 State Route 35', 'Ripponlea', 'VI', '3185', 'http://www.saumscottjesq.com.au', '0448-770-746' UNION ALL
SELECT 'Cherry', 'Roh', 'cherry_roh@yahoo.com', '08-5175-3585', 'Ulrich, Lawrence M Esq', '75 Blackington Ave', 'North Cascade', 'WA', '6445', 'http://www.ulrichlawrencemesq.com.au', '0476-917-926' UNION ALL
SELECT 'Gabriele', 'Frabotta', 'gabriele_frabotta@gmail.com', '03-2689-6049', 'Stewart Levine & Davis', '6 Abbott Rd', 'Ensay', 'VI', '3895', 'http://www.stewartlevinedavis.com.au', '0460-834-526' UNION ALL
SELECT 'Clement', 'Chee', 'clement@hotmail.com', '03-2775-4083', 'Bark Eater Inn', '5159 Saint Ann St', 'Golden Point', 'VI', '3451', 'http://www.barkeaterinn.com.au', '0485-660-179' UNION ALL
SELECT 'Beckie', 'Apodace', 'bapodace@gmail.com', '02-5630-3114', 'Reich, Richard J Esq', '26 Ripley St #5444', 'Middle Cove', 'NS', '2068', 'http://www.reichrichardjesq.com.au', '0469-490-273' UNION ALL
SELECT 'Catrice', 'Fowlkes', 'cfowlkes@hotmail.com', '07-9032-5149', 'Kappus Co', '39828 Abbott Rd', 'Waterfront Place', 'QL', '4001', 'http://www.kappusco.com.au', '0418-429-485' UNION ALL
SELECT 'Richelle', 'Remillard', 'richelle.remillard@remillard.net.au', '08-6831-6370', 'Terri, Teresa Hutchens Esq', '2495 Beach Blvd #557', 'Buraminya', 'WA', '6452', 'http://www.territeresahutchensesq.com.au', '0416-611-806' UNION ALL
SELECT 'Cherri', 'Miccio', 'cherri_miccio@gmail.com', '07-5626-7937', 'Hong Iwai Hulbert & Kawano', '3 Bustleton Ave', 'Balnagowan', 'QL', '4740', 'http://www.hongiwaihulbertkawano.com.au', '0476-736-800' UNION ALL
SELECT 'Dorethea', 'Taketa', 'dtaketa@taketa.net.au', '07-2209-2731', 'Fraser Dante Ltd', '7 N 4th St', 'Lower Cressbrook', 'QL', '4313', 'http://www.fraserdanteltd.com.au', '0436-606-487' UNION ALL
SELECT 'Barb', 'Latina', 'blatina@hotmail.com', '08-8506-7259', 'Die Craft Stamping', '1 National Plac #6619', 'Larrakeyah', 'NT', '820', 'http://www.diecraftstamping.com.au', '0443-657-148' UNION ALL
SELECT 'Bettye', 'Meray', 'bmeray@yahoo.com', '03-9424-2956', 'Sako, Bradley T Esq', '248 Academy Rd', 'Middleton', 'TA', '7163', 'http://www.sakobradleytesq.com.au', '0420-742-142' UNION ALL
SELECT 'Sherrell', 'Sprowl', 'sherrell_sprowl@hotmail.com', '02-4074-4461', 'Country Comfort', '2 State Hwy', 'Oak Flats', 'NS', '2529', 'http://www.countrycomfort.com.au', '0417-795-558' UNION ALL
SELECT 'Ruth', 'Niglio', 'ruth.niglio@hotmail.com', '07-5128-8956', 'Amberley Suite Hotels', '6 W Cornelia Ave', 'Orange Hill', 'QL', '4455', 'http://www.amberleysuitehotels.com.au', '0428-843-553' UNION ALL
SELECT 'Alva', 'Shoulders', 'alva@gmail.com', '08-8329-4211', 'Warren Leadership', '461 S Fannin Ave', 'Welshpool', 'WA', '6106', 'http://www.warrenleadership.com.au', '0471-940-163' UNION ALL
SELECT 'Carri', 'Palaspas', 'carri_palaspas@palaspas.net.au', '08-6069-1579', 'Alexander, David T Esq', '51255 Tea Town Rd #9', 'Minnenooka', 'WA', '6532', 'http://www.alexanderdavidtesq.com.au', '0499-165-889' UNION ALL
SELECT 'Onita', 'Milbrandt', 'onita.milbrandt@milbrandt.com.au', '02-1157-3829', 'Fairfield Inn By Marriott', '93 Bloomfield Ave #829', 'Wagga Wagga South', 'NS', '2650', 'http://www.fairfieldinnbymarriott.com.au', '0485-105-744' UNION ALL
SELECT 'Jessenia', 'Sarp', 'jsarp@hotmail.com', '08-8878-5994', 'Skyline Lodge & Restaurant', '5775 Mechanic St #517', 'Wansbrough', 'WA', '6320', 'http://www.skylinelodgerestaurant.com.au', '0422-775-760' UNION ALL
SELECT 'Tricia', 'Peressini', 'tperessini@yahoo.com', '08-4326-1560', 'Aviation Design', '3 Industrial Blvd', 'Pintharuka', 'WA', '6623', 'http://www.aviationdesign.com.au', '0484-192-990' UNION ALL
SELECT 'Stephaine', 'Manin', 'stephaine_manin@yahoo.com', '07-2031-6566', 'Malmon, Alvin S Esq', '8202 Cornwall Rd', 'Eumundi', 'QL', '4562', 'http://www.malmonalvinsesq.com.au', '0438-847-885' UNION ALL
SELECT 'Florinda', 'Gudgel', 'fgudgel@gudgel.com.au', '02-2501-8301', 'Transit Cargo Services Inc', '53597 W Clarendon Ave', 'Halton', 'NS', '2311', 'http://www.transitcargoservicesinc.com.au', '0444-376-606' UNION ALL
SELECT 'Marsha', 'Farnham', 'marsha@farnham.com.au', '02-5402-8024', 'Comfort Inn Of Revere', '577 Cleveland Ave', 'Glenmore Park', 'NS', '2745', 'http://www.comfortinnofrevere.com.au', '0470-386-894' UNION ALL
SELECT 'Josefa', 'Oakland', 'josefa_oakland@oakland.com.au', '07-5404-6221', 'Duncan & Associates', '259 1st Ave', 'Mccutcheon', 'QL', '4856', 'http://www.duncanassociates.com.au', '0493-826-469' UNION ALL
SELECT 'Deeann', 'Nicklous', 'deeann_nicklous@gmail.com', '07-6382-5073', 'Philip Kingsley Trichological', '79 Mechanic St', 'Pimpimbudgee', 'QL', '4615', 'http://www.philipkingsleytrichological.com.au', '0440-980-784' UNION ALL
SELECT 'Jeannetta', 'Vonstaden', 'jvonstaden@gmail.com', '02-8222-9319', 'Burlington Homes Of Maine', '269 Executive Dr', 'Ilford', 'NS', '2850', 'http://www.burlingtonhomesofmaine.com.au', '0435-530-318' UNION ALL
SELECT 'Desmond', 'Amuso', 'desmond@hotmail.com', '02-1706-8506', 'Carson, Scott W Esq', '79 Runamuck Pl', 'Caparra', 'NS', '2429', 'http://www.carsonscottwesq.com.au', '0427-106-677' UNION ALL
SELECT 'Trina', 'Bakey', 'tbakey@bakey.com.au', '07-5922-1983', 'Dewitt Cnty Fed Svngs & Ln', '31 Guilford Rd #7904', 'Duaringa', 'QL', '4712', 'http://www.dewittcntyfedsvngsln.com.au', '0495-376-112' UNION ALL
SELECT 'Ramonita', 'Picotte', 'ramonita_picotte@yahoo.com', '02-4360-8467', 'Art Material Services Inc', '504 Steve Dr', 'Weston', 'NS', '2326', 'http://www.artmaterialservicesinc.com.au', '0479-654-997' UNION ALL
SELECT 'Temeka', 'Bodine', 'temeka.bodine@gmail.com', '02-2581-7479', 'Consolidated Manufacturing Inc', '407 E 57th Ave', 'Clunes', 'NS', '2480', 'http://www.consolidatedmanufacturinginc.com.au', '0452-835-388' UNION ALL
SELECT 'Bea', 'Iida', 'bea_iida@iida.net.au', '07-6984-9278', 'Reliance Credit Union', '72 W Ripley Ave', 'Oakey', 'QL', '4401', 'http://www.reliancecreditunion.com.au', '0493-653-304' UNION ALL
SELECT 'Soledad', 'Mockus', 'soledad_mockus@yahoo.com', '02-1291-8182', 'Sinclair Machine Products Inc', '75 Elm Rd #1190', 'Barton', 'AC', '2600', 'http://www.sinclairmachineproductsinc.com.au', '0444-126-746' UNION ALL
SELECT 'Margurite', 'Okon', 'margurite.okon@hotmail.com', '03-9721-7313', 'Kent, Wendy M Esq', '32 Broadway St', 'Lanena', 'TA', '7275', 'http://www.kentwendymesq.com.au', '0442-360-982' UNION ALL
SELECT 'Artie', 'Saine', 'artie_saine@yahoo.com', '03-3457-2524', 'Dixon, Eric D Esq', '41 Washington Blvd', 'Cora Lynn', 'VI', '3814', 'http://www.dixonericdesq.com.au', '0433-550-202' UNION ALL
SELECT 'Major', 'Studwell', 'major@gmail.com', '07-1377-6898', 'Wood Sign & Banner Co', '5 Buford Hwy Ne #3', 'Allora', 'QL', '4362', 'http://www.woodsignbannerco.com.au', '0426-784-480' UNION ALL
SELECT 'Veronika', 'Buchauer', 'veronika.buchauer@buchauer.net.au', '02-4202-5191', 'Adkins, Russell Esq', '6 Flex Ave', 'Willow Tree', 'NS', '2339', 'http://www.adkinsrussellesq.com.au', '0434-402-895' UNION ALL
SELECT 'Christene', 'Cisney', 'christene@hotmail.com', '03-3630-2467', 'Danform Shoe Stores', '21058 Massillon Rd', 'Keilor Downs', 'VI', '3038', 'http://www.danformshoestores.com.au', '0451-465-174' UNION ALL
SELECT 'Miles', 'Feldner', 'miles@hotmail.com', '07-8561-5894', 'Antietam Cable Television', '28465 Downey Ave #4238', 'Barringun', 'QL', '4490', 'http://www.antietamcabletelevision.com.au', '0475-337-188' UNION ALL
SELECT 'Julio', 'Mikel', 'julio.mikel@mikel.net.au', '02-6995-9902', 'Lombardi Bros Inc', '2803 N Catalina Ave', 'Pilliga', 'NS', '2388', 'http://www.lombardibrosinc.com.au', '0464-594-316' UNION ALL
SELECT 'Aide', 'Ghera', 'aide.ghera@ghera.com.au', '02-3738-7508', 'Nathaniel Electronics', '22 Livingston Ave', 'Rhodes', 'NS', '2138', 'http://www.nathanielelectronics.com.au', '0443-448-467' UNION ALL
SELECT 'Noelia', 'Brackett', 'noelia@brackett.net.au', '08-3773-3770', 'Rodriguez, Joseph A Esq', '403 Conn Valley Rd', 'Castletown', 'WA', '6450', 'http://www.rodriguezjosephaesq.com.au', '0454-135-614' UNION ALL
SELECT 'Lenora', 'Delacruz', 'lenora@delacruz.net.au', '02-7862-5151', 'Stilling, William J Esq', '5400 Market St', 'Turill', 'NS', '2850', 'http://www.stillingwilliamjesq.com.au', '0454-434-110'
GO

/******************************
 * ReloadContacts
 ******************************/
CREATE PROCEDURE ReloadContacts
AS
  
  -- 1. Truncate data
  TRUNCATE TABLE Contacts
  
  -- 2. Insert data back
  INSERT INTO Contacts (FirstName, LastName, Email, Phone1, Company, Address, City, State, Post, Web, Phone2) 
  SELECT 'Rebbecca', 'Didio', 'rebbecca.didio@didio.com.au', '03-8174-9123', 'Brandt, Jonathan F Esq', '171 E 24th St', 'Leith', 'TA', '7315', 'http://www.brandtjonathanfesq.com.au', '0458-665-290' UNION ALL
  SELECT 'Stevie', 'Hallo', 'stevie.hallo@hotmail.com', '07-9997-3366', 'Landrum Temporary Services', '22222 Acoma St', 'Proston', 'QL', '4613', 'http://www.landrumtemporaryservices.com.au', '0497-622-620' UNION ALL
  SELECT 'Mariko', 'Stayer', 'mariko_stayer@hotmail.com', '08-5558-9019', 'Inabinet, Macre Esq', '534 Schoenborn St #51', 'Hamel', 'WA', '6215', 'http://www.inabinetmacreesq.com.au', '0427-885-282' UNION ALL
  SELECT 'Gerardo', 'Woodka', 'gerardo_woodka@hotmail.com', '02-6044-4682', 'Morris Downing & Sherred', '69206 Jackson Ave', 'Talmalmo', 'NS', '2640', 'http://www.morrisdowningsherred.com.au', '0443-795-912' UNION ALL
  SELECT 'Mayra', 'Bena', 'mayra.bena@gmail.com', '02-1455-6085', 'Buelt, David L Esq', '808 Glen Cove Ave', 'Lane Cove', 'NS', '1595', 'http://www.bueltdavidlesq.com.au', '0453-666-885' UNION ALL
  SELECT 'Idella', 'Scotland', 'idella@hotmail.com', '08-7868-1355', 'Artesian Ice & Cold Storage Co', '373 Lafayette St', 'Cartmeticup', 'WA', '6316', 'http://www.artesianicecoldstorageco.com.au', '0451-966-921' UNION ALL
  SELECT 'Sherill', 'Klar', 'sklar@hotmail.com', '08-6522-8931', 'Midway Hotel', '87 Sylvan Ave', 'Nyamup', 'WA', '6258', 'http://www.midwayhotel.com.au', '0427-991-688' UNION ALL
  SELECT 'Ena', 'Desjardiws', 'ena_desjardiws@desjardiws.com.au', '02-5226-9402', 'Selsor, Robert J Esq', '60562 Ky Rt 321', 'Bendick Murrell', 'NS', '2803', 'http://www.selsorrobertjesq.com.au', '0415-961-606' UNION ALL
  SELECT 'Vince', 'Siena', 'vince_siena@yahoo.com', '07-3184-9989', 'Vincent J Petti & Co', '70 S 18th Pl', 'Purrawunda', 'QL', '4356', 'http://www.vincentjpettico.com.au', '0411-732-965' UNION ALL
  SELECT 'Theron', 'Jarding', 'tjarding@hotmail.com', '08-6890-4661', 'Prentiss, Paul F Esq', '8839 Ventura Blvd', 'Blanchetown', 'SA', '5357', 'http://www.prentisspaulfesq.com.au', '0461-862-457' UNION ALL
  SELECT 'Amira', 'Chudej', 'amira.chudej@chudej.net.au', '07-8135-3271', 'Public Works Department', '3684 N Wacker Dr', 'Rockside', 'QL', '4343', 'http://www.publicworksdepartment.com.au', '0478-867-289' UNION ALL
  SELECT 'Marica', 'Tarbor', 'marica.tarbor@hotmail.com', '03-1174-6817', 'Prudential Lighting Corp', '68828 S 32nd St #6', 'Rosegarland', 'TA', '7140', 'http://www.prudentiallightingcorp.com.au', '0494-982-617' UNION ALL
  SELECT 'Shawna', 'Albrough', 'shawna.albrough@albrough.com.au', '07-7977-6039', 'Wood, J Scott Esq', '43157 Cypress St', 'Ringwood', 'QL', '4343', 'http://www.woodjscottesq.com.au', '0441-255-802' UNION ALL
  SELECT 'Paulina', 'Maker', 'paulina_maker@maker.net.au', '08-8344-8929', 'Swanson Peterson Fnrl Home Inc', '6 S Hanover Ave', 'Maylands', 'WA', '6931', 'http://www.swansonpetersonfnrlhomeinc.com.au', '0420-123-282' UNION ALL
  SELECT 'Rose', 'Jebb', 'rose@jebb.net.au', '07-4941-9471', 'Old Cider Mill Grove', '27916 Tarrytown Rd', 'Wooloowin', 'QL', '4030', 'http://www.oldcidermillgrove.com.au', '0496-441-929' UNION ALL
  SELECT 'Reita', 'Tabar', 'rtabar@hotmail.com', '02-3518-7078', 'Cooper Myers Y Co', '79620 Timber Dr', 'Arthurville', 'NS', '2820', 'http://www.coopermyersyco.com.au', '0431-669-863' UNION ALL
  SELECT 'Maybelle', 'Bewley', 'mbewley@yahoo.com', '07-9387-7293', 'Angelo International', '387 Airway Cir #62', 'Mapleton', 'QL', '4560', 'http://www.angelointernational.com.au', '0448-221-640' UNION ALL
  SELECT 'Camellia', 'Pylant', 'camellia_pylant@gmail.com', '02-5171-4345', 'Blackley, William J Pa', '570 W Pine St', 'Tuggerawong', 'NS', '2259', 'http://www.blackleywilliamjpa.com.au', '0423-446-913' UNION ALL
  SELECT 'Roy', 'Nybo', 'rnybo@nybo.net.au', '02-5311-7778', 'Phoenix Phototype', '823 Fishers Ln', 'Red Hill', 'AC', '2603', 'http://www.phoenixphototype.com.au', '0416-394-795' UNION ALL
  SELECT 'Albert', 'Sonier', 'albert.sonier@gmail.com', '07-9354-2612', 'Quartzite Processing Inc', '4 Brookcrest Dr #7786', 'Inverlaw', 'QL', '4610', 'http://www.quartziteprocessinginc.com.au', '0420-575-355' UNION ALL
  SELECT 'Hayley', 'Taghon', 'htaghon@taghon.net.au', '02-1638-4380', 'Biltmore Textile Co Inc', '72 Wyoming Ave', 'Eugowra', 'NS', '2806', 'http://www.biltmoretextilecoinc.com.au', '0491-976-291' UNION ALL
  SELECT 'Norah', 'Daleo', 'ndaleo@daleo.net.au', '02-5322-6127', 'Gateway Refrigeration', '754 Sammis Ave', 'Kotara Fair', 'NS', '2289', 'http://www.gatewayrefrigeration.com.au', '0462-327-613' UNION ALL
  SELECT 'Rosina', 'Sidhu', 'rosina_sidhu@gmail.com', '07-6460-4488', 'Anchorage Yamaha', '660 N Green St', 'Burpengary', 'QL', '4505', 'http://www.anchorageyamaha.com.au', '0458-753-924' UNION ALL
  SELECT 'Royal', 'Costeira', 'royal_costeira@costeira.com.au', '07-5338-6357', 'Wynns Precision Inc Az Div', '970 Waterloo Rd', 'Ellis Beach', 'QL', '4879', 'http://www.wynnsprecisionincazdiv.com.au', '0480-443-612' UNION ALL
  SELECT 'Barrie', 'Nicley', 'bnicley@nicley.com.au', '03-6443-2786', 'Paragon Cable Tv', '4129 Abbott Dr', 'Fish Creek', 'VI', '3959', 'http://www.paragoncabletv.com.au', '0455-270-505' UNION ALL
  SELECT 'Linsey', 'Gedman', 'lgedman@gedman.net.au', '07-4785-3781', 'Eagle Computer Services Inc', '1529 Prince Rodgers Ave', 'Kennedy', 'QL', '4816', 'http://www.eaglecomputerservicesinc.com.au', '0433-965-131' UNION ALL
  SELECT 'Laura', 'Bourbonnais', 'laura.bourbonnais@yahoo.com', '03-6543-6688', 'Kansas Association Ins Agtts', '2 N Valley Mills Dr', 'Cape Portland', 'TA', '7264', 'http://www.kansasassociationinsagtts.com.au', '0491-455-112' UNION ALL
  SELECT 'Fanny', 'Stoneking', 'fstoneking@hotmail.com', '07-3721-9123', 'Di Giacomo, Richard F Esq', '50968 Kurtz St #45', 'Warra', 'QL', '4411', 'http://www.digiacomorichardfesq.com.au', '0465-778-983' UNION ALL
  SELECT 'Kristian', 'Ellerbusch', 'kristian@yahoo.com', '08-2748-1250', 'Butler, Frank B Esq', '71585 S Ayon Ave #9', 'Wanguri', 'NT', '810', 'http://www.butlerfrankbesq.com.au', '0442-982-316' UNION ALL
  SELECT 'Gwen', 'Julye', 'gjulye@hotmail.com', '03-7063-6734', 'Alphagraphics Printshops', '8 Old County Rd #3', 'Alvie', 'VI', '3249', 'http://www.alphagraphicsprintshops.com.au', '0465-547-766' UNION ALL
  SELECT 'Ben', 'Majorga', 'ben.majorga@hotmail.com', '02-8171-9051', 'Voyager Travel Service', '13904 S 35th St', 'Wherrol Flat', 'NS', '2429', 'http://www.voyagertravelservice.com.au', '0462-648-621' UNION ALL
  SELECT 'Trina', 'Oto', 'trina@oto.com.au', '07-1153-8567', 'N Amer Plast & Chemls Co Inc', '6149 Kapiolani Blvd #6', 'Placid Hills', 'QL', '4343', 'http://www.namerplastchemlscoinc.com.au', '0460-377-727' UNION ALL
  SELECT 'Emelda', 'Geffers', 'emelda.geffers@gmail.com', '08-7097-3947', 'D L Downing General Contr Inc', '95431 34th Ave #62', 'Nedlands', 'WA', '6909', 'http://www.dldowninggeneralcontrinc.com.au', '0454-643-433' UNION ALL
  SELECT 'Zana', 'Ploszaj', 'zana_ploszaj@ploszaj.net.au', '07-7991-8880', 'Community Insurance Agy Inc', '25 Swift Ave', 'Auchenflower', 'QL', '4066', 'http://www.communityinsuranceagyinc.com.au', '0430-656-502' UNION ALL
  SELECT 'Shaun', 'Rael', 'shaun.rael@rael.com.au', '03-8998-5485', 'House Of Ing', '14304 Old Alexandria Ferry Rd', 'Buninyong', 'VI', '3357', 'http://www.houseofing.com.au', '0498-627-281' UNION ALL
  SELECT 'Oren', 'Lobosco', 'olobosco@hotmail.com', '02-5046-1307', 'Vei Inc', '1585 Salem Church Rd #59', 'Dangar Island', 'NS', '2083', 'http://www.veiinc.com.au', '0495-838-492' UNION ALL
  SELECT 'Catherin', 'Aguele', 'caguele@gmail.com', '07-6476-1399', 'Hanna, Robert J Esq', '75962 E Drinker St', 'Sunny Nook', 'QL', '4605', 'http://www.hannarobertjesq.com.au', '0444-150-950' UNION ALL
  SELECT 'Pearlene', 'Boudrie', 'pboudrie@boudrie.net.au', '07-4463-7223', 'Design Rite Homes Inc', '8978 W Henrietta Rd', 'Minden', 'QL', '4311', 'http://www.designritehomesinc.com.au', '0462-627-260' UNION ALL
  SELECT 'Kathryn', 'Bonalumi', 'kathryn.bonalumi@yahoo.com', '08-3071-2258', 'State Library', '86 Worth St #272', 'Tibradden', 'WA', '6532', 'http://www.statelibrary.com.au', '0455-699-311' UNION ALL
  SELECT 'Suzan', 'Landa', 'suzan.landa@gmail.com', '07-1576-1412', 'Vista Grande Baptist Church', '15 Campville Rd #191', 'Clermont', 'QL', '4721', 'http://www.vistagrandebaptistchurch.com.au', '0471-251-939' UNION ALL
  SELECT 'Sommer', 'Agar', 'sagar@agar.net.au', '08-9130-3372', 'Poole Publications Inc', '3 N Ridge Ave', 'Kadina', 'SA', '5554', 'http://www.poolepublicationsinc.com.au', '0486-599-199' UNION ALL
  SELECT 'Keena', 'Rebich', 'krebich@rebich.net.au', '02-4972-3570', 'Affilated Consulting Group Inc', '3713 Poway Rd', 'Sawtell', 'NS', '2452', 'http://www.affilatedconsultinggroupinc.com.au', '0468-708-802' UNION ALL
  SELECT 'Rupert', 'Hinkson', 'rupert_hinkson@hinkson.net.au', '02-7160-2066', 'Northwestern Mutual Life Ins', '1 E 17th St', 'East Gosford', 'NS', '2250', 'http://www.northwesternmutuallifeins.com.au', '0489-430-358' UNION ALL
  SELECT 'Aleta', 'Poarch', 'apoarch@gmail.com', '03-2691-1298', 'Barrett Burke Wilson Castl', '5 Liberty Ave', 'Fosterville', 'VI', '3557', 'http://www.barrettburkewilsoncastl.com.au', '0419-138-629' UNION ALL
  SELECT 'Jamal', 'Korczynski', 'jamal_korczynski@gmail.com', '02-3877-9654', 'Helricks Inc', '404 Broxton Ave', 'Bateau Bay', 'NS', '2261', 'http://www.helricksinc.com.au', '0427-970-674' UNION ALL
  SELECT 'Luz', 'Broccoli', 'luz_broccoli@hotmail.com', '07-2679-1774', 'Wynn, Mary Ellen Esq', '4 S Main St #285', 'Glenmoral', 'QL', '4719', 'http://www.wynnmaryellenesq.com.au', '0416-525-908' UNION ALL
  SELECT 'Janessa', 'Ruthers', 'janessa@yahoo.com', '02-2367-6845', 'Mackraft Signs', '1255 W Passaic St #1553', 'Bolivia', 'NS', '2372', 'http://www.mackraftsigns.com.au', '0410-358-989' UNION ALL
  SELECT 'Lavonne', 'Esco', 'lavonne.esco@yahoo.com', '03-3474-2120', 'Ansaring Answering Service', '377 Excalibur Dr', 'East Melbourne', 'VI', '3002', 'http://www.ansaringansweringservice.com.au', '0444-359-546' UNION ALL
  SELECT 'Honey', 'Lymaster', 'honey_lymaster@lymaster.net.au', '07-8087-2603', 'Joiner & Goudeau Law Offices', '7 Wilshire Blvd', 'Taringa', 'QL', '4068', 'http://www.joinergoudeaulawoffices.com.au', '0411-717-109' UNION ALL
  SELECT 'Jean', 'Cecchinato', 'jean.cecchinato@gmail.com', '08-5263-2786', 'Cox, J Thomas Jr', '7 Hugh Wallis Rd', 'Koolan Island', 'WA', '6733', 'http://www.coxjthomasjr.com.au', '0448-530-536' UNION ALL
  SELECT 'Katlyn', 'Flitcroft', 'kflitcroft@hotmail.com', '07-1778-9968', 'Bill, Michael M', '7177 E 14th St', 'Maleny', 'QL', '4552', 'http://www.billmichaelm.com.au', '0465-519-356' UNION ALL
  SELECT 'Cassie', 'Soros', 'csoros@gmail.com', '08-2666-6390', 'A B C Tank Co', '67765 W 11th St', 'Yelverton', 'WA', '6280', 'http://www.abctankco.com.au', '0423-281-356' UNION ALL
  SELECT 'Rolf', 'Gene', 'rolf_gene@gene.com.au', '02-4458-2810', 'Jolley, Mark A Cpa', '99968 Merced St #79', 'Flinders', 'NS', '2529', 'http://www.jolleymarkacpa.com.au', '0482-882-653' UNION ALL
  SELECT 'Darnell', 'Moothart', 'darnell_moothart@yahoo.com', '02-3996-9188', 'Melco Embroidery Systems', '40 E 19th Ave', 'Empire Bay', 'NS', '2257', 'http://www.melcoembroiderysystems.com.au', '0419-656-117' UNION ALL
  SELECT 'Cherilyn', 'Fraize', 'cherilyn_fraize@fraize.net.au', '02-4873-1914', 'Witchs Brew', '84826 Plaza Dr', 'Rose Bay North', 'NS', '2030', 'http://www.witchsbrew.com.au', '0468-743-337' UNION ALL
  SELECT 'Lynda', 'Lazzaro', 'lynda.lazzaro@gmail.com', '03-4933-4205', 'Funding Equity Corp', '20214 W Main St', 'Macks Creek', 'VI', '3971', 'http://www.fundingequitycorp.com.au', '0472-315-303' UNION ALL
  SELECT 'Leigha', 'Capelli', 'leigha.capelli@capelli.com.au', '07-4823-9785', 'Saturn Of Delray', '8039 Howard Ave', 'East Toowoomba', 'QL', '4350', 'http://www.saturnofdelray.com.au', '0432-580-634' UNION ALL
  SELECT 'Delfina', 'Binnie', 'delfina_binnie@binnie.net.au', '08-3692-5784', 'Motel 6', '8 Austin Bluffs Pky', 'Bimbijy', 'WA', '6472', 'http://www.motel.com.au', '0460-951-322' UNION ALL
  SELECT 'Carlota', 'Gephardt', 'carlota.gephardt@gephardt.com.au', '02-5078-4389', 'Ultimate In Womens Apparel The', '96605 Pioneer Rd', 'Kundabung', 'NS', '2441', 'http://www.ultimateinwomensapparelthe.com.au', '0415-230-654' UNION ALL
  SELECT 'Alida', 'Helger', 'alida@helger.com.au', '07-1642-3251', 'Ballinger, Maria Chan Esq', '6 Hope Rd #10', 'Pinnacle', 'QL', '4741', 'http://www.ballingermariachanesq.com.au', '0412-699-567' UNION ALL
  SELECT 'Donte', 'Resureccion', 'donte.resureccion@yahoo.com', '07-2373-6048', 'N E Industrial Distr Inc', '65898 E St Nw', 'Watsonville', 'QL', '4887', 'http://www.neindustrialdistrinc.com.au', '0478-459-448' UNION ALL
  SELECT 'Lou', 'Kriner', 'lou.kriner@hotmail.com', '02-7328-3350', 'Joondeph, Jerome J Esq', '39 Broad St', 'Seaforth', 'NS', '2092', 'http://www.joondephjeromejesq.com.au', '0496-387-592' UNION ALL
  SELECT 'Dortha', 'Vrieze', 'dortha@vrieze.net.au', '03-1981-6209', 'Art In Forms', '654 Seguine Ave', 'White Hills', 'TA', '7258', 'http://www.artinforms.com.au', '0430-222-319' UNION ALL
  SELECT 'Genevive', 'Sanborn', 'genevive@hotmail.com', '02-6246-5711', 'Central Hudson Ent Corp', '78 31st St', 'Bellangry', 'NS', '2446', 'http://www.centralhudsonentcorp.com.au', '0431-413-930' UNION ALL
  SELECT 'Alease', 'Strawbridge', 'alease_strawbridge@strawbridge.com.au', '07-3760-1546', 'Marscher, William F Iii', '35673 Annapolis Rd #190', 'Ascot', 'QL', '4359', 'http://www.marscherwilliamfiii.com.au', '0497-868-525' UNION ALL
  SELECT 'Veda', 'Mishkin', 'veda.mishkin@mishkin.com.au', '07-6034-2422', 'Smith, Sean O Esq', '98247 Russell Blvd', 'Stafford Heights', 'QL', '4053', 'http://www.smithseanoesq.com.au', '0474-823-917' UNION ALL
  SELECT 'Craig', 'Vandersloot', 'craig_vandersloot@yahoo.com', '02-5487-7528', 'Maverik Country Stores Inc', '3 S Willow St #82', 'Bygalorie', 'NS', '2669', 'http://www.maverikcountrystoresinc.com.au', '0492-408-109' UNION ALL
  SELECT 'Lauran', 'Tovmasyan', 'ltovmasyan@tovmasyan.net.au', '02-2546-5344', 'United Christian Cmnty Crdt Un', '199 Maple Ave', 'Boolaroo', 'NS', '2284', 'http://www.unitedchristiancmntycrdtun.com.au', '0459-680-488' UNION ALL
  SELECT 'Aaron', 'Kloska', 'aaron_kloska@kloska.net.au', '07-9896-4827', 'Radecker, H Philip Jr', '423 S Navajo St #56', 'Brookhill', 'QL', '4816', 'http://www.radeckerhphilipjr.com.au', '0473-600-733' UNION ALL
  SELECT 'Francene', 'Skursky', 'francene.skursky@skursky.net.au', '02-5941-3178', 'Cullen, Jack J Esq', '5 30w W #3083', 'Hillston', 'NS', '2675', 'http://www.cullenjackjesq.com.au', '0485-944-417' UNION ALL
  SELECT 'Zena', 'Daria', 'zdaria@gmail.com', '03-2822-8156', 'Kszl Am Radio', '57245 W Union Blvd #25', 'Ivanhoe East', 'VI', '3079', 'http://www.kszlamradio.com.au', '0466-820-981' UNION ALL
  SELECT 'Brigette', 'Breckenstein', 'brigette@breckenstein.com.au', '03-5722-3451', 'Blewett, Yvonne S', '971 Northwest Blvd', 'Caniambo', 'VI', '3630', 'http://www.blewettyvonnes.com.au', '0462-308-800' UNION ALL
  SELECT 'Jeniffer', 'Jezek', 'jeniffer@gmail.com', '03-3268-5102', 'Sheraton Inn Atlanta Northwest', '1089 Pacific Coast Hwy', 'Myrniong', 'VI', '3341', 'http://www.sheratoninnatlantanorthwest.com.au', '0493-644-827' UNION ALL
  SELECT 'Selma', 'Elm', 'selm@elm.net.au', '03-9183-9493', 'Preston, Anne M Esq', '6787 Emerson St', 'Woolamai', 'VI', '3995', 'http://www.prestonannemesq.com.au', '0418-581-770' UNION ALL
  SELECT 'Elenora', 'Handler', 'ehandler@yahoo.com', '08-5671-3318', 'A & A Custom Rubber Stamps', '8 Middletown Blvd #708', 'Wardering', 'WA', '6311', 'http://www.aacustomrubberstamps.com.au', '0481-367-908' UNION ALL
  SELECT 'Nadine', 'Okojie', 'nadine.okojie@okojie.com.au', '08-9746-2341', 'Hirsch, Walter W Esq', '56 Tank Farm Rd', 'Kukerin', 'WA', '6352', 'http://www.hirschwalterwesq.com.au', '0424-801-736' UNION ALL
  SELECT 'Kristin', 'Shiflet', 'kristin@hotmail.com', '03-4529-7210', 'Jones, Peter B Esq', '503 Fulford Ave', 'Somers', 'VI', '3927', 'http://www.jonespeterbesq.com.au', '0488-223-788' UNION ALL
  SELECT 'Melinda', 'Fellhauer', 'melinda_fellhauer@fellhauer.com.au', '03-4387-3800', 'Sterling Institute', '8275 Calle De Industrias', 'Wayatinah', 'TA', '7140', 'http://www.sterlinginstitute.com.au', '0493-258-647' UNION ALL
  SELECT 'Kirby', 'Litherland', 'kirby.litherland@hotmail.com', '07-5284-3845', 'Cross Western Store', '92 South St', 'Alligator Creek', 'QL', '4740', 'http://www.crosswesternstore.com.au', '0480-676-186' UNION ALL
  SELECT 'Kent', 'Ivans', 'kent_ivans@yahoo.com', '07-8661-4016', 'Demer Normann Smith Ltd', '56710 Euclid Ave', 'Camp Mountain', 'QL', '4520', 'http://www.demernormannsmithltd.com.au', '0429-746-524' UNION ALL
  SELECT 'Dan', 'Platz', 'dan_platz@hotmail.com', '07-4306-1623', 'Ny Stat Trial Lawyers Assn', '5210 E Airy St #2', 'Brandy Creek', 'QL', '4800', 'http://www.nystattriallawyersassn.com.au', '0441-978-907' UNION ALL
  SELECT 'Millie', 'Pirkl', 'millie_pirkl@gmail.com', '03-6023-2680', 'Mann, Charles E Esq', '31 Schuyler Ave', 'Sovereign Hill', 'VI', '3350', 'http://www.manncharleseesq.com.au', '0410-688-713' UNION ALL
  SELECT 'Moira', 'Qadir', 'moira.qadir@gmail.com', '08-7687-4883', 'Airnetics Engineering Co', '661 Plummer St #963', 'Arno Bay', 'SA', '5603', 'http://www.airneticsengineeringco.com.au', '0471-106-909' UNION ALL
  SELECT 'Reta', 'Qazi', 'reta.qazi@yahoo.com', '03-1974-9948', 'American Pie Co Inc', '1351 Simpson St', 'Maffra', 'VI', '3860', 'http://www.americanpiecoinc.com.au', '0446-105-779' UNION ALL
  SELECT 'Brittney', 'Lolley', 'brittney@lolley.net.au', '03-4072-7094', 'Brown Chiropractic', '2391 Pacific Blvd', 'Ulverstone', 'TA', '7315', 'http://www.brownchiropractic.com.au', '0451-120-660' UNION ALL
  SELECT 'Leandro', 'Bolka', 'leandro_bolka@hotmail.com', '03-8157-4609', 'Classic Video Duplication Inc', '1886 2nd Ave', 'Wattle Hill', 'TA', '7172', 'http://www.classicvideoduplicationinc.com.au', '0413-530-467' UNION ALL
  SELECT 'Edison', 'Sumera', 'edison.sumera@sumera.net.au', '08-9114-1763', 'Mcclier Corp', '52404 S Clinton Ave', 'Bower', 'SA', '5374', 'http://www.mccliercorp.com.au', '0463-377-181' UNION ALL
  SELECT 'Breana', 'Cassi', 'breana@yahoo.com', '03-2305-8627', 'Gormley Lore Murphy', '405 W Lee St', 'Stonehaven', 'VI', '3221', 'http://www.gormleyloremurphy.com.au', '0495-644-883' UNION ALL
  SELECT 'Jarvis', 'Nicols', 'jarvis@gmail.com', '08-2117-5217', 'Thudium Mail Advg Company', '5656 N Fiesta Blvd', 'East Newdegate', 'WA', '6355', 'http://www.thudiummailadvgcompany.com.au', '0436-246-951' UNION ALL
  SELECT 'Felicitas', 'Orlinski', 'felicitas_orlinski@orlinski.com.au', '03-2451-1896', 'Jen E Distributing Co', '9 Beverly Rd #5', 'Emerald', 'VI', '3782', 'http://www.jenedistributingco.com.au', '0444-326-506' UNION ALL
  SELECT 'Geraldine', 'Neisius', 'geraldine@gmail.com', '03-8243-2999', 'Re/max Realty Services', '96 Armitage Ave', 'Katunga', 'VI', '3640', 'http://www.remaxrealtyservices.com.au', '0440-707-817' UNION ALL
  SELECT 'Alfred', 'Pacleb', 'alfred@pacleb.net.au', '08-9450-7978', 'Roundys Pole Fence Co', '523 N Prince St', 'Willunga', 'SA', '5172', 'http://www.roundyspolefenceco.com.au', '0453-896-533' UNION ALL
  SELECT 'Leatha', 'Block', 'leatha_block@gmail.com', '08-7635-8350', 'Chadds Ford Winery', '6926 Orange Ave', 'Two Rocks', 'WA', '6037', 'http://www.chaddsfordwinery.com.au', '0445-211-162' UNION ALL
  SELECT 'Jacquelyne', 'Rosso', 'jacquelyne.rosso@yahoo.com', '02-4565-6425', 'Barragar, Anne L Esq', '6940 Prospect Pl', 'Caldwell', 'NS', '2710', 'http://www.barragarannelesq.com.au', '0464-763-350' UNION ALL
  SELECT 'Jonelle', 'Epps', 'jepps@hotmail.com', '07-8085-8351', 'Kvoo Radio', '52347 San Fernando Rd', 'Coppabella', 'QL', '4741', 'http://www.kvooradio.com.au', '0461-339-731' UNION ALL
  SELECT 'Rosamond', 'Amlin', 'rosamond.amlin@gmail.com', '02-8007-5034', 'Donovan, William P Esq', '5399 Mcwhorter Rd', 'Calala', 'NS', '2340', 'http://www.donovanwilliampesq.com.au', '0438-251-615' UNION ALL
  SELECT 'Johnson', 'Mcenery', 'johnson@gmail.com', '02-1718-4983', 'Overseas General Business Co', '7 Hall St', 'Nambucca Heads', 'NS', '2448', 'http://www.overseasgeneralbusinessco.com.au', '0446-721-262' UNION ALL
  SELECT 'Elliot', 'Scatton', 'elliot.scatton@hotmail.com', '02-3647-9507', 'Nilad Machining', '5 W Allen St', 'Mccullys Gap', 'NS', '2333', 'http://www.niladmachining.com.au', '0481-878-290' UNION ALL
  SELECT 'Gerri', 'Perra', 'gerri@yahoo.com', '07-6019-7861', 'Byrne, Beth Hobbs', '15126 Goldenwest St', 'Toowoomba South', 'QL', '4350', 'http://www.byrnebethhobbs.com.au', '0416-887-937' UNION ALL
  SELECT 'Rosendo', 'Jelsma', 'rosendo_jelsma@hotmail.com', '08-7712-4785', 'Dileo, Lucille A Esq', '94 I 55s S', 'Applecross', 'WA', '6953', 'http://www.dileolucilleaesq.com.au', '0477-239-199' UNION ALL
  SELECT 'Eveline', 'Brickhouse', 'eveline@yahoo.com', '03-9517-9800', 'First Express', '288 N 168th Ave #266', 'Camberwell West', 'VI', '3124', 'http://www.firstexpress.com.au', '0463-242-525' UNION ALL
  SELECT 'Laurene', 'Bennett', 'laurene_bennett@gmail.com', '08-2969-2908', 'Elbin Internatl Baskets', '5 Richmond Ct', 'North Perth', 'WA', '6906', 'http://www.elbininternatlbaskets.com.au', '0468-234-875' UNION ALL
  SELECT 'Tegan', 'Ebershoff', 'tegan_ebershoff@hotmail.com', '02-6604-9720', 'Multiform Business Printing', '28 Aaronwood Ave Ne', 'Coombell', 'NS', '2470', 'http://www.multiformbusinessprinting.com.au', '0499-760-910' UNION ALL
  SELECT 'Tracie', 'Huro', 'thuro@gmail.com', '07-1951-6787', 'Jin Shin Travel Agency', '39701 6th Ave #1485', 'Pacific Heights', 'QL', '4703', 'http://www.jinshintravelagency.com.au', '0494-620-234' UNION ALL
  SELECT 'Mertie', 'Kazeck', 'mertie.kazeck@kazeck.com.au', '08-5475-6162', 'Electra Gear Divsn Regal', '35662 S University Blvd', 'Guildford', 'WA', '6935', 'http://www.electrageardivsnregal.com.au', '0446-422-535' UNION ALL
  SELECT 'Clare', 'Bortignon', 'clare_bortignon@hotmail.com', '08-9256-6135', 'Sparta Home Center', '73 Dennison St #70', 'Herron', 'WA', '6210', 'http://www.spartahomecenter.com.au', '0423-874-910' UNION ALL
  SELECT 'Rebeca', 'Baley', 'rebeca_baley@hotmail.com', '02-7049-7728', 'R A C E Enterprises Inc', '9591 Bayshore Rd #637', 'Mirrool', 'NS', '2665', 'http://www.raceenterprisesinc.com.au', '0486-736-129' UNION ALL
  SELECT 'Nilsa', 'Pawell', 'npawell@pawell.net.au', '07-8997-8513', 'Jersey Wholesale Fence Co Inc', '57 N Weinbach Ave', 'Bundaberg West', 'QL', '4670', 'http://www.jerseywholesalefencecoinc.com.au', '0486-504-582' UNION ALL
  SELECT 'Samuel', 'Arellanes', 'samuel.arellanes@arellanes.net.au', '02-7995-6787', 'Ryan, Barry M Esq', '286 Santa Rosa Ave', 'Lane Cove', 'NS', '1595', 'http://www.ryanbarrymesq.com.au', '0446-710-661' UNION ALL
  SELECT 'Ivette', 'Servantes', 'ivette_servantes@servantes.com.au', '03-9801-9429', 'Albright, Alexandra W Esq', '446 Woodward Ave #1', 'Reservoir', 'VI', '3073', 'http://www.albrightalexandrawesq.com.au', '0488-109-742' UNION ALL
  SELECT 'Merrilee', 'Fajen', 'merrilee@fajen.net.au', '07-9104-1459', 'Gazette Record', '1 Jenks Ave', 'Upper Kedron', 'QL', '4055', 'http://www.gazetterecord.com.au', '0489-493-308' UNION ALL
  SELECT 'Gianna', 'Eilers', 'gianna@yahoo.com', '03-4328-5253', 'Cochnower Pest Control', '7 Valley Blvd', 'Buchan', 'VI', '3885', 'http://www.cochnowerpestcontrol.com.au', '0418-994-884' UNION ALL
  SELECT 'Hyman', 'Phinazee', 'hphinazee@yahoo.com', '08-5756-9456', 'Als Village Stationers', '42741 Anania Dr', 'Beltana', 'SA', '5730', 'http://www.alsvillagestationers.com.au', '0446-460-955' UNION ALL
  SELECT 'Buck', 'Pascucci', 'buck@yahoo.com', '08-9279-1731', 'A B C Pattern & Foundry Co', '5 Shakespeare Ave', 'Kingswood', 'SA', '5062', 'http://www.abcpatternfoundryco.com.au', '0453-818-566' UNION ALL
  SELECT 'Kenny', 'Leicht', 'kenny@leicht.com.au', '03-6240-8274', 'Gaddis Court Reporting', '245 5th Ave', 'Nicholls Rivulet', 'TA', '7112', 'http://www.gaddiscourtreporting.com.au', '0486-712-822' UNION ALL
  SELECT 'Tabetha', 'Bai', 'tabetha.bai@gmail.com', '07-6813-6477', 'Howard Johnson', '2 Gateway Ctr', 'Upper Mount Gravatt', 'QL', '4122', 'http://www.howardjohnson.com.au', '0438-141-107' UNION ALL
  SELECT 'Alonso', 'Popper', 'alonso_popper@hotmail.com', '03-7036-7071', 'Sunrise Cirby Animal Hospital', '3175 Northwestern Hwy', 'Ridgley', 'TA', '7321', 'http://www.sunrisecirbyanimalhospital.com.au', '0448-235-525' UNION ALL
  SELECT 'Alonzo', 'Polek', 'alonzo_polek@polek.net.au', '03-2403-7167', 'Braid Electric Co', '8 S Plaza Dr', 'Tubbut', 'VI', '3888', 'http://www.braidelectricco.com.au', '0419-100-429' UNION ALL
  SELECT 'Son', 'Magnotta', 'son.magnotta@magnotta.net.au', '02-2376-7653', 'Lisko, Roy K Esq', '8 Collins Ave', 'Collingullie', 'NS', '2650', 'http://www.liskoroykesq.com.au', '0446-520-807' UNION ALL
  SELECT 'Jesusita', 'Druck', 'jesusita@druck.net.au', '08-3605-3943', 'House Of Ing', '9526 Lincoln St', 'Munno Para', 'SA', '5115', 'http://www.houseofing.com.au', '0424-741-530' UNION ALL
  SELECT 'Annice', 'Kunich', 'annice_kunich@kunich.net.au', '02-6769-6153', 'Hassanein, Nesa E Esq', '406 E 4th St', 'Tyagarah', 'NS', '2481', 'http://www.hassaneinnesaeesq.com.au', '0449-775-616' UNION ALL
  SELECT 'Delila', 'Buchman', 'delila.buchman@hotmail.com', '08-1791-7668', 'Frasier Karen L Kolligs', '361 Via Colinas', 'Redgate', 'WA', '6286', 'http://www.frasierkarenlkolligs.com.au', '0454-544-286' UNION ALL
  SELECT 'Iraida', 'Sionesini', 'iraida.sionesini@yahoo.com', '03-4812-5654', 'Arc Of Montgomery County Inc', '94 S Jefferson Rd', 'Modewarre', 'VI', '3240', 'http://www.arcofmontgomerycountyinc.com.au', '0490-625-307' UNION ALL
  SELECT 'Alona', 'Driesenga', 'alona_driesenga@hotmail.com', '08-6777-4159', 'Redington, Thomas P Esq', '8961 S Central Expy', 'Stirling Range National Park', 'WA', '6338', 'http://www.redingtonthomaspesq.com.au', '0428-176-191' UNION ALL
  SELECT 'Lajuana', 'Vonderahe', 'lajuana.vonderahe@yahoo.com', '03-5661-2424', 'Milwaukee Courier Inc', '7 Wiley Post Way', 'Trowutta', 'TA', '7330', 'http://www.milwaukeecourierinc.com.au', '0430-111-686' UNION ALL
  SELECT 'Madelyn', 'Maestri', 'madelyn.maestri@yahoo.com', '02-2129-8131', 'Mervis Steel Co', '60 S 4th St', 'Rouse Hill', 'NS', '2155', 'http://www.mervissteelco.com.au', '0413-115-438' UNION ALL
  SELECT 'Louann', 'Susmilch', 'louann_susmilch@yahoo.com', '07-5035-4889', 'M Sorkin Sanford Associates', '6 Lafayette St #3034', 'Wyandra', 'QL', '4489', 'http://www.msorkinsanfordassociates.com.au', '0489-594-290' UNION ALL
  SELECT 'William', 'Devol', 'wdevol@devol.net.au', '07-4963-5297', 'Low Country Kitchen & Bath', '35 Jefferson Ave', 'Goondi Hill', 'QL', '4860', 'http://www.lowcountrykitchenbath.com.au', '0485-183-917' UNION ALL
  SELECT 'Corazon', 'Grafenstein', 'cgrafenstein@gmail.com', '08-1624-7236', 'Spieker Properties', '3492 88th St', 'Hill River', 'WA', '6521', 'http://www.spiekerproperties.com.au', '0481-500-964' UNION ALL
  SELECT 'Fairy', 'Burket', 'fairy_burket@burket.com.au', '08-9159-7562', 'Walker & Brehn Pa', '20 Sw 28th Ter', 'Fairview Park', 'SA', '5126', 'http://www.walkerbrehnpa.com.au', '0472-806-350' UNION ALL
  SELECT 'Lashawn', 'Urion', 'lurion@yahoo.com', '02-4794-6673', 'U Stor', '6 Argyle Rd', 'Bar Beach', 'NS', '2300', 'http://www.ustor.com.au', '0436-337-750' UNION ALL
  SELECT 'Ronald', 'Gayner', 'rgayner@hotmail.com', '03-7734-9557', 'Moorhead, Michael D Esq', '438 E Reynolds Rd #239', 'University Of Tasmania', 'TA', '7005', 'http://www.moorheadmichaeldesq.com.au', '0499-737-220' UNION ALL
  SELECT 'Shizue', 'Hayduk', 'shayduk@gmail.com', '03-2297-9891', 'R M Sloan Co Inc', '47 Hall St', 'Regent West', 'VI', '3072', 'http://www.rmsloancoinc.com.au', '0456-480-906' UNION ALL
  SELECT 'Nida', 'Fitz', 'nfitz@hotmail.com', '07-7445-2572', 'Star Limousine', '17720 Beach Blvd', 'Oxley', 'QL', '4075', 'http://www.starlimousine.com.au', '0473-495-435' UNION ALL
  SELECT 'Amos', 'Limberg', 'alimberg@limberg.com.au', '03-4539-9131', 'Pioneer Telephone Paging', '8 2nd St', 'Don', 'TA', '7310', 'http://www.pioneertelephonepaging.com.au', '0492-444-651' UNION ALL
  SELECT 'Dexter', 'Prosienski', 'dexter@prosienski.net.au', '03-2454-6523', 'Communication Buildings Amer', '490 Court St', 'Nyora', 'VI', '3987', 'http://www.communicationbuildingsamer.com.au', '0472-707-132' UNION ALL
  SELECT 'Ludivina', 'Calamarino', 'lcalamarino@yahoo.com', '07-5378-4498', 'Components & Equipment Co', '1456 Hill Rd', 'Croydon', 'QL', '4871', 'http://www.componentsequipmentco.com.au', '0482-267-844' UNION ALL
  SELECT 'Ariel', 'Stavely', 'ariel_stavely@stavely.com.au', '03-6510-4788', 'Grand Rapids Right To Life', '6 7th St', 'Scottsdale', 'TA', '7260', 'http://www.grandrapidsrighttolife.com.au', '0441-579-823' UNION ALL
  SELECT 'Haley', 'Vaughn', 'haley_vaughn@vaughn.net.au', '03-7035-6484', 'Martin Nighswander & Mitchell', '29 Nottingham Way #926', 'Montrose', 'VI', '3765', 'http://www.martinnighswandermitchell.com.au', '0430-736-276' UNION ALL
  SELECT 'Raelene', 'Legeyt', 'raelene@gmail.com', '03-4878-1766', 'Barter Systems Inc', '8818 Century Park E #33', 'Oak Park', 'VI', '3046', 'http://www.bartersystemsinc.com.au', '0463-745-755' UNION ALL
  SELECT 'Micaela', 'Shiflett', 'micaela_shiflett@shiflett.com.au', '08-8856-8589', 'W R Grace & Co', '4 Commerce Center Dr', 'Nailsworth', 'SA', '5083', 'http://www.wrgraceco.com.au', '0451-514-152' UNION ALL
  SELECT 'Alpha', 'Prudhomme', 'aprudhomme@hotmail.com', '07-9053-8045', 'Davis, J Mark Esq', '979 S La Cienega Blvd #627', 'Tarong', 'QL', '4615', 'http://www.davisjmarkesq.com.au', '0464-687-686' UNION ALL
  SELECT 'Zack', 'Warman', 'zwarman@gmail.com', '08-9948-2940', 'Roswell Honda Partners', '9181 E 26th St', 'Kensington Park', 'SA', '5068', 'http://www.roswellhondapartners.com.au', '0414-749-850' UNION ALL
  SELECT 'Wilford', 'Pata', 'wilford_pata@pata.net.au', '07-7445-2538', 'Era Mclachlan John Morgan Real', '8855 North Ave', 'Ashmore', 'QL', '4214', 'http://www.eramclachlanjohnmorganreal.com.au', '0445-797-121' UNION ALL
  SELECT 'Carman', 'Robasciotti', 'carman_robasciotti@hotmail.com', '03-1570-9956', 'Vaughan, James J Esq', '4 Spinning Wheel Ln', 'Granya', 'VI', '3701', 'http://www.vaughanjamesjesq.com.au', '0420-704-683' UNION ALL
  SELECT 'Carylon', 'Bayot', 'carylon@gmail.com', '03-8858-7088', 'Wzyx 1440 Am', '5905 S 32nd St', 'Alexandra', 'VI', '3714', 'http://www.wzyxam.com.au', '0475-926-458' UNION ALL
  SELECT 'Gladys', 'Schmale', 'gschmale@schmale.net.au', '08-4564-2338', 'Amercn Spdy Printg Ctrs Ocala', '514 Glenn Way', 'Wirrulla', 'SA', '5661', 'http://www.amercnspdyprintgctrsocala.com.au', '0410-812-931' UNION ALL
  SELECT 'Matilda', 'Peleg', 'matilda.peleg@hotmail.com', '03-1130-5685', 'A & D Pallet Co', '708 S Wilson Way', 'Weymouth', 'TA', '7252', 'http://www.adpalletco.com.au', '0481-222-272' UNION ALL
  SELECT 'Jacklyn', 'Wojnar', 'jacklyn@hotmail.com', '02-6287-8787', 'Nationwide Insurance', '16949 Harristown Rd', 'Summer Hill', 'NS', '2287', 'http://www.nationwideinsurance.com.au', '0434-382-805' UNION ALL
  SELECT 'Tashia', 'Charney', 'tashia.charney@charney.net.au', '07-7659-5711', 'Gallagher, Owen Esq', '9 13th Ave S', 'Shailer Park', 'QL', '4128', 'http://www.gallagherowenesq.com.au', '0450-769-383' UNION ALL
  SELECT 'Dorian', 'Eischens', 'deischens@gmail.com', '02-7739-6600', 'Thomas Somerville Co', '1 Rock Island Rd #8', 'Bell', 'NS', '2786', 'http://www.thomassomervilleco.com.au', '0428-946-162' UNION ALL
  SELECT 'Jesus', 'Merkt', 'jesus_merkt@merkt.net.au', '03-9341-9757', 'Unr Rohn', '1554 Bracken Crk', 'Licola', 'VI', '3858', 'http://www.unrrohn.com.au', '0492-739-675' UNION ALL
  SELECT 'Brandee', 'Svoboda', 'brandee_svoboda@svoboda.net.au', '08-3614-5966', 'Cath Lea For Relig & Cvl Rgts', '7 10th St W', 'Walyormouring', 'WA', '6460', 'http://www.cathleaforreligcvlrgts.com.au', '0419-644-936' UNION ALL
  SELECT 'Edda', 'Mcquaide', 'emcquaide@yahoo.com', '03-1465-8645', 'Eagles Nest', '9 Cron Hill Dr', 'Boronia', 'VI', '3155', 'http://www.eaglesnest.com.au', '0416-330-811' UNION ALL
  SELECT 'Felix', 'Bumby', 'felix.bumby@bumby.com.au', '03-1431-3996', 'Epsilon Products Company', '82 Tremont St #4', 'Baddaginnie', 'VI', '3670', 'http://www.epsilonproductscompany.com.au', '0485-718-212' UNION ALL
  SELECT 'Ben', 'Kellman', 'ben_kellman@kellman.net.au', '02-7968-9243', 'Anderson, Julie A Esq', '30024 Whipple Ave Nw', 'Berrilee', 'NS', '2159', 'http://www.andersonjulieaesq.com.au', '0441-733-809' UNION ALL
  SELECT 'Mickie', 'Upton', 'mickie.upton@yahoo.com', '07-7647-5420', 'Oakey & Oakey Abstrct Burnett', '900 W Wood St', 'Barmaryee', 'QL', '4703', 'http://www.oakeyoakeyabstrctburnett.com.au', '0499-576-666' UNION ALL
  SELECT 'Phung', 'Krome', 'pkrome@yahoo.com', '03-9617-5392', 'Pacific Scientific Co', '847 Norristown Rd', 'Longford', 'TA', '7301', 'http://www.pacificscientificco.com.au', '0417-815-258' UNION ALL
  SELECT 'Lashonda', 'Langanke', 'lashonda@langanke.net.au', '03-9838-7533', 'Krausert, Diane D Esq', '667 S Highland Dr #4', 'Simson', 'VI', '3465', 'http://www.krausertdianedesq.com.au', '0491-793-730' UNION ALL
  SELECT 'Patria', 'Popa', 'patria.popa@gmail.com', '02-6522-3993', 'Blaney Sheet Metal', '21 W 2nd St', 'Killabakh', 'NS', '2429', 'http://www.blaneysheetmetal.com.au', '0493-319-728' UNION ALL
  SELECT 'Nidia', 'Horr', 'nidia@gmail.com', '07-8441-8214', 'Goodknight, David R', '2 W Henrietta Rd #6', 'Paluma', 'QL', '4816', 'http://www.goodknightdavidr.com.au', '0437-170-488' UNION ALL
  SELECT 'Skye', 'Culcasi', 'skye_culcasi@hotmail.com', '03-9075-3104', 'Sullivan & Associates Ltd', '82655 Shawnee Mission Pky #5798', 'Barnawartha', 'VI', '3688', 'http://www.sullivanassociatesltd.com.au', '0451-601-420' UNION ALL
  SELECT 'Kanisha', 'Reyelts', 'kreyelts@yahoo.com', '03-2921-8418', 'American Board Of Surgery', '9 Taylor Ave', 'Holwell', 'TA', '7275', 'http://www.americanboardofsurgery.com.au', '0423-358-965' UNION ALL
  SELECT 'Hector', 'Barras', 'hector.barras@barras.com.au', '03-3017-8394', 'Vernon Manor Hotel', '62 J St #450', 'Combienbar', 'VI', '3889', 'http://www.vernonmanorhotel.com.au', '0438-431-666' UNION ALL
  SELECT 'Stefan', 'Mongolo', 'stefan_mongolo@mongolo.net.au', '08-4563-6214', 'Keith Altizer & Company Pa', '2 Pennington St', 'Port Adelaide', 'SA', '5015', 'http://www.keithaltizercompanypa.com.au', '0495-777-435' UNION ALL
  SELECT 'Francoise', 'Byon', 'francoise@hotmail.com', '08-3914-9404', 'H P Stran & Co', '5496 Ne Columbia Blvd', 'Klemzig', 'SA', '5087', 'http://www.hpstranco.com.au', '0430-357-187' UNION ALL
  SELECT 'Lindy', 'Vandermeer', 'lindy@vandermeer.com.au', '07-9407-9202', 'Southern National Bank S Car', '4244 Lucas Creek Rd', 'Emu Park', 'QL', '4710', 'http://www.southernnationalbankscar.com.au', '0417-325-352' UNION ALL
  SELECT 'Arthur', 'Diniz', 'arthur@gmail.com', '03-2517-3453', 'American Western Mortgage', '79819 Palmetto Ave', 'Travancore', 'VI', '3032', 'http://www.americanwesternmortgage.com.au', '0429-206-122' UNION ALL
  SELECT 'Nicholle', 'Hulme', 'nicholle_hulme@hulme.com.au', '07-7144-4719', 'Oxner Vallerie', '7 N Glenn Rd', 'Whetstone', 'QL', '4387', 'http://www.oxnervallerie.com.au', '0476-915-729' UNION ALL
  SELECT 'Tijuana', 'Mesch', 'tijuana_mesch@gmail.com', '07-1415-9307', 'Rochelle Cold Storage', '61 Center St #8', 'Corella', 'QL', '4570', 'http://www.rochellecoldstorage.com.au', '0444-393-673' UNION ALL
  SELECT 'Lorenza', 'Schoenleber', 'lorenza.schoenleber@schoenleber.com.au', '08-8081-7779', 'Mail Boxes Etc', '562 Nw Cornell Rd', 'Humpty Doo', 'NT', '836', 'http://www.mailboxesetc.com.au', '0445-830-408' UNION ALL
  SELECT 'Iola', 'Baird', 'ibaird@baird.net.au', '08-2325-5905', 'Xandex Inc', '48 General George Patton Dr #8611', 'Goode Beach', 'WA', '6330', 'http://www.xandexinc.com.au', '0482-635-206' UNION ALL
  SELECT 'Sang', 'Weigner', 'sweigner@gmail.com', '03-8912-5755', 'Hander, Deborah G Esq', '9 W Passaic St', 'Heidelberg Rgh', 'VI', '3081', 'http://www.handerdeborahgesq.com.au', '0419-565-485' UNION ALL
  SELECT 'Leonor', 'Prez', 'lprez@prez.com.au', '02-7463-8776', 'Vinco Furniture Inc', '968 Delaware Ave', 'Waterloo', 'NS', '2017', 'http://www.vincofurnitureinc.com.au', '0466-155-348' UNION ALL
  SELECT 'Silvana', 'Whelpley', 'swhelpley@yahoo.com', '03-5175-6193', 'Stamp House', '548 Charmonie Ln', 'Minyip', 'VI', '3392', 'http://www.stamphouse.com.au', '0489-343-254' UNION ALL
  SELECT 'Anthony', 'Stever', 'anthony.stever@hotmail.com', '07-7092-8542', 'Burton & Davis', '91114 Grand Ave', 'Hunchy', 'QL', '4555', 'http://www.burtondavis.com.au', '0495-801-419' UNION ALL
  SELECT 'Wenona', 'Carmel', 'wenona@gmail.com', '02-2832-1545', 'Maier, Kristine M', '44 Bush St', 'Grosvenor Place', 'NS', '1220', 'http://www.maierkristinem.com.au', '0439-849-209' UNION ALL
  SELECT 'Isadora', 'Yurick', 'iyurick@hotmail.com', '07-9595-6042', 'J M Edmunds Co Inc', '6 Mahler Rd', 'Pacific Paradise', 'QL', '4564', 'http://www.jmedmundscoinc.com.au', '0412-855-847' UNION ALL
  SELECT 'Mose', 'Vonseggern', 'mose_vonseggern@hotmail.com', '07-5769-8004', 'Art Concepts', '1 E Main St', 'Hungerford', 'QL', '4493', 'http://www.artconcepts.com.au', '0467-531-601' UNION ALL
  SELECT 'Marci', 'Aveline', 'marci.aveline@hotmail.com', '08-3342-3889', 'Richards, Don R Esq', '58 State St #998', 'Boya', 'WA', '6056', 'http://www.richardsdonresq.com.au', '0447-443-927' UNION ALL
  SELECT 'Michel', 'Hoyne', 'michel@hoyne.com.au', '08-6183-9260', 'B & B Environmental Inc', '11408 Green St', 'Elizabeth West', 'SA', '5113', 'http://www.bbenvironmentalinc.com.au', '0481-466-206' UNION ALL
  SELECT 'Stephania', 'Connon', 'stephania.connon@connon.com.au', '02-5725-5992', 'Printing Delite', '297 8th Ave S #9', 'Gumly Gumly', 'NS', '2652', 'http://www.printingdelite.com.au', '0416-443-185' UNION ALL
  SELECT 'Charolette', 'Turk', 'cturk@yahoo.com', '08-4735-5054', 'Weil Mclain Co', '1 Wyckoff Ave', 'Wilmington', 'SA', '5485', 'http://www.weilmclainco.com.au', '0430-400-899' UNION ALL
  SELECT 'Katie', 'Magro', 'katie_magro@gmail.com', '02-7265-9702', 'Jones, Andrew D Esq', '8 E North Ave', 'Pagewood', 'NS', '2035', 'http://www.jonesandrewdesq.com.au', '0439-832-641' UNION ALL
  SELECT 'Inocencia', 'Angeron', 'inocencia.angeron@angeron.net.au', '03-6268-2647', 'South Adams Savings Bank', '13386 Tamarco Dr #20', 'Tawonga', 'VI', '3697', 'http://www.southadamssavingsbank.com.au', '0482-712-669' UNION ALL
  SELECT 'Nikita', 'Novosel', 'nikita_novosel@novosel.net.au', '03-5716-1053', 'Universal Granite & Marble Inc', '70 W Market St #20', 'Hamlyn Heights', 'VI', '3215', 'http://www.universalgranitemarbleinc.com.au', '0470-886-805' UNION ALL
  SELECT 'Malcolm', 'Gohlke', 'malcolm@yahoo.com', '07-9826-3950', 'Imagelink', '53247 Montgomery St #36', 'Southtown', 'QL', '4350', 'http://www.imagelink.com.au', '0450-887-422' UNION ALL
  SELECT 'Desiree', 'Englund', 'denglund@gmail.com', '08-5289-4594', 'Wrrr Fm', '9495 Central Hwy #66', 'East Bowes', 'WA', '6535', 'http://www.wrrrfm.com.au', '0414-731-630' UNION ALL
  SELECT 'Holley', 'Worland', 'holley.worland@hotmail.com', '02-9885-9593', 'Lord Aeck & Sargent Architects', '2 Route 9', 'Blue Haven', 'NS', '2262', 'http://www.lordaecksargentarchitects.com.au', '0469-808-491' UNION ALL
  SELECT 'Maryann', 'Tates', 'mtates@yahoo.com', '08-1520-4093', 'Dalbec Agency Inc', '75700 Academy Rd', 'Cramphorne', 'WA', '6420', 'http://www.dalbecagencyinc.com.au', '0479-474-917' UNION ALL
  SELECT 'Ling', 'Dibello', 'ling_dibello@yahoo.com', '07-1330-6750', 'Reese Press Inc', '6 Monte Ave', 'Beelbi Creek', 'QL', '4659', 'http://www.reesepressinc.com.au', '0444-175-406' UNION ALL
  SELECT 'Hailey', 'Kopet', 'hailey_kopet@kopet.com.au', '07-3799-1667', 'Stokes, Fred J Esq', '5 France Ave S', 'Tanbar', 'QL', '4481', 'http://www.stokesfredjesq.com.au', '0443-979-875' UNION ALL
  SELECT 'Farrah', 'Malboeuf', 'farrah@malboeuf.com.au', '03-7139-6376', 'Slachter, David Esq', '803 Tupper Ln', 'Ringwood', 'VI', '3134', 'http://www.slachterdavidesq.com.au', '0472-511-112' UNION ALL
  SELECT 'Candra', 'Deritis', 'candra@deritis.net.au', '03-4231-3633', 'Girling Health Care Inc', '43 Nolan St', 'Battery Point', 'TA', '7004', 'http://www.girlinghealthcareinc.com.au', '0439-769-439' UNION ALL
  SELECT 'Reuben', 'Hegland', 'reuben@yahoo.com', '02-1402-5215', 'Welders Supply Service Inc', '6 W 39th St', 'Milton', 'NS', '2538', 'http://www.welderssupplyserviceinc.com.au', '0489-476-500' UNION ALL
  SELECT 'Anglea', 'Andrion', 'anglea.andrion@andrion.com.au', '07-3239-2830', 'Engelbrecht, William H Esq', '910 21st St', 'Laura', 'QL', '4871', 'http://www.engelbrechtwilliamhesq.com.au', '0442-946-694' UNION ALL
  SELECT 'Paris', 'Tuccio', 'paris.tuccio@hotmail.com', '08-8868-2010', 'Nancy Brandon Realtor', '2677 S Jackson St', 'Kidman Park', 'SA', '5025', 'http://www.nancybrandonrealtor.com.au', '0417-281-870' UNION ALL
  SELECT 'Latricia', 'Schmoyer', 'latricia_schmoyer@hotmail.com', '08-5444-3296', 'Flanagan Lieberman Hoffman', '6 Central Ave #4', 'Woodville', 'SA', '5011', 'http://www.flanaganliebermanhoffman.com.au', '0459-945-995' UNION ALL
  SELECT 'Jeffrey', 'Leuenberger', 'jleuenberger@yahoo.com', '08-1267-4421', 'Walter W Lawrence Ink', '564 Almeria Ave #7474', 'Pedler Creek', 'SA', '5171', 'http://www.walterwlawrenceink.com.au', '0436-612-609' UNION ALL
  SELECT 'Dean', 'Vollstedt', 'dvollstedt@vollstedt.com.au', '03-6776-1146', 'Ship It Packaging Inc', '4 Grand St', 'Muckleford South', 'VI', '3462', 'http://www.shipitpackaginginc.com.au', '0492-559-630' UNION ALL
  SELECT 'Deane', 'Haag', 'dhaag@hotmail.com', '02-9718-2944', 'Malsbary Mfg Co', '9 Hamilton Blvd #299', 'Sydney South', 'NS', '1235', 'http://www.malsbarymfgco.com.au', '0453-828-758' UNION ALL
  SELECT 'Edelmira', 'Pedregon', 'edelmira_pedregon@hotmail.com', '08-8484-3223', 'Independence Marine Corp', '50638 Northwest Blvd', 'Bandy Creek', 'WA', '6450', 'http://www.independencemarinecorp.com.au', '0454-458-365' UNION ALL
  SELECT 'Andrew', 'Keks', 'andrew@gmail.com', '03-5251-3153', 'Anthonys', '51 Bridge Ave', 'Carwarp', 'VI', '3494', 'http://www.anthonys.com.au', '0499-155-325' UNION ALL
  SELECT 'Miesha', 'Decelles', 'mdecelles@decelles.net.au', '03-5185-6258', 'L M H Inc', '457 St Sebastian Way #189', 'Eltham', 'VI', '3095', 'http://www.lmhinc.com.au', '0440-277-657' UNION ALL
  SELECT 'Javier', 'Osmer', 'javier@osmer.com.au', '03-8369-6924', 'Milgo Industrial Inc', '6 Ackerman Rd', 'Doncaster East', 'VI', '3109', 'http://www.milgoindustrialinc.com.au', '0489-202-570' UNION ALL
  SELECT 'Kizzy', 'Stangle', 'kizzy.stangle@yahoo.com', '08-1937-3980', 'Rogers, Clay M Esq', '8 W Lake St #1', 'Welbungin', 'WA', '6477', 'http://www.rogersclaymesq.com.au', '0474-218-755' UNION ALL
  SELECT 'Sharan', 'Wodicka', 'sharan@wodicka.net.au', '08-4712-2157', 'Usa Asbestos Co', '8454 6  17 M At Bradleys', 'Shenton Park', 'WA', '6008', 'http://www.usaasbestosco.com.au', '0413-129-424' UNION ALL
  SELECT 'Novella', 'Fritch', 'nfritch@fritch.com.au', '02-2612-1455', 'Voils, Otis V', '5 Ellestad Dr', 'Girraween', 'NS', '2145', 'http://www.voilsotisv.com.au', '0458-731-791' UNION ALL
  SELECT 'German', 'Dones', 'german@gmail.com', '02-2393-3289', 'Oaz Communications', '9 N Nevada Ave', 'Woronora', 'NS', '2232', 'http://www.oazcommunications.com.au', '0495-882-447' UNION ALL
  SELECT 'Robt', 'Blanck', 'robt.blanck@yahoo.com', '03-6517-9318', 'Elan Techlgy A Divsn Mansol', '790 E Wisconsin Ave', 'Woodbury', 'TA', '7120', 'http://www.elantechlgyadivsnmansol.com.au', '0415-690-961' UNION ALL
  SELECT 'Rossana', 'Biler', 'rossana.biler@biler.net.au', '08-9855-2125', 'Norfolk County Newton Lung', '60481 N Clark St', 'Lee Point', 'NT', '810', 'http://www.norfolkcountynewtonlung.com.au', '0461-569-843' UNION ALL
  SELECT 'Henriette', 'Gish', 'henriette.gish@gish.net.au', '03-9935-5135', 'Parker Bush & Lane Pc', '43 E Main St', 'Baranduda', 'VI', '3691', 'http://www.parkerbushlanepc.com.au', '0413-952-396' UNION ALL
  SELECT 'Buffy', 'Stitely', 'buffy_stitely@stitely.com.au', '03-1600-5230', 'Stylecraft Corporation', '5 Madison St #4651', 'Police Point', 'TA', '7116', 'http://www.stylecraftcorporation.com.au', '0451-121-905' UNION ALL
  SELECT 'Christiane', 'Osmanski', 'christiane@gmail.com', '08-9693-9052', 'Bennett, Matthew T Esq', '85 Nw Frontage Rd', 'Williamstown', 'WA', '6430', 'http://www.bennettmatthewtesq.com.au', '0418-813-310' UNION ALL
  SELECT 'Annamae', 'Lothridge', 'alothridge@hotmail.com', '02-1919-3941', 'Highland Meadows Golf Club', '584 Meridian St #997', 'Civic Square', 'AC', '2608', 'http://www.highlandmeadowsgolfclub.com.au', '0495-759-817' UNION ALL
  SELECT 'Vanesa', 'Glockner', 'vanesa@glockner.com.au', '07-7052-4547', 'Nelson, Michael J Esq', '28220 Park Avenue W', 'Taragoola', 'QL', '4680', 'http://www.nelsonmichaeljesq.com.au', '0496-610-278' UNION ALL
  SELECT 'Gennie', 'Pastorino', 'gennie.pastorino@gmail.com', '08-4753-2870', 'Henry, Robert J Esq', '5 Austin Ave', 'Charleston', 'SA', '5244', 'http://www.henryrobertjesq.com.au', '0425-685-933' UNION ALL
  SELECT 'Tamra', 'Kenfield', 'tkenfield@kenfield.com.au', '08-5614-9153', 'Mackraft Signs', '481 925n N #959', 'Kealy', 'WA', '6280', 'http://www.mackraftsigns.com.au', '0438-378-139' UNION ALL
  SELECT 'Tien', 'Kinney', 'tien_kinney@kinney.com.au', '03-7767-6169', 'Orco State Empl Fed Crdt Un', '9 9th St #4', 'Lillimur', 'VI', '3420', 'http://www.orcostateemplfedcrdtun.com.au', '0468-244-186' UNION ALL
  SELECT 'Malcom', 'Leja', 'malcom@leja.com.au', '03-2477-9133', 'Johnsen, Robert U Esq', '56232 Hohman Ave', 'Officer', 'VI', '3809', 'http://www.johnsenrobertuesq.com.au', '0412-417-394' UNION ALL
  SELECT 'Claudia', 'Gawrych', 'claudia@gmail.com', '02-4246-3092', 'Abe Goldstein Ofc Furn', '3 Wall St #26', 'Lilli Pilli', 'NS', '2229', 'http://www.abegoldsteinofcfurn.com.au', '0465-885-293' UNION ALL
  SELECT 'Page', 'Entzi', 'page@entzi.net.au', '03-2484-5500', 'Roland Ashcroft', '63154 Artesia Blvd', 'Blue Rocks', 'TA', '7255', 'http://www.rolandashcroft.com.au', '0497-335-342' UNION ALL
  SELECT 'Lorita', 'Roches', 'lorita_roches@roches.net.au', '08-2358-3115', 'Village Meadows', '32 E Poythress St', 'Westminster', 'WA', '6061', 'http://www.villagemeadows.com.au', '0436-530-773' UNION ALL
  SELECT 'Annita', 'Lek', 'annita.lek@lek.net.au', '08-3384-3181', 'Busada Manufacturing Corp', '86274 Howell Mill Rd Nw', 'Karama', 'NT', '812', 'http://www.busadamanufacturingcorp.com.au', '0426-888-203' UNION ALL
  SELECT 'Eliseo', 'Mikovec', 'emikovec@mikovec.com.au', '02-9829-2371', 'Air Flow Co Inc', '25488 Brickell Ave', 'Ocean Shores', 'NS', '2483', 'http://www.airflowcoinc.com.au', '0497-955-472' UNION ALL
  SELECT 'Tyisha', 'Layland', 'tyisha@yahoo.com', '08-2158-6758', 'Freitag Pc', '270 5th Ave', 'Eastwood', 'SA', '5063', 'http://www.freitagpc.com.au', '0490-478-206' UNION ALL
  SELECT 'Colene', 'Tolbent', 'colene.tolbent@tolbent.net.au', '02-4376-1104', 'Saw Repair & Supply Co', '891 Union Pacific Ave #8463', 'Gloucester', 'NS', '2422', 'http://www.sawrepairsupplyco.com.au', '0466-541-467' UNION ALL
  SELECT 'Francis', 'Senters', 'fsenters@gmail.com', '03-5933-7288', 'Middendorf Meat Quality Foods', '4562 Aurora Ave N', 'Heidelberg Rgh', 'VI', '3081', 'http://www.middendorfmeatqualityfoods.com.au', '0463-965-946' UNION ALL
  SELECT 'Hester', 'Dollins', 'hester_dollins@gmail.com', '02-1622-6412', 'Eagle Plywood & Door Mfrs Inc', '4864 N 168th Ave', 'The Risk', 'NS', '2474', 'http://www.eagleplywooddoormfrsinc.com.au', '0473-268-319' UNION ALL
  SELECT 'Susana', 'Baumgarter', 'susana.baumgarter@yahoo.com', '02-5410-5137', 'Leigh, Lewis R Esq', '7 Elm Ave', 'Yanco', 'NS', '2703', 'http://www.leighlewisresq.com.au', '0491-209-954' UNION ALL
  SELECT 'Dahlia', 'Tummons', 'dahlia.tummons@gmail.com', '03-8216-8640', 'Bare Bones', '6508 Adams St #32', 'Port Fairy', 'VI', '3284', 'http://www.barebones.com.au', '0430-768-907' UNION ALL
  SELECT 'Osvaldo', 'Falvey', 'osvaldo.falvey@yahoo.com', '07-4854-5045', 'Avila, Edward G Esq', '6434 Westchester Ave #28', 'Queenton', 'QL', '4820', 'http://www.avilaedwardgesq.com.au', '0437-545-265' UNION ALL
  SELECT 'Armando', 'Barkley', 'armando.barkley@yahoo.com', '08-8161-8201', 'Oregon Handling Equip Co', '70680 S Rider Trl', 'Watercarrin', 'WA', '6407', 'http://www.oregonhandlingequipco.com.au', '0465-254-471' UNION ALL
  SELECT 'Torie', 'Deras', 'torie_deras@yahoo.com', '07-8371-4719', 'Reynolds, Stephen R Esq', '700 Factory Ave #5649', 'Yeppoon', 'QL', '4703', 'http://www.reynoldsstephenresq.com.au', '0426-991-115' UNION ALL
  SELECT 'Tamie', 'Hollimon', 'tamie@hollimon.com.au', '08-7046-5484', 'Credit Union Of The Rockies', '3 Cherokee St', 'Bobalong', 'WA', '6320', 'http://www.creditunionoftherockies.com.au', '0423-870-900' UNION ALL
  SELECT 'Lettie', 'Hessenthaler', 'lettie_hessenthaler@hessenthaler.net.au', '03-5855-5156', 'Sullivan, John M Esq', '76542 W Bijou St', 'Wurdiboluc', 'VI', '3241', 'http://www.sullivanjohnmesq.com.au', '0454-956-810' UNION ALL
  SELECT 'Chaya', 'Muhlbauer', 'chaya_muhlbauer@muhlbauer.net.au', '08-5943-4352', 'Henry D Lederman', '44009 W 63rd #269', 'North Dandalup', 'WA', '6207', 'http://www.henrydlederman.com.au', '0469-609-289' UNION ALL
  SELECT 'Terina', 'Wildeboer', 'terina_wildeboer@wildeboer.com.au', '03-9107-7349', 'Burress, S Paige Esq', '462 Morris Ave', 'Seddon', 'VI', '3011', 'http://www.burressspaigeesq.com.au', '0438-810-326' UNION ALL
  SELECT 'Lisbeth', 'Agney', 'lisbeth.agney@agney.net.au', '08-1184-4145', 'Dynetics', '1 El Camino Real #603', 'Hindmarsh', 'WA', '6462', 'http://www.dynetics.com.au', '0449-675-754' UNION ALL
  SELECT 'Lillian', 'Dominique', 'lillian@hotmail.com', '07-3594-6592', 'West Pac Environmental Inc', '92417 Arbuckle Ct', 'Julia Creek', 'QL', '4823', 'http://www.westpacenvironmentalinc.com.au', '0490-548-561' UNION ALL
  SELECT 'Corrina', 'Lindblom', 'clindblom@gmail.com', '08-7915-5110', 'Progressive Machine Co', '1 Westpark Dr', 'Salter Point', 'WA', '6152', 'http://www.progressivemachineco.com.au', '0463-118-373' UNION ALL
  SELECT 'Dylan', 'Chaleun', 'dylan_chaleun@hotmail.com', '07-2319-2889', 'Berhanu International Foods', '5 Montana Ave', 'Lilydale', 'QL', '4344', 'http://www.berhanuinternationalfoods.com.au', '0412-631-864' UNION ALL
  SELECT 'Jerrod', 'Luening', 'jerrod_luening@luening.com.au', '02-9554-9632', 'Mcmillan, Regina E Esq', '6629 Main St', 'Tea Gardens', 'NS', '2324', 'http://www.mcmillanreginaeesq.com.au', '0451-857-511' UNION ALL
  SELECT 'Gracie', 'Vicente', 'gracie.vicente@hotmail.com', '03-2444-8291', 'Central Nebraska Home Care', '4 W 18th St', 'Oxley', 'VI', '3678', 'http://www.centralnebraskahomecare.com.au', '0420-776-847' UNION ALL
  SELECT 'Barabara', 'Amedro', 'barabara@amedro.net.au', '02-3449-6894', 'Unicircuit Inc', '95412 16th St #6', 'Yallah', 'NS', '2530', 'http://www.unicircuitinc.com.au', '0467-209-469' UNION ALL
  SELECT 'Delsie', 'Ducos', 'dducos@hotmail.com', '03-1361-8465', 'F H Overseas Export Inc', '17 Kamehameha Hwy', 'Cavendish', 'VI', '3314', 'http://www.fhoverseasexportinc.com.au', '0458-548-827' UNION ALL
  SELECT 'Cassie', 'Digregorio', 'cdigregorio@digregorio.net.au', '02-7922-5417', 'Musgrave, R Todd Esq', '8650 S Valley View Bld #6941', 'Condobolin', 'NS', '2877', 'http://www.musgravertoddesq.com.au', '0433-677-495' UNION ALL
  SELECT 'Tamekia', 'Kajder', 'tamekia_kajder@yahoo.com', '02-7498-8576', 'Santek Inc', '16 Talmadge Rd', 'West Tamworth', 'NS', '2340', 'http://www.santekinc.com.au', '0418-218-423' UNION ALL
  SELECT 'Johanna', 'Saffer', 'johanna@yahoo.com', '02-5970-1748', 'Springer Industrial Equip Inc', '750 Lancaster Ave', 'Campsie', 'NS', '2194', 'http://www.springerindustrialequipinc.com.au', '0477-424-229' UNION ALL
  SELECT 'Sharita', 'Kruk', 'sharita_kruk@gmail.com', '02-7386-4544', 'Long, Robert B Jr', '8808 Northern Blvd', 'Merrylands', 'NS', '2160', 'http://www.longrobertbjr.com.au', '0442-976-132' UNION ALL
  SELECT 'Gerald', 'Chrusciel', 'gerald@chrusciel.net.au', '07-7446-6315', 'Prusax, Maximilian M Esq', '76596 Pleasant Hill Rd', 'Townsville Milpo', 'QL', '4813', 'http://www.prusaxmaximilianmesq.com.au', '0426-833-750' UNION ALL
  SELECT 'Ardella', 'Dieterich', 'ardella.dieterich@yahoo.com', '07-3581-9462', 'Custom Jig Grinding', '94 Delta Fair Blvd #2702', 'Runnymede', 'QL', '4615', 'http://www.customjiggrinding.com.au', '0426-488-593' UNION ALL
  SELECT 'Jackie', 'Kellebrew', 'jackie.kellebrew@kellebrew.com.au', '07-9840-6419', 'Senior Village Nursing Home', '25 Sw End Blvd #609', 'Coominya', 'QL', '4311', 'http://www.seniorvillagenursinghome.com.au', '0448-206-407' UNION ALL
  SELECT 'Mabelle', 'Ramero', 'mabelle.ramero@ramero.net.au', '07-8857-6463', 'Mchale, Joseph G Esq', '15258 W Charleston Blvd', 'Aroona', 'QL', '4551', 'http://www.mchalejosephgesq.com.au', '0427-579-588' UNION ALL
  SELECT 'Jonell', 'Biasi', 'jbiasi@biasi.net.au', '02-5095-2983', 'Pestmaster Services Inc', '75 Ryan Dr #70', 'Duramana', 'NS', '2795', 'http://www.pestmasterservicesinc.com.au', '0486-778-453' UNION ALL
  SELECT 'Linwood', 'Wessner', 'linwood.wessner@hotmail.com', '03-6053-2447', 'Moorhead Associates Inc', '9634 South St', 'Saltwater River', 'TA', '7186', 'http://www.moorheadassociatesinc.com.au', '0487-913-509' UNION ALL
  SELECT 'Samira', 'Heninger', 'sheninger@yahoo.com', '07-9512-2457', 'Alb Inc', '40490 Morrow St', 'Bluff', 'QL', '4702', 'http://www.albinc.com.au', '0443-539-658' UNION ALL
  SELECT 'Julieta', 'Cropsey', 'julieta@yahoo.com', '07-4217-6258', 'Atrium Marketing Inc', '9 Commerce Cir', 'Kingaroy', 'QL', '4610', 'http://www.atriummarketinginc.com.au', '0420-286-404' UNION ALL
  SELECT 'Serita', 'Barthlow', 'serita_barthlow@gmail.com', '08-2941-7378', 'Machine Design Service Inc', '190 34th St #8', 'Nangetty', 'WA', '6522', 'http://www.machinedesignserviceinc.com.au', '0493-703-129' UNION ALL
  SELECT 'Tori', 'Tepley', 'tori@tepley.net.au', '02-2493-1870', 'Mcwhirter Realty Corp', '1036 Malone Rd', 'Uarbry', 'NS', '2329', 'http://www.mcwhirterrealtycorp.com.au', '0449-807-281' UNION ALL
  SELECT 'Nancey', 'Whal', 'nancey@whal.net.au', '02-3248-3283', 'National Mortgage Co', '398 Fort Campbell Blvd #923', 'Cudgera Creek', 'NS', '2484', 'http://www.nationalmortgageco.com.au', '0426-612-418' UNION ALL
  SELECT 'Wilbert', 'Beckes', 'wilbert@hotmail.com', '07-9178-6430', 'Alvis, John W Esq', '2799 Cajon Blvd', 'East Nanango', 'QL', '4615', 'http://www.alvisjohnwesq.com.au', '0455-947-547' UNION ALL
  SELECT 'Werner', 'Hermens', 'whermens@hermens.net.au', '03-9085-5714', 'Community Health Law Project', '302 N 10th St #3896', 'Oakleigh South', 'VI', '3167', 'http://www.communityhealthlawproject.com.au', '0462-625-869' UNION ALL
  SELECT 'Sunny', 'Catton', 'scatton@catton.com.au', '07-1217-9907', 'Highway Rentals Inc', '79346 Firestone Blvd', 'Gununa', 'QL', '4871', 'http://www.highwayrentalsinc.com.au', '0450-440-670' UNION ALL
  SELECT 'Keva', 'Moehring', 'keva.moehring@moehring.net.au', '02-9187-4769', 'Rapid Reproductions Printing', '37564 Grace Ln', 'Salamander Bay', 'NS', '2317', 'http://www.rapidreproductionsprinting.com.au', '0448-465-944' UNION ALL
  SELECT 'Mary', 'Dingler', 'mary.dingler@gmail.com', '07-3963-4469', 'Autocrat Inc', '470 W Irving Park Rd', 'Bundaberg North', 'QL', '4670', 'http://www.autocratinc.com.au', '0452-920-972' UNION ALL
  SELECT 'Huey', 'Bukovac', 'huey.bukovac@hotmail.com', '08-5236-2143', 'Venino And Venino', '6 Jefferson St', 'Middleton', 'SA', '5213', 'http://www.veninoandvenino.com.au', '0486-924-555' UNION ALL
  SELECT 'Antonio', 'Eighmy', 'antonio.eighmy@yahoo.com', '03-6144-7318', 'Corporex Companies Inc', '1758 Park Pl', 'Eaglemont', 'VI', '3084', 'http://www.corporexcompaniesinc.com.au', '0438-100-197' UNION ALL
  SELECT 'Quinn', 'Weissbrodt', 'qweissbrodt@weissbrodt.com.au', '02-7239-9923', 'Economy Stainless Supl Co Inc', '7659 Market St', 'Premer', 'NS', '2381', 'http://www.economystainlesssuplcoinc.com.au', '0432-253-912' UNION ALL
  SELECT 'Carin', 'Georgiades', 'cgeorgiades@gmail.com', '08-8343-3550', 'Dgstv Diseases Cnslnts', '95830 Webster Dr', 'Trott Park', 'SA', '5158', 'http://www.dgstvdiseasescnslnts.com.au', '0475-701-279' UNION ALL
  SELECT 'Jill', 'Davoren', 'jill_davoren@davoren.net.au', '07-1698-9047', 'Broaches Inc', '26 Old William Penn Hwy', 'Boynewood', 'QL', '4626', 'http://www.broachesinc.com.au', '0468-451-905' UNION ALL
  SELECT 'Sanjuana', 'Goodness', 'sgoodness@goodness.net.au', '02-2208-2711', 'Woods Manufactured Housing', '343 E Main St', 'Maraylya', 'NS', '2765', 'http://www.woodsmanufacturedhousing.com.au', '0436-444-424' UNION ALL
  SELECT 'Elin', 'Koerner', 'elin_koerner@koerner.com.au', '08-5221-9700', 'Theos Software Corp', '8 Cabot Rd', 'Wayville', 'SA', '5034', 'http://www.theossoftwarecorp.com.au', '0472-281-671' UNION ALL
  SELECT 'Charlena', 'Decamp', 'charlena@gmail.com', '08-7615-2416', 'Stanco Metal Products Inc', '8 Allied Dr', 'Burnside', 'WA', '6285', 'http://www.stancometalproductsinc.com.au', '0469-445-592' UNION ALL
  SELECT 'Annette', 'Breyer', 'abreyer@hotmail.com', '07-5417-9612', 'Xyvision Inc', '26921 Vassar St', 'Daradgee', 'QL', '4860', 'http://www.xyvisioninc.com.au', '0484-806-405' UNION ALL
  SELECT 'Alexis', 'Morguson', 'amorguson@morguson.com.au', '08-1895-1457', 'Carrera Casting Corp', '9 Old York Rd #418', 'Weetulta', 'SA', '5573', 'http://www.carreracastingcorp.com.au', '0475-760-952' UNION ALL
  SELECT 'Princess', 'Saffo', 'princess_saffo@hotmail.com', '02-2656-6234', 'Asian Jewelry', '12398 Duluth St', 'Auburn', 'NS', '1835', 'http://www.asianjewelry.com.au', '0467-758-219' UNION ALL
  SELECT 'Ashton', 'Sutherburg', 'asutherburg@gmail.com', '03-9215-3224', 'Southwark Corporation', '960 S Arroyo Pkwy', 'South Hobart', 'TA', '7004', 'http://www.southwarkcorporation.com.au', '0427-327-492' UNION ALL
  SELECT 'Elmer', 'Redlon', 'elmer@hotmail.com', '02-1075-4690', 'Kdhl Am Radio', '53 Euclid Ave', 'Forbes', 'NS', '2871', 'http://www.kdhlamradio.com.au', '0463-757-229' UNION ALL
  SELECT 'Aliza', 'Akiyama', 'aliza@yahoo.com', '02-9324-7803', 'Kelly, Charles G Esq', '700 Wilmson Rd', 'Forest Reefs', 'NS', '2798', 'http://www.kellycharlesgesq.com.au', '0445-609-538' UNION ALL
  SELECT 'Ora', 'Handrick', 'ora.handrick@gmail.com', '03-8357-4617', 'Fennessey Buick Inc', '466 Hillsdale Ave', 'Rocklands', 'VI', '3401', 'http://www.fennesseybuickinc.com.au', '0411-111-689' UNION ALL
  SELECT 'Brent', 'Ahlborn', 'bahlborn@ahlborn.com.au', '08-4563-9520', 'Apex Bottle Co', '86351 Pine Ave', 'Oaklands Park', 'SA', '5046', 'http://www.apexbottleco.com.au', '0492-994-709' UNION ALL
  SELECT 'Tora', 'Telch', 'tora@telch.net.au', '08-8808-8104', 'Shamrock Food Service', '6139 Contractors Dr #450', 'Buckland Park', 'SA', '5120', 'http://www.shamrockfoodservice.com.au', '0429-419-390' UNION ALL
  SELECT 'Hildred', 'Eilbeck', 'hildred_eilbeck@eilbeck.net.au', '08-2922-4115', 'Plastic Supply Inc', '83 Longhurst Rd', 'Longwood', 'SA', '5153', 'http://www.plasticsupplyinc.com.au', '0463-881-817' UNION ALL
  SELECT 'Dante', 'Freiman', 'dante_freiman@freiman.net.au', '07-1964-4238', 'Gaylord', '76 Daylight Way #7', 'Varsity Lakes', 'QL', '4227', 'http://www.gaylord.com.au', '0432-682-937' UNION ALL
  SELECT 'Emmanuel', 'Avera', 'emmanuel@yahoo.com', '02-1987-8525', 'Bank Of New York Na', '3883 N Central Ave', 'Appin', 'NS', '2560', 'http://www.bankofnewyorkna.com.au', '0498-489-459' UNION ALL
  SELECT 'Keshia', 'Wasp', 'kwasp@wasp.net.au', '08-1683-9243', 'Cole, Gary D Esq', '75 E Main', 'Adelaide River', 'NT', '846', 'http://www.colegarydesq.com.au', '0439-885-729' UNION ALL
  SELECT 'Sherman', 'Mahmud', 'sherman@mahmud.com.au', '02-2621-3361', 'Gencheff, Nelson E Do', '9 Memorial Pky Nw', 'Harris Park', 'NS', '2150', 'http://www.gencheffnelsonedo.com.au', '0468-488-918' UNION ALL
  SELECT 'Lore', 'Brothers', 'lore@hotmail.com', '03-8780-3473', 'American General Finance', '70086 Division St #3', 'Kallista', 'VI', '3791', 'http://www.americangeneralfinance.com.au', '0449-337-116' UNION ALL
  SELECT 'Shawn', 'Weibe', 'shawn@hotmail.com', '03-9480-9611', 'Feutz, James F Esq', '4 Middletown Blvd #33', 'Camena', 'TA', '7316', 'http://www.feutzjamesfesq.com.au', '0456-595-946' UNION ALL
  SELECT 'Karima', 'Cheever', 'karima_cheever@hotmail.com', '02-5977-8561', 'Kwik Kopy Printing & Copying', '20907 65s S', 'Woodberry', 'NS', '2322', 'http://www.kwikkopyprintingcopying.com.au', '0416-963-557' UNION ALL
  SELECT 'Francesco', 'Kloos', 'fkloos@kloos.com.au', '08-1687-4873', 'Borough Clerk', '82136 Post Rd', 'Rocky Gully', 'WA', '6397', 'http://www.boroughclerk.com.au', '0420-185-206' UNION ALL
  SELECT 'King', 'Picton', 'king@hotmail.com', '08-7605-2080', 'U S Rentals', '3 W Pioneer Dr', 'Preston Beach', 'WA', '6215', 'http://www.usrentals.com.au', '0468-322-703' UNION ALL
  SELECT 'Mica', 'Simco', 'msimco@gmail.com', '07-1037-3391', 'Katz Brothers Market Inc', '5610 Holliday Rd', 'Brigalow', 'QL', '4412', 'http://www.katzbrothersmarketinc.com.au', '0471-169-302' UNION ALL
  SELECT 'Lamonica', 'Princiotta', 'lamonica@hotmail.com', '08-5227-2620', 'Grossman Tuchman & Shah', '29133 Hammond Dr #1', 'Beermullah', 'WA', '6503', 'http://www.grossmantuchmanshah.com.au', '0425-628-359' UNION ALL
  SELECT 'Curtis', 'Ware', 'curtis@ware.net.au', '08-6278-9532', 'American Inst Muscl Studies', '51 Greenwood Ave', 'Ridgewood', 'WA', '6030', 'http://www.americaninstmusclstudies.com.au', '0484-331-585' UNION ALL
  SELECT 'Sabrina', 'Rabena', 'sabrina_rabena@hotmail.com', '03-5662-3542', 'Joyces Submarine Sandwiches', '327 Ward Pky', 'Bayles', 'VI', '3981', 'http://www.joycessubmarinesandwiches.com.au', '0486-768-529' UNION ALL
  SELECT 'Denae', 'Saeteun', 'denae_saeteun@hotmail.com', '03-2802-7434', 'Domurad, John M Esq', '52680 W Hwy 55 #59', 'Moorabbin Airport', 'VI', '3194', 'http://www.domuradjohnmesq.com.au', '0410-539-386' UNION ALL
  SELECT 'Anastacia', 'Carranzo', 'anastacia@yahoo.com', '02-6078-3417', 'Debbies Golden Touch', '654 Se 29th St', 'Waratah West', 'NS', '2298', 'http://www.debbiesgoldentouch.com.au', '0481-193-115' UNION ALL
  SELECT 'Irving', 'Plocica', 'irving@hotmail.com', '03-9050-2741', 'Johnston, George M Esq', '65 Clayton Rd', 'Cullulleraine', 'VI', '3496', 'http://www.johnstongeorgemesq.com.au', '0465-434-187' UNION ALL
  SELECT 'Elenor', 'Siefken', 'elenor.siefken@yahoo.com', '07-5085-8138', 'Chateau Sonesta Hotel', '136 2nd Ave N', 'Cairns City', 'QL', '4870', 'http://www.chateausonestahotel.com.au', '0419-509-353' UNION ALL
  SELECT 'Mary', 'Irene', 'mirene@gmail.com', '08-8012-6469', 'Superior Trading Co', '3 N Michigan Ave', 'Warding East', 'WA', '6405', 'http://www.superiortradingco.com.au', '0411-620-740' UNION ALL
  SELECT 'Crista', 'Padua', 'crista_padua@gmail.com', '02-9472-5814', 'Breathitt Fnrl Home & Mnmt Co', '1607 Laurel St', 'North Haven', 'NS', '2443', 'http://www.breathittfnrlhomemnmtco.com.au', '0471-602-916' UNION ALL
  SELECT 'Lawana', 'Yuasa', 'lawana_yuasa@yuasa.net.au', '03-2324-3472', 'Viking Lodge', '77818 Prince Drew Rd', 'Cape Paterson', 'VI', '3995', 'http://www.vikinglodge.com.au', '0456-330-756' UNION ALL
  SELECT 'Maryrose', 'Cove', 'mcove@hotmail.com', '02-8010-8344', 'Brown Bear Bait Company', '1 Vogel Rd', 'Cabramatta', 'NS', '2166', 'http://www.brownbearbaitcompany.com.au', '0440-811-454' UNION ALL
  SELECT 'Lindsey', 'Rathmann', 'lindsey_rathmann@rathmann.com.au', '08-1269-1489', 'Pakzad Advertising', '5 Main St', 'Kongorong', 'SA', '5291', 'http://www.pakzadadvertising.com.au', '0499-741-651' UNION ALL
  SELECT 'Lynelle', 'Koury', 'lynelle.koury@koury.net.au', '03-5213-8219', 'Jean Barbara Ltd', '7696 Carey Ave', 'Digby', 'VI', '3309', 'http://www.jeanbarbaraltd.com.au', '0462-987-152' UNION ALL
  SELECT 'Brice', 'Bogacz', 'bbogacz@hotmail.com', '08-5203-2193', 'Thurmon, Steven P', '76 San Pablo Ave', 'Sedan', 'SA', '5353', 'http://www.thurmonstevenp.com.au', '0467-821-930' UNION ALL
  SELECT 'Laine', 'Killean', 'laine@gmail.com', '03-2813-6426', 'Bussard, Vicki L Esq', '767 9th Ave Sw', 'Braybrook', 'VI', '3019', 'http://www.bussardvickilesq.com.au', '0411-276-383' UNION ALL
  SELECT 'Rachael', 'Crawley', 'rachael@gmail.com', '08-2089-8553', 'Stamell Tabacco & Schager', '82 Hopkins Plz', 'Inkpen', 'WA', '6302', 'http://www.stamelltabaccoschager.com.au', '0459-738-842' UNION ALL
  SELECT 'Della', 'Selestewa', 'della.selestewa@gmail.com', '02-4885-8382', 'Aztech Controls Inc', '64 Prairie Ave', 'Gillieston Heights', 'NS', '2321', 'http://www.aztechcontrolsinc.com.au', '0456-162-659' UNION ALL
  SELECT 'Thomasena', 'Graziosi', 'thomasena@gmail.com', '08-4849-4417', 'Hutchinson Inc', '5 Jackson St', 'Neerabup', 'WA', '6031', 'http://www.hutchinsoninc.com.au', '0434-497-618' UNION ALL
  SELECT 'Frederic', 'Schimke', 'fschimke@schimke.com.au', '03-4829-5695', 'Curtis & Curtis Inc', '705 Stanwix St', 'Mount Martha', 'VI', '3934', 'http://www.curtiscurtisinc.com.au', '0435-982-307' UNION ALL
  SELECT 'Halina', 'Dellen', 'halina.dellen@dellen.com.au', '08-6742-2308', 'Roane, Matthew H Esq', '3318 Buckelew Ave', 'Appila', 'SA', '5480', 'http://www.roanematthewhesq.com.au', '0478-235-293' UNION ALL
  SELECT 'Ryann', 'Riston', 'ryann@hotmail.com', '07-9920-3550', 'Best Western Gloucester Inn', '38494 Port Reading Ave', 'Milton', 'QL', '4064', 'http://www.bestwesterngloucesterinn.com.au', '0423-341-752' UNION ALL
  SELECT 'Shawn', 'Vugteveen', 'svugteveen@vugteveen.net.au', '07-3103-8372', 'Shine', '81 Us Highway 9', 'Etty Bay', 'QL', '4858', 'http://www.shine.com.au', '0480-561-819' UNION ALL
  SELECT 'Leah', 'Milsap', 'leah@milsap.com.au', '08-4040-9192', 'Schwartz, Seymour I Md', '45 Mountain View Ave', 'Lower Hermitage', 'SA', '5131', 'http://www.schwartzseymourimd.com.au', '0452-193-155' UNION ALL
  SELECT 'Ira', 'Zihal', 'ira.zihal@yahoo.com', '07-4724-9987', 'American Express Publshng Corp', '6 W Meadow St', 'Degilbo', 'QL', '4621', 'http://www.americanexpresspublshngcorp.com.au', '0466-603-340' UNION ALL
  SELECT 'Paris', 'Kinnison', 'paris.kinnison@gmail.com', '07-4518-4450', 'Saratoga Land Office', '2 Old Corlies Ave', 'Eastern Heights', 'QL', '4305', 'http://www.saratogalandoffice.com.au', '0454-257-906' UNION ALL
  SELECT 'Shayne', 'Sundahl', 'shayne.sundahl@gmail.com', '08-8587-1196', 'Jaywork, John Terence Esq', '5614 Public Sq', 'Normanville', 'SA', '5204', 'http://www.jayworkjohnterenceesq.com.au', '0443-386-213' UNION ALL
  SELECT 'Ernestine', 'Paavola', 'ernestine.paavola@paavola.com.au', '08-1140-6357', 'Northbros Co Divsn Natl Svc', '6 E Gloria Switch Rd #96', 'Yorkrakine', 'WA', '6409', 'http://www.northbroscodivsnnatlsvc.com.au', '0414-354-955' UNION ALL
  SELECT 'Eleonore', 'Everline', 'eeverline@hotmail.com', '03-5355-5505', 'Psychotherapy Associates', '1 Us Highway 206', 'Kialla East', 'VI', '3631', 'http://www.psychotherapyassociates.com.au', '0497-442-813' UNION ALL
  SELECT 'Misty', 'Leriche', 'mleriche@yahoo.com', '07-5486-1002', 'K J N Advertising Inc', '5289 Ramblewood Dr', 'Glen Boughton', 'QL', '4871', 'http://www.kjnadvertisinginc.com.au', '0414-661-490' UNION ALL
  SELECT 'Na', 'Hodges', 'na_hodges@hotmail.com', '08-8215-1588', 'Automatic Feed Co', '5 Aquarium Pl #1', 'Ongerup', 'WA', '6336', 'http://www.automaticfeedco.com.au', '0444-777-459' UNION ALL
  SELECT 'Juan', 'Knudtson', 'juan@gmail.com', '03-9173-6140', 'Newton Clerk', '466 Lincoln Blvd', 'Clunes', 'VI', '3370', 'http://www.newtonclerk.com.au', '0474-730-764' UNION ALL
  SELECT 'Gerald', 'Kloepper', 'gerald@yahoo.com', '07-4297-4607', 'Pleasantville Finance Dept', '42 United Dr', 'Pierces Creek', 'QL', '4355', 'http://www.pleasantvillefinancedept.com.au', '0437-819-518' UNION ALL
  SELECT 'Desmond', 'Tarkowski', 'desmond_tarkowski@hotmail.com', '07-6793-5954', 'Body Part Connection', '5920 E Arapahoe Rd', 'Andergrove', 'QL', '4740', 'http://www.bodypartconnection.com.au', '0445-121-372' UNION ALL
  SELECT 'Tommy', 'Gennusa', 'tommy@hotmail.com', '02-5444-1961', 'Cooper And Raley', '2 New Brooklyn Rd', 'Concord West', 'NS', '2138', 'http://www.cooperandraley.com.au', '0498-290-826' UNION ALL
  SELECT 'Adrianna', 'Poncio', 'adrianna@poncio.com.au', '07-6113-9653', 'H T Communications Group Ltd', '9 34th Ave #69', 'Bethania', 'QL', '4205', 'http://www.htcommunicationsgroupltd.com.au', '0432-130-553' UNION ALL
  SELECT 'Adaline', 'Galagher', 'adaline.galagher@galagher.com.au', '02-3225-1954', 'Debbie Reynolds Hotel', '32716 N Michigan Ave #82', 'Barooga', 'NS', '3644', 'http://www.debbiereynoldshotel.com.au', '0416-156-336' UNION ALL
  SELECT 'Tammi', 'Schiavi', 'tammi.schiavi@hotmail.com', '08-9707-2679', 'Crew, Robert B Esq', '78 Sw Beaverton Hillsdale H', 'Willetton', 'WA', '6155', 'http://www.crewrobertbesq.com.au', '0425-809-254' UNION ALL
  SELECT 'Virgilio', 'Phay', 'vphay@phay.com.au', '08-8147-9584', 'Reef Encrustaceans', '8494 E 57th St', 'Stratton', 'WA', '6056', 'http://www.reefencrustaceans.com.au', '0460-368-567' UNION ALL
  SELECT 'Emeline', 'Sotelo', 'emeline@gmail.com', '07-7240-6480', 'Reporters Inc', '46 Broadway St', 'Elimbah', 'QL', '4516', 'http://www.reportersinc.com.au', '0451-790-704' UNION ALL
  SELECT 'Marcos', 'Seniff', 'marcos_seniff@gmail.com', '03-6340-5010', 'Arizona Equipment Trnsprt Inc', '228 S Tyler St', 'Emerald', 'VI', '3782', 'http://www.arizonaequipmenttrnsprtinc.com.au', '0464-786-310' UNION ALL
  SELECT 'Yuonne', 'Carabajal', 'ycarabajal@carabajal.com.au', '08-7432-4632', 'Hub Manufacturing Company Inc', '2714 Beach Blvd', 'Changerup', 'WA', '6394', 'http://www.hubmanufacturingcompanyinc.com.au', '0470-345-731' UNION ALL
  SELECT 'Gladis', 'Kazemi', 'gkazemi@kazemi.net.au', '07-6444-3666', 'Dippin Flavors', '3266 Welsh Rd', 'Varsity Lakes', 'QL', '4227', 'http://www.dippinflavors.com.au', '0444-157-156' UNION ALL
  SELECT 'Muriel', 'Drozdowski', 'muriel_drozdowski@hotmail.com', '07-5686-8088', 'Harfred Oil Co', '1 S Maryland Pky', 'Durham Downs', 'QL', '4454', 'http://www.harfredoilco.com.au', '0473-213-595' UNION ALL
  SELECT 'Juliann', 'Dammeyer', 'juliann@gmail.com', '08-3562-8644', 'Wilheim, Kari A Esq', '6 De Belier Rue', 'Bouvard', 'WA', '6210', 'http://www.wilheimkariaesq.com.au', '0492-961-209' UNION ALL
  SELECT 'Reiko', 'Dejarme', 'rdejarme@dejarme.net.au', '08-3733-5261', 'Gilardis Frozen Food', '57869 Alemany Blvd', 'Bentley Dc', 'WA', '6983', 'http://www.gilardisfrozenfood.com.au', '0414-715-583' UNION ALL
  SELECT 'Verdell', 'Garness', 'verdell.garness@yahoo.com', '02-6291-7620', 'Ronald Massingill Pc', '39 Plummer St', 'Thornton', 'NS', '2322', 'http://www.ronaldmassingillpc.com.au', '0474-367-875' UNION ALL
  SELECT 'Arleen', 'Kane', 'arleen.kane@hotmail.com', '07-3476-2066', 'Colosi, Darryl J Esq', '78717 Graves Ln', 'Eagle Farm', 'QL', '4009', 'http://www.colosidarryljesq.com.au', '0430-271-168' UNION ALL
  SELECT 'Launa', 'Vanauken', 'launa@gmail.com', '08-9808-2647', 'Tripuraneni, Prabhakar Md', '30338 S Dunworth St', 'Peake', 'SA', '5301', 'http://www.tripuraneniprabhakarmd.com.au', '0423-125-880' UNION ALL
  SELECT 'Casandra', 'Gordis', 'casandra_gordis@gordis.com.au', '02-5808-6388', 'Carlyle Abstract Co', '6 Walnut St', 'Chippendale', 'NS', '2008', 'http://www.carlyleabstractco.com.au', '0418-327-906' UNION ALL
  SELECT 'Julio', 'Puccini', 'julio@gmail.com', '02-5632-9914', 'Streator Onized Fed Crdt Un', '2244 Franquette Ave', 'Gorokan', 'NS', '2263', 'http://www.streatoronizedfedcrdtun.com.au', '0452-766-262' UNION ALL
  SELECT 'Alica', 'Alerte', 'aalerte@alerte.com.au', '02-6974-7785', 'Valley Hi Bank', '9892 Hernando W', 'Grevillia', 'NS', '2474', 'http://www.valleyhibank.com.au', '0423-831-803' UNION ALL
  SELECT 'Karol', 'Sarkissian', 'ksarkissian@yahoo.com', '02-3490-2407', 'Pep Boys Manny Moe & Jack', '9296 Prince Rodgers Ave', 'Chatsworth', 'NS', '2469', 'http://www.pepboysmannymoejack.com.au', '0419-430-467' UNION ALL
  SELECT 'Wava', 'Ochs', 'wava.ochs@gmail.com', '02-1222-7812', 'Knights Inn', '9 Chandler Ave #355', 'Bawley Point', 'NS', '2539', 'http://www.knightsinn.com.au', '0445-285-375' UNION ALL
  SELECT 'Felicitas', 'Gong', 'fgong@gong.com.au', '07-8516-6453', 'Telcom Communication Center', '173 Howard Ave', 'Weengallon', 'QL', '4497', 'http://www.telcomcommunicationcenter.com.au', '0470-655-661' UNION ALL
  SELECT 'Jamie', 'Kushnir', 'jamie@kushnir.net.au', '02-4623-8120', 'Bell Electric Co', '3216 W Wabansia Ave', 'Tuggeranong Dc', 'AC', '2901', 'http://www.bellelectricco.com.au', '0426-830-817' UNION ALL
  SELECT 'Fidelia', 'Dampier', 'fidelia_dampier@gmail.com', '02-8035-9997', 'Signs Now', '947 W Harrison St #640', 'Dangar Island', 'NS', '2083', 'http://www.signsnow.com.au', '0478-179-538' UNION ALL
  SELECT 'Kris', 'Medich', 'kris.medich@hotmail.com', '03-6589-2556', 'Chieftain Four Inc', '94843 Trabold Rd #59', 'Shannon', 'TA', '7030', 'http://www.chieftainfourinc.com.au', '0469-243-477' UNION ALL
  SELECT 'Lashawna', 'Filan', 'lashawna.filan@filan.net.au', '08-6937-4366', 'South Carolina State Housing F', '8 Lincoln Way W #6698', 'Greenhills', 'WA', '6302', 'http://www.southcarolinastatehousingf.com.au', '0488-276-458' UNION ALL
  SELECT 'Lachelle', 'Andrzejewski', 'lachelle.andrzejewski@andrzejewski.com.au', '02-3416-9617', 'Lucas Cntrl Systems Prod Deeco', '262 Montauk Blvd', 'Cherrybrook', 'NS', '2126', 'http://www.lucascntrlsystemsproddeeco.com.au', '0453-493-910' UNION ALL
  SELECT 'Katy', 'Saltourides', 'katy_saltourides@yahoo.com', '02-3003-1369', 'J C S Iron Works Inc', '5040 Teague Rd #65', 'Junee', 'NS', '2663', 'http://www.jcsironworksinc.com.au', '0481-278-876' UNION ALL
  SELECT 'Bettyann', 'Fernades', 'bettyann@fernades.com.au', '08-2901-3421', 'Lsr Pokorny Schwartz Friedman', '54648 Hylan Blvd #883', 'Tibradden', 'WA', '6532', 'http://www.lsrpokornyschwartzfriedman.com.au', '0427-971-504' UNION ALL
  SELECT 'Valda', 'Levay', 'vlevay@levay.net.au', '08-2401-5672', 'Branom Instrument Co', '7463 Elmwood Park Blvd', 'Tungkillo', 'SA', '5236', 'http://www.branominstrumentco.com.au', '0434-637-971' UNION ALL
  SELECT 'Lynette', 'Beaureguard', 'lynette.beaureguard@hotmail.com', '07-6679-3722', 'Young, Craig C Md', '630 E Plano Pky', 'Tarawera', 'QL', '4494', 'http://www.youngcraigcmd.com.au', '0417-544-301' UNION ALL
  SELECT 'Victor', 'Laroia', 'victor@laroia.net.au', '02-8156-6969', 'Midwest Marketing Inc', '166 N Maple Dr', 'Scotts Head', 'NS', '2447', 'http://www.midwestmarketinginc.com.au', '0421-987-667' UNION ALL
  SELECT 'Pa', 'Badgero', 'pa_badgero@badgero.com.au', '03-1861-5074', 'Korolishin, Michael Esq', '20 Meadow Ln', 'Pakenham Upper', 'VI', '3810', 'http://www.korolishinmichaelesq.com.au', '0480-433-145' UNION ALL
  SELECT 'Dorathy', 'Miskelly', 'dorathy.miskelly@gmail.com', '03-6340-9772', 'Perrysburg Animal Care Inc', '73 Robert S', 'Westerway', 'TA', '7140', 'http://www.perrysburganimalcareinc.com.au', '0432-706-521' UNION ALL
  SELECT 'Rodrigo', 'Schuh', 'rodrigo_schuh@gmail.com', '02-3869-4096', 'Hospitality Design Group', '512 E Idaho St', 'Burrier', 'NS', '2540', 'http://www.hospitalitydesigngroup.com.au', '0430-503-397' UNION ALL
  SELECT 'Stanford', 'Waganer', 'stanford_waganer@waganer.net.au', '08-3200-1670', 'Ciba Geigy Corp', '98021 Harwin Dr', 'East Nabawa', 'WA', '6532', 'http://www.cibageigycorp.com.au', '0479-127-500' UNION ALL
  SELECT 'Michael', 'Orehek', 'michael_orehek@gmail.com', '02-1919-1709', 'Robinson, Michael C Esq', '892 Sw Broadway #8', 'Millers Point', 'NS', '2000', 'http://www.robinsonmichaelcesq.com.au', '0482-613-598' UNION ALL
  SELECT 'Ines', 'Tokich', 'ines_tokich@tokich.net.au', '07-5017-7337', 'De Woskin, Alan E Esq', '192 N Sheffield Ave', 'Bunya Mountains', 'QL', '4405', 'http://www.dewoskinalaneesq.com.au', '0481-799-605' UNION ALL
  SELECT 'Dorinda', 'Markoff', 'dorinda_markoff@hotmail.com', '02-6529-9317', 'Alumi Span Inc', '5 Columbia Pike', 'Mayfield East', 'NS', '2304', 'http://www.alumispaninc.com.au', '0412-153-776' UNION ALL
  SELECT 'Clarence', 'Gabbert', 'clarence.gabbert@gmail.com', '02-4776-1384', 'M C Publishing', '35983 Daubert St', 'Verges Creek', 'NS', '2440', 'http://www.mcpublishing.com.au', '0486-302-652' UNION ALL
  SELECT 'Omer', 'Radel', 'omer_radel@radel.net.au', '08-9919-9540', 'Phoenix Marketing Rep Inc', '678 S Main St', 'Hill River', 'WA', '6521', 'http://www.phoenixmarketingrepinc.com.au', '0439-808-753' UNION ALL
  SELECT 'Winifred', 'Kingshott', 'winifred.kingshott@yahoo.com', '02-5318-1342', 'Remc South Eastern', '532 Saint Marks Ct', 'Marshdale', 'NS', '2420', 'http://www.remcsoutheastern.com.au', '0471-558-187' UNION ALL
  SELECT 'Theresia', 'Salomone', 'theresia_salomone@gmail.com', '07-8250-2277', 'Curran, Carol N Esq', '1337 N 26th St', 'Bundall', 'QL', '4217', 'http://www.currancarolnesq.com.au', '0437-687-429' UNION ALL
  SELECT 'Daisy', 'Kearsey', 'dkearsey@yahoo.com', '08-2127-5977', 'Faber Castell Corporation', '556 Bernardo Cent', 'Mount Nasura', 'WA', '6112', 'http://www.fabercastellcorporation.com.au', '0455-503-406' UNION ALL
  SELECT 'Aretha', 'Bodle', 'aretha_bodle@hotmail.com', '08-7385-2716', 'Palmetto Food Equipment Co Inc', '9561 Chartres St', 'Parndana', 'SA', '5220', 'http://www.palmettofoodequipmentcoinc.com.au', '0481-452-729' UNION ALL
  SELECT 'Bettina', 'Diciano', 'bdiciano@diciano.com.au', '02-3566-7608', 'Greater Ky Corp', '11999 Main St', 'Dripstone', 'NS', '2820', 'http://www.greaterkycorp.com.au', '0472-631-448' UNION ALL
  SELECT 'Omega', 'Mangino', 'omega.mangino@hotmail.com', '03-6623-5501', 'Kajo 1270 Am Radio', '495 Distribution Dr #996', 'Gnotuk', 'VI', '3260', 'http://www.kajoamradio.com.au', '0422-968-757' UNION ALL
  SELECT 'Dana', 'Vock', 'dana_vock@yahoo.com', '02-6689-1150', 'Fried, Monte Esq', '49 Walnut St', 'Yarralumla', 'AC', '2600', 'http://www.friedmonteesq.com.au', '0411-398-917' UNION ALL
  SELECT 'Naomi', 'Tuamoheloa', 'naomi@yahoo.com', '08-6137-1726', 'Dayer Real Estate Group', '85 S Washington Ave', 'Muja', 'WA', '6225', 'http://www.dayerrealestategroup.com.au', '0430-962-223' UNION ALL
  SELECT 'Luis', 'Yerry', 'luis@hotmail.com', '03-4492-4927', 'On Your Feet', '72984 W 1st St', 'Summerhill', 'TA', '7250', 'http://www.onyourfeet.com.au', '0490-571-461' UNION ALL
  SELECT 'Dominga', 'Barchacky', 'dominga.barchacky@hotmail.com', '08-3087-9658', 'South Side Machine Works Inc', '3 Ridge Rd W #949', 'Port Flinders', 'SA', '5495', 'http://www.southsidemachineworksinc.com.au', '0412-225-824' UNION ALL
  SELECT 'Isreal', 'Calizo', 'isreal_calizo@gmail.com', '02-3494-3282', 'Milner Inn', '2 Landmeier Rd', 'Wombeyan Caves', 'NS', '2580', 'http://www.milnerinn.com.au', '0455-472-994' UNION ALL
  SELECT 'Myrtie', 'Korba', 'mkorba@hotmail.com', '08-3174-2706', 'United Mortgage', '82 W Market St', 'Dartnall', 'WA', '6320', 'http://www.unitedmortgage.com.au', '0412-679-832' UNION ALL
  SELECT 'Jodi', 'Naifeh', 'jodi@hotmail.com', '02-6193-5184', 'Cahill, Steven J Esq', '89 N Himes Ave', 'Dural', 'NS', '2330', 'http://www.cahillstevenjesq.com.au', '0488-646-644' UNION ALL
  SELECT 'Pearly', 'Hedstrom', 'pearly@gmail.com', '08-3412-6699', 'G Whitfield Richards Co', '62296 S Elliott Rd #2', 'Wandering', 'WA', '6308', 'http://www.gwhitfieldrichardsco.com.au', '0460-335-582' UNION ALL
  SELECT 'Aileen', 'Menez', 'aileen_menez@menez.net.au', '08-1196-2822', 'Cuzzo, Michael J Esq', '8 S Main St', 'Manjimup', 'WA', '6258', 'http://www.cuzzomichaeljesq.com.au', '0495-852-298' UNION ALL
  SELECT 'Glory', 'Carlo', 'glory_carlo@gmail.com', '07-9265-7183', 'Swanson Travel', '50808 A Pamalee Dr', 'Grange', 'QL', '4051', 'http://www.swansontravel.com.au', '0490-570-424' UNION ALL
  SELECT 'Kathrine', 'Francoise', 'kathrine@yahoo.com', '03-8791-9436', 'Jackson, Brian C', '30691 Poplar Ave #4', 'Indented Head', 'VI', '3223', 'http://www.jacksonbrianc.com.au', '0449-461-650' UNION ALL
  SELECT 'Domingo', 'Mckale', 'domingo_mckale@mckale.net.au', '08-9919-7850', 'Fables Gallery', '80968 Armitage Ave', 'Marla', 'SA', '5724', 'http://www.fablesgallery.com.au', '0418-290-707' UNION ALL
  SELECT 'Julian', 'Laprade', 'jlaprade@laprade.net.au', '07-2627-9976', 'Forsyth Steel Co', '5 Pittsburg St', 'Mungabunda', 'QL', '4718', 'http://www.forsythsteelco.com.au', '0419-587-898' UNION ALL
  SELECT 'Marylou', 'Lofts', 'marylou_lofts@lofts.com.au', '03-1765-4584', 'Lally, Lawrence D Esq', '812 Berry Blvd #96', 'Houston', 'VI', '3128', 'http://www.lallylawrencedesq.com.au', '0473-727-909' UNION ALL
  SELECT 'Louis', 'Brueck', 'louis.brueck@brueck.net.au', '08-5228-3628', 'Sassy Lassie Dolls', '73 12th St', 'Larrakeyah', 'NT', '820', 'http://www.sassylassiedolls.com.au', '0471-229-188' UNION ALL
  SELECT 'Ellsworth', 'Guenther', 'eguenther@hotmail.com', '03-2749-1381', 'Performance Consulting Grp Inc', '27730 American Ave', 'Docklands', 'VI', '3008', 'http://www.performanceconsultinggrpinc.com.au', '0442-173-327' UNION ALL
  SELECT 'Wilburn', 'Lary', 'wlary@lary.net.au', '08-1042-4275', 'Padrick, Comer W Jr', '72 Park Ave', 'Gabbadah', 'WA', '6041', 'http://www.padrickcomerwjr.com.au', '0431-743-155' UNION ALL
  SELECT 'Arlie', 'Borra', 'arlie.borra@gmail.com', '02-1211-3823', 'Analytical Laboratories', '59215 W 80th St', 'Morundah', 'NS', '2700', 'http://www.analyticallaboratories.com.au', '0423-740-512' UNION ALL
  SELECT 'Alysa', 'Lehoux', 'alysa@hotmail.com', '02-1385-3480', 'Signs Of The Times', '186 Geary Blvd #923', 'Trungley Hall', 'NS', '2666', 'http://www.signsofthetimes.com.au', '0475-366-466' UNION ALL
  SELECT 'Marilynn', 'Herrera', 'marilynn.herrera@herrera.net.au', '03-1447-7041', 'Brown, Alan Esq', '717 Midway Pl', 'Tawonga', 'VI', '3697', 'http://www.brownalanesq.com.au', '0474-199-825' UNION ALL
  SELECT 'Scot', 'Jarva', 'scot.jarva@jarva.com.au', '02-9676-4462', 'Biancas La Petite French Bkry', '68 Camden Rd', 'Kingswood', 'NS', '2550', 'http://www.biancaslapetitefrenchbkry.com.au', '0445-480-672' UNION ALL
  SELECT 'Adelaide', 'Ender', 'aender@gmail.com', '07-7538-5504', 'Williams Design Group', '175 N Central Ave', 'Greenslopes', 'QL', '4120', 'http://www.williamsdesigngroup.com.au', '0473-505-816' UNION ALL
  SELECT 'Jackie', 'Borchelt', 'jackie_borchelt@hotmail.com', '03-8055-8668', 'Community Communication Servs', '80896 South Ave', 'Grovedale', 'VI', '3216', 'http://www.communitycommunicationservs.com.au', '0423-545-966' UNION ALL
  SELECT 'Carli', 'Bame', 'carli@yahoo.com', '07-5354-7251', 'Hampton Inn Hotel', '6584 S Bascom Ave #371', 'Elanora', 'QL', '4221', 'http://www.hamptoninnhotel.com.au', '0499-207-236' UNION ALL
  SELECT 'Coletta', 'Thro', 'coletta.thro@thro.net.au', '08-1991-6947', 'Hoffman, Carl Esq', '64865 Main St', 'North Fremantle', 'WA', '6159', 'http://www.hoffmancarlesq.com.au', '0444-915-799' UNION ALL
  SELECT 'Katheryn', 'Lamers', 'katheryn_lamers@gmail.com', '02-4885-1611', 'Sonoco Products Co', '62171 E 6th Ave', 'Fyshwick', 'AC', '2609', 'http://www.sonocoproductsco.com.au', '0497-455-126' UNION ALL
  SELECT 'Santos', 'Wisenbaker', 'swisenbaker@wisenbaker.net.au', '02-2957-4812', 'Brattleboro Printing Inc', '67729 180th St', 'Allworth', 'NS', '2425', 'http://www.brattleboroprintinginc.com.au', '0411-294-588' UNION ALL
  SELECT 'Kimberely', 'Weyman', 'kweyman@weyman.com.au', '02-7091-8948', 'Scientific Agrcltl Svc Inc', '7721 Harrison St', 'Kingsway West', 'NS', '2208', 'http://www.scientificagrcltlsvcinc.com.au', '0441-151-810' UNION ALL
  SELECT 'Earlean', 'Suffern', 'earlean.suffern@suffern.net.au', '02-9653-2199', 'Booster Farms', '5351 E Thousand Oaks Blvd', 'Woodford', 'NS', '2463', 'http://www.boosterfarms.com.au', '0452-941-575' UNION ALL
  SELECT 'Dannette', 'Heimbaugh', 'dannette@gmail.com', '07-8738-4205', 'Accent Copy Center Inc', '5 Carpenter Ave', 'Breakaway', 'QL', '4825', 'http://www.accentcopycenterinc.com.au', '0422-884-614' UNION ALL
  SELECT 'Odelia', 'Hutchin', 'odelia.hutchin@hutchin.com.au', '08-9895-1954', 'Mccaffreys Supermarket', '374 Sunrise Ave', 'Gorrie', 'WA', '6556', 'http://www.mccaffreyssupermarket.com.au', '0472-399-247' UNION ALL
  SELECT 'Lina', 'Schwiebert', 'lina@yahoo.com', '03-3608-5660', 'Chemex Labs Ltd', '68538 N Bentz St #1451', 'Koorlong', 'VI', '3501', 'http://www.chemexlabsltd.com.au', '0487-835-113' UNION ALL
  SELECT 'Fredric', 'Johanningmeie', 'fredric@hotmail.com', '02-1827-1736', 'Galaxie Displays Inc', '23 S Orange Ave #55', 'Wardell', 'NS', '2477', 'http://www.galaxiedisplaysinc.com.au', '0425-214-447' UNION ALL
  SELECT 'Alfreda', 'Delsoin', 'adelsoin@yahoo.com', '07-7369-8849', 'Harris, Eric C Esq', '4373 Washington St', 'Bongeen', 'QL', '4356', 'http://www.harrisericcesq.com.au', '0419-246-570' UNION ALL
  SELECT 'Bernadine', 'Elamin', 'bernadine_elamin@yahoo.com', '02-1815-8700', 'Tarix Printing', '61550 S Figueroa St', 'Waverley', 'NS', '2024', 'http://www.tarixprinting.com.au', '0448-195-542' UNION ALL
  SELECT 'Ming', 'Thaxton', 'mthaxton@gmail.com', '03-4010-1900', 'Chem Aqua', '8 N Town East Blvd', 'Forrest', 'VI', '3236', 'http://www.chemaqua.com.au', '0486-557-304' UNION ALL
  SELECT 'Gracia', 'Pecot', 'gpecot@hotmail.com', '02-8081-3883', 'Kern Valley Printing', '2452 Bango Rd', 'Gundaroo', 'NS', '2620', 'http://www.kernvalleyprinting.com.au', '0472-903-534' UNION ALL
  SELECT 'Yuette', 'Metevelis', 'yuette.metevelis@metevelis.net.au', '08-4700-8894', 'American Speedy Printing Ctrs', '8219 Roswell Rd Ne', 'North Boyanup', 'WA', '6237', 'http://www.americanspeedyprintingctrs.com.au', '0483-854-984' UNION ALL
  SELECT 'Yuriko', 'Kazarian', 'yuriko_kazarian@gmail.com', '08-1109-5346', 'Doane Products Company', '3 Davis Blvd', 'Mouroubra', 'WA', '6472', 'http://www.doaneproductscompany.com.au', '0476-877-991' UNION ALL
  SELECT 'Hyman', 'Hegeman', 'hyman@hotmail.com', '08-9280-9177', 'Jerico Group', '1 S Marginal Rd', 'Flinders University', 'SA', '5042', 'http://www.jericogroup.com.au', '0413-650-821' UNION ALL
  SELECT 'Linette', 'Summerfield', 'linette.summerfield@hotmail.com', '07-7489-7577', 'Mortenson Broadcasting Co', '78 S Robson', 'Crows Nest', 'QL', '4355', 'http://www.mortensonbroadcastingco.com.au', '0453-580-611' UNION ALL
  SELECT 'Jospeh', 'Couzens', 'jospeh.couzens@couzens.com.au', '03-8451-7537', 'M & M Quality Printing', '2749 Van Nuys Blvd', 'Panmure', 'VI', '3265', 'http://www.mmqualityprinting.com.au', '0452-605-630' UNION ALL
  SELECT 'Anna', 'Ovit', 'anna.ovit@hotmail.com', '02-4649-5341', 'Georgia Business Machines', '722 E Liberty St', 'Bygalorie', 'NS', '2669', 'http://www.georgiabusinessmachines.com.au', '0459-496-184' UNION ALL
  SELECT 'Shawnta', 'Woodhams', 'shawnta@woodhams.com.au', '02-5770-8546', 'Leo, Frank M', '9 Gunnison St', 'Oakhurst', 'NS', '2761', 'http://www.leofrankm.com.au', '0410-116-435' UNION ALL
  SELECT 'Ettie', 'Luckenbach', 'ettie@yahoo.com', '08-9378-7021', 'S E M A', '2902 Edison Dr #278', 'Mandurah East', 'WA', '6210', 'http://www.sema.com.au', '0424-568-217' UNION ALL
  SELECT 'Chara', 'Leveston', 'cleveston@gmail.com', '03-2574-8915', 'Arthur Andersen & Co', '72 N Buckeye Ave', 'Daisy Hill', 'VI', '3465', 'http://www.arthurandersenco.com.au', '0415-341-310' UNION ALL
  SELECT 'Lauran', 'Huntsberger', 'lhuntsberger@huntsberger.net.au', '08-2704-3706', 'Triangle Engineering Inc', '41 E Jackson St', 'Willetton', 'WA', '6155', 'http://www.triangleengineeringinc.com.au', '0476-605-889' UNION ALL
  SELECT 'Pansy', 'Todesco', 'pansy_todesco@gmail.com', '03-3233-4255', 'Schmidt, Charles E Jr', '684 William St', 'Tarnagulla', 'VI', '3551', 'http://www.schmidtcharlesejr.com.au', '0467-468-894' UNION ALL
  SELECT 'Georgeanna', 'Silverstone', 'georgeanna@silverstone.net.au', '03-7416-6750', 'Emess Professional Svces', '185 W Guadalupe Rd', 'Steels Creek', 'VI', '3775', 'http://www.emessprofessionalsvces.com.au', '0436-793-916' UNION ALL
  SELECT 'Jesus', 'Liversedge', 'jesus.liversedge@hotmail.com', '02-4418-5927', 'White, Mark A Cpa', '18514 E 4th St #8', 'Broken Head', 'NS', '2481', 'http://www.whitemarkacpa.com.au', '0467-331-796' UNION ALL
  SELECT 'Jamey', 'Tetter', 'jamey.tetter@gmail.com', '07-6073-5039', 'Vicon Corporation', '28 Standiford Ave #6', 'Bundaberg West', 'QL', '4670', 'http://www.viconcorporation.com.au', '0481-690-589' UNION ALL
  SELECT 'Alberta', 'Motter', 'alberta_motter@hotmail.com', '03-1248-8221', 'Turl Engineering Works', '33108 S Yosemite Ct', 'Port Melbourne', 'VI', '3207', 'http://www.turlengineeringworks.com.au', '0491-832-907' UNION ALL
  SELECT 'Ronald', 'Grube', 'ronald.grube@yahoo.com', '08-3305-5436', 'Deep Creek Pharmacy', '73778 Battery St', 'Happy Valley', 'SA', '5159', 'http://www.deepcreekpharmacy.com.au', '0457-126-909' UNION ALL
  SELECT 'Tamala', 'Hickie', 'tamala_hickie@yahoo.com', '03-3695-2399', 'Mister Bagel', '351 Crooks Rd', 'Benambra', 'VI', '3900', 'http://www.misterbagel.com.au', '0432-182-830' UNION ALL
  SELECT 'Gerry', 'Mohrmann', 'gerry_mohrmann@mohrmann.net.au', '08-1399-2471', 'Howard Winig Realty Assocs Inc', '8 Glenn Way #3', 'Brockman', 'WA', '6701', 'http://www.howardwinigrealtyassocsinc.com.au', '0490-947-955' UNION ALL
  SELECT 'Isaiah', 'Kueter', 'ikueter@kueter.com.au', '03-3725-6290', 'Jordan, Mark D Esq', '8 W Virginia St', 'Amphitheatre', 'VI', '3468', 'http://www.jordanmarkdesq.com.au', '0494-282-122' UNION ALL
  SELECT 'Magnolia', 'Overbough', 'moverbough@overbough.com.au', '02-7947-2980', 'Marin Sun Printing', '65484 Bainbridge Rd', 'Penrith', 'NS', '2750', 'http://www.marinsunprinting.com.au', '0488-624-111' UNION ALL
  SELECT 'Ngoc', 'Guglielmina', 'ngoc_guglielmina@hotmail.com', '08-2264-5559', 'Verde, Louis J Esq', '156 Morris St', 'Darke Peak', 'SA', '5642', 'http://www.verdelouisjesq.com.au', '0490-128-503' UNION ALL
  SELECT 'Julene', 'Lauretta', 'julene.lauretta@gmail.com', '03-1036-9594', 'Convum Internatl Corp', '1881 Market St', 'Mole Creek', 'TA', '7304', 'http://www.convuminternatlcorp.com.au', '0451-946-241' UNION ALL
  SELECT 'Magda', 'Lindbeck', 'magda_lindbeck@yahoo.com', '02-3713-3646', 'Thomas Torto Constr Corp', '6 Kings St #4790', 'Emerald Beach', 'NS', '2456', 'http://www.thomastortoconstrcorp.com.au', '0451-383-562' UNION ALL
  SELECT 'Shantell', 'Lizama', 'shantell.lizama@gmail.com', '07-5346-5917', 'Astromatic', '9787 Dunksferry Rd', 'Logan Village', 'QL', '4207', 'http://www.astromatic.com.au', '0459-937-449' UNION ALL
  SELECT 'Audria', 'Piccinich', 'audria.piccinich@gmail.com', '08-9757-2379', 'Kuhio Photo', '13 Blanchard St #996', 'Coober Pedy', 'SA', '5723', 'http://www.kuhiophoto.com.au', '0426-175-813' UNION ALL
  SELECT 'Nickole', 'Derenzis', 'nderenzis@hotmail.com', '02-5573-6627', 'Lehigh Furn Divsn Lehigh', '2 Pompton Ave', 'Berowra Heights', 'NS', '2082', 'http://www.lehighfurndivsnlehigh.com.au', '0480-120-597' UNION ALL
  SELECT 'Grover', 'Reynolds', 'grover.reynolds@gmail.com', '08-7785-3040', 'Okon Inc', '2867 Industrial Way', 'Innaloo', 'WA', '6018', 'http://www.okoninc.com.au', '0447-228-633' UNION ALL
  SELECT 'Rocco', 'Bergstrom', 'rocco@yahoo.com', '08-3987-7521', 'Postlewaite, Jack A Esq', '850 Warwick Blvd #58', 'Leeman', 'WA', '6514', 'http://www.postlewaitejackaesq.com.au', '0457-212-114' UNION ALL
  SELECT 'Ethan', 'Quintero', 'ethan_quintero@quintero.com.au', '08-8280-9492', 'Regent Consultants Corp', '2 Ellis Rd', 'East Damboring', 'WA', '6608', 'http://www.regentconsultantscorp.com.au', '0488-425-192' UNION ALL
  SELECT 'Glynda', 'Sanzenbacher', 'glynda@sanzenbacher.com.au', '03-1051-7865', 'Hinkson Cooper Weaver Inc', '80 Monroe St', 'Kinglake West', 'VI', '3757', 'http://www.hinksoncooperweaverinc.com.au', '0451-639-283' UNION ALL
  SELECT 'Yolande', 'Scrimsher', 'yolande@yahoo.com', '08-2136-2433', 'Spclty Fastening Systems Inc', '71089 Queens Blvd', 'Canning Vale', 'WA', '6155', 'http://www.spcltyfasteningsystemsinc.com.au', '0472-691-355' UNION ALL
  SELECT 'Twanna', 'Sieber', 'twanna@yahoo.com', '07-5235-7319', 'Rudolph, William S Cpa', '66094 Pioneer Rd', 'Upper Glastonbury', 'QL', '4570', 'http://www.rudolphwilliamscpa.com.au', '0451-406-157' UNION ALL
  SELECT 'Rosenda', 'Petteway', 'rosenda@gmail.com', '03-9599-4122', 'Choo Choo Caboose At Jade Bbq', '66 Congress St', 'Caroline Springs', 'VI', '3023', 'http://www.choochoocabooseatjadebbq.com.au', '0438-478-951' UNION ALL
  SELECT 'Lacey', 'Francis', 'lacey.francis@francis.net.au', '07-4119-3981', 'Anthony & Langford', '44 105th Ave', 'Hunchy', 'QL', '4555', 'http://www.anthonylangford.com.au', '0415-135-989' UNION ALL
  SELECT 'Cordie', 'Meikle', 'cordie.meikle@hotmail.com', '02-8727-4906', 'Shapiro Bag Company', '40809 Rockburn Hill Rd', 'Hamlyn Terrace', 'NS', '2259', 'http://www.shapirobagcompany.com.au', '0441-386-796' UNION ALL
  SELECT 'Annalee', 'Graleski', 'annalee.graleski@hotmail.com', '02-6118-8773', 'Lescure Company Inc', '9 Green Rd #5877', 'Darbys Falls', 'NS', '2793', 'http://www.lescurecompanyinc.com.au', '0447-563-450' UNION ALL
  SELECT 'Dana', 'Ladeau', 'dana@ladeau.net.au', '07-3511-9233', 'Higgins, Daniel B Esq', '63 W 41st Ave #93', 'Pinnacle', 'QL', '4741', 'http://www.higginsdanielbesq.com.au', '0480-125-331' UNION ALL
  SELECT 'Wai', 'Raddle', 'wai.raddle@raddle.com.au', '03-4811-3832', 'Dot Pitch Electronics', '2 Stirrup Dr #4907', 'Carlsruhe', 'VI', '3442', 'http://www.dotpitchelectronics.com.au', '0494-517-582' UNION ALL
  SELECT 'Johana', 'Conquest', 'johana@conquest.net.au', '08-6579-7569', 'Henri D Kahn Insurance', '19 Court St', 'Paulls Valley', 'WA', '6076', 'http://www.henridkahninsurance.com.au', '0442-561-392' UNION ALL
  SELECT 'Tomas', 'Fults', 'tomas_fults@fults.net.au', '07-1536-4805', 'Test Tools Inc', '3 Hwy 61 #2491', 'Mirani', 'QL', '4754', 'http://www.testtoolsinc.com.au', '0473-757-584' UNION ALL
  SELECT 'Karon', 'Etzler', 'karon@hotmail.com', '03-6698-8416', 'Rachmel & Company Cpa Pa', '97539 Connecticut Ave Nw #3586', 'Buckland', 'TA', '7190', 'http://www.rachmelcompanycpapa.com.au', '0432-184-936' UNION ALL
  SELECT 'Delbert', 'Houben', 'delbert.houben@hotmail.com', '03-1560-6800', 'Hermann Assocs Inc Safe Mart', '59 Murray Hill Pky', 'Mitta Mitta', 'VI', '3701', 'http://www.hermannassocsincsafemart.com.au', '0417-833-905' UNION ALL
  SELECT 'Ashleigh', 'Rimmer', 'ashleigh.rimmer@hotmail.com', '03-5354-9557', 'Palmer Publications Inc', '15 W 11mile Rd', 'Boat Harbour Beach', 'TA', '7321', 'http://www.palmerpublicationsinc.com.au', '0467-120-854' UNION ALL
  SELECT 'Nenita', 'Mckenna', 'nmckenna@yahoo.com', '02-5059-2649', 'Southern Imperial Inc', '709 New Market St', 'Botany', 'NS', '1455', 'http://www.southernimperialinc.com.au', '0419-730-349' UNION ALL
  SELECT 'Micah', 'Shear', 'mshear@hotmail.com', '08-6270-6829', 'United Water Resources Inc', '324 Shawnee Mission Pky', 'Scaddan', 'WA', '6447', 'http://www.unitedwaterresourcesinc.com.au', '0432-703-516' UNION ALL
  SELECT 'Stefany', 'Figueras', 'stefany@figueras.net.au', '08-2209-8647', 'Burke, Jonathan H Esq', '37 Saint Louis Ave #292', 'Lenswood', 'SA', '5240', 'http://www.burkejonathanhesq.com.au', '0474-975-307' UNION ALL
  SELECT 'Rene', 'Burnsworth', 'rene@burnsworth.net.au', '08-8222-3171', 'Nurses Ofr Newborns', '80289 Victory Ave #9', 'Farrell Flat', 'SA', '5416', 'http://www.nursesofrnewborns.com.au', '0422-183-541' UNION ALL
  SELECT 'Cary', 'Orazine', 'cary.orazine@hotmail.com', '08-7718-8495', 'Para Laboratories', '16 Governors Dr Sw', 'Melrose', 'SA', '5483', 'http://www.paralaboratories.com.au', '0419-720-227' UNION ALL
  SELECT 'Micheal', 'Ocken', 'micheal.ocken@ocken.net.au', '02-9828-4921', 'New Orleans Credit Service Inc', '4 E Aven #284', 'Freemans Waterhole', 'NS', '2323', 'http://www.neworleanscreditserviceinc.com.au', '0449-668-295' UNION ALL
  SELECT 'Frederick', 'Tamburello', 'frederick.tamburello@hotmail.com', '03-4800-7102', 'Signs By Berry', '262 8th St', 'Simpsons Bay', 'TA', '7150', 'http://www.signsbyberry.com.au', '0466-921-460' UNION ALL
  SELECT 'Burma', 'Noa', 'burma.noa@gmail.com', '03-6438-4586', 'Saum, Scott J Esq', '79 State Route 35', 'Ripponlea', 'VI', '3185', 'http://www.saumscottjesq.com.au', '0448-770-746' UNION ALL
  SELECT 'Cherry', 'Roh', 'cherry_roh@yahoo.com', '08-5175-3585', 'Ulrich, Lawrence M Esq', '75 Blackington Ave', 'North Cascade', 'WA', '6445', 'http://www.ulrichlawrencemesq.com.au', '0476-917-926' UNION ALL
  SELECT 'Gabriele', 'Frabotta', 'gabriele_frabotta@gmail.com', '03-2689-6049', 'Stewart Levine & Davis', '6 Abbott Rd', 'Ensay', 'VI', '3895', 'http://www.stewartlevinedavis.com.au', '0460-834-526' UNION ALL
  SELECT 'Clement', 'Chee', 'clement@hotmail.com', '03-2775-4083', 'Bark Eater Inn', '5159 Saint Ann St', 'Golden Point', 'VI', '3451', 'http://www.barkeaterinn.com.au', '0485-660-179' UNION ALL
  SELECT 'Beckie', 'Apodace', 'bapodace@gmail.com', '02-5630-3114', 'Reich, Richard J Esq', '26 Ripley St #5444', 'Middle Cove', 'NS', '2068', 'http://www.reichrichardjesq.com.au', '0469-490-273' UNION ALL
  SELECT 'Catrice', 'Fowlkes', 'cfowlkes@hotmail.com', '07-9032-5149', 'Kappus Co', '39828 Abbott Rd', 'Waterfront Place', 'QL', '4001', 'http://www.kappusco.com.au', '0418-429-485' UNION ALL
  SELECT 'Richelle', 'Remillard', 'richelle.remillard@remillard.net.au', '08-6831-6370', 'Terri, Teresa Hutchens Esq', '2495 Beach Blvd #557', 'Buraminya', 'WA', '6452', 'http://www.territeresahutchensesq.com.au', '0416-611-806' UNION ALL
  SELECT 'Cherri', 'Miccio', 'cherri_miccio@gmail.com', '07-5626-7937', 'Hong Iwai Hulbert & Kawano', '3 Bustleton Ave', 'Balnagowan', 'QL', '4740', 'http://www.hongiwaihulbertkawano.com.au', '0476-736-800' UNION ALL
  SELECT 'Dorethea', 'Taketa', 'dtaketa@taketa.net.au', '07-2209-2731', 'Fraser Dante Ltd', '7 N 4th St', 'Lower Cressbrook', 'QL', '4313', 'http://www.fraserdanteltd.com.au', '0436-606-487' UNION ALL
  SELECT 'Barb', 'Latina', 'blatina@hotmail.com', '08-8506-7259', 'Die Craft Stamping', '1 National Plac #6619', 'Larrakeyah', 'NT', '820', 'http://www.diecraftstamping.com.au', '0443-657-148' UNION ALL
  SELECT 'Bettye', 'Meray', 'bmeray@yahoo.com', '03-9424-2956', 'Sako, Bradley T Esq', '248 Academy Rd', 'Middleton', 'TA', '7163', 'http://www.sakobradleytesq.com.au', '0420-742-142' UNION ALL
  SELECT 'Sherrell', 'Sprowl', 'sherrell_sprowl@hotmail.com', '02-4074-4461', 'Country Comfort', '2 State Hwy', 'Oak Flats', 'NS', '2529', 'http://www.countrycomfort.com.au', '0417-795-558' UNION ALL
  SELECT 'Ruth', 'Niglio', 'ruth.niglio@hotmail.com', '07-5128-8956', 'Amberley Suite Hotels', '6 W Cornelia Ave', 'Orange Hill', 'QL', '4455', 'http://www.amberleysuitehotels.com.au', '0428-843-553' UNION ALL
  SELECT 'Alva', 'Shoulders', 'alva@gmail.com', '08-8329-4211', 'Warren Leadership', '461 S Fannin Ave', 'Welshpool', 'WA', '6106', 'http://www.warrenleadership.com.au', '0471-940-163' UNION ALL
  SELECT 'Carri', 'Palaspas', 'carri_palaspas@palaspas.net.au', '08-6069-1579', 'Alexander, David T Esq', '51255 Tea Town Rd #9', 'Minnenooka', 'WA', '6532', 'http://www.alexanderdavidtesq.com.au', '0499-165-889' UNION ALL
  SELECT 'Onita', 'Milbrandt', 'onita.milbrandt@milbrandt.com.au', '02-1157-3829', 'Fairfield Inn By Marriott', '93 Bloomfield Ave #829', 'Wagga Wagga South', 'NS', '2650', 'http://www.fairfieldinnbymarriott.com.au', '0485-105-744' UNION ALL
  SELECT 'Jessenia', 'Sarp', 'jsarp@hotmail.com', '08-8878-5994', 'Skyline Lodge & Restaurant', '5775 Mechanic St #517', 'Wansbrough', 'WA', '6320', 'http://www.skylinelodgerestaurant.com.au', '0422-775-760' UNION ALL
  SELECT 'Tricia', 'Peressini', 'tperessini@yahoo.com', '08-4326-1560', 'Aviation Design', '3 Industrial Blvd', 'Pintharuka', 'WA', '6623', 'http://www.aviationdesign.com.au', '0484-192-990' UNION ALL
  SELECT 'Stephaine', 'Manin', 'stephaine_manin@yahoo.com', '07-2031-6566', 'Malmon, Alvin S Esq', '8202 Cornwall Rd', 'Eumundi', 'QL', '4562', 'http://www.malmonalvinsesq.com.au', '0438-847-885' UNION ALL
  SELECT 'Florinda', 'Gudgel', 'fgudgel@gudgel.com.au', '02-2501-8301', 'Transit Cargo Services Inc', '53597 W Clarendon Ave', 'Halton', 'NS', '2311', 'http://www.transitcargoservicesinc.com.au', '0444-376-606' UNION ALL
  SELECT 'Marsha', 'Farnham', 'marsha@farnham.com.au', '02-5402-8024', 'Comfort Inn Of Revere', '577 Cleveland Ave', 'Glenmore Park', 'NS', '2745', 'http://www.comfortinnofrevere.com.au', '0470-386-894' UNION ALL
  SELECT 'Josefa', 'Oakland', 'josefa_oakland@oakland.com.au', '07-5404-6221', 'Duncan & Associates', '259 1st Ave', 'Mccutcheon', 'QL', '4856', 'http://www.duncanassociates.com.au', '0493-826-469' UNION ALL
  SELECT 'Deeann', 'Nicklous', 'deeann_nicklous@gmail.com', '07-6382-5073', 'Philip Kingsley Trichological', '79 Mechanic St', 'Pimpimbudgee', 'QL', '4615', 'http://www.philipkingsleytrichological.com.au', '0440-980-784' UNION ALL
  SELECT 'Jeannetta', 'Vonstaden', 'jvonstaden@gmail.com', '02-8222-9319', 'Burlington Homes Of Maine', '269 Executive Dr', 'Ilford', 'NS', '2850', 'http://www.burlingtonhomesofmaine.com.au', '0435-530-318' UNION ALL
  SELECT 'Desmond', 'Amuso', 'desmond@hotmail.com', '02-1706-8506', 'Carson, Scott W Esq', '79 Runamuck Pl', 'Caparra', 'NS', '2429', 'http://www.carsonscottwesq.com.au', '0427-106-677' UNION ALL
  SELECT 'Trina', 'Bakey', 'tbakey@bakey.com.au', '07-5922-1983', 'Dewitt Cnty Fed Svngs & Ln', '31 Guilford Rd #7904', 'Duaringa', 'QL', '4712', 'http://www.dewittcntyfedsvngsln.com.au', '0495-376-112' UNION ALL
  SELECT 'Ramonita', 'Picotte', 'ramonita_picotte@yahoo.com', '02-4360-8467', 'Art Material Services Inc', '504 Steve Dr', 'Weston', 'NS', '2326', 'http://www.artmaterialservicesinc.com.au', '0479-654-997' UNION ALL
  SELECT 'Temeka', 'Bodine', 'temeka.bodine@gmail.com', '02-2581-7479', 'Consolidated Manufacturing Inc', '407 E 57th Ave', 'Clunes', 'NS', '2480', 'http://www.consolidatedmanufacturinginc.com.au', '0452-835-388' UNION ALL
  SELECT 'Bea', 'Iida', 'bea_iida@iida.net.au', '07-6984-9278', 'Reliance Credit Union', '72 W Ripley Ave', 'Oakey', 'QL', '4401', 'http://www.reliancecreditunion.com.au', '0493-653-304' UNION ALL
  SELECT 'Soledad', 'Mockus', 'soledad_mockus@yahoo.com', '02-1291-8182', 'Sinclair Machine Products Inc', '75 Elm Rd #1190', 'Barton', 'AC', '2600', 'http://www.sinclairmachineproductsinc.com.au', '0444-126-746' UNION ALL
  SELECT 'Margurite', 'Okon', 'margurite.okon@hotmail.com', '03-9721-7313', 'Kent, Wendy M Esq', '32 Broadway St', 'Lanena', 'TA', '7275', 'http://www.kentwendymesq.com.au', '0442-360-982' UNION ALL
  SELECT 'Artie', 'Saine', 'artie_saine@yahoo.com', '03-3457-2524', 'Dixon, Eric D Esq', '41 Washington Blvd', 'Cora Lynn', 'VI', '3814', 'http://www.dixonericdesq.com.au', '0433-550-202' UNION ALL
  SELECT 'Major', 'Studwell', 'major@gmail.com', '07-1377-6898', 'Wood Sign & Banner Co', '5 Buford Hwy Ne #3', 'Allora', 'QL', '4362', 'http://www.woodsignbannerco.com.au', '0426-784-480' UNION ALL
  SELECT 'Veronika', 'Buchauer', 'veronika.buchauer@buchauer.net.au', '02-4202-5191', 'Adkins, Russell Esq', '6 Flex Ave', 'Willow Tree', 'NS', '2339', 'http://www.adkinsrussellesq.com.au', '0434-402-895' UNION ALL
  SELECT 'Christene', 'Cisney', 'christene@hotmail.com', '03-3630-2467', 'Danform Shoe Stores', '21058 Massillon Rd', 'Keilor Downs', 'VI', '3038', 'http://www.danformshoestores.com.au', '0451-465-174' UNION ALL
  SELECT 'Miles', 'Feldner', 'miles@hotmail.com', '07-8561-5894', 'Antietam Cable Television', '28465 Downey Ave #4238', 'Barringun', 'QL', '4490', 'http://www.antietamcabletelevision.com.au', '0475-337-188' UNION ALL
  SELECT 'Julio', 'Mikel', 'julio.mikel@mikel.net.au', '02-6995-9902', 'Lombardi Bros Inc', '2803 N Catalina Ave', 'Pilliga', 'NS', '2388', 'http://www.lombardibrosinc.com.au', '0464-594-316' UNION ALL
  SELECT 'Aide', 'Ghera', 'aide.ghera@ghera.com.au', '02-3738-7508', 'Nathaniel Electronics', '22 Livingston Ave', 'Rhodes', 'NS', '2138', 'http://www.nathanielelectronics.com.au', '0443-448-467' UNION ALL
  SELECT 'Noelia', 'Brackett', 'noelia@brackett.net.au', '08-3773-3770', 'Rodriguez, Joseph A Esq', '403 Conn Valley Rd', 'Castletown', 'WA', '6450', 'http://www.rodriguezjosephaesq.com.au', '0454-135-614' UNION ALL
  SELECT 'Lenora', 'Delacruz', 'lenora@delacruz.net.au', '02-7862-5151', 'Stilling, William J Esq', '5400 Market St', 'Turill', 'NS', '2850', 'http://www.stillingwilliamjesq.com.au', '0454-434-110';
  GO

