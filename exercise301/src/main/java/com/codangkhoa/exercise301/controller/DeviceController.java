// package com.codangkhoa.exercise301.controller;

// import com.codangkhoa.exercise301.model.Device;
// import com.codangkhoa.exercise301.repository.DeviceRepository;
// import com.codangkhoa.exercise301.service.MqttPublisherService;
// import org.springframework.beans.factory.annotation.Autowired;
// import org.springframework.integration.mqtt.inbound.MqttPahoMessageDrivenChannelAdapter;
// import org.springframework.web.bind.annotation.*;

// import java.util.List;

// @RestController
// @RequestMapping("/devices")
// public class DeviceController {

//     @Autowired
//     private DeviceRepository deviceRepository;

//     @Autowired
//     private MqttPublisherService mqttPublisherService;

//     @Autowired
//     private MqttPahoMessageDrivenChannelAdapter mqttAdapter;

//     // Lấy tất cả device (kèm status)
//     @GetMapping
//     public List<Device> getAllDevices() {
//         return deviceRepository.findAll();
//     }

//     // Thêm mới device
//     @PostMapping
//     public Device createDevice(@RequestBody Device device) {
//         device.setStatus("LED_OFF"); // mặc định tắt
//         mqttAdapter.addTopic(device.getTopic(), 1);
//         return deviceRepository.save(device);
//     }

//     // Điều khiển chung bằng payload
//     @PostMapping("/{id}/control")
//     public String controlDevice(@PathVariable Long id, @RequestBody String payload) {
//         Device device = deviceRepository.findById(id).orElse(null);
//         if (device != null) {
//             mqttPublisherService.publish(device.getTopic(), payload);
//             device.setStatus(payload);   // ✅ cập nhật trạng thái
//             deviceRepository.save(device);
//             return "Published to " + device.getTopic();
//         }
//         return "Device not found";
//     }

//     @PostMapping("/{id}/led/{status}")
//     public String controlLed(@PathVariable Long id, @PathVariable String status) {
//         Device device = deviceRepository.findById(id).orElse(null);
//         if (device != null) {
//             if ("on".equalsIgnoreCase(status)) {
//                 mqttPublisherService.publish(device.getTopic(), "LED_ON");
//                 device.setStatus("LED_ON");   // ✅ cập nhật DB
//             } else if ("off".equalsIgnoreCase(status)) {
//                 mqttPublisherService.publish(device.getTopic(), "LED_OFF");
//                 device.setStatus("LED_OFF");  // ✅ cập nhật DB
//             }
//             deviceRepository.save(device);
//             return "LED status updated for " + device.getTopic();
//         }
//         return "Device not found";
//     }
// }

// package com.codangkhoa.exercise301.controller;

// import com.codangkhoa.exercise301.model.Device;
// import com.codangkhoa.exercise301.repository.DeviceRepository;
// import com.codangkhoa.exercise301.service.MqttPublisherService;
// import org.springframework.beans.factory.annotation.Autowired;
// import org.springframework.integration.mqtt.inbound.MqttPahoMessageDrivenChannelAdapter;
// import org.springframework.web.bind.annotation.*;

// import java.util.List;

// @RestController
// @RequestMapping("/devices")
// public class DeviceController {

//     @Autowired
//     private DeviceRepository deviceRepository;

//     @Autowired
//     private MqttPublisherService mqttPublisherService;

//     @Autowired
//     private MqttPahoMessageDrivenChannelAdapter mqttAdapter;

//     // 🔹 Lấy tất cả thiết bị (kèm trạng thái)
//     @GetMapping
//     public List<Device> getAllDevices() {
//         return deviceRepository.findAll();
//     }

//     // 🔹 Thêm thiết bị mới (tự động subscribe MQTT topic + broadcast)
//     @PostMapping
//     public Device createDevice(@RequestBody Device device) {
//         device.setStatus("LED_OFF"); // Mặc định tắt
//         mqttAdapter.addTopic(device.getTopic(), 1);
//         Device saved = deviceRepository.save(device);

//         // 🔸 Gửi thông báo MQTT để đồng bộ sang web/app khác
//         mqttPublisherService.publish("devices/update", "NEW_DEVICE");

//         return saved;
//     }

//     // 🔹 Điều khiển bằng payload (tự do)
//     @PostMapping("/{id}/control")
//     public String controlDevice(@PathVariable Long id, @RequestBody String payload) {
//         Device device = deviceRepository.findById(id).orElse(null);
//         if (device != null) {
//             mqttPublisherService.publish(device.getTopic(), payload);
//             device.setStatus(payload);
//             deviceRepository.save(device);

//             // 🔸 Gửi thông báo cập nhật trạng thái cho các client khác
//             mqttPublisherService.publish("devices/update", "STATE_CHANGED");

//             return "Published to " + device.getTopic();
//         }
//         return "Device not found";
//     }

//     // 🔹 Bật / tắt LED (điều khiển cụ thể)
//     @PostMapping("/{id}/led/{status}")
//     public String controlLed(@PathVariable Long id, @PathVariable String status) {
//         Device device = deviceRepository.findById(id).orElse(null);
//         if (device != null) {
//             if ("on".equalsIgnoreCase(status)) {
//                 mqttPublisherService.publish(device.getTopic(), "LED_ON");
//                 device.setStatus("LED_ON");
//             } else if ("off".equalsIgnoreCase(status)) {
//                 mqttPublisherService.publish(device.getTopic(), "LED_OFF");
//                 device.setStatus("LED_OFF");
//             }
//             deviceRepository.save(device);

//             // 🔸 Báo cho web/app reload danh sách
//             mqttPublisherService.publish("devices/update", "STATE_CHANGED");

//             return "LED status updated for " + device.getTopic();
//         }
//         return "Device not found";
//     }
// }


package com.codangkhoa.exercise301.controller;

import com.codangkhoa.exercise301.model.Device;
import com.codangkhoa.exercise301.repository.DeviceRepository;
import com.codangkhoa.exercise301.service.MqttPublisherService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.integration.mqtt.inbound.MqttPahoMessageDrivenChannelAdapter;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/devices")
public class DeviceController {

    @Autowired
    private DeviceRepository deviceRepository;

    @Autowired
    private MqttPublisherService mqttPublisherService;

    @Autowired
    private MqttPahoMessageDrivenChannelAdapter mqttAdapter;

    // 🔹 Lấy tất cả thiết bị
    @GetMapping
    public List<Device> getAllDevices() {
        return deviceRepository.findAll();
    }

    // 🔹 Thêm thiết bị mới (tự động subscribe + broadcast)
    @PostMapping
    public Device createDevice(@RequestBody Device device) {
        device.setStatus("LED_OFF"); // mặc định tắt

        // Tránh trùng topic
        if (!List.of(mqttAdapter.getTopic()).contains(device.getTopic())) {
            mqttAdapter.addTopic(device.getTopic(), 1);
        }

        Device saved = deviceRepository.save(device);

        // 🔸 Thông báo cho tất cả client cập nhật danh sách
        mqttPublisherService.publish("/devices/update", "NEW_DEVICE");

        return saved;
    }

    // 🔹 Điều khiển tự do (payload)
    @PostMapping("/{id}/control")
    public String controlDevice(@PathVariable Long id, @RequestBody String payload) {
        Device device = deviceRepository.findById(id).orElse(null);
        if (device != null) {
            device.setStatus(payload);
            deviceRepository.save(device);

            mqttPublisherService.publish(device.getTopic(), payload);
            mqttPublisherService.publish("/devices/update", "STATE_CHANGED");

            return "Published " + payload + " to " + device.getTopic();
        }
        return "Device not found";
    }

    // 🔹 Điều khiển bật/tắt LED cụ thể
    @PostMapping("/{id}/led/{status}")
    public String controlLed(@PathVariable Long id, @PathVariable String status) {
        Device device = deviceRepository.findById(id).orElse(null);
        if (device != null) {
            if ("on".equalsIgnoreCase(status)) {
                device.setStatus("LED_ON");
                deviceRepository.save(device);
                mqttPublisherService.publish(device.getTopic(), "LED_ON");
            } else if ("off".equalsIgnoreCase(status)) {
                device.setStatus("LED_OFF");
                deviceRepository.save(device);
                mqttPublisherService.publish(device.getTopic(), "LED_OFF");
            }

            // 🔸 Báo cho các client khác
            mqttPublisherService.publish("/devices/update", "STATE_CHANGED");

            return "LED status updated for " + device.getTopic();
        }
        return "Device not found";
    }
}

