class Comments {
  String parentcmtid;
  String replytoname;
  bool isreply;
  String commentid;
  DateTime time;
  String text;
  String userid;
  String username;
  String profilepicurl;
  bool likes;
  int likesno;

  Comments(
      {this.parentcmtid,
      this.replytoname,
      this.isreply,
      this.likesno,
      this.likes,
      this.commentid,
      this.userid,
      this.time,
      this.profilepicurl,
      this.text,
      this.username});
}
