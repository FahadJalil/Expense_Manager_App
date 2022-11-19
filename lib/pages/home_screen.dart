import 'package:expense_manager/controllers/db_helper.dart';
import 'package:expense_manager/pages/add_transaction.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/transaction_model.dart';
import '../widgets/confirm_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DBHelper dbHelper = DBHelper();
  DateTime today = DateTime.now();
  late SharedPreferences preferences;
  late Box box;
  int totalBalance = 0;
  int totalIncome = 0;
  int totalExpense = 0;
  List<FlSpot> dataSet = [];

  List<String> months = [
    "Jan", "Feb", "Mar", "Apr", "May", "Jun",
    "Jul", "Aug", "Sep", "Oct", "Nov", "Dec",
  ];

  List<FlSpot> getPlotPoints(List<TransactionModel> entireData){
    dataSet = [];
    // entireData.forEach((key, value) {
    //   if(value['type'] == "Expense" && (value['date'] as DateTime).month == today.month){
    //     dataSet.add(FlSpot((value['date'] as DateTime).day.toDouble(), (value['amount'] as int).toDouble()));
    //   }
    // });

    // We need sorted list of data in graph according to date
    List tempDataSet = [];  // for generating plot points data
    for(TransactionModel data in entireData){
      if(data.date.month == today.month && data.type == "Expense"){
        tempDataSet.add(data);
      }
    }

    tempDataSet.sort((a, b) => a.date.day.compareTo(b.date.day));  // it will sort in ascending order

    for(var i = 0; i< tempDataSet.length; i++){
      dataSet.add(FlSpot(tempDataSet[i].date.day.toDouble(), tempDataSet[i].amount.toDouble()));
    }
    return dataSet;
  }

  getTotalBalance(List<TransactionModel> entireData) {
    totalExpense = 0;
    totalIncome = 0;
    totalBalance = 0;

    // entireData.forEach((key, value) {
    //   print(key);
    //   // print(value); // this will be entire map
    //   if (value["type"] == "Income") {
    //     totalBalance +=
    //         (value['amount'] as int); // AMOUNT enter in add transaction screen
    //     totalIncome += (value['amount'] as int);
    //   }
    //   // if it is expense
    //   else {
    //     totalBalance -= (value['amount'] as int);
    //     totalExpense -= (value['amount'] as int);
    //   }
    // });

    for(TransactionModel data in entireData){
      if(data.date.month == today.month){
        if(data.type == "Income"){
          totalBalance += data.amount;
          totalIncome += data.amount;
        }
        else{ // it's an expense
          totalBalance -= data.amount;
          totalExpense -= data.amount;
        }
      }
    }
  }

  getPreferences() async{
    preferences = await SharedPreferences.getInstance();
  }

  Future<List<TransactionModel>> fetch() async{
    if(box.values.isEmpty){  // which means there are no values
      return Future.value([]);  // which is empty list
    }
    else{
      List<TransactionModel> items = []; // to build list from the data
      box.toMap().values.forEach((element) {
        // print(element);  // this will display all data => amount, date, type, note
        items.add(TransactionModel(element['amount'] as int,
            element['date'] as DateTime,
            element['note'] as String,
            element['type'] as String
        ));
      });
      return items;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPreferences(); // calling getPreferences function here
    box = Hive.box('money');  // which we created in main
    fetch();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        // backgroundColor: Colors.grey,
        resizeToAvoidBottomInset: false,
        // appBar: AppBar(
        //   title: Text("Personal Expense"),
        //   centerTitle: true,
        //   actions: [
        //
        //   ],
        // ),

        backgroundColor: Color(0xffe2e7ef),

        // body: Container(
        //   height: 30,
        //   width: 30,
        //   child: Padding(
        //     padding: const EdgeInsets.all(8.0),
        //     child: Column(
        //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //       crossAxisAlignment: CrossAxisAlignment.start,
        //       children: [
        //         Row(
        //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //           children: [
        //             TextButton(onPressed: (){}, child: Text("Summary", style: TextStyle(color: Colors.green),)),
        //           ],
        //         )
        //       ],
        //     ),
        //   ),
        // ),

        body: FutureBuilder<List<TransactionModel>>(
          future: fetch(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text("Unexpecdted Error !"),
              );
            }
            if (snapshot.hasData) {
              if (snapshot.data!.isEmpty) {
                return Center(
                  child: Text("No Values Found"),
                );
              }

              getTotalBalance(snapshot.data!);
              getPlotPoints(snapshot.data!);
              return ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(32),
                                    color: Colors.white70),
                                child: CircleAvatar(
                                    maxRadius: 32.0,
                                    child: Icon(
                                      Icons.monetization_on,
                                      size: 32,
                                      color: Colors.blueGrey,
                                    ))),
                          ],
                        ),

                        Text(
                          "Welcome ${preferences.getString("name")}",
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Colors.deepPurple),
                        ),
                        Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.white70),
                            child: Icon(
                              Icons.settings,
                              size: 32,
                              color: Colors.blueGrey,
                            )),
                      ],
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    margin: EdgeInsets.all(12),
                    child: Container(
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              colors: [Colors.deepPurple, Colors.blueAccent]),
                          borderRadius: BorderRadius.all(Radius.circular(24))),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 20.0, horizontal: 8),
                        child: Column(
                          children: [
                            Text(
                              "Total Balance",
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(fontSize: 22, color: Colors.white),
                            ),
                            SizedBox(
                              height: 12,
                            ),
                            Text(
                              "Rs $totalBalance",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 26,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700),
                            ),
                            SizedBox(
                              height: 12,
                            ),
                            Padding(
                              padding: EdgeInsets.all(8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  cardIncome(totalIncome
                                      .toString()), // cardIncome function calling to display under total balance
                                  cardExpense(totalExpense.toString())
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(12),
                    child: Text(
                      "Expenses",
                      style: TextStyle(
                          fontSize: 32,
                          color: Colors.black87,
                          fontWeight: FontWeight.w900),
                    ),
                  ),

                  // here we need giant chart => we will plot a chart here
                  dataSet.length < 2 ?  Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 40),
            margin: EdgeInsets.all(12),
            decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
            BoxShadow(
            color: Colors.grey.withOpacity(0.4),
            spreadRadius: 5,
            blurRadius: 6,
            offset: Offset(0, 4)
            ),
            ]
            ),
            child: Text("No enough values to render Chart", style: TextStyle(fontSize: 20,
                color: Colors.black87, fontWeight: FontWeight.w900),),  // 2
            )

                //  if dataset is greater than 2
                : Container(
                    height: 400,
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 40),
                    margin: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.4),
                          spreadRadius: 5,
                          blurRadius: 6,
                          offset: Offset(0, 4)
                        ),
                      ]
                    ),
                    child: LineChart(
                        LineChartData(
                          borderData: FlBorderData(show: false),  // for removing border line
                        lineBarsData: [
                      LineChartBarData(
                          spots: getPlotPoints(snapshot.data!),
                          // [ it,s static data for just understanding purpose
                          //   FlSpot(1, 4),
                          // FlSpot(7, 15)
                          // ],
                          isCurved: false,
                          barWidth: 2.5,
                          color: Colors.deepPurple)
                    ])),
                  ),

                  Padding(
                    padding: EdgeInsets.all(12),
                    child: Text(
                      "Recent Transactions",
                      style: TextStyle(
                          fontSize: 32,
                          color: Colors.black87,
                          fontWeight: FontWeight.w900),
                    ),
                  ),
                  ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        TransactionModel dataAtIndex;

                        try{
                        dataAtIndex = snapshot.data![index];

                        }
                        catch (e){
                          return Container();
                        }


                        if (dataAtIndex.type == "Income") {
                          return incomeTile(
                              dataAtIndex.amount,
                              dataAtIndex.note,
                          dataAtIndex.date,
                          index);
                        } else {
                          return expenseTile(
                              dataAtIndex.amount,
                              dataAtIndex.note,
                          dataAtIndex.date,
                          index);
                        }
                      }),
                  SizedBox(height: 70,),
                ],
              );
            } else {
              return Center(
                child: Text("Unexpected Error"),
              );
            }
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AddTransaction()))
                .whenComplete(() {
              setState(() {});
            });
          },
          child: Icon(
            Icons.add,
            size: 30,
          ),
        ),
      ),
    );
  }

  // to display income
  Widget cardIncome(String value) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white70,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: EdgeInsets.all(6),
          child: Icon(
            Icons.arrow_downward,
            size: 28,
            color: Colors.green[700],
          ),
          margin: EdgeInsets.only(right: 8),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // We are donating income here
            Text(
              "Income",
              style: TextStyle(fontSize: 14, color: Colors.white70),
            ),

            //  what income we are donating
            Text(
              value,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white70),
            )
          ],
        )
      ],
    );
  }

// We need Card Expense too
  Widget cardExpense(String value) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
              color: Colors.white70, borderRadius: BorderRadius.circular(20)),
          padding: EdgeInsets.all(6),
          child: Icon(
            Icons.arrow_upward,
            size: 28,
            color: Colors.red[700],
          ),
          margin: EdgeInsets.only(right: 8),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              "Expense",
              style: TextStyle(fontSize: 14, color: Colors.white70),
            ),
            Text(
              value,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white70),
            )
          ],
        )
      ],
    );
  }

  Widget expenseTile(int value, String note, DateTime date, int index) {
    return InkWell(
      onLongPress: () async{
        bool? answer = await showConfirmDialog(context, "Warning", "Do You want to delete this record");
        if(answer != null && answer){  // data will be deleted at particular index
          dbHelper.deleteData(index);
          setState(() {

          });
        }
      },
      child: Container(
        margin: EdgeInsets.all(8.0),
        padding: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Color(0xffced4eb),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.arrow_circle_up_outlined,
                      size: 28,
                      color: Colors.red[700],
                    ),
                    SizedBox(
                      width: 4,
                    ),
                    Text(
                      "Expense",
                      style: TextStyle(fontSize: 20),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Text( "${date.day} ${months[date.month - 1]}",
                      style: TextStyle(color: Colors.grey[800])),
                ),
              ],
            ),
            Column(
              children: [
                Text(
                  "- $value",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                ),
                Text(
                  note,
                  style: TextStyle(color: Colors.grey[800]),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget incomeTile(int value, String note, DateTime date, int index) {
    return InkWell(
      onLongPress: () async{
        bool? answer = await showConfirmDialog(context, "Warning", "Do You want to delete this record");
        if(answer != null && answer){  // data will be deleted at particular index
          dbHelper.deleteData(index);
          setState(() {

          });
        }
      },
      child: Container(
        margin: EdgeInsets.all(8.0),
        padding: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Color(0xffced4eb),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.arrow_circle_down_outlined,
                      size: 28,
                      color: Colors.green[700],
                    ),
                    SizedBox(
                      width: 4,
                    ),
                    Text(
                      "Income",
                      style: TextStyle(fontSize: 20),
                    ),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Text( "${date.day} ${months[date.month - 1]}",
                      style: TextStyle(color: Colors.grey[800])),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "+ $value",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                ),
                Text(
                  note,
                  style: TextStyle(color: Colors.grey[800]),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
