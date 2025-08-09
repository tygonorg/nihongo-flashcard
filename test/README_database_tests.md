````markdown
# Kiểm Thử Dịch Vụ Cơ Sở Dữ Liệu

Tài liệu này mô tả các bài kiểm thử đơn vị toàn diện cho các thao tác CRUD của Dịch vụ Cơ sở dữ liệu sử dụng `sqflite_common_ffi` để tránh I/O file.

## Tổng Quan

Các bài kiểm thử đơn vị được triển khai trong `database_service_unit_test.dart` và cung cấp độ phủ toàn diện cho tất cả các thao tác CRUD của tầng cơ sở dữ liệu trong ứng dụng flashcard từ vựng.

## Cơ Sở Hạ Tầng Kiểm Thử

### Lớp DatabaseServiceTest
- **Cơ sở dữ liệu trong bộ nhớ**: Sử dụng cơ sở dữ liệu `:memory:` với `sqflite_common_ffi` để tránh I/O file
- **Hỗ trợ khóa ngoại**: Bật `PRAGMA foreign_keys = ON` để kiểm tra xóa theo cascade
- **Schema môi trường production**: Khớp chính xác với schema từ `DatabaseService` trong môi trường production
- **Trạng thái kiểm thử sạch**: Cung cấp chức năng reset để đảm bảo cô lập kiểm thử

### Tính Năng Chính
- Không có thao tác I/O file (sử dụng SQLite trong bộ nhớ)
- Kiểm thử độc lập với nền tảng (Windows, Linux, macOS)
- Tự động dọn dẹp và cô lập kiểm thử
- Schema sẵn sàng cho môi trường production

## Độ Phủ Kiểm Thử

### 1. Thao Tác Chèn Từ Vựng (3 bài kiểm thử)
- **Chỉ các trường bắt buộc**: Kiểm tra chèn từ vựng cơ bản với dữ liệu tối thiểu
- **Tất cả các trường**: Kiểm tra chèn với đầy đủ trường SRS và metadata
- **ID tự tăng**: Xác minh việc tạo và sắp xếp ID phù hợp

### 2. Thao Tác Đọc Từ Vựng (5 bài kiểm thử)
- **Đọc theo ID**: Kiểm tra lấy một từ vựng theo khóa chính
- **ID không tồn tại**: Xác minh trả về null cho bản ghi không tồn tại
- **Đọc tất cả từ vựng**: Kiểm tra lấy hàng loạt và tính toàn vẹn dữ liệu
- **Lọc theo cấp độ**: Kiểm tra truy vấn có điều kiện với tham số cấp độ
- **Sắp xếp**: Xác minh sắp xếp `updatedAt DESC`

### 3. Thao Tác Tìm Kiếm Từ Vựng (6 bài kiểm thử)
- **Tìm kiếm thuật ngữ**: Kiểm tra khớp một phần trên trường term
- **Tìm kiếm nghĩa**: Kiểm tra khớp một phần trên trường meaning
- **Khớp một phần**: Kiểm tra chức năng truy vấn LIKE
- **Lọc cấp độ**: Kiểm tra tìm kiếm kết hợp với lọc cấp độ
- **Không có kết quả khớp**: Kiểm tra xử lý kết quả trống
- **Ký tự đặc biệt**: Kiểm tra bảo vệ SQL injection và xử lý ký tự đặc biệt

### 4. Thao Tác Cập Nhật Từ Vựng (4 bài kiểm thử)
- **Cập nhật cơ bản**: Kiểm tra sửa đổi trường và cập nhật timestamp
- **Cập nhật dữ liệu SRS**: Kiểm tra cập nhật trường hệ thống ôn tập theo khoảng thời gian
- **Xử lý lỗi**: Kiểm tra cập nhật không có ID (phải ném lỗi)
- **Bản ghi không tồn tại**: Kiểm tra cập nhật trên bản ghi đã xóa

### 5. Thao Tác Xóa Từ Vựng (2 bài kiểm thử)
- **Xóa thành công**: Kiểm tra xóa bản ghi và xác nhận
- **Bản ghi không tồn tại**: Kiểm tra thao tác xóa trên bản ghi không tồn tại

### 6. Thao Tác CRUD Nhật Ký Ôn Tập (3 bài kiểm thử)
- **Chèn và đọc**: Kiểm tra tạo và lấy nhật ký ôn tập
- **Nhiều nhật ký**: Kiểm tra nhiều nhật ký ôn tập cho mỗi từ vựng
- **Sắp xếp**: Kiểm tra sắp xếp `reviewedAt DESC` cho nhật ký

### 7. Thao Tác Xóa Cascade (2 bài kiểm thử)
- **Cascade một từ vựng**: Kiểm tra hành vi xóa cascade khóa ngoại
- **Cascade nhiều từ vựng**: Kiểm tra thao tác cascade hàng loạt
- **Tính toàn vẹn dữ liệu**: Xác minh dọn dẹp hoàn toàn dữ liệu liên quan

### 8. Thao Tác Đếm (2 bài kiểm thử)
- **Đếm từ vựng**: Kiểm tra đếm tổng số và số từ vựng đã lọc
- **Đếm nhật ký ôn tập**: Kiểm tra tổng số và số nhật ký cho mỗi từ vựng

### 9. Trường Hợp Đặc Biệt và Xử Lý Lỗi (5 bài kiểm thử)
- **Chuỗi rỗng**: Kiểm tra xử lý dữ liệu rỗng nhưng hợp lệ
- **Ký tự đặc biệt**: Kiểm tra Unicode, dấu nháy và ký tự đặc biệt
- **Dữ liệu lớn**: Kiểm tra xử lý trường văn bản lớn (1000+ ký tự)
- **Ngày cực trị**: Kiểm tra giá trị timestamp min/max
- **Trường null**: Kiểm tra xử lý null đúng cho các trường tùy chọn

### 10. Thao Tác Đồng Thời (2 bài kiểm thử)
- **Chèn đồng thời**: Kiểm tra an toàn luồng của cơ sở dữ liệu với nhiều thao tác chèn
- **Cập nhật đồng thời**: Kiểm tra thao tác cập nhật trong điều kiện đồng thời

## Kết Quả Kiểm Thử

Tất cả 35 bài kiểm thử đơn vị đều pass thành công, cung cấp độ phủ toàn diện cho:

- ✅ **Thao tác chèn**: Tạo với xác thực đầy đủ trường
- ✅ **Thao tác đọc**: Lấy theo ID và chức năng tìm kiếm
- ✅ **Thao tác cập nhật**: Sửa đổi bản ghi hiện có với xác thực phù hợp
- ✅ **Thao tác xóa**: Xóa bản ghi với hành vi cascade
- ✅ **Chức năng tìm kiếm**: Khớp một phần và lọc
- ✅ **Xóa cascade**: Xác thực ràng buộc khóa ngoại
- ✅ **Xử lý lỗi**: Trường hợp đặc biệt và thao tác không hợp lệ
- ✅ **Đồng thời**: Thao tác cơ sở dữ liệu đa luồng
- ✅ **Tính toàn vẹn dữ liệu**: Serialize/deserialize trường phù hợp

## Tính Năng Kỹ Thuật Chính Được Kiểm Thử

### Thao Tác CRUD
1. **Create**: Chèn từ vựng và nhật ký ôn tập với ID tự tăng
2. **Read**: Truy vấn theo ID, tìm kiếm với thao tác LIKE, lọc cấp độ
3. **Update**: Sửa đổi bản ghi hiện có với quản lý timestamp
4. **Delete**: Xóa bản ghi với hành vi cascade khóa ngoại

### Tính Năng Cơ Sở Dữ Liệu
1. **Khóa ngoại**: CASCADE DELETE từ vocabs đến review_logs
2. **Chỉ mục**: Tối ưu hiệu năng cho level, dueAt, updatedAt, favorite
3. **Giao dịch**: Xử lý giao dịch ngầm cho tính nhất quán dữ liệu
4. **Kiểu dữ liệu**: INTEGER, TEXT, REAL với serialize phù hợp

### Chức Năng Nâng Cao
1. **Tìm kiếm**: Thao tác LIKE với khớp một phần
2. **Lọc**: Truy vấn có điều kiện dựa trên cấp độ
3. **Sắp xếp**: ORDER BY với thao tác DESC/ASC
4. **Đếm**: Hàm tổng hợp với lọc tùy chọn
5. **Đồng thời**: Thao tác cơ sở dữ liệu an toàn luồng

## Chạy Kiểm Thử

```bash
# Chạy chỉ kiểm thử đơn vị cơ sở dữ liệu
flutter test test/database_service_unit_test.dart

# Chạy tất cả kiểm thử bao gồm kiểm thử đơn vị cơ sở dữ liệu
flutter test
```

## Tích Hợp với Bộ Kiểm Thử Chính

Các kiểm thử đơn vị này bổ sung cho các kiểm thử tích hợp hiện có:
- **Kiểm thử đơn vị**: Tập trung vào thao tác CRUD độc lập
- **Kiểm thử tích hợp**: Tập trung vào luồng công việc phức tạp và logic nghiệp vụ
- **Độ phủ kết hợp**: Cung cấp xác thực đầy đủ tầng cơ sở dữ liệu

Các kiểm thử sử dụng cùng mô hình dữ liệu và schema như môi trường production, đảm bảo thao tác cơ sở dữ liệu hoạt động chính xác qua tất cả các tầng ứng dụng.

````
