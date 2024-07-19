import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BMI Calculator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  double bmi = 0.00;
  String weightStatus = "Underweight";
  String bmiMessage =
      "You have a lower than a normal body weight. You can eat a bit more.";

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _calculateBMI() async {
    if (_formKey.currentState!.validate()) {
      double heightCm = double.parse(_heightController.text);
      double heightM = heightCm / 100; // Convert height to meters
      double weight = double.parse(_weightController.text);

      setState(() {
        bmi = double.parse((weight / (heightM * heightM)).toStringAsFixed(2));
        // Calculate BMI

        if (bmi < 18.5) {
          weightStatus = "Underweight";
          bmiMessage =
              "You have a lower than a normal body weight. You can eat a bit more.";
        } else if (bmi >= 18.5 && bmi < 24.9) {
          weightStatus = "Normal weight";
          bmiMessage = "You have a normal body weight. Good job!";
        } else if (bmi >= 25 && bmi < 29.9) {
          weightStatus = "Overweight";
          bmiMessage =
              "You have a higher than normal body weight. Try to exercise more.";
        } else {
          weightStatus = "Obesity";
          bmiMessage =
              "You have a much higher than normal body weight. Seek medical advice.";
        }
      });

      _saveData();
    }
  }

  Future<void> _saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('bmi', bmi);
    await prefs.setString('weightStatus', weightStatus);
    await prefs.setString('bmiMessage', bmiMessage);

    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('BMI calculated successfully.')));
  }

  Future<void> _clear() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    setState(() {
      bmi = prefs.getDouble('bmi') ?? 0.00;
      weightStatus = prefs.getString('weightStatus') ?? "Underweight";
      bmiMessage = prefs.getString('bmiMessage') ??
          "You have a lower than a normal body weight. You can eat a bit more.";

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data cleared successfully')));
    });
  }

  Future<void> _loadSavedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      bmi = prefs.getDouble('bmi') ?? 0.00;
      weightStatus = prefs.getString('weightStatus') ?? "Underweight";
      bmiMessage = prefs.getString('bmiMessage') ??
          "You have a lower than a normal body weight. You can eat a bit more.";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("BMI CALCULATOR"),
        foregroundColor: Colors.white,
        backgroundColor: Colors.green[500],
      ),
      body: Center(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Container(
                height: 250,
                width: 400,
                margin: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                    // color: Colors.green,
                    ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Calculate your BMI",
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'BMI: $bmi',
                      style: const TextStyle(fontSize: 25),
                    ),
                    Text(
                      weightStatus,
                      style: const TextStyle(fontSize: 25),
                    ),
                    Text(
                      bmiMessage,
                      style: const TextStyle(fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              Container(
                height: 250,
                width: 400,
                margin: const EdgeInsets.all(10),
                // decoration: const BoxDecoration(color: Colors.amber),
                child: Column(
                  children: [
                    TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter your height in centimeters";
                        } else if (!RegExp(r'^\d+(\.\d)?$').hasMatch(value)) {
                          return "Please enter a valid number";
                        } else {
                          double height = double.parse(value);
                          if (height < 50 || height > 300) {
                            return "Please enter a height between 50cm and 300cm";
                          }
                        }
                        return null;
                      },
                      controller: _heightController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Height: Centimeters',
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter your weight in kilograms";
                        } else if (!RegExp(r'^\d+(\.\d)?$').hasMatch(value)) {
                          return "Please enter a valid number";
                        } else {
                          double weight = double.parse(value);
                          if (weight < 30 || weight > 300) {
                            return "Please enter a height between 30kg and 300kg";
                          }
                        }
                        return null;
                      },
                      controller: _weightController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Weight: Kilograms',
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _calculateBMI,
                          icon: const Icon(Icons.calculate),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0)),
                            backgroundColor: Colors.green[400],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 25, vertical: 15),
                          ),
                          label: const Text('Calculate BMI'),
                        ),
                        ElevatedButton.icon(
                          onPressed: _clear,
                          icon: const Icon(Icons.delete),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0)),
                            backgroundColor:
                                const Color.fromARGB(255, 187, 41, 33),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 35, vertical: 15),
                          ),
                          label: const Text('Clear data'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
