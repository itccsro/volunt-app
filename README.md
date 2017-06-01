[![Travis build](https://travis-ci.org/civictechro/volunt-app.svg?branch=master)](https://travis-ci.org/civictechro/volunt-app)
[![Code Climate](https://codeclimate.com/github/civictechro/volunt-app/badges/gpa.svg)](https://codeclimate.com/github/civictechro/volunt-app)

# Gestiunea membrilor si proiectelor CivicTech
Un sistem de gestiune a membrilor si proiectelor CivicTech disponibil la https://membri.civictech.ro/

Cind aplicatia este folosita de un coordinator:
- Inregistrarea membrilor, completarea de profil (locatie, contact, skills, tags)
- Cautare membri dupa locatie, skils, taguri
- Inregistrarea proiectelor CivicTech
- Managementul alocarii de membri per proiect, incarcare etc
- Inregistrera progresului pe proiecte, integrare cu GitHub
- Pozitii disponibile in proiect (openings, jobs)
- Mass mailing pentru comunitate, contributori la proiecte

Cind aplicatia este folosita de un membru:
- Signup, aplicare
- Editare profil personal
- Acces lista de proiecte, informatii publice in proiect
- Acces lista de pozitii, cautare dupa skills/atribute
- Aplicare la pozitii (disponibilitate de a lucra la un proiect)

## Install

Applicatia se conecteaza la o baza de PostgreSQL.

```
psql
CREATE ROLE voluntapp;
ALTER ROLE voluntapp WITH LOGIN;
```

```
createdb voluntari_development --host=localhost --port=5432 --owner=voluntapp
createdb voluntari_test --host=localhost --port=5432 --owner=voluntapp
```

```
git clone https://github.com/gov-ithub/volunt-app.git
cd volunt-app
bundle install
cp config/.env.sample .env
rails db:setup
rails server
rspec # will run all tests in spec/
```

**Made with :heart: by [GovITHub](http://ithub.gov.ro)**
