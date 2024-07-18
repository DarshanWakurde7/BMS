import 'package:bms/ApiCalls/apiCalls.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:html/parser.dart' show parse;

class CommentPage extends StatefulWidget {
  final int accid, projectId, projecttaskid, created_by;
  final bool showProject;

  CommentPage({
    required this.accid,
    required this.projectId,
    required this.projecttaskid,
    required this.created_by,
    required this.showProject,
  });

  @override
  State<StatefulWidget> createState() {
    return CommentPageState();
  }
}

class CommentPageState extends State<CommentPage> {
  var commentName = TextEditingController();
  var bottomscroll = ScrollController();

  @override
  void initState() {
    getAllData();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    myComment.clear();
  }

  void getAllData() async {
    if (!widget.showProject) {
      await ApiCalls.getComments(
          widget.accid, widget.projectId, widget.projecttaskid);
    } else {
      await ApiCalls.getProjectComment(widget.accid, widget.projectId);
    }
    setState(() {
      myComment;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Comment Log',
          style: GoogleFonts.lato(fontSize: 24, fontWeight: FontWeight.w400),
        ),
      ),
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height - 190,
                color: Colors.transparent,
                child: RefreshIndicator(
                  onRefresh: () async {
                    getAllData();
                  },
                  child: ListView.builder(
                    itemCount: myComment.length,
                    reverse: true,
                    controller: bottomscroll,
                    itemBuilder: (context, index) {
                      return ChatMessageWidget(
                        username: myComment[index].createdFname ?? "No Name",
                        message: myComment[index].message ?? "",
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(2),
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                        child: TextField(
                          controller: commentName,
                          decoration: InputDecoration(
                            isDense: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            hintText: 'Text here',
                            suffixIcon: IconButton(
                              icon: Icon(Icons.clear),
                              onPressed: () {
                                commentName.clear();
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        String message = commentName.text;
                        SharedPreferences pref =
                            await SharedPreferences.getInstance();
                        bottomscroll.animateTo(
                          bottomscroll.position.minScrollExtent,
                          duration: Duration(milliseconds: 500),
                          curve: Curves.easeOut,
                        );
                        await ApiCalls.postComment(
                          widget.accid,
                          widget.projectId,
                          widget.projecttaskid,
                          widget.created_by,
                          message,
                          pref.getInt('user_id') ?? 0,
                        );
                        getAllData();
                        commentName.clear();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.all(16),
                        child: Icon(
                          Icons.send,
                          color: Colors.white,
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class ChatMessageWidget extends StatelessWidget {
  const ChatMessageWidget({
    required this.username,
    required this.message,
    super.key,
  });

  final String username;
  final String message;

  @override
  Widget build(BuildContext context) {
    var document = parse(message);
    String parsedMessage = parse(document.body!.text).documentElement!.text;

    List<String> splitMessage(String message) {
      return message.split(RegExp(r'[\r\n]+'));
    }

    List<String> lines = splitMessage(parsedMessage);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Card(
        elevation: 3,
        margin: EdgeInsets.symmetric(vertical: 5),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.black,
                    child: Text(
                      username[0],
                      style: GoogleFonts.lato(color: Colors.white),
                    ),
                    radius: 20,
                  ),
                  SizedBox(width: 10),
                  Text(
                    username,
                    style: GoogleFonts.lato(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: Colors.blueAccent,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: lines
                    .map((line) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '• ',
                                style: GoogleFonts.lato(),
                              ),
                              Expanded(
                                child: Text(
                                  line.trim(),
                                  style: GoogleFonts.lato(),
                                  textAlign: TextAlign.left,
                                  softWrap: true,
                                  overflow: TextOverflow.visible,
                                ),
                              ),
                            ],
                          ),
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
