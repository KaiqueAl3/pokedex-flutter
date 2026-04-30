<div align="center">

# 🔴 Pokédex Flutter

> Aplicativo Flutter completo que consome a PokéAPI e integra com Firebase para persistência de favoritos em tempo real.

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Firestore-FFCA28?logo=firebase)](https://firebase.google.com)
[![PokéAPI](https://img.shields.io/badge/API-PokéAPI-EF5350)](https://pokeapi.co)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)

</div>

---

## 📱 Prints da Aplicação

HOME
<img width="773" height="1280" alt="01_home" src="https://github.com/user-attachments/assets/bfe4f18e-55af-428c-bad1-f0da5852ba40" />

DETALHES
<img width="784" height="1280" alt="02_detail" src="https://github.com/user-attachments/assets/af7084ac-661c-40f4-b012-f91aa36c41d0" />

FAVORITOS
<img width="775" height="1280" alt="03_favorites" src="https://github.com/user-attachments/assets/75b49c5b-d2ef-4c20-af36-7c3362ead7ea" />

FILTRO
<img width="770" height="1280" alt="04_filter" src="https://github.com/user-attachments/assets/2f8187a5-f268-4080-8e23-71f9e179699e" />




## 📐 Arquitetura da Aplicação

```
┌─────────────────────────────────────────────────────────┐
│                    POKÉDEX FLUTTER                       │
│                                                         │
│  ┌──────────────────────────────────────────────────┐  │
│  │                  PRESENTATION LAYER               │  │
│  │  ┌────────────┐  ┌────────────┐  ┌────────────┐  │  │
│  │  │ HomeScreen │  │DetailScreen│  │ Favorites  │  │  │
│  │  │  - Grid    │  │  - Stats   │  │  Screen    │  │  │
│  │  │  - Search  │  │  - Shiny   │  │  - Stream  │  │  │
│  │  │  - Filter  │  │  - Types   │  │  - CRUD    │  │  │
│  │  └─────┬──────┘  └─────┬──────┘  └─────┬──────┘  │  │
│  └────────┼───────────────┼───────────────┼──────────┘  │
│           │               │               │              │
│  ┌────────▼───────────────▼───────────────▼──────────┐  │
│  │              STATE MANAGEMENT LAYER                │  │
│  │                  PokemonProvider                   │  │
│  │         (ChangeNotifier + Provider package)        │  │
│  │  - pokemonList  - selectedPokemon  - favoriteIds   │  │
│  │  - searchQuery  - selectedType     - loadingState  │  │
│  └────────┬─────────────────────────┬─────────────────┘  │
│           │                         │                     │
│  ┌────────▼──────────┐   ┌──────────▼──────────────┐    │
│  │   SERVICE LAYER   │   │      SERVICE LAYER       │    │
│  │  PokeApiService   │   │    FirebaseService        │    │
│  │  ───────────────  │   │  ─────────────────────── │    │
│  │  fetchPokemonList │   │  favoritesStream()         │    │
│  │  fetchPokemon     │   │  toggleFavorite()          │    │
│  │  Detail()         │   │  saveRecentlyViewed()      │    │
│  │  searchPokemon()  │   │  logPokemonViewed()        │    │
│  │  fetchTypes()     │   │  (Firebase Analytics)      │    │
│  └────────┬──────────┘   └──────────┬─────────────────┘  │
│           │                         │                      │
│  ┌────────▼──────────┐   ┌──────────▼──────────────┐    │
│  │   EXTERNAL APIs   │   │   FIREBASE SERVICES      │    │
│  │  PokeAPI v2       │   │  Cloud Firestore          │    │
│  │  pokeapi.co/v2    │   │  Firebase Analytics       │    │
│  └───────────────────┘   └──────────────────────────┘    │
└─────────────────────────────────────────────────────────-─┘
```

### Fluxo de Dados

```
User Input → Widget → Provider → Service → API/Firebase
                    ↑                    ↓
              notifyListeners()      dados retornam
                    ↑                    ↓
              Widget rebuild  ←  setState / Stream
```

---

## 🚀 Funcionalidades

| Feature | Descrição | Pontuação |
|---------|-----------|-----------|
| 📋 **Lista paginada** | Grid com 1025+ Pokémon, carregamento infinito | API |
| 🔍 **Busca** | Busca por nome ou número (#001) | API |
| 🎨 **Filtro por tipo** | 18 tipos: Fire, Water, Grass... | API |
| 📄 **Detalhe completo** | Stats, habilidades, descrição, altura, peso | API |
| ✨ **Versão Shiny** | Toggle para ver sprite shiny de cada Pokémon | API |
| ⭐ **Favoritos** | Salvar/remover favoritos persistidos no Firebase | Firebase |
| 🔄 **Sync em tempo real** | StreamBuilder com Firestore (atualização automática) | Firebase |
| 📊 **Analytics** | Eventos de navegação e interação via Firebase Analytics | Firebase |
| 🕒 **Vistos recentemente** | Histórico salvo no Firestore | Firebase |
| 🌙 **Dark Theme** | UI escura com cores por tipo de Pokémon | UI |
| 🎭 **Animações** | Hero transitions, stat bars animadas, shimmer loading | UI |

---

## 🛠️ Tecnologias Utilizadas

### Core
- **Flutter 3.x** — Framework cross-platform
- **Dart 3.x** — Linguagem de programação
- **Provider 6.x** — Gerenciamento de estado (ChangeNotifier)

### APIs & Backend
- **[PokéAPI v2](https://pokeapi.co/)** — REST API gratuita com dados de todos os Pokémon
- **Firebase Cloud Firestore** — Banco de dados NoSQL em tempo real (favoritos)
- **Firebase Analytics** — Rastreamento de eventos do usuário

### Pacotes Flutter
| Pacote | Uso |
|--------|-----|
| `http` | Requisições HTTP para a PokéAPI |
| `firebase_core` | Inicialização do Firebase |
| `cloud_firestore` | Banco de dados de favoritos |
| `firebase_analytics` | Analytics de uso |
| `provider` | Gerenciamento de estado |
| `cached_network_image` | Cache de imagens dos Pokémon |
| `shimmer` | Loading skeleton animation |
| `flutter_staggered_animations` | Animações na grid |
| `google_fonts` | Tipografia (Nunito) |
| `palette_generator` | Cores dinâmicas por Pokémon |

---


## 📂 Estrutura do Projeto

```
pokedex_flutter/
├── lib/
│   ├── main.dart                   # Entry point, Firebase init, Provider setup
│   ├── firebase_options.dart       # Credenciais Firebase (gerado pelo flutterfire)
│   │
│   ├── models/
│   │   └── pokemon.dart            # Modelos de dados (Pokemon, PokemonStat, etc.)
│   │
│   ├── services/
│   │   ├── poke_api_service.dart   # Todas as chamadas à PokéAPI v2
│   │   └── firebase_service.dart   # Firestore CRUD + Analytics
│   │
│   ├── providers/
│   │   └── pokemon_provider.dart   # Estado global (ChangeNotifier)
│   │
│   ├── screens/
│   │   ├── home_screen.dart        # Lista paginada + busca + filtros
│   │   ├── detail_screen.dart      # Detalhes, stats, habilidades, shiny
│   │   └── favorites_screen.dart   # Favoritos em tempo real do Firestore
│   │
│   ├── widgets/
│   │   ├── pokemon_card.dart       # Card do Pokémon na grid
│   │   ├── type_chip.dart          # Chip colorido por tipo
│   │   └── stat_bar.dart           # Barra animada de estatística
│   │
│   └── theme/
│       └── app_theme.dart          # Tema dark + cores por tipo
│
├── screenshots/                    # Prints da aplicação
├── assets/images/                  # Assets locais
├── pubspec.yaml                    # Dependências
└── README.md
```

---

## 🌐 APK / Versão Web

> **Versão de demonstração:** [🔗 Acessar app web](#)  
> **Download APK:** [⬇️ app-release.apk](#)

> Para testar localmente, siga os passos de instalação acima e execute `flutter run -d chrome` para a versão web.

---

## 🗺️ Endpoints da PokéAPI utilizados

| Endpoint | Uso |
|----------|-----|
| `GET /pokemon?limit=20&offset=0` | Lista paginada |
| `GET /pokemon/{id}` | Detalhes do Pokémon |
| `GET /pokemon-species/{id}` | Descrição em texto |
| `GET /type` | Lista de tipos |
| `GET /type/{name}` | Pokémon por tipo |

---

## 🔥 Estrutura do Firebase (Firestore)

```
firestore/
├── favorites/
│   └── user_default/
│       └── pokemon/
│           ├── 6  (Charizard)
│           ├── 25 (Pikachu)
│           └── ...
└── recently_viewed/
    └── user_default/
        └── pokemon/
            ├── 143 (Snorlax)
            └── ...
```

---

## 👨‍💻 Autor
 
**Kaique Alencar Braga Silva** 

