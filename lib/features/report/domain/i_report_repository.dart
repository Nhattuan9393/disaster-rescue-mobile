import 'assistance_request_model.dart';
import 'situation_report_model.dart';

abstract class IReportRepository {
  Future<void> sendAssistanceRequest(AssistanceRequestModel request);
  Future<void> sendSituationReport(SituationReportModel report);
  Stream<List<AssistanceRequestModel>> watchAssistanceRequests();
  Stream<List<SituationReportModel>> watchSituationReports();
  Future<void> updateAssistanceRequestStatus(String id, String status);
  Future<void> approveAndCreateSos(AssistanceRequestModel request);
}
