import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../widgets/content/page_viewer.dart';
import '../../colorscheme.dart';

class ContentDemoScreen extends StatefulWidget {
  const ContentDemoScreen({Key? key}) : super(key: key);

  @override
  State<ContentDemoScreen> createState() => _ContentDemoScreenState();
}

class _ContentDemoScreenState extends State<ContentDemoScreen> {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://localhost:8000',
  ));

  bool _isLoading = false;

  // Sample data for testing (you can remove this once backend is working)
  final Map<String, dynamic> _sampleStory = {
    "title": "The Smart Shopper",
    "subtitle": "Learn about budgeting while shopping",
    "emoji": "🛒",
    "pages": [
      {
        "id": "page_1",
        "title": "The Shopping Trip",
        "content": """
# The Shopping Trip Begins! 🛒

You're at the mall with your friends, and you have **\$50** in your pocket. You want to buy some new clothes for the school dance next week.

As you walk into your favorite store, you see:
- A cool jacket for **\$45**
- A nice shirt for **\$25** 
- Some jeans for **\$35**

*What do you do?*
        """,
        "choices": [
          {
            "text": "Buy the jacket - it's so cool!",
            "next_page": "page_2a",
            "consequence": "You spend most of your money on one item"
          },
          {
            "text": "Buy the shirt and save the rest",
            "next_page": "page_2b", 
            "consequence": "You make a smart choice and save money"
          }
        ]
      },
      {
        "id": "page_2a",
        "title": "The Jacket Choice",
        "content": """
## You bought the jacket! 🧥

You spent **\$45** on the jacket, leaving you with only **\$5**. 

**The consequence:** You can't afford anything else, and you might need money for food or other expenses later.

*What do you learn from this?*
        """,
        "choices": [
          {
            "text": "Continue to learn more",
            "next_page": "page_3a"
          }
        ]
      },
      {
        "id": "page_2b",
        "title": "The Smart Choice",
        "content": """
## Great decision! 👍

You bought the shirt for **\$25** and saved **\$25**. This means you still have money for:
- Food and drinks
- Other small purchases
- Saving for future needs

**The lesson:** Always think about your total budget before making big purchases!
        """,
        "choices": [
          {
            "text": "Continue to learn more",
            "next_page": "page_3b"
          }
        ]
      },
      {
        "id": "page_3a",
        "title": "Learning from Mistakes",
        "content": """
## What You Learned 📚

Even though the jacket was cool, spending almost all your money on one thing wasn't the best choice. 

**Key Takeaways:**
- Always leave some money for unexpected expenses
- Consider if you really need something before buying it
- It's okay to save money for later

**Next time:** Try to spend only 50-70% of your budget on wants, and save the rest!
        """,
        "choices": [
          {
            "text": "Finish the story",
            "next_page": "page_end"
          }
        ]
      },
      {
        "id": "page_3b",
        "title": "Smart Shopping Success!",
        "content": """
## You're a Smart Shopper! 🎉

You made excellent financial decisions:
- ✅ You stayed within your budget
- ✅ You saved money for other needs
- ✅ You thought about the future

**Remember:** Good financial habits start with small choices like this one. Keep it up!
        """,
        "choices": [
          {
            "text": "Finish the story",
            "next_page": "page_end"
          }
        ]
      },
      {
        "id": "page_end",
        "title": "Story Complete! 🎊",
        "content": """
# Congratulations!

You've completed "The Smart Shopper" story and learned about:
- **Budgeting** - Planning how to spend your money
- **Prioritizing** - Choosing what's most important
- **Saving** - Keeping money for future needs

**Your choices matter!** Every financial decision you make helps you build better money habits.
        """,
        "choices": []
      }
    ],
    "topics": ["budgeting", "smart shopping"],
    "estimated_read_time": 5
  };

  final Map<String, dynamic> _sampleLesson = {
    "title": "Understanding Budgeting",
    "subtitle": "Learn the basics of creating and sticking to a budget",
    "emoji": "📊",
    "pages": [
      {
        "id": "intro",
        "title": "Welcome to Budgeting Basics!",
        "content": """
# Welcome to Budgeting Basics! 📊

In this lesson, you'll learn:
- What a budget is and why it's important
- How to create a simple budget
- Tips for sticking to your budget
- Common budgeting mistakes to avoid

**Estimated time:** 5-7 minutes

Let's get started!
        """,
        "type": "intro"
      },
      {
        "id": "page_1",
        "title": "What is a Budget?",
        "content": """
## What is a Budget? 💰

A **budget** is a plan for how you'll spend your money. Think of it like a roadmap for your finances!

**Key Points:**
- A budget helps you track income and expenses
- It prevents overspending
- It helps you save for goals
- It gives you control over your money

**Simple Formula:**
```
Income - Expenses = Savings (or Debt)
```

*The goal is to have money left over for savings!*
        """,
        "type": "content",
        "interactive_elements": [
          {
            "type": "quiz",
            "question": "What is the main purpose of a budget?",
            "options": [
              "To spend all your money quickly",
              "To plan how you'll use your money",
              "To avoid saving money",
              "To make you rich overnight"
            ],
            "correct": 1
          }
        ]
      },
      {
        "id": "page_2",
        "title": "Creating Your First Budget",
        "content": """
## Creating Your First Budget 📝

**Step 1: List Your Income**
- Allowance
- Part-time job
- Birthday money
- Any other money you receive

**Step 2: List Your Expenses**
- Food and snacks
- Entertainment (movies, games)
- Transportation
- Savings goals

**Step 3: Compare**
- If Income > Expenses = You're doing great!
- If Expenses > Income = You need to adjust

**Pro Tip:** Start with a simple 50/30/20 rule:
- 50% for needs
- 30% for wants  
- 20% for savings
        """,
        "type": "content"
      },
      {
        "id": "summary",
        "title": "Budgeting Summary",
        "content": """
# You've Completed Budgeting Basics! 🎉

**What You Learned:**
- ✅ What a budget is and why it matters
- ✅ How to create a simple budget
- ✅ The 50/30/20 rule for budgeting
- ✅ How to track income vs expenses

**Next Steps:**
1. Try creating your own budget
2. Track your spending for a week
3. Set a savings goal
4. Practice the 50/30/20 rule

**Remember:** Budgeting is a skill that gets easier with practice. Start small and build from there!
        """,
        "type": "summary"
      }
    ],
    "learning_objectives": [
      "Understand what a budget is",
      "Learn how to create a simple budget", 
      "Practice budgeting skills"
    ],
    "topics": ["budgeting", "financial planning"],
    "estimated_duration": 6
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Content Demo'),
        backgroundColor: AppColorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Choose Content Type',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            
            // Story Demo Button
            ElevatedButton.icon(
              onPressed: () => _showContent(_sampleStory, 'story'),
              icon: const Icon(Icons.book),
              label: const Text('Demo Interactive Story'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColorScheme.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Lesson Demo Button
            ElevatedButton.icon(
              onPressed: () => _showContent(_sampleLesson, 'lesson'),
              icon: const Icon(Icons.school),
              label: const Text('Demo Educational Lesson'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Generate from API Button
            const Text(
              'Generate New Content',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            
            ElevatedButton.icon(
              onPressed: _isLoading ? null : () => _generateContent('budgeting'),
              icon: _isLoading 
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.auto_awesome),
              label: Text(_isLoading ? 'Generating...' : 'Generate Story About Budgeting'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showContent(Map<String, dynamic> content, String contentType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PageViewer(
          pages: List<Map<String, dynamic>>.from(content['pages']),
          title: content['title'],
          emoji: content['emoji'],
          contentType: contentType,
        ),
      ),
    );
  }

  Future<void> _generateContent(String topic) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _dio.post(
        '/stories/generate',
        data: {'topic': topic, 'content_type': 'story'},
      );
      
      if (response.statusCode == 200) {
        final storyData = response.data;
        _showContent(storyData, 'story');
      }
    } catch (e) {
      // Show error or fallback to sample data
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating content: $e'),
          backgroundColor: Colors.red,
        ),
      );
      // Fallback to sample data
      _showContent(_sampleStory, 'story');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
} 