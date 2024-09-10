package org.soltalk.soltalk_backend.domain.financial.projection;

public interface FinancialTrend {
    String getCategory();
    int getTotalAmount();
    int getTotalAmountBefore();
    int getDifference();
    int getPercentChange();
}
