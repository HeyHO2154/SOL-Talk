package org.soltalk.soltalk_backend.financial.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "daily_financial_summary")
public class DailyFinancialSummary {

    // summary 일련번호
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "summary_no")
    private int summaryNo;

    // 사용자 일련번호
    @Column(name = "user_id", nullable = false)
    private int userId;

    // 지출 날짜
    @Column(name = "financial_date", nullable = false)
    private LocalDateTime financialDate;

    // 산출 유형(1: 저축 , 2:소비, 3:수익)
    @Column(name = "financial_type", nullable = false, length = 1)
    private String financialType;

    // 지출 카테고리
    @Column(name = "category", length = 50)
    private String category;

    // 총액(저축/지출 카테고리별)
    @Column(name = "total_amount", precision = 15, nullable = false)
    private int totalAmount;

    // 요약 생성일
    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;

    // 최종 요약 수정일
    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;
}