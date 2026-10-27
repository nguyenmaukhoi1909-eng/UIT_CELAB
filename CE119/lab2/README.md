### 1. `CE119_Lab02_25520909_1.asm`
* **Nội dung:** Chứa toàn bộ mã nguồn xử lý của **Thí nghiệm 2 (TN2)** và **Phần mở rộng (TN4)**.
* **Các thủ tục chính:**
  * `stats`: Thống kê điểm số nhỏ nhất (`min`) và lớn nhất (`max`) trong mảng.
  * `histogram`: Tra bảng `grade_tab` bằng lệnh `lbu` và đếm số lượng sinh viên theo từng nhóm xếp loại (g0, g1, g2, g3) vào mảng `hist`.
  * `draw_hist` *(Phần mở rộng / TN4)*: Trực quan hóa bảng phân bố phổ điểm dưới dạng biểu đồ cột ngang bằng các ký tự `|`.
### 2. `CE119_Lab02_25520909_2.asm`
* **Nội dung:** Chứa toàn bộ mã nguồn xử lý của **Thí nghiệm 3 (TN3)**.
* **Các thủ tục chính:**
  * `check_brackets`: Cấu trúc dữ liệu Ngăn xếp (Stack) dùng để kiểm tra tính cân bằng của các cặp ngoặc `()`, `[]`, `{}` trong chuỗi văn bản. Trả về vị trí lỗi ($v0) và mã lỗi chi tiết ($v1).
