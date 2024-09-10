package org.soltalk.soltalk_backend.domain.transaction.entity;

import jakarta.persistence.*;
import lombok.*;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "expense_category")
public class ExpenseCategory {

    // 카테고리 일련번호 - pk
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "category_id")
    private int categoryId;

    // 카테고리 이름
    @Column(name = "name", nullable = false, length = 50)
    private String name;
}
