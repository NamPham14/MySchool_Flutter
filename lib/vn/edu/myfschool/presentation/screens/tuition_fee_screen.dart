import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controller/misc_providers.dart';
import '../../domain/fee_invoice_model.dart';

class TuitionFeeScreen extends StatefulWidget {
  const TuitionFeeScreen({Key? key}) : super(key: key);

  @override
  State<TuitionFeeScreen> createState() => _TuitionFeeScreenState();
}

class _TuitionFeeScreenState extends State<TuitionFeeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FeeInvoiceProvider>().fetchInvoices();
    });
  }

  String _formatCurrency(double amount) {
    String str = amount.toStringAsFixed(0);
    String result = '';
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      if (count == 3) {
        result = '.' + result;
        count = 0;
      }
      result = str[i] + result;
      count++;
    }
    return "$result VNĐ";
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FeeInvoiceProvider>();

    // Tính tổng số tiền chưa nộp
    double totalUnpaid = 0.0;
    for (var invoice in provider.invoices) {
      if (invoice.status == 'UNPAID') {
        totalUnpaid += invoice.amount;
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F3F0),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF7A3D)))
                  : RefreshIndicator(
                      color: const Color(0xFFFF7A3D),
                      onRefresh: () async {
                        await context.read<FeeInvoiceProvider>().fetchInvoices();
                      },
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),
                            _buildSummaryCard(totalUnpaid),
                            const SizedBox(height: 24),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                "Chi tiết học phí",
                                style: TextStyle(color: Color(0xFF2D2D2D), fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildInvoiceList(provider.invoices),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Color(0xFF2D2D2D)),
            onPressed: () => Navigator.pop(context),
          ),
          const Text(
            'Học Phí',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF2D2D2D)),
          ),
          const SizedBox(width: 48), // Balance for centering
        ],
      ),
    );
  }

  Widget _buildSummaryCard(double totalUnpaid) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF7A3D), Color(0xFFFF9D66)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF7A3D).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Tổng số tiền cần nộp",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            _formatCurrency(totalUnpaid),
            style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: totalUnpaid > 0 ? () {
                    // Xử lý thanh toán tại đây
                  } : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFFFF7A3D),
                    disabledBackgroundColor: Colors.white.withOpacity(0.5),
                    disabledForegroundColor: Colors.grey,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(totalUnpaid > 0 ? "Thanh toán ngay" : "Đã hoàn thành", style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildInvoiceList(List<FeeInvoiceModel> invoices) {
    if (invoices.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text("Không có dữ liệu học phí.", style: TextStyle(color: Color(0xFF9E9E9E))),
        ),
      );
    }

    return Column(
      children: invoices.map((invoice) {
        final isPaid = invoice.status == 'PAID';
        final statusText = isPaid ? "Đã nộp" : "Chưa nộp";
        final statusColor = isPaid ? const Color(0xFF4CAF50) : const Color(0xFFFF4D4F);
        final statusBg = isPaid ? const Color(0xFFD4F5DD) : const Color(0xFFFFEDED);

        return Container(
          margin: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 3)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      invoice.title,
                      style: const TextStyle(color: Color(0xFF2D2D2D), fontSize: 15, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(color: Color(0xFFEEEEEE), height: 1),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Kỳ học:", style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 13)),
                  Text(
                    invoice.semesterName ?? "Chưa rõ",
                    style: const TextStyle(color: Color(0xFF2D2D2D), fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Số tiền:", style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 13)),
                  Text(
                    _formatCurrency(invoice.amount),
                    style: const TextStyle(color: Color(0xFFFF7A3D), fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Hạn nộp:", style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 13)),
                  Text(
                    invoice.dueDate,
                    style: const TextStyle(color: Color(0xFF2D2D2D), fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
