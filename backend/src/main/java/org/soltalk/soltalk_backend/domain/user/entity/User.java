package org.soltalk.soltalk_backend.domain.user.entity;

import java.time.LocalDateTime;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "users")
public class User {

    // 사용자 일련번호 - PK
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "user_id")
    private int userId;

    // 사용자 로그인 ID
    @Column(name = "login_id", nullable = true, length = 50)
    private String loginId;

    // 사용자 비밀번호
    @Column(name = "password", nullable = true, length = 255)
    private String password;

    // 사용자 이름
    @Column(name = "name", nullable = true, length = 50)
    private String name;

    // 사용자 이메일
    @Column(name = "email", nullable = true, length = 100)
    private String email;

    // 사용자 프로필 사진 경로 또는 URL
    @Column(name = "profile_picture", nullable = true, length = 255)
    private String profilePicture;

    // 사용자 생년월일
    @Column(name = "birth", nullable = false)
    private LocalDateTime birth;

    // 사용자 API KEY
    @Column(name = "user_key", length = 125)
    private String userKey;

    // 계정 생성일
    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;

    // 최종 계정 수정일
    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;
}
