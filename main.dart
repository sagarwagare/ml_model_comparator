import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

void main() {
  runApp(AIApp());
}

class AIApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AI Model Comparator & Tutorials',
      theme: ThemeData.dark(),
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    ModelComparatorScreen(),
    TutorialScreen(),
    ChatbotScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ML Model Comparator & Tutorials with Chatbot',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.black.withOpacity(0.8),
        elevation: 4,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          MovingBackground(),
          _pages[_selectedIndex],
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.black.withOpacity(0.7),
        selectedItemColor: Colors.cyanAccent,
        unselectedItemColor: Colors.white70,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.auto_graph), label: 'AI Comparator'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Tutorials'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chatbot'),
        ],
      ),
    );
  }
}

class MovingBackground extends StatefulWidget {
  @override
  _MovingBackgroundState createState() => _MovingBackgroundState();
}

class _MovingBackgroundState extends State<MovingBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 10),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.deepPurpleAccent.withOpacity(0.8 + 0.2 * _controller.value),
                Colors.blueAccent.withOpacity(0.8 + 0.2 * (1 - _controller.value)),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ModelComparatorScreen extends StatefulWidget {
  @override
  _ModelComparatorScreenState createState() => _ModelComparatorScreenState();
}

class _ModelComparatorScreenState extends State<ModelComparatorScreen> {
  String? selectedDataset;
  String? selectedAlgorithm1;
  String? selectedAlgorithm2;
  String bestAlgorithm = "";
  String explanation = "";
  String? mse1, mse2, mae1, mae2, r2_1, r2_2;
  bool isComparing = false;

  final String apiUrl = "http://your-backend-url.com/compare"; // Update this

  final Map<String, String> datasetInfo = {
    'Iris Dataset': "Classification of iris flowers into three species.",
    'California Housing': "Predicts median house values based on census data.",
    'Boston Housing': "Predicts house prices in Boston based on various factors.",
    'MNIST Digits': "Handwritten digits dataset for classification.",
    'CIFAR-10': "Image dataset for object classification into 10 categories.",
    'Wine Quality': "Predicts wine quality based on physicochemical tests.",
    'Diabetes': "Predicts diabetes progression based on medical data.",
    'Titanic': "Passenger survival data from the Titanic disaster."
  };

  Future<void> compareAlgorithms() async {
  if (selectedAlgorithm1 == null || selectedAlgorithm2 == null || selectedDataset == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Please select a dataset and two algorithms")),
    );
    return;
  }

  setState(() {
    isComparing = true;
  });

  try {
    final response = await http.post(
      Uri.parse("http://127.0.0.1:5000/compare"),  // Ensure the backend URL is correct
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "dataset": selectedDataset,
        "algorithm1": selectedAlgorithm1,
        "algorithm2": selectedAlgorithm2
      }),
    );

    print("API Response Status: ${response.statusCode}");
    print("API Response Body: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data.containsKey("metrics")) {
        setState(() {
          mse1 = data["metrics"]["MSE1"]?.toString() ?? "N/A";
          mse2 = data["metrics"]["MSE2"]?.toString() ?? "N/A";
          mae1 = data["metrics"]["MAE1"]?.toString() ?? "N/A";
          mae2 = data["metrics"]["MAE2"]?.toString() ?? "N/A";
          r2_1 = data["metrics"]["R2_1"]?.toString() ?? "N/A";
          r2_2 = data["metrics"]["R2_2"]?.toString() ?? "N/A";
          bestAlgorithm = data["best_algorithm"] ?? "Unknown";
          explanation = data["explanation"] ?? "No explanation provided.";
        });
      } else {
        throw Exception("Invalid response structure.");
      }
    } else {
      throw Exception("Error: ${response.statusCode}");
    }
  } catch (e) {
    print("Error: $e");
    setState(() {
      bestAlgorithm = "Error";
      explanation = "Failed to fetch data. Check API.";
      mse1 = mse2 = mae1 = mae2 = r2_1 = r2_2 = "null";
    });
  } finally {
    setState(() {
      isComparing = false;
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(16.0),
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Select Dataset:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              isExpanded: true,
              value: selectedDataset,
              hint: Text('Choose a dataset'),
              onChanged: (value) {
                setState(() { selectedDataset = value; });
              },
              items: datasetInfo.keys.map((dataset) {
                return DropdownMenuItem(value: dataset, child: Text(dataset));
              }).toList(),
            ),
            if (selectedDataset != null)
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Card(
                  color: Colors.white24,
                  child: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Text(datasetInfo[selectedDataset!] ?? ""),
                  ),
                ),
              ),
            Text('Select Algorithms:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              isExpanded: true,
              value: selectedAlgorithm1,
              hint: Text('Choose first algorithm'),
              onChanged: (value) {
                setState(() { selectedAlgorithm1 = value; });
              },
              items: ['Random Forest Regressor', 'Decision Tree', 'SVM', 'LightGBM', 'Gradient Boosting', 'AdaBoost', 'XGBoost', 'Linear Regression', 'Ridge Regression', 'Lasso Regression'].map((algo) {
                return DropdownMenuItem(value: algo, child: Text(algo));
              }).toList(),
            ),
            DropdownButton<String>(
              isExpanded: true,
              value: selectedAlgorithm2,
              hint: Text('Choose second algorithm'),
              onChanged: (value) {
                setState(() { selectedAlgorithm2 = value; });
              },
              items: ['Random Forest Regressor', 'Decision Tree', 'SVM', 'LightGBM', 'Gradient Boosting', 'AdaBoost', 'XGBoost', 'Linear Regression', 'Ridge Regression', 'Lasso Regression'].map((algo) {
                return DropdownMenuItem(value: algo, child: Text(algo));
              }).toList(),
            ),
            ElevatedButton(
              onPressed: compareAlgorithms,
              child: Text('Compare Algorithms'),
            ),
            if (isComparing) CircularProgressIndicator(),
            if (bestAlgorithm.isNotEmpty && !isComparing)
              Card(
                color: Colors.blue,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text('Best Algorithm:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                      Text(bestAlgorithm, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                      Text(explanation, style: TextStyle(color: Colors.white)),
                      SizedBox(height: 10),
                      Text("MSE: $mse1 vs $mse2", style: TextStyle(color: Colors.white)),
                      Text("MAE: $mae1 vs $mae2", style: TextStyle(color: Colors.white)),
                      Text("R²: $r2_1 vs $r2_2", style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}


class TutorialScreen extends StatefulWidget {
  @override
  _TutorialScreenState createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  List<dynamic> tutorials = [];
  bool isLoading = true;
  String errorMessage = "";

  @override
  void initState() {
    super.initState();
    fetchTutorials();
  }

  Future<void> fetchTutorials() async {
    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:5000/tutorials'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          tutorials = data['tutorials'];
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load tutorials.");
      }
    } catch (error) {
      setState(() {
        errorMessage = "Error fetching tutorials. Make sure the backend is running!";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.deepPurple.shade700,
              Colors.blue.shade400,
            ],
          ),
        ),
        child: Center(
          child: isLoading
              ? CircularProgressIndicator(color: Colors.white)
              : errorMessage.isNotEmpty
                  ? Text(errorMessage, style: TextStyle(color: Colors.red, fontSize: 16))
                  : SingleChildScrollView(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              "Tutorials",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.all(16.0),
                            itemCount: tutorials.length,
                            itemBuilder: (context, index) {
                              final tutorial = tutorials[index];
                              return Card(
                                color: Colors.black.withOpacity(0.7),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                margin: EdgeInsets.symmetric(vertical: 8),
                                child: ListTile(
                                  title: Text(
                                    tutorial['title'],
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  subtitle: Text(
                                    tutorial['description'],
                                    style: TextStyle(color: Colors.grey[300]),
                                  ),
                                  trailing: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      primary: Colors.blue.shade600,                                    ),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          backgroundColor: Colors.black.withOpacity(0.9),
                                          title: Text(
                                            tutorial['title'],
                                            style: TextStyle(color: Colors.white),
                                          ),
                                          content: Text(
                                            tutorial['content'],
                                            style: TextStyle(color: Colors.white70),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context),
                                              child: Text("Close", style: TextStyle(color: Colors.blue)),
                                            )
                                          ],
                                        ),
                                      );
                                    },
                                    child: Text("View"),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
        ),
      ),
    );
  }
}

class ChatbotScreen extends StatefulWidget {
  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, String>> messages = [];
  bool showHelp = false;

  Future<void> sendMessage() async {
    if (_controller.text.isEmpty) return;

    String userMessage = _controller.text;
    setState(() {
      messages.add({'sender': 'user', 'text': userMessage});
    });

    _controller.clear();

    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:5000/chatbot'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': userMessage}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          messages.add({'sender': 'bot', 'text': data['response']});
        });
      } else {
        throw Exception("Failed to get response from chatbot.");
      }
    } catch (error) {
      setState(() {
        messages.add({'sender': 'bot', 'text': 'Error connecting to chatbot!'});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Match UI Theme
      appBar: AppBar(
        title: Text("AI Chatbot"),
        backgroundColor: Colors.black, // Keep consistent with UI
      ),
      body: Column(
        children: [
          // Help Section
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              children: [
                InkWell(
                  onTap: () => setState(() => showHelp = !showHelp),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "How to Use Chatbot",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      Icon(
                        showHelp ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
                if (showHelp)
                  Card(
                    color: Colors.grey[900], // Dark theme card
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("✔️ You can ask questions like:", style: TextStyle(color: Colors.white)),
                          Text("- 'Explain Decision Trees'", style: TextStyle(color: Colors.white70)),
                          Text("- 'Give me ML interview questions'", style: TextStyle(color: Colors.white70)),
                          Text("- 'Suggest practice problems on SVM'", style: TextStyle(color: Colors.white70)),
                          SizedBox(height: 8),
                          Text("💡 Tip: Be specific for better answers!", style: TextStyle(color: Colors.blueAccent)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Chat Messages Section
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16.0),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                bool isUser = message['sender'] == 'user';

                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 6.0),
                    padding: EdgeInsets.all(14.0),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue.shade700 : Colors.grey.shade900, // Match theme
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                        bottomLeft: isUser ? Radius.circular(12) : Radius.zero,
                        bottomRight: isUser ? Radius.zero : Radius.circular(12),
                      ),
                    ),
                    child: Text(
                      message['text']!,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),
          // Input Field
          Padding(
            padding: EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      controller: _controller,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Type a message...",
                        hintStyle: TextStyle(color: Colors.white70),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(12),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blueAccent,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.send, color: Colors.white),
                    onPressed: sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FeatureCard extends StatelessWidget {
  final String title;
  FeatureCard({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.white24, blurRadius: 10, spreadRadius: 1),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome, size: 40, color: Colors.white70),
          SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
