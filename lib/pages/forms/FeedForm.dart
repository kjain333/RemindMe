import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:scheduler/models/models.dart';

class FeedForm extends StatefulWidget{

  final userData;
  FeedForm(this.userData);

  _FeedForm createState() => _FeedForm();
}

String poster;
class _FeedForm extends State<FeedForm>{
  TextEditingController title = new TextEditingController();
  TextEditingController by = new TextEditingController();
  TextEditingController description = new TextEditingController();
  TextEditingController link = new TextEditingController();
  final _formkey = GlobalKey<FormState>();
  List<DropdownMenuItem<String>> buildDropDownMenuItems(categoryList) {
    List<DropdownMenuItem<String>> items = List();
    for (String category in categoryList) {
      items.add(DropdownMenuItem(
        value: category,
        child: Text(category),
      ));
    }
    return items;
  }

  Future<void> addDataToFirebase(FeedItem data) async {
    CollectionReference reminder = FirebaseFirestore.instance.collection("data").doc(widget.userData['uid']).collection("feed");
    await reminder.add({
      'title': data.title,
      'by': data.by,
      'senderId' : widget.userData['uid'],
      'details': data.description,
      'link': data.link,
      'poster': data.poster
    }).then((value) => Fluttertoast.showToast(msg: "Data Added Successfully")).catchError((error) => Fluttertoast.showToast(msg: error.toString()));
  }

  @override
  void initState() {
    poster = null;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    // CollectionReference users = FirebaseFirestore.instance.collection('Clubs');
    return SafeArea(
        child: WillPopScope(
          onWillPop: (){
            Navigator.pop(context,null);
            return Future.value(false);
          },
          child: Scaffold(
            body: SingleChildScrollView(
                child: Form(
                  key: _formkey,
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 30,
                      ),
                      Text("Get Started with Creating a Post",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
                      Padding(
                        padding: EdgeInsets.all(20),
                        child: TextFormField(
                          controller: title,
                          validator: (text){
                            if(text == null || text.isEmpty)
                              return "Field cannot be empty";
                            return null;
                          },
                          decoration: InputDecoration(
                              labelText: "Title",
                              hintText: "Provide Title to the post",
                              errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: BorderSide(color: Colors.redAccent)
                              ),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: BorderSide(color: Colors.blueAccent)
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: BorderSide(color: Colors.redAccent)
                              ),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: BorderSide(color: Colors.grey.shade400)
                              )
                          ),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.all(20),
                        child: TextFormField(
                          controller: link,
                          decoration: InputDecoration(
                              labelText: "Links",
                              hintText: "Provide any relevant link to the feed(optional)",
                              errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: BorderSide(color: Colors.redAccent)
                              ),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: BorderSide(color: Colors.blueAccent)
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: BorderSide(color: Colors.redAccent)
                              ),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: BorderSide(color: Colors.grey.shade400)
                              )
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(20),
                        child: TextFormField(
                          controller: description,
                          maxLines: 7,
                          validator: (text){
                            if(text == null || text.isEmpty)
                              return "Field cannot be empty";
                            return null;
                          },
                          decoration: InputDecoration(
                              labelText: "Description",
                              hintText: "Provide description for the post",
                              errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: BorderSide(color: Colors.redAccent)
                              ),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: BorderSide(color: Colors.blueAccent)
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: BorderSide(color: Colors.redAccent)
                              ),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: BorderSide(color: Colors.grey.shade400)
                              )
                          ),
                        ),
                      ),
                      RaisedButton(
                        color: Colors.blueAccent,
                        onPressed: () async {
                          String result = await sendDocument();
                          if(result!=null)
                            {
                              setState(() {
                                poster = result;
                              });
                            }
                        },
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: Text("Upload Image",style: TextStyle(color: Colors.white),),
                        ),
                      ),
                      (poster==null)?Container():CachedNetworkImage(
                        placeholder: (context, url) => Container(
                          child: CircularProgressIndicator(
                          ),
                          width: 200.0,
                          height: 200.0,
                          padding: EdgeInsets.all(70.0),
                        ),
                        errorWidget: (context, url, error) =>
                            Material(
                              child: Container(
                                height: 200,
                                width: 200,
                                child: Center(
                                  child: Icon(Icons.warning,color: Colors.black,size: 100,),
                                ),
                              ),
                              clipBehavior: Clip.hardEdge,
                            ),
                        imageUrl: poster,
                        width: 200.0,
                        height: 200.0,
                        fit: BoxFit.cover,
                      ),
                      RaisedButton(
                        color: Colors.blueAccent,
                        onPressed: () async {
                          if(_formkey.currentState.validate()&&poster!=null){
                            var data;
                            if(widget.userData["role"] == "Club") data = FeedItem(title.text.toString(),widget.userData['username'], poster, description.text.toString(), link.text.toString());
                            else data = FeedItem(title.text.toString(), "Personal", poster, description.text.toString(), link.text.toString());
                            await addDataToFirebase(data);
                            Navigator.pop(context,data);
                          }
                          else if(poster==null){
                            Fluttertoast.showToast(msg: "Please select image");
                          }
                        },
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: Text("Submit",style: TextStyle(color: Colors.white),),
                        ),
                      )
                    ],
                  ),
                )
            ),
          ),
        )
    );

  }
  Future<String> sendDocument() async {
    File documentToUpload;
    documentToUpload = await documentSender();
    if(documentToUpload==null)
      return null;
    else
    {
      String message = await uploadFile(documentToUpload);
      if(message==null)
        return null;
      else
      {
        return message;
      }
    }
  }

  Future<File> documentSender(){
    return FilePicker.getFile();
  }

  Future<String> uploadFile(documentFile) async {
    String imageUrl;
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference reference = FirebaseStorage.instance.ref().child(fileName);
    await reference.putFile(documentFile).then((storageTaskSnapshot) async {
      await storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl){
        imageUrl = downloadUrl;
        print(downloadUrl);
      },onError: (err){
        print(err.toString());
      });
    },onError: (err){
      print("error");
    });
    return imageUrl;
  }
}
