import 'package:flutter/material.dart';

import '../services/api_service.dart';

typedef ApiResponseButtonBuilder =
    Widget Function(
      BuildContext context,
      bool isLoading,
      VoidCallback? onPressed,
    );

class ApiResponseAction extends StatefulWidget {
  const ApiResponseAction({
    super.key,
    required this.status,
    required this.route,
    required this.builder,
  });

  final String status;
  final String route;
  final ApiResponseButtonBuilder builder;

  @override
  State<ApiResponseAction> createState() => _ApiResponseActionState();
}

class _ApiResponseActionState extends State<ApiResponseAction> {
  bool _isLoading = false;

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    try {
      await ApiService.instance.kirimRespons(widget.status);
      if (mounted) Navigator.pushNamed(context, widget.route);
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) => widget.builder(
    context,
    _isLoading,
    _isLoading ? null : _submit,
  );
}
