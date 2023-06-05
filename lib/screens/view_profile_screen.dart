// ignore_for_file: use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:letschat/helpers/my_date_util.dart';
import 'package:letschat/models/chat_user.dart';
import '../main.dart';

// view profile screen to view profile of the user

class ViewProfileScreen extends StatefulWidget {
  final ChatUser user;

  const ViewProfileScreen({super.key, required this.user});

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
          appBar: AppBar(
            title: Text(widget.user.name),
          ),
          floatingActionButton: // user about
              Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Joined on: ",
                  style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w700,
                      fontSize: 16)),
              Text(
                MyDateUtil.getLastMessageTime(
                    context: context,
                    time: widget.user.createdAt,
                    showYear: true),
                style: const TextStyle(color: Colors.black87, fontSize: 16),
              ),
            ],
          ),
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: mq.width * 0.05),
            child: SingleChildScrollView(
              child: Column(children: [
                // for adding  some space
                SizedBox(width: mq.width, height: mq.height * 0.03),
                // user profile picture
                ClipRRect(
                  borderRadius: BorderRadius.circular(mq.height * 0.3),
                  child: CachedNetworkImage(
                    width: mq.height * 0.2,
                    height: mq.height * 0.2,
                    fit: BoxFit.fill,
                    imageUrl: widget.user.image,
                    // placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) =>
                        const CircleAvatar(child: Icon(CupertinoIcons.person)),
                  ),
                ),

                // for adding  some space
                SizedBox(width: mq.width, height: mq.height * 0.03),
                // user email label
                Text(
                  widget.user.email,
                  style: const TextStyle(color: Colors.black87, fontSize: 16),
                ),
                // for adding  some space
                SizedBox(width: mq.width, height: mq.height * 0.02),

                // user about
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("About: ",
                        style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w700,
                            fontSize: 16)),
                    Text(
                      widget.user.about,
                      style:
                          const TextStyle(color: Colors.black87, fontSize: 16),
                    ),
                  ],
                ),
                // for adding  some space
                SizedBox(width: mq.width, height: mq.height * 0.05),
              ]),
            ),
          )),
    );
  }
}
