const express = require('express');
const promClient = require('prom-client');
const os = require('os');


const app = express();
const PORT = process.env.PORT || 3000;



//********/ Prometheus Metrics ********/


const collectDefaultMetrics = promClient.collectDefaultMetrics;
collectDefaultMetrics({
    timeout: 5000
});

const httpRequestDuration = new promClient.Histogram({
    name: 'http_request_duration_seconds',
    help: 'Duration of HTTP requests in seconds',
    labelNames: ['method', 'route', 'status_code'],
    buckets: [0.1, 0.5, 1, 2, 5, 10]
});

const httpRequestTotal = new promClient.Counter({
    name: 'http_requests_total',
    help: 'Total number of HTTP requests',
    labelNames: ['method', 'route', 'status_code']
});

//******************************
//* middleware to track all  requests */
//******************************

app.use((req, res, next) => {
    const start = Date.now();
    res.on('finish', () => {
        const duration = (Date.now() - start) / 1000;
        httpRequestDuration
            .labels(req.method, req.route?.path || req.path, res.statusCode)
            .observe(duration);
        httpRequestTotal
            .labels(req.method, req.route?.path || req.path, res.statusCode)
            .inc();
    });
    next();
})


// routes


app.get('/', (req, res) => {
    res.json({
        message: "hello from aws eks demo app",
        version: process.env.APP_VERSION || "1.0.0",
        hostname: os.hostname(),


    })

})


app.get('/health', (req, res) => {
    res.json({ message: "OK", status: "healthy", timeStamp: new Date().toISOString() })
});


app.get('/metrics', async (req, res) => {
    res.set('Content-Type', promClient.register.contentType);
    res.end(await promClient.register.metrics());
});

app.use((req, res) => {
    res.status(404).json({ error: "Not Found" })
});


app.listen(PORT, () => {
    console.log(`App is Running on Port ${PORT}`)
});