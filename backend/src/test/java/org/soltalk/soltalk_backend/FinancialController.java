package org.soltalk.soltalk_backend;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/financial")
public class FinancialController {

    @Autowired
    private FinancialAnalysisService financialAnalysisService;

    // 최근 7일 금융 거래 내역 분석 API
    @GetMapping("/analyze/recent")
    public String getRecentTransactionAnalysis(@RequestParam int userId) {
        return financialAnalysisService.analyzeRecentTransactions(userId);
    }

    // 지난 30일 지출 내역 분석 API
    @GetMapping("/analyze/spending-growth")
    public String getSpendingGrowthAnalysis(@RequestParam int userId) {
        return financialAnalysisService.analyzeSpendingGrowth(userId);
    }
}
