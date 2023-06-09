import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NewCar extends StatefulWidget {
  @override
  _NewCarState createState() => _NewCarState();
}

class _NewCarState extends State<NewCar> {
  final TextEditingController _vendorname = TextEditingController();
  final TextEditingController _carname = TextEditingController();
  final TextEditingController _carnumber = TextEditingController();
  final TextEditingController _sittingcapacity = TextEditingController();

  String? fetchedFieldName; // Variable to store the fetched field name

  @override
  void initState() {
    super.initState();
    fetchComapnyname(); // Fetch the field name when the widget is initialized
  }

  // Fetch the field name from Firebase
  Future<void> fetchComapnyname() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userId = user.uid;
      DocumentSnapshot<Map<String, dynamic>> snapshot =
      await FirebaseFirestore.instance.collection('users').doc(userId).get();

      if (snapshot.exists) {
        String? phone = snapshot.data()?['phone'] as String?;
        if (phone != null) {
          QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance.collection('number').get();

          if (querySnapshot.docs.isNotEmpty) {
            for (QueryDocumentSnapshot<Map<String, dynamic>> document
            in querySnapshot.docs) {
              List<dynamic> phoneArray = document.data()['phone'];
              for (int i = 0; i < phoneArray.length; i++) {
                if (phoneArray[i] is Map<String, dynamic>) {
                  Map<String, dynamic> map =
                  Map<String, dynamic>.from(phoneArray[i]);
                  if (map.containsValue(phone)) {
                    fetchedFieldName = map.keys.first;
                    break;
                  }
                } else if (phoneArray[i] == phone) {
                  fetchedFieldName = 'phone';
                  break;
                }
              }
            }
          }
        }
      }
    }
  }

  void _saveOption() {
    String vendorname = _vendorname.text.trim();
    String carname = _carname.text.trim();
    String carnumber = _carnumber.text.trim();
    String sittingcapacity = _sittingcapacity.text.trim();

    if (vendorname.isNotEmpty && fetchedFieldName != null) {
      FirebaseFirestore.instance
          // .collection(fetchedFieldName!) // Use the fetched field name
          // .doc('Vendors')
          .collection('vendors')
          .doc(vendorname)
          .collection('vehicle')
          .add({
        'company':fetchedFieldName,
        'CarName': carname,
        'CarNumber': carnumber,
        'SittingCapacity': sittingcapacity,
      })
          .then((value) => print('Option added'))
          .catchError((error) => print('Failed to add option: $error'));

      FirebaseFirestore.instance
          // .collection(fetchedFieldName!) // Use the fetched field name
          // .doc('Vendors')
          .collection('vendors')
          .doc(vendorname)
          .set({'vendorname': vendorname,'company':fetchedFieldName,});

      _vendorname.clear();
      _carname.clear();
      _sittingcapacity.clear();
      _carnumber.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Add Cars'),
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.asset(
                "assets/images/vendors.jpg",
                fit: BoxFit.cover,
                height: 200,
              ),
              TextField(
                controller: _vendorname,
                decoration: InputDecoration(
                  labelText: 'Vendor Name',
                ),
              ),
              TextField(
                controller: _carname,
                decoration: InputDecoration(
                  labelText: 'Car Name',
                ),
              ),
              TextField(
                controller: _carnumber,
                decoration: InputDecoration(
                  labelText: 'Car Number',
                ),
              ),
              TextField(
                controller: _sittingcapacity,
                keyboardType: TextInputType.number,

                decoration: InputDecoration(

                  labelText: 'Sitting Capacity',
                ),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _saveOption,
                child: Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
