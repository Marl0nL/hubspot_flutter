import '../core/errors/hubspot_exception.dart';
import '../core/models/hubspot_object.dart';
import '../core/models/paging.dart';

/// **STUB — backend tier.** The CRM backbone: objects, search, batch,
/// associations and properties for contacts, companies, deals, tickets, and any
/// custom object.
///
/// All CRM endpoints are authenticated (`/crm/v3/objects/...`, `/crm/v4/...`),
/// so they must be called from a server that holds the Private App / OAuth
/// secret — never directly from a mobile app. This class documents the intended
/// surface; every method throws [HubSpotUnimplementedError] in this release.
class CrmStub {
  /// Internal — constructed by `HubspotClient`.
  const CrmStub();

  /// Object operations for [objectType] (`contacts`, `deals`, `0-1`, a custom
  /// object's fully-qualified name, ...).
  CrmObjectsStub objects(String objectType) => CrmObjectsStub._(objectType);

  /// Shortcut for `objects('contacts')`.
  CrmObjectsStub get contacts => objects('contacts');

  /// Shortcut for `objects('companies')`.
  CrmObjectsStub get companies => objects('companies');

  /// Shortcut for `objects('deals')`.
  CrmObjectsStub get deals => objects('deals');

  /// Shortcut for `objects('tickets')`.
  CrmObjectsStub get tickets => objects('tickets');

  /// CRM v4 associations between object types.
  CrmAssociationsStub get associations => const CrmAssociationsStub._();

  /// Property / schema definitions.
  CrmPropertiesStub get properties => const CrmPropertiesStub._();
}

/// **STUB — backend tier.** CRUD + search + batch for a single CRM object type.
class CrmObjectsStub {
  const CrmObjectsStub._(this.objectType);

  /// The object type these operations target.
  final String objectType;

  /// `GET /crm/v3/objects/{type}/{id}`.
  Future<HubSpotObject> getById(
    String id, {
    List<String> properties = const [],
    List<String> associations = const [],
  }) => throw HubSpotUnimplementedError('CRM $objectType getById');

  /// `GET /crm/v3/objects/{type}` (one page).
  Future<Page<HubSpotObject>> list({
    int? limit,
    String? after,
    List<String> properties = const [],
  }) => throw HubSpotUnimplementedError('CRM $objectType list');

  /// `POST /crm/v3/objects/{type}`.
  Future<HubSpotObject> create(Map<String, Object?> properties) =>
      throw HubSpotUnimplementedError('CRM $objectType create');

  /// `PATCH /crm/v3/objects/{type}/{id}`.
  Future<HubSpotObject> update(String id, Map<String, Object?> properties) =>
      throw HubSpotUnimplementedError('CRM $objectType update');

  /// `DELETE /crm/v3/objects/{type}/{id}`.
  Future<void> archive(String id) =>
      throw HubSpotUnimplementedError('CRM $objectType archive');

  /// `POST /crm/v3/objects/{type}/search` (max 200/page, 10 000-result ceiling).
  Future<Page<HubSpotObject>> search({
    List<Map<String, Object?>> filterGroups = const [],
    List<Map<String, Object?>> sorts = const [],
    String? query,
    List<String> properties = const [],
    int? limit,
    String? after,
  }) => throw HubSpotUnimplementedError('CRM $objectType search');

  /// `POST /crm/v3/objects/{type}/batch/read` (max 100 inputs).
  Future<List<HubSpotObject>> batchRead(
    List<String> ids, {
    List<String> properties = const [],
    String idProperty = 'id',
  }) => throw HubSpotUnimplementedError('CRM $objectType batchRead');

  /// `POST /crm/v3/objects/{type}/batch/create` (max 100 inputs).
  Future<List<HubSpotObject>> batchCreate(List<Map<String, Object?>> inputs) =>
      throw HubSpotUnimplementedError('CRM $objectType batchCreate');

  /// `POST /crm/v3/objects/{type}/batch/update` (max 100 inputs).
  Future<List<HubSpotObject>> batchUpdate(List<Map<String, Object?>> inputs) =>
      throw HubSpotUnimplementedError('CRM $objectType batchUpdate');

  /// `POST /crm/v3/objects/{type}/batch/upsert` (max 100 inputs).
  Future<List<HubSpotObject>> batchUpsert(
    List<Map<String, Object?>> inputs, {
    required String idProperty,
  }) => throw HubSpotUnimplementedError('CRM $objectType batchUpsert');

  /// `POST /crm/v3/objects/{type}/batch/archive` (max 100 inputs).
  Future<void> batchArchive(List<String> ids) =>
      throw HubSpotUnimplementedError('CRM $objectType batchArchive');
}

/// **STUB — backend tier.** CRM v4 associations.
class CrmAssociationsStub {
  const CrmAssociationsStub._();

  /// `PUT /crm/v4/objects/{a}/{aId}/associations/default/{b}/{bId}`.
  Future<void> associate({
    required String fromObjectType,
    required String fromId,
    required String toObjectType,
    required String toId,
    List<Map<String, Object?>> labels = const [],
  }) => throw HubSpotUnimplementedError('CRM associations associate');

  /// `DELETE /crm/v4/objects/{a}/{aId}/associations/{b}/{bId}`.
  Future<void> disassociate({
    required String fromObjectType,
    required String fromId,
    required String toObjectType,
    required String toId,
  }) => throw HubSpotUnimplementedError('CRM associations disassociate');

  /// `POST /crm/v4/associations/{a}/{b}/batch/read`.
  Future<Map<String, List<String>>> batchRead({
    required String fromObjectType,
    required String toObjectType,
    required List<String> fromIds,
  }) => throw HubSpotUnimplementedError('CRM associations batchRead');

  /// `GET /crm/v4/associations/{a}/{b}/labels`.
  Future<List<Map<String, Object?>>> listLabels({
    required String fromObjectType,
    required String toObjectType,
  }) => throw HubSpotUnimplementedError('CRM associations listLabels');
}

/// **STUB — backend tier.** CRM property / schema definitions.
class CrmPropertiesStub {
  const CrmPropertiesStub._();

  /// `GET /crm/v3/properties/{type}`.
  Future<List<Map<String, Object?>>> list(String objectType) =>
      throw HubSpotUnimplementedError('CRM properties list');

  /// `GET /crm/v3/properties/{type}/{name}`.
  Future<Map<String, Object?>> get(String objectType, String name) =>
      throw HubSpotUnimplementedError('CRM properties get');

  /// `POST /crm/v3/properties/{type}`.
  Future<Map<String, Object?>> create(
    String objectType,
    Map<String, Object?> definition,
  ) => throw HubSpotUnimplementedError('CRM properties create');

  /// `PATCH /crm/v3/properties/{type}/{name}`.
  Future<Map<String, Object?>> update(
    String objectType,
    String name,
    Map<String, Object?> definition,
  ) => throw HubSpotUnimplementedError('CRM properties update');

  /// `DELETE /crm/v3/properties/{type}/{name}`.
  Future<void> archive(String objectType, String name) =>
      throw HubSpotUnimplementedError('CRM properties archive');
}
