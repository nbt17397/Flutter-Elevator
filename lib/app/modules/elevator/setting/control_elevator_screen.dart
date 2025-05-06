import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:elevator/app/data/response/location_response.dart';
import 'package:elevator/app/data/response/request_control_response.dart';
import 'package:elevator/config/shared/colors.dart';

import '../../../services/reporitories/board_repo.dart';

class ControlRequestScreen extends StatefulWidget {
  final BoardDB board;

  const ControlRequestScreen({super.key, required this.board});

  @override
  State<ControlRequestScreen> createState() => _ControlRequestScreenState();
}

class _ControlRequestScreenState extends State<ControlRequestScreen> {
  bool isLoading = false;
  bool isRequesting = false;
  RequestControlResponse? _response;

  @override
  void initState() {
    super.initState();
    _fetchControlRequests();
  }

  Future<void> _fetchControlRequests() async {
    setState(() => isLoading = true);
    try {
      final resp =
          await BoardRepo().getRequestControlByBoardID(id: widget.board.id!);
      setState(() {
        _response = resp;
      });
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _createRequest() async {
    setState(() => isRequesting = true);
    try {
      bool result = await BoardRepo().requestControl(boardId: widget.board.id!);
      if (result) {
        await _fetchControlRequests(); // Reload list
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tạo yêu cầu thành công')),
        );
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => isRequesting = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  String formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr).toLocal();
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  String getStatus(String? dateStr) {
    if (dateStr == null) return 'Không xác định';
    try {
      final expireDate = DateTime.parse(dateStr).toLocal();
      return DateTime.now().isBefore(expireDate) ? 'Còn hiệu lực' : 'Hết hạn';
    } catch (e) {
      return 'Không xác định';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Danh sách yêu cầu'),
        backgroundColor: CustomColors.appbarColor,
        centerTitle: true,
        actions: [
          IconButton(
            icon: isRequesting
                ? CircularProgressIndicator(color: Colors.white)
                : Icon(Icons.add_circle_outline),
            onPressed: isRequesting ? null : _createRequest,
            tooltip: 'Tạo yêu cầu điều khiển',
          )
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bg1.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : _response == null
                ? Center(
                    child: Text("Không có dữ liệu",
                        style: TextStyle(color: Colors.white)))
                : _buildDataTable(),
      ),
    );
  }

  Widget _buildDataTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints:
              BoxConstraints(minWidth: MediaQuery.of(context).size.width),
          child: DataTable(
            columnSpacing: 24,
            headingRowColor:
                MaterialStateColor.resolveWith((states) => Colors.black54),
            columns: const [
              DataColumn(
                  label: Text('Người yêu cầu',
                      style: TextStyle(color: Colors.white))),
              DataColumn(
                  label: Text('Trạng thái',
                      style: TextStyle(color: Colors.white))),
              DataColumn(
                  label:
                      Text('Thời hạn', style: TextStyle(color: Colors.white))),
            ],
            rows: (_response?.results ?? []).map(
              (item) {
                return DataRow(
                  color: MaterialStateColor.resolveWith(
                      (states) => Colors.black38),
                  cells: [
                    DataCell(Text('${item.userName}',
                        style: TextStyle(color: Colors.white))),
                    DataCell(Text(getStatus(item.expiresAt),
                        style: TextStyle(color: Colors.white))),
                    DataCell(Text(formatDate(item.expiresAt),
                        style: TextStyle(color: Colors.white))),
                  ],
                );
              },
            ).toList(),
          ),
        ),
      ),
    );
  }
}
