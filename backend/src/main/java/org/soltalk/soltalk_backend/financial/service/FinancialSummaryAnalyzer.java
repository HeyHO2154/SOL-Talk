package org.soltalk.soltalk_backend.financial.service;

import java.net.URISyntaxException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.soltalk.soltalk_backend.financial.projection.FinancialTrend;
import org.soltalk.soltalk_backend.financial.projection.UserCategory;
import org.springframework.stereotype.Service;

import org.soltalk.soltalk_backend.financial.projection.AccountKey;
import org.soltalk.soltalk_backend.financial.projection.CategorySpendingAvg;
import org.soltalk.soltalk_backend.financial.dto.CategorySpendingSummaryDTO;
import org.soltalk.soltalk_backend.financial.dto.StoreSpendingSummaryResponse;
import org.soltalk.soltalk_backend.financial.projection.UserCategory;
import org.soltalk.soltalk_backend.financial.repository.FinancialSummaryRepository;
import org.soltalk.soltalk_backend.account.repository.AccountRepository;

import lombok.AllArgsConstructor;

/**
 * 금융 정보 분석
 */
@SuppressWarnings("unused")
@Service
@AllArgsConstructor
public class FinancialSummaryAnalyzer {
	
	private final SpendingSummaryProcessor spendingProcessor;
	private final SavingsCollector savingsCollector;
    private FinancialSummaryRepository summaryRepository;
	private AccountRepository accountRepository;
    private static final Logger logger = LoggerFactory.getLogger(FinancialSummaryAnalyzer.class.getSimpleName());

	/**
	 * 최근 한달 지출 상위 5개 카테고리
	 * @param userId
	 * @return
	 */
    public List<CategorySpendingSummaryDTO> getTop5Categories(int userId) {
        logger.info("getTop5Categories()...userNo:{}", userId);
    	return summaryRepository.findTop5Categories(userId);
    }
    
    /**
     * 최근 한달 지출 상위 5개 카테고리의 동일 연령대 평균 지출 금액
     * @param userId
     * @return
     */
    public Map<String, CategorySpendingAvg> getTop5CategoriesWithAvg(int userId) {
        logger.info("getTop5CategoriesWithAvg()...userId:{}", userId);
    	List<CategorySpendingAvg> list = summaryRepository.findTop5CategoriesWithAvg(userId);
    	Map<String, CategorySpendingAvg> map = new HashMap<String, CategorySpendingAvg>();
    	for(CategorySpendingAvg others : list) {
    		map.put(others.getCategory(), others);
    	}
        return map;
    }
    
    /**
     * 최근 한달 지출 상위 10개 카테고리의 전월 대비 지출 증감
     * @param userId
     * @return
     */
    public List<FinancialTrend> getSpendingTrends(int userId) {
        logger.info("getSpendingTrends()...userId:{}", userId);
    	return summaryRepository.getSpendingTrends(userId);
    }
    
    /**
     * 최근 7일 전체 카테고리별 지출
     * @param userNo
     * @return
     */
    public List<CategorySpendingSummaryDTO> getLast7DaysSpending(int userNo) {
        logger.info("getLast7DaysSpending()...userNo:{}", userNo);
    	return summaryRepository.getLast7DaysSpending(userNo);
    }
    
    /**
     * 최근 7일간 가장 지출이 많은 카테고리의 한달간 지출 내역 요약
     * @param userNo
     * @return
     * @throws URISyntaxException 
     */
    public List<StoreSpendingSummaryResponse> getCategoryDetails(int userNo) throws URISyntaxException {
        logger.info("getCategoryDetails()...userNo:{}", userNo);
    	// 최근 7일간 가장 지출이 많은 카테고리와, 입출금 계좌번호, user_key 받아오기
        UserCategory categoryDTO = summaryRepository.getMostSpendingCategory(userNo);
    	// 최근 30일간 지출처별 지출 내역 요약 정보
    	return spendingProcessor.fetchTransactionDataForMonth(categoryDTO);
    }
    
    
    /** 미사용
     * 최근 한달, 전월 대비 소비 증가율이 가장 높은 카테고리 중 가장 지출이 높은 keyword 반환
     * @param userNo
     * @return
     * @throws URISyntaxException
     */
    public String getKeywordWithHighestSpendingGrowth(int userNo) throws URISyntaxException {
        logger.info("getKeywordWithHighestSpendingGrowth()...userNo:{}", userNo);
    	// 최근 한달, 전월 대비 소비 증가율이 가장 높은 카테고리, 입출금 계좌번호, user_key 받아오기
    	UserCategory categoryDTO = summaryRepository.getCategoryWithHighestSpendingGrowth(userNo);
    	// 최근 30일간 지출처별 지출 내역 요약 정보
    	return spendingProcessor.getKeywordWithCategoryForMonth(categoryDTO);
    }
    
    /**
     * 최근 한달, 전월 대비 소비 증가율이 가장 높은 카테고리
     * @param userNo
     * @return
     * @throws URISyntaxException
     */
    public String getCategoryWithHighestSpendingGrowth(int userNo) throws URISyntaxException {
        logger.info("getCategoryWithHighestSpendingGrowth()...userNo:{}", userNo);
    	return  summaryRepository.findTopCategoryForMonth(userNo);
    }
    /**
     * 최근 한달 지출 총액 > DB에서 합산으로 가져옴
     * @param userNo
     * @return 최근 한달 지출 총액
     */
    public int getTotalSpendingForMonth(int userNo) {
        logger.info("getTotalSpendingForMonth()...userNo:{}", userNo);
    	return summaryRepository.deriveTotalSpendingForMonth(userNo);
    }
    
    /**
     * 여태까지 저축 총액 (계좌 잔액으로)
     * @param userId
     * @return
     * @throws URISyntaxException 
     */
    public int getTotalSavingsAmount(int userId) throws URISyntaxException {
        logger.info("getTotalSavingsAmount()...userId:{}", userId);
    	// 저축 계좌 번호, user_key를 받아옴
    	AccountKey userAccount = summaryRepository.findActiveSavingsAccounts(userId);
    	return savingsCollector.fetchSavingsTotal(userAccount);
    }
    
    /**
     * 금융 점수
     * @param userNo
     * @return
     */
    public int getFinancialScore(int userNo) {
        logger.info("getFinancialScore()...userNo:{}", userNo);
    	return summaryRepository.deriveFinancialScore(userNo);
    }
    
    
    
    /**
     * 최근 한달 지출 상위 3개 카테고리
     * @param userNo
     * @return
     */
    public String[] getTop3Categories(int userNo) {
        logger.info("getTop3Categories()...userNo:{}", userNo);
    	return summaryRepository.findTop3Categories(userNo);
    }
}
