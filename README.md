# Praise Me (夸夸我)

# [演示视频](https://www.bilibili.com/video/BV1LyPMeSEqj/)

## Introduction
The AI Praise Me app is designed to boost users' confidence and improve their mood, turning AI into a companion that always praises and encourages them.

## Core Features
- **AI Praise Modes**
  - **Direct Praise**: No input needed; AI generates compliments instantly.
  - **Prompted Praise**: Users enter their achievements, mood, or hobbies, and AI generates warm compliments.
  - **Voice Praise**: AI-generated compliments are converted into voice for a more immersive experience.
  - **Photo Praise**: Users upload a photo, and AI generates a compliment based on it.
  - **Styled Praise**: Users can select different compliment styles, such as playful, dominant, poetic, or classic.
  - **Praise Leaderboard**: Users can share AI-generated compliments with others to spread happiness.

Background & Motivation for Developing Praise Me App
Everyone needs to be praised—that's the reason I created Praise Me. In today’s world, people often face stress, anxiety, and self-doubt. A well-timed compliment can bring warmth and encouragement. With the power of AI, I want everyone to receive praise anytime, anywhere, boosting confidence, improving mood, and making AI your personal “praise companion.”

Introduction
Praise Me is an AI-powered praise app designed to uplift users, enhance self-confidence, and bring joy. Whether you want to hear words of encouragement or share compliments with others, this app is here to make it happen.

Core Value
Celebrity Praise 🎤✨
Get praised by famous personalities like Wang Yibo or Elon Musk. AI-generated voices can make the experience even more immersive.

Praise Others 💌
Share AI-generated compliments with friends, family, or colleagues, making praise a part of social interactions.

Praise Leaderboard 🏆
Turn praise into a fun and engaging experience, encouraging users to praise each other and compete for the top spot.

Monetization Model 💰
Integrate ads or premium features, such as personalized praise or custom voice options, to create a sustainable business model.

Conclusion
Praise Me is more than just an AI praise tool—it’s an app that spreads happiness. I hope it helps more people feel warmth and positivity, making praise a part of daily life and filling the world with encouragement and good vibes! 🚀💖

## UI Style
The frontend features a rotating compass design, where each section can be clicked to navigate to the corresponding page.  
Each praise mode result can be liked or shared with others (as a way of praising them).  
When a result is liked or shared, it is immediately stored in the database and assigned a unique link.

## Project Structure
- `backend`
- `frontend`

## Technical Overview
- Uses OpenAI API (GPT-4o-mini) to generate praise content.
- File uploads use the `multipart/form-data` format.
- The user system operates anonymously; users can enter a username when needed.
- Audio files are accessed via `/static/audio/`.
- Uploaded images are stored in `/static/uploads/`.

---

## Backend API

### Core Features - AI Praise Modes

#### 1. Direct Praise
- **Method**: `POST`
- **Endpoint**: `/direct-praise`
- **Parameters**: None
- **Response**:
  ```json
  {
    "text": "Randomly generated warm compliment"
  }
  ```
- **Description**: AI generates a random compliment without any input.

#### 2. Prompted Praise
- **Method**: `POST`
- **Endpoint**: `/hint-praise`
- **Form Parameters**:
  - `text` (required): User input for context.
  - `style` (optional, default: `normal`): Praise style `[normal, funny, poetic, zhonger, domineering]`
- **Response**:
  ```json
  {
    "text": "Stylized compliment based on user input"
  }
  ```
- **Example Request**:
  ```sh
  curl -X POST \
    -F "text=I learned to swim today" \
    -F "style=poetic" \
    http://api.example.com/hint-praise
  ```

#### 3. Photo Praise
- **Method**: `POST`
- **Endpoint**: `/photo-praise`
- **Form Parameters**:
  - `file` (required): Uploaded image file (`jpg/png` supported).
  - `style` (optional, default: `normal`): Praise style.
- **Response**:
  ```json
  {
    "text": "Compliment based on image analysis",
    "image_url": "/static/uploads/filename.jpg"
  }
  ```
- **Description**: Uploaded images are stored in `/static/uploads/`.

#### 4. Voice Praise
- **Method**: `POST`
- **Endpoint**: `/generate-voice`
- **Form Parameters**:
  - `text` (required): Text to convert to speech.
- **Response**: Returns an `audio/mpeg` file.
- **Example Usage**:
  ```html
  <audio controls>
    <source src="http://api.example.com/generate-voice" type="audio/mpeg">
  </audio>
  ```

---

## Community Interaction

#### 1. Complete a Challenge
- **Method**: `POST`
- **Endpoint**: `/challenge/complete`
- **Form Parameters**:
  - `user_id` (required): User ID.
  - `challenge_type` (required): Challenge type `[selfie, diary, share]`
- **Response**:
  ```json
  {
    "status": "success"
  }
  ```

#### 2. Praise Leaderboard
- **Method**: `GET`
- **Endpoint**: `/leaderboard`
- **Query Parameters**:
  - `period` (optional, default: `daily`): Time period `[daily, weekly, monthly]`
- **Response**:
  ```json
  {
    "leaderboard": [
      {
        "user_id": "uuid",
        "praise_count": 15
      },
      ...
    ]
  }
  ```

---

## Software Architecture
1. **Frontend (Web + App)**: Built with Flutter.
2. **Backend**: Developed using Python FastAPI.

---

## Installation Guide
1. Clone the project:  
   ```sh
   git clone https://gitee.com/johnsonguo/praise-me.git
   ```
2. Navigate to the project directory:  
   ```sh
   cd praise-me
   ```
3. Install dependencies:  
   - **Frontend**:  
     ```sh
     npm install
     ```
   - **Backend**:  
     ```sh
     pip install -r requirements.txt
     ```

---

## Usage Guide
1. Start the backend service:  
   ```sh
   uvicorn main:app --reload
   ```
2. Start the frontend application:  
   ```sh
   npm start
   ```
3. Open a browser and visit `http://localhost:3000` to start using the AI Praise Me app.

---

## Contribution
Contributions are welcome! Please submit a Pull Request or report issues.

---

## License
This project is licensed under the MIT License.
