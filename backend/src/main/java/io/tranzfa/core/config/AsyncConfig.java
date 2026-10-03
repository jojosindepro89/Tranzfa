package io.tranzfa.core.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.scheduling.concurrent.ThreadPoolTaskExecutor;

import java.util.concurrent.Executor;

@Configuration
@EnableAsync
public class AsyncConfig {

    private final AppProperties appProperties;

    public AsyncConfig(AppProperties appProperties) {
        this.appProperties = appProperties;
    }

    @Bean(name = "taskExecutor")
    public Executor taskExecutor() {
        ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
        AppProperties.Async async = appProperties.async();
        executor.setCorePoolSize(async != null ? async.corePoolSize() : 4);
        executor.setMaxPoolSize(async != null ? async.maxPoolSize() : 10);
        executor.setQueueCapacity(async != null ? async.queueCapacity() : 50);
        executor.setThreadNamePrefix(async != null && async.threadNamePrefix() != null ? async.threadNamePrefix() : "TranzfaAsync-");
        executor.initialize();
        return executor;
    }
}
