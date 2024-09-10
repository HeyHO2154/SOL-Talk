package org.soltalk.soltalk_backend;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
@EnableBatchProcessing
@EnableScheduling
public class SoltalkBackendApplication {

	public static void main(String[] args) {
		SpringApplication.run(SoltalkBackendApplication.class, args);
	}

}
