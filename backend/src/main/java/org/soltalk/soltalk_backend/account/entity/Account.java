package org.soltalk.soltalk_backend.account.entity;

import java.time.LocalDate;
import java.time.LocalDateTime;

import org.soltalk.soltalk_backend.user.entity.User;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "accounts")
public class Account {

    // 계좌번호(PK)
    @Id
    @Column(name = "account_no", nullable = false, length = 50)
    private String accountNo;

    // 사용자 객체
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    // 계좌 잔액 (소수점 2자리까지)
    @Column(name = "balance", precision = 15, scale = 2, nullable = false)
    private Double balance;

    // 계좌 유형(1:저축 2:입출금)
    @Column(name = "account_type", length = 1, nullable = false)
    private String accountType;

    // 계좌 생성일
    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;

    // 최종 계좌 수정일
    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

}