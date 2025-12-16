USE bibliotheque;

INSERT INTO auteur (nom) VALUES
('Victor Hugo'),
('George Orwell'),
('Jane Austen');

SELECT id, nom FROM auteur WHERE nom='Victor Hugo';
INSERT INTO ouvrage (titre, disponible, auteur_id)
VALUES 
  ('Les Misérables', TRUE, 1),
  ('1984', FALSE, 2),
  ('Pride and Prejudice', TRUE, 3);
INSERT INTO abonne (nom, email)
VALUES 
  ('Karim', 'karim@mail.com'),
  ('Lucie', 'lucie@mail.com');
  INSERT INTO emprunt (ouvrage_id, abonne_id, date_debut)
VALUES (2, 1, '2025-06-18');
UPDATE ouvrage
SET disponible = FALSE
WHERE titre = 'Les Misérables';
UPDATE abonne
SET email = 'karim.new@mail.com'
WHERE nom = 'Karim';
UPDATE emprunt
SET date_fin = CURDATE()
WHERE id = 1;
DELETE FROM auteur
WHERE nom = 'George Orwell';
DELETE FROM ouvrage
WHERE id = 2;
DELETE FROM abonne
WHERE nom = 'Lucie';
START TRANSACTION;
INSERT INTO abonne (nom, email) VALUES ('Samir', 'samir@mail.com');
INSERT INTO emprunt (ouvrage_id, abonne_id, date_debut) VALUES (3, LAST_INSERT_ID(), '2025-06-19');
COMMIT;
ROLLBACK;

DELETE FROM auteur WHERE id = 3;

INSERT INTO emprunt VALUES (1, 2, '2025-06-10', '2025-06-01');

SET FOREIGN_KEY_CHECKS = 0;
SET FOREIGN_KEY_CHECKS = 1;





SELECT titre
FROM ouvrage
WHERE disponible = TRUE;
SELECT *
FROM abonne
WHERE email LIKE '%@gmail.com';
SELECT *
FROM emprunt
WHERE date_fin IS NULL;
SELECT a.nom AS abonne,
       o.titre AS ouvrage,
       e.date_debut,
       e.date_fin
FROM emprunt e
JOIN abonne a  ON e.abonne_id = a.id
JOIN ouvrage o ON e.ouvrage_id = o.id;

SELECT a.id,
       a.nom,
       COUNT(e.ouvrage_id) AS nb_emprunts
FROM abonne a
LEFT JOIN emprunt e ON a.id = e.abonne_id
GROUP BY a.id, a.nom;

SELECT au.id,
       au.nom,
       COUNT(o.id) AS nb_ouvrages
FROM auteur au
LEFT JOIN ouvrage o ON au.id = o.auteur_id
GROUP BY au.id, au.nom
ORDER BY nb_ouvrages DESC;
SELECT au.id,
       au.nom,
       COUNT(o.id) AS nb_ouvrages
FROM auteur au
JOIN ouvrage o ON au.id = o.auteur_id
GROUP BY au.id, au.nom
HAVING COUNT(o.id) >= 3;

UPDATE ouvrage
SET disponible = FALSE
WHERE id = 1;
UPDATE ouvrage
SET disponible = FALSE
WHERE titre = 'Les Misérables';
DELETE FROM emprunt
WHERE date_fin < '2025-01-01';

UPDATE emprunt
SET date_fin = CURDATE()
WHERE ouvrage_id = 2
  AND abonne_id = 1
  AND date_fin IS NULL;
  
 -- Ajouter un nouvel abonné
INSERT INTO abonne (nom, email)
VALUES ('Amine', 'amine@mail.com');

-- Récupérer l'id de l'abonné nouvellement inséré
SET @abonne_id = LAST_INSERT_ID();

-- Vérifier la disponibilité des ouvrages
SELECT id INTO @ouvrage1_id
FROM ouvrage
WHERE titre = '1984' 
LIMIT 1;

SELECT disponible INTO @dispo1
FROM ouvrage
WHERE id = @ouvrage1_id;

SELECT id INTO @ouvrage2_id
FROM ouvrage
WHERE titre = 'Pride and Prejudice' 
LIMIT 1;

SELECT disponible INTO @dispo2
FROM ouvrage
WHERE id = @ouvrage2_id;

INSERT INTO ouvrage (titre, disponible, auteur_id, slug)
VALUES ('1984', TRUE, 2, '1984') AS new_ouvrage
ON DUPLICATE KEY UPDATE
    titre = new_ouvrage.titre,
    disponible = new_ouvrage.disponible,
    auteur_id = new_ouvrage.auteur_id;
DELIMITER $$

CREATE PROCEDURE CreerEmprunt(
    IN p_abonne_id INT,
    IN p_ouvrage_id INT
)
BEGIN
    DECLARE v_disponible BOOLEAN;

    -- Vérifier la disponibilité de l'ouvrage
    SELECT disponible INTO v_disponible
    FROM ouvrage
    WHERE id = p_ouvrage_id;

    IF v_disponible THEN
        -- Insérer l'emprunt avec la date de début = aujourd'hui
        INSERT INTO emprunt (abonne_id, ouvrage_id, date_debut)
        VALUES (p_abonne_id, p_ouvrage_id, CURDATE());

        -- Mettre à jour la disponibilité de l'ouvrage
        UPDATE ouvrage
        SET disponible = FALSE
        WHERE id = p_ouvrage_id;

        SELECT 'Emprunt créé avec succès' AS message;
    ELSE
        SELECT 'Ouvrage non disponible' AS message;
    END IF;
END $$

DELIMITER ;

