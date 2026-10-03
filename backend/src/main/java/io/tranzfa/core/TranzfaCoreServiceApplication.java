package io.tranzfa.core;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.properties.ConfigurationPropertiesScan;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;

@EnableMethodSecurity
@EnableScheduling
@SpringBootApplication
@ConfigurationPropertiesScan
public class TranzfaCoreServiceApplication {

    public static void main(String[] args) {
        SpringApplication.run(TranzfaCoreServiceApplication.class, args);
    }
}
