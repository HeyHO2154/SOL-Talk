package org.soltalk.soltalk_backend.financial.dto;

public interface FinancialTrendDTO {
    String getCategory();
    int getTotalAmount();
    int getTotalAmountBefore();
    int getDifference();
    int getPercentChange();
}
