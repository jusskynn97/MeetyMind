# AI Meeting Assistant
> Multi-platform smart meeting assistant with speech-to-text, speaker diarization, and AI-powered Q&A features

## Introduction
AI Meeting Assistant helps you manage meetings, record audio, view real-time transcripts, and ask questions about meeting content using a RAG (Retrieval-Augmented Generation) chatbot.

## Key Features
- 📱 **Cross-platform mobile app** (iOS/Android) built with Flutter
- 🔐 **Secure JWT authentication**
- 📅 **Meeting management** (create, view, edit, delete)
- 🎤 **Audio recording & upload** (supports files up to 100MB)
- 🗣️ **Speech-to-Text** with OpenAI Whisper (high accuracy for Vietnamese)
- 👥 **Speaker Diarization** with WhisperX (speaker identification)
- 🤖 **RAG Chatbot** for meeting content Q&A with LangChain + ChromaDB
- ⚡ **Real-time communication** with WebSocket and RabbitMQ
- 📲 **Push notifications** with Firebase Cloud Messaging (FCM)
- ☁️ **Media file storage** with Cloudinary

## System Architecture
The project uses a **Microservices** architecture.

```mermaid
graph TD
    Flutter[Flutter App <br/> (iOS/Android)]
    Gateway[API Gateway <br/> Spring Cloud Gateway]
    Eureka[Discovery Server <br/> Eureka Server]
    UserService[User Service <br/> Spring Boot]
    MeetingService[Meeting Service <br/> Spring Boot]
    NotificationService[Notification Service <br/> Spring Boot]
    AIService[AI Service <br/> FastAPI]
    PostgreSQL[(PostgreSQL)]
    RabbitMQ{RabbitMQ}
    Chroma[(ChromaDB)]
    Cloudinary[(Cloudinary)]
    Firebase[(Firebase FCM)]

    Flutter --> Gateway
    Gateway --> Eureka
    Gateway --> UserService
    Gateway --> MeetingService
    Gateway --> NotificationService
    Gateway --> AIService

    UserService --> PostgreSQL
    MeetingService --> PostgreSQL
    NotificationService --> PostgreSQL

    MeetingService --> RabbitMQ
    RabbitMQ --> AIService

    AIService --> Chroma
    MeetingService --> Cloudinary
    NotificationService --> Firebase
```

### Backend Services List
| Service | Port | Description |
|---------|------|-------------|
| Discovery Server | 8761 | Eureka Server - Service Discovery |
| API Gateway | 8080 | Routing and load balancing |
| User Service | 8090 | User management and authentication |
| Meeting Service | 8091 | Meeting management, transcripts, audio files |
| Notification Service | 8092 | Notification management and WebSocket |
| AI Service | 8093 | Speech-to-Text, Speaker Diarization, RAG processing |

## Tech Stack

### 📱 Frontend
- **Framework:** Flutter 3.8.1, Dart
- **State Management:** flutter_bloc
- **Routing:** go_router
- **Networking:** Dio, http
- **Local Storage:** Hive, shared_preferences
- **Real-time:** stomp_dart_client
- **Notifications:** Firebase Messaging, flutter_local_notifications
- **Others:** Lottie, Rive, audioplayers, file_picker, table_calendar

### 🔧 Backend - Java Microservices
- **Core:** Java 17, Spring Boot 3.5.7 / 4.0.1
- **Spring Cloud:** Netflix Eureka, Spring Cloud Gateway
- **Data:** Spring Data JPA, PostgreSQL 18, Hypersistence Utils
- **Security:** Spring Security, JWT (JJWT)
- **Communication:** Spring Web, Spring WebSocket, Spring AMQP, OpenFeign
- **Mapping:** MapStruct
- **Utilities:** Lombok, Apache Commons IO, Jackson

### 🧠 Backend - AI Services
- **Web Framework:** FastAPI, Uvicorn
- **Speech Processing:** OpenAI Whisper, WhisperX
- **AI/ML:** LangChain, Hugging Face Transformers/Embeddings
- **Vector DB:** ChromaDB
- **Service Discovery:** py-eureka-client

### 💾 Database & Storage
- PostgreSQL 18
- ChromaDB
- Cloudinary
- pgAdmin

### 🚀 Infrastructure
- Docker, Docker Compose
- RabbitMQ

## Prerequisites
Before running the project, you need to install the following software:
- **Java:** JDK 17+
- **Flutter:** 3.8.1+
- **Python:** 3.10+
- **Docker:** 24.0+
- **Docker Compose:** 2.20+
- **Maven:** 3.8+
- **CUDA (optional, for AI acceleration):** 11.8+ (if using GPU)

## Installation & Getting Started

### 1. Clone the repository
```bash
git clone <your-repo-url>
cd "DACS4 - AI Meeting Assistant"
```

### 2. Start dependent services (Docker)
First, navigate to the `back-end` directory and run Docker Compose to spin up PostgreSQL, pgAdmin, and RabbitMQ:
```bash
cd back-end
# Create complete docker-compose.yml if needed (add RabbitMQ)
docker-compose up -d
```

**pgAdmin Access Information:**
- URL: `http://localhost:5050`
- Email: `admin@admin.com`
- Password: `123456`

**PostgreSQL Information:**
- Host: `localhost`
- Port: `5432`
- User: `admin`
- Password: `123456`

### 3. Run backend services (Spring Boot)
Run each service in the following order (using IDE or Maven):

1. **Discovery Server:**
   ```bash
   cd discovery_server
   mvn spring-boot:run
   ```

2. **API Gateway:**
   ```bash
   cd ../api_gateway
   mvn spring-boot:run
   ```

3. **User Service:**
   ```bash
   cd ../user_service
   mvn spring-boot:run
   ```

4. **Meeting Service:**
   ```bash
   cd ../meeting_service
   mvn spring-boot:run
   ```

5. **Notification Service:**
   ```bash
   cd ../notification_service
   mvn spring-boot:run
   ```

Check the Eureka Dashboard at `http://localhost:8761` to confirm all services have registered successfully.

### 4. Configure & Run AI Service
1. Navigate to the `back-end/ai_services/api` directory
2. Create a `.env` file with the following content (replace with your information):
   ```env
   # AI Configuration
   DEVICE=cpu  # Or cuda if using GPU
   MODEL_NAME=base  # tiny/base/small/medium/large
   HF_TOKEN=your-huggingface-token  # Create at https://huggingface.co/settings/tokens

   # Vector DB Configuration
   VECTOR_DB_PATH=./meeting_vectordb

   # LLM Configuration
   LLM_BASE_URL=http://localhost:11434/v1  # Or other OpenAI-compatible API
   LLM_MODEL_NAME=gemma2:9b
   LLM_API_KEY=your-llm-api-key

   # Eureka Configuration
   EUREKA_SERVER=http://localhost:8761/eureka
   ```
3. Create a virtual environment and install dependencies:
   ```bash
   python -m venv venv
   # Windows
   .\venv\Scripts\activate
   # Linux/Mac
   source venv/bin/activate

   pip install -r requirements.txt  # If requirements.txt exists; create it if not
   ```
4. Run the AI Service:
   ```bash
   python main.py
   ```

### 5. Run Flutter App
1. Navigate to the `front_end` directory
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app:
   ```bash
   flutter run
   ```

## Project Structure
```
DACS4 - AI Meeting Assistant/
├── back-end/
│   ├── ai_services/          # AI Service (FastAPI)
│   │   ├── api/
│   │   └── rag/
│   ├── api_gateway/          # API Gateway
│   ├── discovery_server/     # Eureka Discovery Server
│   ├── meeting_service/      # Meeting Service
│   ├── notification_service/ # Notification Service
│   ├── user_service/         # User Service
│   ├── uploads/              # Temporary file storage
│   └── docker-compose.yml    # Docker configuration
└── front_end/                # Flutter App
    ├── android/
    ├── ios/
    ├── lib/
    ├── assets/
    └── pubspec.yaml
```
