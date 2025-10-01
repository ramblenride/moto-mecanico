enum AttachmentType { file, link, picture }

// Defines a generic attachment.
class Attachment {
  Attachment({
    required this.type,
    required this.url,
    this.name = '',
    this.copyable = false,
  });

  final AttachmentType type;
  final String url;
  String name;
  bool copyable;

  Attachment copyWith({
    AttachmentType? type,
    String? url,
    String? name,
    bool? copyable,
  }) {
    return Attachment(
        type: type ?? this.type,
        url: url ?? this.url,
        name: name ?? this.name,
        copyable: copyable ?? this.copyable);
  }

  factory Attachment.fromJson(Map<String, dynamic> json) {
    if (json['type'] == null || json['url'] == null) {
      throw ArgumentError('Invalid attachment JSON: $json');
    }
    AttachmentType type = AttachmentType.file;
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

    return Attachment(
      type: type,
      url: json['url'],
      name: json['name'],
      copyable: json['copyable'] ?? false,
    );
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
