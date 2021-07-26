const express = require('express'),
    app = express(),
    server = require('http').Server(app),
    cors = require('cors'),
    path = require('path');

app.use(cors());
app.use(express.static(path.join(__dirname, '../build/web')));

// RestAPI
app.get('/data/all', (req,res) => res.json({
    client: req.headers["user-agent"],
    title : 'MyNodeJsServer',
    data : 'MyNodeJsServerData'
}));

// Flutter
app.get('*', (req,res) => res.sendFile(path.join(__dirname, '../build/web/index.html')));

server.listen(8900, () => console.log(8900));