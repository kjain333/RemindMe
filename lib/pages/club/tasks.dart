import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:scheduler/models/models.dart';
import 'package:scheduler/pages/student/forms.dart';

class ClubTasks extends StatefulWidget {

  final userData;
  ClubTasks(this.userData);

  @override
  _ClubTasksState createState() => _ClubTasksState();
}

bool loading = true;
class _ClubTasksState extends State<ClubTasks> {

  List<Reminder> remainders = [];
  User user = FirebaseAuth.instance.currentUser;

  List<dynamic> subscribed;
  void setReminders() async{
    QuerySnapshot clubList = await FirebaseFirestore.instance.collection("Clubs").get();
    subscribed = clubList.docs;
    remainders.clear();
    for(int i=0;i<subscribed.length;i++)
    {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection("data").doc(subscribed[i]["uid"].toString()).collection("reminders").get();
      List<QueryDocumentSnapshot> data = querySnapshot.docs;
      for(int j=0;j<data.length;j++)
      {
        Reminder rem = Reminder(
            data[j].get('title'),
            data[j].get('subtitle'),
            data[j].get('details'),
            data[j].get('by'),
            data[j].get('date'),
            data[j].get('startTime'),
            data[j].get('endTime')
        );
        remainders.add(rem);
      }
    }
    setState(() {
      loading = false;
    });
  }

  @override
  void initState() {
    loading = true;
    subscribed = new List();
    setReminders();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    var size = MediaQuery.of(context).size;
    return (loading==true)?Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    ):Scaffold(
      // backgroundColor: Colors.grey[500],
      body: Column(
        children: [
          Row(
            children: [
              Spacer(),
              Container(
                padding: EdgeInsets.fromLTRB(0, 0, 8, 0),
                height: size.height*0.06,
                alignment: AlignmentDirectional.center,
                child: FlatButton(
                  onPressed: null,
                  child: Row(
                    children: [
                      Icon(
                        Icons.filter_list,
                        color: Colors.blue,
                      ),
                      Text(
                        " Filter",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: ReminderItems(remainders),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          var newItem = await Navigator.push(context, MaterialPageRoute(builder: (context)=>Forms(widget.userData)));
          if(newItem!=null)
          {
            setState(() {
              remainders.add(newItem);
            });
          }
        },
      ),
    );
  }
}


class ReminderItems extends StatefulWidget {

  final List<Reminder> remainders;
  ReminderItems(this.remainders);

  @override
  _ReminderItemsState createState() => _ReminderItemsState();
}

class _ReminderItemsState extends State<ReminderItems> {

  @override
  Widget build(BuildContext context) {
    // remainders.add(Remainder("A","B","C","D","E","F"));

    return ListView.builder(
      itemCount: widget.remainders.length,
      itemBuilder: (context,index) => RemainderListItem(widget.remainders[index]),
    );
  }
}

class RemainderListItem extends StatefulWidget {

  final Reminder remainder;
  RemainderListItem(this.remainder);

  @override
  _RemainderListItemState createState() => _RemainderListItemState();
}

class _RemainderListItemState extends State<RemainderListItem> {
  @override
  Widget build(BuildContext context) {

    return Card(
      margin: EdgeInsets.fromLTRB(8,8,8,0),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: GestureDetector(
        onLongPress: (){print("Long pressed!");},
        child: ListTile(
          onTap: (){print('Tapped');},
          title: Text(widget.remainder.title),
          trailing: Icon(
            Icons.notifications_active,
            color: Colors.red,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
               widget.remainder.by,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              Row(
                children: [
                  Text("On "),
                  Text(widget.remainder.date),
                  SizedBox(width: 10),
                  Text("At "),
                  Text(widget.remainder.startTime),
                  Text(" to "),
                  Text(widget.remainder.endTime),
                ],
              ),
            ],
          ),
          isThreeLine: true,

        ),
      ),
    );
  }
}
