// Example: drop a HubSpot form into a Flutter screen with `HubSpotForm`.
//
// It uses the client-safe tier (PublicClient, no secret). Replace the portalId
// and formGuid with your own. Run inside a Flutter app scaffold.
import 'package:hubspot_flutter_forms/hubspot_flutter_forms.dart';
import 'package:flutter/material.dart';

void main() => runApp(const FormDemoApp());

class FormDemoApp extends StatelessWidget {
  const FormDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'hubspot_flutter Form Demo',
      home: FormDemoPage(),
    );
  }
}

class FormDemoPage extends StatelessWidget {
  const FormDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    // One client per portal. `requireClientSafe` guarantees no secret is used.
    final client = HubspotClient(
      options: const HubspotOptions(portalId: '1234567'),
      auth: const PublicClient(),
      requireClientSafe: true,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Contact us')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: HubSpotForm(
          client: client,
          formGuid: 'your-form-guid',
          submitLabel: 'Send',
          fields: const <HubSpotFormFieldSpec>[
            HubSpotFormFieldSpec(
              name: 'email',
              label: 'Email',
              type: HubSpotFieldType.email,
              required: true,
            ),
            HubSpotFormFieldSpec(name: 'firstname', label: 'First name'),
            HubSpotFormFieldSpec(
              name: 'message',
              label: 'Message',
              type: HubSpotFieldType.multiline,
            ),
            HubSpotFormFieldSpec(
              name: 'consent',
              label: 'I agree to be contacted',
              type: HubSpotFieldType.checkbox,
              required: true,
            ),
          ],
          onSuccess: (result) => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result.inlineMessage ?? 'Thanks!')),
          ),
          onError: (error) => ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed: ${error.message}'))),
        ),
      ),
    );
  }
}
