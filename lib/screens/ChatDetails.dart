// ignore_for_file: file_names, prefer_const_con, prefer_const_constructors


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:local_chat/screens/chat_list.dart';

class ChatDetails extends StatefulWidget {
  const ChatDetails({ Key? key,required this.receiverName,required this.receiverEmail}) : super(key: key);
  final String receiverName;
  final String receiverEmail;
  @override
  _ChatDetailsState createState() => _ChatDetailsState();
}
var messageController = TextEditingController();
class _ChatDetailsState extends State<ChatDetails> {
  var color1 = Colors.yellow[600];
  var color2 = darkMode? Colors.black : Colors.white;
  var color3 = darkMode==false? Colors.black : Colors.white;
  var formKey = GlobalKey<FormState>();
  String currentEmail = "";
  String currentUID = '';
  String currentUserName = '';
  String currentUserNumber = '';
  late bool isMe;
  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    inputData();
    getCurrentData();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        leading: IconButton(
          onPressed: (){
            Navigator.pop(context);
          }, 
          icon: Icon(Icons.arrow_back_ios)
        ),
        title:Text(
          widget.receiverName,
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: color1,
      ),
      body: Container(
        color: color2,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: StreamBuilder(
                stream: firestore.collection(currentEmail).doc(widget.receiverEmail).collection('Chats').orderBy('timestamp', descending: true).snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot){
                  if(snapshot.hasError){
                    return Text('Something went wrong');
                  }
                  if (!snapshot.hasData){
                    return Center(child: CircularProgressIndicator());
                  }
                  else{
                    var data = snapshot.data!.docs;
                    int length = data.length;
                    return ListView.builder(
                      reverse: true,
                      itemCount: length,
                      itemBuilder: (context,i){
                        (currentEmail == data[i]['sender'])? isMe = true: isMe= false;
                        return Align(
                          alignment: isMe? Alignment.bottomRight:Alignment.bottomLeft,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(10,5,10,5),
                            child: Material(
                              borderRadius: isMe
                                  ? BorderRadius.only(
                                      topLeft: Radius.circular(30.0),
                                      bottomLeft: Radius.circular(30.0),
                                      bottomRight: Radius.circular(30.0))
                                  : BorderRadius.only(
                                      bottomLeft: Radius.circular(30.0),
                                      bottomRight: Radius.circular(30.0),
                                      topRight: Radius.circular(30.0),
                                    ),
                              elevation: 5.0,
                              color: isMe? color1 : Colors.white,
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                                child: Text(
                                  data[i]['Msg'],
                                  style: TextStyle(
                                    color: isMe==false ? color1 : Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15.0,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                    );
                  }
                },
              ),
            ),

            Row(
              children: [
                IconButton(
                  onPressed: (){}, 
                  icon: Icon(Icons.add_a_photo,color: color1,)
                ),
                SizedBox(width: 15,),
                Expanded(
                  child: Form(
                    key: formKey,
                    child: TextFormField(
                      controller: messageController,
                      style: TextStyle(color: color3),
                      validator: (value){
                        if(value!.isEmpty){
                          return 'An empty message can\'t be send';
                        }
                        else{
                          return null;
                        }
                      },
                      decoration: InputDecoration(
                        hintText: "Write message...",
                        hintStyle: TextStyle(color: color3),
                        border: InputBorder.none,
                        
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: (){
                    if(formKey.currentState!.validate())
                      {
                        addSender(widget.receiverEmail);
                        addTime(widget.receiverEmail);
                        addMessage(messageController.text);
                      
                        messageController.clear();
                      }
                  }, 
                  icon: Icon(Icons.send,color: color1,)
                )
              ],
            ),
            SizedBox(height: 20,)
          ],
        ),
      ),
    );
  }
// var timeformat = DateTime.now().hour.toString() + ':'+ DateTime.now().minute.toString();
// var dateformat = DateTime.now().day.toString() + '/'+ DateTime.now().month.toString()+ '/'+ DateTime.now().year.toString();
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  addMessage(String message) async{
    await firestore
      .collection(currentEmail)
      .doc(widget.receiverEmail)
      .collection("Chats")
      .doc().set(
        {
          'Msg': message,
          'sender':currentEmail,
          'timestamp': FieldValue.serverTimestamp(),
        }
      );
    await firestore
      .collection(widget.receiverEmail)
      .doc(currentEmail)
      .collection("Chats")
      .doc().set(
        {
          'Msg': message,
          'sender':currentEmail,
          'timestamp': FieldValue.serverTimestamp(),
        }
      );
  }
  addSender(String receiverEmail) async{
    await firestore
    .collection(receiverEmail)
    .doc(currentEmail).set({
      'Name': currentUserName,
      'Email': currentEmail,
      'timestamp': FieldValue.serverTimestamp(),
    }
    );
  }
  
  addTime(String receiverEmail) async{
    await firestore
    .collection(currentEmail)
    .doc(receiverEmail).update({
      'timestamp': FieldValue.serverTimestamp(),
    });
    await firestore
    .collection(receiverEmail)
    .doc(currentEmail).update({
      'timestamp': FieldValue.serverTimestamp(),
    });
}
  void inputData() { 
    final User? user = auth.currentUser;
    currentEmail = user!.email.toString();
    currentUID = user.uid.toString();
  }
  Future getCurrentData() async{
      return await firestore
      .collection('Users')
      .doc(currentEmail)
      .get().then((snapshot) {
        setState(() {
          currentUserName = snapshot.get('Name').toString();
          currentUserNumber = snapshot.get('Mobile').toString();
        });
      });
    }
}
