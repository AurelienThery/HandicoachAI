# HandIaCoach 🧩

**Coach IA pour routines visuelles personnalisées** - Application Rails 7.1.6 MVP pour l'accompagnement du handicap (TSA, polyhandicap).

## 🎯 Fonctionnalités MVP

- ✅ **Chat temps réel** (ActionCable + Turbo Streams)
- ✅ **IA locale Ollama** (Mistral) OU API Mistral/OpenAI
- ✅ **Routines collaboratives** partagées famille ↔ pro
- ✅ **Auth Devise** (family/professional roles)
- ✅ **Freemium ready** (basic gratuit, pro 20€/mois)

## 🚀 Installation

### Prérequis

- Ruby 3.2+
- Rails 7.1.6
- Node.js 18+
- SQLite3

### Installation rapide

```bash
# Cloner le repo
git clone <repo-url>
cd HandicoachAI

# Installer les dépendances
bundle install
yarn install

# Créer la base de données
rails db:create db:migrate

# Lancer le serveur
bin/dev
```

### Configuration IA (optionnel)

L'application fonctionne avec un mock par défaut. Pour activer une vraie IA :

**Ollama (local) :**
```bash
# Installer Ollama
curl -fsSL https://ollama.com/install.sh | sh
ollama pull mistral

# Variables d'environnement
export OLLAMA_URL=http://localhost:11434
export OLLAMA_MODEL=mistral
```

**Mistral API :**
```bash
export MISTRAL_API_KEY=your_api_key
export MISTRAL_MODEL=mistral-small-latest
```

**OpenAI API :**
```bash
export OPENAI_API_KEY=your_api_key
export OPENAI_MODEL=gpt-3.5-turbo
```

## 📁 Structure du projet

```
app/
├── channels/         # ActionCable pour chat temps réel
├── controllers/      # Contrôleurs Rails
├── jobs/            # Jobs async pour réponses IA
├── models/          # User, Routine, ChatMessage
├── services/        # AiService (Ollama, Mistral, OpenAI)
└── views/           # Vues avec Bootstrap

config/
├── routes.rb        # Routes RESTful
└── importmap.rb     # JavaScript imports
```

## 👥 Rôles utilisateurs

- **Family** : Familles et aidants
- **Professional** : Éducateurs, psychologues, etc.

## 💰 Plans d'abonnement

| Fonctionnalité | Basic (Gratuit) | Pro (20€/mois) |
|----------------|-----------------|----------------|
| Routines | 3 max | Illimitées |
| Chat IA | Limité | Illimité |
| Partage | 1 personne | Illimité |
| Support | Standard | Prioritaire |

## 🧪 Tests

```bash
rails test
```

## 📄 Licence

MIT License - Projet MVP Lean Startup