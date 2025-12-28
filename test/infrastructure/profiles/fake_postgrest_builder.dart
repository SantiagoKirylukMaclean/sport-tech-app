
import 'dart:async';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Create a Fake that implements both PostgrestTransformBuilder and Future
class FakePostgrestTransformBuilder<T> extends Fake implements PostgrestTransformBuilder<T> {
  final T _value;

  FakePostgrestTransformBuilder(this._value);

  @override
  Future<R> then<R>(FutureOr<R> Function(T value) onValue, {Function? onError}) {
    return Future.value(_value).then(onValue, onError: onError);
  }
}
