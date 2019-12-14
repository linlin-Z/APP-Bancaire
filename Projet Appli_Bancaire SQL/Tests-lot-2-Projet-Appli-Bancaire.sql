--AJOUTNOUVOPERATION


execute actionsurcompte.AJOUTNOUVOPERATION(6, 546);


--ANNULEROPERATION


execute actionsurcompte.annuleroperation(24);


--MAJDECOUVERTAUTORISE

execute actionsurcompte.majdecouvertautorise(2,12345);


--SOLDECOMPTE

select actionsurcompte.SOLDECOMPTE(6) FROM DUAL;

--FAIRETRANSFERTCOMPTE


execute actionsurcompte.FAIRETRANSFERTCOMPTE(2,6, 0);


--BANQUEOPERATION

SELECT actionsurcompte.BANQUEOPERATION(5) FROM DUAL;

