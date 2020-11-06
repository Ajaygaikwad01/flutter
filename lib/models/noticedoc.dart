class OurNoticeDoc {
  String id;
  String name;

  String noticetype;
  String subject;
  String description;

  List<String> fileurl;
  List<String> filenames;
  OurNoticeDoc({
    this.id,
    this.name,
    this.noticetype,
    this.subject,
    this.description,
    this.fileurl,
    this.filenames,
  });
}
