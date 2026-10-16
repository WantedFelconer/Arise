import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../design_system/components/pressable_card.dart';
import '../../network/api_config.dart';

/// Shows an interactive modal dialog allowing the hunter to view, test, and update
/// the backend server gateway address (e.g. Render hosted backend URL).
Future<void> showGatewayConfigDialog(BuildContext context, WidgetRef ref) async {
  await showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (ctx) => const _GatewayConfigDialog(),
  );
}

class _GatewayConfigDialog extends ConsumerStatefulWidget {
  const _GatewayConfigDialog();

  @override
  ConsumerState<_GatewayConfigDialog> createState() => _GatewayConfigDialogState();
}

class _GatewayConfigDialogState extends ConsumerState<_GatewayConfigDialog> {
  late final TextEditingController _urlController;
  bool _isTesting = false;
  String? _testResult;
  bool? _testSuccess;

  @override
  void initState() {
    super.initState();
    final currentUrl = ref.read(apiConfigProvider).baseUrl;
    _urlController = TextEditingController(text: currentUrl);
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _testUplink() async {
    final rawUrl = _urlController.text.trim();
    if (rawUrl.isEmpty) {
      setState(() {
        _testResult = 'Please enter a gateway address';
        _testSuccess = false;
      });
      return;
    }

    final sanitized = ApiConfig.sanitizeBaseUrl(rawUrl);
    // Ping the /health endpoint (which is excluded from /api/v1 prefix)
    final rootHost = sanitized.replaceAll('/api/v1', '');
    final healthEndpoint = '$rootHost/health';

    setState(() {
      _isTesting = true;
      _testResult = 'Pinging $healthEndpoint...\n(Render may take 45-60s to wake up if sleeping)';
      _testSuccess = null;
    });

    try {
      final dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 75),
          receiveTimeout: const Duration(seconds: 75),
        ),
      );
      final response = await dio.get<dynamic>(healthEndpoint);
      if (mounted) {
        setState(() {
          _isTesting = false;
          _testSuccess = response.statusCode == 200;
          _testResult = response.statusCode == 200
              ? '✓ UPLINK ACTIVE (Status: 200 OK)'
              : '⚠ Server returned status ${response.statusCode}';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isTesting = false;
          _testSuccess = false;
          _testResult = '✕ UPLINK FAILED: Connection timed out or unreachable.\nVerify URL and ensure Render instance is live.';
        });
      }
    }
  }

  Future<void> _handleSave() async {
    final rawUrl = _urlController.text.trim();
    if (rawUrl.isEmpty) return;

    final sanitized = ApiConfig.sanitizeBaseUrl(rawUrl);
    await ref.read(apiConfigProvider.notifier).updateBaseUrl(sanitized);

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF0F172A),
          content: Text(
            'SYSTEM GATEWAY UPDATED: $sanitized',
            style: AppTypography.monoStat(fontSize: 11, color: AppColors.manaCyan),
          ),
        ),
      );
    }
  }

  Future<void> _handleReset() async {
    await ref.read(apiConfigProvider.notifier).resetToDefault();
    final defaultUrl = ref.read(apiConfigProvider).baseUrl;
    _urlController.text = defaultUrl;

    setState(() {
      _testResult = 'Reset to system default: $defaultUrl';
      _testSuccess = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentConfig = ref.watch(apiConfigProvider);

    return Dialog(
      backgroundColor: const Color(0xFF0A1224),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.manaCyan, width: 1.2),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.settings_input_antenna, color: AppColors.manaCyan, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'SYSTEM GATEWAY CONFIG',
                    style: AppTypography.orbitron(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      letterSpacing: 0.1,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(Icons.close, size: 18, color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Active Gateway: ${currentConfig.baseUrl}',
              style: AppTypography.monoStat(fontSize: 10, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),

            // Input Field
            Text(
              'HOSTED BACKEND URL (RENDER / CLOUD)',
              style: AppTypography.monoStat(fontSize: 10, color: AppColors.manaCyan),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _urlController,
              style: AppTypography.rajdhani(
                fontSize: 14,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                hintText: 'https://arise-backend.onrender.com/api/v1',
                hintStyle: AppTypography.rajdhani(fontSize: 13, color: AppColors.textDisabled),
                filled: true,
                fillColor: const Color(0xFF030712),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.glassBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.manaCyan, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tip: You can paste your bare Render domain (e.g. https://xyz.onrender.com). The /api/v1 prefix and https:// protocol are attached automatically.',
              style: AppTypography.rajdhani(fontSize: 11, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),

            // Test Ping Box
            if (_isTesting || _testResult != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: _testSuccess == true
                      ? AppColors.terminalGreen.withValues(alpha: 0.1)
                      : _testSuccess == false
                          ? AppColors.dangerRed.withValues(alpha: 0.1)
                          : AppColors.manaCyan.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _testSuccess == true
                        ? AppColors.terminalGreen
                        : _testSuccess == false
                            ? AppColors.dangerRed
                            : AppColors.manaCyan,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_isTesting)
                      const Padding(
                        padding: EdgeInsets.only(right: 8.0, top: 2.0),
                        child: SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.manaCyan,
                          ),
                        ),
                      ),
                    Expanded(
                      child: Text(
                        _testResult ?? '',
                        style: AppTypography.monoStat(
                          fontSize: 10,
                          color: _testSuccess == true
                              ? AppColors.terminalGreen
                              : _testSuccess == false
                                  ? AppColors.dangerRed
                                  : AppColors.manaCyan,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: PressableCard(
                    onTap: _isTesting ? null : _testUplink,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.manaCyan.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.manaCyan),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _isTesting ? 'PINGING...' : 'TEST UPLINK',
                        style: AppTypography.orbitron(fontSize: 10, color: AppColors.manaCyan),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: PressableCard(
                    onTap: _handleSave,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.manaCyan,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'SAVE GATEWAY',
                        style: AppTypography.orbitron(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Center(
              child: TextButton(
                onPressed: _handleReset,
                child: Text(
                  'RESET TO ENVIRONMENT DEFAULT',
                  style: AppTypography.monoStat(fontSize: 9, color: AppColors.textDisabled),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
