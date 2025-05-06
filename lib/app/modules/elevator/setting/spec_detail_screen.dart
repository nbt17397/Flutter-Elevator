import 'package:flutter/material.dart';
import 'package:elevator/app/data/response/tag_response.dart';
import 'package:elevator/app/services/reporitories/tag_repo.dart';
import 'package:elevator/config/shared/colors.dart';

class SpecDetailScreen extends StatefulWidget {
  const SpecDetailScreen({Key? key}) : super(key: key);

  @override
  SpecDetailScreenState createState() => SpecDetailScreenState();
}

class SpecDetailScreenState extends State<SpecDetailScreen> {
  List<TagDB> tags = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchTags();
  }

  Future<void> fetchTags() async {
    try {
      final repo = TagRepo();
      final TagResponse response = await repo.getTags();
      setState(() {
        tags = response.results ?? [];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  List<Map<String, String>> get tagList => tags.map((tag) {
        // Trả về Map với các giá trị non-nullable
        return {
          'tagCode': tag.tagCode ??
              '', // Nếu tagCode là null, thay thế bằng chuỗi rỗng
          'tagName': tag.tagName ??
              '', // Nếu tagName là null, thay thế bằng chuỗi rỗng
          'maxValue': tag.maxValue?.toString() ??
              '', // Nếu maxValue là null, thay thế bằng chuỗi rỗng
          'minValue': tag.minValue?.toString() ??
              '', // Nếu minValue là null, thay thế bằng chuỗi rỗng
          'description': tag.description ??
              '', // Nếu description là null, thay thế bằng chuỗi rỗng
        };
      }).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tài liệu'),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Builder(
                  builder: (_) {
                    if (isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    } else if (errorMessage.isNotEmpty) {
                      return Center(
                        child: Text(
                          'Lỗi: $errorMessage',
                          style:
                              const TextStyle(color: Colors.red, fontSize: 16),
                        ),
                      );
                    } else if (tagList.isEmpty) {
                      return const Center(
                        child: Text(
                          'Không có dữ liệu lỗi.',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      );
                    }

                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: DataTable(
                          headingRowColor: MaterialStateColor.resolveWith(
                              (_) => Colors.black54),
                          columns: const [
                            DataColumn(
                              label: Text('Mã',
                                  style: TextStyle(color: Colors.white)),
                            ),
                            DataColumn(
                              label: Text('Tên',
                                  style: TextStyle(color: Colors.white)),
                            ),
                            DataColumn(
                              label: Text('Giá trị tối đa',
                                  style: TextStyle(color: Colors.white)),
                            ),
                            DataColumn(
                              label: Text('Giá trị tối thiểu',
                                  style: TextStyle(color: Colors.white)),
                            ),
                            DataColumn(
                              label: Text('Mô tả',
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ],
                          rows: tagList.map((tag) {
                            return DataRow(cells: [
                              DataCell(Text(tag['tagCode']!,
                                  style: const TextStyle(color: Colors.white))),
                              DataCell(Text(tag['tagName']!,
                                  style: const TextStyle(color: Colors.white))),
                              DataCell(Text(tag['maxValue']!,
                                  style: const TextStyle(color: Colors.white))),
                              DataCell(Text(tag['minValue']!,
                                  style: const TextStyle(color: Colors.white))),
                              DataCell(Text(tag['description']!,
                                  style: const TextStyle(color: Colors.white))),
                            ]);
                          }).toList(),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
