-- Разработка информационной базы учета оказания услуг в ателье

CREATE TABLE clients (
    ID_client SERIAL PRIMARY KEY,
    fullname_client VARCHAR(100) NOT NULL,
    phone_client VARCHAR(20) CHECK (phone_client ~ '^\+7\d{10}$'),
    address_client VARCHAR(255),
    email_client VARCHAR(100) UNIQUE CHECK (
        email_client ~* '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    )
);

CREATE TABLE positions (
    ID_position SERIAL PRIMARY KEY,
    name_position VARCHAR(100) NOT NULL UNIQUE,
    rate_position INTEGER NOT NULL
);

CREATE TABLE employees (
    ID_employee SERIAL PRIMARY KEY,
    ID_position INTEGER REFERENCES positions (ID_position),
    fullname_employee VARCHAR(100) NOT NULL,
    phone_employee VARCHAR(20) NOT NULL CHECK (
        phone_employee ~ '^\+7\d{10}$'
    ),
    email_employee VARCHAR(100) UNIQUE CHECK (
        email_employee ~* '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    ),
    address_employee VARCHAR(150),
    passport_employee VARCHAR(11) NOT NULL UNIQUE CHECK (
        passport_employee ~ '[0-9]{4}-[0-9]{6}'
    ),
    birthday_employee DATE NOT NULL,
    hire_date_employee DATE NOT NULL,
    termination_date_employee DATE
);

CREATE TABLE services (
    ID_service SERIAL PRIMARY KEY,
    name_service VARCHAR(100) NOT NULL,
    price_service DECIMAL(10, 2) NOT NULL CHECK (price_service >= 0)
);

CREATE TABLE coupons (
    ID_coupon SERIAL PRIMARY KEY,
    coupon_name VARCHAR(50) NOT NULL,
    coupon_discount INTEGER NOT NULL CHECK (
        coupon_discount > 0
        AND coupon_discount < 100
    )
);

CREATE TABLE orders (
    ID_order SERIAL PRIMARY KEY,
    ID_client INTEGER REFERENCES clients (ID_client),
    ID_employee INTEGER REFERENCES employees (ID_employee),
    ID_coupon INTEGER REFERENCES coupons (ID_coupon),
    date_order DATE NOT NULL CHECK (date_order <= CURRENT_DATE),
    date_order_completed DATE CHECK (
        date_order_completed >= CURRENT_DATE
    )
);

CREATE TABLE order_compositions (
    ID_order INTEGER REFERENCES orders (ID_order),
    ID_service INTEGER REFERENCES services (ID_service),
    amount_compositions INTEGER NOT NULL CHECK (amount_compositions >= 1),
    PRIMARY KEY (ID_order, ID_service)
);

CREATE TABLE client_reviews (
    ID_review SERIAL PRIMARY KEY,
    ID_client INTEGER REFERENCES clients (ID_client),
    ID_order INTEGER REFERENCES orders (ID_order),
    review_text TEXT,
    review_date DATE DEFAULT CURRENT_DATE
);

-- Процедуры

CREATE OR REPLACE PROCEDURE create_position(
    IN position_name VARCHAR(100),
    IN position_rate INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO positions (name_position, rate_position)
    VALUES (position_name, position_rate);
END;
$$;

CREATE OR REPLACE PROCEDURE insert_employee(
    IN employee_name VARCHAR(100),
    IN employee_position VARCHAR(100),
    IN employee_phone VARCHAR(20),
    IN employee_email VARCHAR(100)
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO employees (fullname_employee, position_employee, phone_employee, email_employee)
    VALUES (employee_name, employee_position, employee_phone, employee_email);
END;
$$;

CREATE OR REPLACE PROCEDURE create_client(
    IN client_name VARCHAR(100),
    IN client_phone VARCHAR(20),
    IN client_address VARCHAR(255),
    IN client_email VARCHAR(100)
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO clients (fullname_client, phone_client, address_client, email_client)
    VALUES (client_name, client_phone, client_address, client_email);
END;
$$;

CREATE OR REPLACE PROCEDURE insert_employee(
    IN employee_name VARCHAR(100),
    IN employee_position INTEGER,
    IN employee_phone VARCHAR(20),
    IN employee_email VARCHAR(100),
    IN employee_address VARCHAR(150),
    IN employee_passport VARCHAR(11),
    IN employee_birthday DATE,
    IN employee_hire_date DATE,
    IN employee_termination_date DATE DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO employees (
        fullname_employee,
        ID_position,
        phone_employee,
        email_employee,
        address_employee,
        passport_employee,
        birthday_employee,
        hire_date_employee,
        termination_date_employee
    )
    VALUES (
        employee_name,
        employee_position,
        employee_phone,
        employee_email,
        employee_address,
        employee_passport,
        employee_birthday,
        employee_hire_date,
        employee_termination_date
    );
END;
$$;

CREATE OR REPLACE PROCEDURE insert_service(
    IN service_name VARCHAR(100),
    IN service_price DECIMAL(10, 2)
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO services (name_service, price_service)
    VALUES (service_name, service_price);
END;
$$;

CREATE OR REPLACE PROCEDURE insert_order(
    IN client_id INTEGER,
    IN employee_id INTEGER,
    IN coupon_id INTEGER,
    IN order_date DATE DEFAULT CURRENT_DATE
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO orders (ID_client, ID_employee, ID_coupon, date_order)
    VALUES (client_id, employee_id, coupon_id, COALESCE(order_date, CURRENT_DATE));
END;
$$;

CREATE OR REPLACE PROCEDURE complete_order(
    IN order_id INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE orders SET date_order_completed = CURRENT_DATE WHERE ID_order = order_id;
END;
$$;

CREATE OR REPLACE PROCEDURE insert_order_composition(
    IN order_id INTEGER,
    IN service_id INTEGER,
    IN amount_compositions INTEGER DEFAULT 1
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO order_compositions (ID_order, ID_service, amount_compositions)
    VALUES (order_id, service_id, amount_compositions);
END;
$$;

CREATE OR REPLACE PROCEDURE insert_coupons(
    IN coupon_name VARCHAR(50),
    IN coupon_discount INTEGER DEFAULT 10
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO coupons (coupon_name, coupon_discount)
    VALUES (coupon_name, coupon_discount);
END;
$$;

CREATE OR REPLACE PROCEDURE add_client_review(
    IN client_id INTEGER,
    IN order_id INTEGER,
    IN review_text TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO client_reviews (ID_client, ID_order, review_text)
    VALUES (client_id, order_id, review_text);
END;
$$;

CREATE OR REPLACE PROCEDURE terminate_employee(
    IN employee_id INTEGER,
    IN date_terminate DATE DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE employees SET termination_date_employee = COALESCE(date_terminate, CURRENT_DATE) WHERE ID_employee = employee_id;
END;
$$;

CALL terminate_employee (1);

CALL create_position ('Технолог', 50000);

CALL create_position ('Портной', 40000);

CALL create_position ('Закройщик', 45000);

CALL create_position ('Швея', 30000);

CALL create_position ('Мастер по ремонту', 35000);

CALL create_position ('Управляющий', 60000);

CALL create_position ('Приемщик заказов', 25000);

CALL insert_employee (
    'Иванов Иван Иванович',
    1,
    '+79000000001',
    'ivanov@example.com',
    'г. Москва, ул. Ленина, д. 1',
    '1234-567890',
    '1980-01-01',
    '2020-01-01'
);

CALL insert_employee (
    'Петров Петр Петрович',
    2,
    '+79000000002',
    'petrov@example.com',
    'г. Москва, ул. Пушкина, д. 2',
    '2345-678901',
    '1985-02-02',
    '2021-02-02'
);

CALL insert_employee (
    'Сидоров Сидор Сидорович',
    3,
    '+79000000003',
    'sidorov@example.com',
    'г. Москва, ул. Садовая, д. 3',
    '3456-789012',
    '1990-03-03',
    '2022-03-03'
);

CALL insert_employee (
    'Алексеева Александра Александровна',
    4,
    '+79000000004',
    'alekseeva@example.com',
    'г. Москва, ул. Тверская, д. 4',
    '4567-890123',
    '1995-04-04',
    '2023-04-04'
);

CALL insert_employee (
    'Михайлова Мария Михайловна',
    5,
    '+79000000005',
    'mikhailova@example.com',
    'г. Москва, ул. Арбат, д. 5',
    '5678-901234',
    '2000-05-05',
    '2024-05-05'
);

CALL insert_employee (
    'Кузнецова Екатерина Кузьминична',
    6,
    '+79000000006',
    'kuznetsova@example.com',
    'г. Москва, ул. Пречистенка, д. 6',
    '6789-012345',
    '1987-06-06',
    '2020-06-06'
);

CALL insert_employee (
    'Романова Ольга Романовна',
    7,
    '+79000000007',
    'romanova@example.com',
    'г. Москва, ул. Кутузовский проспект, д. 7',
    '7890-123456',
    '1992-07-07',
    '2021-07-07'
);

CALL create_client (
    'Андреев Андрей Андреевич',
    '+79000000008',
    'г. Москва, ул. Невский проспект, д. 8',
    'andreev@example.com'
);

CALL create_client (
    'Борисова Бориса Борисовна',
    '+79000000009',
    'г. Москва, ул. Ломоносова, д. 9',
    'borisova@example.com'
);

CALL create_client (
    'Васильев Василий Васильевич',
    '+79000000010',
    'г. Москва, ул. Большая Никитская, д. 10',
    'vasiliev@example.com'
);

CALL create_client (
    'Григорьева Галина Григорьевна',
    '+79000000011',
    'г. Москва, ул. Новослободская, д. 11',
    'grigorieva@example.com'
);

CALL create_client (
    'Дмитриев Дмитрий Дмитриевич',
    '+79000000012',
    'г. Москва, ул. Малая Дмитровка, д. 12',
    'dmitriev@example.com'
);

CALL create_client (
    'Евгеньева Евгения Евгеньевна',
    '+79000000013',
    'г. Москва, ул. Кузнецкий мост, д. 13',
    'evgeneva@example.com'
);

CALL create_client (
    'Захаров Захар Захарович',
    '+79000000014',
    'г. Москва, ул. Солянка, д. 14',
    'zaharov@example.com'
);

CALL insert_service ('Пошив платья', 5000.00);

CALL insert_service ('Ремонт одежды', 2000.00);

CALL insert_service ('Укоротить брюки', 1500.00);

CALL insert_service ('Пошив костюма', 10000.00);

CALL insert_service ('Ремонт обуви', 3000.00);

CALL insert_service ('Пошив рубашки', 2500.00);

CALL insert_service ('Замена молнии', 500.00);

CALL insert_coupons ('Летняя скидка', 10);

CALL insert_coupons ('Зимняя распродажа', 20);

CALL insert_coupons ('Весенняя акция', 15);

CALL insert_coupons ('Осенний бонус', 25);

CALL insert_coupons ('День Рождения', 30);

CALL insert_coupons ('Первый заказ', 5);

CALL insert_coupons ('Постоянный клиент', 35);

CALL insert_order (1, 1, 1, '2024-06-01');

CALL insert_order (2, 2, 2, '2024-06-02');

CALL insert_order (3, 3, 3, '2024-06-03');

CALL insert_order (4, 4, 4, '2024-06-04');

CALL insert_order (5, 5, 5, '2024-06-05');

CALL insert_order (6, 6, 6, '2024-06-06');

CALL insert_order (7, 7, 7, '2024-06-07');

CALL insert_order_composition (1, 1, 2);

CALL insert_order_composition (2, 2, 1);

CALL insert_order_composition (3, 3, 1);

CALL insert_order_composition (4, 4, 2);

CALL insert_order_composition (5, 5, 3);

CALL insert_order_composition (6, 6, 1);

CALL insert_order_composition (7, 7, 1);

CALL add_client_review ( 1, 1, 'Очень доволен сервисом!' );

CALL add_client_review (2, 2, 'Хорошая работа!');

CALL add_client_review (3, 3, 'Все понравилось.');

CALL add_client_review (4, 4, 'Отличный пошив.');

CALL add_client_review (5, 5, 'Быстро и качественно.');

CALL add_client_review (6, 6, 'Очень рекомендую.');

CALL add_client_review (7, 7, 'Спасибо за помощь!');

-- 1. Запрос на получение информации о всех заказах, выполненных определенным сотрудником, с деталями заказа и клиента.
SELECT o.ID_order, c.fullname_client, c.phone_client, e.fullname_employee, o.date_order, o.date_order_completed
FROM
    orders o
    JOIN clients c ON o.ID_client = c.ID_client
    JOIN employees e ON o.ID_employee = e.ID_employee
WHERE
    e.fullname_employee = 'Иванов Иван Иванович';

-- 2. Запрос на получение списка услуг, которые заказывали клиенты, с указанием количества каждой услуги.
SELECT s.name_service, COUNT(oc.ID_service) AS service_count
FROM
    order_compositions oc
    JOIN services s ON oc.ID_service = s.ID_service
GROUP BY
    s.name_service
ORDER BY service_count DESC;

-- 3. Запрос на получение информации о клиентах, которые сделали больше одного заказа.
SELECT c.fullname_client, c.phone_client, COUNT(o.ID_order) AS order_count
FROM clients c
    JOIN orders o ON c.ID_client = o.ID_client
GROUP BY
    c.ID_client
HAVING
    COUNT(o.ID_order) > 1;

-- 4. Запрос на получение информации о сотрудниках, которые работают на позиции с самой высокой зарплатой.
SELECT e.fullname_employee, p.name_position, p.rate_position
FROM employees e
    JOIN positions p ON e.ID_position = p.ID_position
WHERE
    p.rate_position = (
        SELECT MAX(rate_position)
        FROM positions
    );

-- 5. Запрос на получение информации о заказах, которые использовали купон с самой большой скидкой.
SELECT o.ID_order, c.fullname_client, c.phone_client, cp.coupon_name, cp.coupon_discount, o.date_order
FROM
    orders o
    JOIN clients c ON o.ID_client = c.ID_client
    JOIN coupons cp ON o.ID_coupon = cp.ID_coupon
WHERE
    cp.coupon_discount = (
        SELECT MAX(coupon_discount)
        FROM coupons
    );

-- 6. Запрос на получение списка сотрудников с количеством заказов, которые они выполнили.
SELECT e.fullname_employee, COUNT(o.ID_order) AS order_count
FROM employees e
    JOIN orders o ON e.ID_employee = o.ID_employee
GROUP BY
    e.ID_employee
ORDER BY order_count DESC;

-- 7. Запрос на получение средней цены услуг, заказанных клиентом, за определенный период времени.
SELECT c.fullname_client, AVG(s.price_service) AS avg_service_price
FROM
    clients c
    JOIN orders o ON c.ID_client = o.ID_client
    JOIN order_compositions oc ON o.ID_order = oc.ID_order
    JOIN services s ON oc.ID_service = s.ID_service
WHERE
    o.date_order BETWEEN '2024-06-01' AND '2024-06-30'
GROUP BY
    c.ID_client;

-- 1. Триггер для автоматического обновления даты завершения заказа на текущую дату при выполнении заказа
CREATE OR REPLACE FUNCTION set_order_completion_date()
RETURNS TRIGGER AS $$
BEGIN
    NEW.date_order_completed := CURRENT_DATE;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_set_completion_date BEFORE
UPDATE ON orders FOR EACH ROW WHEN (
    NEW.date_order_completed IS NOT NULL
)
EXECUTE FUNCTION set_order_completion_date ();

-- 2. Триггер для проверки возраста сотрудника при добавлении или обновлении записи в таблице employees (минимум 18 лет)
CREATE OR REPLACE FUNCTION check_employee_age()
RETURNS TRIGGER AS $$
DECLARE
    age INTEGER;
BEGIN
    age := DATE_PART('year', AGE(NEW.birthday_employee));
    IF age < 18 THEN
        RAISE EXCEPTION 'Employee must be at least 18 years old.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_employee_age BEFORE INSERT
OR
UPDATE ON employees FOR EACH ROW
EXECUTE FUNCTION check_employee_age ();

-- 3. Триггер для автоматической установки скидки по умолчанию на 5% при добавлении купона с нулевой скидкой
CREATE OR REPLACE FUNCTION set_default_coupon_discount()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.coupon_discount <= 0 THEN
        NEW.coupon_discount := 5;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_set_default_coupon_discount BEFORE INSERT ON coupons FOR EACH ROW
EXECUTE FUNCTION set_default_coupon_discount ();

-- 3 trigger test

INSERT INTO
    coupons (coupon_name, coupon_discount)
VALUES ('Пробный купон', 0);

SELECT * FROM coupons WHERE coupon_name = 'Пробный купон';

-- 1 trigger test

INSERT INTO
    orders (
        ID_client,
        ID_employee,
        ID_coupon,
        date_order
    )
VALUES (1, 1, 1, '2024-06-01');

UPDATE orders
SET
    date_order_completed = '2024-06-15'
WHERE
    ID_order = 1;

SELECT * FROM orders WHERE ID_order = 1;

SELECT o.ID_order, e.fullname_employee, c.fullname_client, SUM(
        s.price_service * oc.amount_compositions
    ) AS total_order_price
FROM
    orders o
    JOIN employees e ON o.ID_employee = e.ID_employee
    JOIN clients c ON o.ID_client = c.ID_client
    JOIN order_compositions oc ON o.ID_order = oc.ID_order
    JOIN services s ON oc.ID_service = s.ID_service
GROUP BY
    o.ID_order,
    e.fullname_employee,
    c.fullname_client
ORDER BY o.ID_order;