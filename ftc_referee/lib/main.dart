import 'package:flutter/material.dart';
import 'package:ftc_referee/enums/Alliance.dart';
import 'package:ftc_referee/enums/Zone.dart';
import 'package:ftc_referee/json_parser.dart';
import 'package:ftc_referee/utils/drop_down.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FTC Referee Contact Zone Helper',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 23, 61, 185),
        ),
      ),
      home: const MyHomePage(title: 'FTC Referee Contact\nZone Helper'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final Future<Map<String, dynamic>> _resFuture;
  Zone? _selectedZone;
  Alliance? _selectedAllianceInitiated;
  Alliance? _selectedAllianceReceived;

  @override
  void initState() {
    super.initState();
    _resFuture = JsonParser().parse('assets/res.json');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title, softWrap: true, textAlign: TextAlign.center),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const SizedBox(height: 16),

            // Initiated Contact dropdown
            getDropdownMenu<Alliance>("Initiated Contact", Alliance.values, (
              value,
            ) {
              setState(() {
                _selectedAllianceInitiated = value;
              });
            }),

            const SizedBox(height: 16),

            // Received Contact dropdown
            getDropdownMenu<Alliance>("Received Contact", Alliance.values, (
              value,
            ) {
              setState(() {
                _selectedAllianceReceived = value;
              });
            }),

            const SizedBox(height: 16),

            // Zone dropdown
            getDropdownMenu<Zone>("Zone of Contact", Zone.values, (value) {
              setState(() {
                _selectedZone = value;
              });
            }),

            const SizedBox(height: 24),

            FutureBuilder<Map<String, dynamic>>(
              future: _resFuture,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final data = snapshot.data!;
                final rules = Map<String, dynamic>.from(data['rules'] as Map);
                final zones = Map<String, dynamic>.from(data['zone'] as Map);

                var initiator = _selectedAllianceInitiated?.name;
                final receiver = _selectedAllianceReceived?.name;
                final zoneKey = _selectedZone?.getJsonName();

                if (receiver == null || zoneKey == null) {
                  return const Text('Select at least one alliance and a zone.');
                }

                final zoneMap = zones[zoneKey] as Map<String, dynamic>?;
                if (zoneMap == null) {
                  return const Text('No data for selected zone.');
                }

                if (zoneMap['contactReceiver'] != receiver) {
                  return const Text('No penalty in this configuration.');
                }

                if (initiator == null) {
                  initiator = receiver == 'red' ? 'blue' : 'red';
                }

                final ruleId = zoneMap['rule'] as String;
                final ruleEntry = rules[ruleId] as Map<String, dynamic>?;

                if (ruleEntry == null) {
                  return Text('Unknown rule: $ruleId');
                }

                final penalty = ruleEntry['penalty']?.toString() ?? '';
                final description = ruleEntry['description']?.toString() ?? '';

                return Column(
                  children: [
                    Text(
                      'Penalty: $penalty on $initiator alliance',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Rule: $ruleId',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        description,
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
