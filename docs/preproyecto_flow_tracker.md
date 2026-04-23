# Flow-Tracker

## Tracker de Hàbits i Xarxa Social

**Preprojecte del Crèdit de Síntesi · DAM AMS2**

---

| Camp | Detall |
| :---- | :---- |
|  |  |
| **Curs / Grup** | Desenvolupament d'Aplicacions Multiplataforma · AMS2 |
| **Mòdul** | MP13 · Projecte de Desenvolupament d'Aplicacions Multiplataforma |
| **Data d'entrega** | 3 de Març 2026 |
|  |  |

---

## Índex

1. [Nom del Projecte](#1-nom-del-projecte)  
2. [Participants](#2-participants)  
3. [Descripció Breu i Clara del Projecte](#3-descripció-breu-i-clara-del-projecte)  
   - 3.1 Descripció general  
   - 3.2 Antecedents i context  
   - 3.3 Objectius generals  
4. [Motivació](#4-motivació)  
   - 4.1 Interès personal i professional  
   - 4.2 Necessitat real i problema a resoldre  
   - 4.3 Beneficis esperats  
5. [Descripció del que s'Implementarà](#5-descripció-del-que-simplementarà)  
   - 5.1 Funcionalitats mínimes (obligatòries) — MVP  
   - 5.2 Funcionalitats desitjades (opcionals / millora)  
6. [Descripció del que s'Investigarà](#6-descripció-del-que-sinvestigarà)  
   - 6.1 Tecnologies de frontend  
   - 6.2 Tecnologies de backend  
   - 6.3 Bases de dades  
   - 6.4 Desplegament i infraestructura  
   - 6.5 Metodologia i control de versions  
7. [Material Hardware / Software Necessari](#7-material-hardware--software-necessari)  
   - 7.1 Hardware  
   - 7.2 Software i tecnologies  
8. [Planificació i Temporització (Metodologia SCRUM)](#8-planificació-i-temporització-metodologia-scrum)  
   - 8.1 Estimació global  
   - 8.2 Sprints proposats  
   - 8.3 Tasques i responsabilitats  
9. [Possibles Dificultats](#9-possibles-dificultats)  
10. [Conclusions](#10-conclusions)  
11. [Bibliografia i Referències](#11-bibliografia-i-referències)  
12. [Full de Comentaris del Professorat](#12-full-de-comentaris-del-professorat)

## 3\. Descripció Breu i Clara del Projecte

### 3.1 Descripció general

Flow-Tracker és una aplicació multiplataforma que permet als usuaris crear, gestionar i fer el seguiment dels seus hàbits i activitats diàries de manera personalitzada. Combina les funcionalitats d'un tracker de productivitat personal amb les d'una xarxa social lleugera. Cada usuari pot definir les seves pròpies categories d'activitat mitjançant etiquetes (*tags*) lliures, registrar el compliment diari i visualitzar el seu progrés a través de gràfiques i estadístiques interactives.

A més, la plataforma ofereix un component social on els usuaris poden connectar-se amb amics i veure el progrés dels seus contactes, afegint un factor de motivació col·lectiva al seguiment individual. L’aplicació s’implementarà com una aplicació multiplataforma desenvolupada amb Flutter, disponible com a app nativa per a Android i Windows, i també accessible des del navegador web. Es desplegarà sobre el servidor Proxmox del departament d’Informàtica de l’institut, gestionant els processos de Node.js amb PM2 o systemd.

### 3.2 Antecedents i context

Existeixen aplicacions populars de tracking d'hàbits com Habitica, Streaks o Notion, però presenten limitacions rellevants: Habitica és excessivament gamificada; Streaks és exclusiva d'iOS; i Notion requereix configuració molt manual per a aquest ús. Cap d'elles combina de forma nativa el seguiment personalitzable per *tags* amb una xarxa social integrada pensada per a grups petits. Flow-Tracker neix per cobrir aquesta necessitat: una eina senzilla, flexible i social, desplegada en infraestructura pròpia del centre.

### 3.3 Objectius generals

- Desenvolupar una aplicació multiplataforma funcional i desplegada en un entorn real (servidor Proxmox del departament).  
- Permetre als usuaris registrar i visualitzar hàbits i activitats amb estadístiques clares i visuals.  
- Incorporar un component social que afegeixi motivació i valor col·lectiu a l'eina.  
- Aplicar una metodologia de treball àgil (SCRUM) amb control de versions (Git/GitHub).  
- Adquirir experiència pràctica amb tecnologies modernes i demandades en el sector professional.

---

## 4\. Motivació

### 4.1 Interès personal i professional

La idea sorgeix de la necessitat pròpia dels membres del grup de disposar d'una eina senzilla per fer el seguiment de rutines com l'exercici físic, les hores d'estudi o la lectura, sense dependre d'aplicacions de pagament ni de plataformes que no respecten la privacitat. Des del punt de vista professional, el projecte permet treballar amb un stack tecnològic (Flutter, Node.js, PostgreSQL) molt demandat al mercat laboral actual, cosa que representa una oportunitat real d'aprenentatge aplicat i directament transferible a un entorn de treball.

### 4.2 Necessitat real i problema a resoldre

Mantenir hàbits saludables és difícil sense un sistema de seguiment visual i sense el suport social de l'entorn. Les aplicacions existents o bé són massa complexes, o bé no ofereixen la flexibilitat necessària per adaptar-se a qualsevol tipus d'activitat. Flow-Tracker resol aquesta situació amb una interfície minimalista i un sistema de *tags* lliures que permeten categoritzar qualsevol activitat sense restriccions predefinides de la plataforma.

### 4.3 Beneficis esperats

- **Per als usuaris finals:** disposar d'una eina gratuïta, accessible des de qualsevol dispositiu, allotjada en infraestructura pròpia i sense necessitat de cedir dades a tercers.  
- **Per als desenvolupadors:** adquirir experiència real en el desenvolupament full-stack, en el desplegament de serveis multiplataforma en producció i en el treball en equip amb metodologies àgils.  
- **Per al centre educatiu:** demostrar la capacitat dels alumnes d'implementar solucions tecnològiques reals sobre la infraestructura del departament, posant en valor el servidor Proxmox disponible.

---

## 5\. Descripció del que s'Implementarà

### 5.1 Funcionalitats mínimes (obligatòries) — MVP

Les funcionalitats mínimes defineixen la versió viable del producte (MVP). L'aplicació no es considerarà funcional fins que totes elles estiguin operatives. S'han triat les estrictament necessàries per garantir un producte funcional i entregable dins del temps disponible (100 hores totals d'equip, 50 per membre).

1. **Registre i autenticació d'usuaris.** Creació de compte amb correu electrònic i contrasenya. Gestió de sessions amb tokens JWT.  
2. **Gestió del perfil d'usuari.** Perfil editable amb nom, avatar i estadístiques globals de compliment.  
3. **Creació i gestió d'hàbits i activitats.** L'usuari pot crear activitats pròpies amb nom, descripció i un o més *tags* de categoria personalitzats (p. ex.: "esport", "estudi", "lectura").  
4. **Registre diari de compliment.** Per a cada activitat, l'usuari pot marcar si l'ha realitzada o no cada dia, generant un historial de compliment.  
5. **Visualització d'estadístiques personals.** Gràfiques de compliment setmanal i mensual per activitat, ratxes actuals i màximes, i calendari de calor (*heatmap*) estil GitHub.  
6. **Sistema d'amistats.** Enviar i acceptar sol·licituds d'amistat per crear una llista de contactes dins la plataforma.  
7. **Feed social amb assoliments automàtics.** Feed on es mostren automàticament publicacions d'assoliments dels amics (p. ex.: "L'usuari X ha completat 7 dies seguits d'exercici").  
8. **Disseny responsiu.** La interfície s'adapta correctament a dispositius mòbils, tauletes i ordinadors de sobretaula.

### 5.2 Funcionalitats desitjades (opcionals / millora)

Les funcionalitats opcionals s'implementaran si la planificació i el temps ho permeten. Aporten valor afegit però no condicionen la viabilitat del producte.

1. **Publicació manual d'assoliments.** L'usuari pot publicar un missatge personalitzat al feed, visible per als seus amics.  
2. **Sistema de reaccions (likes).** Els usuaris poden reaccionar amb un "like" a les publicacions del feed dels seus amics.  
3. **Sistema de reptes entre amics.** Proposar un repte a un amic (p. ex.: "30 dies d'exercici") i fer-ne el seguiment conjunt.  
4. **Notificacions in-app.** Alertes en temps real de nous likes, sol·licituds d'amistat o reptes rebuts.  
5. **Ranking setmanal entre amics.** Classificació setmanal dels amics per percentatge de compliment total.  
6. **Personalització de tema visual.** Mode clar i mode fosc a la interfície.  
7. **Exportació de dades personals.** Exportar l'historial d'activitat en format CSV per a ús personal.  
8. **Comentaris al feed.** Permetre als usuaris comentar les publicacions dels seus amics.  
9. **Estadístiques agregades del grup.** Visualització de les tendències globals entre amics (p. ex.: activitat més seguida pel grup).

---

## 6\. Descripció del que s'Investigarà

Per dur a terme el projecte amb garanties de qualitat, caldrà investigar i aprendre els aspectes tècnics i teòrics següents. Molts d'ells van més enllà dels continguts treballats a classe i representen la part d'aprenentatge autònom del projecte.

### 6.1 Tecnologies de frontend

- Arquitectura de widgets amb **Flutter** i gestió d'estat amb **Provider** o **Riverpod**.  
- Disseny d'interfícies adaptatives amb els widgets de Material Design de Flutter.  
- Implementació de gràfiques interactives amb la biblioteca **fl\_chart**: gràfiques de barres, línies i heatmap.  
- Navegació entre pantalles amb **GoRouter** o el navegador natiu de Flutter.  
- Comunicació asíncrona amb l'API REST del backend mitjançant el paquet **dio** o **http**.  
- Compilació a APK (Android) i build web per al desplegament al servidor Proxmox.

### 6.2 Tecnologies de backend

- Creació d'una API REST amb **Node.js** i el framework **Express**: definició de rutes, controladors i middlewares.  
- Autenticació segura mitjançant **JWT (JSON Web Tokens)**: generació, validació i renovació de tokens.  
- Gestió segura de contrasenyes amb **bcrypt**: aplicació de hash i salt per evitar emmagatzemar-les en text pla.  
- Validació i sanitització de dades d'entrada al backend per prevenir injeccions i atacs XSS.

### 6.3 Bases de dades

- Disseny d'un esquema relacional amb **PostgreSQL**: taules, relacions, claus foranies i índexs per a consultes eficients.  
- Ús de consultes SQL complexes per a les estadístiques (agregacions i funcions de finestra).  
- Ús de **Prisma ORM** per simplificar les operacions CRUD, gestionar les migracions i disposar d'un esquema tipat.

### 6.4 Desplegament i infraestructura (sense Docker)

- Desplegament sobre el servidor **Proxmox** del departamen per allotjar l'aplicació i la base de dades en producció.  
- Gestió dels processos Node.js amb **PM2** o com a serveis **systemd** per garantir reinicis automàtics i gestió de logs.  
- Configuració d'un servidor web invers (**Nginx**) per fer de proxy invers i gestionar el TLS (Let's Encrypt si és possible).  
- Estratègia de desplegament: build del frontend en local, còpia al servidor amb `scp/rsync` o Git pull en producció, i scripts d'inicialització i migracions de base de dades.  
- Gestió de variables d'entorn i secrets mitjançant fitxers `.env` protegits al servidor.

### 6.5 Metodologia i control de versions

- Treball en equip amb **Git** i **GitHub**: branques per funcionalitat (*feature branches*), pull requests i resolució de conflictes de fusió.  
- Aplicació de la metodologia àgil **SCRUM**: backlog de producte, sprints, revisió i retrospectiva al final de cada sprint.  
- Gestió i seguiment de tasques amb **GitHub Projects** o **Trello**.

---

## 

## 7\. Material Hardware / Software Necessari

### 7.1 Hardware

| Recurs | Descripció i ús | Disponibilitat |
| :---- | :---- | :---- |
| Servidor Proxmox | Servidor de virtualització del departament. S'hi crearan VM o contenidors LXC per desplegar l'aplicació i la base de dades en producció, accessible a la xarxa del centre. | Proporcionat pel centre |
| Espai en disc (servidor) | Mínim 10 GB per a les imatges del projecte, la base de dades PostgreSQL i els fitxers estàtics del frontend. | Proporcionat pel centre |
| Ordinadors de treball (×2) | Un PC per a cada membre del grup per al desenvolupament local. Requereixen mínim 8 GB de RAM per executar Node.js, PostgreSQL local i el navegador simultàniament. | PCs del departament / personals |
| Connexió a la xarxa local | Accés a la xarxa del departament per connectar-se al servidor Proxmox durant el desplegament i les proves de producció. | Infraestructura del centre |

### 7.2 Software i tecnologies

| Eina / Tecnologia | Versió | Ús en el projecte | Justificació |
| :---- | :---- | :---- | :---- |
| **Flutter**  | SDK 3.x  | Per desenvolupar una aplicació multiplataforma que funcioni en Android, Windows i també com a web, amb una interfície atractiva i coherent en tots els dispositius. | Permet crear una sola aplicació per diverses plataformes, facilita mostrar gràfics i animacions per al progrés dels usuaris i aprofita els coneixements previs de l’alumnat en DAM. |
| **Material Design** | Integrat a Flutter | S’utilitza Material Design per crear una interfície visual clara, moderna i coherent, amb botons, menús i formularis fàcils d’utilitzar pels usuaris. | Proporciona components i estils ja definits, estalviant temps de disseny i garantint una experiència d’usuari consistent en tota l’aplicació. |
| **fl\_chart** | Última estable | S’utilitza fl\_chart per crear gràfics i visualitzacions dins de l’aplicació Flutter, mostrant el progrés dels usuaris i comparatives amb els seus contactes. | Permet generar gràfics atractius i interactius de manera fàcil, millorant la comprensió de les dades i la motivació dels usuaris dins de l’aplicació. |
| **Node.js \+ Express** | Node 20 LTS | Entorn d'execució i framework per al backend (API REST). | Mateix llenguatge (JavaScript) al frontend i al backend, reduint la corba d'aprenentatge de l'equip. |
| **PostgreSQL** | v15+ | Sistema gestor de bases de dades relacionals. | Robust, gratuït, estàndard al sector i amb bon suport per a consultes complexes d'estadístiques. |
| **Prisma ORM** | Última estable | ORM per simplificar les operacions amb la base de dades. | Esquema tipat, migracions automàtiques i protecció contra injeccions SQL per defecte. |
| **PM2 / systemd** | Última estable | Gestió de processos Node.js en producció al servidor. | Permet reinicis automàtics, gestió de logs i alta disponibilitat sense necessitat de Docker. |
| **Nginx** | Última estable | Servidor web invers per exposar l'aplicació i gestionar TLS. | Lleuger, estable i àmpliament usat com a reverse proxy per a aplicacions Node.js. |
| **Git \+ GitHub** | Git 2.x | Control de versions i col·laboració entre els dos membres del grup. | Eina estàndard imprescindible del sector per al treball en equip en projectes de software. |
| **Visual Studio Code** | Última estable | IDE de desenvolupament per als dos membres. | Gratuït, lleuger, amb extensions per a React, Node.js i PostgreSQL integrades. |
| **Postman** | Última estable | Proves i documentació de l'API REST durant el desenvolupament. | Simplifica la depuració del backend sense necessitat de tenir la interfície visual llesta. |
| **Trello / GitHub Projects** | Web | Gestió de tasques i seguiment dels sprints SCRUM. | Gratuït, visual i adequat per a equips petits que segueixen metodologia àgil. |
| **bcrypt \+ JWT** | Biblioteques npm | Hash de contrasenyes i gestió de sessions autenticades. | Estàndards de seguretat consolidats en aplicacions web modernes. |

---

## 8\. Planificació i Temporització (Metodologia SCRUM)

### 8.1 Estimació global

El projecte disposa d'un total de **100 hores d'equip** (aproximadament **50 hores per membre**), emmarcades en el Mòdul Professional 13 (99 hores lectives). S'estima una durada de **10 a 11 setmanes** distribuïdes en **4 sprints** de durada variable, amb una reunió de revisió i retrospectiva al final de cada un.

| Fita | Descripció | Setmana estimada |
| :---- | :---- | :---- |
| Kick-off | Definició final del projecte, configuració de l'entorn de desenvolupament i repositori Git. | Setmana 1 |
| MVP | Autenticació, CRUD d'hàbits, registre diari i estadístiques personals funcionals. | Setmana 4–5 |
| Versió Beta | Funcionalitats socials (amistats, feed) operatives i primer desplegament al servidor Proxmox. | Setmana 7–8 |
| Entrega final | Aplicació completa en producció, documentació tècnica, guia d'usuari i presentació. | Setmana 10–11 |

### 8.2 Sprints proposats

---

**Sprint 1 · Setmanes 1–2 · \~20 h equip · Configuració i autenticació**

Objectius:

- Configuració del repositori Git amb estructura de branques (*main*, *develop*, branques per funcionalitat) i convencions de commits.  
- Disseny de l'esquema de la base de dades (diagrama entitat-relació) i configuració de l'entorn local (Node.js, React, PostgreSQL).  
- Implementació del registre i login d'usuaris amb JWT i hash de contrasenyes amb bcrypt al backend.  
- Pantalles de login, registre i dashboard buit amb navegació bàsica al frontend.

**Entregables:** esquema de BBDD, API d'autenticació funcional, pantalles de login i registre operatives.

---

**Sprint 2 · Setmanes 3–5 · \~30 h equip · Tracking i estadístiques**

Objectius:

- CRUD complet d'hàbits i activitats amb sistema de *tags* lliures personalitzables.  
- Pantalla de registre diari: marcar activitats com a completades o no per a cada dia.  
- Pàgina de perfil d'usuari amb dades editables i estadístiques globals de compliment.  
- Gràfiques de seguiment setmanal i mensual per activitat (Recharts) i heatmap anual estil GitHub.

**Entregables:** MVP funcional amb tracking complet i visualització d'estadístiques personals operatives.

---

**Sprint 3 · Setmanes 6–8 · \~30 h equip · Funcionalitats socials i desplegament**

Objectius:

- Sistema d'amistats: enviar, acceptar i eliminar contactes a la plataforma.  
- Feed social amb publicacions automàtiques d'assoliments (ratxes, fites completades).  
- Primer desplegament de l'aplicació al servidor Proxmox (VM o LXC), configurant Nginx com a reverse proxy i PM2 o systemd per a l'execució del servei Node.js.

**Entregables:** versió Beta desplegada al servidor Proxmox amb les funcionalitats socials mínimes operatives.

---

**Sprint 4 · Setmanes 9–11 · \~20 h equip · Poliment, proves i documentació**

Objectius:

- Correcció de bugs detectats durant les proves d'usuari i la revisió del Sprint 3\.  
- Implementació de funcionalitats opcionals si el temps ho permet (likes, publicació manual, mode fosc, exportació CSV).  
- Proves funcionals i de seguretat: validació d'entrades, control d'accés i protecció de rutes.  
- Redacció de la documentació tècnica (guia de programador) i la guia d'usuari.  
- Preparació i assaig de la presentació final del projecte.

**Entregables:** aplicació final en producció, documentació completa i presentació preparada.

---

### 8.3 Tasques i responsabilitats

La distribució de tasques s'ha fet intentant equilibrar la càrrega de treball entre els dos membres, assignant el backend principalment a un membre i el frontend a l'altre, amb tasques compartides en les parts que requereixen coordinació.

| Tasca principal | Responsable | Hores \[Membre 1\] | Hores \[Membre 2\] | Total (h) |
| :---- | :---- | :---- | :---- | :---- |
| Disseny de l'esquema de BBDD i migracions Prisma | \[Membre 1\] | 7 | — | 7 |
| Desenvolupament de l'API REST (Node.js \+ Express) | \[Membre 1\] | 17 | — | 17 |
| Autenticació JWT i seguretat del backend (bcrypt) | \[Membre 1\] | 5 | — | 5 |
| Backend funcionalitats socials (feed, amistats) | \[Membre 1\] | 7 | — | 7 |
| Desplegament Proxmox (VM/LXC), Nginx i PM2 | \[Membre 1\] | 8 | — | 8 |
| Disseny d'UI i maquetació **(Flutter \+ Material Design)** | \[Membre 2\] | — | 15 | 15 |
| Integració gràfiques i estadístiques **(fl\_chart)** | \[Membre 2\] | — | 9 | 9 |
| Integració frontend↔API **(dio, gestió d'estat amb Provider)** | \[Membre 2\] | — | 8 | 8 |
| Frontend funcionalitats socials (feed, amistats UI) | \[Membre 2\] | — | 6 | 6 |
| Poliment visual i compilació APK \+ build web | \[Membre 2\] | — | 5 | 5 |
| Proves funcionals, seguretat i QA | Tots dos | 3 | 4 | 7 |
| Documentació tècnica (guia de programador) | Tots dos | 2 | 3 | 5 |
| Preparació de la presentació final | Tots dos | 1 | — | 1 |
| **TOTAL** |  | **50 h** | **50 h** | **100 h** |

---

## 9\. Possibles Dificultats

| Risc identificat | Probabilitat | Impacte | Pla de contingència |
| :---- | :---- | :---- | :---- |
| Falta de coneixement previ de **Flutter/Dart** i Node.js | Mitjana | Mitjà | Dedicar la primera setmana a repassar conceptes i investigar. La documentació oficial és molt completa. Es poden usar plantilles base per no aturar el progrés del grup. |
| Problemes de configuració del servidor Proxmox | Mitjana | Alt | Demanar suport al professor o al responsable. Mantenir un entorn local completament funcional per no bloquejar el desenvolupament mentre es resol. |
| Desequilibri en la distribució de tasques entre membres | Baixa | Mitjà | Reunions de seguiment setmanals per revisar l'estat de les tasques. Ús de Trello o GitHub Projects per fer visible el progrés de cadascú en tot moment i redistribuir si cal. |
| Abast del projecte massa gran per al temps disponible | Mitjana | Alt | Separació clara i documentada entre MVP i funcionalitats opcionals des del primer dia. Si el temps s'esgota, es descarten les opcionals garantint sempre un MVP funcional i entregable. |
| Problemes de seguretat (injeccions SQL, exposició de dades) | Baixa | Alt | Usar Prisma ORM (prevé injeccions SQL per defecte), validar totes les entrades al backend, gestionar secrets amb fitxers `.env` i no emmagatzemar mai contrasenyes en text pla ni tokens al codi font. |
| Conflictes en el repositori Git per treball simultani | Mitjana | Baix | Usar branques separades per a cada funcionalitat i fer pull requests per integrar canvis. Comunicació constant entre membres per evitar modificar els mateixos fitxers alhora. |

---

## 10\. Conclusions

Flow-Tracker representa un projecte equilibrat entre ambició i viabilitat, sempre que es mantingui un control estricte de l'abast. La idea de fusionar un tracker d'hàbits amb un dashboard d'estadístiques i una capa social és adequada i aporta un fil conductor clar: seguiment personal → visualització d'evolució → motivació social. Aquesta lògica facilita la coherència entre les funcionalitats, on les estadístiques no són un "dashboard" aïllat sinó el motor de la interacció social.

Per a dos alumnes amb 100 hores d'equip, la prioritat absoluta és el nucli del MVP: autenticació, CRUD d'hàbits, registre diari, estadístiques (heatmap i ratxes) i un sistema social mínim (amistats i feed automàtic). Funcionalitats com les reaccions, publicacions manuals, notificacions en temps real o analytics agregades queden explícitament com a opcionals per si sobra temps al Sprint 4\.

El pla de desplegament s'ha adaptat a l'entorn del centre (Proxmox sense Docker), mitjançant VM o LXC i gestió amb PM2 o systemd. Aquesta decisió és viable però requereix atenció a les versions de Node.js i PostgreSQL instal·lades, als scripts d'inicialització i a la configuració de Nginx per garantir que l'aplicació funcioni correctament en producció i sigui accessible a la xarxa del centre.

---

## 11\. Bibliografia i Referències

- Documentació oficial de Flutter: [https://flutter.dev/docs](https://flutter.dev/docs)  
- Documentació oficial de Dart: [https://dart.dev/guides](https://dart.dev/guides)  
- Biblioteca fl\_chart: [https://pub.dev/packages/fl\_chart](https://pub.dev/packages/fl_chart)  
- Paquet dio (HTTP client per a Dart): [https://pub.dev/packages/dio](https://pub.dev/packages/dio)  
- Documentació oficial de PostgreSQL: [https://www.postgresql.org/docs](https://www.postgresql.org/docs)  
- Documentació oficial de Prisma ORM: [https://www.prisma.io/docs](https://www.prisma.io/docs)  
- Documentació oficial de PM2: [https://pm2.keymetrics.io](https://pm2.keymetrics.io)  
- Documentació oficial de Nginx: [https://nginx.org/en/docs](https://nginx.org/en/docs)  
- Introducció a JWT (JSON Web Tokens): [https://jwt.io/introduction](https://jwt.io/introduction)  
- OWASP Top 10 – Seguretat en aplicacions web: [https://owasp.org/www-project-top-ten](https://owasp.org/www-project-top-ten)  
- The Scrum Guide (Schwaber & Sutherland, 2020): [https://scrumguides.org](https://scrumguides.org)

---

 

 

 

 

 

 

