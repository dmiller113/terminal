const express = require('express');
const app = express();

app.use(express.static('src/template'));
app.use(express.static('src'));
app.use(express.static('src/script'));

app.listen(4000, '0.0.0.0')
