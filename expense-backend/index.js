const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');

const expensesRouter = require('./routes/expenses');

const app = express();
const PORT = 3000;

//---- Middleware --------//
app.use(cors());
app.use(bodyParser.json());

// Routes
app.use('/expenses', expensesRouter);

//----------- Default route -------------------//
app.get('/', (req, res) => {
  res.send('Expense Tracker API is running');
});

//------------------ Start server ------------------------------//
app.listen(PORT, () => {
  console.log(`Server is running on http://192.168.x.x:${PORT}`);
});
