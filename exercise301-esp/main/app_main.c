#include <stdio.h>
#include <stdint.h>
#include <stddef.h>
#include <string.h>
#include "esp_wifi.h"
#include "esp_system.h"
#include "nvs_flash.h"
#include "esp_event.h"
#include "esp_netif.h"
#include "protocol_examples_common.h"

#include "freertos/FreeRTOS.h"
#include "freertos/task.h"

#include "lwip/sockets.h"
#include "lwip/dns.h"
#include "lwip/netdb.h"

#include "esp_log.h"
#include "mqtt_client.h"
#include "driver/gpio.h"

static const char *TAG = "MQTT_EX301";

#define ESP_WIFI_SSID "Thanh Hieu"
#define ESP_WIFI_PASS "03031982"
#define ESP_BROKER_URI "mqtt://192.168.1.8:1883"

// Dùng GPIO4 cho LED ngoài (không bị chiếm dụng)
#define LED_GPIO GPIO_NUM_4

// MQTT topics
#define TOPIC_CONTROL "/sensor/led"   // ESP sẽ subscribe topic này

uint32_t MQTT_CONNECTED = 0;
esp_mqtt_client_handle_t client = NULL;

static void mqtt_app_start(void);

static void wifi_event_handler(void *arg, esp_event_base_t event_base,
                               int32_t event_id, void *event_data)
{
    if (event_base == WIFI_EVENT) {
        if (event_id == WIFI_EVENT_STA_START) {
            esp_wifi_connect();
            ESP_LOGI(TAG, "Connecting to WiFi...");
        } else if (event_id == WIFI_EVENT_STA_DISCONNECTED) {
            ESP_LOGI(TAG, "Disconnected, retrying WiFi...");
            esp_wifi_connect();
        }
    } else if (event_base == IP_EVENT && event_id == IP_EVENT_STA_GOT_IP) {
        ESP_LOGI(TAG, "Got IP -> starting MQTT client");
        mqtt_app_start();
    }
}

void wifi_init(void)
{
    ESP_ERROR_CHECK(esp_netif_init());
    ESP_ERROR_CHECK(esp_event_loop_create_default());
    esp_netif_create_default_wifi_sta();

    wifi_init_config_t cfg = WIFI_INIT_CONFIG_DEFAULT();
    ESP_ERROR_CHECK(esp_wifi_init(&cfg));

    ESP_ERROR_CHECK(esp_event_handler_instance_register(WIFI_EVENT,
                                                        ESP_EVENT_ANY_ID,
                                                        &wifi_event_handler,
                                                        NULL, NULL));
    ESP_ERROR_CHECK(esp_event_handler_instance_register(IP_EVENT,
                                                        IP_EVENT_STA_GOT_IP,
                                                        &wifi_event_handler,
                                                        NULL, NULL));

    wifi_config_t wifi_config = {
        .sta = {
            .ssid = ESP_WIFI_SSID,
            .password = ESP_WIFI_PASS,
            .threshold.authmode = (strlen(ESP_WIFI_PASS) == 0) ? WIFI_AUTH_OPEN : WIFI_AUTH_WPA2_PSK,
        },
    };
    ESP_ERROR_CHECK(esp_wifi_set_mode(WIFI_MODE_STA));
    ESP_ERROR_CHECK(esp_wifi_set_config(WIFI_IF_STA, &wifi_config));
    ESP_ERROR_CHECK(esp_wifi_start());
}

static void mqtt_event_handler(void *handler_args, esp_event_base_t base,
                               int32_t event_id, void *event_data)
{
    esp_mqtt_event_handle_t event = event_data;
    client = event->client;
    int msg_id;

    switch ((esp_mqtt_event_id_t)event_id) {
    case MQTT_EVENT_CONNECTED:
        ESP_LOGI(TAG, "MQTT connected");
        MQTT_CONNECTED = 1;

        // Subscribe control topic
        msg_id = esp_mqtt_client_subscribe(client, TOPIC_CONTROL, 1);
        ESP_LOGI(TAG, "Subscribed to %s, msg_id=%d", TOPIC_CONTROL, msg_id);
        break;

    case MQTT_EVENT_DISCONNECTED:
        ESP_LOGI(TAG, "MQTT disconnected");
        MQTT_CONNECTED = 0;
        break;

    case MQTT_EVENT_DATA: {
        char topic[128], data[128];
        snprintf(topic, event->topic_len + 1, "%.*s", event->topic_len, event->topic);
        snprintf(data, event->data_len + 1, "%.*s", event->data_len, event->data);

        ESP_LOGI(TAG, "Received topic: %s, data: %s", topic, data);

        if (strcmp(data, "LED_ON") == 0) {
            gpio_set_level(LED_GPIO, 1);   // 1 = sáng LED ngoài
            ESP_LOGI(TAG, "LED OUTSIDE turned ON (GPIO4)");
        } else if (strcmp(data, "LED_OFF") == 0) {
            gpio_set_level(LED_GPIO, 0);   // 0 = tắt LED ngoài
            ESP_LOGI(TAG, "LED OUTSIDE turned OFF (GPIO4)");
        }
        break;
    }

    default:
        break;
    }
}

static void mqtt_app_start(void)
{
    esp_mqtt_client_config_t mqttConfig = {
        .broker.address.uri = ESP_BROKER_URI,
    };
    client = esp_mqtt_client_init(&mqttConfig);
    esp_mqtt_client_register_event(client, ESP_EVENT_ANY_ID, mqtt_event_handler, NULL);
    esp_mqtt_client_start(client);
}

void app_main(void)
{
    // Init flash
    esp_err_t ret = nvs_flash_init();
    if (ret == ESP_ERR_NVS_NO_FREE_PAGES || ret == ESP_ERR_NVS_NEW_VERSION_FOUND) {
        ESP_ERROR_CHECK(nvs_flash_erase());
        ret = nvs_flash_init();
    }
    ESP_ERROR_CHECK(ret);

    // Init LED pin
    gpio_reset_pin(LED_GPIO);
    gpio_set_direction(LED_GPIO, GPIO_MODE_OUTPUT);
    gpio_set_level(LED_GPIO, 0);  // mặc định LED ngoài tắt

    // Init WiFi
    wifi_init();
}
