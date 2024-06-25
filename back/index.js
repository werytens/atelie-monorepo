const express = require('express');
const { Pool } = require('pg');
const cors = require('cors');
const bodyParser = require('body-parser');

const app = express();
const port = 4000;

// Настройка подключения к базе данных
const pool = new Pool({
  user: 'postgres',
  host: 'localhost',
  database: 'atelie_3',
  password: '1234',
  port: 5432,
});

app.use(cors());
app.use(bodyParser.json());

// Функция для выполнения запроса к базе данных
const query = async (text, params) => {
  const client = await pool.connect();
  try {
    const res = await client.query(text, params);
    return res;
  } finally {
    client.release();
  }
};

// Эндпоинты для таблицы clients
app.get('/clients', async (req, res) => {
  try {
    const result = await query('SELECT * FROM clients');
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post('/clients', async (req, res) => {
  const { client_name, client_phone, client_address, client_email } = req.body;
  try {
    await query('CALL create_client($1, $2, $3, $4)', [client_name, client_phone, client_address, client_email]);
    res.status(201).json({ message: 'Client created successfully' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Эндпоинты для таблицы positions
app.get('/positions', async (req, res) => {
  try {
    const result = await query('SELECT * FROM positions');
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post('/positions', async (req, res) => {
  const { position_name, position_rate } = req.body;
  try {
    await query('CALL create_position($1, $2)', [position_name, position_rate]);
    res.status(201).json({ message: 'Position created successfully' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Эндпоинты для таблицы employees
app.get('/employees', async (req, res) => {
  try {
    const result = await query('SELECT * FROM employees');
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post('/employees', async (req, res) => {
  const {
    employee_name,
    employee_position,
    employee_phone,
    employee_email,
    employee_address,
    employee_passport,
    employee_birthday,
    employee_hire_date,
    employee_termination_date,
  } = req.body;
  try {
    await query('CALL insert_employee($1, $2, $3, $4, $5, $6, $7, $8, $9)', [
      employee_name,
      employee_position,
      employee_phone,
      employee_email,
      employee_address,
      employee_passport,
      employee_birthday,
      employee_hire_date,
      employee_termination_date,
    ]);
    res.status(201).json({ message: 'Employee created successfully' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Эндпоинты для таблицы services
app.get('/services', async (req, res) => {
  try {
    const result = await query('SELECT * FROM services');
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post('/services', async (req, res) => {
  const { service_name, service_price } = req.body;
  try {
    await query('CALL insert_service($1, $2)', [service_name, service_price]);
    res.status(201).json({ message: 'Service created successfully' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Эндпоинты для таблицы orders
app.get('/orders', async (req, res) => {
  try {
    const result = await query('SELECT * FROM orders');
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post('/orders', async (req, res) => {
  const { client_id, employee_id, coupon_id, order_date } = req.body;
  try {
    await query('CALL insert_order($1, $2, $3, $4)', [client_id, employee_id, coupon_id, order_date]);
    res.status(201).json({ message: 'Order created successfully' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Эндпоинты для таблицы coupons
app.get('/coupons', async (req, res) => {
  try {
    const result = await query('SELECT * FROM coupons');
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post('/coupon', async (req, res) => {
  const { coupon_name, coupon_discount } = req.body;
  try {
    await query('CALL insert_coupons($1, $2)', [coupon_name, coupon_discount]);
    res.status(201).json({ message: 'Coupon created successfully' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Эндпоинты для таблицы order_compositions
app.get('/order_compositions', async (req, res) => {
  try {
    const result = await query('SELECT * FROM order_compositions');
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post('/order_compositions', async (req, res) => {
  const { order_id, service_id, amount_compositions } = req.body;
  try {
    await query('CALL insert_order_composition($1, $2, $3)', [order_id, service_id, amount_compositions]);
    res.status(201).json({ message: 'Order composition created successfully' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post('/complete_order', async (req, res) => {
  const {order_id} = req.body;

  try {
    await query('CALL complete_order($1);', [order_id]);
    res.status(201).json({ message: 'Order completed successfully' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
})

// Эндпоинты для таблицы client_reviews
app.get('/client_reviews', async (req, res) => {
  try {
    const result = await query('SELECT * FROM client_reviews');
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post('/client_reviews', async (req, res) => {
  const { client_id, order_id, review_text } = req.body;
  try {
    await query('CALL add_client_review($1, $2, $3)', [client_id, order_id, review_text]);
    res.status(201).json({ message: 'Client review created successfully' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});