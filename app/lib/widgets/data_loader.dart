import 'package:flutter/material.dart';

import '../services/api_client.dart';
import 'state_views.dart';
import 'toast.dart';

/// Loads data from the server and shows the right thing:
///  - a spinner while loading,
///  - an error view with a Retry button (including "server is off"),
///  - or the data via [builder].
///
/// Change [refreshKey] to load again (the old data stays visible meanwhile).
/// The [reload] function given to [builder] is for pull-to-refresh.
class DataLoader<T> extends StatefulWidget {
  const DataLoader({
    super.key,
    required this.load,
    required this.builder,
    this.refreshKey,
  });

  final Future<T> Function() load;
  final Widget Function(BuildContext context, T data, Future<void> Function() reload) builder;
  final Object? refreshKey;

  @override
  State<DataLoader<T>> createState() => _DataLoaderState<T>();
}

class _DataLoaderState<T> extends State<DataLoader<T>> {
  T? _data;
  bool _hasData = false;
  bool _loading = true;
  Object? _error;
  int _sequence = 0;

  @override
  void initState() {
    super.initState();
    _run();
  }

  @override
  void didUpdateWidget(DataLoader<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshKey != widget.refreshKey) {
      if (!_hasData) {
        _loading = true;
        _error = null;
      }
      _run();
    }
  }

  Future<void> _run() async {
    final sequence = ++_sequence;
    try {
      final result = await widget.load();
      if (!mounted || sequence != _sequence) return;
      setState(() {
        _data = result;
        _hasData = true;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted || sequence != _sequence) return;
      if (_hasData) {
        // Keep showing the old data, just tell the user the refresh failed.
        setState(() => _loading = false);
        showToast(e is ApiException ? e.message : 'Could not refresh. Please try again.', error: true);
      } else {
        setState(() {
          _error = e;
          _loading = false;
        });
      }
    }
  }

  void _retry() {
    setState(() {
      _loading = true;
      _error = null;
    });
    _run();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasData) return widget.builder(context, _data as T, _run);
    if (_error != null && !_loading) return ErrorView(error: _error!, onRetry: _retry);
    return const LoadingView();
  }
}
