import 'evacuation_point_model.dart';
import 'evacuation_order_model.dart';

abstract class IEvacuationRepository {
  Stream<List<EvacuationPointModel>> watchEvacuationPoints();
  Stream<List<EvacuationOrderModel>> watchEvacuationOrders();
  Future<void> createEvacuationPoint(EvacuationPointModel point);
  Future<void> updateEvacuationPoint(EvacuationPointModel point);
  Future<void> broadcastEvacuationOrder(EvacuationOrderModel order);
  Future<void> checkInHousehold(String pointId, String householdId);
}
