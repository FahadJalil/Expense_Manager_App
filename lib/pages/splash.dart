import 'package:expense_manager/controllers/db_helper.dart';
import 'package:expense_manager/pages/add_name.dart';
import 'package:expense_manager/pages/home_screen.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  DBHelper dbHelper = DBHelper();

  Future getSettings() async{
    String? name = await dbHelper.getName();  // it can be a null it is not mandatory that we everytime get a name
    if(name != null){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
    }
    else{
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AddName()));
    }
}

@override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSettings(); // calling get setting function
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0.0, // for showing appbar color only
      ),
      backgroundColor: Colors.deepPurple,

      body: Center(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white70,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.all(16),
          child: Image.asset("assets/icon.jpg", height: 64, width: 64,),
        ),
      ),
    );
  }
}
