import 'dart:convert';
import 'package:boox_mobile/models/reply.dart';
import 'package:boox_mobile/models/review.dart';
import 'package:boox_mobile/models/user.dart';
import 'package:boox_mobile/screens/show_review.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


Future<List<Reply>> fetchReplies(int idReview) async {
  final response = await http.get(Uri.parse('https://boox-b09-tk.pbp.cs.ui.ac.id/editreview/get-reply/$idReview/'));

  if (response.statusCode == 200) {
    // Konversi response JSON menjadi daftar objek Reply
    return replyFromJson(response.body);
  } else {
    throw Exception('Failed to load replies');
  }
}



void bottomReply(BuildContext context, int idReview, List<dynamic> replies) {
  TextEditingController replyController = TextEditingController();
  String currentUsername = User.username;

  showModalBottomSheet(
    isScrollControlled: true,
    context: context,
    builder: (BuildContext bc) {
      return Container(
        color: Colors.black87,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'View Reply',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              SizedBox(height: 10),
              // Gunakan Expanded untuk list agar mengambil ruang tersisa di Column
              Expanded(
                child: SingleChildScrollView(
                  child: ListBody(
                    children: replies.map<Widget>((reply) {
                      // Pastikan untuk menangani null dengan memberikan nilai default atau kondisional
                      String username = reply.fields.username.isEmpty ? 'Unknown user' : reply.fields.username;
                      String text = reply.fields.reply.isEmpty ? 'No content' : reply.fields.reply;

                      return Card(
                        color: Colors.grey[850],
                        child: ListTile(
                          leading: Icon(Icons.account_circle, color: Colors.white),
                          title: Text(username, style: TextStyle(color: Colors.white)),
                          subtitle: Text(text, style: TextStyle(color: Colors.white)),
                          trailing: reply.fields.username == currentUsername
                              ? IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () async {
                                    bool shouldDelete = await showDeleteConfirmationDialog(context);
                                    if (shouldDelete) {
                                      bool success = await deleteReply(reply.pk);
                                      if (success) {
                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                          content: Text("Review deleted successfully"),
                                          backgroundColor: Colors.green,
                                        ));

                                        Navigator.of(context).pop();
                                        showReplyBottomSheet(context, idReview);

                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                          content: Text("Failed to delete review"),
                                          backgroundColor: Colors.red,
                                        ));
                                      }
                                    }
                                  },
                                )
                              : SizedBox.shrink(), // Tidak menampilkan apa-apa jika bukan pengguna yang membalas
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              TextField(
                style: TextStyle(color: Colors.white),
                controller: replyController, 
                decoration: InputDecoration(
                  hintText: 'Add your reply here...',
                  hintStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder(),
                ),
                minLines: 3,
                maxLines: 5,
              ),
              SizedBox(height: 10),
              ElevatedButton(
                child: Text(
                  'Add Reply',
                  style: TextStyle(color: Color(0xFFFFFFFF)),
                ),
                style: ElevatedButton.styleFrom(
                  primary: Color(0xFFD85EA9),
                  onPrimary: Color(0xFFFFFFFF),
                ),
                onPressed: () async {
                  String replyText = replyController.text;
                  bool success = await addReply(idReview, replyText);
                  if (success) {
                    // Tutup bottom sheet saat ini
                    Navigator.of(context).pop();
                    // Tampilkan bottom sheet dengan data yang diperbarui
                    showReplyBottomSheet(context, idReview);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Reply submission failed'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
              )
            ],
          ),
        ),
      );
    },
  );
}

void showReplyBottomSheet(BuildContext context, int idReview) async {
  try {
    List<dynamic> replies = await fetchReplies(idReview);
    for (var reply in replies) {
      String username = await fetchUsernameForReview(reply.fields.user);
      reply.fields.username = username;
    }

    bottomReply(context, idReview, replies);
    
  } catch (e) {
    // Handle error, misalnya menampilkan dialog error atau snackbar
    print('Error fetching replies: $e');
  }
}

Future<bool> addReply(int reviewId, String replyText) async {
  final url = Uri.parse('https://boox-b09-tk.pbp.cs.ui.ac.id/editreview/add-reply/${User.username}/');
  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Accept': 'application/json',
    },
    body: {
      'id': reviewId.toString(),
      'reply': replyText, // Tambahkan teks reply
    },
  );

  if (response.statusCode == 200) {
    // Mengubah respons menjadi JSON dan melakukan sesuatu dengan itu jika perlu
    var jsonResponse = jsonDecode(response.body);
    // Contoh: memeriksa status dalam respons JSON
    if (jsonResponse['status'] == 'success') {
      return true;
    }
    return false;
  } else {
    // Jika server mengembalikan respon yang bukan status 200 OK, tampilkan error
    throw Exception('Failed to add reply: ${response.body}');
  }
}

Future<bool> deleteReply(int idReply) async {
  var url = Uri.parse('https://boox-b09-tk.pbp.cs.ui.ac.id/editreview/delete-reply/${User.username}/');

  try {
    var response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Failed to delete review: ${response.body}');
      return false;
    }
  } catch (e) {
    print('Error deleting review: $e');
    return false;
  }
}