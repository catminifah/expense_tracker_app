const express = require('express');
const router = express.Router();
const db = require('../db');

// ดึงรายการทั้งหมด
router.get('/', (req, res) => {
  db.query('SELECT * FROM expenses ORDER BY id DESC', (err, result) => {
    if (err) return res.status(500).json({ error: err });
    res.json(result);
  });
});

// เพิ่มรายการใหม่
router.post('/', (req, res) => {
  const { title, amount, category } = req.body;
  db.query(
    'INSERT INTO expenses (title, amount, category) VALUES (?, ?, ?)',
    [title, amount, category],
    (err, result) => {
      if (err) return res.status(500).json({ error: err });
      res.json({ id: result.insertId, title, amount, category });
    }
  );
});

module.exports = router;
