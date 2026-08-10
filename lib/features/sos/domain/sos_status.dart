enum SosStatus {
  pending,       // Đang chờ admin phân công
  assigned,      // Đã gán đội, đội đang trên đường tới (Khóa với đội khác)
  inProgress,    // Đội đã tới nơi và đang xử lý
  completed,     // Đã cứu xong
  cancelled,     // Báo cáo sai hoặc tự hủy
  escalated,     // Vượt quá khả năng, đã chuyển lên Tỉnh
}
