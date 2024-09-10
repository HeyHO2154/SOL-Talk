package org.soltalk.soltalk_backend.financial.dto;

import lombok.*;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class StoreSpendingSummary implements StoreSpendingSummaryDTO {
	private String storeName;
    private int visitCount;
    private int totalAmount;
}
