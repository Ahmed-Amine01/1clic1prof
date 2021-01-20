CREATE TABLE auth_user (
    id int PRIMARY KEY,
    user_pass VARCHAR(255) NOT NULL,
    user_email VARCHAR(100) NOT NULL
    );
    
CREATE TABLE Utilisateur (
    user_id int PRIMARY KEY NOT NULL,
    user_nom VARCHAR(30) DEFAULT "",
    user_prenom VARCHAR(30) DEFAULT "",
    user_email VARCHAR(100) REFERENCES auth_user(user_email),
    user_cp VARCHAR(5) DEFAULT "",
    user_tel VARCHAR(10) DEFAULT "",
    user_niveauEtude int DEFAULT 1 REFERENCES Type_Etude(etude_id),
    user_role ENUM('Professeur','Etudiant','Autre') DEFAULT 'Autre',
    user_descriptionProfil VARCHAR(300),
    user_souhait VARCHAR(300)
    );
    
CREATE TABLE Type_Matiere (
    matiere_id int PRIMARY KEY,
    matiere_nom VARCHAR(30) NOT NULL DEFAULT ""
    );

CREATE TABLE Type_Etude (
    etude_id int PRIMARY KEY,
    etude_nom VARCHAR(30) NOT NULL DEFAULT ""
    );
    
CREATE TABLE Matiere_Enseignable (
    user_id int NOT NULL REFERENCES Utilisateur(user_id),
    matiere_id int NOT NULL REFERENCES Type_Matiere(matiere_id)
    );
    
CREATE TABLE Enseignement (
    enseignement_id int PRIMARY KEY,
    etudiant_id int REFERENCES Utilisateur(user_id),
    professeur_id int REFERENCES Utilisateur(user_id),
    matiere_id int REFERENCES Type_Matiere(matiere_id)
    );
    
CREATE TABLE Document (
    document_id int PRIMARY KEY,
    document_nom VARCHAR(20) NOT NULL DEFAULT "",
    document_lien VARCHAR(200) NOT NULL DEFAULT "",
    date_creation DATETIME,
    date_modification DATETIME,
    createur_id int NOT NULL REFERENCES Utilisateur(user_id),
    doc_type ENUM('Facture','Fiche de paie','Autre') NOT NULL DEFAULT 'Autre'
    );
    
CREATE TABLE Cours (
    cours_id int PRIMARY KEY,
    cours_enseignement int REFERENCES Enseignement(enseignement_id),
    cours_nom VARCHAR(30) NOT NULL,
    cours_date DATETIME NOT NULL,
    cours_verification BOOLEAN,
    cours_document int REFERENCES Document(document_id),
    cours_duree float NOT NULL DEFAULT 0.0,
    cours_description VARCHAR(300)
    );

CREATE TABLE Evenement (
    event_id int PRIMARY KEY,
    event_nom_event VARCHAR(20) NOT NULL DEFAULT "",
    event_date_debut DATE ,
    event_date_fin DATE ,
    event_description VARCHAR(300),
    event_createur int NOT NULL REFERENCES Utilisateur(user_id)
    );

CREATE TABLE Option_Event (
    event_id int NOT NULL REFERENCES Evenement(event_id),
    user_id int NOT NULL REFERENCES Utilisateur(user_id),
    rappel int DEFAULT 0,
    frequence int DEFAULT 0
    );



ALTER TABLE Matiere_Enseignable ADD PRIMARY KEY (user_id,matiere_id);


DELIMITER |
/* un trigger qui crée une ligne dans Utilisateur apres avoir inserer un id dans auth_user */
CREATE trigger New_Utilisateur_ligne_après_Auth_user BEFORE INSERT ON auth_user
	FOR EACH ROW
	BEGIN
    insert into Utilisateur(id) values (new.id);
    END |


/* un trigger s'assurant que user_id de matiere_enseignable est bien celui d'un professeur_id (user_role ?) */
CREATE TRIGGER UserID_MatiereEnseignable_estUnProfesseur BEFORE INSERT ON matiere_enseignable
FOR EACH ROW  
BEGIN  
    SELECT user_role FROM Utilisateur
    IF user_role <=> 'Professeur' THEN
        insert into matiere_enseignable(user_id, matiere_id) values (new.user_id , new.matiere_id)
    END IF;
    ELSE   
		ErreurPourEtudiant SQLSTATE 'Etudiant' SET MESSAGE_TEXT = "L'user_id entré dans matiere_enseignable n'est pas celui d'un professeur mais d'un Etudiant";
		ErreurPourAutre SQLSTATE 'Autre' SET MESSAGE_TEXT = "L'user_id entré dans matiere_enseignable n'est pas celui d'un professeur mais Autre";

	END ELSE;  
END| 



/* un trigger s'assurant que user_id de option_event est bien celui d'un professeur_id */
CREATE TRIGGER UserID_OptionEvent_estUnProfesseur BEFORE INSERT ON option_event
FOR EACH ROW  
BEGIN  
    SELECT user_role FROM Utilisateur
    IF user_role <=> 'Professeur' THEN
        insert into option_event(user_id, event_id) values (new.user_id , new.event_id)
    END IF;
    ELSE   
		ErreurPourEtudiant SQLSTATE 'Etudiant' SET MESSAGE_TEXT = "L'user_id entré dans option_event n'est pas celui d'un professeur mais d'un Etudiant";
		ErreurPourAutre SQLSTATE 'Autre' SET MESSAGE_TEXT = "L'user_id entré dans option_event n'est pas celui d'un professeur mais Autre";

	END ELSE;  
END|  
DELIMITER ;

/* un trigger s'assurant que enseignement_id de enseignement est bien celui d'un statut professeur et eleve */
CREATE TRIGGER enseignementID_enseignement_estUnProfesseurETunEleve BEFORE INSERT ON option_event
FOR EACH ROW  
BEGIN  
    SELECT user_role FROM Utilisateur
    IF user_role <=> 'Professeur' or 'Eleve' THEN
        insert into enseignement_id(enseignement_id, etudiant_id) values (new.enseignement_id , new.etudiant_id)
    END IF;
    ELSE   
		ErreurPourEtudiant SQLSTATE 'Etudiant' SET MESSAGE_TEXT = "L'id entré dans la table enseignement n'est pas celui d'un etudiant";
		ErreurPourProfesseur SQLSTATE 'Autre' SET MESSAGE_TEXT = "L'id entré dans la table enseignement n'est pas celui d'un professeur ";

	END ELSE;  
END|  
DELIMITER ;
