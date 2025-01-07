/*Potrebno je kreirati pogled pRadnik_Angazovanje_Racun kroz koji ćemo videti podatke o JMBG radnika,
imenu i prezimenu radnika, datum početka i završetka angažovanja, PIB računa, naziv i cenu proizvoda i
datum izdavanja računa.*/

USE Projekat;
GO

CREATE VIEW pRadnik_Angazovanje_Racun AS
SELECT r.JMBG_radnika, r.Ime, r.Prezime, a.Dat_od, a.Dat_do,
       ra.PIB, ra.Naziv_proizvoda, ra.Cena_proizvoda, ra.Datum_izdavanja
FROM Radnik r
JOIN Angazovanje a ON r.JMBG_radnika = a.JMBG_radnika
JOIN Racun ra ON r.JMBG_radnika = ra.JMBG_radnika;
GO


-- Upit nad pogledom
SELECT *
FROM pRadnik_Angazovanje_Racun


/*Potrebno je kreirati baznu proceduru kdpPopustZaRadnika koja će kao argument prihvatiti JMBG
radnika.
Procedura na osnovu JMBG radnika proverava da li radnik ima neko angažovanje i da li radnikovo
angažovanje ističe na današnji dan.
Ukoliko je radnik angažovan i ako mu angažovanje ističe na današnji dan, radnik dobija popust u iznosu
od 10% na sve račune izdate na današnji dan. U suprotnom, dobija obaveštenje da radniku danas ne
ističe angažovanje ni na jednom radnom mestu ili obaveštenje da radniku ističe angažovanje na današnji
dan ali da nije u mogućnosti da ostvari popust iz razloga što nema ni jedan izdat račun na današnji dan.*/

USE Projekat;
GO
CREATE PROCEDURE kdpPopustZaRadnika
@Jmbg_Radnika char(13)
AS
DECLARE @angazovan bit
DECLARE @brojRacunaRadnika int
BEGIN
    SELECT @angazovan = count(*) 
    FROM Angazovanje 
    WHERE JMBG_radnika = @Jmbg_Radnika 
    AND Dat_do = CONVERT(date, getdate())
    
    IF (@angazovan > 0)
    BEGIN
        SELECT @brojRacunaRadnika = count(*) 
        FROM Racun 
        WHERE JMBG_radnika = @Jmbg_Radnika
        AND Datum_izdavanja = CONVERT(date, getdate())
        
        IF (@brojRacunaRadnika = 0)
        BEGIN
            PRINT 'Radniku sa jmbg-om: ' + @Jmbg_Radnika + ' ističe angažovanje na današnji dan, ali nije došlo do ostvarivanja popusta iz razloga što nema nijedan izdat račun na današnji dan.'
        END
        ELSE
        BEGIN
            UPDATE Racun 
            SET Cena_proizvoda = Cena_proizvoda * 0.90 
            WHERE JMBG_radnika = @Jmbg_Radnika 
            AND Datum_izdavanja = CONVERT(date, getdate())
        END
    END
    ELSE
    BEGIN
        PRINT 'Radniku sa jmbg-om: ' + @Jmbg_Radnika + ' danas ne ističe angažovanje ni na jednom radnom mestu i zbog toga ne može da ostvari popust prilikom kupovine.'
    END
END
GO

-- Poziv procedure
EXEC kdpPopustZaRadnika 1231447533199;



/*Potrebno je kreirati baznu funkciju dbo.PretragaRacuna koja će na osnovu JMBG radnika nalazite sve
izdate računa za njega. Time možemo videti da li je došlo do promene prilikom pokretanja prethodne
navedene procedure. (Na slici ispod vidimo da je cena proizvoda spala na 4500 sa 5000 dinara)
Kao argument prihvata JMBG radnika, a vraća pogled za određenog radnika.*/
USE Projekat;
GO

CREATE FUNCTION dbo.PretragaRacuna (@Jmbg_Radnika char(13))
RETURNS TABLE
AS
RETURN 
    SELECT * 
    FROM pRadnik_Angazovanje_Racun 
    WHERE JMBG_radnika = @Jmbg_Radnika;
GO

-- Pozivanje funkcije
SELECT *
FROM dbo.PretragaRacuna(1231447533199);
GO



/*Potrebno je kreirati pogled Radnik_Kupac_Rezervacija kroz koji ćemo moći videti podatke o šifri
rezervacije, šifri proizvoda, vremenu početka rezervacije, vremenu završetka rezervacije, JMBG radnika,
imenu radnika, prezimenu radnika, JMBG kupca, imenu kupca i prezimenu kupca.*/
USE Projekat;
GO

-- Ako već postoji pogled, brišemo ga
IF OBJECT_ID('Radnik_Kupac_Rezervacija', 'V') IS NOT NULL
    DROP VIEW Radnik_Kupac_Rezervacija;
GO

-- Kreiramo novi pogled
CREATE VIEW Radnik_Kupac_Rezervacija (SifraRezervacije, SifraProizvoda, VremePocetka,
VremeZavrsetka, JmbgRadnika, ImeRadnika, PrezimeRadnika,
JmbgKupca, ImeKupca, PrezimeKupca)
AS
SELECT re.SifraRez, re.Sif, re.Vreme_od, re.Vreme_do, r.JMBG_radnika, r.Ime, r.Prezime,
       k.JMBG_kupca, k.Ime, k.Prezime
FROM Rezervacija re
JOIN Radnik r ON r.JMBG_radnika = re.JMBG_radnika
JOIN Kupac k ON k.JMBG_kupca = re.JMBG_kupca;
GO

-- Upit nad pogledom
SELECT *
FROM Radnik_Kupac_Rezervacija;
GO




/*Potrebno je kreirati baznu proceduru kdpBrisanjeRezervacije koja ce kao argumente prihvatiti sifru
rezervacije, jmbg kupca i jmbg radnika. Procedura na osnovu šifre rezervacije pronalazi datum isteka te
rezervacije, proverava da li je datum isteka manji od datuma: 2023-02-02 , a zatim briše pronađenu
rezervaciju kao i kupca i radnika koji su učestvovali u kreiranju rezervacije.*/
CREATE PROCEDURE kdpBrisanjeRezervacije2
@SifraRez int,
@JMBGKupca char (13),
@JMBGRadnik char (13)
as
DECLARE @VremeDo datetime
begin
select @VremeDo = Vreme_do from Rezervacija
where SifraRez = @SifraRez
if (CONVERT(date, @VremeDo) < '2023-02-02')
DELETE from Pravi where SifraRez = @SifraRez
DELETE from Rezervacija where SifraRez = @SifraRez
DELETE from Chat where JMBG_kupca = @JMBGKupca
DELETE from Angazovanje where JMBG_radnika = @JMBGRadnik
DELETE from Cuva where JMBG_radnika = @JMBGRadnik
DELETE from Racun where JMBG_kupca = @JMBGKupca
DELETE from Dodeljuje where JMBG_radnika = @JMBGRadnik
DELETE from Kupac where JMBG_kupca = @JMBGKupca
DELETE from Radnik where JMBG_radnika = @JMBGRadnik
end;
exec kdpBrisanjeRezervacije2 34462, 1103146578126, 1708146543126
Go

/*Kreirana je bazna funkcija ‘PregledRezervacije’ u bazi Projekat, koja u ovom slučaju neće imati
parametre zbog toga što želimo da prikažemo stanje nakon brisanja rezervacije, radnika i kupca.
Kao rezultat pokretanja funkcije dobijamo pogled nad rezervacijama, radnicima i kupcima sa obrisanim
redom.*/
CREATE FUNCTION dbo.PregledRezervacije ()
RETURNS TABLE
AS
RETURN
    SELECT * 
    FROM Radnik_Kupac_Rezervacija;
GO

SELECT * 
FROM dbo.PregledRezervacije();




