-- ==========================================
-- 1. DDL: TẠO CÁC BẢNG (EduHub)
-- ==========================================
CREATE TABLE members (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    joined_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE courses (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    capacity INT NOT NULL CHECK (capacity > 0)
);

CREATE TABLE registrations (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    member_id INT NOT NULL REFERENCES members(id),
    course_id INT NOT NULL REFERENCES courses(id),
    status VARCHAR(20) NOT NULL DEFAULT 'pending',
    registered_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (member_id, course_id)
);

CREATE INDEX ix_reg_course ON registrations (course_id);

-- ==========================================
-- 2. DỮ LIỆU MẪU (SEED DATA)
-- ==========================================
INSERT INTO members (full_name, email) VALUES
('Nguyễn An', 'an.nguyen@example.com'),
('Lê Chi', 'chi.le@example.com'),
('Trần Bình', 'binh.tran@example.com');

INSERT INTO courses (title, capacity) VALUES
('Lập trình Back End', 30),
('Cơ sở dữ liệu', 25),
('Cấu trúc dữ liệu', 40);

INSERT INTO registrations (member_id, course_id) VALUES
(1, 1),
(1, 2),
(3, 1);

-- ==========================================
-- 3. CÁC CÂU HỎI BÀI TẬP
-- ==========================================

-- Câu 1: Liệt kê tên các khoá học mà Nguyễn An đã đăng ký (JOIN)
SELECT c.title
FROM courses c
JOIN registrations r ON c.id = r.course_id
JOIN members m ON m.id = r.member_id
WHERE m.full_name = 'Nguyễn An';

-- Câu 2: Đếm số thành viên của mỗi khoá, khoá nhiều người nhất đứng đầu (GROUP BY)
SELECT 
    c.id,
    c.title,
    COUNT(r.member_id) AS total_members
FROM courses c
LEFT JOIN registrations r ON c.id = r.course_id
GROUP BY c.id, c.title
ORDER BY total_members DESC;

-- Câu 3: Chuyển/thêm Lê Chi vào khoá “Cơ sở dữ liệu” bằng transaction
BEGIN;

INSERT INTO registrations (member_id, course_id)
SELECT m.id, c.id
FROM members m, courses c
WHERE m.full_name = 'Lê Chi' 
  AND c.title = 'Cơ sở dữ liệu';

COMMIT;

-- Xem lại kết quả sau khi chuyển
SELECT m.full_name, c.title, r.status, r.registered_at
FROM registrations r
JOIN members m ON m.id = r.member_id
JOIN courses c ON c.id = r.course_id
WHERE m.full_name = 'Lê Chi' AND c.title = 'Cơ sở dữ liệu';