package org.soltalk.soltalk_backend.domain.user.entity;

import java.time.LocalDateTime;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "users")
@EntityListeners(AuditingEntityListener.class)  // Auditing 활성화 (날짜 갱신)
public class User {

    // 사용자 일련번호 - PK
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "user_id")
    private int userId;

    // 사용자 로그인 ID
    @Column(name = "login_id", nullable = false, length = 50)
    private String loginId;

    // 사용자 비밀번호
    @Column(name = "password", nullable = false, length = 255)
    private String password;

    // 사용자 이름
    @Column(name = "name", nullable = false, length = 50)
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

    // 성별
    @Enumerated(EnumType.STRING)
    @Column(name = "gender", nullable = false)
    private Gender gender;

    // 사용자 API KEY
    @Column(name = "user_key", length = 125)
    private String userKey;

    // 계정 생성일
    @CreatedDate
    private LocalDateTime createdAt;

    // 최종 계정 수정일
    @LastModifiedDate
    private LocalDateTime updatedAt;
}
