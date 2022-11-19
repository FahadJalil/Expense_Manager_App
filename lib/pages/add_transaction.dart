import 'package:expense_manager/controllers/db_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AddTransaction extends StatefulWidget {
  const AddTransaction({Key? key}) : super(key: key);

  @override
  State<AddTransaction> createState() => _AddTransactionState();
}

class _AddTransactionState extends State<AddTransaction> {
  // for amount that we have spent
  int? amount;
  String note = "some Expense";
  String type = "Income";
  DateTime selectedDate = DateTime.now();

  List<String> months = [
    "Jan", "Feb", "Mar", "Apr", "May", "Jun",
    "Jul", "Aug", "Sep", "Oct", "Nov", "Dec",
  ];

  // Function for picking date through calendar
  // DateTime is like a datatype
  Future<void> _selectedDate(context) async{
    final DateTime? picked = await showDatePicker(context: context, initialDate: selectedDate,
        firstDate: DateTime(2020, 12), lastDate: DateTime(2100, 01));
    if(picked != null && picked != selectedDate){
      setState(() {
        selectedDate = picked;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      // backgroundColor: Colors.grey,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text("Add Transaction"),
        centerTitle: true,
      ),
      backgroundColor: Color(0xffe2e7ef),
      body: ListView(
        padding: EdgeInsets.all(12.0),
        children: [
          SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Container(
                  decoration: BoxDecoration(
                    color: Colors.deepPurple,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: EdgeInsets.all(12),
                  child: Icon(
                    Icons.attach_money,
                    size: 24,
                    color: Colors.white,
                  )),
              SizedBox(
                width: 12,
              ),
              Expanded(
                child: TextField(
                  keyboardType: TextInputType.number,
                  decoration:
                      InputDecoration(hintText: "0", border: InputBorder.none),
                  style: TextStyle(fontSize: 20),
                  onChanged: (val){
                    try{
                      // for converting value to int in text field
                      amount = int.parse(val);
                    }
                    catch (e){
                      Fluttertoast.showToast(msg: "Enter only a number",
                      gravity: ToastGravity.CENTER,
                        toastLength: Toast.LENGTH_SHORT
                      );
                    }
                  },
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.deepPurple,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: EdgeInsets.all(12),
                child: Icon(
                  Icons.description,
                  size: 24,
                  color: Colors.white,
                ),
              ),
              SizedBox(
                width: 12,
              ),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                      hintText: "Note on Transaction",
                      border: InputBorder.none),
                  style: TextStyle(
                    fontSize: 24,
                  ),
                  onChanged: (val){
                    note = val;
                  },
                ),
              )
            ],
          ),
          SizedBox(
            height: 20,
          ),
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.deepPurple,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: EdgeInsets.all(12),
                child: Icon(
                  Icons.money_sharp,
                  size: 24,
                  color: Colors.white,
                ),
              ),
              SizedBox(
                width: 12,
              ),
              ChoiceChip(
                label: Text(
                  "Income",
                  style: TextStyle(fontSize: 16, color: type == "Income" ? Colors.white : Colors.black),
                ),
                selectedColor: Colors.deepPurple,
                selected: type == "Income" ? true : false,

              // if it is selected something will be happen
                onSelected: (val){
                  if(val){
                    setState(() {
                      type = "Income";
                    });
                  }
                },
              ),
              SizedBox(width: 12,),

              ChoiceChip(label: Text("Expense",
                style: TextStyle(fontSize: 16, color: type == "Expense" ? Colors.white : Colors.black),),
                  selectedColor: Colors.deepPurple,
              selected: type == "Expense" ? true : false,
                onSelected: (val){
                setState(() {
                  type = "Expense";
                });
                },
              ),
            ],
          ),
          SizedBox(height: 20,),

          SizedBox(
            height: 50,
              child: TextButton(onPressed: () {
                //calling function here so we can select date & month from calendar
                _selectedDate(context);
              },  style: ButtonStyle(padding: MaterialStateProperty.all(EdgeInsets.zero)),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.deepPurple,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: EdgeInsets.all(12),
                        child: Icon(Icons.date_range,
                          size: 24, color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 12,),
                      // For date
                      Text("${selectedDate.day} ${months[selectedDate.month - 1]}"), // index start from 0
                    ],
                  ))),
          SizedBox(height: 20,),

          SizedBox(
            height: 50,
            child: ElevatedButton(onPressed: () async{
            //  For Testing if we are getting value or not in console
              print(amount);
              print(note);
              print(type);
              print(selectedDate);

            //  we have to check if some of values are null or not
              if(amount != null && note.isNotEmpty){
                DBHelper dbHelper = DBHelper();
                dbHelper.addData(amount!, selectedDate, note, type);
                Navigator.of(context).pop();
              }
              else{
                print("Not all values provided");
              }
            },
              child:  Text("Add", style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600),),
              ),
          ),
        ],
      ),
    ));
  }
}
