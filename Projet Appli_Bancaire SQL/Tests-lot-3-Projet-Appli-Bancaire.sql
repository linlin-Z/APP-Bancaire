--Test solde épargne toujours positif ou nul
execute actionsurcompte.AJOUTNOUVOPERATION(2, -1);
execute actionsurcompte.FAIRETRANSFERTCOMPTE(2,6, 100);

--Test calcul solde sur compte courant sans dépassement de découvert
execute actionsurcompte.AJOUTNOUVOPERATION(6, 1000);
select * from operation order by idoperation;
select * from compte;
select * from auditdecouvert;

execute actionsurcompte.annuleroperation(24);
select * from operation order by idoperation;
select * from compte;
select * from auditdecouvert;

--Test calcul solde sur compte courant AVEC dépassement de découvert
execute actionsurcompte.AJOUTNOUVOPERATION(6, -5000);
select * from operation order by idoperation;
select * from compte;
select * from auditdecouvert;

--On reste en découvert mais il n'y a toujours qu'une seule ligne qui s'update dans auditdecouvert
execute actionsurcompte.AJOUTNOUVOPERATION(6, -1000);
select * from operation order by idoperation;
select * from compte;
select * from auditdecouvert;

--On sort du découvert et la ligne est donc supprimée d'auditdecouvert
execute actionsurcompte.AJOUTNOUVOPERATION(6, 10000);
select * from operation order by idoperation;
select * from compte;
select * from auditdecouvert;
