package org.soltalk.soltalk_backend.financial.dto;

import lombok.*;
import org.soltalk.soltalk_backend.financial.projection.StoreSpendingSummary;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class StoreSpendingSummaryResponse implements StoreSpendingSummary {
	private String storeName;
    private int visitCount;
    private int totalAmount;

}
