package org.soltalk.soltalk_backend;

import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import java.util.*;

@Service
public class FinancialAnalysisService {

    private final RestTemplate restTemplate = new RestTemplate();
    private final String API_BASE_URL = "http://your-api-url/api/financial";

    // 최근 7일 금융 거래 내역 분석
    public String analyzeRecentTransactions(int userId) {
        String url = API_BASE_URL + "/last7-days-spending?userid=" + userId;
        Map<String, Object> response = restTemplate.getForObject(url, Map.class);

        // 예시 분석: 가장 많이 지출한 카테고리 찾기
        List<Map<String, Object>> transactions = (List<Map<String, Object>>) response.get("transactions");
        Map<String, Double> categoryTotals = new HashMap<>();
        for (Map<String, Object> transaction : transactions) {
            String category = (String) transaction.get("category");
            Double amount = (Double) transaction.get("amount");
            categoryTotals.put(category, categoryTotals.getOrDefault(category, 0.0) + amount);
        }

        // 키워드 추출 (가장 많이 지출한 카테고리 반환)
        String mostSpentCategory = categoryTotals.entrySet().stream()
            .max(Comparator.comparingDouble(Map.Entry::getValue))
            .map(Map.Entry::getKey)
            .orElse("Unknown");

        return "최근 7일 동안 가장 많이 지출한 카테고리: " + mostSpentCategory;
    }

    // 지난 30일 지출 내역 분석 (가장 많이 늘어난 부분 찾기)
    public String analyzeSpendingGrowth(int userId) {
        String url = API_BASE_URL + "/highest-spending-growth-category?userid=" + userId;
        Map<String, Object> response = restTemplate.getForObject(url, Map.class);

        // 예시 분석: 가장 지출이 많이 증가한 카테고리 찾기
        String highestGrowthCategory = (String) response.get("category");
        Double growthPercentage = (Double) response.get("growthPercentage");

        return "지난 30일 동안 지출이 가장 많이 증가한 카테고리: " + highestGrowthCategory + " (" + growthPercentage + "% 증가)";
    }
}
