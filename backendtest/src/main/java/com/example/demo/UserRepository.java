package com.example.demo;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByUsername(String username); // 사용자 이름으로 검색
    Optional<User> findByEmail(String email);       // 이메일로 검색 (이메일을 사용하려면)
}
