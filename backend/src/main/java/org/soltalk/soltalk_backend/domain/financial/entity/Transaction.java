package org.soltalk.soltalk_backend.domain.financial.entity;

import java.time.LocalDateTime;

import jakarta.persistence.*;
import lombok.*;
import org.soltalk.soltalk_backend.domain.account.entity.Account;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "transactions")
public class Transaction {

    // 거래 일련번호
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "transaction_id")
    private int transactionId;

    // 계좌
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "account_no", nullable = false)
    private Account acccount;

    // 거래 금액
    @Column(name = "amount", nullable = false, precision = 15, scale = 2)
    private Double amount;

    // 거래 유형('IN', 'OUT')
    @Enumerated(EnumType.STRING)
    @Column(name = "transaction_type", nullable = false)
    private TransactionType transactionType;

    // 거래 날짜
    @Column(name = "transaction_date", nullable = false)
    private LocalDateTime transactionDate;

    // 거래 설명
    @Column(name = "description", nullable = false, length = 255)
    private String description;

    // 카테고리
    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "category_id", nullable = false)
    private ExpenseCategory category;
}
