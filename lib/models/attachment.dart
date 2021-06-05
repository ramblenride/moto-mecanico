import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

enum AttachmentType { file, link, picture }

// Defines a generic attachment.
class Attachment {
  Attachment({
    @required this.type,
    @required this.url,
    this.name,
    this.copyable = false,
  })  : assert(type != null),
        assert(url != null);

  final AttachmentType type;
  final String url;
  String name;
  bool copyable;

  factory Attachment.from(Attachment attachment) {
    return Attachment(
      type: attachment.type,
      url: attachment.url,
      name: attachment.name,
      copyable: attachment.copyable,
    );
  }

  factory Attachment.fromJson(Map<String, dynamic> json) {
    if (json['type'] != null && json['url'] != null) {
      var type;
      switch (json['type']) {
        case 'file':
          type = AttachmentType.file;
          break;
        case 'link':
          type = AttachmentType.link;
          break;
        case 'picture':
          type = AttachmentType.picture;
          break;
      }

      if (type != null) {
        return Attachment(
          type: type,
          url: json['url'],
          name: json['name'],
          copyable: json['copyable'] ?? false,
        );
      }
    }

    return null;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['name'] = name;
    data['url'] = url;
    data['copyable'] = copyable;

    switch (type) {
      case AttachmentType.file:
        {
          data['type'] = 'file';
          break;
        }
      case AttachmentType.link:
        {
          data['type'] = 'link';
          break;
        }
      case AttachmentType.picture:
        {
          data['type'] = 'picture';
          break;
        }
    }

    return data;
  }
}
