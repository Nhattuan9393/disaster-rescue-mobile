/// Các vai trò người dùng trong hệ thống điều phối cứu hộ DisasterRescue.
enum UserRole {
  household('Hộ dân bị nạn'),
  admin('Ban chỉ đạo xã'),
  rescueTeam('Đội cứu hộ / MTQ'),
  public('Situation Board công khai');

  final String label;
  const UserRole(this.label);
}
