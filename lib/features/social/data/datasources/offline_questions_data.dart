class OfflineQuestionsData {
  static const Map<String, dynamic> data = {
    "questions": [
       // ==================== MATH (Simple: Basic, Medium: Algebra/Geometry, Hard: Calculus) ====================
       // --- English ---
       {
          "topic": "Math", "language": "English", "difficulty": "Simple", "question": "7 * 8 = ?",
          "options": ["54", "56", "58", "62"], "correctIndex": 1, "explanation": "Basic multiplication."
       },
       {
          "topic": "Math", "language": "English", "difficulty": "Simple", "question": "What is 15% of 200?",
          "options": ["25", "30", "35", "40"], "correctIndex": 1, "explanation": "10% is 20, 5% is 10. Total 30."
       },
       {
          "topic": "Math", "language": "English", "difficulty": "Medium", "question": "If 2x + 5 = 13, solve for x.",
          "options": ["2", "3", "4", "5"], "correctIndex": 2, "explanation": "2x = 8 => x = 4."
       },
       {
          "topic": "Math", "language": "English", "difficulty": "Medium", "question": "Area of a circle with radius 3?",
          "options": ["6π", "9π", "12π", "3π"], "correctIndex": 1, "explanation": "Area = πr² = π(3)² = 9π."
       },
       {
          "topic": "Math", "language": "English", "difficulty": "Hard", "question": "Derivative of x² with respect to x?",
          "options": ["x", "2x", "x²", "2"], "correctIndex": 1, "explanation": "Power rule: d/dx(x^n) = nx^(n-1)."
       },
       {
          "topic": "Math", "language": "English", "difficulty": "Hard", "question": "Integral of 2x dx?",
          "options": ["x² + C", "2x² + C", "x + C", "2 + C"], "correctIndex": 0, "explanation": "Reverse power rule."
       },

       // --- Bengali ---
       {
          "topic": "Math", "language": "Bengali", "difficulty": "Simple", "question": "৮ * ৯ = কত?",
          "options": ["৭২", "৬৪", "৮১", "৫৬"], "correctIndex": 0, "explanation": "৮ নামতা: ৮ নং ৭২।"
       },
       {
          "topic": "Math", "language": "Bengali", "difficulty": "Medium", "question": "একটি ত্রিভুজের ভূমি ১০ সেমি ও উচ্চতা ৫ সেমি। ক্ষেত্রফল কত?",
          "options": ["২৫ বর্গ সেমি", "৫০ বর্গ সেমি", "২০ বর্গ সেমি", "১০০ বর্গ সেমি"], "correctIndex": 0, "explanation": "ক্ষেত্রফল = ১/২ * ভূমি * উচ্চতা = ১/২ * ১০ * ৫ = ২৫।"
       },
       {
          "topic": "Math", "language": "Bengali", "difficulty": "Hard", "question": "f(x) = sin(x) হলে f'(x) কত?",
          "options": ["cos(x)", "-cos(x)", "sin(x)", "-sin(x)"], "correctIndex": 0, "explanation": "sin(x) এর অন্তরজ cos(x)।"
       },

       // ==================== PHYSICS ====================
       // --- English ---
       {
          "topic": "Physics", "language": "English", "difficulty": "Simple", "question": "Unit of current?",
          "options": ["Volt", "Ampere", "Ohm", "Watt"], "correctIndex": 1, "explanation": "Ampere is the SI unit of electric current."
       },
       {
          "topic": "Physics", "language": "English", "difficulty": "Medium", "question": "Kinetic Energy formula?",
          "options": ["mv", "mgh", "1/2 mv²", "ma"], "correctIndex": 2, "explanation": "KE = 0.5 * mass * velocity squared."
       },
       {
          "topic": "Physics", "language": "English", "difficulty": "Hard", "question": "Heisenberg Uncertainty Principle relates position and...?",
          "options": ["Energy", "Time", "Momentum", "Mass"], "correctIndex": 2, "explanation": "Impossible to know position and momentum precisely."
       },

       // --- Bengali ---
       {
          "topic": "Physics", "language": "Bengali", "difficulty": "Simple", "question": "শব্দের বেগ সবচেয়ে বেশি কোথায়?",
          "options": ["শূন্যে", "পানিতে", "লোহায়", "বাতাসে"], "correctIndex": 2, "explanation": "কঠিন পদার্থে শব্দের বেগ সবচেয়ে বেশি।"
       },
       {
          "topic": "Physics", "language": "Bengali", "difficulty": "Medium", "question": "ওহমের সূত্র কোনটি?",
          "options": ["V = IR", "P = VI", "F = ma", "E = mc²"], "correctIndex": 0, "explanation": "ভোল্টেজ = কারেন্ট * রোধ।"
       },
       {
          "topic": "Physics", "language": "Bengali", "difficulty": "Hard", "question": "Escape velocity (মুক্তিবেগ) of Earth?",
          "options": ["9.8 km/s", "11.2 km/s", "7.9 km/s", "3.0 km/s"], "correctIndex": 1, "explanation": "পৃথিবীর মুক্তিবেগ প্রায় ১১.২ কিমি/সেকেন্ড।"
       },

       // ==================== CHEMISTRY ====================
       // --- English ---
       {
          "topic": "Chemistry", "language": "English", "difficulty": "Simple", "question": "Symbol for Gold?",
          "options": ["Go", "Gd", "Au", "Ag"], "correctIndex": 2, "explanation": "Au comes from Latin 'Aurum'."
       },
       {
          "topic": "Chemistry", "language": "English", "difficulty": "Medium", "question": "pH of pure water at 25°C?",
          "options": ["0", "7", "14", "1"], "correctIndex": 1, "explanation": "Scale is 0-14, 7 is neutral."
       },
       // --- Bengali ---
       {
          "topic": "Chemistry", "language": "Bengali", "difficulty": "Simple", "question": "খাবার লবণের সংকেত কি?",
          "options": ["NaCl", "KCl", "HCl", "NaOH"], "correctIndex": 0, "explanation": "সোডিয়াম ক্লোরাইড (NaCl)।"
       },
       {
          "topic": "Chemistry", "language": "Bengali", "difficulty": "Hard", "question": "বেনজিন চক্রে কয়টি কার্বন থাকে?",
          "options": ["৪", "৫", "৬", "৮"], "correctIndex": 2, "explanation": "বেনজিনের সংকেত C6H6।"
       },

       // ==================== BIOLOGY ====================
       // --- English ---
       {
          "topic": "Biology", "language": "English", "difficulty": "Simple", "question": "Largest organ in human body?",
          "options": ["Liver", "Brain", "Skin", "Heart"], "correctIndex": 2, "explanation": "Skin is the largest organ."
       },
        // --- Bengali ---
       {
          "topic": "Biology", "language": "Bengali", "difficulty": "Simple", "question": "মানুষের শরীরে মোট হাড় কয়টি?",
          "options": ["২০৬", "৩০৬", "২০৮", "২০০"], "correctIndex": 0, "explanation": "প্রাপ্তবয়স্ক মানুষের ২০৬টি হাড় থাকে।"
       },
       {
          "topic": "Biology", "language": "Bengali", "difficulty": "Medium", "question": "DNA এর পূর্ণরূপ কি?",
          "options": ["Deoxyribonucleic Acid", "Denitrogen Acid", "Dual Acid", "None"], "correctIndex": 0, "explanation": "বংশগতির ধারক ও বাহক।"
       },

       // ==================== ENGLISH ====================
       {
          "topic": "English", "language": "English", "difficulty": "Medium", "question": "Which is a Preposition?",
          "options": ["Run", "Beautiful", "In", "Table"], "correctIndex": 2, "explanation": "'In' shows relationship/position."
       },
       {
          "topic": "English", "language": "Bengali", "difficulty": "Medium", "question": "'Honesty is the best policy' - এখানে Honesty কোন Noun?",
          "options": ["Common", "Proper", "Abstract", "Collective"], "correctIndex": 2, "explanation": "সততা দেখা যায় না, অনুভব করা যায়। তাই Abstract।"
       },

       // ==================== BANGLA ====================
       {
          "topic": "Bangla", "language": "Bengali", "difficulty": "Simple", "question": "বাংলাদেশের জাতীয় কবি কে?",
          "options": ["রবীন্দ্রনাথ ঠাকুর", "কাজী নজরুল ইসলাম", "জীবনানন্দ দাশ", "জসীম উদ্দীন"], "correctIndex": 1, "explanation": "বিদ্রোহী কবি কাজী নজরুল ইসলাম।"
       },
       {
          "topic": "Bangla", "language": "Bengali", "difficulty": "Medium", "question": "'বিদ্রোহী' কবিতাটি কোন কাব্যের অন্তর্গত?",
          "options": ["অগ্নিবীণা", "বিষের বাঁশি", "দোলনচাঁপা", "সাম্যবাদী"], "correctIndex": 0, "explanation": "নজরুলের প্রথম কাব্যগ্রন্থ অগ্নিবীণা।"
       },
       {
          "topic": "Bangla", "language": "Bengali", "difficulty": "Hard", "question": "চর্যাপদ কে আবিষ্কার করেন?",
          "options": ["হরপ্রসাদ শাস্ত্রী", "ড. শহীদুল্লাহ", "সুনীতিকুমার", "রবীন্দ্রনাথ"], "correctIndex": 0, "explanation": "১৯০৭ সালে নেপালের রাজদরবার থেকে।"
       }
    ]
  };
}
