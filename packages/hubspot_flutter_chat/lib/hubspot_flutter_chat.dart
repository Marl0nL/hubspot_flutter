/// Flutter bridge over HubSpot's native iOS & Android mobile chat SDKs.
///
/// See [HubspotChat] for the high-level API and the package README for native
/// setup (Android Maven dependency, iOS Swift Package).
library;

export 'src/chat_config.dart';
export 'src/hubspot_chat.dart';
// Re-export the generated transport types callers may reference (the Pigeon
// data classes). The low-level *Api classes are exported too so tests and
// advanced users can inject a custom host API.
export 'src/messages.g.dart'
    show
        ChatSetupData,
        VisitorIdentity,
        HubspotChatHostApi,
        HubspotChatFlutterApi;
