package org.example;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.boot.context.web.SpringBootServletInitializer;
import org.springframework.boot.devtools.autoconfigure.DevToolsDataSourceAutoConfiguration;
import org.springframework.scheduling.annotation.EnableScheduling;

/**
 * Fires up Spring Boot. A bug in Boot in 1.3.3 requires DevToolsDataSourceAutoConfiguration to be ignored - this bug is
 * slated to be fixed in 1.3.4.
 */
@SpringBootApplication(exclude = DevToolsDataSourceAutoConfiguration.class)
@EnableScheduling
public class App extends SpringBootServletInitializer {

    public static void main(String[] args) {
        SpringApplication.run(App.class, args);
    }
    
    @Override
    protected SpringApplicationBuilder configure(SpringApplicationBuilder application) {
    	return application.sources(App.class);
    }
}