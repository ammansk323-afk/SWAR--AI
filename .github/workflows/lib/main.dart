import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

void main() {
  runApp(const SwarAIApp());
}

class SwarAIApp extends StatelessWidget {
  const SwarAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SwarAI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0077D7)),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const MainHomeScreen(),
    );
  }
}

class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({super.key});

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  int _currentIndex = 0;
  int _credits = 10;
  bool _isSubscribed = false;

  final FlutterTts _flutterTts = FlutterTts();
  final TextEditingController _textController = TextEditingController(
    text: "নমস্কার! SwarAI-তে আপনাকে স্বাগতম। আপনার পছন্দের ভয়েস সিলেক্ট করুন।",
  );

  String _selectedLanguage = "bn-IN";
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  void _initTts() async {
    await _flutterTts.setLanguage(_selectedLanguage);
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.5);

    _flutterTts.setCompletionHandler(() {
      setState(() => _isSpeaking = false);
    });
  }

  void _speak() async {
    if (_textController.text.trim().isEmpty) return;
    if (!_isSubscribed && _credits <= 0) {
      _showSubscriptionDialog();
      return;
    }

    setState(() => _isSpeaking = true);
    await _flutterTts.setLanguage(_selectedLanguage);
    await _flutterTts.speak(_textController.text);

    if (!_isSubscribed) {
      setState(() {
        _credits = (_credits - 1).clamp(0, 9999);
      });
    }
  }

  void _stop() async {
    await _flutterTts.stop();
    setState(() => _isSpeaking = false);
  }

  void _watchAd() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("ভিডিও অ্যাড লোড হচ্ছে..."),
        content: const Text("অ্যাড শেষ হলে আপনি ৫টি ক্রেডিট পাবেন।"),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _credits += 5);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("অভিনন্দন! ৫ ক্রেডিট যোগ করা হয়েছে।")),
              );
            },
            child: const Text("অ্যাড দেখা শেষ করুন"),
          )
        ],
      ),
    );
  }

  void _showSubscriptionDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "প্রিমিয়াম সাবস্ক্রিপশন",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text("মাত্র ₹১০০ / প্রতি মাসে আনলিমিটেড ভয়েস জেনারেশন"),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0077D7),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                setState(() => _isSubscribed = true);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("সাবস্ক্রিপশন সফল হয়েছে!")),
                );
              },
              child: const Text("UPI / GPay দিয়ে ₹১০০ পেমেন্ট করুন"),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                _watchAd();
              },
              child: const Text("অথবা ফ্রি ক্রেডিট পেতে অ্যাড দেখুন"),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SwarAI (স্বর এআই)', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0077D7),
        foregroundColor: Colors.white,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _isSubscribed ? "VIP Pro" : "🪙 $_credits ক্রেডিট",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ভাষা নির্বাচন
            const Text("ভাষা নির্বাচন করুন:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            Row(
              children: [
                ChoiceChip(
                  label: const Text("বাংলা (India)"),
                  selected: _selectedLanguage == "bn-IN",
                  onSelected: (val) {
                    setState(() => _selectedLanguage = "bn-IN");
                  },
                ),
                const SizedBox(width: 10),
                ChoiceChip(
                  label: const Text("হিন্দি (Hindi)"),
                  selected: _selectedLanguage == "hi-IN",
                  onSelected: (val) {
                    setState(() => _selectedLanguage = "hi-IN");
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            // টেক্সট বক্স
            const Text("টেক্সট লিখুন:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              controller: _textController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: "এখানে আপনার লেখা পেস্ট বা টাইপ করুন...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 20),

            // প্লে/স্টপ বাটন
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isSpeaking ? Colors.red : const Color(0xFF0077D7),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isSpeaking ? _stop : _speak,
                icon: Icon(_isSpeaking ? Icons.stop : Icons.play_arrow),
                label: Text(
                  _isSpeaking ? "ভয়েস থামান" : "ভয়েস শুনুন",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // সাবস্ক্রিপশন কার্ড
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const ListTile(
                      leading: Icon(Icons.workspace_premium, color: Colors.amber, size: 36),
                      title: Text("মাসিক প্ল্যান - ₹১০০", style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text("আনলিমিটেড ভয়েস ও ভয়েস ক্লোনিং সুবিধা"),
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        OutlinedButton.icon(
                          onPressed: _watchAd,
                          icon: const Icon(Icons.ondemand_video),
                          label: const Text("+৫ ক্রেডিট"),
                        ),
                        ElevatedButton(
                          onPressed: _showSubscriptionDialog,
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                          child: const Text("সাবস্ক্রাইব করুন"),
                        ),
                      ],
                    )
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
