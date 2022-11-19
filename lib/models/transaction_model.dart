// Whatever data we grab from database it is going to stay in this transaction model

class TransactionModel{
  final int amount;
  final DateTime date;
  final String note;
  final String type;


  TransactionModel(this.amount, this.date, this.note, this.type);


}