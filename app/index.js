const express = require('express');
const promClient = require('prom-client');
const os = require('os');

const app = express();
const port = 3000;


app.get('/', (req, res) => {
    res.send("hello")

})



app.listen(port, () => {
    console.log(`App is Running on Port ${port}`)
});