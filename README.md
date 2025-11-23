# NiaBot — Conversations That Care

NiaBot is an **AI-powered conversational assistant** designed to help users recognize early signs of **Gender-Based Violence (GBV)** through emotionally aware dialogue and educational guidance.  
The system integrates **Twitter sentiment analysis**, **machine learning**, and a **support-focused chatbot** to empower women and communities with early awareness and self-guided protective strategies.

---

## Overview

**NiaBot** serves as a safe digital companion that:

- Listens empathetically  
- Provides GBV-awareness guidance  
- Helps users reflect quietly without pressure  
- Encourages practical, self-guided protective actions  
- Escalates to resources only when absolutely needed  

It combines:

- **SwiftUI iOS App**  
- **Flask / FastAPI backend**  
- **Sentiment analysis (mBERT)**  
- **Conversational model (Phi-3-mini)**  
- **Core Data** for persistent chat storage  

---

## Key Features

| Feature | Description |
|--------|-------------|
| **Auth Module** | Signup, Login, OTP verification (SwiftUI + MVVM). |
| **NiaBot Chat** | AI-powered empathetic chat interface. |
| **Saved Chats** | Local CRUD with Core Data. |
| **mBERT Sentiment Model** | Classifies GBV-related Twitter text into emotional categories. |
| **Phi Conversational Model** | Generates emotionally sensitive and supportive chatbot responses. |
| **Location-Based Resources** | Safe center recommendations. |
| **Modern UI/UX** | Clean layout, sidebar, custom message bubbles. |

---

## Project Structure

```
NiaBot/
├── NiaBotApp.swift
├── Models/
│   ├── Message.swift
│   ├── ChatSession.swift
│   └── User.swift
├── ViewModels/
│   ├── AuthViewModel.swift
│   ├── ChatViewModel.swift
│   ├── SessionViewModel.swift
│   └── ProfileViewModel.swift
├── Views/
│   ├── Auth/
│   │   ├── LoginView.swift
│   │   ├── SignupView.swift
│   │   └── OTPVerificationView.swift
│   ├── Chat/
│   │   ├── ChatbotView.swift
│   │   ├── SavedChatsView.swift
│   │   └── MessageRow.swift
│   ├── Profile/
│   │   └── ProfileView.swift
│   └── Shared/
│       ├── SidebarView.swift
│       └── LoadingIndicator.swift
├── Services/
│   ├── AIService.swift
│   ├── APIClient.swift
│   └── CoreDataManager.swift
├── CoreData/
│   ├── NiaBot.xcdatamodeld
│   └── Persistence.swift
└── Resources/
    ├── Assets.xcassets
    └── AppIcon.appiconset
```

---

## System Architecture

- **Frontend:** SwiftUI (MVVM)  
- **Backend:** Flask / FastAPI  
- **Sentiment Model:** mBERT (fine-tuned)  
- **Chat Model:** Phi-3-mini-4k-instruct (fine-tuned LoRA)  
- **Database:** Core Data  
- **Networking:** URLSession + async/await  

---

## Dataset & Model Training

### Twitter GBV Dataset
NiaBot uses a curated dataset of GBV-related tweets (2020–2024), annotated into:

- `sexual_violence`  
- `Physical_violence`  
- `emotional_violence`  
- `Harmful_Traditional_practice`  
- `economic_violence`    

---

## Preprocessing  
Twitter text preprocessing included:

- Lowercasing  
- Removing URLs/mentions  
- Emoji → text mapping  
- Violence-related keyword tagging  
- Tokenization (WordPiece for mBERT)  

---

# Model Training

NiaBot uses **two ML models**:

---

# **1. mBERT — Sentiment Classification Model**

**Base Model:** `bert-base-multilingual-cased`  
**Purpose:** Classify tweets into multiple GBV categories.

###  Training Configuration
- Learning Rate: **3e-5**  
- Batch Size: **16**  
- Epochs: **3**  
- Optimizer: **AdamW**  
- Max Sequence Length: **128**  

#### Per-Label Evaluation Metrics

| Label | Precision | Recall | F1-score |
|-------|-----------|--------|----------|
| sexual_violence | 0.89 | 0.86 | 0.87 |
| Physical_violence | 0.87 | 0.84 | 0.85 |
| emotional_violence | 0.91 | 0.88 | 0.89 |
| Harmful_Traditional_practice | 0.86 | 0.80 | 0.83 |
| economic_violence | 0.90 | 0.82 | 0.86 |


### Insight
mBERT achieved high accuracy in distinguishing distress-oriented tweets, improving the contextual awareness of NiaBot responses.

---

# **2. Phi-3-mini-4k-instruct — NiaBot Conversational Model**

**Purpose:** Generate empathetic conversations and educational guidance.

###  Training Configuration
- Fine-tuning Method: **LoRA**  
- Learning Rate: **2e-4**  
- Batch Size: **2**  
- Epochs: **1**  
- Precision: **FP16**  
- Optimizer: **AdamW**  

### Dataset Format
```
### User: ...
### bot: ...
```

### Training & Validation Loss
- Training Loss: **1.31**  
- Validation Loss: **1.48**  

### Perplexity (PPL)
- **Perplexity: 1.78** *(lower = better)*

*This indicates Phi learned the communication patterns well, especially empathetic, non-judgmental responses.*

---

## Testing

### Unit Tests  
- ViewModels (Auth, Chat, Session)  
- API client parsing  
- Message encoding  

### Integration Tests  
- Chat + Core Data  
- Sentiment + Chatbot routing  

### UI Tests  
- Navigation flow  
- Sidebar behaviour  
- Chat scrolling performance  

Testing Tools:
- XCTest  
- Postman  
- Physical iPhone testing  

---

## Getting Started

### 1. Clone Repository  
```bash
git clone https://github.com/emilykkimani/IS-project
cd NiaBot
```

### 2. Open the Project  
```
open NiaBot.xcodeproj
```

### 3. Configure Backend Endpoint  
Inside `APIClient.swift`:

```swift
static let baseURL = "http://<your-backend-url>"
```

### 4. Run the App  
- Choose simulator  
- Press **Run**  

---

## Future Works Roadmap

- Offline Phi-3-mini model (on-device)  
- Multi-language support (mBERT already multilingual)  
- Expand GBV-risk awareness indicators  
- Emotion trajectory visualization  
- Integration with local GBV support networks  

---


