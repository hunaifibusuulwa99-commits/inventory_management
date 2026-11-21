import 'dart:async';

/// Runs two requests at the same time. If one fails, the original error is rethrown
/// (so the app can still tell "server off" apart from other errors).
Future<(A, B)> both<A, B>(Future<A> a, Future<B> b) async {
  final results = await Future.wait<Object?>([a, b]);
  return (results[0] as A, results[1] as B);
}
