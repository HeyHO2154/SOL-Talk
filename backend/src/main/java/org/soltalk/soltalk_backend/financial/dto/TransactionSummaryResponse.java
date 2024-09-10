package org.soltalk.soltalk_backend.financial.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class TransactionSummaryResponse {
	// 클래스 이름 바꾸기
	
	private String transactionDate;
	private int transactionBalance; // 지출금액
	private String category; // 지출 카테고리
	private String transactionSummary; // 지출내용 - 사장님네 계좌 이름

	@Override
	public String toString() {
		return "Transaction [transactionDate=" + transactionDate  
				+ ", transactionBalance=" + transactionBalance 
				+ ", category=" + category 
				+ ", transactionName=" + transactionSummary + "]";
	}
	
}
