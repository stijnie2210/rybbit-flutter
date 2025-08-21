import 'package:flutter/material.dart';
import 'package:rybbit_flutter/rybbit_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Rybbit Analytics with new configuration options
  await RybbitFlutter.instance.initialize(
    RybbitConfig(
      apiKey: 'your-api-key-here', // Replace with your actual API key
      siteId: 'your-site-id-here', // Replace with your actual site ID
      enableLogging: true, // Enable for debugging
      trackScreenViews: true,
      trackAppLifecycle: true,
      trackQuerystring: true, // Include query params in pageviews
      trackOutbound: true, // Track outbound link clicks
      autoTrackPageview: true, // Track initial pageview on init
      skipPatterns: [
        '/debug/*', // Skip debug pages
        '/admin/internal/*', // Skip internal admin pages
        '*/temp', // Skip temporary pages
      ],
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rybbit Flutter Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // Add the route observer for automatic screen tracking
      navigatorObservers: [RybbitFlutter.instance.routeObserver],
      home: const MyHomePage(title: 'Rybbit Flutter Example'),
      routes: {
        '/second': (context) => const SecondPage(),
        '/third': (context) => const ThirdPage(),
        '/debug': (context) => const DebugPage(), // This will be skipped by analytics
      },
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
  int _counter = 0;

  @override
  void initState() {
    super.initState();
    // Track a pageview when the screen loads
    _trackPageView();
  }

  void _trackPageView() {
    RybbitFlutter.instance.trackPageView(
      pathname: '/',
      pageTitle: 'Home Page',
      queryParams: {
        'source': 'manual_track',
        'version': '1.0',
      },
    );
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });

    // Track the button click as a custom event
    RybbitFlutter.instance.trackEvent(
      'button_clicked',
      properties: {
        'button_type': 'increment',
        'counter_value': _counter,
        'page': 'home',
      },
      pathname: '/',
      pageTitle: 'Home Page',
    );
  }

  void _identifyUser() {
    // Example of user identification
    RybbitFlutter.instance.identify(
      'user_${DateTime.now().millisecondsSinceEpoch}',
    );

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('User identified!')));

    // Track the identification event
    RybbitFlutter.instance.trackEvent(
      'user_identified',
      properties: {'method': 'button_click'},
    );
  }

  void _trackOutboundLink() {
    // Example of tracking an outbound link
    RybbitFlutter.instance.trackOutboundLink(
      'https://rybbit.io',
      text: 'Visit Rybbit',
      pathname: '/',
    );

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Outbound link tracked!')));
  }

  void _trackError() {
    // Example of error tracking
    try {
      // Simulate an error
      throw Exception('This is a test error for analytics');
    } catch (e, stackTrace) {
      RybbitFlutter.instance.trackError(
        'TestError',
        'Simulated error: ${e.toString()}',
        stackTrace: stackTrace.toString(),
        fileName: 'main.dart',
        lineNumber: 95,
        pathname: '/',
        pageTitle: 'Home Page',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error tracked to analytics!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _identifyUser,
              child: const Text('Identify User'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _trackOutboundLink,
              child: const Text('Track Outbound Link'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/second');
              },
              child: const Text('Go to Second Page'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/third');
              },
              child: const Text('Go to Third Page'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/debug');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Go to Debug Page (Skipped)'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _trackError,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Track Error'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class SecondPage extends StatelessWidget {
  const SecondPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Second Page'),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'This is the second page!',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // Track a custom event
                RybbitFlutter.instance.trackEvent(
                  'page_interaction',
                  properties: {
                    'action': 'button_click',
                    'page': 'second',
                    'element': 'custom_event_button',
                  },
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Custom event tracked!')),
                );
              },
              child: const Text('Track Custom Event'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}

class DebugPage extends StatelessWidget {
  const DebugPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Page (Analytics Skipped)'),
        backgroundColor: Colors.red,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bug_report,
              size: 80,
              color: Colors.red,
            ),
            SizedBox(height: 16),
            Text(
              'This is a debug page!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'This page matches the skip pattern "/debug/*"',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'So it won\'t be tracked in analytics.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class ThirdPage extends StatefulWidget {
  const ThirdPage({super.key});

  @override
  State<ThirdPage> createState() => _ThirdPageState();
}

class _ThirdPageState extends State<ThirdPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Track form submission
      RybbitFlutter.instance.trackEvent(
        'form_submitted',
        properties: {
          'form_type': 'contact',
          'page': 'third',
          'has_name': _nameController.text.isNotEmpty,
          'has_email': _emailController.text.isNotEmpty,
        },
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Form submitted and tracked!')),
      );

      // Clear form
      _nameController.clear();
      _emailController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Third Page - Form'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text(
                'Contact Form Example',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
                onChanged: (value) {
                  // Track form field interaction
                  if (value.length == 1) {
                    RybbitFlutter.instance.trackEvent(
                      'form_field_started',
                      properties: {'field': 'name', 'page': 'third'},
                    );
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
                onChanged: (value) {
                  // Track form field interaction
                  if (value.length == 1) {
                    RybbitFlutter.instance.trackEvent(
                      'form_field_started',
                      properties: {'field': 'email', 'page': 'third'},
                    );
                  }
                },
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      child: const Text('Submit'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
