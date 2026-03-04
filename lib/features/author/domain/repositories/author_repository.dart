import 'package:uz_xarid/features/author/domain/entities/author_entity.dart';

abstract class AuthorRepository {
  Future<AuthorEntity> getAuthorAds({required int userId, required int page});
}
