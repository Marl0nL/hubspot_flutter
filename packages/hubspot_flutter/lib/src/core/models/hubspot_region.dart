/// The HubSpot data-hosting region for an account.
///
/// Region affects a small number of hosts (notably the Forms submission host).
/// The main API host (`api.hubapi.com`) is shared across regions.
enum HubSpotRegion {
  /// North America (default) — `api.hsforms.com`.
  na,

  /// European Union — `api-eu1.hsforms.com`.
  eu;

  /// Host for the Forms submission API in this region.
  String get formsHost => switch (this) {
    HubSpotRegion.na => 'api.hsforms.com',
    HubSpotRegion.eu => 'api-eu1.hsforms.com',
  };
}
