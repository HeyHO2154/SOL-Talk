package com.example.demo;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.web.SecurityFilterChain;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
            .csrf(csrf ->csrf.disable()) // CSRF º¸È£ ºñÈ°¼ºÈ­
            .authorizeHttpRequests((requests) -> requests
                .requestMatchers("/api/register").permitAll() // '/api/register' 경로는 인증 없이 접근 가능
                .requestMatchers("/api/login").permitAll()
                .anyRequest().authenticated() // 그 외의 요청은 인증 필요
            );
        return http.build();
    }
}
