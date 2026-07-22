/// Flutter UI helpers for hubspot_flutter.
///
/// Currently exposes [HubSpotForm], a drop-in widget that renders and submits a
/// HubSpot form via the client-safe Forms API. It re-exports the core
/// `package:hubspot_flutter` symbols the widgets need so a Flutter app can depend on
/// just this package.
library;

// Re-export the core, hiding its `FormField` model so it doesn't collide with
// Flutter's `FormField` widget in apps that import both. Import
// `package:hubspot_flutter/hubspot_flutter.dart` directly if you need the core model.
export 'package:hubspot_flutter/hubspot_flutter.dart' hide FormField;

export 'src/hubspot_form.dart';
export 'src/hubspot_form_field.dart';
