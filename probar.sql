SELECT DISTINCT idusuario,idplan, sum(montopagado) over(PARTITION BY idusuario,idplan) as PagadoxP
from pagos
GROUP by idusuario,idpago

SELECT idusuario,count(CASE WHEN DiasR BETWEEN 1 AND 5 Then idreproducción END) "durante semana",
count(CASE WHEN DiasR BETWEEN 6 AND 7 Then idreproducción END) "fin de"
from (select idreproducción,idusuario, 
      EXTRACT(ISODOW FROM fechaReproducción) as DiasR
	  from reproducciones RE ) as InfRexUsu
GROUP BY idusuario

SELECT DISTINCT DENSE_RANK()OVER(
                                 ORDER BY
                                   (SELECT sum(montopagado)
                                    FROM pagos P
                                    WHERE P.idusuario=Us.idusuario) DESC) AS "Top pagado en planes",
                CONCAT(Us.nombres, ' ', Us.apellidos) AS "Nombre Completo",
                Us.email AS "Email",
                InfRexUsu.RTxU AS "Reproducciones totales",
                CONCAT('(', count(CASE WHEN DiasR BETWEEN 1 AND 5 THEN idreproducciónEND), ') ', 
                                                      CONCAT((100*(count(CASE
                                                           WHEN DiasR BETWEEN 1 AND 5 THEN idreproducción
                                                       END)))/InfRexUsu.RTxU, '%')) AS "Porcentage de reproduccion durante semana",
                CONCAT('(', count(CASE WHEN DiasR BETWEEN 6 AND 7 THEN idreproducción END), ') ', 
                                  CONCAT((100*(count(CASE
                                                      WHEN DiasR BETWEEN 6 AND 7 THEN idreproducción
                                                     END)))/InfRexUsu.RTxU, '%')) AS "Porcentage de reproduccion durante fin de semana",
                (InfRexUsu.UFR-InfRexUsu.LFR)/31 AS "meses activo",
  (SELECT sum(montopagado)
   FROM pagos P
   WHERE P.idusuario=Us.idusuario) AS "Total Pagado en planes"
FROM usuarios US
INNER JOIN
  (SELECT idreproducción,
          idusuario,
          count(RE.idreproducción) over(PARTITION BY idusuario) AS RTxU,
          Max(RE.fechareproducción) over(PARTITION BY idusuario) AS UFR,
          min(RE.fechareproducción) over(PARTITION BY idusuario) AS LFR,
          EXTRACT(ISODOW
                  FROM fechaReproducción) AS DiasR
   FROM reproducciones RE
   WHERE segundosReproducidos>=60) AS InfRexUsu USING(idusuario)
GROUP BY Us.idusuario,
         InfRexUsu.RTxU,
         InfRexUsu.UFR,
         InfRexUsu.LFR