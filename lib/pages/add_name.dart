import 'package:expense_manager/controllers/db_helper.dart';
import 'package:expense_manager/pages/home_screen.dart';
import 'package:flutter/material.dart';

class AddName extends StatefulWidget {
  const AddName({Key? key}) : super(key: key);

  @override
  State<AddName> createState() => _AddNameState();
}

class _AddNameState extends State<AddName> {
  DBHelper dbHelper = DBHelper();

  String name= "";  // we want to store name so we will use local db shared preference
  // We used hive to store transaction data


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0.0, // for showing appbar color only
      ),
      // backgroundColor: Colors.deepPurple,

      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white70,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.all(16),
              child: Image.asset("assets/icon.jpg", width: 64, height: 64,),
            ),
            SizedBox(height: 12,),
            Text("What should we call you ?", textAlign: TextAlign.right, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),),
            SizedBox(height: 12,),

            Container(
    decoration: BoxDecoration(
        color: Colors.white70,
        borderRadius: BorderRadius.circular(12)
    ),
    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    child: TextField(
        decoration: InputDecoration(
          hintText: "Your Name",
          border: InputBorder.none
        ),
        style: TextStyle(fontSize: 20),
      onChanged: (val){
          name = val;
      },
    ),
            ),
            SizedBox(height: 12,),
            SizedBox(
                height: 50,
                width: double.maxFinite,  // to occupy full screen by button
                child: ElevatedButton(onPressed: (){
                //   check if there is a valid name
                  if(name.isNotEmpty){
                  //  add to database
                  //  move to homepage
                    dbHelper.addName(name);
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
                  }
                  else{
                  //  show some error
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                      action: SnackBarAction(
                        label: "OK",
                        onPressed: (){
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        },
                      ),

                          backgroundColor: Colors.white,
                          content: Text(
                            "Please Enter a name",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18
                            ),
                          ),
                    ));
                  }
                },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Next",  style: TextStyle(fontSize: 20.0),),
                  SizedBox(width: 6,),
                    Icon(Icons.navigate_next_outlined)
                  ],
                )
                ))
          ],
        ),
      ),
    );
  }
}
