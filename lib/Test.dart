import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  String relation1 = '';
  String relation2 = '';
  final TextEditingController nameController1 = TextEditingController();
  final TextEditingController phoneController1 = TextEditingController();
  final TextEditingController nameController2 = TextEditingController();
  final TextEditingController phoneController2 = TextEditingController();

  bool get canSubmit {
    return relation1.isNotEmpty &&
        relation2.isNotEmpty &&
        nameController1.text.trim().isNotEmpty &&
        phoneController1.text.trim().isNotEmpty &&
        nameController2.text.trim().isNotEmpty &&
        phoneController2.text.trim().isNotEmpty;
  }

  void _onTextChanged() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    nameController1.addListener(_onTextChanged);
    phoneController1.addListener(_onTextChanged);
    nameController2.addListener(_onTextChanged);
    phoneController2.addListener(_onTextChanged);
  }

  final List<String> relations = [
    'Parents',
    'Conjoint',
    'Proches',
    'Amis',
    'Collègues',
  ];

  void showRelationPicker(int index) {
    int selectedIndex = relations.indexOf(index == 1 ? relation1 : relation2);
    if (selectedIndex == -1) selectedIndex = 0;
    int tempSelectedIndex = selectedIndex;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Container(
          height: 280,
          padding: const EdgeInsets.only(top: 16),
          child: Column(
            children: [
              // 顶部标题栏
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.close,
                        color: Colors.grey,
                        size: 24,
                      ),
                    ),
                    const Text(
                      'Relation',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          if (index == 1) {
                            relation1 = relations[tempSelectedIndex];
                          } else {
                            relation2 = relations[tempSelectedIndex];
                          }
                        });
                        Navigator.pop(context);
                      },
                      child: const Icon(
                        Icons.check,
                        color: Color(0xFF6B5CE7),
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 16),
              // 滚轮选择器
              Expanded(
                child: CupertinoPicker(
                  scrollController: FixedExtentScrollController(
                    initialItem: selectedIndex,
                  ),
                  itemExtent: 40,
                  onSelectedItemChanged: (int value) {
                    tempSelectedIndex = value;
                  },
                  children: relations.map((relation) {
                    return Center(
                      child: Text(
                        relation,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.black54,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildSection({
    required String number,
    required String relation,
    required TextEditingController nameController,
    required TextEditingController phoneController,
    required int index,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 编号标签
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 6),
          decoration: const BoxDecoration(
            color: Color(0xFF6B5CE7),
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(2),
              topLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
              bottomLeft: Radius.circular(2)
            ),
          ),
          child: Text(
            number,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 20),
        // Relations
        const Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Text(
            'Relations',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: GestureDetector(
            onTap: () => showRelationPicker(index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    relation.isEmpty ? 'Sélectionner' : relation,
                    style: TextStyle(
                      fontSize: 16,
                      color: relation.isEmpty ? Colors.black38 : Colors.black,
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.black54,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        // Un nom
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Un nom',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: nameController,
              decoration: const InputDecoration(
                hintText: 'Veuillez entrer',
                hintStyle: TextStyle(
                  color: Colors.black38,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        // +221
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            '+221',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                hintText: 'portable',
                hintStyle: TextStyle(
                  color: Colors.black38,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Étape 2',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // 第一部分
            buildSection(
              number: '01',
              relation: relation1,
              nameController: nameController1,
              phoneController: phoneController1,
              index: 1,
            ),
            const SizedBox(height: 30),
            // 第二部分
            buildSection(
              number: '02',
              relation: relation2,
              nameController: nameController2,
              phoneController: phoneController2,
              index: 2,
            ),
            const SizedBox(height: 40),
            // 底部按钮
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: canSubmit
                      ? () {
                          // 提交逻辑
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B5CE7),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFF6B5CE7).withOpacity(0.4),
                    disabledForegroundColor: Colors.white.withOpacity(0.6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Après',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController1.dispose();
    phoneController1.dispose();
    nameController2.dispose();
    phoneController2.dispose();
    super.dispose();
  }
}
