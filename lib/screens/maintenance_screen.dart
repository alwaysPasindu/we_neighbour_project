import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';
import './create_maintenance_request_screen.dart';

class MaintenanceCard {
  final String title;
  final String description;
  String feedback = '';
  int rating = 0;

  MaintenanceCard({required this.title, required this.description});
}

class MaintenanceScreen extends StatefulWidget {
  const MaintenanceScreen({Key? key}) : super(key: key);

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> {
  final List<MaintenanceCard> _maintenanceCards = [
    MaintenanceCard(
      title: 'Security\nmaintenance',
      description: 'Encrypt all user data, including visitor management details and feedback records.',
    ),
    MaintenanceCard(
      title: 'General\nmaintenance',
      description: 'Optimize app speed by reducing redundant processes and optimizing database queries.',
    ),
    MaintenanceCard(
      title: 'Feature\nmaintenance',
      description: 'Test QR code generation and scanning systems weekly to ensure smooth operation.',
    ),
    MaintenanceCard(
      title: 'Security\nmaintenance',
      description: 'Encrypt all user data, including visitor management details and feedback records.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0A1A3B) : Colors.white,
      appBar: AppBar(
        backgroundColor: isDarkMode ? const Color(0xFF0A1A3B) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDarkMode ? Colors.white : Colors.black,
            size: 30,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Maintenance',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.85,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _maintenanceCards.length,
        itemBuilder: (context, index) {
          return _buildMaintenanceCard(_maintenanceCards[index], isDarkMode);
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF4080FF),
        child: const Icon(Icons.add, size: 32),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateMaintenanceRequestScreen(),
            ),
          );
          
          if (result != null && result is MaintenanceCard) {
            setState(() {
              _maintenanceCards.add(result);
            });
          }
        },
      ),
    );
  }

  Widget _buildMaintenanceCard(MaintenanceCard card, bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF4080FF),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            card.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              card.description,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: TextField(
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
                hintText: 'Type Your Feedback',
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
              ),
              onChanged: (value) {
                setState(() {
                  card.feedback = value;
                });
              },
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (starIndex) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    card.rating = starIndex + 1;
                  });
                },
                child: Icon(
                  Icons.star,
                  color: starIndex < card.rating ? Colors.amber : Colors.white,
                  size: 20,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}