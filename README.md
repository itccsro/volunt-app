[![Travis build](https://travis-ci.org/civictechro/volunt-app.svg?branch=master)](https://travis-ci.org/civictechro/volunt-app)
[![Code Climate](https://codeclimate.com/github/civictechro/volunt-app/badges/gpa.svg)](https://codeclimate.com/github/civictechro/volunt-app)

# Gestiunea membrilor și proiectelor CivicTech
Un sistem de gestiune a membrilor și proiectelor CivicTech disponibil la https://membri.civictech.ro/

Când aplicația este folosită de un coordinator:
- Înregistrarea membrilor, completarea de profil (locație, contact, skills, tags)
- Căutare membrii după locație, skills, taguri
- Înregistrarea proiectelor CivicTech
- Managementul alocării de membrii per proiect, încarcare etc
- Înregistrarea progresului pe proiecte, integrare cu GitHub
- Poziții disponibile în proiect (openings, jobs)
- Mass mailing pentru comunitate, contributori la proiecte

Când aplicația este folosită de un membru:
- Signup, aplicare
- Editare profil personal
- Acces listă de proiecte, informații publice în proiect
- Acces listă de poziții, căutare după skills/attribute
- Aplicare la poziții (disponibilitate de a lucra la un proiect)

## Install

Applicația se conectează la o baza de date PostgreSQL.

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
