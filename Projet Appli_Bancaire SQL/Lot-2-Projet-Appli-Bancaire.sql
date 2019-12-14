
--Creation de l'interface du package ACTIONSURCOMPTE
DROP package ACTIONSURCOMPTE;
CREATE OR REPLACE PACKAGE ACTIONSURCOMPTE IS
	PROCEDURE AJOUTNOUVOPERATION
		(	Idcompte_ INTEGER,
			"Value" NUMBER
		);
	PROCEDURE ANNULEROPERATION
		(	IdOpt INTEGER
		);
	PROCEDURE MAJDECOUVERTAUTORISE
		(	Idcompte_ INTEGER,
			"Value" NUMBER
		);
	PROCEDURE MAJMONTANTOPERATION
		(	Idoperation_ INTEGER,
			"Value" NUMBER
		);
		
	FUNCTION SOLDECOMPTE
		(	Cpt INTEGER
		)
		RETURN NUMBER;
		
	PROCEDURE FAIRETRANSFERTCOMPTE
		(	CptOrig INTEGER,
			CptDest INTEGER,
			"Value" NUMBER
		);
	FUNCTION BANQUEOPERATION
		(	Idopt INTEGER
		)
		RETURN VARCHAR;
END ACTIONSURCOMPTE;
/


--Creation du body du package ACTIONSURCOMPTE
CREATE OR REPLACE PACKAGE BODY ACTIONSURCOMPTE AS
	PROCEDURE AJOUTNOUVOPERATION(
	Idcompte_ INTEGER,
	"Value" NUMBER
	)
	IS
	IdBanque_ INTEGER;
	BEGIN
	SELECT IdBanque INTO IdBanque_ FROM COMPTE WHERE IdCompte = Idcompte_;
	INSERT INTO "OPERATION"(IdOperation,MontantOperation, IdCompte, IdBanque) 
	VALUES(SeqOperation.nextval, "Value",Idcompte_, IdBanque_);
	COMMIT;
	END AJOUTNOUVOPERATION;
	
	PROCEDURE ANNULEROPERATION(
	IdOpt INTEGER)
	IS
	Montant NUMBER;
	IdCompte_ INTEGER;
	BEGIN
	SELECT MontantOperation INTO Montant FROM "OPERATION" WHERE IdOperation = IdOpt;
	SELECT IdCompte INTO IdCompte_ FROM "OPERATION" WHERE IdOperation = IdOpt;
	ajoutnouvoperation(IdCompte_, -Montant);
	COMMIT;
	END ANNULEROPERATION;
	
	PROCEDURE MAJDECOUVERTAUTORISE(
	Idcompte_ INTEGER,
	"Value" NUMBER)
	IS 
	BEGIN
	UPDATE COMPTE SET DecouvertAutorise = "Value" WHERE IdCompte = Idcompte_;
	COMMIT;
	END MAJDECOUVERTAUTORISE;
	
	PROCEDURE MAJMONTANTOPERATION(
	Idoperation_ INTEGER,
	"Value" NUMBER)
	IS 
	IdCompte_ INTEGER;
	BEGIN
	SELECT IdCompte INTO IdCompte_ FROM "OPERATION" WHERE IdOperation = IdOperation_;
	annuleroperation(Idoperation_);
	ajoutnouvoperation(IdCompte_, "Value");
	COMMIT;
	END MAJMONTANTOPERATION;
	
	FUNCTION SOLDECOMPTE(Cpt INTEGER) RETURN NUMBER
	IS
	solde_ NUMBER(10,2);
	BEGIN
	SELECT SoldeCompte INTO solde_ FROM COMPTE WHERE IdCompte = Cpt;
	RETURN solde_;
	END SOLDECOMPTE;
	
	PROCEDURE FAIRETRANSFERTCOMPTE(
	CptOrig INTEGER,
	CptDest INTEGER,
	"Value" NUMBER)
	IS
	BEGIN
	IF "Value" > 0 THEN
	    ajoutnouvoperation(CptOrig, -"Value");
	    ajoutnouvoperation(CptDest, "Value");
	ELSE	
    RAISE_APPLICATION_ERROR(-20002, 'Le montant doit etre positif et non nul.');
	END IF;
	COMMIT;
	END FAIRETRANSFERTCOMPTE;
	
	FUNCTION BANQUEOPERATION(Idopt INTEGER) RETURN VARCHAR
	IS
	lib VARCHAR(50);
	BEGIN
	SELECT b.LibelleBanque INTO lib FROM BANQUE b, "OPERATION" o, COMPTE c WHERE o.IdOperation = Idopt
	AND b.IdBanque = c.IdBanque
	AND o.IdCompte = c.IdCompte;
	RETURN lib;
	END BANQUEOPERATION;
	
	
	
END ACTIONSURCOMPTE;
/

--Appel des procédures et fonctions stockées du package ACTIONSURCOMPTE

/*
--AJOUTNOUVOPERATION
--1 seule banque pour un numéro de compte !!
--ajouter idbanque dans la réponse de la procédure 
DROP PROCEDURE AJOUTNOUVOPERATION;
CREATE OR REPLACE PROCEDURE AJOUTNOUVOPERATION(
	Idcompte_ INTEGER,
	"Value" NUMBER
	)
	IS
	IdBanque_ INTEGER;
	BEGIN
	SELECT IdBanque INTO IdBanque_ FROM COMPTE WHERE IdCompte = Idcompte_;
	INSERT INTO "OPERATION"(IdOperation,MontantOperation, IdCompte, IdBanque) 
	VALUES(SeqOperation.nextval, "Value",Idcompte_, IdBanque_);
	COMMIT;
	END AJOUTNOUVOPERATION;
	/

EXECUTE ajoutnouvoperation(2, 200);
EXECUTE ajoutnouvoperation(6, -100);
EXECUTE ajoutnouvoperation(4, -100); --Ne marche pas : violation contrainte FK_IdCompte (IdCompte=4 n'existe pas encore



--ANNULEROPERATION
DROP PROCEDURE ANNULEROPERATION;
CREATE OR REPLACE PROCEDURE ANNULEROPERATION(
	IdOpt INTEGER)
	IS
	Montant NUMBER;
	IdCompte_ INTEGER;
	BEGIN
	SELECT MontantOperation INTO Montant FROM "OPERATION" WHERE IdOperation = IdOpt;
	SELECT IdCompte INTO IdCompte_ FROM "OPERATION" WHERE IdOperation = IdOpt;
	ajoutnouvoperation(IdCompte_, -Montant);
	COMMIT;
	END ANNULEROPERATION;
	/

EXECUTE annuleroperation(7);
EXECUTE annuleroperation(8);

--MAJDECOUVERTAUTORISE
DROP PROCEDURE MAJDECOUVERTAUTORISE;
CREATE OR REPLACE PROCEDURE MAJDECOUVERTAUTORISE(
	Idcompte_ INTEGER,
	"Value" NUMBER)
	IS 
	BEGIN
	UPDATE COMPTE SET DecouvertAutorise = "Value" WHERE IdCompte = Idcompte_;
	COMMIT;
	END MAJDECOUVERTAUTORISE;
	/


EXECUTE majdecouvertautorise(2,200);
EXECUTE majdecouvertautorise(6,1000);

--MAJMONTANTOPERATION
DROP PROCEDURE MAJMONTANTOPERATION;
CREATE OR REPLACE PROCEDURE MAJMONTANTOPERATION(
	Idoperation_ INTEGER,
	"Value" NUMBER)
	IS 
	IdCompte_ INTEGER;
	BEGIN
	SELECT IdCompte INTO IdCompte_ FROM "OPERATION" WHERE IdOperation = IdOperation_;
	annuleroperation(Idoperation_);
	ajoutnouvoperation(IdCompte_, "Value");
	COMMIT;
	END MAJMONTANTOPERATION;
	/


EXECUTE majmontantoperation(5,178);
EXECUTE majmontantoperation(11,-99);

--SOLDECOMPTE

DROP FUNCTION SOLDECOMPTE;
CREATE OR REPLACE FUNCTION SOLDECOMPTE(Cpt INTEGER) RETURN NUMBER
	IS
	solde_ NUMBER(10,2);
	BEGIN
	SELECT SoldeCompte INTO solde_ FROM COMPTE WHERE IdCompte = Cpt;
	RETURN solde_;
	END SOLDECOMPTE;
	/

SELECT SOLDECOMPTE(6) FROM DUAL;
SELECT SOLDECOMPTE(2) FROM DUAL;


--FAIRETRANSFERTCOMPTE

DROP PROCEDURE FAIRETRANSFERTCOMPTE;
CREATE OR REPLACE PROCEDURE FAIRETRANSFERTCOMPTE(
	CptOrig INTEGER,
	CptDest INTEGER,
	"Value" NUMBER)
	IS
	BEGIN
	IF "Value" > 0 THEN
	   IF soldeCompte(CptOrig) >= "Value" THEN
	        ajoutnouvoperation(CptOrig, -"Value");
	        ajoutnouvoperation(CptDest, "Value");
	    ELSE
		RAISE_APPLICATION_ERROR(-20001, 'Solde insuffisant au transfert.');
		END IF;
	ELSE	
    RAISE_APPLICATION_ERROR(-20002, 'Le montant doit etre positif et non nul.');
	END IF;
	COMMIT;
	END FAIRETRANSFERTCOMPTE;
	/

EXECUTE FAIRETRANSFERTCOMPTE(6,2, 500);
EXECUTE FAIRETRANSFERTCOMPTE(2,6, 500); --Ne marche pas car solde insuffisant
EXECUTE FAIRETRANSFERTCOMPTE(2,6, 0); --Ne marche pas car transfert nul

--BANQUEOPERATION

DROP FUNCTION BANQUEOPERATION;
CREATE OR REPLACE FUNCTION BANQUEOPERATION(Idopt INTEGER) RETURN VARCHAR
	IS
	lib VARCHAR(50);
	BEGIN
	SELECT b.LibelleBanque INTO lib FROM BANQUE b, "OPERATION" o, COMPTE c WHERE o.IdOperation = Idopt
	AND b.IdBanque = c.IdBanque
	AND o.IdCompte = c.IdCompte;
	RETURN lib;
	END BANQUEOPERATION;
	/


SELECT BANQUEOPERATION(5) FROM DUAL;
SELECT BANQUEOPERATION(6) FROM DUAL;
*/
