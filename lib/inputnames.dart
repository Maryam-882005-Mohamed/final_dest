import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NameInputPage extends StatefulWidget {
  @override
  _NameInputPageState createState() => _NameInputPageState();
}

class _NameInputPageState extends State<NameInputPage> {
  final TextEditingController nameController = TextEditingController();

  void addName() async {
    if (nameController.text.isEmpty) return;

    // Check current number of winners
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("winners")
        .get();

    if (snapshot.docs.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Maximum of 3 winners allowed.")),
      );
      return;
    }

    // Add winner to Firestore
    await FirebaseFirestore.instance.collection("winners").add({
      "name": nameController.text,
      "timestamp": FieldValue.serverTimestamp(),
    });

    nameController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Winner added successfully ")),
    );
  }

  void showWinners() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ShowNamesPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        title: Text(
          "Clue Solver Winners",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.green.shade800,
        elevation: 6,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.green.shade200,
              backgroundImage: AssetImage("assets/images/cairouni.jpg"),
            ),
            SizedBox(height: 25),
            Text(
              "Enter Winner Name",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade900,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: "Enter winner name",
                filled: true,
                fillColor: Colors.white,
                prefixIcon: Icon(Icons.person, color: Colors.green.shade700),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: addName,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  "Confirm",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
            Spacer(),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade700,
                padding: EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: showWinners,
              icon: Icon(Icons.emoji_events, color: Colors.white),
              label: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  "Show Winners",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ShowNamesPage extends StatelessWidget {
  final List<Color> medalColors = [
    Colors.green.shade700,
    Colors.green.shade500,
    Colors.green.shade300,
  ];

  final List<String> medals = ["🥇", "🥈", "🥉"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        title: Text(
          "Winners",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.green.shade800,
        elevation: 6,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("winners")
            .orderBy("timestamp", descending: false) // ✅ first added = first place
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var docs = snapshot.data!.docs;

          // Limit to first 3 winners
          var top3Docs = docs.length > 3 ? docs.sublist(0, 3) : docs;

          return ListView.builder(
            itemCount: top3Docs.length,
            itemBuilder: (context, index) {
              var data = top3Docs[index];

              return Container(
                margin: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      medalColors[index].withOpacity(0.9),
                      medalColors[index].withOpacity(0.5),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(2, 4),
                    ),
                  ],
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: medalColors[index],
                    child: Text(
                      medals[index],
                      style: TextStyle(fontSize: 22, color: Colors.white),
                    ),
                  ),
                  title: Text(
                    data["name"],
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
