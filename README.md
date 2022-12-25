# Objectif 

Ce projet a pour but de mettre en application l'ensemble des connaissances acquises sur l'une des technologies les plus importantes du devops, à savoir, Terraform. Et cela, à travers le déploiement d'un site portfolio développé sous Bootstrap dans le cadre d'un projet d'école.

Terraform présente de nombreux avantages, notamment la facilité à répliquer l'infrastructure très rapidement tout en améliorant sa cohérence et en réduisant les couts ainsi que les écarts de configuration.


# Documentation

Cette documentation vous accompagnera pas à pas dans le déploiement du projet.


# Pré-requis

- un compte GCP relié à un compte de facturation
- un domaine géré dans le cloud DNS
- le contenu d'un site à publier au CDN (ici, le site portfolio)
- Terraform et GCloud. (Nous allons expliquer comment les installer sous votre machine)


## 1. Création d'environnement

    • Ouvrir la machine virtuelle (codespace) :
    accéder à github.com > au repo "devops-technical-tests" > cliquez sur le bouton vert "Code" > puis sur "codespaces" > et enfin, sur "create code space on master" 


## 2. Installer Terraform : 

Pour commencer, il faut installer Terraform. Voici un tuto qui explique en détail comment installer Terraform sous Linux ubunto. 

**N'oubliez pas de selectionner l'onglet "ubunto/debian" au niveau de la seconde section intitulée "install Terraform"** 

=> https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli

Une fois l'installation terminée, on peut vérifier que cette dernière a bien été effectuée en tapant ```terraform -help```  

<br>

## 3. Se connecter à la console :

Pour cela, nous avons deux choix : 

    1. on peut utiliser une clé de compte de service importée depuis GCP. Ou alors, il est possible d'installer GCloud. Cette derniere est la méthode la plus pratique. 

Voici un tuto qui explique comment l'installer sur une MV Linux Ubunto => https://www.educative.io/answers/how-to-install-google-cloud-cli-on-debian-ubuntu

    2. Et si vous souhaitez utiliser une clé, voici comment faire : https://cloud.google.com/iam/docs/creating-managing-service-account-keys?hl=fr


**Notez que dans ce cas de figure, il faudra déclarer une nouvelle variable dans le fichier 'variables.tf' et d'y mettre le path (chemin d'accés) du fichier contenant la clé "../account.json"**

<br>


## Importer le repo sur la MV :

    sur la MV, créez un nouveau dossier vide dans lequel on importera le repo : ```mkdir <new-folder>``` 
    sur le repo github "devops-technical-tests", cliquez sur "code" > "local" > "clone : https" > copier le lien https
    se rendre sur la MV, dans le nouveau dossier, tapez ```git clone https://github.com/InnovOrder/sonia-lab.git``` 


## Exécuter les configurations Terraform

    1. entrer un `terraform init` --> pour initialiser un répertoire de travail contenant les fichiers de configuration de Terraform
    2. entrer un `terraform plan`--> cela nous indiquera toutes les actions +/-/~ qui seront exécutées suite à la prochaine commande
    3. entrer un `terraform apply`--> pour exécution
    

## Mettre à jour ou détruire le projet

    1. entrer un 'terraform plan' --> pour appliquer des modifications que vous venez d'effectuer sur la configuration Terraform
    2. entrer un 'terraform apply' --> pour executer les modifs
    3. entrer un 'terraform destroy' --> pour detruire le projet, ainsi, toutes les ressources créées via ce code tf seront détruites


## . Importer le state :

Le remote state permet de centraliser le state pour le rendre accessible à toute l'équipe mais aussi de le garder en sécurité et chiffré. 

    1. Sur le terminal, vous tapez :  `gcloud config set project innovorder-lab` pour se connecter au projet sur la console si besoin
    2. vous tapez : `gcloud services enable storage.googleapis.com` pour activer les Cloud storage API 
    3. ajouter ce bout de code affiché en dessous dans le fichier "ressources.tf"
        ````
    terraform {
    backend "gcs" {
    bucket  = "portfolio-lab"
    prefix  = "terraform/state"
     }
    }
    ``` 
    4. tapez : `terraform plan`, 'terraform apply`
    5. se rendre sur la console, actualiser la page des buckets

## Workspaces

Ici, nous avons créer deux nouveaux workspaces. un lab et un dev. Voici un petit rappel des commandes de bases a connaitre pour les workspaces : 

`terraform workspace new <prod>` : pour créer un nouveau workspace (remplacer le nom dans prod) et on se rendra directement dedans
`terraform workspace list` : pour lister les workspaces
`terraform workspace select <dev>` : pour se rendre dans un workspace
`terraform workspace show` : pour savoir dans quel workspace on se situe 



## Récapitulatif

Pour déployer un site static via GCP, il va nous falloir : 
    1. Bucket : permet de stocker les fichiers du site web
    2. DNS : c'est le nom de domaine qui sera relié à une IP
    3. CDN backend : permet de relier le bucket et le LB
    4. Load Balancer : permet d'améliorer la disponibilité et rapidité du site


## 

https://spacelift.io/blog/how-to-use-terraform-variables



questions :: 
(qu'est ce qui est connecter à la console ? Tf ou la machine ?)