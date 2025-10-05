package com.codangkhoa.exercise301.controller;

import com.codangkhoa.exercise301.model.Telemetry;
import com.codangkhoa.exercise301.repository.TelemetryRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/telemetry")
public class TelemetryController {

    @Autowired
    private TelemetryRepository telemetryRepository;

    @GetMapping("/{deviceId}")
    public List<Telemetry> getByDevice(@PathVariable Long deviceId) {
        return telemetryRepository.findByDeviceId(deviceId);
    }
}
