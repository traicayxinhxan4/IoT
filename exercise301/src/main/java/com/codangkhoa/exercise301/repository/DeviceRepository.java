package com.codangkhoa.exercise301.repository;

import com.codangkhoa.exercise301.model.Device;
import org.springframework.data.jpa.repository.JpaRepository;

public interface DeviceRepository extends JpaRepository<Device, Long> {
}
