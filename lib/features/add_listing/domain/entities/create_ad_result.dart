import 'package:equatable/equatable.dart';

class CreateAdResult extends Equatable {
  const CreateAdResult({required this.slug});

  final String slug;

  @override
  List<Object?> get props => [slug];
}
