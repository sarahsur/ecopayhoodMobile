import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../constants/app_colors.dart';
import '../constants/app_textstyle.dart';
import '../models/pickup_completion.dart';
import '../models/pickup_request.dart';
import '../services/collector_service.dart';

class CollectorScanPage extends StatefulWidget {
  const CollectorScanPage({super.key});

  @override
  State<CollectorScanPage> createState() => _CollectorScanPageState();
}

class _CollectorScanPageState extends State<CollectorScanPage> {
  final CollectorService _collectorService = CollectorService();
  final MobileScannerController _scannerController = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  bool _isProcessing = false;
  bool _isTorchOn = false;
  String? _wargaId;
  List<PickupRequest> _pendingRequests = [];
  final Set<String> _selectedRequestIds = {};
  PickupCompletion? _completion;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _handleDetect(BarcodeCapture capture) async {
    if (_isProcessing || _wargaId != null || _completion != null) return;

    String? qrText;
    for (final barcode in capture.barcodes) {
      final rawValue = barcode.rawValue;
      if (rawValue != null && rawValue.trim().isNotEmpty) {
        qrText = rawValue;
        break;
      }
    }

    if (qrText == null || qrText.trim().isEmpty) return;

    setState(() => _isProcessing = true);
    await _scannerController.stop();

    try {
      final wargaId = _collectorService.extractWargaId(qrText);
      if (wargaId == null || wargaId.isEmpty) {
        throw const FormatException('QR warga tidak valid');
      }

      final requests = await _collectorService.getScheduledPickupsByWargaId(
        wargaId,
      );

      if (!mounted) return;
      setState(() {
        _wargaId = wargaId;
        _pendingRequests = requests;
        _selectedRequestIds
          ..clear()
          ..addAll(requests.map((request) => request.id));
      });

      if (requests.isEmpty) {
        _showSnackBar('Tidak ada pengajuan aktif untuk warga ini');
      }
    } catch (error) {
      if (!mounted) return;
      _showSnackBar(error.toString());
      await _scannerController.start();
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _submitSelectedPickups() async {
    final wargaId = _wargaId;
    if (wargaId == null) return;

    if (_selectedRequestIds.isEmpty) {
      _showSnackBar('Pilih minimal satu pengajuan yang dijemput');
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final completion = await _collectorService.completeSelectedPickups(
        wargaId: wargaId,
        requestIds: _selectedRequestIds.toList(),
      );

      if (!mounted) return;
      setState(() => _completion = completion);
      _showSnackBar('${completion.completedCount} pengajuan berhasil dijemput');
    } catch (error) {
      if (!mounted) return;
      _showSnackBar(error.toString());
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _resetScanner() async {
    setState(() {
      _wargaId = null;
      _pendingRequests = [];
      _selectedRequestIds.clear();
      _completion = null;
      _isProcessing = false;
    });
    await _scannerController.start();
  }

  Future<void> _toggleTorch() async {
    await _scannerController.toggleTorch();
    if (!mounted) return;
    setState(() => _isTorchOn = !_isTorchOn);
  }

  void _toggleRequest(String requestId, bool selected) {
    setState(() {
      if (selected) {
        _selectedRequestIds.add(requestId);
      } else {
        _selectedRequestIds.remove(requestId);
      }
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF071B10),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      'Scan QR Warga',
                      textAlign: TextAlign.center,
                      style: AppTextStyle.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _toggleTorch,
                    icon: Icon(
                      _isTorchOn ? Icons.flash_on : Icons.flash_off,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  MobileScanner(
                    controller: _scannerController,
                    onDetect: _handleDetect,
                  ),
                  Container(color: Colors.black.withValues(alpha: 0.18)),
                  const _ScannerFrame(),
                  Positioned(
                    left: 18,
                    right: 18,
                    bottom: 18,
                    child: _ScannerActionPanel(
                      isProcessing: _isProcessing,
                      wargaId: _wargaId,
                      requests: _pendingRequests,
                      selectedRequestIds: _selectedRequestIds,
                      completion: _completion,
                      onToggleRequest: _toggleRequest,
                      onSubmit: _submitSelectedPickups,
                      onRetry: _resetScanner,
                      onSwitchCamera: _scannerController.switchCamera,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScannerFrame extends StatelessWidget {
  const _ScannerFrame();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      height: 260,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.28),
                  width: 1,
                ),
              ),
            ),
          ),
          const _Corner(alignment: Alignment.topLeft),
          const _Corner(alignment: Alignment.topRight),
          const _Corner(alignment: Alignment.bottomLeft),
          const _Corner(alignment: Alignment.bottomRight),
          Center(
            child: Container(
              height: 2,
              margin: const EdgeInsets.symmetric(horizontal: 28),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen,
                borderRadius: BorderRadius.circular(4),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.primaryGreen,
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Corner extends StatelessWidget {
  final Alignment alignment;

  const _Corner({required this.alignment});

  @override
  Widget build(BuildContext context) {
    final isTop = alignment.y < 0;
    final isLeft = alignment.x < 0;

    return Align(
      alignment: alignment,
      child: Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          border: Border(
            top: isTop
                ? const BorderSide(color: Colors.white, width: 5)
                : BorderSide.none,
            bottom: !isTop
                ? const BorderSide(color: Colors.white, width: 5)
                : BorderSide.none,
            left: isLeft
                ? const BorderSide(color: Colors.white, width: 5)
                : BorderSide.none,
            right: !isLeft
                ? const BorderSide(color: Colors.white, width: 5)
                : BorderSide.none,
          ),
          borderRadius: BorderRadius.only(
            topLeft: isTop && isLeft ? const Radius.circular(16) : Radius.zero,
            topRight: isTop && !isLeft
                ? const Radius.circular(16)
                : Radius.zero,
            bottomLeft: !isTop && isLeft
                ? const Radius.circular(16)
                : Radius.zero,
            bottomRight: !isTop && !isLeft
                ? const Radius.circular(16)
                : Radius.zero,
          ),
        ),
      ),
    );
  }
}

class _ScannerActionPanel extends StatelessWidget {
  final bool isProcessing;
  final String? wargaId;
  final List<PickupRequest> requests;
  final Set<String> selectedRequestIds;
  final PickupCompletion? completion;
  final void Function(String requestId, bool selected) onToggleRequest;
  final Future<void> Function() onSubmit;
  final Future<void> Function() onRetry;
  final Future<void> Function() onSwitchCamera;

  const _ScannerActionPanel({
    required this.isProcessing,
    required this.wargaId,
    required this.requests,
    required this.selectedRequestIds,
    required this.completion,
    required this.onToggleRequest,
    required this.onSubmit,
    required this.onRetry,
    required this.onSwitchCamera,
  });

  @override
  Widget build(BuildContext context) {
    final currentCompletion = completion;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.46,
      ),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: currentCompletion != null
          ? _CompletionView(completion: currentCompletion, onRetry: onRetry)
          : wargaId == null
          ? _ScanHintView(
              isProcessing: isProcessing,
              onSwitchCamera: onSwitchCamera,
            )
          : _PickupChecklistView(
              isProcessing: isProcessing,
              requests: requests,
              selectedRequestIds: selectedRequestIds,
              onToggleRequest: onToggleRequest,
              onSubmit: onSubmit,
              onRetry: onRetry,
            ),
    );
  }
}

class _ScanHintView extends StatelessWidget {
  final bool isProcessing;
  final Future<void> Function() onSwitchCamera;

  const _ScanHintView({
    required this.isProcessing,
    required this.onSwitchCamera,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          isProcessing ? 'Mencari pengajuan...' : 'Arahkan kamera ke QR warga',
          textAlign: TextAlign.center,
          style: AppTextStyle.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.darkGreen,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Setelah QR valid, pilih pengajuan mana saja yang benar-benar sudah dijemput.',
          textAlign: TextAlign.center,
          style: AppTextStyle.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Colors.black54,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: isProcessing ? null : onSwitchCamera,
                icon: const Icon(Icons.cameraswitch),
                label: const Text('Ganti Kamera'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.darkGreen,
                ),
              ),
            ),
            if (isProcessing) ...[
              const SizedBox(width: 12),
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _PickupChecklistView extends StatelessWidget {
  final bool isProcessing;
  final List<PickupRequest> requests;
  final Set<String> selectedRequestIds;
  final void Function(String requestId, bool selected) onToggleRequest;
  final Future<void> Function() onSubmit;
  final Future<void> Function() onRetry;

  const _PickupChecklistView({
    required this.isProcessing,
    required this.requests,
    required this.selectedRequestIds,
    required this.onToggleRequest,
    required this.onSubmit,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (requests.isEmpty) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.inventory_2_outlined,
            color: AppColors.darkGreen,
            size: 42,
          ),
          const SizedBox(height: 10),
          Text(
            'Tidak ada pengajuan aktif',
            style: AppTextStyle.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.darkGreen,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Warga ini belum punya request berstatus menunggu dijemput.',
            textAlign: TextAlign.center,
            style: AppTextStyle.poppins(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkGreen,
                foregroundColor: Colors.white,
              ),
              child: const Text('Scan Warga Lain'),
            ),
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Checklist Sampah Dijemput',
          style: AppTextStyle.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.darkGreen,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${selectedRequestIds.length}/${requests.length} pengajuan dipilih',
          style: AppTextStyle.poppins(fontSize: 12, color: Colors.black54),
        ),
        const SizedBox(height: 10),
        Flexible(
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: requests.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final request = requests[index];
              final selected = selectedRequestIds.contains(request.id);

              return InkWell(
                onTap: isProcessing
                    ? null
                    : () => onToggleRequest(request.id, !selected),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.lightGreen
                        : const Color(0xFFF7F7F7),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: selected
                          ? AppColors.primaryGreen
                          : Colors.black.withValues(alpha: 0.06),
                    ),
                  ),
                  child: Row(
                    children: [
                      Checkbox(
                        value: selected,
                        activeColor: AppColors.darkGreen,
                        onChanged: isProcessing
                            ? null
                            : (value) =>
                                  onToggleRequest(request.id, value ?? false),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              request.category,
                              style: AppTextStyle.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.darkGreen,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${request.amount} ${request.unit} - ${_formatDate(request.createdAt)}',
                              style: AppTextStyle.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: isProcessing ? null : onRetry,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.darkGreen,
                ),
                child: const Text('Scan Ulang'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: isProcessing ? null : onSubmit,
                icon: isProcessing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check_circle_outline),
                label: Text(isProcessing ? 'Memproses' : 'Tandai Dijemput'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkGreen,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day/$month ${hour}:${minute}';
  }
}

class _CompletionView extends StatelessWidget {
  final PickupCompletion completion;
  final Future<void> Function() onRetry;

  const _CompletionView({required this.completion, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.check_circle, color: AppColors.primaryGreen, size: 46),
        const SizedBox(height: 10),
        Text(
          'Pickup Selesai',
          style: AppTextStyle.poppins(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: AppColors.darkGreen,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '${completion.completedCount} pengajuan selesai. Warga mendapatkan ${completion.pointsAwarded} poin.',
          textAlign: TextAlign.center,
          style: AppTextStyle.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.darkGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('Dashboard'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('Scan Lagi'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
