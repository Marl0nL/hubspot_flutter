import '../core/errors/hubspot_exception.dart';

/// **STUB — backend tier.** The Files API (`/files/v3/files`).
///
/// Uploads are multipart and authenticated (`files` scope). In the recommended
/// posture, an app proxies file uploads through your backend (client → backend →
/// Files), so this is backend-only. Every method throws
/// [HubSpotUnimplementedError].
class FilesStub {
  /// Internal — constructed by `HubspotClient`.
  const FilesStub();

  /// `POST /files/v3/files` — upload bytes with an access level of
  /// `PUBLIC_INDEXABLE` / `PUBLIC_NOT_INDEXABLE` / `PRIVATE`.
  Future<Map<String, Object?>> upload({
    required List<int> bytes,
    required String fileName,
    required String folderPath,
    String accessLevel = 'PRIVATE',
  }) => throw HubSpotUnimplementedError('Files upload');

  /// `GET /files/v3/files/{fileId}`.
  Future<Map<String, Object?>> getById(String fileId) =>
      throw HubSpotUnimplementedError('Files getById');

  /// `DELETE /files/v3/files/{fileId}`.
  Future<void> delete(String fileId) =>
      throw HubSpotUnimplementedError('Files delete');
}
