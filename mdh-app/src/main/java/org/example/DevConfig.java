package org.example;

import org.apache.catalina.connector.Connector;
import org.apache.coyote.http11.Http11NioProtocol;
import org.example.util.ModuleWatcher;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.context.embedded.ConfigurableEmbeddedServletContainer;
import org.springframework.boot.context.embedded.EmbeddedServletContainerCustomizer;
import org.springframework.boot.context.embedded.tomcat.TomcatConnectorCustomizer;
import org.springframework.boot.context.embedded.tomcat.TomcatEmbeddedServletContainerFactory;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;
import org.springframework.scheduling.annotation.EnableScheduling;

import com.marklogic.client.helper.DatabaseClientConfig;
import com.marklogic.client.spring.DatabaseClientManager;

/**
 * The beans in this configuration are only intended to be used in a development environment.
 */
@Configuration
@Profile("dev")
@EnableScheduling
public class DevConfig {

    @Value("${mlAppName}")
    protected String mlAppName;

    @Value("${mlHost:localhost}")
    protected String mlHost;

    @Value("${mlRestPort}")
    protected Integer mlRestPort;

    @Value("${mlRestAdminUsername}")
    protected String mlRestAdminUsername;

    @Value("${mlRestAdminPassword}")
    protected String mlRestAdminPassword;

    @Bean
    public DatabaseClientConfig contentDatabaseClientConfig() {
        DatabaseClientConfig config = new DatabaseClientConfig(mlHost, mlRestPort, mlRestAdminUsername,
                mlRestAdminPassword);
        config.setDatabase(mlAppName + "-FINAL");
        return config;
    }

    @Bean
    public DatabaseClientManager contentDatabaseClientManager() {
        return new DatabaseClientManager(contentDatabaseClientConfig());
    }

    @Bean
    public DatabaseClientManager modulesDatabaseClientManager() {
        DatabaseClientConfig config = new DatabaseClientConfig(mlHost, mlRestPort, mlRestAdminUsername,
                mlRestAdminPassword);
        config.setDatabase(mlAppName + "-MODULES");
        return new DatabaseClientManager(config);
    }

    @Bean
    public ModuleWatcher moduleWatcher() {
        return new ModuleWatcher(contentDatabaseClientManager().getObject(),
                modulesDatabaseClientManager().getObject());
    }
    
    
    /**
     * Added a customizer for Tomcat so we can set the Max HTTP Header Size.
     * The search request that includes the additional structured query for ABAWD is
     * 	very large.
     * @return
     */
    @Bean 
    EmbeddedServletContainerCustomizer containerCustomizer() {
    	return new EmbeddedServletContainerCustomizer() {
            @Override
            public void customize(ConfigurableEmbeddedServletContainer container) {
                if(container instanceof TomcatEmbeddedServletContainerFactory) {
                	TomcatEmbeddedServletContainerFactory tomcat = (TomcatEmbeddedServletContainerFactory) container;
                	
                	tomcat.addConnectorCustomizers(
                            new TomcatConnectorCustomizer() {
        						@Override
        						public void customize(Connector connector) {
        	                        
        	                        Http11NioProtocol proto = (Http11NioProtocol) connector
        	    							.getProtocolHandler();
        	    					proto.setMaxHttpHeaderSize(1000000);
        						}
                            });
                	
                }
            }    		
    	};
    }
    
}
