

**Flow-Tracker**

Tracker de Hàbits i Xarxa Social

**Planificació del Projecte**

DAM AMS2  |  MP13 Projecte  |  Credit de Sintesi

5 de Març 2026  —  Presentació: 15 de Maig 2026

# **1\. Backlog de Tasques**

El projecte es planifica en 4 sprints distribuïts entre el 05/03/2026 i el 07/05/2026, amb una dedicació de 66 hores per membre (132 hores d'equip). La presentació final es el 15 de maig. Les tasques marcades \[OPC\] en cursiva son opcionals i només s'implementen si el temps ho permet.

## **Sprint 1  |  S01-S02  |  05/03 \- 12/03  |  Configuració i Autenticació**

| ID | Tasca | Resp. | Hores | Sessió/es | Categoria |
| ----- | ----- | :---: | :---: | ----- | :---: |
| **B01** | Planificació del projecte, backlog i calendarització | Tots | **4h** | S01 | Planificació |
| **B02** | Configuració repositori Git (branques, convencions de commits) | Tots | **2h** | S01, S02 | Infraestructura |
| **B03** | Configuració entorn local: Node.js, PostgreSQL i Flutter SDK | Tots | **2h** | S01, S02 | Infraestructura |
| **B04** | Setup Proxmox: VM/LXC \+ Node.js \+ PostgreSQL en producció | M1 | **3h** | S01, S02 | DevOps |
| **B05** | Disseny esquema BBDD (diagrama ER) \+ configuración Prisma | M1 | **3h** | S01, S02 | Backend |
| **B06** | API REST: registre d'usuaris (bcrypt) \+ login \+ JWT | M1 | **4h** | S02 | Backend |
| **B07** | Pantalles login i registre (Flutter) \+ navegacio basica | M2 | **5h** | S01, S02 | Frontend |
| **B08** | Integració autenticació frontend \<-\> API (JWT, rutes protegides) | M2 | **2h** | S02 | Integració |
| **TOTAL** |  |  | **25h** |  |  |

## **Sprint 2  |  S03-S05  |  19/03 \- 02/04  |  Tracking i Estadístiques**

| ID | Tasca | Resp. | Hores | Sessió/es | Categoria |
| ----- | ----- | :---: | :---: | ----- | :---: |
| **B09** | Proxmox: Nginx reverse proxy \+ PM2/systemd \+ 1r desplegament API | M1 | **3h** | S03 | DevOps |
| **B10** | API REST: CRUD habits/activitats \+ sistema de tags lliures | M1 | **4h** | S03, S04 | Backend |
| **B11** | API REST: registre diari de compliment (check/uncheck per dia) | M1 | **3h** | S04 | Backend |
| **B12** | API REST: estadístiques (ratxes, percentatge, dades heatmap) | M1 | **4h** | S04, S05 | Backend |
| **B13** | API REST: perfil d'usuari (get \+ update) | M1 | **1h** | S05 | Backend |
| **B14** | Pantalles CRUD habits \+ tags (Flutter) | M2 | **4h** | S03 | Frontend |
| **B15** | Pantalla registre diari amb check per dia (Flutter) | M2 | **3h** | S03, S04 | Frontend |
| **B16** | Pagina perfil d'usuari editable \+ estadístiques globals (Flutter) | M2 | **2h** | S04 | Frontend |
| **B17** | Gestió d'estat global amb Provider/Riverpod | M2 | **2h** | S04 | Frontend |
| **B18** | Gràfiques setmanal/mensual per activitat (fl\_chart) | M2 | **4h** | S05 | Frontend |
| **B19** | Heatmap anual estil GitHub (fl\_chart) | M2 | **3h** | S05, S06 | Frontend |
| **B20** | Proves de connexió frontend \<-\> API en producció (Proxmox) | Tots | **2h** | S05 | DevOps |
| **TOTAL** |  |  | **35h** |  |  |

## **Sprint 3  |  S06-S08  |  09/04 \- 23/04  |  Funcions Socials i Desplegament Beta**

| ID | Tasca | Resp. | Hores | Sessió/es | Categoria |
| ----- | ----- | :---: | :---: | ----- | :---: |
| **B21** | API REST: sistema d'amistats (enviar, acceptar, eliminar) | M1 | **4h** | S06, S07 | Backend |
| **B22** | API REST: feed social \+ assoliments automàtics (ratxes) | M1 | **4h** | S07, S08 | Backend |
| **B23** | Pantalles amistats: cercar usuaris i sol.licituds (Flutter) | M2 | **4h** | S06, S07 | Frontend |
| **B24** | Pantalla feed social amb publicacions d'assoliments (Flutter) | M2 | **4h** | S07, S08 | Frontend |
| **B25** | Compilacio APK Android \+ build web Flutter | M2 | **2h** | S08 | Frontend |
| **B26** | Desplegament versió Beta al Proxmox \+ migracions Prisma en prod. | M1 | **2h** | S08 | DevOps |
| **TOTAL** |  |  | **20h** |  |  |

## **Sprint 4  |  S09-S10  |  30/04 \- 07/05  |  Poliment, Proves i Documentació**

| ID | Tasca | Resp. | Hores | Sessió/es | Categoria |
| ----- | ----- | :---: | :---: | ----- | :---: |
| **B27** | Correcció de bugs \+ proves de seguretat i control d'accés | Tots | **4h** | S09 | QA |
| **B28** | Proves funcionals end-to-end \+ validació d'entrades al backend | Tots | **3h** | S09, S10 | QA |
| **B29** | Documentació tècnica (guia de programador) \+ guia d'usuari | Tots | **4h** | S10 | Documentació |
| **B30** | Preparació i assaig de la presentació final \+ demo en producció | Tots | **4h** | S10 | Presentació |
| **O01** | \[OPC\] Sistema de likes al feed | Tots | **2h** | S09 | Opcional |
| **O02** | \[OPC\] Publicació manual al feed per part de l'usuari | Tots | **2h** | S09 | Opcional |
| **O03** | \[OPC\] Mode clar/fosc (Flutter) | M2 | **2h** | S10 | Opcional |
| **O04** | \[OPC\] Exportació CSV de l'historial d'activitat | Tots | **2h** | S10 | Opcional |
| **O05** | \[OPC\] Ranking setmanal entre amics | Tots | **2h** | S10 | Opcional |
| **TOTAL** |  |  | **25h** |  |  |

# **2\. Estimació Horaria per Sprint**

| Sprint | Dates | H Membre 1 | H Membre 2 | H Equip | Entregable clau |
| ----- | :---: | :---: | :---: | :---: | ----- |
| **Sprint 1** | 05/03 \- 12/03 | \~14h | \~11h | **25h** | Auth JWT \+ login \+ setup Proxmox |
| **Sprint 2** | 19/03 \- 02/04 | \~16h | \~19h | **35h** | MVP: habits, registre, estadístiques, gràfiques |
| **Sprint 3** | 09/04 \- 23/04 | \~10h | \~10h | **20h** | Feed social \+ amistats \+ Beta Proxmox |
| **Sprint 4** | 30/04 \- 07/05 | \~8h | \~7h | **15h** | QA, documentació, presentació |
| **TOTAL MVP** | **S01 \- S10** | **\~48h** | **\~47h** | **95h** | Marge: 37h d'equip (18h/persona) |

# **3\. Planificació i Calendarització**

Diagrama per sessions. Cada columna correspon a una sessió de dijous. La columna vermella (15/05) indica la presentació final.

|  |  | Sprint 1 S01-S02 |  | Sprint 2 S03-S05 |  |  | Sprint 3 S06-S08 |  |  | Sprint 4 S09-S10 |  | Pres. 15/05 |
| ----- | ----- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **ID** | **Tasca** | **S01 05/03** | **S02 12/03** | **S03 19/03** | **S042 6/03** | **S05 02/04** | **S06 09/04** | **S07 16/04** | **S08 23/04** | **S09 30/04** | **S10 07/05** | **Pres. 15/05** |
| **B01** | Planificació del projecte, backlog i calendarització | ▮ |  |  |  |  |  |  |  |  |  |  |
| **B02** | Configuració repositori Git (branques, convencions de commits) | ▮ | ▮ |  |  |  |  |  |  |  |  |  |
| **B03** | Configuració entorn local: Node.js, PostgreSQL i Flutter SDK | ▮ | ▮ |  |  |  |  |  |  |  |  |  |
| **B04** | Setup Proxmox: VM/LXC \+ Node.js \+ PostgreSQL en producció | ▮ | ▮ |  |  |  |  |  |  |  |  |  |
| **B05** | Disseny esquema BBDD (diagrama ER) \+ configuració Prisma | ▮ | ▮ |  |  |  |  |  |  |  |  |  |
| **B06** | API REST: registre d'usuaris (bcrypt) \+ login \+ JWT |  | ▮ |  |  |  |  |  |  |  |  |  |
| **B07** | Pantalles login i registre (Flutter) \+ navegacio basica | ▮ | ▮ |  |  |  |  |  |  |  |  |  |
| **B08** | Integració autenticació frontend \<-\> API (JWT, rutes protegides) |  | ▮ |  |  |  |  |  |  |  |  |  |
| **B09** | Proxmox: Nginx reverse proxy \+ PM2/systemd \+ 1r desplegament API |  |  | ▮ |  |  |  |  |  |  |  |  |
| **B10** | API REST: CRUD habits/activitats \+ sistema de tags lliures |  |  | ▮ | ▮ |  |  |  |  |  |  |  |
| **B11** | API REST: registre diari de compliment (check/uncheck per dia) |  |  |  | ▮ |  |  |  |  |  |  |  |
| **B12** | API REST: estadístiques (ratxes, percentatge, dades heatmap) |  |  |  | ▮ | ▮ |  |  |  |  |  |  |
| **B13** | API REST: perfil d'usuari (get \+ update) |  |  |  |  | ▮ |  |  |  |  |  |  |
| **B14** | Pantalles CRUD habits \+ tags (Flutter) |  |  | ▮ |  |  |  |  |  |  |  |  |
| **B15** | Pantalla registre diari amb check per dia (Flutter) |  |  | ▮ | ▮ |  |  |  |  |  |  |  |
| **B16** | Pagina perfil d'usuari editable \+ estadístiques globals (Flutter) |  |  |  | ▮ |  |  |  |  |  |  |  |
| **B17** | Gestió d'estat global amb Provider/Riverpod |  |  |  | ▮ |  |  |  |  |  |  |  |
| **B18** | Gràfiques setmanal/mensual per activitat (fl\_chart) |  |  |  |  | ▮ |  |  |  |  |  |  |
| **B19** | Heatmap anual estil GitHub (fl\_chart) |  |  |  |  | ▮ | ▮ |  |  |  |  |  |
| **B20** | Proves de connexió frontend \<-\> API en producció (Proxmox) |  |  |  |  | ▮ |  |  |  |  |  |  |
| **B21** | API REST: sistema d'amistats (enviar, acceptar, eliminar) |  |  |  |  |  | ▮ | ▮ |  |  |  |  |
| **B22** | API REST: feed social \+ assoliments automàtics (ratxes) |  |  |  |  |  |  | ▮ | ▮ |  |  |  |
| **B23** | Pantalles amistats: cercar usuaris i sol.licituds (Flutter) |  |  |  |  |  | ▮ | ▮ |  |  |  |  |
| **B24** | Pantalla feed social amb publicacions d'assoliments (Flutter) |  |  |  |  |  |  | ▮ | ▮ |  |  |  |
| **B25** | Compilacio APK Android \+ build web Flutter |  |  |  |  |  |  |  | ▮ |  |  |  |
| **B26** | Desplegament versió Beta al Proxmox \+ migracions Prisma en prod. |  |  |  |  |  |  |  | ▮ |  |  |  |
| **B27** | Correcció de bugs \+ proves de seguretat i control d'accés |  |  |  |  |  |  |  |  | ▮ |  |  |
| **B28** | Proves funcionals end-to-end \+ validació d'entrades al backend |  |  |  |  |  |  |  |  | ▮ | ▮ |  |
| **B29** | Documentació tècnica (guia de programador) \+ guia d'usuari |  |  |  |  |  |  |  |  |  | ▮ |  |
| **B30** | Preparació i assaig de la presentació final \+ demo en producció |  |  |  |  |  |  |  |  |  | ▮ |  |
| — | **Presentació final del projecte** |  |  |  |  |  |  |  |  |  |  | **PRES** |

