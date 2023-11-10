import 'package:flutter/material.dart';

class AllAch extends StatefulWidget {
  const AllAch({Key? key}) : super(key: key);

  @override
  _AllAchState createState() => _AllAchState();
}

class _AllAchState extends State<AllAch> {
  String selectedSort = "Achieved time";
  String selectDirection = "ASC";
  String nameSearchQuary = "";
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Wrap(
          spacing: 1.5,
          children: [
            TextField(
              onChanged: (String value){
                setState(() {
                  nameSearchQuary = value;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Search name',
              ),
            ),
            DropdownButton<String>(
              value: selectedSort,
              onChanged: (String? newValue) {
                setState(() {
                  selectedSort = newValue!;
                });
              },
              items: <String>[
                'Name',
                'Percent',
                'GameName',
                'Achieved time',
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(
                width: 60,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        selectDirection == "ASC"
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        size: 20,
                      ),
                    ],
                  ),
                ))
          ],
        )
      ],
    );
  }
}
