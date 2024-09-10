package org.soltalk.soltalk_backend.financial.entity;

import jakarta.persistence.*;
import lombok.*;
import org.soltalk.soltalk_backend.account.entity.Account;

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
