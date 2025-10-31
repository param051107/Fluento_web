// suggestion_database.dart
import 'dart:math';

List<Map<String, dynamic>> suggestionDatabase = [
  // --- 1–10 : Greetings & Intros ---
  {
    "keywords": ["hello", "hi", "hey", "good morning", "good evening", "good night"],
    "suggestions": [
      "Hey 👋 How are you?",
      "Hi! What’s up?",
      "Hello 😊 nice to hear from you!",
      "Good morning ☀️ how’s your day starting?",
      "Good night 🌙 sleep well!",
    ]
  },
  {
    "keywords": ["how are you", "how's it going", "how r u", "how do you do"],
    "suggestions": [
      "I’m good 😄 you?",
      "Doing great! What about you?",
      "All good here 👍 how about you?",
      "Feeling awesome today 😎 hope you are too!",
    ]
  },
  {
    "keywords": ["what's up", "sup", "how’s life"],
    "suggestions": [
      "Nothing much, just chilling 😄",
      "All good here, you?",
      "Same old routine 😅",
      "Busy but good!",
    ]
  },
  {
    "keywords": ["nice to meet", "pleasure"],
    "suggestions": [
      "Nice to meet you too 😊",
      "Pleasure’s mine!",
      "Glad we connected!",
      "Happy to know you!",
    ]
  },
  {
    "keywords": ["where are you", "location", "place"],
    "suggestions": [
      "At home 🏠",
      "Just outside for a bit.",
      "In class right now.",
      "On my way somewhere 🚗",
    ]
  },
  {
    "keywords": ["free", "tomorrow", "meet", "coffee", "plan"],
    "suggestions": [
      "Sure ☕ let's meet tomorrow!",
      "I’m free — what time suits you?",
      "Sounds good, where should we meet?",
      "Let’s plan something fun 😄",
    ]
  },
  {
    "keywords": ["good", "awesome", "nice", "great"],
    "suggestions": [
      "Glad to hear that 😄",
      "That’s awesome!",
      "Happy for you 🎉",
      "Nice 👍 keep it up!",
    ]
  },
  {
    "keywords": ["bad", "sad", "upset", "tired", "bored"],
    "suggestions": [
      "Oh no 😢 want to talk about it?",
      "Take some rest 💤",
      "Cheer up 💪 better days are coming!",
      "Let’s do something fun to lift your mood 😊",
    ]
  },
  {
    "keywords": ["thanks", "thank you", "thx", "thanku"],
    "suggestions": [
      "You’re welcome 😊",
      "No problem!",
      "Glad I could help 😇",
      "Anytime 👍",
    ]
  },
  {
    "keywords": ["bye", "goodbye", "see you", "later", "take care"],
    "suggestions": [
      "See you soon 👋",
      "Bye! Take care 💫",
      "Catch you later!",
      "Talk soon 👋",
    ]
  },

  // --- 11–20 : Food & Drinks ---
  {
    "keywords": ["hungry", "food", "eat", "lunch", "dinner", "breakfast"],
    "suggestions": [
      "Haha same 🍕 what do you want to eat?",
      "Let’s grab something tasty 😋",
      "Yum! What’s on your menu?",
      "I’m thinking of ordering something 😄",
    ]
  },
  {
    "keywords": ["restaurant", "hotel", "cafe"],
    "suggestions": [
      "Let’s try that new cafe ☕",
      "Heard it’s good there!",
      "Want me to book a table?",
      "Sounds delicious 😋",
    ]
  },
  {
    "keywords": ["water", "juice", "coffee", "tea"],
    "suggestions": [
      "I’ll grab some coffee ☕",
      "Need a tea break 🍵",
      "Stay hydrated 💧",
      "Let’s drink something cool 🧃",
    ]
  },
  {
    "keywords": ["cook", "cooking", "kitchen"],
    "suggestions": [
      "What are you cooking today?",
      "Smells good already 👨‍🍳",
      "I love homemade food!",
      "Save me a plate 😋",
    ]
  },
  {
    "keywords": ["diet", "healthy", "gym food"],
    "suggestions": [
      "Sticking to your diet? 💪",
      "Health first always!",
      "That’s great discipline 👏",
      "Keep it clean and green 🥗",
    ]
  },
  {
    "keywords": ["snack", "chips", "burger", "pizza"],
    "suggestions": [
      "Yum 😋 I want some too!",
      "Now I’m hungry 😭",
      "Good choice!",
      "Don’t forget my share 😆",
    ]
  },
  {
    "keywords": ["sweet", "dessert", "ice cream", "cake"],
    "suggestions": [
      "Omg delicious 🍰",
      "Save me a bite 😋",
      "I love sweets too!",
      "Perfect treat 😍",
    ]
  },
  {
    "keywords": ["fruits", "fruit"],
    "suggestions": [
      "Fruits are the best 🍎🍌",
      "Healthy choice 👍",
      "Which one’s your favorite?",
      "Love fresh fruit in the morning!",
    ]
  },
  {
    "keywords": ["restaurant bill", "order", "delivery"],
    "suggestions": [
      "Hope it arrives fast 🚚",
      "Tracking it now!",
      "Let’s split the bill 😅",
      "Waiting for my food too!",
    ]
  },
  {
    "keywords": ["break", "rest", "nap"],
    "suggestions": [
      "Take a small nap 😴",
      "Rest is important!",
      "Recharge yourself ⚡",
      "You’ll feel better after some rest.",
    ]
  },

  // --- 21–40 : Study / Work ---
  {
    "keywords": ["study", "exam", "class", "school", "college"],
    "suggestions": [
      "Good luck with your studies 📚",
      "Don’t stress too much — you got this 💪",
      "How’s your preparation going?",
      "Need any help with subjects?",
    ]
  },
  {
    "keywords": ["teacher", "sir", "madam", "assignment"],
    "suggestions": [
      "Submit it on time 😅",
      "Ask the teacher once more!",
      "Assignments never end 😂",
      "You’ll finish it soon!",
    ]
  },
  {
    "keywords": ["project", "deadline", "work"],
    "suggestions": [
      "Almost done with the project 💻",
      "Deadline stress 😩",
      "Let’s finish it together!",
      "We got this 🙌",
    ]
  },
  {
    "keywords": ["office", "job", "meeting"],
    "suggestions": [
      "Good luck for the meeting 🤝",
      "Office days again 😅",
      "Hope it goes well!",
      "Busy schedule huh?",
    ]
  },
  {
    "keywords": ["result", "marks", "grades"],
    "suggestions": [
      "How did you do?",
      "Don’t worry, you’ll do better next time!",
      "Congrats 🎉",
      "Proud of you!",
    ]
  },
  {
    "keywords": ["teacher", "lecture", "notes"],
    "suggestions": [
      "Send me your notes pls 🙏",
      "Lecture was long today 😂",
      "Let’s study together later!",
      "Did you understand today’s topic?",
    ]
  },
  {
    "keywords": ["bored", "free period", "nothing to do"],
    "suggestions": [
      "Wanna play something?",
      "Let’s chat 😄",
      "Time for a snack break?",
      "Scroll memes maybe 😂",
    ]
  },
  {
    "keywords": ["holiday", "vacation", "leave"],
    "suggestions": [
      "Where are you going?",
      "Enjoy your vacation 🏖️",
      "That sounds relaxing!",
      "Send pics from the trip 📸",
    ]
  },
  {
    "keywords": ["travel", "trip", "journey", "train", "flight"],
    "suggestions": [
      "Safe travels ✈️",
      "Enjoy your trip!",
      "Take lots of photos!",
      "Have fun and stay safe 😊",
    ]
  },
  {
    "keywords": ["weather", "rain", "hot", "cold", "sunny"],
    "suggestions": [
      "It’s so hot today 🔥",
      "Rainy mood ☔",
      "Perfect weather for coffee ☕",
      "Stay warm 🧣",
    ]
  },

  // --- 41–60 : Emotions / Relationships ---
  {
    "keywords": ["love", "miss", "heart", "crush"],
    "suggestions": [
      "Aww ❤️ that’s sweet!",
      "Haha cute 😍",
      "You’re in love huh 😉",
      "That’s adorable 🥰",
    ]
  },
  {
    "keywords": ["angry", "mad", "upset"],
    "suggestions": [
      "Calm down 😌",
      "Let’s talk it out.",
      "Don’t stay mad for long 😅",
      "Take a deep breath 🌬️",
    ]
  },
  {
    "keywords": ["happy", "joy", "excited"],
    "suggestions": [
      "Yay 🎉 that’s awesome!",
      "I’m happy for you!",
      "That’s great news!",
      "Keep smiling 😄",
    ]
  },
  {
    "keywords": ["cry", "tears", "sad"],
    "suggestions": [
      "Don’t cry 😢",
      "Everything will be okay 💖",
      "Sending you hugs 🤗",
      "You’re stronger than this 💪",
    ]
  },
  {
    "keywords": ["friend", "buddy", "bro", "sis"],
    "suggestions": [
      "You’re the best 💙",
      "Always there for you!",
      "Haha bro that’s funny 😂",
      "Thanks friend 🤝",
    ]
  },
  {
    "keywords": ["family", "mom", "dad", "parents"],
    "suggestions": [
      "Family time is the best ❤️",
      "Say hi to them from me!",
      "Enjoy with your family!",
      "That’s sweet 👨‍👩‍👧‍👦",
    ]
  },
  {
    "keywords": ["birthday", "bday", "anniversary"],
    "suggestions": [
      "Happy Birthday 🎉🎂",
      "Wish you an amazing year ahead!",
      "Enjoy your special day 🥳",
      "Many happy returns 🎈",
    ]
  },
  {
    "keywords": ["help", "support", "assist"],
    "suggestions": [
      "Sure, I’ll help you!",
      "Tell me what you need 😊",
      "I got you 👍",
      "No worries, I’ll handle it.",
    ]
  },
  {
    "keywords": ["problem", "issue", "error", "bug"],
    "suggestions": [
      "Let’s solve it together 🔧",
      "What exactly happened?",
      "Try restarting maybe?",
      "I’ll check it out.",
    ]
  },
  {
    "keywords": ["sorry", "apologize", "forgive"],
    "suggestions": [
      "It’s okay 😊",
      "No hard feelings!",
      "Forget it, all good 👍",
      "We’re cool ✌️",
    ]
  },

  // --- 61–80 : Entertainment / Daily life ---
  {
    "keywords": ["movie", "film", "watch", "series", "netflix"],
    "suggestions": [
      "Nice! Which one are you watching?",
      "I love that one 🎬",
      "Any recommendations?",
      "Let’s watch something together 🍿",
    ]
  },
  {
    "keywords": ["music", "song", "playlist"],
    "suggestions": [
      "What’s playing right now?",
      "Good taste 😍",
      "Send me that track!",
      "Love this song 🎶",
    ]
  },
  {
    "keywords": ["game", "gaming", "pubg", "valorant", "free fire"],
    "suggestions": [
      "Let’s play later 🎮",
      "Nice headshot 😂",
      "GG bro!",
      "I’m in for a match!",
    ]
  },
  {
    "keywords": ["meme", "funny", "joke", "laugh"],
    "suggestions": [
      "Haha 😂 good one!",
      "That made me laugh!",
      "You’re so funny 😆",
      "Tell me another one!",
    ]
  },
  {
    "keywords": ["photo", "pic", "selfie"],
    "suggestions": [
      "Nice picture 📸",
      "Looking great 😍",
      "Cool vibe 😎",
      "Love that click!",
    ]
  },
  {
    "keywords": ["travel", "trip", "vacation"],
    "suggestions": [
      "Where are you heading?",
      "Take me with you 😂",
      "Have fun 🏖️",
      "Don’t forget souvenirs!",
    ]
  },
  {
    "keywords": ["sports", "match", "cricket", "football"],
    "suggestions": [
      "Who won? 🏆",
      "That was a crazy match!",
      "Big fan here too 😍",
      "Let’s play sometime!",
    ]
  },
  {
    "keywords": ["weather", "rain", "cold", "sunny"],
    "suggestions": [
      "Perfect weather today ☀️",
      "It’s raining here ☔",
      "So cold 🥶",
      "Love this breeze 😌",
    ]
  },
  {
    "keywords": ["sleep", "dream", "tired"],
    "suggestions": [
      "Sleep well 😴",
      "Sweet dreams 🌙",
      "Rest up!",
      "Don’t stay up too late!",
    ]
  },
  {
    "keywords": ["morning", "evening", "night"],
    "suggestions": [
      "Good morning ☀️",
      "Good evening 🌆",
      "Good night 🌙",
      "Hope you had a nice day!",
    ]
  },

  // --- 81–100 : Random daily & motivation ---
  {
    "keywords": ["busy", "workload"],
    "suggestions": [
      "Take short breaks 💪",
      "Stay focused!",
      "You’ll finish it soon!",
      "Don’t overwork yourself!",
    ]
  },
  {
    "keywords": ["motivation", "focus", "goal"],
    "suggestions": [
      "Keep going 💪",
      "You can do it!",
      "Don’t give up 🙌",
      "Stay positive!",
    ]
  },
  {
    "keywords": ["health", "sick", "medicine"],
    "suggestions": [
      "Take care 🩺",
      "Get well soon 🤒",
      "Drink plenty of water!",
      "Rest and recover ❤️",
    ]
  },
  {
    "keywords": ["pet", "dog", "cat"],
    "suggestions": [
      "Aww 🐾 so cute!",
      "Pets make life better ❤️",
      "What’s their name?",
      "Give them a hug from me 😍",
    ]
  },
  {
    "keywords": ["festival", "holiday", "celebration"],
    "suggestions": [
      "Happy festival 🎉",
      "Enjoy the celebrations!",
      "Best wishes to you and family!",
      "Festive vibes 😄",
    ]
  },
  {
    "keywords": ["shopping", "mall", "clothes"],
    "suggestions": [
      "What did you buy? 🛍️",
      "Take me next time 😂",
      "Sounds fun!",
      "Show me your haul!",
    ]
  },
  {
    "keywords": ["money", "salary", "budget"],
    "suggestions": [
      "Same here 😅 broke again!",
      "Let’s save next month 😂",
      "Budgeting is hard!",
      "Hope payday comes soon 💸",
    ]
  },
  {
    "keywords": ["news", "update", "information"],
    "suggestions": [
      "Thanks for the update!",
      "Didn’t know that!",
      "Interesting news 📰",
      "Appreciate it 👍",
    ]
  },
  {
    "keywords": ["internet", "wifi", "network"],
    "suggestions": [
      "My wifi’s slow too 😭",
      "Connection issues again!",
      "Lol classic network fail 😅",
      "Try reconnecting 🔄",
    ]
  },
  {
    "keywords": ["time", "clock", "late", "early"],
    "suggestions": [
      "Time flies ⏰",
      "Running late again 😂",
      "Early bird today 🐦",
      "Better hurry up!",
    ]
  },
];
