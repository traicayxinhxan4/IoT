// import React, { useEffect, useState } from 'react';
// import axios from 'axios';
// import {
//   Box, Button, Card, CardContent, Container, Divider,
//   TextField, Typography, Dialog, DialogTitle,
//   DialogContent, DialogActions
// } from '@mui/material';
// import SendIcon from '@mui/icons-material/Send';
// import AddIcon from '@mui/icons-material/Add';
// import VisibilityIcon from '@mui/icons-material/Visibility';
// import { Select, MenuItem, FormControl, InputLabel } from '@mui/material';

// function App() {
//   const [devices, setDevices] = useState([]);
//   const [newDevice, setNewDevice] = useState({ name: '', topic: '' });
//   const [payloads, setPayloads] = useState({});
//   const [telemetry, setTelemetry] = useState([]);
//   const [selectedDevice, setSelectedDevice] = useState(null);
//   const [openDialog, setOpenDialog] = useState(false);

//   useEffect(() => {
//     fetchDevices();
//   }, []);

//   const fetchDevices = async () => {
//     const res = await axios.get('http://localhost:8080/devices');
//     setDevices(res.data);
//     const initPayloads = {};
//     res.data.forEach(d => initPayloads[d.id] = d.status || "LED_OFF");
//     setPayloads(initPayloads);
//   };

//   // const handleSend = async (id) => {
//   //   const payload = payloads[id];
//   //   await axios.post(`http://localhost:8080/devices/${id}/control`, payload, {
//   //     headers: { 'Content-Type': 'text/plain' }
//   //   });
//   //   fetchDevices(); // ✅ reload trạng thái từ server
//   // };
//   const handleSend = async (id) => {
//     const payload = payloads[id];
//     await axios.post(`http://localhost:8080/devices/${id}/control`, payload, {
//       headers: { 'Content-Type': 'text/plain' }
//     });
//     // ✅ cập nhật local state ngay thay vì fetchDevices
//     setPayloads(prev => ({ ...prev, [id]: payload }));
//     setDevices(prev => prev.map(d => d.id === id ? { ...d, status: payload } : d));
//   };

//   const handleLedOn = async (id) => {
//     await axios.post(`http://localhost:8080/devices/${id}/led/on`);
//     setPayloads(prev => ({ ...prev, [id]: "LED_ON" }));
//     setDevices(prev => prev.map(d => d.id === id ? { ...d, status: "LED_ON" } : d));
//   };

//   const handleLedOff = async (id) => {
//     await axios.post(`http://localhost:8080/devices/${id}/led/off`);
//     setPayloads(prev => ({ ...prev, [id]: "LED_OFF" }));
//     setDevices(prev => prev.map(d => d.id === id ? { ...d, status: "LED_OFF" } : d));
//   };

//   const handleCreate = async () => {
//     if (!newDevice.name || !newDevice.topic) return;
//     await axios.post('http://localhost:8080/devices', newDevice);
//     setNewDevice({ name: '', topic: '' });
//     fetchDevices();
//   };

//   const fetchTelemetry = async (deviceId) => {
//     const res = await axios.get(`http://localhost:8080/telemetry/${deviceId}`);
//     return res.data;
//   };

//   const handleViewTelemetry = async (device) => {
//     const data = await fetchTelemetry(device.id);
//     setTelemetry(data);
//     setSelectedDevice(device);
//     setOpenDialog(true);
//   };

//   return (
//     <Container maxWidth="sm" sx={{ mt: 4 }}>
//       <Typography variant="h4" textAlign="center" fontWeight="bold" gutterBottom>
//         📡 IoT Device Dashboard
//       </Typography>

//       <Typography variant="h6" gutterBottom>📋 Danh sách thiết bị</Typography>
//       {devices.map(device => (
//         <Card key={device.id} sx={{ mb: 2, backgroundColor: payloads[device.id] === "LED_ON" ? "#e0ffe0" : "#ffe0e0" }}>
//           <CardContent>
//             <Typography fontWeight="bold">{device.name}</Typography>
//             <Typography variant="body2" gutterBottom>MQTT Topic: {device.topic}</Typography>

//             <FormControl fullWidth sx={{ mt: 1, mb: 2 }}>
//               <InputLabel>Lệnh điều khiển</InputLabel>
//               <Select
//                 value={payloads[device.id] || "LED_ON"} // mặc định LED_ON
//                 label="Lệnh điều khiển"
//                 onChange={(e) => setPayloads({ ...payloads, [device.id]: e.target.value })}
//               >
//                 <MenuItem value="LED_ON">LED_ON</MenuItem>
//                 <MenuItem value="LED_OFF">LED_OFF</MenuItem>
//               </Select>
//             </FormControl>

//             {/* ✅ Hai nút nằm cùng dòng, giống Flutter */}
//             <Box display="flex" justifyContent="flex-end" gap={1}>
//               <Button
//                 variant="contained"
//                 onClick={() => handleSend(device.id)}
//                 endIcon={<SendIcon />}
//                 sx={{ textTransform: 'none' }}
//               >
//                 GỬI LỆNH
//               </Button>

//               {/* <Button
//                 variant="contained"
//                 color="success"
//                 onClick={() => {
//                   axios.post(`http://localhost:8080/devices/${device.id}/led/on`)
//                     .then(fetchDevices); // ✅ đồng bộ ngay
//                 }}
//               > */}
//               <Button variant="contained" color="success" onClick={() => handleLedOn(device.id)}>
//                 BẬT LED
//               </Button>

//               {/* <Button
//                 variant="contained"
//                 color="error"
//                 onClick={() => {
//                   axios.post(`http://localhost:8080/devices/${device.id}/led/off`)
//                     .then(fetchDevices); // ✅ đồng bộ ngay
//                 }}
//               > */}
//               <Button variant="contained" color="error" onClick={() => handleLedOff(device.id)}>
//                 TẮT LED
//               </Button>
//             </Box>
//           </CardContent>
//         </Card>
//       ))}

//       <Divider sx={{ my: 3 }} />

//       <Typography variant="h6" gutterBottom>➕ Thêm thiết bị mới</Typography>
//       <TextField
//         fullWidth
//         label="Tên thiết bị"
//         variant="outlined"
//         sx={{ mb: 2 }}
//         value={newDevice.name}
//         onChange={(e) => setNewDevice({ ...newDevice, name: e.target.value })}
//       />
//       <TextField
//         fullWidth
//         label="Topic MQTT"
//         variant="outlined"
//         sx={{ mb: 2 }}
//         value={newDevice.topic}
//         onChange={(e) => setNewDevice({ ...newDevice, topic: e.target.value })}
//       />
//       <Button
//         variant="contained"
//         fullWidth
//         onClick={handleCreate}
//         startIcon={<AddIcon />}
//         sx={{ textTransform: 'none' }}
//       >
//         TẠO THIẾT BỊ
//       </Button>

//       {/* Dialog hiển thị telemetry */}
//       {selectedDevice && (
//         <Dialog open={openDialog} onClose={() => setOpenDialog(false)} fullWidth maxWidth="sm">
//           <DialogTitle>Telemetry - {selectedDevice.name}</DialogTitle>
//           <DialogContent dividers>
//             {telemetry.length === 0 ? (
//               <Typography>Không có dữ liệu</Typography>
//             ) : (
//               telemetry.map((t, i) => (
//                 <Box key={i} sx={{ mb: 1 }}>
//                   <Typography><b>Giá trị:</b> {t.value}</Typography>
//                   <Typography variant="caption" color="text.secondary">{t.timestamp}</Typography>
//                 </Box>
//               ))
//             )}
//           </DialogContent>
//           <DialogActions>
//             <Button onClick={() => setOpenDialog(false)}>Đóng</Button>
//           </DialogActions>
//         </Dialog>
//       )}
//     </Container>
//   );
// }

// export default App;



// import React, { useEffect, useState } from 'react';
// import axios from 'axios';
// import mqtt from 'mqtt';
// import {
//   Box, Button, Card, CardContent, Container, Divider,
//   TextField, Typography, Dialog, DialogTitle,
//   DialogContent, DialogActions, Select, MenuItem, FormControl, InputLabel
// } from '@mui/material';
// import SendIcon from '@mui/icons-material/Send';
// import AddIcon from '@mui/icons-material/Add';

// function App() {
//   const [devices, setDevices] = useState([]);
//   const [newDevice, setNewDevice] = useState({ name: '', topic: '' });
//   const [payloads, setPayloads] = useState({});
//   const [telemetry, setTelemetry] = useState([]);
//   const [selectedDevice, setSelectedDevice] = useState(null);
//   const [openDialog, setOpenDialog] = useState(false);
//   const [mqttClient, setMqttClient] = useState(null);

//   // ✅ Kết nối MQTT khi app load
//   useEffect(() => {
//     fetchDevices();

//     // Kết nối MQTT WebSocket broker
//     const client = mqtt.connect('ws://localhost:9001');
//     setMqttClient(client);

//     client.on('connect', () => {
//       console.log('✅ Web connected to MQTT broker');
//       client.subscribe('/sensor/led');
//     });

//     // Khi có message từ MQTT → cập nhật giao diện ngay
//     client.on('message', (topic, message) => {
//       const payload = message.toString();
//       console.log('📩 MQTT:', topic, payload);

//       if (topic === '/sensor/led') {
//         setDevices(prev =>
//           prev.map(d => ({ ...d, status: payload }))
//         );
//         setPayloads(prev => {
//           const newPayloads = { ...prev };
//           Object.keys(newPayloads).forEach(k => {
//             newPayloads[k] = payload;
//           });
//           return newPayloads;
//         });
//       }
//     });

//     return () => client.end(); // cleanup
//   }, []);

//   const fetchDevices = async () => {
//     const res = await axios.get('http://localhost:8080/devices');
//     setDevices(res.data);
//     const initPayloads = {};
//     res.data.forEach(d => (initPayloads[d.id] = d.status || 'LED_OFF'));
//     setPayloads(initPayloads);
//   };

//   const handleSend = async (id) => {
//     const payload = payloads[id];
//     await axios.post(`http://localhost:8080/devices/${id}/control`, payload, {
//       headers: { 'Content-Type': 'text/plain' },
//     });
//     mqttClient?.publish('/sensor/led', payload); // publish tới MQTT
//     setDevices(prev => prev.map(d => (d.id === id ? { ...d, status: payload } : d)));
//   };

//   const handleLedOn = async (id) => {
//     await axios.post(`http://localhost:8080/devices/${id}/led/on`);
//     mqttClient?.publish('/sensor/led', 'LED_ON');
//     setDevices(prev => prev.map(d => (d.id === id ? { ...d, status: 'LED_ON' } : d)));
//   };

//   const handleLedOff = async (id) => {
//     await axios.post(`http://localhost:8080/devices/${id}/led/off`);
//     mqttClient?.publish('/sensor/led', 'LED_OFF');
//     setDevices(prev => prev.map(d => (d.id === id ? { ...d, status: 'LED_OFF' } : d)));
//   };

//   const handleCreate = async () => {
//     if (!newDevice.name || !newDevice.topic) return;
//     await axios.post('http://localhost:8080/devices', newDevice);
//     setNewDevice({ name: '', topic: '' });
//     fetchDevices();
//   };

//   const fetchTelemetry = async (deviceId) => {
//     const res = await axios.get(`http://localhost:8080/telemetry/${deviceId}`);
//     return res.data;
//   };

//   const handleViewTelemetry = async (device) => {
//     const data = await fetchTelemetry(device.id);
//     setTelemetry(data);
//     setSelectedDevice(device);
//     setOpenDialog(true);
//   };

//   return (
//     <Container maxWidth="sm" sx={{ mt: 4 }}>
//       <Typography variant="h4" textAlign="center" fontWeight="bold" gutterBottom>
//         📡 IoT Device Dashboard
//       </Typography>

//       <Typography variant="h6" gutterBottom>📋 Danh sách thiết bị</Typography>
//       {devices.map((device) => (
//         <Card
//           key={device.id}
//           sx={{
//             mb: 2,
//             backgroundColor:
//               device.status === 'LED_ON' ? '#e0ffe0' : '#ffe0e0',
//           }}
//         >
//           <CardContent>
//             <Typography fontWeight="bold">{device.name}</Typography>
//             <Typography variant="body2" gutterBottom>
//               MQTT Topic: {device.topic}
//             </Typography>

//             <FormControl fullWidth sx={{ mt: 1, mb: 2 }}>
//               <InputLabel>Lệnh điều khiển</InputLabel>
//               <Select
//                 value={payloads[device.id] || 'LED_ON'}
//                 label="Lệnh điều khiển"
//                 // onChange={(e) =>
//                 //   setPayloads({ ...payloads, [device.id]: e.target.value })
//                 // }
//                 onChange={(e) => {
//                   const newValue = e.target.value;

//                   // ✅ Cập nhật payload local
//                   setPayloads({ ...payloads, [device.id]: newValue });

//                   // ✅ Cập nhật luôn status để card đổi màu ngay
//                   setDevices(prev =>
//                     prev.map(d =>
//                       d.id === device.id ? { ...d, status: newValue } : d
//                     )
//                   );
//                 }}
//               >
//                 <MenuItem value="LED_ON">LED_ON</MenuItem>
//                 <MenuItem value="LED_OFF">LED_OFF</MenuItem>
//               </Select>
//             </FormControl>

//             <Box display="flex" justifyContent="flex-end" gap={1}>
//               <Button
//                 variant="contained"
//                 onClick={() => handleSend(device.id)}
//                 endIcon={<SendIcon />}
//                 sx={{ textTransform: 'none' }}
//               >
//                 GỬI LỆNH
//               </Button>
//               <Button
//                 variant="contained"
//                 color="success"
//                 onClick={() => handleLedOn(device.id)}
//               >
//                 BẬT LED
//               </Button>
//               <Button
//                 variant="contained"
//                 color="error"
//                 onClick={() => handleLedOff(device.id)}
//               >
//                 TẮT LED
//               </Button>
//             </Box>
//           </CardContent>
//         </Card>
//       ))}

//       <Divider sx={{ my: 3 }} />

//       <Typography variant="h6" gutterBottom>➕ Thêm thiết bị mới</Typography>
//       <TextField
//         fullWidth
//         label="Tên thiết bị"
//         variant="outlined"
//         sx={{ mb: 2 }}
//         value={newDevice.name}
//         onChange={(e) => setNewDevice({ ...newDevice, name: e.target.value })}
//       />
//       <TextField
//         fullWidth
//         label="Topic MQTT"
//         variant="outlined"
//         sx={{ mb: 2 }}
//         value={newDevice.topic}
//         onChange={(e) => setNewDevice({ ...newDevice, topic: e.target.value })}
//       />
//       <Button
//         variant="contained"
//         fullWidth
//         onClick={handleCreate}
//         startIcon={<AddIcon />}
//         sx={{ textTransform: 'none' }}
//       >
//         TẠO THIẾT BỊ
//       </Button>

//       {selectedDevice && (
//         <Dialog
//           open={openDialog}
//           onClose={() => setOpenDialog(false)}
//           fullWidth
//           maxWidth="sm"
//         >
//           <DialogTitle>Telemetry - {selectedDevice.name}</DialogTitle>
//           <DialogContent dividers>
//             {telemetry.length === 0 ? (
//               <Typography>Không có dữ liệu</Typography>
//             ) : (
//               telemetry.map((t, i) => (
//                 <Box key={i} sx={{ mb: 1 }}>
//                   <Typography>
//                     <b>Giá trị:</b> {t.value}
//                   </Typography>
//                   <Typography variant="caption" color="text.secondary">
//                     {t.timestamp}
//                   </Typography>
//                 </Box>
//               ))
//             )}
//           </DialogContent>
//           <DialogActions>
//             <Button onClick={() => setOpenDialog(false)}>Đóng</Button>
//           </DialogActions>
//         </Dialog>
//       )}
//     </Container>
//   );
// }

// export default App;


// import React, { useEffect, useState, useRef } from 'react';
// import axios from 'axios';
// import mqtt from 'mqtt';
// import {
//   Box, Button, Card, CardContent, Container, Divider,
//   TextField, Typography, Dialog, DialogTitle,
//   DialogContent, DialogActions, Select, MenuItem, FormControl, InputLabel,
//   IconButton, Stack, Snackbar, Alert
// } from '@mui/material';
// import SendIcon from '@mui/icons-material/Send';
// import AddIcon from '@mui/icons-material/Add';
// import MicIcon from '@mui/icons-material/Mic';
// import MicOffIcon from '@mui/icons-material/MicOff';

// function App() {
//   const [devices, setDevices] = useState([]);
//   const [newDevice, setNewDevice] = useState({ name: '', topic: '' });
//   const [payloads, setPayloads] = useState({});
//   const [telemetry, setTelemetry] = useState([]);
//   const [selectedDevice, setSelectedDevice] = useState(null);
//   const [openDialog, setOpenDialog] = useState(false);
//   const [mqttClient, setMqttClient] = useState(null);

//   // mic state: which device id is currently listening
//   const [listeningFor, setListeningFor] = useState(null);
//   const recognitionRef = useRef(null);
//   const [snack, setSnack] = useState({ open: false, severity: 'info', message: '' });

//   // check speech support
//   const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition || null;

//   useEffect(() => {
//     fetchDevices();

//     // connect to MQTT WebSocket broker
//     const client = mqtt.connect('ws://localhost:9001'); // your broker
//     setMqttClient(client);

//     client.on('connect', () => {
//       console.log('✅ Web connected to MQTT broker');
//       client.subscribe('/sensor/led', (err) => {
//         if (err) console.warn('subscribe error', err);
//       });
//     });

//     client.on('message', (topic, message) => {
//       const payload = message.toString();
//       console.log('📩 MQTT:', topic, payload);

//       if (topic === '/sensor/led') {
//         // update all devices or specific logic (we update each device status to payload)
//         setDevices(prev =>
//           prev.map(d => ({ ...d, status: payload }))
//         );

//         setPayloads(prev => {
//           const newPayloads = { ...prev };
//           Object.keys(newPayloads).forEach(k => {
//             newPayloads[k] = payload;
//           });
//           return newPayloads;
//         });
//       }
//     });

//     client.on('error', (err) => {
//       console.error('MQTT error', err);
//       setSnack({ open: true, severity: 'error', message: 'MQTT connection error' });
//     });

//     return () => {
//       client.end();
//     };
//     // eslint-disable-next-line react-hooks/exhaustive-deps
//   }, []);

//   const fetchDevices = async () => {
//     try {
//       const res = await axios.get('http://localhost:8080/devices');
//       setDevices(res.data);
//       const initPayloads = {};
//       res.data.forEach(d => (initPayloads[d.id] = d.status || 'LED_OFF'));
//       setPayloads(initPayloads);
//     } catch (err) {
//       console.error('fetchDevices error', err);
//       setSnack({ open: true, severity: 'error', message: 'Không thể tải danh sách thiết bị' });
//     }
//   };

//   const publishAndUpdate = (topic, payload, deviceId) => {
//     if (mqttClient?.connected) {
//       mqttClient.publish(topic, payload);
//     } else {
//       console.warn('MQTT not connected, still calling backend API');
//     }
//     // update UI local immediately
//     setDevices(prev => prev.map(d => (d.id === deviceId ? { ...d, status: payload } : d)));
//     setPayloads(prev => ({ ...prev, [deviceId]: payload }));
//   };

//   const handleCreate = async () => {
//     if (!newDevice.name || !newDevice.topic) return;
//     await axios.post('http://localhost:8080/devices', newDevice);
//     setNewDevice({ name: '', topic: '' });
//     fetchDevices();
//   };

//   const handleSend = async (id) => {
//     const payload = payloads[id];
//     try {
//       await axios.post(`http://localhost:8080/devices/${id}/control`, payload, {
//         headers: { 'Content-Type': 'text/plain' },
//       });
//       publishAndUpdate('/sensor/led', payload, id);
//       setSnack({ open: true, severity: 'success', message: 'Lệnh đã gửi' });
//     } catch (err) {
//       console.error(err);
//       setSnack({ open: true, severity: 'error', message: 'Gửi lệnh thất bại' });
//     }
//   };

//   const handleLedOn = async (id) => {
//     try {
//       await axios.post(`http://localhost:8080/devices/${id}/led/on`);
//       publishAndUpdate('/sensor/led', 'LED_ON', id);
//       setSnack({ open: true, severity: 'success', message: 'Bật LED' });
//     } catch (err) {
//       console.error(err);
//       setSnack({ open: true, severity: 'error', message: 'Bật LED thất bại' });
//     }
//   };

//   const handleLedOff = async (id) => {
//     try {
//       await axios.post(`http://localhost:8080/devices/${id}/led/off`);
//       publishAndUpdate('/sensor/led', 'LED_OFF', id);
//       setSnack({ open: true, severity: 'success', message: 'Tắt LED' });
//     } catch (err) {
//       console.error(err);
//       setSnack({ open: true, severity: 'error', message: 'Tắt LED thất bại' });
//     }
//   };

//   // VOICE functions
//   const startListeningFor = (device) => {
//     if (!SpeechRecognition) {
//       setSnack({ open: true, severity: 'warning', message: 'Trình duyệt không hỗ trợ giọng nói (Web Speech API)' });
//       return;
//     }

//     // If currently listening for another device, stop it first
//     if (listeningFor !== null) {
//       stopListening();
//     }

//     const recognition = new SpeechRecognition();
//     recognition.lang = 'vi-VN'; // Vietnamese
//     recognition.interimResults = false;
//     recognition.maxAlternatives = 1;
//     recognition.continuous = false;

//     recognition.onstart = () => {
//       setListeningFor(device.id);
//       console.log('Listening started for device', device.id);
//     };

//     recognition.onresult = (event) => {
//       const text = (event.results[0][0].transcript || '').toLowerCase();
//       console.log('Recognized text:', text);

//       // simple mapping
//       let payload = null;
//       if (text.includes('bật') || text.includes('mở') || text.includes('on')) {
//         payload = 'LED_ON';
//       } else if (text.includes('tắt') || text.includes('đóng') || text.includes('off')) {
//         payload = 'LED_OFF';
//       } else {
//         // try to match "bật đèn" or "tắt đèn"
//         if (text.includes('đèn') && text.includes('bật')) payload = 'LED_ON';
//         if (text.includes('đèn') && text.includes('tắt')) payload = 'LED_OFF';
//       }

//       if (payload) {
//         // set local payload
//         setPayloads(prev => ({ ...prev, [device.id]: payload }));
//         // call API + mqtt publish
//         axios.post(`http://localhost:8080/devices/${device.id}/control`, payload, {
//           headers: { 'Content-Type': 'text/plain' },
//         }).then(() => {
//           publishAndUpdate('/sensor/led', payload, device.id);
//           setSnack({ open: true, severity: 'success', message: `Lệnh '${payload}' gửi cho ${device.name}` });
//         }).catch(err => {
//           console.error(err);
//           setSnack({ open: true, severity: 'error', message: 'Gửi lệnh thất bại' });
//         });
//       } else {
//         setSnack({ open: true, severity: 'info', message: `Không hiểu lệnh: "${text}"` });
//       }
//     };

//     recognition.onerror = (e) => {
//       console.error('recognition error', e);
//       setSnack({ open: true, severity: 'error', message: 'Lỗi khi nhận giọng nói' });
//     };

//     recognition.onend = () => {
//       console.log('Recognition ended');
//       setListeningFor(null);
//     };

//     recognition.start();
//     recognitionRef.current = recognition;
//   };

//   const stopListening = () => {
//     if (recognitionRef.current) {
//       try {
//         recognitionRef.current.onresult = null;
//         recognitionRef.current.onend = null;
//         recognitionRef.current.onerror = null;
//         recognitionRef.current.stop();
//       } catch (e) {
//         // ignore
//       }
//       recognitionRef.current = null;
//     }
//     setListeningFor(null);
//   };

//   // telemetry helpers
//   const fetchTelemetry = async (deviceId) => {
//     const res = await axios.get(`http://localhost:8080/telemetry/${deviceId}`);
//     return res.data;
//   };

//   const handleViewTelemetry = async (device) => {
//     const data = await fetchTelemetry(device.id);
//     setTelemetry(data);
//     setSelectedDevice(device);
//     setOpenDialog(true);
//   };

//   // UI render
//   return (
//     <Container maxWidth="sm" sx={{ mt: 4 }}>
//       <Typography variant="h4" textAlign="center" fontWeight="bold" gutterBottom>
//         📡 IoT Device Controller
//       </Typography>

//       <Typography variant="h6" gutterBottom>📋 Danh sách thiết bị</Typography>
//       {devices.map((device) => (
//         <Card
//           key={device.id}
//           sx={{
//             mb: 2,
//             backgroundColor:
//               device.status === 'LED_ON' ? '#e0ffe0' : '#ffe0e0',
//           }}
//         >
//           <CardContent>
//             <Box display="flex" alignItems="center" justifyContent="space-between">
//               <Box>
//                 <Typography fontWeight="bold">{device.name}</Typography>
//                 <Typography variant="body2" gutterBottom>
//                   MQTT Topic: {device.topic}
//                 </Typography>
//               </Box>

//               <Stack direction="row" spacing={1} alignItems="center">
//                 <IconButton
//                   color={listeningFor === device.id ? 'error' : 'primary'}
//                   onClick={() => {
//                     if (listeningFor === device.id) {
//                       stopListening();
//                     } else {
//                       startListeningFor(device);
//                     }
//                   }}
//                   aria-label={listeningFor === device.id ? 'Stop listening' : 'Start listening'}
//                 >
//                   {listeningFor === device.id ? <MicOffIcon /> : <MicIcon />}
//                 </IconButton>

//                 <Button size="small" onClick={() => handleViewTelemetry(device)}>Telemetry</Button>
//               </Stack>
//             </Box>

//             <FormControl fullWidth sx={{ mt: 1, mb: 2 }}>
//               <InputLabel>Lệnh điều khiển</InputLabel>
//               <Select
//                 value={payloads[device.id] || 'LED_OFF'}
//                 label="Lệnh điều khiển"
//                 onChange={(e) => {
//                   const newValue = e.target.value;
//                   setPayloads({ ...payloads, [device.id]: newValue });
//                   // update card color immediately
//                   setDevices(prev =>
//                     prev.map(d =>
//                       d.id === device.id ? { ...d, status: newValue } : d
//                     )
//                   );
//                 }}
//               >
//                 <MenuItem value="LED_ON">LED_ON</MenuItem>
//                 <MenuItem value="LED_OFF">LED_OFF</MenuItem>
//               </Select>
//             </FormControl>

//             <Box display="flex" justifyContent="flex-end" gap={1}>
//               <Button
//                 variant="contained"
//                 onClick={() => handleSend(device.id)}
//                 endIcon={<SendIcon />}
//                 sx={{ textTransform: 'none' }}
//               >
//                 GỬI LỆNH
//               </Button>
//               <Button
//                 variant="contained"
//                 color="success"
//                 onClick={() => handleLedOn(device.id)}
//               >
//                 BẬT LED
//               </Button>
//               <Button
//                 variant="contained"
//                 color="error"
//                 onClick={() => handleLedOff(device.id)}
//               >
//                 TẮT LED
//               </Button>
//             </Box>
//           </CardContent>
//         </Card>
//       ))}

//       <Divider sx={{ my: 3 }} />

//       <Typography variant="h6" gutterBottom>➕ Thêm thiết bị mới</Typography>
//       <TextField
//         fullWidth
//         label="Tên thiết bị"
//         variant="outlined"
//         sx={{ mb: 2 }}
//         value={newDevice.name}
//         onChange={(e) => setNewDevice({ ...newDevice, name: e.target.value })}
//       />
//       <TextField
//         fullWidth
//         label="Topic MQTT"
//         variant="outlined"
//         sx={{ mb: 2 }}
//         value={newDevice.topic}
//         onChange={(e) => setNewDevice({ ...newDevice, topic: e.target.value })}
//       />
//       <Button
//         variant="contained"
//         fullWidth
//         onClick={async () => {
//           await handleCreate();
//         }}
//         startIcon={<AddIcon />}
//         sx={{ textTransform: 'none' }}
//       >
//         TẠO THIẾT BỊ
//       </Button>

//       {selectedDevice && (
//         <Dialog
//           open={openDialog}
//           onClose={() => setOpenDialog(false)}
//           fullWidth
//           maxWidth="sm"
//         >
//           <DialogTitle>Telemetry - {selectedDevice.name}</DialogTitle>
//           <DialogContent dividers>
//             {telemetry.length === 0 ? (
//               <Typography>Không có dữ liệu</Typography>
//             ) : (
//               telemetry.map((t, i) => (
//                 <Box key={i} sx={{ mb: 1 }}>
//                   <Typography>
//                     <b>Giá trị:</b> {t.value}
//                   </Typography>
//                   <Typography variant="caption" color="text.secondary">
//                     {t.timestamp}
//                   </Typography>
//                 </Box>
//               ))
//             )}
//           </DialogContent>
//           <DialogActions>
//             <Button onClick={() => setOpenDialog(false)}>Đóng</Button>
//           </DialogActions>
//         </Dialog>
//       )}

//       <Snackbar
//         open={snack.open}
//         autoHideDuration={3000}
//         onClose={() => setSnack(prev => ({ ...prev, open: false }))}>
//         <Alert severity={snack.severity} sx={{ width: '100%' }}>
//           {snack.message}
//         </Alert>
//       </Snackbar>
//     </Container>
//   );
// }

// export default App;


// import React, { useEffect, useState, useRef } from 'react';
// import axios from 'axios';
// import mqtt from 'mqtt';
// import {
//   Box, Button, Card, CardContent, Container, Divider,
//   TextField, Typography, Select, MenuItem, FormControl, InputLabel,
//   IconButton, Stack, Snackbar, Alert
// } from '@mui/material';
// import SendIcon from '@mui/icons-material/Send';
// import AddIcon from '@mui/icons-material/Add';
// import MicIcon from '@mui/icons-material/Mic';
// import MicOffIcon from '@mui/icons-material/MicOff';

// function App() {
//   const [devices, setDevices] = useState([]);
//   const [newDevice, setNewDevice] = useState({ name: '', topic: '' });
//   const [payloads, setPayloads] = useState({});
//   const [mqttClient, setMqttClient] = useState(null);
//   const [listeningFor, setListeningFor] = useState(null);
//   const recognitionRef = useRef(null);
//   const [snack, setSnack] = useState({ open: false, severity: 'info', message: '' });

//   const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition || null;

//   // --- MQTT setup ---
//   useEffect(() => {
//     fetchDevices();

//     const client = mqtt.connect('ws://localhost:9001');
//     setMqttClient(client);

//     client.on('connect', () => {
//       console.log('✅ Web connected to MQTT broker');
//       // subscribe wildcard để nhận tất cả topic dạng /sensor/...
//       client.subscribe('/sensor/#', (err) => {
//         if (err) console.warn('subscribe error', err);
//       });
//     });

//     client.on('message', (topic, message) => {
//       const payload = message.toString();
//       console.log('📩 MQTT:', topic, payload);

//       // chỉ update đúng device có topic khớp
//       setDevices(prev =>
//         prev.map(d =>
//           d.topic === topic ? { ...d, status: payload } : d
//         )
//       );
//       setPayloads(prev => {
//         const newPayloads = { ...prev };
//         const found = devices.find(d => d.topic === topic);
//         if (found) newPayloads[found.id] = payload;
//         return newPayloads;
//       });
//     });

//     client.on('error', (err) => {
//       console.error('MQTT error', err);
//       setSnack({ open: true, severity: 'error', message: 'MQTT connection error' });
//     });

//     return () => {
//       client.end();
//     };
//     // eslint-disable-next-line react-hooks/exhaustive-deps
//   }, []);

//   // --- REST ---
//   const fetchDevices = async () => {
//     try {
//       const res = await axios.get('http://localhost:8080/devices');
//       setDevices(res.data);
//       const initPayloads = {};
//       res.data.forEach(d => (initPayloads[d.id] = d.status || 'LED_OFF'));
//       setPayloads(initPayloads);
//     } catch (err) {
//       console.error('fetchDevices error', err);
//       setSnack({ open: true, severity: 'error', message: 'Không thể tải danh sách thiết bị' });
//     }
//   };

//   const publishAndUpdate = (topic, payload, deviceId) => {
//     if (mqttClient?.connected) {
//       mqttClient.publish(topic, payload);
//     } else {
//       console.warn('⚠️ MQTT not connected');
//     }
//     // update UI local ngay
//     setDevices(prev =>
//       prev.map(d => (d.id === deviceId ? { ...d, status: payload } : d))
//     );
//     setPayloads(prev => ({ ...prev, [deviceId]: payload }));
//   };

//   const handleCreate = async () => {
//     if (!newDevice.name || !newDevice.topic) return;
//     try {
//       const res = await axios.post('http://localhost:8080/devices', newDevice);
//       const created = res.data;
//       setDevices(prev => [...prev, created]); // thêm ngay vào danh sách
//       setPayloads(prev => ({ ...prev, [created.id]: created.status || 'LED_OFF' }));
//       setNewDevice({ name: '', topic: '' });
//       setSnack({ open: true, severity: 'success', message: 'Thêm thiết bị thành công' });
//     } catch (err) {
//       console.error(err);
//       setSnack({ open: true, severity: 'error', message: 'Không thể thêm thiết bị' });
//     }
//   };

//   const handleSend = async (id) => {
//     const device = devices.find(d => d.id === id);
//     const payload = payloads[id];
//     try {
//       await axios.post(`http://localhost:8080/devices/${id}/control`, payload, {
//         headers: { 'Content-Type': 'text/plain' },
//       });
//       publishAndUpdate(device.topic, payload, id);
//       setSnack({ open: true, severity: 'success', message: 'Lệnh đã gửi' });
//     } catch (err) {
//       console.error(err);
//       setSnack({ open: true, severity: 'error', message: 'Gửi lệnh thất bại' });
//     }
//   };

//   const handleLedOn = (device) => {
//     publishAndUpdate(device.topic, 'LED_ON', device.id);
//     axios.post(`http://localhost:8080/devices/${device.id}/led/on`);
//     setSnack({ open: true, severity: 'success', message: 'Bật LED' });
//   };

//   const handleLedOff = (device) => {
//     publishAndUpdate(device.topic, 'LED_OFF', device.id);
//     axios.post(`http://localhost:8080/devices/${device.id}/led/off`);
//     setSnack({ open: true, severity: 'success', message: 'Tắt LED' });
//   };

//   // --- Voice ---
//   const startListeningFor = (device) => {
//     if (!SpeechRecognition) {
//       setSnack({ open: true, severity: 'warning', message: 'Trình duyệt không hỗ trợ giọng nói' });
//       return;
//     }

//     if (listeningFor !== null) stopListening();

//     const recognition = new SpeechRecognition();
//     recognition.lang = 'vi-VN';
//     recognition.interimResults = false;

//     recognition.onstart = () => setListeningFor(device.id);
//     recognition.onresult = (e) => {
//       const text = e.results[0][0].transcript.toLowerCase();
//       console.log('🎤 Nghe:', text);
//       let payload = null;
//       if (text.includes('bật') || text.includes('mở') || text.includes('on')) payload = 'LED_ON';
//       else if (text.includes('tắt') || text.includes('đóng') || text.includes('off')) payload = 'LED_OFF';
//       if (payload) {
//         publishAndUpdate(device.topic, payload, device.id);
//         axios.post(`http://localhost:8080/devices/${device.id}/control`, payload, {
//           headers: { 'Content-Type': 'text/plain' },
//         });
//         setSnack({ open: true, severity: 'success', message: `Đã gửi lệnh ${payload}` });
//       } else {
//         setSnack({ open: true, severity: 'info', message: `Không hiểu lệnh: "${text}"` });
//       }
//     };
//     recognition.onend = () => setListeningFor(null);
//     recognition.onerror = (e) => {
//       console.error('Speech error', e);
//       setListeningFor(null);
//     };
//     recognition.start();
//     recognitionRef.current = recognition;
//   };

//   const stopListening = () => {
//     if (recognitionRef.current) {
//       try { recognitionRef.current.stop(); } catch {}
//       recognitionRef.current = null;
//     }
//     setListeningFor(null);
//   };

//   return (
//     <Container maxWidth="sm" sx={{ mt: 4 }}>
//       <Typography variant="h4" textAlign="center" fontWeight="bold" gutterBottom>
//         📡 IoT Device Controller
//       </Typography>

//       <Typography variant="h6" gutterBottom>📋 Danh sách thiết bị</Typography>
//       {devices.map((device) => (
//         <Card
//           key={device.id}
//           sx={{
//             mb: 2,
//             backgroundColor: device.status === 'LED_ON' ? '#e0ffe0' : '#ffe0e0',
//           }}
//         >
//           <CardContent>
//             <Box display="flex" alignItems="center" justifyContent="space-between">
//               <Box>
//                 <Typography fontWeight="bold">{device.name}</Typography>
//                 <Typography variant="body2">Topic: {device.topic}</Typography>
//               </Box>
//               <IconButton
//                 color={listeningFor === device.id ? 'error' : 'primary'}
//                 onClick={() =>
//                   listeningFor === device.id ? stopListening() : startListeningFor(device)
//                 }
//               >
//                 {listeningFor === device.id ? <MicOffIcon /> : <MicIcon />}
//               </IconButton>
//             </Box>

//             <FormControl fullWidth sx={{ mt: 1, mb: 2 }}>
//               <InputLabel>Lệnh điều khiển</InputLabel>
//               <Select
//                 value={payloads[device.id] || 'LED_OFF'}
//                 label="Lệnh điều khiển"
//                 onChange={(e) => {
//                   const newVal = e.target.value;
//                   setPayloads({ ...payloads, [device.id]: newVal });
//                   setDevices(prev =>
//                     prev.map(d => (d.id === device.id ? { ...d, status: newVal } : d))
//                   );
//                 }}
//               >
//                 <MenuItem value="LED_ON">LED_ON</MenuItem>
//                 <MenuItem value="LED_OFF">LED_OFF</MenuItem>
//               </Select>
//             </FormControl>

//             <Box display="flex" justifyContent="flex-end" gap={1}>
//               <Button variant="contained" onClick={() => handleSend(device.id)} endIcon={<SendIcon />}>
//                 GỬI
//               </Button>
//               <Button variant="contained" color="success" onClick={() => handleLedOn(device)}>
//                 BẬT
//               </Button>
//               <Button variant="contained" color="error" onClick={() => handleLedOff(device)}>
//                 TẮT
//               </Button>
//             </Box>
//           </CardContent>
//         </Card>
//       ))}

//       <Divider sx={{ my: 3 }} />

//       <Typography variant="h6" gutterBottom>➕ Thêm thiết bị mới</Typography>
//       <TextField
//         fullWidth label="Tên thiết bị" variant="outlined" sx={{ mb: 2 }}
//         value={newDevice.name} onChange={(e) => setNewDevice({ ...newDevice, name: e.target.value })}
//       />
//       <TextField
//         fullWidth label="Topic MQTT" variant="outlined" sx={{ mb: 2 }}
//         value={newDevice.topic} onChange={(e) => setNewDevice({ ...newDevice, topic: e.target.value })}
//       />
//       <Button
//         variant="contained" fullWidth startIcon={<AddIcon />} onClick={handleCreate}
//         sx={{ textTransform: 'none' }}
//       >
//         TẠO THIẾT BỊ
//       </Button>

//       <Snackbar
//         open={snack.open} autoHideDuration={3000}
//         onClose={() => setSnack(prev => ({ ...prev, open: false }))}>
//         <Alert severity={snack.severity} sx={{ width: '100%' }}>
//           {snack.message}
//         </Alert>
//       </Snackbar>
//     </Container>
//   );
// }

// export default App;


import React, { useEffect, useState, useRef } from 'react';
import axios from 'axios';
import mqtt from 'mqtt';
import {
  Box, Button, Card, CardContent, Container, Divider,
  TextField, Typography, Select, MenuItem, FormControl, InputLabel,
  IconButton, Snackbar, Alert
} from '@mui/material';
import SendIcon from '@mui/icons-material/Send';
import AddIcon from '@mui/icons-material/Add';
import MicIcon from '@mui/icons-material/Mic';
import MicOffIcon from '@mui/icons-material/MicOff';

function App() {
  const [devices, setDevices] = useState([]);
  const [newDevice, setNewDevice] = useState({ name: '', topic: '' });
  const [payloads, setPayloads] = useState({});
  const [mqttClient, setMqttClient] = useState(null);
  const [listeningFor, setListeningFor] = useState(null);
  const recognitionRef = useRef(null);
  const [snack, setSnack] = useState({ open: false, severity: 'info', message: '' });

  const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition || null;

  // --- MQTT setup ---
  useEffect(() => {
    fetchDevices();

    const client = mqtt.connect('ws://localhost:9001');
    setMqttClient(client);

    client.on('connect', () => {
      console.log('✅ Web connected to MQTT broker');
      // Subcribe tất cả topic thiết bị và topic đồng bộ
      client.subscribe('/sensor/#', (err) => {
        if (err) console.warn('subscribe error', err);
      });
      client.subscribe('/devices/update', (err) => {
        if (err) console.warn('subscribe update error', err);
      });
    });

    client.on('message', (topic, message) => {
      const payload = message.toString();
      console.log('📩 MQTT:', topic, payload);

      // 🔸 Khi có thông báo đồng bộ → tải lại danh sách thiết bị
      if (topic === '/devices/update') {
        fetchDevices();
        return;
      }

      // 🔸 Cập nhật trạng thái từng thiết bị
      setDevices(prev =>
        prev.map(d =>
          d.topic === topic ? { ...d, status: payload } : d
        )
      );
      setPayloads(prev => {
        const newPayloads = { ...prev };
        const found = devices.find(d => d.topic === topic);
        if (found) newPayloads[found.id] = payload;
        return newPayloads;
      });
    });

    client.on('error', (err) => {
      console.error('MQTT error', err);
      setSnack({ open: true, severity: 'error', message: 'MQTT connection error' });
    });

    return () => {
      client.end();
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  // --- REST ---
  const fetchDevices = async () => {
    try {
      const res = await axios.get('http://localhost:8080/devices');
      setDevices(res.data);
      const initPayloads = {};
      res.data.forEach(d => (initPayloads[d.id] = d.status || 'LED_OFF'));
      setPayloads(initPayloads);
    } catch (err) {
      console.error('fetchDevices error', err);
      setSnack({ open: true, severity: 'error', message: 'Không thể tải danh sách thiết bị' });
    }
  };

  const publishAndUpdate = (topic, payload, deviceId) => {
    if (mqttClient?.connected) {
      mqttClient.publish(topic, payload);
    } else {
      console.warn('⚠️ MQTT not connected');
    }
    setDevices(prev =>
      prev.map(d => (d.id === deviceId ? { ...d, status: payload } : d))
    );
    setPayloads(prev => ({ ...prev, [deviceId]: payload }));
  };

  const handleCreate = async () => {
    if (!newDevice.name || !newDevice.topic) return;
    try {
      const res = await axios.post('http://localhost:8080/devices', newDevice);
      const created = res.data;
      setDevices(prev => [...prev, created]);
      setPayloads(prev => ({ ...prev, [created.id]: created.status || 'LED_OFF' }));
      setNewDevice({ name: '', topic: '' });
      setSnack({ open: true, severity: 'success', message: 'Thêm thiết bị thành công' });
      // 🔸 Gửi tín hiệu MQTT để các client khác cập nhật
      // mqttClient.publish('/devices/update', 'NEW_DEVICE');
    } catch (err) {
      console.error(err);
      setSnack({ open: true, severity: 'error', message: 'Không thể thêm thiết bị' });
    }
  };

  const handleSend = async (id) => {
    const device = devices.find(d => d.id === id);
    const payload = payloads[id];
    try {
      await axios.post(`http://localhost:8080/devices/${id}/control`, payload, {
        headers: { 'Content-Type': 'text/plain' },
      });
      publishAndUpdate(device.topic, payload, id);
      mqttClient.publish('/devices/update', 'STATE_CHANGED');
      setSnack({ open: true, severity: 'success', message: 'Lệnh đã gửi' });
    } catch (err) {
      console.error(err);
      setSnack({ open: true, severity: 'error', message: 'Gửi lệnh thất bại' });
    }
  };

  const handleLedOn = (device) => {
    publishAndUpdate(device.topic, 'LED_ON', device.id);
    axios.post(`http://localhost:8080/devices/${device.id}/led/on`);
    mqttClient.publish('/devices/update', 'STATE_CHANGED');
    setSnack({ open: true, severity: 'success', message: 'Bật LED' });
  };

  const handleLedOff = (device) => {
    publishAndUpdate(device.topic, 'LED_OFF', device.id);
    axios.post(`http://localhost:8080/devices/${device.id}/led/off`);
    mqttClient.publish('/devices/update', 'STATE_CHANGED');
    setSnack({ open: true, severity: 'success', message: 'Tắt LED' });
  };

  // --- Voice ---
  const startListeningFor = (device) => {
    if (!SpeechRecognition) {
      setSnack({ open: true, severity: 'warning', message: 'Trình duyệt không hỗ trợ giọng nói' });
      return;
    }

    if (listeningFor !== null) stopListening();

    const recognition = new SpeechRecognition();
    recognition.lang = 'vi-VN';
    recognition.interimResults = false;

    recognition.onstart = () => setListeningFor(device.id);
    recognition.onresult = (e) => {
      const text = e.results[0][0].transcript.toLowerCase();
      console.log('🎤 Nghe:', text);
      let payload = null;
      if (text.includes('bật') || text.includes('mở') || text.includes('on')) payload = 'LED_ON';
      else if (text.includes('tắt') || text.includes('đóng') || text.includes('off')) payload = 'LED_OFF';
      if (payload) {
        publishAndUpdate(device.topic, payload, device.id);
        axios.post(`http://localhost:8080/devices/${device.id}/control`, payload, {
          headers: { 'Content-Type': 'text/plain' },
        });
        mqttClient.publish('/devices/update', 'STATE_CHANGED');
        setSnack({ open: true, severity: 'success', message: `Đã gửi lệnh ${payload}` });
      } else {
        setSnack({ open: true, severity: 'info', message: `Không hiểu lệnh: "${text}"` });
      }
    };
    recognition.onend = () => setListeningFor(null);
    recognition.onerror = (e) => {
      console.error('Speech error', e);
      setListeningFor(null);
    };
    recognition.start();
    recognitionRef.current = recognition;
  };

  const stopListening = () => {
    if (recognitionRef.current) {
      try { recognitionRef.current.stop(); } catch {}
      recognitionRef.current = null;
    }
    setListeningFor(null);
  };

  return (
    <Container maxWidth="sm" sx={{ mt: 4 }}>
      <Typography variant="h4" textAlign="center" fontWeight="bold" gutterBottom>
        📡 IoT Device Controller
      </Typography>

      <Typography variant="h6" gutterBottom>📋 Danh sách thiết bị</Typography>
      {devices.map((device) => (
        <Card
          key={device.id}
          sx={{
            mb: 2,
            backgroundColor: device.status === 'LED_ON' ? '#e0ffe0' : '#ffe0e0',
          }}
        >
          <CardContent>
            <Box display="flex" alignItems="center" justifyContent="space-between">
              <Box>
                <Typography fontWeight="bold">{device.name}</Typography>
                <Typography variant="body2">Topic: {device.topic}</Typography>
              </Box>
              <IconButton
                color={listeningFor === device.id ? 'error' : 'primary'}
                onClick={() =>
                  listeningFor === device.id ? stopListening() : startListeningFor(device)
                }
              >
                {listeningFor === device.id ? <MicOffIcon /> : <MicIcon />}
              </IconButton>
            </Box>

            <FormControl fullWidth sx={{ mt: 1, mb: 2 }}>
              <InputLabel>Lệnh điều khiển</InputLabel>
              <Select
                value={payloads[device.id] || 'LED_OFF'}
                label="Lệnh điều khiển"
                onChange={(e) => {
                  const newVal = e.target.value;
                  setPayloads({ ...payloads, [device.id]: newVal });
                  setDevices(prev =>
                    prev.map(d => (d.id === device.id ? { ...d, status: newVal } : d))
                  );
                }}
              >
                <MenuItem value="LED_ON">LED_ON</MenuItem>
                <MenuItem value="LED_OFF">LED_OFF</MenuItem>
              </Select>
            </FormControl>

            <Box display="flex" justifyContent="flex-end" gap={1}>
              <Button variant="contained" onClick={() => handleSend(device.id)} endIcon={<SendIcon />}>
                GỬI
              </Button>
              <Button variant="contained" color="success" onClick={() => handleLedOn(device)}>
                BẬT
              </Button>
              <Button variant="contained" color="error" onClick={() => handleLedOff(device)}>
                TẮT
              </Button>
            </Box>
          </CardContent>
        </Card>
      ))}

      <Divider sx={{ my: 3 }} />

      <Typography variant="h6" gutterBottom>➕ Thêm thiết bị mới</Typography>
      <TextField
        fullWidth label="Tên thiết bị" variant="outlined" sx={{ mb: 2 }}
        value={newDevice.name} onChange={(e) => setNewDevice({ ...newDevice, name: e.target.value })}
      />
      <TextField
        fullWidth label="Topic MQTT" variant="outlined" sx={{ mb: 2 }}
        value={newDevice.topic} onChange={(e) => setNewDevice({ ...newDevice, topic: e.target.value })}
      />
      <Button
        variant="contained" fullWidth startIcon={<AddIcon />} onClick={handleCreate}
        sx={{ textTransform: 'none' }}
      >
        TẠO THIẾT BỊ
      </Button>

      <Snackbar
        open={snack.open} autoHideDuration={3000}
        onClose={() => setSnack(prev => ({ ...prev, open: false }))}>
        <Alert severity={snack.severity} sx={{ width: '100%' }}>
          {snack.message}
        </Alert>
      </Snackbar>
    </Container>
  );
}

export default App;


// import React, { useEffect, useState, useRef } from 'react';
// import axios from 'axios';
// import mqtt from 'mqtt';
// import {
//   Box, Button, Card, CardContent, Container, Divider,
//   TextField, Typography, Select, MenuItem, FormControl, InputLabel,
//   IconButton, Snackbar, Alert
// } from '@mui/material';
// import SendIcon from '@mui/icons-material/Send';
// import AddIcon from '@mui/icons-material/Add';
// import MicIcon from '@mui/icons-material/Mic';
// import MicOffIcon from '@mui/icons-material/MicOff';

// function App() {
//   const [devices, setDevices] = useState([]);
//   const [newDevice, setNewDevice] = useState({ name: '', topic: '' });
//   const [payloads, setPayloads] = useState({});
//   const [mqttClient, setMqttClient] = useState(null);
//   const [listeningFor, setListeningFor] = useState(null);
//   const recognitionRef = useRef(null);
//   const [snack, setSnack] = useState({ open: false, severity: 'info', message: '' });

//   const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition || null;

//   // --- Kết nối MQTT & đồng bộ thiết bị ---
//   // useEffect(() => {
//   //   fetchDevices(); // tải ban đầu

//   //   // const client = mqtt.connect('ws://localhost:9001');
//   //   const client = mqtt.connect("ws://localhost:9001", {
//   //     reconnectPeriod: 2000,
//   //     connectTimeout: 5000,
//   //     clean: true,
//   //   });
//   //   setMqttClient(client);

//   //   client.on('connect', () => {
//   //     console.log('✅ Web connected to MQTT broker');
//   //     client.subscribe('/sensor/#');
//   //     client.subscribe('/devices/update');
//   //   });

//   //   client.on('message', (topic, message) => {
//   //     const payload = message.toString();
//   //     console.log('📩 MQTT:', topic, payload);

//   //     // Khi backend publish /devices/update → tải lại danh sách
//   //     if (topic === '/devices/update') {
//   //       fetchDevices();
//   //       return;
//   //     }

//   //     // Cập nhật trạng thái riêng cho thiết bị
//   //     setDevices(prev =>
//   //       prev.map(d => (d.topic === topic ? { ...d, status: payload } : d))
//   //     );
//   //   });

//   //   client.on('error', (err) => {
//   //     console.error('MQTT error', err);
//   //     setSnack({ open: true, severity: 'error', message: 'Lỗi kết nối MQTT' });
//   //   });

//   //   return () => {
//   //     client.end();
//   //   };
//   // }, []);
//   useEffect(() => {
//     fetchDevices(); // tải danh sách thiết bị ban đầu

//     const client = mqtt.connect("ws://localhost:9001", {
//       reconnectPeriod: 2000,
//       connectTimeout: 5000,
//       clean: true,
//     });

//     setMqttClient(client);

//     client.on("connect", () => {
//       console.log("✅ Web connected to MQTT broker");
//       setSnack({ open: true, severity: "success", message: "Kết nối MQTT thành công!" });
//       client.subscribe("/sensor/#");
//       client.subscribe("/devices/update");
//     });

//     client.on("error", (err) => {
//       console.error("❌ MQTT error", err);
//       setSnack({ open: true, severity: "error", message: "Lỗi kết nối MQTT" });
//     });

//     client.on("close", () => {
//       console.warn("⚠️ MQTT connection closed");
//     });

//     client.on("message", (topic, message) => {
//       const payload = message.toString();
//       console.log("📩 MQTT:", topic, payload);
//       if (topic === "/devices/update") fetchDevices();
//     });

//     return () => client.end();
//   }, []);

//   // --- REST: lấy danh sách thiết bị ---
//   const fetchDevices = async () => {
//     try {
//       const res = await axios.get('http://localhost:8080/devices');
//       setDevices(res.data);
//       const initPayloads = {};
//       res.data.forEach(d => (initPayloads[d.id] = d.status || 'LED_OFF'));
//       setPayloads(initPayloads);
//     } catch (err) {
//       console.error('fetchDevices error', err);
//       setSnack({ open: true, severity: 'error', message: 'Không thể tải danh sách thiết bị' });
//     }
//   };

//   // --- Gửi lệnh qua MQTT + REST đồng bộ ---
//   const publishAndUpdate = (topic, payload, deviceId) => {
//     if (mqttClient?.connected) mqttClient.publish(topic, payload);
//     setDevices(prev =>
//       prev.map(d => (d.id === deviceId ? { ...d, status: payload } : d))
//     );
//     setPayloads(prev => ({ ...prev, [deviceId]: payload }));
//   };

//   // --- Thêm thiết bị mới ---
//   const handleCreate = async () => {
//     if (!newDevice.name || !newDevice.topic) {
//       setSnack({ open: true, severity: 'warning', message: 'Nhập đầy đủ thông tin!' });
//       return;
//     }
//     try {
//       const res = await axios.post('http://localhost:8080/devices', newDevice);
//       const created = res.data;
//       setDevices(prev => [...prev, created]);
//       setPayloads(prev => ({ ...prev, [created.id]: created.status || 'LED_OFF' }));
//       setNewDevice({ name: '', topic: '' });
//       setSnack({ open: true, severity: 'success', message: 'Thêm thiết bị thành công!' });
//     } catch (err) {
//       console.error(err);
//       setSnack({ open: true, severity: 'error', message: 'Không thể thêm thiết bị' });
//     }
//   };

//   // --- Gửi lệnh tuỳ chỉnh ---
//   const handleSend = async (id) => {
//     const device = devices.find(d => d.id === id);
//     const payload = payloads[id];
//     try {
//       await axios.post(`http://localhost:8080/devices/${id}/control`, payload, {
//         headers: { 'Content-Type': 'text/plain' },
//       });
//       publishAndUpdate(device.topic, payload, id);
//       setSnack({ open: true, severity: 'success', message: 'Lệnh đã gửi!' });
//     } catch (err) {
//       console.error(err);
//       setSnack({ open: true, severity: 'error', message: 'Gửi lệnh thất bại!' });
//     }
//   };

//   // --- Bật / Tắt LED ---
//   const handleLedOn = (device) => {
//     publishAndUpdate(device.topic, 'LED_ON', device.id);
//     axios.post(`http://localhost:8080/devices/${device.id}/led/on`);
//   };

//   const handleLedOff = (device) => {
//     publishAndUpdate(device.topic, 'LED_OFF', device.id);
//     axios.post(`http://localhost:8080/devices/${device.id}/led/off`);
//   };

//   // --- Voice Control ---
//   const startListeningFor = (device) => {
//     if (!SpeechRecognition) {
//       setSnack({ open: true, severity: 'warning', message: 'Trình duyệt không hỗ trợ giọng nói' });
//       return;
//     }

//     if (listeningFor !== null) stopListening();

//     const recognition = new SpeechRecognition();
//     recognition.lang = 'vi-VN';
//     recognition.interimResults = false;

//     recognition.onstart = () => setListeningFor(device.id);
//     recognition.onresult = (e) => {
//       const text = e.results[0][0].transcript.toLowerCase();
//       console.log('🎤 Nghe:', text);
//       let payload = null;
//       if (text.includes('bật') || text.includes('mở') || text.includes('on')) payload = 'LED_ON';
//       else if (text.includes('tắt') || text.includes('đóng') || text.includes('off')) payload = 'LED_OFF';
//       if (payload) {
//         publishAndUpdate(device.topic, payload, device.id);
//         axios.post(`http://localhost:8080/devices/${device.id}/control`, payload, {
//           headers: { 'Content-Type': 'text/plain' },
//         });
//         setSnack({ open: true, severity: 'success', message: `Đã gửi lệnh ${payload}` });
//       } else {
//         setSnack({ open: true, severity: 'info', message: `Không hiểu lệnh: "${text}"` });
//       }
//     };
//     recognition.onend = () => setListeningFor(null);
//     recognition.onerror = (e) => {
//       console.error('Speech error', e);
//       setListeningFor(null);
//     };
//     recognition.start();
//     recognitionRef.current = recognition;
//   };

//   const stopListening = () => {
//     if (recognitionRef.current) {
//       try { recognitionRef.current.stop(); } catch {}
//       recognitionRef.current = null;
//     }
//     setListeningFor(null);
//   };

//   return (
//     <Container maxWidth="sm" sx={{ mt: 4 }}>
//       <Typography variant="h4" textAlign="center" fontWeight="bold" gutterBottom>
//         📡 IoT Device Controller
//       </Typography>

//       <Typography variant="h6" gutterBottom>📋 Danh sách thiết bị</Typography>
//       {devices.map((device) => (
//         <Card
//           key={device.id}
//           sx={{
//             mb: 2,
//             backgroundColor: device.status === 'LED_ON' ? '#e0ffe0' : '#ffe0e0',
//           }}
//         >
//           <CardContent>
//             <Box display="flex" alignItems="center" justifyContent="space-between">
//               <Box>
//                 <Typography fontWeight="bold">{device.name}</Typography>
//                 <Typography variant="body2">Topic: {device.topic}</Typography>
//               </Box>
//               <IconButton
//                 color={listeningFor === device.id ? 'error' : 'primary'}
//                 onClick={() =>
//                   listeningFor === device.id ? stopListening() : startListeningFor(device)
//                 }
//               >
//                 {listeningFor === device.id ? <MicOffIcon /> : <MicIcon />}
//               </IconButton>
//             </Box>

//             <FormControl fullWidth sx={{ mt: 1, mb: 2 }}>
//               <InputLabel>Lệnh điều khiển</InputLabel>
//               <Select
//                 value={payloads[device.id] || 'LED_OFF'}
//                 label="Lệnh điều khiển"
//                 onChange={(e) => {
//                   const newVal = e.target.value;
//                   setPayloads({ ...payloads, [device.id]: newVal });
//                   setDevices(prev =>
//                     prev.map(d => (d.id === device.id ? { ...d, status: newVal } : d))
//                   );
//                 }}
//               >
//                 <MenuItem value="LED_ON">LED_ON</MenuItem>
//                 <MenuItem value="LED_OFF">LED_OFF</MenuItem>
//               </Select>
//             </FormControl>

//             <Box display="flex" justifyContent="flex-end" gap={1}>
//               <Button variant="contained" onClick={() => handleSend(device.id)} endIcon={<SendIcon />}>
//                 GỬI
//               </Button>
//               <Button variant="contained" color="success" onClick={() => handleLedOn(device)}>
//                 BẬT
//               </Button>
//               <Button variant="contained" color="error" onClick={() => handleLedOff(device)}>
//                 TẮT
//               </Button>
//             </Box>
//           </CardContent>
//         </Card>
//       ))}

//       <Divider sx={{ my: 3 }} />

//       <Typography variant="h6" gutterBottom>➕ Thêm thiết bị mới</Typography>
//       <TextField
//         fullWidth label="Tên thiết bị" variant="outlined" sx={{ mb: 2 }}
//         value={newDevice.name} onChange={(e) => setNewDevice({ ...newDevice, name: e.target.value })}
//       />
//       <TextField
//         fullWidth label="Topic MQTT" variant="outlined" sx={{ mb: 2 }}
//         value={newDevice.topic} onChange={(e) => setNewDevice({ ...newDevice, topic: e.target.value })}
//       />
//       <Button
//         variant="contained" fullWidth startIcon={<AddIcon />} onClick={handleCreate}
//         sx={{ textTransform: 'none' }}
//       >
//         TẠO THIẾT BỊ
//       </Button>

//       <Snackbar
//         open={snack.open} autoHideDuration={3000}
//         onClose={() => setSnack(prev => ({ ...prev, open: false }))}>
//         <Alert severity={snack.severity} sx={{ width: '100%' }}>
//           {snack.message}
//         </Alert>
//       </Snackbar>
//     </Container>
//   );
// }

// export default App;


