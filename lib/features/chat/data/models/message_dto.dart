import 'package:json_annotation/json_annotation.dart';

part 'message_dto.g.dart';

@JsonSerializable()
class MessageDto {
  final int id;
  @JsonKey(name: 'sender_id')
  final dynamic senderId;
  final String content;
  @JsonKey(name: 'created_at')
  final String createdAt;
  @JsonKey(name: 'is_read')
  final bool? isRead;
  @JsonKey(name: 'file_url')
  final String? fileUrl;

  MessageDto({
    required this.id,
    this.senderId,
    required this.content,
    required this.createdAt,
    this.isRead,
    this.fileUrl,
  });

  factory MessageDto.fromJson(Map<String, dynamic> json) => _$MessageDtoFromJson(json);
  Map<String, dynamic> toJson() => _$MessageDtoToJson(this);
}

@JsonSerializable()
class MessagePaginationDto {
  final List<MessageDto> results;
  final int? count;
  final String? next;
  final String? previous;

  MessagePaginationDto({required this.results, this.count, this.next, this.previous});

  factory MessagePaginationDto.fromJson(Map<String, dynamic> json) => _$MessagePaginationDtoFromJson(json);
  Map<String, dynamic> toJson() => _$MessagePaginationDtoToJson(this);
}
