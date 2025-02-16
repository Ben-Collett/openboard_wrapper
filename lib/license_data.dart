import 'package:openboard_searlizer/_utils.dart';
import 'package:openboard_searlizer/searlizable.dart';

class LicenseData with Searlizable {
  static const typeKey = 'type';
  static const authorNameKey = 'author_name';
  static const authorEmailKey = 'author_email';
  static const authorURLKey = 'author_url';
  static const urlNoticeKey = 'copyright_notice_url';
  static const sourceURLKey = 'source_url';
  String? type;
  String? authorName;
  String? authorEmail;
  String? authorURL;
  String? urlNotice;
  String? sourceURL;

  LicenseData(this.type, this.authorName, this.authorEmail, this.authorURL,
      this.urlNotice, this.sourceURL);

  LicenseData.fromJson(Map<String, dynamic> json) {
    type = json[typeKey]?.toString();
    authorName = json[authorNameKey]?.toString();
    authorEmail = json[authorEmailKey]?.toString();
    authorURL = json[authorURLKey]?.toString();
    urlNotice = json[urlNoticeKey]?.toString();
    sourceURL = json[sourceURLKey]?.toString();
  }

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};

    addToMapIfNotNull(json, typeKey, type);
    addToMapIfNotNull(json, authorNameKey, authorName);
    addToMapIfNotNull(json, authorEmailKey, authorEmail);
    addToMapIfNotNull(json, authorURLKey, authorURL);
    addToMapIfNotNull(json, urlNoticeKey, urlNotice);
    addToMapIfNotNull(json, sourceURLKey, sourceURL);

    return json;
  }
}
