// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quote.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Quote _$QuoteFromJson(Map<String, dynamic> json) {
  return Quote(
    json['id'] as int,
    json['content'] as String,
    isBookmarked: json['isBookmarked'] as bool,
  );
}

Map<String, dynamic> _$QuoteToJson(Quote instance) => <String, dynamic>{
      'id': instance.id,
      'content': instance.content,
      'isBookmarked': instance.isBookmarked,
    };
