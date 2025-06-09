import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:elevator/app/data/response/historical_data_response.dart';
import 'package:elevator/app/services/reporitories/historical_data_repo.dart';
import 'package:elevator/config/shared/colors.dart';

class AlarmElevatorScreen extends StatefulWidget {
  final int registerID;
  const AlarmElevatorScreen({Key? key, required this.registerID})
      : super(key: key);

  @override
  _AlarmElevatorScreenState createState() => _AlarmElevatorScreenState();
}

class _AlarmElevatorScreenState extends State<AlarmElevatorScreen> {
  final Map<int, String> errorDescriptions = {
    0: 'Bảo trì',
    1: 'Tự học hành trình',
    2: 'Chạy về tầng',
    3: 'Chữa cháy quay về trạm gốc',
    4: 'Lính cứu hỏa chạy',
    5: 'Thất bại',
    6: 'Lái xe',
    7: 'Tự động',
    8: 'Khóa thang',
    9: 'Thang đậu xe miễn phí',
    10: 'Tốc độ quay trở lại lớp cân bằng thấp',
    11: 'Chạy giải cứu',
    12: 'Điều chỉnh động cơ',
    13: 'Điều khiển bàn phím',
    14: 'Xác minh trạm gốc',
    15: 'Trạng thái VIP',
    16: 'Điện khẩn cấp',
  };

  // 2. Formatter cho timestamp
  final DateFormat _formatter = DateFormat('HH:mm:ss dd/MM/yyyy');

  List<HistoricalData> historicalData = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchHistoricalData();
  }

  Future<void> fetchHistoricalData() async {
    try {
      final repo = HistoricalDataRepo();
      // Giả sử phương thức trả về List<HistoricalData>
      final List<HistoricalData> response =
          await repo.getHistoricalDataByRegisterID(id: widget.registerID);
      setState(() {
        historicalData = response;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  List<Map<String, String>> get alarmList {
    // Sắp xếp dữ liệu theo timestamp giảm dần
    List<HistoricalData> sortedData = [...historicalData];
    sortedData.sort((a, b) {
      final dtA = DateTime.tryParse(a.timestamp ?? '') ?? DateTime(1970);
      final dtB = DateTime.tryParse(b.timestamp ?? '') ?? DateTime(1970);
      return dtB.compareTo(dtA); // Giảm dần
    });

    return sortedData
        .where((item) => item.value != null && item.timestamp != null)
        .map((item) {
      DateTime? dt = DateTime.tryParse(item.timestamp!);
      String formattedTime = dt != null ? _formatter.format(dt) : '';
      String desc = errorDescriptions[item.value!] ?? '';
      return {
        'value': item.value.toString(),
        'time': formattedTime,
        'description': desc,
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông báo'),
        backgroundColor: CustomColors.appbarColor,
        centerTitle: true,
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
        // child: Column(
        //   crossAxisAlignment: CrossAxisAlignment.start,
        //   children: [
        //     const Text(
        //       'Danh sách lỗi thang máy',
        //       style: TextStyle(
        //         fontSize: 18,
        //         fontWeight: FontWeight.bold,
        //         color: Colors.white,
        //       ),
        //     ),
        //     const SizedBox(height: 10),
        //     Expanded(
        //       child: Container(
        //         padding: const EdgeInsets.all(8),
        //         decoration: BoxDecoration(
        //           color: Colors.black.withOpacity(0.6),
        //           borderRadius: BorderRadius.circular(6),
        //         ),
        //         child: Builder(
        //           builder: (_) {
        //             if (isLoading) {
        //               return const Center(
        //                 child: CircularProgressIndicator(color: Colors.white),
        //               );
        //             } else if (errorMessage.isNotEmpty) {
        //               return Center(
        //                 child: Text(
        //                   'Lỗi: $errorMessage',
        //                   style:
        //                       const TextStyle(color: Colors.red, fontSize: 16),
        //                 ),
        //               );
        //             } else if (alarmList.isEmpty) {
        //               return const Center(
        //                 child: Text(

        //                   'Không có dữ liệu lỗi.',
        //                   style: TextStyle(color: Colors.white, fontSize: 16),
        //                 ),
        //               );
        //             }

        //             return SingleChildScrollView(
        //               scrollDirection: Axis.horizontal,
        //               child: SingleChildScrollView(
        //                 scrollDirection: Axis.vertical,
        //                 child: DataTable(
        //                   headingRowColor: MaterialStateColor.resolveWith(
        //                       (_) => Colors.black54),
        //                   columns: const [
        //                     // DataColumn(
        //                     //   label: Text('Mã lỗi',
        //                     //       style: TextStyle(color: Colors.white)),
        //                     // ),
        //                     DataColumn(
        //                       label: Text('Mô tả',
        //                           style: TextStyle(color: Colors.white)),
        //                     ),
        //                     DataColumn(
        //                       label: Text('Thời gian',
        //                           style: TextStyle(color: Colors.white)),
        //                     ),
        //                   ],
        //                   rows: alarmList.map((alarm) {
        //                     return DataRow(cells: [
        //                       // DataCell(Text(alarm['value']!,
        //                       //     style: const TextStyle(color: Colors.white))),
        //                       DataCell(Text(alarm['description']!,
        //                           style: const TextStyle(color: Colors.white))),
        //                       DataCell(Text(alarm['time']!,
        //                           style: const TextStyle(color: Colors.white))),
        //                     ]);
        //                   }).toList(),
        //                 ),
        //               ),
        //             );
        //           },
        //         ),
        //       ),
        //     ),
        //   ],
        // ),
      ),
    );
  }
}
