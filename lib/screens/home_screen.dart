import 'package:easy_loading_button/easy_loading_button.dart';
import 'package:flutter/material.dart';
import 'package:polygonic/screens/map_screen.dart';
import 'package:polygonic/utilities/constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<List<double>> recordedPoints = [];

  //function to add recorded points to a list
  void addPoint() async {
    //call the geolocator
    String location = await kLocator.getPosition();
    //convert the location to a list
    List<double> locationList = location.split(',').map(double.parse).toList();

    //add the list to the list of recorded points
    setState(() {
      recordedPoints.add(locationList);
    });
    print(locationList);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text('Garden tracking'),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        color: Colors.teal,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.network(
                  'https://kijaniforestry.com/wp-content/uploads/2019/03/cropped-Kijani_Logo_BW_Circle-03.png',
                  width: 90,
                  height: 90,
                ),
                const SizedBox(
                  height: 10,
                ),
                if (recordedPoints.isNotEmpty)
                  Text(
                    'Recorded points: ${recordedPoints.length}',
                    style: const TextStyle(color: Colors.white),
                  ),
                const SizedBox(
                  height: 10,
                ),
                EasyButton(
                  buttonColor: Colors.white,
                  borderRadius: 25,
                  height: 50,
                  idleStateWidget: const Text(
                    'Record this point',
                    style: TextStyle(color: Colors.teal),
                  ),
                  loadingStateWidget: const Text('gettting cordinates'),
                  onPressed: () {
                    addPoint();
                  },
                ),
                TextButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                        Colors.black,
                      ),
                      padding: MaterialStateProperty.all(
                        const EdgeInsets.symmetric(vertical: 16),
                      ),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      )),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MapScreen(points: recordedPoints),
                      ),
                    );
                  },
                  child: const Text(
                    'Submit',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
