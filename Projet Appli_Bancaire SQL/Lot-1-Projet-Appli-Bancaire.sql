DROP table banque cascade constraint purge;
CREATE TABLE BANQUE
(IdBanque INTEGER,
 LibelleBanque VARCHAR(50),
 CPBanque CHAR(5),
 AdresseBanque VARCHAR(50),
 VilleBanque VARCHAR(30)
);
 drop sequence seqbanque;
 CREATE SEQUENCE SeqBanque START WITH 1;

 ALTER TABLE BANQUE ADD CONSTRAINT PK_Banque_IdBanque PRIMARY KEY(IdBanque);
 ALTER TABLE BANQUE ADD CONSTRAINT U_LibBanque UNIQUE(LibelleBanque);
 ALTER TABLE BANQUE MODIFY LibelleBanque VARCHAR(50) NOT NULL;
 ALTER TABLE BANQUE MODIFY CPBanque CHAR(5) NOT NULL;
 ALTER TABLE BANQUE MODIFY AdresseBanque VARCHAR(50) NOT NULL;
 ALTER TABLE BANQUE MODIFY VilleBanque VARCHAR(30) NOT NULL;
  
 --Entree de donnees
 INSERT INTO BANQUE(IdBanque, LibelleBanque, CPBanque, AdresseBanque, VilleBanque) VALUES(seqBanque.NEXTVAL, 'SOGE', '75016', '110 Avenue de Versailles', 'Paris');
 INSERT INTO BANQUE(IdBanque, LibelleBanque, CPBanque, AdresseBanque, VilleBanque) VALUES(seqBanque.NEXTVAL, 'MACIF', '92110', '29 Rue Anatole France', 'Clichy');
 --Verifie contrainte unique
 INSERT INTO BANQUE(IdBanque, LibelleBanque, CPBanque, AdresseBanque, VilleBanque) VALUES(seqBanque.NEXTVAL, 'SOGE', '75017', '90 Boulevard Bessieres', 'Paris');

DROP table typecompte cascade constraint purge;
CREATE TABLE TYPECOMPTE
 (IdTypeCompte INTEGER,
  LibelleTypeCompte VARCHAR(30)
 );
 
 drop sequence seqtypecompte;
 CREATE SEQUENCE SeqTypeCompte START WITH 1;
 
 ALTER TABLE TYPECOMPTE ADD CONSTRAINT PK_TypeCompte_IdTypeCompte PRIMARY KEY(IdTypeCompte);
 ALTER TABLE TYPECOMPTE MODIFY LibelleTypeCompte VARCHAR(30) NOT NULL;
 
 --Entree de donnees
 INSERT INTO TYPECOMPTE(IdTypeCompte, LibelleTypeCompte) VALUES(seqTypeCompte.NEXTVAL, 'LIVRET A');
 INSERT INTO TYPECOMPTE(IdTypeCompte, LibelleTypeCompte) VALUES(seqTypeCompte.NEXTVAL, 'COMPTE COURANT');
 
DROP table compte cascade constraint purge;
CREATE TABLE COMPTE
(IdCompte INTEGER,
 LibelleCompte VARCHAR(30),
 SoldeCompte NUMBER(10,2),
 DecouvertAutorise NUMBER(10,2),
 DateOuvertureCompte DATE,
 IdBanque INTEGER,
 IdTypeCompte INTEGER
 );
 drop sequence seqcompte;
 CREATE SEQUENCE SeqCompte START WITH 1;
 
 ALTER TABLE COMPTE ADD CONSTRAINT PK_Compte_IdCompte PRIMARY KEY(IdCompte);
 ALTER TABLE COMPTE MODIFY LibelleCompte VARCHAR(30) NOT NULL;
 ALTER TABLE COMPTE ADD CONSTRAINT U_LibCompte UNIQUE(LibelleCompte);
 ALTER TABLE COMPTE MODIFY SoldeCompte NUMBER(10,2) NOT NULL;
 ALTER TABLE COMPTE MODIFY SoldeCompte DEFAULT 0;
 ALTER TABLE COMPTE MODIFY DecouvertAutorise NUMBER(10,2) NOT NULL;
 ALTER TABLE COMPTE MODIFY DecouvertAutorise DEFAULT 0;
 ALTER TABLE COMPTE MODIFY DateOuvertureCompte DATE NOT NULL;
 ALTER TABLE COMPTE MODIFY DateOuvertureCompte DEFAULT SYSDATE;
 ALTER TABLE COMPTE ADD CONSTRAINT FK_IdBanque FOREIGN KEY(IdBanque) REFERENCES BANQUE(IdBanque);
 ALTER TABLE COMPTE ADD CONSTRAINT FK_IdTypeCompte FOREIGN KEY(IdTypeCompte) REFERENCES TYPECOMPTE(IdTypeCompte);
 
 --Verifie les contraintes default
 INSERT INTO COMPTE(IdCompte, LibelleCompte, IdBanque) VALUES(seqCompte.NEXTVAL, 'FR4720041010011177150Z02201',2);
 --Verifie contrainte unique
 INSERT INTO COMPTE(IdCompte, LibelleCompte, IdBanque) VALUES(seqCompte.NEXTVAL, 'FR4720041010011177150Z02201',3);
 --Vérifie contraintes clé étrangère
 INSERT INTO COMPTE(IdCompte, LibelleCompte, IdBanque) VALUES(seqCompte.NEXTVAL, 'FR4820041010011177150Z02201',4);
 INSERT INTO COMPTE(IdCompte, LibelleCompte, IdTypeCompte) VALUES(seqCompte.NEXTVAL, 'FR4820041010011177150Z02201',4);
 --Entrée des données
 INSERT INTO COMPTE(IdCompte, LibelleCompte, SoldeCompte, DecouvertAutorise, DateOuvertureCompte, IdBanque, IdTypeCompte) VALUES(seqCompte.NEXTVAL, 'FR4820041010011177150Z02201',1500, 300, '25/02/18', 3, 2);

DROP table "OPERATION" cascade constraint purge;
CREATE TABLE "OPERATION"
(IdOperation INTEGER,
 DateOperation DATE,
 MontantOperation NUMBER(10,2),
 IdCompte INTEGER,
 IdBanque INTEGER 
);

 drop sequence seqoperation;
 CREATE SEQUENCE SeqOperation START WITH 1;

 ALTER TABLE "OPERATION" ADD CONSTRAINT PK_Operation_IdOperation PRIMARY KEY(IdOperation);
 ALTER TABLE "OPERATION" MODIFY DateOperation DATE NOT NULL;
 ALTER TABLE "OPERATION" MODIFY DateOperation DEFAULT SYSDATE;
 ALTER TABLE "OPERATION" MODIFY MontantOperation NUMBER(10,2) NOT NULL;
 ALTER TABLE "OPERATION" ADD CONSTRAINT FK_IdCompte FOREIGN KEY(IdCompte) REFERENCES COMPTE(IdCompte);
 ALTER TABLE "OPERATION" ADD CONSTRAINT FK_Operation_IdBanque FOREIGN KEY(IdBanque) REFERENCES BANQUE(IdBanque);
 
 --Vérifie les contraintes default
 INSERT INTO "OPERATION"(IdOperation, MontantOperation) VALUES(seqOperation.NEXTVAL, 1000);
--Verifie contrainte clé étrangère
 INSERT INTO "OPERATION"(IdOperation, DateOperation, MontantOperation, IdCompte) VALUES(seqOperation.NEXTVAL, '14/11/18', 1500, 12);
 INSERT INTO "OPERATION"(IdOperation, DateOperation, MontantOperation, IdBanque) VALUES(seqOperation.NEXTVAL, '15/11/18', 1600, 20);  
 --Entrée des données
 INSERT INTO "OPERATION"(IdOperation, DateOperation, MontantOperation, IdCompte, IdBanque) VALUES(seqOperation.NEXTVAL, '14/11/18', 1500, 6, 3);
 --seq.NEXTVAL incrémente le compteur même si erreur dans la console !

DROP table auditdecouvert cascade constraint purge;
CREATE TABLE AUDITDECOUVERT
(IdAudit INTEGER,
 IdCompte INTEGER,
 LibelleCompte VARCHAR(30),
 SoldeCompte NUMBER(10,2),
 DecouvertAutorise NUMBER(10,2),
 Depassement NUMBER(10,2),
 IdDerniereOperation INTEGER
);

 drop sequence seqauditdecouvert;
 CREATE SEQUENCE SeqAuditDecouvert START WITH 1;

 ALTER TABLE AUDITDECOUVERT ADD CONSTRAINT PK_AuditDecouvert_IdAudit PRIMARY KEY(IdAudit);
 ALTER TABLE AUDITDECOUVERT MODIFY IdCompte INTEGER NOT NULL;
 ALTER TABLE AUDITDECOUVERT MODIFY LibelleCompte VARCHAR(30) NOT NULL;
 ALTER TABLE AUDITDECOUVERT MODIFY SoldeCompte NUMBER(10,2) NOT NULL;
 ALTER TABLE AUDITDECOUVERT MODIFY SoldeCompte DEFAULT 0;
 ALTER TABLE AUDITDECOUVERT MODIFY DecouvertAutorise NUMBER(10,2) NOT NULL;
 ALTER TABLE AUDITDECOUVERT ADD CONSTRAINT CHK_DecouvertAutorise CHECK(DecouvertAutorise>=0);
 ALTER TABLE AUDITDECOUVERT MODIFY Depassement NUMBER(10,2) NOT NULL;
 ALTER TABLE AUDITDECOUVERT ADD CONSTRAINT CHK_Depassement CHECK(Depassement>=0);
 ALTER TABLE AUDITDECOUVERT MODIFY IdDerniereOperation INTEGER NOT NULL;
 
 --Vérifie contrainte default
 INSERT INTO AUDITDECOUVERT(IdAudit, IdCompte, LibelleCompte, DecouvertAutorise, Depassement, IdDerniereOperation) VALUES(SeqAuditDecouvert.NEXTVAL, 5, 'AZ38F64', 500, 10, 1);
 --Verifie contraintes check
 INSERT INTO AUDITDECOUVERT(IdAudit, IdCompte, LibelleCompte, DecouvertAutorise, Depassement, IdDerniereOperation) VALUES(SeqAuditDecouvert.NEXTVAL, 5, 'AZ38F64', -500, 10, 1);
 INSERT INTO AUDITDECOUVERT(IdAudit, IdCompte, LibelleCompte, DecouvertAutorise, Depassement, IdDerniereOperation) VALUES(SeqAuditDecouvert.NEXTVAL, 5, 'AZ38F64', 500, -10, 1);
 --Entree de données
 INSERT INTO AUDITDECOUVERT(IdAudit, IdCompte, LibelleCompte, SoldeCompte, DecouvertAutorise, Depassement, IdDerniereOperation) VALUES(SeqAuditDecouvert.NEXTVAL, 5, 'AZ38F64',1400, 500, 10, 1);
 
 
 

 
 