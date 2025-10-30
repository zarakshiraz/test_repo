import '../models/template.dart';

/// Repository interface for template operations.
abstract class TemplateRepository {
  // Template CRUD operations
  Future<Template> createTemplate(Template template);
  Future<Template?> getTemplate(String templateId);
  Future<void> updateTemplate(Template template);
  Future<void> deleteTemplate(String templateId);

  // Template queries
  Future<List<Template>> getUserTemplates(String userId);
  Future<List<Template>> getPublicTemplates({int limit = 50});
  Future<List<Template>> searchTemplates(String query);
  Future<List<Template>> getTemplatesByCategory(String category);
  Stream<List<Template>> watchUserTemplates(String userId);

  // Template usage
  Future<void> incrementUsageCount(String templateId);
  Future<List<Template>> getPopularTemplates({int limit = 20});

  // Offline support placeholders
  Future<void> syncPendingChanges();
  Future<bool> hasPendingChanges();
}
