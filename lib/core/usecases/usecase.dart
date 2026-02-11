import 'package:uz_xarid/core/error/failures.dart';

/// Base class for all use cases in Clean Architecture (DDD style).
///
/// Usage:
/// - Create a subclass per use case, e.g. `GetProducts`.
/// - Implement [call] and return either data `T` or throw/handle [Failure].
abstract class UseCase<T, Params> {
  Future<T> call(Params params);
}

/// Empty params for use cases that don't need input.
class NoParams {
  const NoParams();
}

