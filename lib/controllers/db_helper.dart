import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DBHelper{
  late Box box;
  late SharedPreferences preferences;

 DBHelper(){
openBox();
 }

 openBox(){
   box = Hive.box('money');
 }

 Future addData(int amount, DateTime date, String note, String type) async{
   // creating map => key value pair
   var value = {'amount' : amount, 'date' : date, 'note' : note, 'type' : type};
   box.add(value); // this will add the value to the box
 }

 // For deleting data
 Future deleteData(int index) async{
   await box.deleteAt(index);
 }

  // we want to store name so we will use local db shared preference
  // We used hive to store transaction data
 addName(String name) async{  // it will basically add name
  preferences = await SharedPreferences.getInstance();
  preferences.setString("name", name);
 }

 getName() async{ // it is basically to grab a name
   preferences = await SharedPreferences.getInstance();
   return preferences.getString('name');
 }
}