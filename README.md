# JARS: Emotion Recognition For A More Supportive Digital Experience

## Introduction
JARS is an intelligent mobile application designed to provide real-time, personalized emotional support. By using natural language processing and sentiment analysis, it tracks users’ emotions through short text entries and delivers relevant, empathetic content based on their mood. 

## Problem Statement
- Current systems cannot respond to users’ emotions in real-time.
- They cannot adapt to different situations or personalize responses.
- Teenagers on social media often do not get enough supportive interactions.

## Objectives
- To develop a system that can recognize users’ emotions in real-time.
- To provide personalized and context-aware responses tailored to different situations.
- To offer supportive interactions for teenagers on social media, promoting positive and empathetic engagement.

## Outcome on Usability
| Page | Description | Preview |
|------|------------|---------|
| Home | Overview of today’s mood and quick access to main features | <img width="156" height="320" alt="Image" src="https://github.com/user-attachments/assets/eb2e86cc-3bae-425d-bdb5-c3c353a0765b" /> <img width="156" height="320" alt="Image" src="https://github.com/user-attachments/assets/fda00bee-8e8e-4b5d-92d3-207295b533d8" />|
| Journal | Write diary entries, analyze emotions, and save daily journals | <img width="156" height="320" alt="Image" src="https://github.com/user-attachments/assets/1867a46e-743f-4114-921c-e28ea942729d" /> <img width="156" height="320" alt="Image" src="https://github.com/user-attachments/assets/199eff51-b74c-4c19-b958-c5cad265c616" /> <img width="156" height="320" alt="Image" src="https://github.com/user-attachments/assets/9e32ea16-4ce6-481d-b5b5-d042fff97574" /> |
| Explore | Mood-based music, videos, and personalized feed | <img width="156" height="320" alt="Image" src="https://github.com/user-attachments/assets/32335999-5ea5-4c63-ae4f-5de8972e1705" /> <img width="156" height="320" alt="Image" src="https://github.com/user-attachments/assets/0144897a-f670-4bf3-925e-f8b444f868c2" /> <img width="156" height="320" alt="Image" src="https://github.com/user-attachments/assets/25b2d341-4c5a-4509-8fb6-b0f9a342bdb9" /> |
| Calendar | Track moods and emotions over time | <img width="156" height="320" alt="Image" src="https://github.com/user-attachments/assets/a4aea61e-5343-46d3-9592-192e4d8cf4a1" /> <img width="156" height="320" alt="Image" src="https://github.com/user-attachments/assets/b98990f7-8f2a-4fd6-b20f-e3de7ca5dd47" /> |
| EmoSupport (AI) | AI-powered emotional support companion | <img width="156" height="320" alt="Image" src="https://github.com/user-attachments/assets/815b3475-6b09-445d-8ac0-a89e0bb2b2fa" /> |

## System Architecture & Workflow

JARS is built using a **three-layer architecture** to separate model training, backend services, and the mobile app. This ensures **real-time emotion detection**, scalability, and maintainable code.

| Layer | Description | Details / Preview |
|-------|------------|-----------------|
| **Model Training (Offline – One Time)** | The emotion classification model is trained during development using a labelled dataset. | - Dataset: ~756 text samples<br>- Model: `xlm-roberta-base` fine-tuned for emotion detection<br>- Output: trained model weights, tokenizer, label mappings<br>- Training happens **once**, not in the app |
| **Emotion Detection API (Backend Service)** | The trained model is deployed as a REST API using FastAPI. | - Endpoint: `/predict` accepts user text<br>- Returns detected emotion + confidence score<br>- Example Response:<br>```json { "emotion": "sad", "confidence": 0.8191 }```<br>- Keeps the app lightweight and allows model updates without changing the frontend |
| **Flutter Mobile App (Frontend)** | The user-facing app interacts with the API for real-time emotion detection. | - Users write journal entries<br>- Text is sent to the API<br>- API returns emotion label<br>- App updates UI: emoji, color, mood indicators, supportive content<br>- Entries saved locally using Hive |

## Impact & Contribution on Society
- JARS helps people, especially teenagers, understand and manage their emotions. 
- It encourages positive online communication.
- Supports mental well-being through empathetic responses and mood tracking.

## Conclusion & Future Work
JARS shows that technology can recognize emotions and respond supportively. It provides a helpful and engaging experience that promotes emotional awareness and better digital interactions. Future plans include adding voice and facial emotion detection and improving accuracy.




