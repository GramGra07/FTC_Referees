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
      body: Center(
        child: Column(
          children: <Widget>[
            Spacer(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: getDropdownMenu<Alliance>(
                "Initiated Contact",
                Alliance.values,
                (value) {
                  setState(() {
                    _selectedAllianceInitiated = value;
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: getDropdownMenu<Alliance>(
                "Received Contact",
                Alliance.values,
                (value) {
                  setState(() {
                    _selectedAllianceReceived = value;
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: getDropdownMenu<Zone>("Zone of Contact", Zone.values, (
                value,
              ) {
                setState(() {
                  _selectedZone = value;
                });
              }),
            ),
            Spacer(),
            Spacer(),
            FutureBuilder<Map<String, dynamic>>(
              future: _resFuture,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                final data = snapshot.data!;
                final rules = Map<String, dynamic>.from(data['rules'] as Map);
                final zones = Map<String, dynamic>.from(data['zone'] as Map);

                // Require selections
                final initiator = _selectedAllianceInitiated?.name;
                final receiver = _selectedAllianceReceived?.name;
                final zoneKey = _selectedZone?.getJsonName();
                if (initiator == null || receiver == null || zoneKey == null) {
                  return const Text('Select both alliances and a zone.');
                }

                final zoneMap = zones[zoneKey] as Map<String, dynamic>?;
                if (zoneMap == null) {
                  return const Text('No data for selected zone.');
                }

                if (zoneMap['contactInitiator'] != initiator ||
                    zoneMap['contactReceiver'] != receiver) {
                  return const Text('No penalty in this configuration.');
                }

                // Match found: show penalty details
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
                    ),
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
            Spacer(),
          ],
        ),
      ),
    );
  }
}
