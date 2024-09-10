package org.soltalk.soltalk_backend.domain.financial.controller;

import java.net.URISyntaxException;
import java.util.List;
import java.util.Map;

import lombok.AllArgsConstructor;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.soltalk.soltalk_backend.domain.financial.projection.CategorySpendingSummary;
import org.soltalk.soltalk_backend.domain.financial.dto.StoreSpendingSummaryResponse;
import org.soltalk.soltalk_backend.domain.financial.projection.CategorySpendingAvg;
import org.soltalk.soltalk_backend.domain.financial.projection.FinancialTrend;
import org.soltalk.soltalk_backend.domain.financial.service.FinancialSummaryAnalyzer;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/financial")
@AllArgsConstructor
public class FinancialSummaryController {

    private final FinancialSummaryAnalyzer summaryAnalyzer;
    private static final Logger logger = LoggerFactory.getLogger(FinancialSummaryController.class.getSimpleName());

    /**
     * 최근 30일 지출 상위 카테고리 5개의 지출 합계
     *
     * @param userId
     * @return
     */
    @GetMapping(value = "/top5-categories-amount", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<List<CategorySpendingSummary>> getTop5Categories(@RequestParam("userId") int userId) {
        logger.info("getTop5Categories()...userId:{}", userId);
        List<CategorySpendingSummary> list = summaryAnalyzer.getTop5Categories(userId);
        return ResponseEntity.ok(list);
    }

    /**
     * 최근 30일 지출 상위 카테고리 5개의 동일 연령대 평균 지출 금액
     *
     * @param userId
     * @return
     */
    @GetMapping(value = "/top5-categories-with-avg", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<Map<String, CategorySpendingAvg>> getTop5CategoriesWithAvg(@RequestParam("userId") int userId) {
        logger.info("getTop5CategoriesWithAvg()...userId:{}", userId);
        return ResponseEntity.ok(summaryAnalyzer.getTop5CategoriesWithAvg(userId));
    }

    /**
     * 최근 30일의 이전 30일 대비 지출 증감 (지출 상위 10개 카테고리)
     *
     * @param userId
     * @return
     */
    @GetMapping(value = "/spending-trends", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<List<FinancialTrend>> getSpendingTrends(@RequestParam("userId") int userId) {
        logger.info("getSpendingTrends()...userId:{}", userId);
        return ResponseEntity.ok(summaryAnalyzer.getSpendingTrends(userId));
    }

    /**
     * 최근 7일 카테고리별 지출 합계
     *
     * @param userId
     * @return
     */
    @GetMapping(value = "/last7-days-spending", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<List<CategorySpendingSummary>> getLast7DaysSpending(@RequestParam("userId") int userId) {
        logger.info("getLast7DaysSpending()...userId:{}", userId);
        return ResponseEntity.ok(summaryAnalyzer.getLast7DaysSpending(userId));
    }

    /**
     * 최근 7일간 가장 지출이 많았던 카테고리 소비 요약 정보
     *
     * @param userId
     * @return
     * @throws URISyntaxException
     */
    @GetMapping(value = "/highest-spending-details", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<List<StoreSpendingSummaryResponse>> getCategoryDetails(@RequestParam("userId") int userId) throws URISyntaxException {
        logger.info("getCategoryDetails()...userId:{}", userId);
        return ResponseEntity.ok(summaryAnalyzer.getCategoryDetails(userId));
    }

    /**
     * 미사용 -
     * 최근 한달, 전월 대비 소비 증가율이 가장 높은 카테고리 중 가장 지출이 높은 keyword
     *
     * @param userId
     * @return
     * @throws URISyntaxException
     */
    @GetMapping(value = "/highest-spending-growth-keyword", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<String> getKeywordWithHighestSpendingGrowth(@RequestParam("userNo") int userId) throws URISyntaxException {
        logger.info("getKeywordWithHighestSpendingGrowth()...userId:{}", userId);
        return ResponseEntity.ok(summaryAnalyzer.getKeywordWithHighestSpendingGrowth(userId));
    }

    /**
     * 최근 한달, 전월 대비 소비 증가율이 가장 높은 카테고리
     *
     * @param userId
     * @return
     * @throws URISyntaxException
     */
    @GetMapping(value = "highest-spending-growth-category", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<String> getCategoryWithHighestSpendingGrowth(@RequestParam("userNo") int userId) throws URISyntaxException {
        logger.info("getCategoryWithHighestSpendingGrowth()...userId:{}", userId);
        return ResponseEntity.ok(summaryAnalyzer.getCategoryWithHighestSpendingGrowth(userId));
    }

    /**
     * 최근 한달 지출 총액
     *
     * @param userId
     * @return
     */
    @GetMapping(value = "/total-spending", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<Integer> getTotalSpendingForMonth(@RequestParam("userId") int userId) {
        logger.info("getTotalSpendingForMonth()...userId:{}", userId);
        return ResponseEntity.ok(summaryAnalyzer.getTotalSpendingForMonth(userId));
    }

    /**
     * 저축 계좌 잔액 (총 저축액)
     *
     * @param userId
     * @return
     * @throws URISyntaxException
     */
    @GetMapping(value = "/total-savings-amount", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<Integer> getTotalSavingsAmount(@RequestParam("userId") int userId) throws URISyntaxException {
        logger.info("getTotalSavingsAmount()...userId:{}", userId);
        return ResponseEntity.ok(summaryAnalyzer.getTotalSavingsAmount(userId));
    }


    /**
     * 사용자 금융 상태 분석 점수
     * 저축 점수 : 기본 100 + 지난 달 대비 이번 달 저축 증감률 (0 ~ 200)
     * 지출 점수 : 기본 100 - 지난 달 대비 이번 달 소비 증감률 (0 ~ 200)
     * >> 분석 점수 : (저축 + 지출)/4 > 0 ~ 100점까지 (소수점 두자리 수까지 반환)
     * = 기본 50 + (저축 점수 + 지출 점수)/4
     *
     * @param userId
     * @return
     */
    @GetMapping(value = "/financial-score", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<Integer> getFinancialScore(@RequestParam("userId") int userId) {
        logger.info("getFinancialScore()...userNo:{}", userId);
        return ResponseEntity.ok(summaryAnalyzer.getFinancialScore(userId));
    }


    /**
     * 최근 한달 지출 상위 3개 카테고리
     *
     * @param userId
     * @return
     */
    @GetMapping(value = "/top3-categories", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<String[]> getTop3Categories(@RequestParam("userId") int userId) {
        logger.info("getTop3Categories()...userId:{}", userId);
        return ResponseEntity.ok(summaryAnalyzer.getTop3Categories(userId));
    }
}