import aedes from "aedes";
import net from "net";
import http from "http";
import { WebSocketServer } from "ws";
import websocketStream from "websocket-stream";

const aedesInstance = aedes();

// --- MQTT TCP broker ---
const TCP_PORT = 1884;
const tcpServer = net.createServer(aedesInstance.handle);

tcpServer.listen(TCP_PORT, () => {
  console.log(`🚀 MQTT TCP broker running on port ${TCP_PORT}`);
});

// --- MQTT over WebSocket ---
const WS_PORT = 9001;
const httpServer = http.createServer((req, res) => {
  // Cho phép CORS khi browser test handshake HTTP
  res.writeHead(200, {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
    "Access-Control-Allow-Headers": "Content-Type",
  });
  res.end("MQTT WebSocket broker running\n");
});

const wss = new WebSocketServer({ server: httpServer });

wss.on("connection", (ws, req) => {
  const stream = websocketStream(ws);
  aedesInstance.handle(stream);
  console.log("🔗 WebSocket client connected:", req.socket.remoteAddress);
});

httpServer.listen(WS_PORT, () => {
  console.log(`🌐 MQTT WebSocket broker running on ws://localhost:${WS_PORT}`);
});

// --- Debug logs (optional) ---
aedesInstance.on("clientReady", (client) => {
  console.log("✅ MQTT client connected:", client?.id);
});

aedesInstance.on("publish", (packet, client) => {
  if (client) {
    console.log(`📨 Message from ${client.id}: ${packet.topic} → ${packet.payload}`);
  }
});
