use master;
Go
IF EXISTS (SELECT name FROM master.dbo.sysdatabases WHERE name = N'Projekat')
DROP DATABASE Projekat
Go
create database Projekat
go
use Projekat
go
CREATE TABLE [Kategorije]
([ID_kategorije] [int] NOT NULL,
[Nazivkat] [varchar] (50) NOT NULL,
[Padajuci_meni] [varchar] (50) NOT NULL,
PRIMARY KEY([ID_kategorije]));
CREATE TABLE [Radno_Mesto]
([Sifra] [int] NOT NULL,
[Naziv] [varchar] (50) NOT NULL,
PRIMARY KEY([Sifra]));
CREATE TABLE [Proizvodjac]
([ID_proizvodjaca] [int] NOT NULL,
[Ime] [varchar] (50) NOT NULL,
PRIMARY KEY([ID_proizvodjaca]));
CREATE TABLE [Garancija]
([Serijskibr] [int] NOT NULL,
[Ime] [varchar] (50) NOT NULL,
[Datum] [date] NOT NULL,
[Duzina_trajanja] [int] NOT NULL,
[Mesto] [varchar] (50) NOT NULL,
[Model] [varchar] (50) NOT NULL,
PRIMARY KEY([Serijskibr]));
CREATE TABLE [Radnik]
([JMBG_radnika] [char] (13) NOT NULL,
[Ime] [varchar] (50) NOT NULL,
[Prezime] [varchar] (50) NOT NULL,
PRIMARY KEY([JMBG_radnika]));
CREATE TABLE [Katalog]
([Serijski_broj] [int] NOT NULL,
[Slike_proizvoda] [int] NOT NULL,
PRIMARY KEY([Serijski_broj]));



CREATE TABLE[Porez]
([ID_poreza] [int] NOT NULL,
[Naziv] [varchar] (50) NOT NULL,
[Datum_od] [date] NOT NULL,
[Datum_do] [date] NOT NULL,
PRIMARY KEY([ID_poreza]));
CREATE TABLE [Poreska_Stopa]
([Rb] [int] NOT NULL,
[Datod] [date] NOT NULL,
[Datdo] [date] NOT NULL ,
[Procenat] [int] NOT NULL,
[ID_poreza] [int] NOT NULL,
PRIMARY KEY ([Rb],[ID_poreza]),
FOREIGN KEY ([ID_poreza])REFERENCES[Porez]([ID_poreza]));
CREATE TABLE [Proizvod]
([Sif] [int] NOT NULL,
[Cena] [money] NOT NULL,
[Ime] [varchar] (50) NOT NULL ,
[Serijskibr] [int] NOT NULL,
[ID_poreza] [int] NOT NULL,
PRIMARY KEY ([Sif]),
FOREIGN KEY ([ID_poreza])REFERENCES[Porez]([ID_poreza]),
FOREIGN KEY ([Serijskibr])REFERENCES[Garancija]([Serijskibr]));
CREATE TABLE [Napravio]
([Sif] [int] NOT NULL,
[ID_proizvodjaca] [int] NOT NULL,
PRIMARY KEY ([Sif],[ID_proizvodjaca]),
FOREIGN KEY ([Sif])REFERENCES[Proizvod]([Sif]),
FOREIGN KEY ([ID_proizvodjaca])REFERENCES[Proizvodjac]([ID_proizvodjaca]));
CREATE TABLE [Ves_Masina]
([Sif] [int] NOT NULL,
[Programi_pranja] [varchar] (20) NOT NULL,
PRIMARY KEY ([Sif]),
FOREIGN KEY ([Sif])REFERENCES[Proizvod]([Sif]));
CREATE TABLE [WC_Solja]
([Sif] [int] NOT NULL,
[Bide] [varchar] (10) NOT NULL,
PRIMARY KEY ([Sif]),
FOREIGN KEY ([Sif])REFERENCES[Proizvod]([Sif]));
CREATE TABLE [Bojler]
([Sif] [int] NOT NULL,
[Elektricni_grejac] [varchar] (10) NOT NULL,
PRIMARY KEY ([Sif]),
FOREIGN KEY ([Sif])REFERENCES[Proizvod]([Sif]));
CREATE TABLE [Nalepnica_Rezervacije]
([Sif] [int] NOT NULL,
[Rb_nalepnice] [int] NOT NULL,
PRIMARY KEY ([Rb_nalepnice]),
FOREIGN KEY ([Sif])REFERENCES[Proizvod]([Sif]));



CREATE TABLE [Angazovanje]
([Dat_od] [date] NOT NULL,
[Dat_do] [date] NOT NULL,
[JMBG_radnika] [char] (13) NOT NULL,
[Sifra] [int] NOT NULL,
PRIMARY KEY ([Dat_od],[JMBG_radnika],[Sifra]),
FOREIGN KEY ([JMBG_radnika])REFERENCES[Radnik]([JMBG_radnika]),
FOREIGN KEY ([Sifra])REFERENCES[Radno_Mesto]([Sifra]));
CREATE TABLE [Cuva]
([Sif] [int] NOT NULL,
[JMBG_radnika] [char] (13) NOT NULL,
PRIMARY KEY ([JMBG_radnika],[Sif]),
FOREIGN KEY ([JMBG_radnika])REFERENCES[Radnik]([JMBG_radnika]),
FOREIGN KEY ([Sif])REFERENCES[Proizvod]([Sif]));
CREATE TABLE [Dodeljuje]
([Serijskibr] [int] NOT NULL,
[JMBG_radnika] [char] (13) NOT NULL,
PRIMARY KEY ([JMBG_radnika], [Serijskibr]),
FOREIGN KEY ([JMBG_radnika])REFERENCES[Radnik]([JMBG_radnika]),
FOREIGN KEY ([Serijskibr])REFERENCES[Garancija]([Serijskibr]));
CREATE TABLE [Sadrzi]
([Sif] [int] NOT NULL,
[Serijski_broj] [int] NOT NULL,
PRIMARY KEY ([Serijski_broj], [Sif]),
FOREIGN KEY ([Serijski_broj])REFERENCES[Katalog]([Serijski_broj]),
FOREIGN KEY ([Sif])REFERENCES[Proizvod]([Sif]));
CREATE TABLE [Sajt]
([Web_adresa] [nvarchar] (50) NOT NULL,
[Serijski_broj] [int] NOT NULL,
[Korpa] [nvarchar] (50) NOT NULL,
[Kontakt] [int] NOT NULL,
[Naziv] [nvarchar] (50) NOT NULL,
PRIMARY KEY ([Web_adresa]),
FOREIGN KEY ([Serijski_broj])REFERENCES[Katalog]([Serijski_broj]));
CREATE TABLE [Ima]
([Web_adresa] [nvarchar] (50) NOT NULL,
[ID_kategorije] [int] NOT NULL,
PRIMARY KEY ([Web_adresa], [ID_kategorije]),
FOREIGN KEY ([Web_adresa])REFERENCES[Sajt]([Web_adresa]),
FOREIGN KEY ([ID_kategorije])REFERENCES[Kategorije]([ID_kategorije]));
CREATE TABLE [Kupac]
([JMBG_kupca] [char] (13) NOT NULL,
[Web_adresa] [nvarchar] (50) NOT NULL,
[Ime] [varchar] (50) NOT NULL ,
[Prezime] [varchar] (50) NOT NULL ,
PRIMARY KEY ([JMBG_kupca]),
FOREIGN KEY ([Web_adresa])REFERENCES[Sajt]([Web_adresa]));


CREATE TABLE [Racun]
([PIB] [int] NOT NULL,
[Serijskibr] [int] NOT NULL,
[ID_poreza] [int] NOT NULL,
[Sif] [int] NOT NULL,
[JMBG_radnika] [char] (13) NOT NULL,
[JMBG_kupca] [char] (13) NOT NULL,
[Naziv_proizvoda] [varchar] (50) NOT NULL,
[Datum_izdavanja] [date] NOT NULL,
[Cena_proizvoda] [money] NOT NULL,
PRIMARY KEY ([PIB],[Serijskibr],[ID_poreza],[Sif], [JMBG_radnika],[JMBG_kupca]),
FOREIGN KEY ([Serijskibr])REFERENCES[Garancija]([Serijskibr]),
FOREIGN KEY ([ID_poreza])REFERENCES[Porez]([ID_poreza]),
FOREIGN KEY ([Sif])REFERENCES[Proizvod]([Sif]),
FOREIGN KEY([JMBG_radnika])REFERENCES[Radnik]([JMBG_radnika]),
FOREIGN KEY([JMBG_kupca])REFERENCES[Kupac]([JMBG_kupca]));
CREATE TABLE [Chat]
([JMBG_kupca] [char] (13) NOT NULL,
[Web_adresa] [nvarchar] (50) NOT NULL,
[JMBG_radnika] [char] (13) NOT NULL,
[Vreme_pocetka] [datetime] NOT NULL,
[Vreme_zavrsetka] [datetime] NOT NULL,
PRIMARY KEY ([JMBG_kupca],[Web_adresa],[JMBG_radnika]),
FOREIGN KEY([JMBG_kupca])REFERENCES[Kupac]([JMBG_kupca]),
FOREIGN KEY ([Web_adresa])REFERENCES[Sajt]([Web_adresa]),
FOREIGN KEY ([JMBG_radnika]) REFERENCES[Radnik]([JMBG_radnika]));
CREATE TABLE [Rezervacija]
([SifraRez] [int] NOT NULL,
[Web_adresa] [nvarchar] (50) NOT NULL,
[JMBG_radnika] [char] (13) NOT NULL,
[Sif] [int] NOT NULL,
[JMBG_kupca] [char] (13) NOT NULL,
[Vreme_od] [datetime] NOT NULL,
[Vreme_do] [datetime] NOT NULL,
PRIMARY KEY ([SifraRez],[Web_adresa], [JMBG_radnika], [Sif], [JMBG_kupca]),
FOREIGN KEY ([Web_adresa])REFERENCES[Sajt]([Web_adresa]),
FOREIGN KEY ([JMBG_radnika]) REFERENCES[Radnik]([JMBG_radnika]),
FOREIGN KEY([Sif])REFERENCES[Proizvod]([Sif]),
FOREIGN KEY([JMBG_kupca])REFERENCES[Kupac] ([JMBG_kupca]));

CREATE TABLE [Pravi]
([SifraRez] [int] NOT NULL,
[Web_adresa] [nvarchar] (50) NOT NULL,
[JMBG_radnika] [char] (13) NOT NULL,
[Sif] [int] NOT NULL,
[JMBG_kupca] [char] (13) NOT NULL,
[Rb_nalepnice] [int] NOT NULL,
PRIMARY KEY ([Rb_nalepnice], [SifraRez]),
FOREIGN KEY([SifraRez], [Web_adresa], [JMBG_radnika], [Sif],
[JMBG_kupca])REFERENCES[Rezervacija]([SifraRez], [Web_adresa], [JMBG_radnika], [Sif],
[JMBG_kupca]),
FOREIGN KEY([Rb_nalepnice])REFERENCES[Nalepnica_Rezervacije]([Rb_nalepnice]));
