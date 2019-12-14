--Creation de l'interface du package AUDIT
DROP package "AUDIT";
CREATE OR REPLACE PACKAGE "AUDIT" IS
	FUNCTION DEPASSEMENT
		(
			IdCpt INTEGER
		)
		RETURN NUMBER;
	PROCEDURE MODIFAUDIT
		(	
			idCpt INTEGER
		);
END "AUDIT";
/

--Creation du body du package AUDIT
CREATE OR REPLACE PACKAGE BODY "AUDIT" AS
	FUNCTION DEPASSEMENT(IdCpt INTEGER) RETURN NUMBER
	IS
	Sld NUMBER(10,2); --Solde compte
	Decouv NUMBER(10,2); -- Decouvert autorise
	Depass NUMBER(10,2); --Depassement
	BEGIN
	SELECT actionsurcompte.SOLDECOMPTE(IdCpt) INTO Sld FROM DUAL; --récupère solde du compte
	SELECT DecouvertAutorise INTO Decouv FROM COMPTE WHERE idCompte=IdCpt;--decouvautorise
	IF Sld < -Decouv THEN
		Depass:= -Decouv - Sld;
		RETURN Depass;
	ELSE
		Depass:=0;
		RETURN Depass;
	END IF;
	END DEPASSEMENT;
	
	
	PROCEDURE MODIFAUDIT(idCpt INTEGER)
	IS
	IdTypeCpt INTEGER;
	TypeCpt VARCHAR(30);
	Sld2 NUMBER(10,2);
	Lib VARCHAR(30);
	iDLastOperation INTEGER;
	Depass NUMBER(10,2); --Depassement effectif
	nbLignesCpt INTEGER; --Nb de lignes du compte dans table auditDecouvert
	Decouv NUMBER(10,2);
	BEGIN
	--On recupere le libelle du compte sur lequel l'operation se fait
	SELECT LibelleCompte INTO Lib FROM COMPTE WHERE idCompte= idCpt;
	--On recupere le solde du compte sur lequel l'operation se fait
	SELECT actionsurcompte.SOLDECOMPTE(idCpt) INTO Sld2 FROM DUAL;
	--On recupere le decouvert autorise du compte sur lequel l'operation se fait
	SELECT DecouvertAutorise INTO Decouv FROM COMPTE WHERE idCompte=idCpt;
	--On recup le depassement de cet id de compte
	SELECT "AUDIT".DEPASSEMENT(idCpt) INTO Depass from dual;
	--On recup l'id de la derniere operation de cet id de compte
	iDLastOperation:= SeqOperation.Currval;
	--On recup le nombre de lignes de cet idCompte dans table auditdecouvert
	SELECT COUNT(idCompte) INTO nbLignesCpt FROM AUDITDECOUVERT WHERE idCompte=idCpt;
	--On recupere l'id du type de compte du compte sur lequel l'operation se fait
	SELECT idTypeCompte INTO IdTypeCpt FROM COMPTE WHERE idCompte=idCpt;
	--On recupere le libelle du type du compte sur lequel l'operation se fait
	SELECT LibelleTypeCompte INTO TypeCpt FROM TYPECOMPTE WHERE idTypeCompte= IdTypeCpt;
	
	--Eviter que compte d'épargne ait solde négatif
	IF TypeCpt = 'EPARGNE' THEN
		IF Sld2 <0 THEN
		RAISE_APPLICATION_ERROR(-20001,'Les comptes epargne ne peuvent pas avoir de solde negatif');
		END IF;
	END IF;
	
	--Si decouvert dépassé
	IF Depass <> 0 THEN
		IF nbLignesCpt <1 THEN
			INSERT INTO AUDITDECOUVERT(idAudit, idCompte, libelleCompte, soldeCompte, decouvertAutorise, 
			depassement, idDerniereOperation) VALUES(SeqAuditDecouvert.nextval, idCpt, Lib, Sld2, Decouv,
			Depass, iDLastOperation);
		ELSE
			UPDATE AUDITDECOUVERT SET libelleCompte=Lib, soldeCompte=Sld2, decouvertAutorise=Decouv,
			depassement=Depass, idDerniereOperation=iDLastOperation WHERE idCompte=idCpt;
		END IF;
	--Si decouvert plus dépassé et que la ligne du compte existait, on la supprime d'auditdecouvert
	ELSE
		IF nbLignesCpt >=1 THEN
			DELETE FROM AUDITDECOUVERT WHERE idCompte=idCpt;
		END IF;
	END IF;
	END MODIFAUDIT;
	
END "AUDIT";
/



DROP TRIGGER CALCULSOLDE;
CREATE OR REPLACE TRIGGER CALCULSOLDE
BEFORE INSERT ON "OPERATION"
FOR EACH ROW
DECLARE
BEGIN

	UPDATE COMPTE SET soldeCompte = soldeCompte + :NEW.MontantOperation WHERE idCompte=:NEW.idCompte;
	"AUDIT".modifaudit(:NEW.idCompte);
	
END;
/

