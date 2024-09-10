package org.soltalk.soltalk_backend.financial.projection;

public interface FinancialTrend {
    String getCategory();
    int getTotalAmount();
    int getTotalAmountBefore();
    int getDifference();
    int getPercentChange();
}
