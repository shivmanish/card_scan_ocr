import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../error/failures.dart';
import '../usecases/usecase.dart';

/// Base [Cubit] used by every feature cubit in the app.
///
/// Provides:
///  - [safeEmit] — emits only while the cubit is still open, avoiding
///    "Cannot emit after close" exceptions when the screen pops mid-async.
///  - [handleUseCase] — optional helper that runs the cubit's [useCase] with
///    the given params and dispatches the outcome via [onFailure] / [onSuccess].
///    Cubits that don't have a usecase (or want to invoke multiple) can simply
///    ignore it and call usecases directly.
///
/// Generic params:
///  - [S] cubit state.
///  - [T] use-case response data.
///  - [P] use-case params.
abstract class BaseCubit<S, T, P> extends Cubit<S> {
  BaseCubit({required S initialState, this.useCase}) : super(initialState);

  final UseCase<T, P>? useCase;

  @protected
  void safeEmit(S next) {
    if (!isClosed) emit(next);
  }

  Future<void> handleUseCase(
    P params, {
    required FutureOr<void> Function(Failure failure) onFailure,
    required FutureOr<void> Function(T data) onSuccess,
  }) async {
    if (useCase == null) return;

    final result = await useCase!.call(params);
    if (isClosed) return;

    await result.fold<Future<void>>(
      (failure) async => await onFailure(failure),
      (data) async => await onSuccess(data),
    );
  }
}
