import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  const String url = 'https://lxxvngrhuwjtktssrlws.supabase.co'; // Note: removed /rest/v1/
  const String anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imx4eHZuZ3JodXdqdGt0c3NybHdzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzcyMzc2MzQsImV4cCI6MjA5MjgxMzYzNH0.Pj9ogANqtx9wBpaKrZ5An_04622LUjScLlEv0MQpGD0';

  await Supabase.initialize(
    url: url,
    anonKey: anonKey,
  );

  final supabase = Supabase.instance.client;
  
  try {
    final response = await supabase.from('products').select();
    print(response);
  } catch (e) {
    print("Error: $e");
  }
}
