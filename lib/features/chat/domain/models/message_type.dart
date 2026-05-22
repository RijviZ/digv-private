enum MessageType {
  text,
  image,
  link,
  video,
  audio;

  static MessageType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'image':
        return MessageType.image;
      case 'link':
        return MessageType.link;
      case 'video':
        return MessageType.video;
      case 'audio':
        return MessageType.audio;
      case 'text':
      default:
        return MessageType.text;
    }
  }

  String toJson() => name;
}
